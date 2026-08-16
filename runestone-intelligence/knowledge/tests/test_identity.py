"""Tester for IDENTITY LOCK: trosklar, GPS-sparren och LOW-match-brytaren."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from identity import LOCK_THRESHOLD, REVIEW_THRESHOLD, decide  # noqa: E402


def cand(score, gps_only=False, iid="ric-u-9001"):
    return {"inscription_id": iid, "signum": "U 9001", "score": score,
            "gps_only": gps_only, "evidence_types": ["gps_proximity"] if gps_only
            else ["inscription_similarity", "gps_proximity"]}


class IdentityLockTests(unittest.TestCase):
    def test_high_score_locks(self):
        d = decide([cand(0.978)])
        self.assertEqual(d.mode, "lock")
        self.assertEqual(d.locked["inscription_id"], "ric-u-9001")

    def test_review_band(self):
        d = decide([cand(0.85), cand(0.80, iid="ric-so-9002")])
        self.assertEqual(d.mode, "review")
        self.assertEqual(len(d.candidates), 2)
        self.assertIsNone(d.locked)

    def test_low_score_falls_back_to_reading(self):
        d = decide([cand(0.4)])
        self.assertEqual(d.mode, "fallback")
        self.assertIn("Unknown Stone Path", d.reason)

    def test_gps_only_never_locks_regardless_of_score(self):
        d = decide([cand(0.99, gps_only=True)])
        self.assertEqual(d.mode, "fallback")
        self.assertIn("GPS", d.reason)

    def test_low_verification_match_breaks_lock(self):
        d = decide([cand(0.99)], verification_match="LOW")
        self.assertEqual(d.mode, "fallback")
        self.assertIn("motsager", d.reason)

    def test_thresholds_are_the_spec_values(self):
        self.assertEqual(LOCK_THRESHOLD, 0.95)
        self.assertEqual(REVIEW_THRESHOLD, 0.70)

    def test_boundary_scores(self):
        self.assertEqual(decide([cand(0.95)]).mode, "lock")
        self.assertEqual(decide([cand(0.9499)]).mode, "review")
        self.assertEqual(decide([cand(0.70)]).mode, "review")
        self.assertEqual(decide([cand(0.6999)]).mode, "fallback")


if __name__ == "__main__":
    unittest.main()
