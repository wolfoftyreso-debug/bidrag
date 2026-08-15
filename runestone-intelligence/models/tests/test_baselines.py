"""Tester for baseline-adaptrar och rapportbygget."""

import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "models"))
sys.path.insert(0, str(ROOT / "benchmark"))
sys.path.insert(0, str(ROOT / "ingestion"))
sys.path.insert(0, str(ROOT / "data-contracts"))

from adapters import AbstainAdapter, ConstantAdapter, OracleAdapter, build_adapter  # noqa: E402
from evaluate import evaluate  # noqa: E402
from http_vlm import HttpVlmAdapter, extract_prediction  # noqa: E402
from run_baselines import run_adapter, summarize, train_transliterations  # noqa: E402

CASES = [
    {"case_id": "rb-1", "category": "A", "image_id": "img-1",
     "expected": {"transliteration": "han raisti stain", "abstention_expected": False}},
    {"case_id": "rb-2", "category": "C", "image_id": "img-2",
     "expected": {"transliteration": "tistil", "abstention_expected": True}},
]


class DiagnosticAdapterTests(unittest.TestCase):
    def test_oracle_gives_perfect_sequence_accuracy(self):
        preds = run_adapter(OracleAdapter(), CASES, None)
        report = evaluate(CASES, preds, evaluation_version="v1")
        self.assertEqual(report["metrics"]["sequence_accuracy"], 1.0)
        # men oracle svarar aven pa abstention-fall: false confidence syns
        self.assertEqual(report["metrics"]["false_confidence"], 1)

    def test_abstain_scores_zero_reading_but_full_abstention_recall(self):
        preds = run_adapter(AbstainAdapter(), CASES, None)
        report = evaluate(CASES, preds, evaluation_version="v1")
        self.assertEqual(report["metrics"]["answered"], 0)
        self.assertIsNone(report["metrics"]["sequence_accuracy"])
        self.assertEqual(report["metrics"]["abstention_recall"], 1.0)
        self.assertEqual(report["metrics"]["over_abstentions"], 1)

    def test_constant_uses_majority_and_honest_confidence(self):
        adapter = ConstantAdapter(["a b", "a b", "c"])
        pred = adapter.predict(CASES[0])
        self.assertEqual(pred["transliteration"], "a b")
        self.assertAlmostEqual(pred["confidence"], 2 / 3)

    def test_constant_requires_training_data(self):
        with self.assertRaises(ValueError):
            build_adapter("constant", train_transliterations=[])

    def test_all_diagnostic_flagged(self):
        for adapter in (OracleAdapter(), AbstainAdapter(), ConstantAdapter(["x"])):
            self.assertTrue(adapter.is_diagnostic)

    def test_unknown_adapter_rejected(self):
        with self.assertRaises(ValueError):
            build_adapter("gpt-visionary-9000")


class HttpVlmTests(unittest.TestCase):
    def test_extract_valid_json(self):
        self.assertEqual(
            extract_prediction('{"transliteration": "han raisti", "confidence": 0.8, "abstain": false}'),
            {"transliteration": "han raisti", "confidence": 0.8, "abstained": False})

    def test_extract_fenced_json_with_prose(self):
        reply = 'Har ar min lasning:\n```json\n{"transliteration": "tistil", "confidence": 0.5, "abstain": false}\n```'
        self.assertEqual(extract_prediction(reply)["transliteration"], "tistil")

    def test_abstain_reply(self):
        parsed = extract_prediction('{"abstain": true}')
        self.assertTrue(parsed["abstained"])
        self.assertIsNone(parsed["transliteration"])

    def test_invalid_replies_become_none_not_guesses(self):
        for bad in ("", "ingen json alls",
                    '{"transliteration": "", "confidence": 0.5, "abstain": false}',
                    '{"transliteration": "x", "confidence": 1.5, "abstain": false}',
                    '{"transliteration": "x", "confidence": true, "abstain": false}',
                    '{"transliteration": 42, "confidence": 0.5, "abstain": false}'):
            self.assertIsNone(extract_prediction(bad), bad)

    def test_missing_image_becomes_abstention(self):
        adapter = HttpVlmAdapter("http://localhost:1/nope", "gemma-test")
        pred = adapter.predict(CASES[0], image_path=None)
        self.assertTrue(pred["abstained"])
        self.assertIn("bild saknas", pred["note"])

    def test_from_env_requires_config(self):
        import os
        old = {k: os.environ.pop(k, None) for k in ("VLM_ENDPOINT", "VLM_MODEL")}
        try:
            with self.assertRaises(RuntimeError):
                HttpVlmAdapter.from_env()
        finally:
            for k, v in old.items():
                if v is not None:
                    os.environ[k] = v


class EndToEndBaselineTests(unittest.TestCase):
    def test_full_baseline_run_on_fixture_corpus(self):
        from build_benchmark import build_cases
        from build_corpus import build
        from contracts import read_jsonl

        with tempfile.TemporaryDirectory() as tmp:
            corpus = Path(tmp) / "corpus"
            # seed 8 lagger ric-u-9001 (stenen med bilder) i unknown_stone_test
            build(srd_path=ROOT / "ingestion/fixtures/srd_sample.jsonl",
                  images_path=ROOT / "ingestion/fixtures/hf_sample.jsonl",
                  out_dir=corpus, version="v0.1",
                  timestamp="2026-08-15T00:00:00Z", seed=8)
            split = json.loads((corpus / "split.json").read_text())
            self.assertIn(split["ric-u-9001"], ("test", "unknown_stone_test"))

            inscriptions = read_jsonl(corpus / "inscriptions.jsonl")
            images = read_jsonl(corpus / "images.jsonl")
            cases, _ = build_cases(inscriptions, images, split, benchmark_version="v1")
            self.assertGreater(len(cases), 0)

            train = train_transliterations(corpus)
            self.assertNotIn("iksimbil", train)  # teststenen lacker inte in i golvet

            results = {}
            for name in ("abstain", "constant", "oracle"):
                adapter = build_adapter(name, train_transliterations=train)
                preds = run_adapter(adapter, cases, None)
                results[name] = {
                    "report": evaluate(cases, preds, evaluation_version="v1"),
                    "is_diagnostic": adapter.is_diagnostic,
                }

            self.assertEqual(results["oracle"]["report"]["metrics"]["sequence_accuracy"], 1.0)
            constant_seq = results["constant"]["report"]["metrics"]["sequence_accuracy"]
            self.assertLess(constant_seq, 1.0)  # golvet loser inte teststenen

            summary = summarize(results)
            self.assertIn("| oracle | ja |", summary)
            self.assertIn("| constant | ja |", summary)


if __name__ == "__main__":
    unittest.main()
