"""Brygga till data contracts: varje importer validerar innan den skriver.

En importer far aldrig producera ett objekt som inte validerar (ADR-0003).
Avvisade poster ar data - de loggas med orsak och blir del av
importrapporten, inte tysta bortfall.
"""

from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

_CONTRACTS_DIR = Path(__file__).parents[1] / "data-contracts"
if str(_CONTRACTS_DIR) not in sys.path:
    sys.path.insert(0, str(_CONTRACTS_DIR))

from validator import validate_record  # noqa: E402


def sha256_of(data: bytes | str) -> str:
    if isinstance(data, str):
        data = data.encode("utf-8")
    return "sha256:" + hashlib.sha256(data).hexdigest()


def canonical_json(obj) -> str:
    """Deterministisk serialisering - grund for checksummor och idempotens."""
    return json.dumps(obj, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def validated(record: dict, schema_name: str) -> tuple[dict | None, list[str]]:
    errors = validate_record(record, schema_name)
    return (record, []) if not errors else (None, errors)


def write_jsonl(path: Path, records: list[dict]) -> str:
    """Skriver records som JSONL och returnerar filens checksumma."""
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = "\n".join(canonical_json(r) for r in records) + ("\n" if records else "")
    path.write_text(payload, encoding="utf-8")
    return sha256_of(payload)


def read_jsonl(path: Path) -> list[dict]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
