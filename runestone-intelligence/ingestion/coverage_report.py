#!/usr/bin/env python3
"""Coverage-/gaprapport over en corpusversion - besvarar de sex strategiska
datafragorna (ADR-0009) maskinellt:

  1. Hur manga identifierbara runinskrifter har vi?
  2. Vilka bilder kan vi lagligen anvanda (traningsklassade)?
  3. Vilka koordinater har vi?
  4. Vilka etablerade translittereringar/oversattningar finns?
  5. Hur manga objekt kan fa hogkvalitativ bildmatchning (>=1 kopplad bild)?
  6. Var har datan luckor?

Anvandning:
    python3 coverage_report.py --corpus <corpus-dir> [--out rapport.json]

Rapporten ar styrdokumentet for datainsamlingen: luckorna ar nasta
insamlingsuppgift, inte nagot som doljs.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from contracts import read_jsonl  # noqa: E402


def build_report(corpus_dir: Path) -> dict:
    inscriptions = read_jsonl(corpus_dir / "inscriptions.jsonl")
    images = read_jsonl(corpus_dir / "images.jsonl")
    total = len(inscriptions)

    def count(predicate) -> int:
        return sum(1 for i in inscriptions if predicate(i))

    images_by_inscription: dict[str, int] = {}
    for img in images:
        iid = img.get("inscription_id")
        if iid:
            images_by_inscription[iid] = images_by_inscription.get(iid, 0) + 1

    trainable_images = [i for i in images if i.get("usage", {}).get("training_allowed")]
    unknown_license = [i["image_id"] for i in images if i.get("rights_status") == "unknown"]

    gaps = {
        "without_images": sorted(i["inscription_id"] for i in inscriptions
                                 if i["inscription_id"] not in images_by_inscription),
        "without_coordinates": sorted(i["inscription_id"] for i in inscriptions
                                      if not i.get("coordinates")),
        "without_translation_sv": sorted(i["inscription_id"] for i in inscriptions
                                         if not i.get("translation_sv")),
        "without_normalization": sorted(i["inscription_id"] for i in inscriptions
                                        if not i.get("normalization")),
        "images_with_unknown_license": sorted(unknown_license),
        "unmatched_images": sorted(i["image_id"] for i in images
                                   if not i.get("inscription_id")),
    }

    def pct(n: int) -> float:
        return round(100.0 * n / total, 1) if total else 0.0

    identifiable = sum(1 for iid in images_by_inscription
                       if any(i["inscription_id"] == iid and i.get("coordinates")
                              for i in inscriptions))

    return {
        "q1_inscriptions_total": total,
        "q2_images": {
            "total": len(images),
            "training_allowed": len(trainable_images),
            "unknown_license": len(unknown_license),
        },
        "q3_coordinates": {"count": count(lambda i: i.get("coordinates")),
                           "pct": pct(count(lambda i: i.get("coordinates")))},
        "q4_established_text": {
            "transliteration": {"count": total, "pct": pct(total)},
            "normalization": {"count": count(lambda i: i.get("normalization")),
                              "pct": pct(count(lambda i: i.get("normalization")))},
            "translation_sv": {"count": count(lambda i: i.get("translation_sv")),
                               "pct": pct(count(lambda i: i.get("translation_sv")))},
            "translation_en": {"count": count(lambda i: i.get("translation_en")),
                               "pct": pct(count(lambda i: i.get("translation_en")))},
        },
        "q5_image_matchable": {
            "inscriptions_with_images": len(images_by_inscription),
            "pct": pct(len(images_by_inscription)),
            "with_images_and_coordinates": identifiable,
        },
        "q6_gaps": gaps,
        "gap_counts": {k: len(v) for k, v in gaps.items()},
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--corpus", required=True, type=Path)
    ap.add_argument("--out", type=Path, default=None)
    args = ap.parse_args()

    report = build_report(args.corpus)
    text = json.dumps(report, ensure_ascii=False, indent=2)
    if args.out:
        args.out.write_text(text + "\n", encoding="utf-8")
    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
