"""Tester for Wikimedia-skordaren: per-fil licensklassning och kopplingar."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from contracts import read_jsonl  # noqa: E402
from wikimedia_harvester import classify_commons_license, harvest_wikimedia  # noqa: E402

FIXTURES = Path(__file__).parents[1] / "fixtures"
TS = "2026-08-16T00:00:00Z"


class WikimediaTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.report = harvest_wikimedia(read_jsonl(FIXTURES / "wikimedia_sample.jsonl"),
                                       dataset_version="v0.1", download_timestamp=TS)

    def test_counts(self):
        self.assertEqual(self.report.counts["imported"], 4)
        self.assertEqual(self.report.counts["unclassified"], 1)

    def test_pd_variants_are_open(self):
        self.assertEqual(classify_commons_license("PD-old")[1:], ("open", True, True))
        self.assertEqual(classify_commons_license("CC0")[1:], ("open", True, True))
        self.assertEqual(classify_commons_license("All rights reserved")[1:],
                         ("unknown", False, False))

    def test_unknown_license_never_trainable(self):
        protected = next(i for i in self.report.imported
                         if "ratt-skyddad" in i["image_id"])
        self.assertFalse(protected["usage"]["training_allowed"])
        self.assertFalse(protected["usage"]["redistribution_allowed"])

    def test_attribution_carries_artist_and_license(self):
        img = next(i for i in self.report.imported if i["photographer"] == "Wikianvandare A")
        self.assertIn("CC BY-SA 4.0", img["provenance"]["attribution"])
        self.assertIn("Wikimedia Commons", img["provenance"]["attribution"])

    def test_pairings_only_for_valid_signum(self):
        paired = {p["signum"] for p in self.report.pairings}
        self.assertEqual(paired, {"U 9001", "Sö 9002"})
        self.assertTrue(any("otolkbart signum" in r["reasons"][0]
                            for r in self.report.rejected))

    def test_never_sets_inscription_id(self):
        for img in self.report.imported:
            self.assertIsNone(img["inscription_id"])


if __name__ == "__main__":
    unittest.main()
