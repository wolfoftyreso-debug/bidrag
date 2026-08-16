"""Tester for master-assembleringen: struktur, L1-orordhet och blandskydd."""

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "knowledge"))

from master import assemble_master  # noqa: E402

INSCRIPTION = {
    "inscription_id": "ric-u-9001", "signum": "U 9001", "country": "Sweden",
    "region": "Uppland", "rune_type": "younger_futhark", "dating": "V",
    "runic_text": "ᛁᚴᛋᛁᛘᛒᛁᛚ", "transliteration": "iksimbil",
    "normalization": "exempel", "translation_sv": "Syntetisk exempelpost 1.",
    "translation_en": "Synthetic example 1.",
    "coordinates": {"latitude": 59.85, "longitude": 17.63},
    "source_database": "Scandinavian Runic-text Database",
    "source_provider": "Uppsala University",
    "scholarly_status": "established",
    "bibliography": ["Exempelreferens 1901"],
    "enrichments": [{"source": "Runor / K-samsok (Riksantikvarieambetet)",
                     "source_record_id": "raa-ex-1", "fields": ["coordinates"]}],
}
IMAGES = [
    {"image_id": "img-hf-0001", "inscription_id": "ric-u-9001", "layer": "C",
     "license": "CC BY-SA 4.0", "photographer": "A", "source_institution": "HF"},
    {"image_id": "img-field-1", "inscription_id": "ric-u-9001", "layer": "F",
     "license": "user-contributed", "observation_id": "obs-x"},
]
STONE = {"stone_id": "stone-u-9001", "inscription_id": "ric-u-9001",
         "atlas_status": "registered_known", "current_condition": "standing",
         "observation_count": 3, "last_observation": "2026-08-14T11:45:00Z",
         "municipality": "Uppsala", "accessibility": "easy",
         "location": {"latitude": 59.85, "longitude": 17.63}}
RENDERING = {"text_sv": "Nagon reste den har stenen...", "style": "emotion_first",
             "scholarly_grounded": True, "reviewed": False}


class MasterAssemblyTests(unittest.TestCase):
    def test_full_tree(self):
        m = assemble_master(INSCRIPTION, images=IMAGES, stone=STONE, rendering=RENDERING)
        self.assertEqual(m["identity"]["signum"], "U 9001")
        self.assertEqual(m["identity"]["municipality"], "Uppsala")
        self.assertEqual(m["location"]["accessibility"], "easy")
        self.assertEqual(len(m["visual"]["official_photographs"]), 1)
        self.assertEqual(len(m["visual"]["field_photographs"]), 1)
        self.assertEqual(m["inscription"]["scholarly_translation"]["sv"],
                         "Syntetisk exempelpost 1.")
        self.assertEqual(m["interpretation"]["modern_sv"], "Nagon reste den har stenen...")
        self.assertIn("Runor / K-samsok (Riksantikvarieambetet)", m["sources"]["enrichments"])
        self.assertEqual(m["atlas"]["observation_count"], 3)
        self.assertEqual(m["sources"]["user_observations"], ["obs-x"])

    def test_source_truth_passes_through_unmutated(self):
        before = dict(INSCRIPTION)
        m = assemble_master(INSCRIPTION, images=IMAGES)
        self.assertEqual(INSCRIPTION, before)  # ingen mutation av L1
        self.assertEqual(m["inscription"]["transliteration"], "iksimbil")

    def test_minimal_assembly(self):
        m = assemble_master({"inscription_id": "ric-x", "signum": "X 1",
                             "transliteration": "abc",
                             "source_database": "SRD", "source_provider": "UU"})
        self.assertIsNone(m["location"])
        self.assertIsNone(m["interpretation"]["modern_sv"])
        self.assertEqual(m["visual"]["image_fingerprints"], [])

    def test_refuses_to_mix_stones(self):
        wrong_image = [{"image_id": "img-x", "inscription_id": "ric-other", "layer": "C",
                        "license": "CC0"}]
        with self.assertRaises(ValueError):
            assemble_master(INSCRIPTION, images=wrong_image)
        with self.assertRaises(ValueError):
            assemble_master(INSCRIPTION, stone={"stone_id": "s", "inscription_id": "ric-other"})


if __name__ == "__main__":
    unittest.main()
