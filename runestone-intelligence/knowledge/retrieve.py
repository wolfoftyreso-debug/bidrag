#!/usr/bin/env python3
"""CLI: retrieval + verifiering mot en corpusversion (§17-19-flodet).

    python3 retrieve.py --corpus <corpus-dir> --text "iksimbil" \
        [--lat 59.85 --lon 17.63] [--rune-type younger_futhark] [--top-k 5]

    python3 retrieve.py --corpus <corpus-dir> --lat 59.85 --lon 17.63
    # enbart GPS: kandidatforslag, aldrig identifiering

Output: JSON med rankade kandidater (evidens per signal) och - nar en
lasning finns - verifieringsutlatandet mot basta kandidat.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

_HERE = Path(__file__).parent
sys.path.insert(0, str(_HERE))
sys.path.insert(0, str(_HERE.parent / "verification"))
sys.path.insert(0, str(_HERE.parent / "translation"))

from retrieval import CorpusIndex  # noqa: E402
from translate import translate  # noqa: E402
from verify import verify_against_candidates  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--corpus", required=True, type=Path)
    ap.add_argument("--text", default=None, help="predicerad translitterering")
    ap.add_argument("--lat", type=float, default=None)
    ap.add_argument("--lon", type=float, default=None)
    ap.add_argument("--rune-type", default=None)
    ap.add_argument("--region", default=None)
    ap.add_argument("--top-k", type=int, default=5)
    args = ap.parse_args()

    gps = (args.lat, args.lon) if args.lat is not None and args.lon is not None else None
    index = CorpusIndex.from_corpus_dir(args.corpus)
    candidates = [c.to_dict() for c in index.search(
        query_text=args.text, gps=gps,
        rune_type=args.rune_type, region=args.region, top_k=args.top_k)]

    result: dict = {"candidates": candidates}
    if args.text:
        verdict = verify_against_candidates(args.text, candidates)
        result["verdict"] = verdict
        result["translation"] = translate(args.text, verdict)

    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
