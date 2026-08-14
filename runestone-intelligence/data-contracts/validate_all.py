#!/usr/bin/env python3
"""Validerar alla exempel-/datafiler mot sina scheman + domaninvarianter.

Anvandning:
    python3 validate_all.py            # validerar examples/
    python3 validate_all.py <katalog>  # validerar alla *.json i katalogen

Filformat: {"$schema_name": "<schema>", "record": {...}} eller en lista av
sadana objekt. Exit code 1 vid forsta felet — anvands som CI-grind:
ingestion far inte producera objekt som inte validerar (ADR-0003).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from validator import validate_record


def main() -> int:
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "examples"
    files = sorted(target.glob("*.json"))
    if not files:
        print(f"Inga JSON-filer i {target}", file=sys.stderr)
        return 1

    failed = False
    for path in files:
        with path.open(encoding="utf-8") as fh:
            payload = json.load(fh)
        entries = payload if isinstance(payload, list) else [payload]
        for i, entry in enumerate(entries):
            schema_name = entry.get("$schema_name")
            record = entry.get("record")
            if not schema_name or record is None:
                print(f"FAIL {path.name}[{i}]: saknar $schema_name eller record")
                failed = True
                continue
            errors = validate_record(record, schema_name)
            if errors:
                failed = True
                print(f"FAIL {path.name}[{i}] ({schema_name}):")
                for err in errors:
                    print(f"  - {err}")
            else:
                print(f"OK   {path.name}[{i}] ({schema_name})")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
