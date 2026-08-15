"""Tester for RuneVerifier: matchnivaer, positionsvisa avvikelser och
regeln att verifiering aldrig forbattrar vetenskaplig status."""

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "verification"))
sys.path.insert(0, str(ROOT / "knowledge"))
sys.path.insert(0, str(ROOT / "benchmark"))

from verify import verify_against_candidates, verify_reading  # noqa: E402


def make_candidate(**overrides):
    base = {
        "inscription_id": "ric-u-9001", "signum": "U 9001", "score": 0.95,
        "evidence_types": ["inscription_similarity"], "gps_only": False,
        "source": {"transliteration": "han raisti stain thinsa",
                   "translation_sv": "syntetisk",
                   "source_database": "SRD", "source_provider": "Uppsala University",
                   "scholarly_status": "established"},
    }
    base.update(overrides)
    return base


class VerifyReadingTests(unittest.TestCase):
    def test_identical_is_high(self):
        v = verify_reading("han raisti stain", "han raisti stain")
        self.assertEqual(v["match"], "HIGH")
        self.assertEqual(v["cer"], 0.0)
        self.assertEqual(v["mismatches"], [])
        self.assertFalse(v["alternative_analysis_required"])

    def test_marker_differences_ignored(self):
        v = verify_reading("han : raisti", "han raisti")
        self.assertEqual(v["match"], "HIGH")

    def test_single_rune_diff_is_flagged_with_position(self):
        # kun vs kum - exemplet fran plan §19
        v = verify_reading("kun", "kum")
        self.assertEqual(len(v["mismatches"]), 1)
        self.assertEqual(v["mismatches"][0]["op"], "substitution")
        self.assertEqual(v["mismatches"][0]["canonical"], "m")
        self.assertEqual(v["mismatches"][0]["observed"], "n")

    def test_insertion_does_not_cascade(self):
        # ett extra tecken tidigt ska ge EN avvikelse, inte flagga allt efter
        v = verify_reading("xhan raisti stain thinsa", "han raisti stain thinsa")
        self.assertEqual(len(v["mismatches"]), 1)
        self.assertEqual(v["mismatches"][0]["op"], "extra")

    def test_low_match_triggers_alternative_analysis(self):
        v = verify_reading("nagot helt annat", "han raisti stain thinsa")
        self.assertEqual(v["match"], "LOW")
        self.assertTrue(v["alternative_analysis_required"])

    def test_empty_canonical_rejected(self):
        with self.assertRaises(ValueError):
            verify_reading("nagot", "")


class VerifyAgainstCandidatesTests(unittest.TestCase):
    def test_high_match_keeps_source_status(self):
        verdict = verify_against_candidates("han raisti stain thinsa", [make_candidate()])
        self.assertEqual(verdict["status"], "verified")
        self.assertEqual(verdict["presented_scholarly_status"], "established")
        self.assertEqual(verdict["identification"]["signum"], "U 9001")

    def test_medium_match_downgrades_established_to_probable(self):
        # ~3 teckenfel av 23: MEDIUM
        verdict = verify_against_candidates("han raisti stein thinse", [make_candidate()])
        self.assertEqual(verdict["verification"]["match"], "MEDIUM")
        self.assertEqual(verdict["presented_scholarly_status"], "probable")

    def test_medium_match_never_upgrades_uncertain(self):
        cand = make_candidate()
        cand["source"] = dict(cand["source"], scholarly_status="uncertain")
        verdict = verify_against_candidates("han raisti stein thinse", [cand])
        self.assertEqual(verdict["presented_scholarly_status"], "uncertain")

    def test_low_match_is_mismatch_with_insufficient_evidence(self):
        verdict = verify_against_candidates("nagot helt annat har", [make_candidate()])
        self.assertEqual(verdict["status"], "mismatch")
        self.assertEqual(verdict["presented_scholarly_status"], "insufficient_evidence")
        self.assertTrue(verdict["verification"]["alternative_analysis_required"])

    def test_gps_only_candidates_never_identify(self):
        gps_cand = make_candidate(gps_only=True, evidence_types=["gps_proximity"])
        verdict = verify_against_candidates("han raisti stain thinsa", [gps_cand])
        self.assertEqual(verdict["status"], "gps_only_suggestions")
        self.assertIsNone(verdict["identification"])
        self.assertEqual(len(verdict["suggestions"]), 1)

    def test_no_candidates(self):
        verdict = verify_against_candidates("nagot", [])
        self.assertEqual(verdict["status"], "no_candidates")


if __name__ == "__main__":
    unittest.main()
