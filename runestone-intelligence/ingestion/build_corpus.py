#!/usr/bin/env python3
"""Bygger en corpusversion end-to-end (STEG 4-7):

    SRD-export -> canonical inskrifter
    HF-bilddata -> image-rights med licensklassning
    matcher     -> signum <-> inscription <-> image
    split       -> sten-niva train/val/test + unknown_stone_test
    manifest    -> immutable datasetversion

Anvandning:
    python3 build_corpus.py --srd fixtures/srd_sample.jsonl \
        --images fixtures/hf_sample.jsonl \
        --out /tmp/corpus-v0.1 --version v0.1 \
        --timestamp 2026-08-15T00:00:00Z --seed 20260815

Kor mot fixturer tills verklig dataatkomst ar licensklar (docs/LICENSES.md).
Timestamp ges explicit - inga wall-clock-anrop i pipelinen, sa samma input
ger alltid bit-identisk output.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from contracts import read_jsonl, write_jsonl  # noqa: E402
from hf_importer import import_hf_images  # noqa: E402
from matcher import match_images  # noqa: E402
from runor_importer import apply_enrichment, enrich_with_runor  # noqa: E402
from srd_importer import import_srd  # noqa: E402
from versioning import build_manifest, stone_level_split  # noqa: E402


def build(
    *,
    srd_path: Path,
    images_path: Path,
    out_dir: Path,
    version: str,
    timestamp: str,
    seed: int,
    runor_path: Path | None = None,
    srd_url: str = "https://www.nordiska.uu.se/forskning/samnord/",
    images_url: str = "https://huggingface.co/datasets/scandinavian-runestone-inscriptions",
    runor_url: str = "https://app.raa.se/open/runor/search",
) -> dict:
    srd_report = import_srd(
        read_jsonl(srd_path), source_url=srd_url,
        dataset_version=version, download_timestamp=timestamp,
    )
    img_report = import_hf_images(
        read_jsonl(images_path), source_url=images_url,
        dataset_version=version, download_timestamp=timestamp,
    )

    inscriptions = srd_report.imported
    all_images = list(img_report.imported)
    all_pairings = list(img_report.pairings)
    runor_report = None
    if runor_path is not None:
        runor_report = enrich_with_runor(
            inscriptions, read_jsonl(runor_path), source_url=runor_url,
            dataset_version=version, download_timestamp=timestamp,
        )
        inscriptions = apply_enrichment(inscriptions, runor_report)
        all_images += runor_report.images
        all_pairings += runor_report.pairings

    match_report = match_images(inscriptions, all_images, all_pairings)

    split = stone_level_split(
        [ins["inscription_id"] for ins in inscriptions], seed=seed,
    )

    matched_ids = {img["image_id"] for img in match_report.matched}
    images = match_report.matched + [
        img for img in all_images if img["image_id"] not in matched_ids
    ]

    out_dir.mkdir(parents=True, exist_ok=True)
    write_jsonl(out_dir / "inscriptions.jsonl", inscriptions)
    write_jsonl(out_dir / "images.jsonl", images)

    manifest = build_manifest(
        dataset_name="runestone-corpus",
        dataset_version=version,
        layer="mixed",
        records=inscriptions + images,
        source_datasets=[
            {"source": "Scandinavian Runic-text Database", "source_url": srd_url,
             "license": "Use permitted with reporting and attribution (Uppsala University terms)"},
            {"source": "Scandinavian Runestone Inscriptions", "source_url": images_url,
             "license": "CC BY-SA 4.0 (dataset level); per-image licenses individual"},
        ],
        created_at=timestamp,
        seed=seed,
    )
    (out_dir / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    (out_dir / "split.json").write_text(
        json.dumps(split, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )

    review_queue = {
        "srd_rejected": srd_report.rejected,
        "images_rejected": img_report.rejected,
        "images_unmatched": match_report.unmatched,
        "images_ambiguous": match_report.ambiguous,
        "unclassified_licenses": img_report.unclassified_licenses,
        "runor_review": runor_report.review_queue if runor_report else [],
    }
    (out_dir / "review_queue.json").write_text(
        json.dumps(review_queue, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    summary = {
        "version": version,
        "inscriptions": srd_report.counts,
        "images": img_report.counts,
        "runor": runor_report.counts if runor_report else None,
        "matching": match_report.counts,
        "split": {p: sum(1 for v in split.values() if v == p)
                  for p in ("train", "val", "test", "unknown_stone_test")},
        "manifest_checksum": manifest["checksum"],
    }
    (out_dir / "report.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    return summary


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--srd", required=True, type=Path)
    ap.add_argument("--images", required=True, type=Path)
    ap.add_argument("--runor", type=Path, default=None,
                    help="Runor/K-samsok-export for berikning (valfri)")
    ap.add_argument("--out", required=True, type=Path)
    ap.add_argument("--version", required=True)
    ap.add_argument("--timestamp", required=True, help="ISO 8601, t.ex. 2026-08-15T00:00:00Z")
    ap.add_argument("--seed", required=True, type=int)
    args = ap.parse_args()

    summary = build(
        srd_path=args.srd, images_path=args.images, out_dir=args.out,
        version=args.version, timestamp=args.timestamp, seed=args.seed,
        runor_path=args.runor,
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
