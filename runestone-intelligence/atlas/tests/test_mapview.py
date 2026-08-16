"""Tester for kartfeeden: GeoJSON-struktur, licenssparren for foton,
avbockning, egna foton och vagbeskrivningslankar."""

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1]))

from mapview import directions_links, stones_geojson  # noqa: E402

INSCRIPTIONS = [
    {"inscription_id": "ric-u-9001", "signum": "U 9001", "region": "Uppland",
     "coordinates": {"latitude": 59.85, "longitude": 17.63},
     "translation_sv": "Syntetisk exempelpost 1.", "scholarly_status": "established",
     "source_database": "Scandinavian Runic-text Database"},
    {"inscription_id": "ric-so-9002", "signum": "Sö 9002", "region": "Sodermanland",
     "coordinates": {"latitude": 59.2, "longitude": 17.0},
     "translation_sv": None, "scholarly_status": "uncertain",
     "source_database": "Scandinavian Runic-text Database"},
    {"inscription_id": "ric-og-9003", "signum": "Ög 9003", "region": None,
     "coordinates": None, "source_database": "Scandinavian Runic-text Database"},
]

IMAGES = [
    {"image_id": "img-1", "inscription_id": "ric-u-9001", "layer": "C",
     "original_url": "https://example.org/1.jpg", "license": "CC BY-SA 4.0",
     "photographer": "A", "usage": {"redistribution_allowed": True},
     "provenance": {"attribution": "A, CC BY-SA 4.0, via Wikimedia Commons"}},
    {"image_id": "img-2", "inscription_id": "ric-so-9002", "layer": "B",
     "original_url": "https://example.org/2.jpg", "license": "Upphovsratt",
     "photographer": None, "usage": {"redistribution_allowed": False},
     "provenance": {"attribution": "ATA"}},
    {"image_id": "img-3", "inscription_id": "ric-u-9001", "layer": "F",
     "original_url": "https://example.org/3.jpg", "license": "user-contributed",
     "usage": {"redistribution_allowed": True}, "provenance": {}},
]


class MapViewTests(unittest.TestCase):
    def test_geojson_structure(self):
        gj = stones_geojson(INSCRIPTIONS, IMAGES)
        self.assertEqual(gj["type"], "FeatureCollection")
        self.assertEqual(gj["meta"]["total"], 2)  # Ög saknar koordinater
        self.assertIn("ric-og-9003", gj["meta"]["skipped_no_coordinates"])
        feature = gj["features"][0]
        self.assertEqual(feature["geometry"]["coordinates"], [17.63, 59.85])

    def test_photo_requires_redistribution_rights(self):
        gj = stones_geojson(INSCRIPTIONS, IMAGES)
        u = next(f["properties"] for f in gj["features"] if f["properties"]["signum"] == "U 9001")
        so = next(f["properties"] for f in gj["features"] if f["properties"]["signum"] == "Sö 9002")
        self.assertEqual(u["photo"]["image_id"], "img-1")
        self.assertIn("CC BY-SA", u["photo"]["attribution"])
        self.assertIsNone(so["photo"])  # rattigheter saknas -> inget foto publikt

    def test_field_photos_never_public_display_photo(self):
        only_field = [i for i in IMAGES if i["layer"] == "F"]
        gj = stones_geojson(INSCRIPTIONS, only_field)
        u = next(f["properties"] for f in gj["features"] if f["properties"]["signum"] == "U 9001")
        self.assertIsNone(u["photo"])

    def test_visited_from_seen_list(self):
        gj = stones_geojson(INSCRIPTIONS, IMAGES, seen={"U 9001"})
        u = next(f["properties"] for f in gj["features"] if f["properties"]["signum"] == "U 9001")
        so = next(f["properties"] for f in gj["features"] if f["properties"]["signum"] == "Sö 9002")
        self.assertTrue(u["visited"])
        self.assertFalse(so["visited"])
        self.assertEqual(gj["meta"]["visited"], 1)

    def test_own_photos_mark_visited(self):
        gj = stones_geojson(INSCRIPTIONS, IMAGES,
                            own_observations=[{"stone_ref": "Sö 9002",
                                               "image_ids": ["img-own-1"]}])
        so = next(f["properties"] for f in gj["features"] if f["properties"]["signum"] == "Sö 9002")
        self.assertTrue(so["visited"])
        self.assertEqual(so["own_photos"], ["img-own-1"])

    def test_directions_links(self):
        links = directions_links(59.85, 17.63)
        self.assertIn("59.85,17.63", links["google"])
        self.assertIn("maps.apple.com", links["apple"])
        gj = stones_geojson(INSCRIPTIONS, IMAGES)
        for f in gj["features"]:
            self.assertIn("google", f["properties"]["directions"])


if __name__ == "__main__":
    unittest.main()
