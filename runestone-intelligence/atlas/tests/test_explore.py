"""Tester for Explore: nasta sten, avstand/tider, seen-flaggning och trail."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from explore import nearby, trail  # noqa: E402

# Tre stenar pa en nord-sydlig linje (ca 1,1 km mellan varje) + en utan koordinater.
STONES = [
    {"signum": "U 9001", "inscription_id": "ric-u-9001",
     "coordinates": {"latitude": 59.850, "longitude": 17.630}},
    {"signum": "U 9002", "inscription_id": "ric-u-9002",
     "coordinates": {"latitude": 59.860, "longitude": 17.630}},
    {"signum": "U 9003", "inscription_id": "ric-u-9003",
     "coordinates": {"latitude": 59.880, "longitude": 17.630}, "accessibility": "easy"},
    {"signum": "U 9004", "inscription_id": "ric-u-9004", "coordinates": None},
]

HERE = (59.8501, 17.6301)  # vid U 9001


class NearbyTests(unittest.TestCase):
    def test_orders_by_distance(self):
        result = nearby(STONES, HERE)
        self.assertEqual([r["signum"] for r in result], ["U 9001", "U 9002", "U 9003"])
        self.assertLess(result[0]["distance_km"], 0.05)
        self.assertAlmostEqual(result[1]["distance_km"], 1.1, delta=0.2)

    def test_time_estimates(self):
        second = nearby(STONES, HERE)[1]
        self.assertAlmostEqual(second["walk_min"], 13, delta=3)   # ~1,1 km promenad
        self.assertGreaterEqual(second["drive_min"], 3)

    def test_stones_without_coordinates_are_skipped(self):
        signa = [r["signum"] for r in nearby(STONES, HERE, limit=10)]
        self.assertNotIn("U 9004", signa)

    def test_seen_flagging(self):
        result = nearby(STONES, HERE, exclude_seen={"U 9001"})
        self.assertTrue(result[0]["seen"])
        self.assertFalse(result[1]["seen"])

    def test_max_km_filter(self):
        result = nearby(STONES, HERE, max_km=2.0, limit=10)
        self.assertEqual([r["signum"] for r in result], ["U 9001", "U 9002"])

    def test_limit(self):
        self.assertEqual(len(nearby(STONES, HERE, limit=1)), 1)


class TrailTests(unittest.TestCase):
    def test_greedy_route_visits_in_line_order(self):
        t = trail(STONES, HERE, count=3)
        self.assertEqual([s["signum"] for s in t["stones"]], ["U 9001", "U 9002", "U 9003"])
        self.assertEqual(t["count"], 3)
        self.assertAlmostEqual(t["total_km"], 3.3, delta=0.5)
        self.assertGreater(t["walk_min_estimate"], 30)

    def test_count_caps_route(self):
        self.assertEqual(trail(STONES, HERE, count=2)["count"], 2)

    def test_deterministic(self):
        self.assertEqual(trail(STONES, HERE), trail(STONES, HERE))


if __name__ == "__main__":
    unittest.main()
