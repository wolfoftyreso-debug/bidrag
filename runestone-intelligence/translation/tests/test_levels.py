"""Tester for Level 2 (meaning) och Level 3 (presentation) - inkl. att bada
validerar mot sina kontrakt och att sparbarhetsreglerna haller."""

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "translation"))
sys.path.insert(0, str(ROOT / "data-contracts"))

from meaning import extract_meaning  # noqa: E402
from presentation import STYLE_SPEC, render_modern  # noqa: E402
from validator import validate_record  # noqa: E402

FORMULA = "burkil raisti stain þinsa aftir ulf sun sin"


class MeaningTests(unittest.TestCase):
    def test_memorial_formula_extraction(self):
        m = extract_meaning(FORMULA, basis_source="canonical",
                            inscription_id="ric-u-9001", interpretation_id="int-u-9001")
        names = {p["name"]: p["role"] for p in m["people"]}
        self.assertEqual(names, {"Burkil": "commissioner", "Ulf": "honoree"})
        self.assertEqual(m["relationships"][0]["type"], "son")
        self.assertIn("memorial_stone_erected", m["actions"])
        self.assertIn("remembrance", m["purpose"])
        for ctx in ("memorial", "family", "loss"):
            self.assertIn(ctx, m["emotional_context"])

    def test_level2_validates_and_is_unreviewed(self):
        m = extract_meaning(FORMULA, basis_source="canonical",
                            inscription_id="ric-u-9001", interpretation_id="int-u-9001")
        self.assertEqual(validate_record(m, "interpretation"), [])
        self.assertFalse(m["derivation"]["reviewed"])

    def test_canonical_basis_requires_inscription_id(self):
        m = extract_meaning(FORMULA, basis_source="canonical",
                            interpretation_id="int-x")
        errors = validate_record(m, "interpretation")
        self.assertTrue(any("inscription_id" in e for e in errors))

    def test_prayer_and_pride_detected(self):
        m = extract_meaning("kuþ hialbi ant hans trik kuþan", basis_source="observed",
                            interpretation_id="int-x")
        self.assertIn("prayer_offered", m["actions"])
        self.assertIn("faith", m["emotional_context"])
        self.assertIn("pride", m["emotional_context"])

    def test_every_person_cites_source_token(self):
        m = extract_meaning(FORMULA, basis_source="observed", interpretation_id="int-x")
        for p in m["people"]:
            self.assertIn(p["source_token"], FORMULA.split())


class PresentationTests(unittest.TestCase):
    def _interpretation(self):
        return extract_meaning(FORMULA, basis_source="canonical",
                               inscription_id="ric-u-9001", interpretation_id="int-u-9001")

    def test_render_contains_names_and_kinship(self):
        r = render_modern(self._interpretation(),
                          canonical_translation="Torkel reste stenen efter Ulf, sin son.",
                          rendering_id="ren-u-9001")
        self.assertIn("Burkil", r["text_sv"])
        self.assertIn("Ulf", r["text_sv"])
        self.assertIn("son", r["text_sv"])
        self.assertIn("glömma", r["text_sv"])  # loss -> "For att ingen skulle glomma."

    def test_canonical_rendering_is_scholarly_grounded_and_validates(self):
        r = render_modern(self._interpretation(), canonical_translation="...",
                          rendering_id="ren-u-9001")
        self.assertEqual(r["basis"], "canonical")
        self.assertTrue(r["scholarly_grounded"])
        self.assertEqual(validate_record(r, "rendering"), [])

    def test_formulaic_rendering_never_claims_scholarship(self):
        r = render_modern(self._interpretation(), rendering_id="ren-x")
        self.assertEqual(r["basis"], "formulaic")
        self.assertFalse(r["scholarly_grounded"])
        self.assertEqual(validate_record(r, "rendering"), [])
        forged = dict(r, scholarly_grounded=True)
        self.assertTrue(validate_record(forged, "rendering"))  # invariant stoppar

    def test_empty_semantics_renders_nothing(self):
        empty = extract_meaning("xq zz", basis_source="observed", interpretation_id="int-x")
        self.assertEqual(render_modern(empty, rendering_id="ren-x"), {})

    def test_style_spec_carries_the_hard_rules(self):
        for must in ("nya personer", "dodsorsaker", "citat", "BEVARA KARNAN"):
            self.assertIn(must, STYLE_SPEC)


if __name__ == "__main__":
    unittest.main()
