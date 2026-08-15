"""Tester for RuneKnowledge: trigram/edit-likhet, GPS-signal, filter,
determinism och gps_only-regeln."""

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "knowledge"))
sys.path.insert(0, str(ROOT / "benchmark"))

from retrieval import (  # noqa: E402
    CorpusIndex,
    edit_similarity,
    haversine_km,
    jaccard,
    normalize_text,
    proximity_score,
    trigrams,
)

INSCRIPTIONS = [
    {"inscription_id": "ric-u-9001", "signum": "U 9001", "rune_type": "younger_futhark",
     "region": "Uppland", "transliteration": "han raisti stain thinsa",
     "coordinates": {"latitude": 59.85, "longitude": 17.63},
     "source_database": "SRD", "source_provider": "Uppsala University",
     "translation_sv": "syntetisk", "scholarly_status": "established"},
    {"inscription_id": "ric-so-9002", "signum": "Sö 9002", "rune_type": "younger_futhark",
     "region": "Sodermanland", "transliteration": "tistil mistil kistil",
     "coordinates": {"latitude": 59.2, "longitude": 17.0},
     "source_database": "SRD", "source_provider": "Uppsala University",
     "translation_sv": "syntetisk", "scholarly_status": "uncertain"},
    {"inscription_id": "ric-og-9003", "signum": "Ög 9003", "rune_type": "short_twig",
     "region": "Ostergotland", "transliteration": "aift fathur sin kuthan",
     "coordinates": None,
     "source_database": "SRD", "source_provider": "Uppsala University",
     "translation_sv": None, "scholarly_status": "uncertain"},
]


class TextSimilarityTests(unittest.TestCase):
    def test_normalize_strips_markers(self):
        self.assertEqual(normalize_text("han : raisti -- stain"), "han raisti stain")
        self.assertEqual(normalize_text("  HAN  Raisti "), "han raisti")

    def test_trigrams_and_jaccard(self):
        self.assertEqual(jaccard(trigrams("abc"), trigrams("abc")), 1.0)
        self.assertEqual(jaccard(trigrams("abc"), trigrams("xyz")), 0.0)
        self.assertEqual(jaccard(set(), trigrams("abc")), 0.0)

    def test_edit_similarity(self):
        self.assertEqual(edit_similarity("abcd", "abcd"), 1.0)
        self.assertAlmostEqual(edit_similarity("abcd", "abcx"), 0.75)
        self.assertEqual(edit_similarity("", "abc"), 0.0)


class GeoTests(unittest.TestCase):
    def test_haversine_known_distance(self):
        # Stockholm - Uppsala ar ca 63-64 km fagelvag
        d = haversine_km(59.3293, 18.0686, 59.8586, 17.6389)
        self.assertGreater(d, 55)
        self.assertLess(d, 72)

    def test_proximity_decay(self):
        self.assertEqual(proximity_score(0.0), 1.0)
        self.assertAlmostEqual(proximity_score(2.5), 0.5)
        self.assertEqual(proximity_score(10.0), 0.0)


class RetrievalTests(unittest.TestCase):
    def setUp(self):
        self.index = CorpusIndex(INSCRIPTIONS)

    def test_exact_reading_ranks_first(self):
        top = self.index.search(query_text="han raisti stain thinsa")[0]
        self.assertEqual(top.inscription_id, "ric-u-9001")
        self.assertGreater(top.evidence["inscription_similarity"], 0.99)

    def test_noisy_reading_still_ranks_right_stone(self):
        # tva teckenfel + saknat ord - som en riktig modellasning
        top = self.index.search(query_text="han raisti stein")[0]
        self.assertEqual(top.inscription_id, "ric-u-9001")

    def test_gps_boosts_nearby_stone(self):
        # lasningen ar lika daligt matchande for bada; GPS vid Sö-stenen avgor
        results = self.index.search(query_text="xxxx", gps=(59.2, 17.0), top_k=3)
        self.assertEqual(results[0].inscription_id, "ric-so-9002")
        self.assertIn("gps_proximity", results[0].evidence)

    def test_gps_never_sole_evidence_when_text_present(self):
        results = self.index.search(query_text="tistil mistil kistil", gps=(59.2, 17.0))
        top = results[0]
        self.assertFalse(top.gps_only)
        self.assertIn("inscription_similarity", top.evidence)

    def test_gps_only_search_is_flagged(self):
        results = self.index.search(gps=(59.85, 17.63))
        self.assertTrue(results)
        for cand in results:
            self.assertTrue(cand.gps_only)
            self.assertEqual(sorted(cand.evidence), ["gps_proximity"])
        # stenen utan koordinater kan inte foreslas av GPS
        self.assertNotIn("ric-og-9003", [c.inscription_id for c in results])

    def test_filters_narrow_pool(self):
        results = self.index.search(query_text="aift fathur", rune_type="short_twig")
        self.assertEqual([c.inscription_id for c in results], ["ric-og-9003"])

    def test_requires_text_or_gps(self):
        with self.assertRaises(ValueError):
            self.index.search()

    def test_deterministic_ordering(self):
        a = [c.inscription_id for c in self.index.search(query_text="stil", top_k=3)]
        b = [c.inscription_id for c in self.index.search(query_text="stil", top_k=3)]
        self.assertEqual(a, b)

    def test_candidates_carry_source(self):
        top = self.index.search(query_text="han raisti stain thinsa")[0]
        d = top.to_dict()
        self.assertEqual(d["source"]["source_provider"], "Uppsala University")
        self.assertIn("evidence_types", d)


if __name__ == "__main__":
    unittest.main()
