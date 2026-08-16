"""Tester for coverage-/gaprapporten (de sex strategiska datafragorna)."""

import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from build_corpus import build  # noqa: E402
from coverage_report import build_report  # noqa: E402

FIXTURES = Path(__file__).parents[1] / "fixtures"


class CoverageReportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._tmp = tempfile.TemporaryDirectory()
        cls.corpus = Path(cls._tmp.name) / "corpus"
        build(srd_path=FIXTURES / "srd_sample.jsonl",
              images_path=FIXTURES / "hf_sample.jsonl",
              out_dir=cls.corpus, version="v0.1",
              timestamp="2026-08-15T00:00:00Z", seed=8)
        cls.report = build_report(cls.corpus)

    @classmethod
    def tearDownClass(cls):
        cls._tmp.cleanup()

    def test_q1_totals(self):
        self.assertEqual(self.report["q1_inscriptions_total"], 3)

    def test_q2_legal_images(self):
        q2 = self.report["q2_images"]
        self.assertEqual(q2["total"], 6)
        self.assertEqual(q2["unknown_license"], 1)
        self.assertEqual(q2["training_allowed"], 5)

    def test_q3_coordinates(self):
        self.assertEqual(self.report["q3_coordinates"]["count"], 2)  # Ög 9003 saknar

    def test_q4_established_text(self):
        q4 = self.report["q4_established_text"]
        self.assertEqual(q4["transliteration"]["pct"], 100.0)
        self.assertEqual(q4["translation_sv"]["count"], 2)

    def test_q5_image_matchable(self):
        q5 = self.report["q5_image_matchable"]
        self.assertEqual(q5["inscriptions_with_images"], 2)  # u-9001, so-9002
        self.assertEqual(q5["with_images_and_coordinates"], 2)

    def test_q6_gaps_are_explicit_lists(self):
        gaps = self.report["q6_gaps"]
        self.assertIn("ric-og-9003", gaps["without_images"])
        self.assertIn("ric-og-9003", gaps["without_coordinates"])
        self.assertEqual(len(gaps["unmatched_images"]), 2)
        self.assertEqual(self.report["gap_counts"]["images_with_unknown_license"], 1)


if __name__ == "__main__":
    unittest.main()
