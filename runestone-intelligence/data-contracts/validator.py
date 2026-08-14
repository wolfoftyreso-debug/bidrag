"""Minimal, beroendefri validering av data contracts.

Implementerar den delmangd av JSON Schema som schemana i schemas/ anvander:
type, properties, required, additionalProperties, enum, const, pattern,
minimum, maximum, minLength, minItems, items — samt "$contract", en enkel
korsreferens till ett annat schema i samma katalog (t.ex. provenance).

Stdlib-only avsiktligt: valideringen ska kunna kora i varje ingestion-worker
och i CI utan installationssteg (princip 3: alla data har provenance).
"""

from __future__ import annotations

import json
import re
from pathlib import Path

SCHEMA_DIR = Path(__file__).parent / "schemas"

_TYPE_MAP = {
    "object": dict,
    "array": list,
    "string": str,
    "integer": int,
    "number": (int, float),
    "boolean": bool,
    "null": type(None),
}


def load_schema(name: str) -> dict:
    path = SCHEMA_DIR / f"{name}.schema.json"
    with path.open(encoding="utf-8") as fh:
        return json.load(fh)


def _type_ok(value, expected) -> bool:
    types = expected if isinstance(expected, list) else [expected]
    for t in types:
        py = _TYPE_MAP[t]
        if t == "integer":
            if isinstance(value, int) and not isinstance(value, bool):
                return True
        elif t == "number":
            if isinstance(value, (int, float)) and not isinstance(value, bool):
                return True
        elif t == "boolean":
            if isinstance(value, bool):
                return True
        elif isinstance(value, py):
            return True
    return False


def validate(value, schema: dict, path: str = "$") -> list[str]:
    """Returnerar en lista av felstrangar; tom lista = giltig."""
    errors: list[str] = []

    contract = schema.get("$contract")
    if contract:
        return validate(value, load_schema(contract), path)

    expected_type = schema.get("type")
    if expected_type is not None and not _type_ok(value, expected_type):
        return [f"{path}: expected type {expected_type}, got {type(value).__name__}"]

    if "const" in schema and value != schema["const"]:
        errors.append(f"{path}: expected const {schema['const']!r}, got {value!r}")

    if "enum" in schema and value not in schema["enum"]:
        errors.append(f"{path}: {value!r} not in enum {schema['enum']}")

    if isinstance(value, str):
        pattern = schema.get("pattern")
        if pattern and not re.search(pattern, value):
            errors.append(f"{path}: {value!r} does not match pattern {pattern!r}")
        min_len = schema.get("minLength")
        if min_len is not None and len(value) < min_len:
            errors.append(f"{path}: shorter than minLength {min_len}")

    if isinstance(value, (int, float)) and not isinstance(value, bool):
        if "minimum" in schema and value < schema["minimum"]:
            errors.append(f"{path}: {value} < minimum {schema['minimum']}")
        if "maximum" in schema and value > schema["maximum"]:
            errors.append(f"{path}: {value} > maximum {schema['maximum']}")

    if isinstance(value, list):
        min_items = schema.get("minItems")
        if min_items is not None and len(value) < min_items:
            errors.append(f"{path}: fewer than minItems {min_items}")
        item_schema = schema.get("items")
        if item_schema:
            for i, item in enumerate(value):
                errors.extend(validate(item, item_schema, f"{path}[{i}]"))

    if isinstance(value, dict):
        props = schema.get("properties", {})
        for req in schema.get("required", []):
            if req not in value:
                errors.append(f"{path}: missing required property {req!r}")
        if schema.get("additionalProperties") is False:
            for key in value:
                if key not in props:
                    errors.append(f"{path}: unexpected property {key!r}")
        for key, sub in props.items():
            if key in value:
                errors.extend(validate(value[key], sub, f"{path}.{key}"))

    return errors


def domain_invariants(record: dict, schema_name: str) -> list[str]:
    """Regler som JSON Schema-delmangden inte uttrycker (se resp. schema-description)."""
    errors: list[str] = []
    if schema_name == "image-rights":
        if record.get("rights_status") == "unknown" and record.get("usage", {}).get("training_allowed"):
            errors.append("rights_status 'unknown' kraver usage.training_allowed=false tills licensen ar klassad")
        if (
            record.get("layer") == "F"
            and record.get("usage", {}).get("training_allowed")
            and not record.get("consent_ref")
        ):
            errors.append("Layer F-bild med training_allowed=true kraver consent_ref (uttryckligt anvandarsamtycke)")
    if schema_name == "model-registry-entry":
        if record.get("status") in ("BENCHMARKED", "STAGING", "PRODUCTION") and not record.get("benchmark_results"):
            errors.append(f"status {record.get('status')} kraver benchmark_results (princip 5: ingen production-modell utan benchmark)")
    if schema_name == "field-observation":
        if record.get("verification_status") != "unverified" and not record.get("verified_by"):
            errors.append("verifierad status kraver verified_by (verifieringstrappan ar sparbar)")
        match = record.get("match", {})
        if match.get("status") == "matched":
            evidence = match.get("evidence", [])
            if not [e for e in evidence if e != "gps_proximity"]:
                errors.append("match=matched kraver minst en icke-GPS-evidens (GPS ar signal, inte facit)")
            if not match.get("matched_stone_id"):
                errors.append("match=matched kraver matched_stone_id")
    if schema_name == "stone":
        if record.get("atlas_status") == "registered_known" and not record.get("official_signum"):
            errors.append("registered_known kraver official_signum")
        if record.get("atlas_status") == "merged" and not record.get("merged_into"):
            errors.append("atlas_status=merged kraver merged_into")
    if schema_name == "benchmark-case":
        if record.get("inscription_id") is None and record.get("category") != "I":
            errors.append("inscription_id far bara vara null for kategori I (unknown stone)")
        if record.get("gold") and not record.get("verified_by"):
            errors.append("gold-fall kraver verified_by (RUNEBENCH-GOLD ar manuellt kvalitetssakrad)")
    return errors


def validate_record(record: dict, schema_name: str) -> list[str]:
    return validate(record, load_schema(schema_name)) + domain_invariants(record, schema_name)
