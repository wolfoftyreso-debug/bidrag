#!/usr/bin/env python3
"""Phase 1 (plan §28/§44): kor baselines mot RUNEBENCH och bygg
jamforelserapporten.

    python3 run_baselines.py --cases <runebench>/cases.jsonl \
        --corpus <corpus-dir> --out-dir /tmp/baselines \
        --adapters abstain,constant [--images-dir <dir>] [--include-oracle]

Per adapter skrivs predictions.jsonl + report.json; summary.md jamfor alla.
Diagnostiska adaptrar (oracle/abstain/constant) markeras i rapporten - de
ar matstickor for harnesset och golv, aldrig "baseline-resultat".
Fragan projektet ska besvara ar om en specialiserad modell slar en generell
VLM (http_vlm) - och den jamforelsen sker alltid har, pa samma fall.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

_HERE = Path(__file__).parent
sys.path.insert(0, str(_HERE))
sys.path.insert(0, str(_HERE.parent / "benchmark"))

from adapters import build_adapter  # noqa: E402
from evaluate import evaluate  # noqa: E402


def _load_jsonl(path: Path) -> list[dict]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def train_transliterations(corpus_dir: Path) -> list[str]:
    """Translittereringar fran train-partitionen - aldrig test (split respekteras
    aven av golvbaselines)."""
    split = json.loads((corpus_dir / "split.json").read_text(encoding="utf-8"))
    inscriptions = _load_jsonl(corpus_dir / "inscriptions.jsonl")
    return [ins["transliteration"] for ins in inscriptions
            if split.get(ins["inscription_id"]) == "train"]


def run_adapter(adapter, cases: list[dict], images_dir: Path | None) -> list[dict]:
    predictions = []
    for case in cases:
        image_path = None
        if images_dir is not None:
            candidate = images_dir / f"{case['image_id']}.jpg"
            image_path = candidate if candidate.is_file() else None
        predictions.append(adapter.predict(case, image_path))
    return predictions


def _fmt(value) -> str:
    return "-" if value is None else f"{value:.3f}"


def summarize(results: dict[str, dict]) -> str:
    lines = [
        "# Baseline Report",
        "",
        "| Adapter | Diagnostisk | CER | Rune acc | Seq acc | ECE | False conf | Abstention F1 |",
        "|---|---|---|---|---|---|---|---|",
    ]
    for name, entry in results.items():
        m = entry["report"]["metrics"]
        lines.append(
            f"| {name} | {'ja' if entry['is_diagnostic'] else 'nej'} "
            f"| {_fmt(m['character_error_rate'])} | {_fmt(m['rune_accuracy'])} "
            f"| {_fmt(m['sequence_accuracy'])} | {_fmt(m['calibration_ece'])} "
            f"| {m['false_confidence']} | {_fmt(m['abstention_f1'])} |"
        )
    lines += [
        "",
        "Diagnostiska adaptrar ar matstickor (oracle = harness-sanity, "
        "abstain = abstention-golv, constant = prior-golv). En riktig baseline "
        "ar t.ex. http_vlm mot en Gemma-endpoint; en specialiserad modell "
        "maste sla den for att motivera vidare komplexitet (princip 12).",
        "",
    ]
    return "\n".join(lines)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cases", required=True, type=Path)
    ap.add_argument("--corpus", required=True, type=Path,
                    help="corpuskatalog (for constant-baselinens traningsdata)")
    ap.add_argument("--out-dir", required=True, type=Path)
    ap.add_argument("--adapters", default="abstain,constant")
    ap.add_argument("--images-dir", type=Path, default=None)
    ap.add_argument("--include-oracle", action="store_true",
                    help="kor aven oracle (harness-sanity: ska ge seq acc 1.0)")
    ap.add_argument("--version", default="v1")
    args = ap.parse_args()

    cases = _load_jsonl(args.cases)
    names = [n.strip() for n in args.adapters.split(",") if n.strip()]
    if args.include_oracle and "oracle" not in names:
        names.append("oracle")

    train = train_transliterations(args.corpus)
    results: dict[str, dict] = {}
    for name in names:
        adapter = build_adapter(name, train_transliterations=train)
        predictions = run_adapter(adapter, cases, args.images_dir)
        report = evaluate(cases, predictions, evaluation_version=args.version)

        adapter_dir = args.out_dir / name
        adapter_dir.mkdir(parents=True, exist_ok=True)
        (adapter_dir / "predictions.jsonl").write_text(
            "".join(json.dumps(p, ensure_ascii=False) + "\n" for p in predictions),
            encoding="utf-8")
        (adapter_dir / "report.json").write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        results[name] = {"report": report, "is_diagnostic": adapter.is_diagnostic}

    summary = summarize(results)
    args.out_dir.mkdir(parents=True, exist_ok=True)
    (args.out_dir / "summary.md").write_text(summary, encoding="utf-8")
    print(summary)
    return 0


if __name__ == "__main__":
    sys.exit(main())
