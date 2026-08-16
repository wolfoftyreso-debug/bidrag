"""Tester for API-orkestreringen: pipelineflodet, abstention, confidence-
aggregatet, Atlas-observationer och HTTP-servern end-to-end."""

import base64
import json
import sys
import threading
import unittest
import urllib.request
from pathlib import Path

ROOT = Path(__file__).parents[2]
for sub in ("api", "knowledge", "verification", "translation", "data-contracts", "models"):
    sys.path.insert(0, str(ROOT / sub))

from pipeline import AnalyzePipeline  # noqa: E402
from readers import MockReader, NullReader, build_reader  # noqa: E402
from retrieval import CorpusIndex  # noqa: E402
from server import make_handler  # noqa: E402
from validator import validate_record  # noqa: E402

INSCRIPTIONS = [
    {"inscription_id": "ric-u-9001", "signum": "U 9001", "rune_type": "younger_futhark",
     "region": "Uppland", "transliteration": "iksimbil",
     "coordinates": {"latitude": 59.85, "longitude": 17.63},
     "source_database": "Scandinavian Runic-text Database",
     "source_provider": "Uppsala University",
     "translation_sv": "Syntetisk exempelpost 1.", "scholarly_status": "established"},
    {"inscription_id": "ric-so-9002", "signum": "Sö 9002", "rune_type": "younger_futhark",
     "region": "Sodermanland", "transliteration": "tistil mistil kistil",
     "coordinates": {"latitude": 59.2, "longitude": 17.0},
     "source_database": "Scandinavian Runic-text Database",
     "source_provider": "Uppsala University",
     "translation_sv": None, "scholarly_status": "uncertain"},
]

IMAGE = b"fake-image-bytes"
CONSENT = {"media_storage": True, "training_use": True,
           "consent_version": "consent-v1", "consented_at": "2026-08-15T00:00:00Z"}


def pipeline_with(reader):
    return AnalyzePipeline(CorpusIndex(INSCRIPTIONS), reader)


class AnalyzeFlowTests(unittest.TestCase):
    def test_known_stone_full_result(self):
        p = pipeline_with(MockReader("iksimbil", 0.91))
        out = p.analyze(IMAGE, gps=(59.8501, 17.6302))
        self.assertEqual(out["status"], 200)
        result = out["body"]["result"]
        self.assertEqual(result["stone_id"], "U 9001")
        self.assertEqual(result["translation_sv"], "Syntetisk exempelpost 1.")
        self.assertEqual(result["scholarly_status"], "established")
        self.assertEqual(out["body"]["sources"][0]["inscription"], "U 9001")

    def test_overall_confidence_is_minimum_of_stages(self):
        p = pipeline_with(MockReader("iksimbil", 0.91))
        out = p.analyze(IMAGE, gps=(59.8501, 17.6302))
        stages = out["body"]["stage_confidence"]
        numeric = [v for v in stages.values() if isinstance(v, (int, float))]
        self.assertEqual(out["body"]["result"]["confidence"], round(min(numeric), 4))

    def test_unmeasurable_stages_are_null_not_invented(self):
        p = pipeline_with(MockReader("iksimbil", 0.91))
        stages = p.analyze(IMAGE)["body"]["stage_confidence"]
        self.assertIsNone(stages["image_quality"])
        self.assertIsNone(stages["inscription_detection"])

    def test_null_reader_abstains_with_422(self):
        p = pipeline_with(NullReader())
        out = p.analyze(IMAGE)
        self.assertEqual(out["status"], 422)
        self.assertIn(out["body"]["reason"], (
            "insufficient_image_quality", "no_inscription_detected", "unreadable_inscription"))
        self.assertTrue(out["body"]["recommendation"])

    def test_unreadable_image_abstains(self):
        p = pipeline_with(MockReader(None))
        out = p.analyze(IMAGE)
        self.assertEqual(out["status"], 422)

    def test_missing_image_is_400(self):
        p = pipeline_with(MockReader("iksimbil"))
        self.assertEqual(p.analyze(None)["status"], 400)

    def test_known_stone_path_locks_and_renders_modern(self):
        # Exakt lasning + GPS: score >= 0.95 -> IDENTITY LOCK -> Known Stone
        # Path med kanonisk oversattning OCH modern upplevelsetext (L3).
        p = pipeline_with(MockReader("iksimbil", 0.91))
        out = p.analyze(IMAGE, gps=(59.8501, 17.6302))
        body = out["body"]
        self.assertEqual(body["path"], "known_stone")
        self.assertEqual(body["identity"]["mode"], "lock")
        self.assertEqual(body["result"]["translation_sv"], "Syntetisk exempelpost 1.")
        self.assertIsNotNone(body["interpretation"])
        self.assertEqual(body["interpretation"]["basis"]["source"], "canonical")

    def test_reading_path_when_no_lock(self):
        # Formellasning som inte finns i corpus: Unknown Stone Path,
        # formelbaserad L2/L3 utan scholarly-ansprak.
        p = pipeline_with(MockReader("burkil raisti stain þinsa aftir ulf sun sin", 0.85))
        out = p.analyze(IMAGE)
        body = out["body"]
        self.assertEqual(body["path"], "reading")
        self.assertIsNone(body["result"]["stone_id"])
        self.assertIsNotNone(body["rendering"])
        self.assertEqual(body["rendering"]["basis"], "formulaic")
        self.assertFalse(body["rendering"]["scholarly_grounded"])
        self.assertIn("Burkil", body["result"]["modern_sv"])

    def test_mismatch_gets_no_experience_text(self):
        # Underkand lasning: varken oversattning eller upplevelsetext.
        p = pipeline_with(MockReader("helt okand text har", 0.8))
        body = p.analyze(IMAGE)["body"]
        self.assertEqual(body["path"], "reading")
        self.assertIsNone(body["result"]["modern_sv"])
        self.assertIsNone(body["rendering"])

    def test_mismatch_never_presents_identification(self):
        # Lasning som motsager corpus: LOW match -> ingen stone_id, ingen
        # kalla, oversattning avstar (plan §19) - men 200 med verification.
        p = pipeline_with(MockReader("helt okand text har", 0.8))
        out = p.analyze(IMAGE)
        self.assertEqual(out["status"], 200)
        self.assertIsNone(out["body"]["result"]["stone_id"])
        self.assertEqual(out["body"]["sources"], [])
        self.assertIsNone(out["body"]["result"]["translation_sv"])
        self.assertEqual(out["body"]["result"]["scholarly_status"], "insufficient_evidence")

    def test_uncertainties_propagate(self):
        unc = [{"position": 3, "candidates": [
            {"candidate": "ᚢ", "confidence": 0.61}, {"candidate": "ᚦ", "confidence": 0.29}]}]
        p = pipeline_with(MockReader("iksimbil", 0.91, uncertainties=unc))
        out = p.analyze(IMAGE)
        self.assertEqual(out["body"]["uncertainties"], unc)


class ObservationTests(unittest.TestCase):
    def test_consented_analysis_emits_valid_observation(self):
        p = pipeline_with(MockReader("iksimbil", 0.91))
        out = p.analyze(IMAGE, gps=(59.8501, 17.6302), consent=CONSENT,
                        inference_timestamp="2026-08-15T00:00:00Z")
        obs = out["observation"]
        self.assertIsNotNone(obs)
        self.assertEqual(validate_record(obs, "field-observation"), [])
        self.assertEqual(obs["match"]["status"], "matched")
        self.assertEqual(obs["verification_status"], "database_matched")
        self.assertIn("inscription_similarity", obs["match"]["evidence"])

    def test_no_consent_no_observation(self):
        p = pipeline_with(MockReader("iksimbil", 0.91))
        out = p.analyze(IMAGE, consent=None)
        self.assertIsNone(out["observation"])
        out2 = p.analyze(IMAGE, consent={"media_storage": False, "training_use": False})
        self.assertIsNone(out2["observation"])

    def test_unknown_reading_gives_unverified_observation(self):
        p = pipeline_with(MockReader("helt okand text har", 0.8))
        out = p.analyze(IMAGE, consent=CONSENT,
                        inference_timestamp="2026-08-15T00:00:00Z")
        obs = out["observation"]
        self.assertIsNotNone(obs)
        self.assertEqual(obs["verification_status"], "unverified")
        self.assertIsNone(obs["verified_by"])
        self.assertEqual(validate_record(obs, "field-observation"), [])


class ReaderRegistryTests(unittest.TestCase):
    def test_null_reader_buildable(self):
        self.assertEqual(build_reader("null").name, "null-reader")

    def test_unknown_reader_rejected(self):
        with self.assertRaises(ValueError):
            build_reader("magic-eye")


class HttpServerTests(unittest.TestCase):
    IMAGES = [
        {"image_id": "img-map-1", "inscription_id": "ric-u-9001", "layer": "C",
         "original_url": "https://example.org/1.jpg", "license": "CC BY-SA 4.0",
         "photographer": "A", "usage": {"redistribution_allowed": True},
         "provenance": {"attribution": "A, CC BY-SA 4.0"}},
    ]

    @classmethod
    def setUpClass(cls):
        from http.server import ThreadingHTTPServer
        index = CorpusIndex(INSCRIPTIONS)
        pipeline = AnalyzePipeline(index, MockReader("iksimbil", 0.91))
        cls.server = ThreadingHTTPServer(
            ("127.0.0.1", 0), make_handler(pipeline, index, None, cls.IMAGES))
        cls.port = cls.server.server_address[1]
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def _post(self, path: str, payload: dict) -> tuple[int, dict]:
        req = urllib.request.Request(
            f"http://127.0.0.1:{self.port}{path}",
            data=json.dumps(payload).encode(),
            headers={"Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req) as resp:
                return resp.status, json.loads(resp.read())
        except urllib.error.HTTPError as err:
            return err.code, json.loads(err.read())

    def test_healthz(self):
        with urllib.request.urlopen(f"http://127.0.0.1:{self.port}/healthz") as resp:
            self.assertEqual(resp.status, 200)

    def test_analyze_roundtrip(self):
        status, body = self._post("/v1/analyze", {
            "image_b64": base64.b64encode(IMAGE).decode(),
            "latitude": 59.8501, "longitude": 17.6302})
        self.assertEqual(status, 200)
        self.assertEqual(body["result"]["stone_id"], "U 9001")
        self.assertIn("stage_confidence", body)

    def test_analyze_bad_base64(self):
        status, _ = self._post("/v1/analyze", {"image_b64": "!!!inte-base64!!!"})
        self.assertEqual(status, 400)

    def test_retrieve_endpoint(self):
        status, body = self._post("/knowledge/retrieve", {"text": "tistil mistil"})
        self.assertEqual(status, 200)
        self.assertEqual(body["candidates"][0]["signum"], "Sö 9002")

    def test_retrieve_requires_signal(self):
        status, _ = self._post("/knowledge/retrieve", {})
        self.assertEqual(status, 400)

    def test_explore_endpoint(self):
        status, body = self._post("/v1/explore",
                                  {"latitude": 59.8501, "longitude": 17.6302})
        self.assertEqual(status, 200)
        signa = [s["signum"] for s in body["nearby"]]
        self.assertEqual(signa[0], "U 9001")  # narmast forst
        self.assertIn("walk_min", body["nearby"][0])

    def test_explore_requires_position(self):
        status, _ = self._post("/v1/explore", {})
        self.assertEqual(status, 400)

    def test_map_endpoint(self):
        status, body = self._post("/v1/map", {"seen": ["U 9001"]})
        self.assertEqual(status, 200)
        self.assertEqual(body["type"], "FeatureCollection")
        u = next(f["properties"] for f in body["features"]
                 if f["properties"]["signum"] == "U 9001")
        self.assertTrue(u["visited"])
        self.assertEqual(u["photo"]["image_id"], "img-map-1")
        self.assertIn("google", u["directions"])
        self.assertEqual(body["meta"]["visited"], 1)

    def test_map_page_served(self):
        with urllib.request.urlopen(f"http://127.0.0.1:{self.port}/map") as resp:
            self.assertEqual(resp.status, 200)
            self.assertIn("mapbox-gl", resp.read().decode())

    def test_interpret_endpoint(self):
        status, body = self._post("/interpret",
                                  {"transliteration": "burkil raisti stain þinsa aftir ulf sun sin"})
        self.assertEqual(status, 200)
        self.assertIn("reste", body["formulaic"]["translation_sv"])

    def test_unknown_route_404(self):
        status, _ = self._post("/v1/unknown", {})
        self.assertEqual(status, 404)


if __name__ == "__main__":
    unittest.main()
