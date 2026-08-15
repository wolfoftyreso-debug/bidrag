"""Tester for RuneTranslation: runmappning, normalisering och policykedjan
canonical -> formulaic -> abstain."""

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "translation"))

from normalize import normalization_coverage, normalize_tokens  # noqa: E402
from runes import transliterate_runes  # noqa: E402
from translate import formulaic_translation, translate  # noqa: E402


class RuneMappingTests(unittest.TestCase):
    def test_younger_futhark_word(self):
        r = transliterate_runes("ᚼᛅᚾ ᛬ ᚱᛅᛁᛋᛏᛁ ᛬ ᛋᛏᛅᛁᚾ")
        self.assertEqual(r["transliteration"], "han raisti stain")
        self.assertEqual(r["unknown"], [])
        self.assertEqual(r["coverage"], 1.0)

    def test_separators_become_spaces(self):
        self.assertEqual(transliterate_runes("ᚠᚢ·ᚦ")["transliteration"], "fu þ")

    def test_unknown_rune_reported_never_dropped(self):
        r = transliterate_runes("ᚼᛅ𐌰")  # gotiskt tecken: inte i yngre futharken
        self.assertIn("?", r["transliteration"])
        self.assertEqual(len(r["unknown"]), 1)
        self.assertEqual(r["unknown"][0]["position"], 2)
        self.assertLess(r["coverage"], 1.0)

    def test_yr_rune_keeps_capital_R(self):
        self.assertEqual(transliterate_runes("ᛅᚠᛏᛁᛦ")["transliteration"], "aftiR")

    def test_empty_input(self):
        r = transliterate_runes("")
        self.assertEqual(r["transliteration"], "")
        self.assertEqual(r["coverage"], 0.0)


class NormalizationTests(unittest.TestCase):
    def test_formula_words_normalize(self):
        tokens = normalize_tokens("auk raisti stain þinsa aftir sun sin")
        normalized = [t["normalized"] for t in tokens]
        self.assertEqual(normalized, ["ok", "ræisti", "stæin", "þennsa", "æftiR", "sun", "sinn"])
        self.assertTrue(all(t["resolved"] for t in tokens))

    def test_unknown_token_passes_through_unresolved(self):
        tokens = normalize_tokens("burkil raisti")
        self.assertFalse(tokens[0]["resolved"])
        self.assertEqual(tokens[0]["normalized"], "burkil")  # aldrig gissad
        self.assertTrue(tokens[1]["resolved"])

    def test_coverage(self):
        tokens = normalize_tokens("burkil raisti stain")
        self.assertAlmostEqual(normalization_coverage(tokens), 2 / 3)
        self.assertEqual(normalization_coverage([]), 0.0)


class FormulaicTranslationTests(unittest.TestCase):
    def test_memorial_formula_translates_with_name_preserved(self):
        out = formulaic_translation("burkil raisti stain þinsa aftir ulf sun sin")
        self.assertIsNotNone(out)
        self.assertIn("reste", out["translation_sv"])
        self.assertIn("Burkil", out["translation_sv"])  # namn behalls, versal
        self.assertIn("Ulf", out["translation_sv"])
        self.assertIn("efter", out["translation_sv"])
        kinds = {t["kind"] for t in out["tokens"]}
        self.assertEqual(kinds, {"formula", "unresolved"})

    def test_low_coverage_refuses(self):
        self.assertIsNone(formulaic_translation("burkil ulfr ketill asmundr raisti"))

    def test_too_short_refuses(self):
        self.assertIsNone(formulaic_translation("raisti stain"))


class TranslatePolicyTests(unittest.TestCase):
    VERIFIED = {
        "status": "verified",
        "presented_scholarly_status": "established",
        "identification": {"signum": "U 9001"},
        "source": {"translation_sv": "Torkel reste denna sten efter Ulf, sin son.",
                   "source_database": "Scandinavian Runic-text Database",
                   "source_provider": "Uppsala University"},
    }

    def test_canonical_translation_wins(self):
        out = translate("burkil raisti stain", self.VERIFIED)
        self.assertEqual(out["method"], "canonical")
        self.assertFalse(out["abstained"])
        self.assertEqual(out["translation_source"]["source_provider"], "Uppsala University")
        self.assertEqual(out["translation_source"]["signum"], "U 9001")

    def test_mismatch_never_falls_back_to_formula(self):
        # Lasningen motsager en kand sten: hellre abstention an att
        # formeloversatta en text verifieringen redan underkant.
        mismatch = {"status": "mismatch", "source": {"translation_sv": "..."}}
        out = translate("burkil raisti stain þinsa aftir ulf sun sin", mismatch)
        self.assertTrue(out["abstained"])
        self.assertEqual(out["scholarly_status"], "insufficient_evidence")
        self.assertIn("alternativ analys", out["reason"])

    def test_unknown_stone_gets_formulaic(self):
        out = translate("burkil raisti stain þinsa aftir ulf sun sin",
                        {"status": "no_candidates"})
        self.assertEqual(out["method"], "formulaic")
        self.assertEqual(out["scholarly_status"], "uncertain")
        self.assertIn("coverage", out)

    def test_gps_only_suggestions_allow_formulaic(self):
        out = translate("burkil raisti stain þinsa aftir ulf sun sin",
                        {"status": "gps_only_suggestions"})
        self.assertEqual(out["method"], "formulaic")

    def test_unreadable_text_abstains(self):
        out = translate("xq zzk brr", {"status": "no_candidates"})
        self.assertTrue(out["abstained"])
        self.assertIsNone(out["translation_sv"])

    def test_verified_without_source_translation_falls_through(self):
        verdict = {"status": "verified", "presented_scholarly_status": "established",
                   "identification": {"signum": "U 9001"},
                   "source": {"translation_sv": None}}
        out = translate("xq zzk brr", verdict)
        self.assertTrue(out["abstained"])


class FullChainTests(unittest.TestCase):
    def test_runes_to_swedish_formula(self):
        # ᛒᚢᚱᚴᛁᛚ ᚱᛅᛁᛋᛏᛁ ᛋᛏᛅᛁᚾ ᚦᛁᚾᛋᛅ ᛅᚠᛏᛁᛦ ᚢᛚᚠ ᛋᚢᚾ ᛋᛁᚾ
        runic = "ᛒᚢᚱᚴᛁᛚ ᛬ ᚱᛅᛁᛋᛏᛁ ᛬ ᛋᛏᛅᛁᚾ ᛬ ᚦᛁᚾᛋᛅ ᛬ ᛅᚠᛏᛁᛦ ᛬ ᚢᛚᚠ ᛬ ᛋᚢᚾ ᛬ ᛋᛁᚾ"
        step1 = transliterate_runes(runic)
        self.assertEqual(step1["transliteration"],
                         "burkil raisti stain þinsa aftiR ulf sun sin")
        out = translate(step1["transliteration"], {"status": "no_candidates"})
        self.assertEqual(out["method"], "formulaic")
        self.assertEqual(
            out["translation_sv"],
            "Burkil reste stenen denna efter Ulf son sin")


if __name__ == "__main__":
    unittest.main()
