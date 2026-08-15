#!/usr/bin/env python3
"""Bygger RUNEBENCH-testfall fran en corpusversion (output av
ingestion/build_corpus.py).

Endast test- och unknown_stone_test-partitionerna anvands - traningsstenar
kan per konstruktion inte lacka in i benchmarken (ADR-0002). Ett testfall
kraver en matchad bild: benchmarken mater lasning av fotografier, inte
textkunskap.

Kategorisering sker med deterministiska regler dar det gar automatiskt:

    I  unknown stone     - stenen ligger i unknown_stone_test-partitionen
    C  low resolution    - minsta bilddimension < 1000 px
    J  long inscription  - translitterering >= 60 tecken
    A  clean (default)

Prioritet vid overlapp: I > C > J > A (ett fall har en kategori i schemat).
Ovriga kategorier (B falt, D vinkel, E skada, G kontrast, H vittring,
K sallsynta runformer, L icke-vikingatida) kraver bildannotering och satts
via annotation-verktyget, inte har.

Alla fall skapas med gold=false. Promotion till RUNEBENCH-GOLD sker
manuellt med verified_by - aldrig av detta skript (plan §26).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "data-contracts"))
from validator import validate_record  # noqa: E402

LOW_RESOLUTION_PX = 1000
ABSTENTION_RESOLUTION_PX = 400  # under detta ar ratt beteende att avsta
LONG_INSCRIPTION_CHARS = 60


def categorize(partition: str, image: dict, inscription: dict) -> str:
    if partition == "unknown_stone_test":
        return "I"
    res = image.get("resolution", {})
    if min(res.get("width", 0), res.get("height", 0)) < LOW_RESOLUTION_PX:
        return "C"
    if len(inscription.get("transliteration", "")) >= LONG_INSCRIPTION_CHARS:
        return "J"
    return "A"


def build_cases(
    inscriptions: list[dict],
    images: list[dict],
    split: dict[str, str],
    *,
    benchmark_version: str,
) -> tuple[list[dict], list[dict]]:
    """-> (cases, skipped). skipped: {image_id, reason} - rapporteras, tystas inte."""
    by_id = {ins["inscription_id"]: ins for ins in inscriptions}
    cases: list[dict] = []
    skipped: list[dict] = []

    for image in images:
        iid = image.get("inscription_id")
        if not iid:
            skipped.append({"image_id": image["image_id"], "reason": "omatchad bild"})
            continue
        partition = split.get(iid)
        if partition not in ("test", "unknown_stone_test"):
            skipped.append({"image_id": image["image_id"],
                            "reason": f"partition {partition}: inte testdata"})
            continue
        inscription = by_id.get(iid)
        if inscription is None:
            skipped.append({"image_id": image["image_id"],
                            "reason": f"{iid} saknas i corpus"})
            continue

        res = image.get("resolution", {})
        abstention_expected = min(res.get("width", 0), res.get("height", 0)) < ABSTENTION_RESOLUTION_PX

        case = {
            "case_id": f"rb-{image['image_id'].removeprefix('img-')}",
            "benchmark_version": benchmark_version,
            "category": categorize(partition, image, inscription),
            "inscription_id": None if partition == "unknown_stone_test" else iid,
            "signum": None if partition == "unknown_stone_test" else inscription["signum"],
            "image_id": image["image_id"],
            "expected": {
                "rune_sequence": inscription.get("runic_text"),
                "transliteration": inscription["transliteration"],
                "normalization": inscription.get("normalization"),
                "translation_sv": inscription.get("translation_sv"),
                "abstention_expected": abstention_expected,
            },
            "gold": False,
            "verified_by": None,
            "split": partition,
            "notes": None,
        }
        errors = validate_record(case, "benchmark-case")
        if errors:
            skipped.append({"image_id": image["image_id"], "reason": f"validering: {errors}"})
            continue
        cases.append(case)

    return cases, skipped


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--corpus", required=True, type=Path, help="katalog fran build_corpus.py")
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--version", required=True, help="t.ex. v1")
    args = ap.parse_args()

    def load_jsonl(p: Path) -> list[dict]:
        return [json.loads(line) for line in p.read_text(encoding="utf-8").splitlines() if line.strip()]

    inscriptions = load_jsonl(args.corpus / "inscriptions.jsonl")
    images = load_jsonl(args.corpus / "images.jsonl")
    split = json.loads((args.corpus / "split.json").read_text(encoding="utf-8"))

    cases, skipped = build_cases(inscriptions, images, split, benchmark_version=args.version)

    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / "cases.jsonl").write_text(
        "".join(json.dumps(c, ensure_ascii=False, sort_keys=True) + "\n" for c in cases),
        encoding="utf-8",
    )
    (args.out / "skipped.json").write_text(
        json.dumps(skipped, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    per_category: dict[str, int] = {}
    for c in cases:
        per_category[c["category"]] = per_category.get(c["category"], 0) + 1
    summary = {"version": args.version, "cases": len(cases),
               "skipped": len(skipped), "per_category": per_category}
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
