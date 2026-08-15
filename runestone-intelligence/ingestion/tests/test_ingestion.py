"""Tester for ingestion-pipelinen: signum, importers, matcher, split, e2e."""

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from build_corpus import build  # noqa: E402
from contracts import read_jsonl  # noqa: E402
from hf_importer import classify_license, import_hf_images  # noqa: E402
from matcher import match_images  # noqa: E402
from signum import SignumError, parse_signum, signum_key, signum_slug  # noqa: E402
from srd_importer import import_srd  # noqa: E402
from versioning import build_manifest, stone_level_split  # noqa: E402

FIXTURES = Path(__file__).parents[1] / "fixtures"
TS = "2026-08-15T00:00:00Z"


def _srd():
    return import_srd(read_jsonl(FIXTURES / "srd_sample.jsonl"),
                      source_url="https://example.org/srd", dataset_version="v0.1",
                      download_timestamp=TS)


def _hf():
    return import_hf_images(read_jsonl(FIXTURES / "hf_sample.jsonl"),
                            source_url="https://example.org/hf", dataset_version="v0.1",
                            download_timestamp=TS)


class SignumTests(unittest.TestCase):
    def test_normalization_variants_share_key(self):
        self.assertEqual(signum_key("U 9001"), "u:9001")
        self.assertEqual(signum_key("u9001"), "u:9001")
        self.assertEqual(signum_key("  u   9001 "), "u:9001")

    def test_lost_marker(self):
        s = parse_signum("Ög 9003 †")
        self.assertTrue(s.lost)
        self.assertEqual(s.key, "ög:9003")

    def test_periodical_signum(self):
        self.assertEqual(signum_key("U Fv1955;219"), "u:fv1955;219")

    def test_slug_is_id_safe(self):
        self.assertEqual(signum_slug("Sö 9002"), "so-9002")

    def test_unknown_code_rejected(self):
        with self.assertRaises(SignumError):
            parse_signum("QQ 999")
        with self.assertRaises(SignumError):
            parse_signum("")


class SrdImporterTests(unittest.TestCase):
    def test_import_counts(self):
        r = _srd()
        # 3 unika giltiga, 1 identisk dubblett, 3 avvisade
        # (motstridig dubblett, okand kod, saknat signum)
        self.assertEqual(r.counts, {"imported": 3, "rejected": 3, "duplicates": 1})

    def test_records_validate_and_keep_attribution(self):
        for rec in _srd().imported:
            self.assertEqual(rec["source_database"], "Scandinavian Runic-text Database")
            self.assertEqual(rec["source_provider"], "Uppsala University")
            self.assertTrue(rec["provenance"]["checksum"].startswith("sha256:"))

    def test_conflicting_duplicate_never_overwrites(self):
        r = _srd()
        first = next(rec for rec in r.imported if rec["inscription_id"] == "ric-so-9002")
        self.assertEqual(first["transliteration"], "tistil mistil")
        self.assertTrue(any("motstridig" in rej["reasons"][0] for rej in r.rejected))

    def test_idempotent_rerun(self):
        rows = read_jsonl(FIXTURES / "srd_sample.jsonl")
        a = import_srd(rows, source_url="u", dataset_version="v0.1", download_timestamp=TS)
        b = import_srd(rows, source_url="u", dataset_version="v0.1", download_timestamp=TS)
        self.assertEqual(a.imported, b.imported)


class HfImporterTests(unittest.TestCase):
    def test_license_whitelist(self):
        self.assertEqual(classify_license("CC0")[1:], ("open", True, True))
        self.assertEqual(classify_license("CC BY-SA 4.0")[1:], ("share_alike", True, True))
        self.assertEqual(classify_license("All rights reserved (unclear)")[1:],
                         ("unknown", False, False))
        self.assertEqual(classify_license(None)[1:], ("unknown", False, False))

    def test_unknown_license_never_trainable(self):
        r = _hf()
        img = next(i for i in r.imported if i["image_id"] == "img-hf-0005")
        self.assertFalse(img["usage"]["training_allowed"])
        self.assertIn("img-hf-0005", r.unclassified_licenses)

    def test_importer_never_sets_inscription_id(self):
        for img in _hf().imported:
            self.assertIsNone(img["inscription_id"])

    def test_pairings_only_for_parseable_signum(self):
        r = _hf()
        paired = {p["image_id"] for p in r.pairings}
        self.assertNotIn("img-hf-0006", paired)  # saknar signum
        self.assertIn("img-hf-0002", paired)     # "u9001" ar tolkbart


class MatcherTests(unittest.TestCase):
    def test_matching_outcomes(self):
        srd, hf = _srd(), _hf()
        m = match_images(srd.imported, hf.imported, hf.pairings)
        self.assertEqual(m.counts, {"matched": 4, "unmatched": 2, "ambiguous": 0})
        matched_ids = {i["image_id"]: i["inscription_id"] for i in m.matched}
        self.assertEqual(matched_ids["img-hf-0001"], "ric-u-9001")
        self.assertEqual(matched_ids["img-hf-0002"], "ric-u-9001")  # slarvigt format matchar anda
        unmatched = {u["image_id"]: u["reason"] for u in m.unmatched}
        self.assertIn("finns inte i corpus", unmatched["img-hf-0004"])
        self.assertIn("saknar signum", unmatched["img-hf-0006"])

    def test_never_guesses(self):
        srd, hf = _srd(), _hf()
        m = match_images(srd.imported, hf.imported, [])
        self.assertEqual(len(m.matched), 0)
        self.assertEqual(len(m.unmatched), len(hf.imported))


class SplitTests(unittest.TestCase):
    IDS = [f"ric-u-{n}" for n in range(1000)]

    def test_deterministic(self):
        self.assertEqual(stone_level_split(self.IDS, seed=1), stone_level_split(self.IDS, seed=1))

    def test_seed_changes_split(self):
        self.assertNotEqual(stone_level_split(self.IDS, seed=1), stone_level_split(self.IDS, seed=2))

    def test_fractions_roughly_hold(self):
        split = stone_level_split(self.IDS, seed=42)
        n = len(self.IDS)
        train = sum(1 for v in split.values() if v == "train")
        unknown = sum(1 for v in split.values() if v == "unknown_stone_test")
        self.assertGreater(train / n, 0.74)
        self.assertLess(train / n, 0.86)
        self.assertGreater(unknown, 0)

    def test_stable_when_new_stones_added(self):
        base = stone_level_split(self.IDS, seed=7)
        extended = stone_level_split(self.IDS + ["ric-so-99999"], seed=7)
        for iid in self.IDS:
            self.assertEqual(base[iid], extended[iid])

    def test_bad_fractions_rejected(self):
        with self.assertRaises(ValueError):
            stone_level_split(self.IDS, seed=1, fractions={"train": 0.5, "val": 0.1, "test": 0.1})


class EndToEndTests(unittest.TestCase):
    def test_build_corpus(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "corpus-v0.1"
            summary = build(
                srd_path=FIXTURES / "srd_sample.jsonl",
                images_path=FIXTURES / "hf_sample.jsonl",
                out_dir=out, version="v0.1", timestamp=TS, seed=20260815,
            )
            self.assertEqual(summary["inscriptions"]["imported"], 3)
            self.assertEqual(summary["matching"]["matched"], 4)

            manifest = json.loads((out / "manifest.json").read_text())
            self.assertTrue(manifest["immutable"])
            self.assertEqual(manifest["split_policy"]["unit"], "inscription_id")

            review = json.loads((out / "review_queue.json").read_text())
            self.assertEqual(len(review["images_unmatched"]), 2)
            self.assertEqual(review["unclassified_licenses"], ["img-hf-0005"])

            # Deterministisk: samma input + timestamp + seed -> samma checksumma
            out2 = Path(tmp) / "again"
            summary2 = build(
                srd_path=FIXTURES / "srd_sample.jsonl",
                images_path=FIXTURES / "hf_sample.jsonl",
                out_dir=out2, version="v0.1", timestamp=TS, seed=20260815,
            )
            self.assertEqual(summary["manifest_checksum"], summary2["manifest_checksum"])

    def test_manifest_requires_valid_layer(self):
        with self.assertRaises(ValueError):
            build_manifest(
                dataset_name="x", dataset_version="v0.1", layer="Z", records=[],
                source_datasets=[{"source": "s", "license": "l"}],
                created_at=TS, seed=1,
            )


if __name__ == "__main__":
    unittest.main()
