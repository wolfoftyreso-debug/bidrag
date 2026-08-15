"""Tester for RUNEBENCH: metrics mot handraknade varden, casebygge fran
corpus och evalueringsharnesset end-to-end."""

import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[2]
sys.path.insert(0, str(ROOT / "benchmark"))
sys.path.insert(0, str(ROOT / "ingestion"))
sys.path.insert(0, str(ROOT / "data-contracts"))

from build_benchmark import build_cases, categorize  # noqa: E402
from evaluate import evaluate  # noqa: E402
from metrics import (  # noqa: E402
    abstention_metrics,
    cer,
    edit_distance,
    expected_calibration_error,
    rune_accuracy,
    sequence_correct,
    wer,
)
from validator import validate_record  # noqa: E402

FIXTURES = ROOT / "ingestion" / "fixtures"
TS = "2026-08-15T00:00:00Z"


class MetricsTests(unittest.TestCase):
    def test_edit_distance_known_values(self):
        self.assertEqual(edit_distance("kitten", "sitting"), 3)
        self.assertEqual(edit_distance("", "abc"), 3)
        self.assertEqual(edit_distance("abc", "abc"), 0)
        self.assertEqual(edit_distance(["a", "b"], ["a", "c"]), 1)

    def test_cer_and_rune_accuracy(self):
        self.assertAlmostEqual(cer("abc", "abd"), 1 / 3)
        self.assertAlmostEqual(rune_accuracy("abc", "abd"), 2 / 3)
        self.assertEqual(rune_accuracy("ab", "wxyz"), 0.0)  # golvad, CER > 1
        self.assertIsNone(cer("", "x"))  # odefinierad, inte 0

    def test_wer(self):
        self.assertAlmostEqual(wer("han raisti stain", "han risti stain"), 1 / 3)
        self.assertIsNone(wer("", "x"))

    def test_sequence_correct_normalizes_whitespace(self):
        self.assertTrue(sequence_correct("han  raisti", "han raisti"))
        self.assertFalse(sequence_correct("han raisti", "han risti"))

    def test_ece_hand_computed(self):
        # En bin: medelconf 0.9, accuracy 0.5 -> ECE 0.4
        self.assertAlmostEqual(
            expected_calibration_error([(0.9, True), (0.9, False)]), 0.4)
        # Perfekt kalibrerad och korrekt
        self.assertAlmostEqual(
            expected_calibration_error([(1.0, True), (1.0, True)]), 0.0)
        self.assertIsNone(expected_calibration_error([]))

    def test_abstention_metrics(self):
        cases = [
            {"expected_abstain": True, "abstained": True, "correct": None},    # TP
            {"expected_abstain": True, "abstained": False, "correct": False},  # false confidence
            {"expected_abstain": False, "abstained": True, "correct": None},   # over-abstention
            {"expected_abstain": False, "abstained": False, "correct": True},
        ]
        m = abstention_metrics(cases)
        self.assertEqual(m["true_abstentions"], 1)
        self.assertEqual(m["false_confidence"], 1)
        self.assertEqual(m["over_abstentions"], 1)
        self.assertAlmostEqual(m["abstention_precision"], 0.5)
        self.assertAlmostEqual(m["abstention_recall"], 0.5)
        self.assertAlmostEqual(m["abstention_f1"], 0.5)

    def test_abstention_undefined_without_expected_cases(self):
        m = abstention_metrics([{"expected_abstain": False, "abstained": False, "correct": True}])
        self.assertIsNone(m["abstention_recall"])
        self.assertIsNone(m["abstention_f1"])


def _corpus_with_test_stone():
    """Bygger fixturcorpuset med ett seed dar en sten med bilder hamnar i
    test/unknown_stone_test, sa att benchmarkfall kan skapas."""
    from build_corpus import build  # importeras har for att undvika sys.path-krock
    from contracts import read_jsonl

    tmp = tempfile.TemporaryDirectory()
    out = Path(tmp.name) / "corpus"
    import json as _json
    for seed in range(1, 300):
        summary = build(srd_path=FIXTURES / "srd_sample.jsonl",
                        images_path=FIXTURES / "hf_sample.jsonl",
                        out_dir=out, version="v0.1", timestamp=TS, seed=seed)
        split = _json.loads((out / "split.json").read_text())
        if split.get("ric-u-9001") in ("test", "unknown_stone_test"):
            return tmp, out, split, summary
    raise AssertionError("hittade inget seed som lagger ric-u-9001 i test")


class BuildBenchmarkTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls._tmp, cls.corpus, cls.split, _ = _corpus_with_test_stone()
        import json
        cls.inscriptions = [json.loads(l) for l in (cls.corpus / "inscriptions.jsonl").read_text().splitlines() if l]
        cls.images = [json.loads(l) for l in (cls.corpus / "images.jsonl").read_text().splitlines() if l]

    @classmethod
    def tearDownClass(cls):
        cls._tmp.cleanup()

    def test_cases_validate_and_only_from_test_partitions(self):
        cases, skipped = build_cases(self.inscriptions, self.images, self.split,
                                     benchmark_version="v1")
        self.assertGreater(len(cases), 0)
        for case in cases:
            self.assertEqual(validate_record(case, "benchmark-case"), [])
            self.assertIn(case["split"], ("test", "unknown_stone_test"))
            self.assertFalse(case["gold"])  # promotion sker aldrig automatiskt

    def test_train_stones_never_leak(self):
        cases, _ = build_cases(self.inscriptions, self.images, self.split,
                               benchmark_version="v1")
        train_ids = {iid for iid, p in self.split.items() if p in ("train", "val")}
        for case in cases:
            if case["inscription_id"] is not None:
                self.assertNotIn(case["inscription_id"], train_ids)

    def test_unknown_stone_cases_hide_identity(self):
        split = dict(self.split)
        split["ric-u-9001"] = "unknown_stone_test"
        cases, _ = build_cases(self.inscriptions, self.images, split,
                               benchmark_version="v1")
        unknown = [c for c in cases if c["split"] == "unknown_stone_test"]
        self.assertGreater(len(unknown), 0)
        for case in unknown:
            self.assertIsNone(case["inscription_id"])
            self.assertIsNone(case["signum"])
            self.assertEqual(case["category"], "I")

    def test_low_resolution_categorization_and_abstention(self):
        image = {"image_id": "img-x", "inscription_id": "i", "resolution": {"width": 300, "height": 200}}
        inscription = {"transliteration": "kort"}
        self.assertEqual(categorize("test", image, inscription), "C")
        cases, _ = build_cases(
            [{"inscription_id": "i", "signum": "U 9001", "transliteration": "kort",
              "runic_text": None, "normalization": None, "translation_sv": None}],
            [image], {"i": "test"}, benchmark_version="v1")
        self.assertTrue(cases[0]["expected"]["abstention_expected"])

    def test_unmatched_images_are_reported_not_silent(self):
        _, skipped = build_cases(self.inscriptions, self.images, self.split,
                                 benchmark_version="v1")
        reasons = [s["reason"] for s in skipped]
        self.assertTrue(any("omatchad" in r for r in reasons))


class EvaluateTests(unittest.TestCase):
    CASES = [
        {"case_id": "rb-1", "category": "A",
         "expected": {"transliteration": "han raisti stain", "abstention_expected": False}},
        {"case_id": "rb-2", "category": "A",
         "expected": {"transliteration": "tistil mistil", "abstention_expected": False}},
        {"case_id": "rb-3", "category": "C",
         "expected": {"transliteration": "kistil", "abstention_expected": True}},
        {"case_id": "rb-4", "category": "A",
         "expected": {"transliteration": "aldrig besvarad", "abstention_expected": False}},
    ]

    def test_report_shape_and_values(self):
        predictions = [
            {"case_id": "rb-1", "transliteration": "han raisti stain", "confidence": 0.95, "abstained": False},
            {"case_id": "rb-2", "transliteration": "tistil mistil fistil", "confidence": 0.80, "abstained": False},
            {"case_id": "rb-3", "transliteration": None, "confidence": 0.2, "abstained": True},
        ]
        report = evaluate(self.CASES, predictions, evaluation_version="v1")
        m = report["metrics"]
        self.assertEqual(report["missing_predictions"], ["rb-4"])  # aldrig tyst
        self.assertEqual(m["answered"], 2)
        self.assertAlmostEqual(m["sequence_accuracy"], 0.5)
        self.assertEqual(m["true_abstentions"], 1)
        self.assertEqual(m["false_confidence"], 0)
        self.assertIn("A", report["per_category"])
        self.assertIn("calibration_ece", m)

    def test_false_confidence_detected(self):
        predictions = [
            {"case_id": "rb-3", "transliteration": "gissning", "confidence": 0.99, "abstained": False},
        ]
        report = evaluate(self.CASES, predictions, evaluation_version="v1")
        self.assertEqual(report["metrics"]["false_confidence"], 1)

    def test_registry_compatible_keys(self):
        report = evaluate(self.CASES, [], evaluation_version="v1")
        entry = {
            "model_name": "runestone-vision", "model_version": "0.1.0",
            "status": "BENCHMARKED", "dataset_version": "v0.1",
            "code_commit": "0123456789abcdef0123456789abcdef01234567",
            "training_config": "training/configs/x.yaml", "base_model": None,
            "hyperparameters": {}, "gpu_environment": "test",
            "evaluation_version": "v1",
            "benchmark_results": {"benchmark_version": "v1",
                                  "metrics": report["metrics"], "report_path": None},
        }
        self.assertEqual(validate_record(entry, "model-registry-entry"), [])


if __name__ == "__main__":
    unittest.main()
