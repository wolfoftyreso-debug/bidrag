#!/usr/bin/env python3
"""Automatiserad evaluering mot RUNEBENCH.

Input:
  cases.jsonl        - fran build_benchmark.py
  predictions.jsonl  - en rad per fall:
      {"case_id": "...", "transliteration": "...", "confidence": 0.93,
       "abstained": false}

Regler:
- Fall utan prediction raknas som missing (rapporteras) - en modell far
  inte se battre ut genom att hoppa over svara fall.
- Abstention pa ett abstention_expected-fall ar korrekt beteende;
  svar med hog confidence pa samma fall ar false confidence (samsta
  utfallet, plan §21/§45).
- Rapportens metrics-block har samma nyckelnamn som
  model-registry-entry.benchmark_results.metrics - resultatet kan
  kopplas direkt till modellregistret (ingen production utan benchmark).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from metrics import (  # noqa: E402
    abstention_metrics,
    cer,
    expected_calibration_error,
    rune_accuracy,
    sequence_correct,
    wer,
)


def _mean(values: list[float]) -> float | None:
    values = [v for v in values if v is not None]
    return sum(values) / len(values) if values else None


def evaluate(cases: list[dict], predictions: list[dict], *, evaluation_version: str) -> dict:
    preds = {p["case_id"]: p for p in predictions}
    missing = [c["case_id"] for c in cases if c["case_id"] not in preds]

    per_case: list[dict] = []
    for case in cases:
        pred = preds.get(case["case_id"])
        if pred is None:
            continue
        expected_abstain = bool(case["expected"].get("abstention_expected"))
        abstained = bool(pred.get("abstained"))
        ref = case["expected"]["transliteration"]
        hyp = pred.get("transliteration", "") if not abstained else ""
        correct = sequence_correct(ref, hyp) if not abstained else None
        per_case.append({
            "case_id": case["case_id"],
            "category": case["category"],
            "expected_abstain": expected_abstain,
            "abstained": abstained,
            "confidence": pred.get("confidence"),
            "cer": cer(ref, hyp) if not abstained else None,
            "wer": wer(ref, hyp) if not abstained else None,
            "rune_accuracy": rune_accuracy(ref, hyp) if not abstained else None,
            "correct": correct,
        })

    answered = [c for c in per_case if not c["abstained"] and not c["expected_abstain"]]
    calibration_pairs = [
        (c["confidence"], bool(c["correct"]))
        for c in per_case
        if not c["abstained"] and c["confidence"] is not None
    ]

    def block(rows: list[dict]) -> dict:
        answered_rows = [r for r in rows if not r["abstained"] and not r["expected_abstain"]]
        return {
            "cases": len(rows),
            "answered": len(answered_rows),
            "character_error_rate": _mean([r["cer"] for r in answered_rows]),
            "word_error_rate": _mean([r["wer"] for r in answered_rows]),
            "rune_accuracy": _mean([r["rune_accuracy"] for r in answered_rows]),
            "sequence_accuracy": _mean([1.0 if r["correct"] else 0.0 for r in answered_rows]),
        }

    categories = sorted({c["category"] for c in per_case})
    report = {
        "evaluation_version": evaluation_version,
        "total_cases": len(cases),
        "missing_predictions": missing,
        "metrics": {
            **block(per_case),
            "calibration_ece": expected_calibration_error(calibration_pairs),
            **abstention_metrics(per_case),
        },
        "per_category": {cat: block([c for c in per_case if c["category"] == cat])
                         for cat in categories},
        "per_case": per_case,
    }
    return report


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cases", required=True, type=Path)
    ap.add_argument("--predictions", required=True, type=Path)
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--version", required=True, help="evaluation_version, t.ex. v1")
    args = ap.parse_args()

    def load_jsonl(p: Path) -> list[dict]:
        return [json.loads(line) for line in p.read_text(encoding="utf-8").splitlines() if line.strip()]

    report = evaluate(load_jsonl(args.cases), load_jsonl(args.predictions),
                      evaluation_version=args.version)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    printable = {k: v for k, v in report.items() if k != "per_case"}
    print(json.dumps(printable, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
