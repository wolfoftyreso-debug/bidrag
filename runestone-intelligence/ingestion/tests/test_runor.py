"""Tester for Runor/K-samsok-importern: berikning utan mutation,
konfliktdetektering, bildrattigheter och integration i corpusbygget."""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from build_corpus import build  # noqa: E402
from contracts import read_jsonl  # noqa: E402
from runor_importer import apply_enrichment, enrich_with_runor  # noqa: E402
from srd_importer import import_srd  # noqa: E402

FIXTURES = Path(__file__).parents[1] / "fixtures"
TS = "2026-08-15T00:00:00Z"


def _setup():
    srd = import_srd(read_jsonl(FIXTURES / "srd_sample.jsonl"),
                     source_url="https://example.org/srd",
                     dataset_version="v0.1", download_timestamp=TS)
    report = enrich_with_runor(srd.imported, read_jsonl(FIXTURES / "runor_sample.jsonl"),
                               source_url="https://example.org/runor",
                               dataset_version="v0.1", download_timestamp=TS)
    return srd, report


class RunorEnrichmentTests(unittest.TestCase):
    def test_fills_only_missing_fields(self):
        srd, report = _setup()
        og = next(r for r in report.enriched if r["inscription_id"] == "ric-og-9003")
        self.assertEqual(og["coordinates"]["latitude"], 58.41)  # var tomt: fylls
        self.assertEqual(og["region"], "Ostergotland")
        self.assertEqual(og["dating"], "V")  # fanns redan i SRD? nej - Ög saknade... fylls
        fields = og["enrichments"][0]["fields"]
        self.assertIn("coordinates", fields)
        self.assertNotIn("transliteration", fields)

    def test_never_overwrites_existing_values(self):
        srd, report = _setup()
        # Sö 9002 har redan SRD-koordinater; Runor-vardet ar nara men far inte ersatta
        so = next((r for r in report.enriched if r["inscription_id"] == "ric-so-9002"), None)
        if so is not None:
            self.assertEqual(so["coordinates"]["latitude"], 59.2)  # SRD-vardet orort
            self.assertNotIn("coordinates", so["enrichments"][0]["fields"])
        original = next(r for r in srd.imported if r["inscription_id"] == "ric-so-9002")
        self.assertEqual(original["coordinates"]["latitude"], 59.2)

    def test_coordinate_conflict_goes_to_review_not_silent_choice(self):
        srd, report = _setup()
        reasons = [r["reason"] for r in report.review_queue]
        self.assertTrue(any("koordinatkonflikt" in r for r in reasons))
        # U 9001 behaller SRD-koordinaten
        u = apply_enrichment(srd.imported, report)
        u9001 = next(r for r in u if r["inscription_id"] == "ric-u-9001")
        self.assertEqual(u9001["coordinates"]["latitude"], 59.85)

    def test_unknown_signum_flags_possible_srd_gap(self):
        _, report = _setup()
        self.assertTrue(any("finns inte i corpus" in r["reason"] for r in report.review_queue))

    def test_missing_signum_rejected(self):
        _, report = _setup()
        self.assertTrue(any("utan signum" in r["reason"] for r in report.review_queue))

    def test_image_rights_with_unknown_license_never_trainable(self):
        _, report = _setup()
        ata_image = next(i for i in report.images if i["source_institution"] == "ATA")
        self.assertEqual(ata_image["rights_status"], "unknown")
        self.assertFalse(ata_image["usage"]["training_allowed"])
        cc_image = next(i for i in report.images if i["license"] == "CC BY 4.0")
        self.assertTrue(cc_image["usage"]["training_allowed"])

    def test_enrichment_is_traceable(self):
        _, report = _setup()
        for rec in report.enriched:
            self.assertEqual(rec["provenance"]["modification_status"], "enriched")
            for e in rec["enrichments"]:
                self.assertTrue(e["source_record_id"])


class BuildIntegrationTests(unittest.TestCase):
    def test_build_with_runor_enrichment(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "corpus"
            summary = build(srd_path=FIXTURES / "srd_sample.jsonl",
                            images_path=FIXTURES / "hf_sample.jsonl",
                            runor_path=FIXTURES / "runor_sample.jsonl",
                            out_dir=out, version="v0.2", timestamp=TS, seed=8)
            # Endast Ög 9003 saknar falt att fylla; Sö 9002 ar komplett i SRD
            # (untouched) och U 9001 har koordinatkonflikt (granskningsko).
            self.assertEqual(summary["runor"]["enriched"], 1)
            self.assertEqual(summary["runor"]["untouched"], 2)
            self.assertGreaterEqual(summary["runor"]["review"], 3)
            # Runor-bilden for Ög 9003 matchas nu - stenen hade inga bilder forut
            inscriptions = read_jsonl(out / "inscriptions.jsonl")
            og = next(r for r in inscriptions if r["inscription_id"] == "ric-og-9003")
            self.assertIsNotNone(og["coordinates"])
            images = read_jsonl(out / "images.jsonl")
            runor_matched = [i for i in images
                             if i["image_id"].startswith("img-runor") and i["inscription_id"]]
            self.assertTrue(runor_matched)

    def test_build_without_runor_still_works(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "corpus"
            summary = build(srd_path=FIXTURES / "srd_sample.jsonl",
                            images_path=FIXTURES / "hf_sample.jsonl",
                            out_dir=out, version="v0.1", timestamp=TS, seed=8)
            self.assertIsNone(summary["runor"])


if __name__ == "__main__":
    unittest.main()
