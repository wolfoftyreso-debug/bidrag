"""Tester for Context Engine: kallstatus-separationen, blockurval och
berattelsekomposition."""

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "knowledge"))
sys.path.insert(0, str(ROOT / "translation"))

from context import CONTEXT_SPEC, LIBRARY_VERSION, build_context, compose_story  # noqa: E402
from meaning import extract_meaning  # noqa: E402

INSCRIPTION = {
    "inscription_id": "ric-u-9001", "signum": "U 9001", "region": "Uppland",
    "location": "Exempelsocken", "dating": "V", "rune_type": "younger_futhark",
    "style": "Pr 3", "carver": "Exempelristaren",
    "transliteration": "iksimbil",
}


class ContextTests(unittest.TestCase):
    def test_established_blocks_only_from_record_fields(self):
        ctx = build_context(INSCRIPTION)
        established = [b for b in ctx["blocks"] if b["kind"] == "established"]
        topics = {b["topic"] for b in established}
        self.assertEqual(topics, {"datering", "ristare", "stil", "plats"})
        for b in established:
            self.assertTrue(b["source"].startswith("corpus:"), b["source"])

    def test_known_carver_beats_anonymous_background(self):
        ctx = build_context(INSCRIPTION)
        topics_by_kind = {(b["kind"], b["topic"]) for b in ctx["blocks"]}
        self.assertIn(("established", "ristare"), topics_by_kind)
        self.assertNotIn(("general_background", "ristaren"), topics_by_kind)
        # utan ristare: bakgrundsblocket om anonyma ristare i stallet
        anon = build_context({**INSCRIPTION, "carver": None})
        kinds = {(b["kind"], b["topic"]) for b in anon["blocks"]}
        self.assertIn(("general_background", "ristaren"), kinds)

    def test_unknown_stone_has_no_established_blocks(self):
        interp = extract_meaning("burkil raisti stain þinsa aftir ulf sun sin",
                                 basis_source="observed", interpretation_id="int-x")
        ctx = build_context(None, interp)
        self.assertNotIn("established", ctx["kinds_present"])
        self.assertIn("interpreted", ctx["kinds_present"])
        self.assertIn("general_background", ctx["kinds_present"])

    def test_interpreted_block_names_people(self):
        interp = extract_meaning("burkil raisti stain þinsa aftir ulf sun sin",
                                 basis_source="observed", interpretation_id="int-x")
        ctx = build_context(None, interp)
        block = next(b for b in ctx["blocks"] if b["topic"] == "människorna")
        self.assertIn("Burkil", block["text_sv"])
        self.assertIn("Ulf", block["text_sv"])
        self.assertEqual(block["kind"], "interpreted")

    def test_prayer_triggers_christianization_background(self):
        interp = extract_meaning("kuþ hialbi ant hans", basis_source="observed",
                                 interpretation_id="int-x")
        ctx = build_context(None, interp)
        self.assertTrue(any(b["topic"] == "kristnandet" for b in ctx["blocks"]))
        no_prayer = build_context(INSCRIPTION)
        self.assertFalse(any(b["topic"] == "kristnandet" for b in no_prayer["blocks"]))

    def test_style_hint_is_marked_as_dating_convention(self):
        ctx = build_context(INSCRIPTION)
        style_block = next(b for b in ctx["blocks"] if b["topic"] == "stil")
        self.assertIn("brukar", style_block["text_sv"])  # aldrig "ar daterad till"
        self.assertIn(f"library:styles@{LIBRARY_VERSION}", style_block["source"])

    def test_every_block_has_source_and_kind(self):
        ctx = build_context(INSCRIPTION)
        for b in ctx["blocks"]:
            self.assertIn(b["kind"], ("established", "interpreted", "general_background"))
            self.assertTrue(b["source"])

    def test_story_composition_order(self):
        interp = extract_meaning("burkil raisti stain þinsa aftir ulf sun sin",
                                 basis_source="observed", interpretation_id="int-x")
        ctx = build_context(INSCRIPTION, interp)
        story = compose_story(ctx, {"text_sv": "Burkil reste den har stenen."})
        self.assertTrue(story.startswith("Burkil reste den har stenen."))
        # manniskorna fore tidsbilden
        self.assertLess(story.index("Burkil,") if "Burkil," in story else story.index("Burkil"),
                        story.index("950-1100"))

    def test_context_spec_carries_hard_rules(self):
        for must in ("established", "ALDRIG", "dodsorsaker", "tidsbild"):
            self.assertIn(must, CONTEXT_SPEC)


if __name__ == "__main__":
    unittest.main()
