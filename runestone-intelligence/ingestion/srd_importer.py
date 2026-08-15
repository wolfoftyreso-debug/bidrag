"""Importer for Scandinavian Runic-text Database (Uppsala universitet).

Laser en radbaserad JSONL-export och producerar canonical
inscription-poster for Runestone Intelligence Corpus.

Viktigt om kallformatet: den verkliga SRD/Rundata-distributionen har ett
eget filformat; adaptern till det skrivs nar dataatkomsten ar pa plats och
anvandningen ar rapporterad till Uppsala (se docs/LICENSES.md). Detta
importsteg definierar den stabila interna kontraktsytan: allt som kommer in
- oavsett kallformat - gar genom samma validering, provenance och
idempotensregler. Fixturer i fixtures/ visar radformatet.

Regler:
- source_database/source_provider satts alltid (ADR-0004).
- Idempotent per signum: samma rad tva ganger ger en post; motstridiga
  dubbletter avvisas till granskningskon i stallet for att skrivas over.
- Avvisade rader rapporteras med orsak - de ar datainventering.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from contracts import canonical_json, sha256_of, validated
from signum import SignumError, signum_key, signum_slug

SOURCE_DATABASE = "Scandinavian Runic-text Database"
SOURCE_PROVIDER = "Uppsala University"

_RUNE_TYPE_MAP = {
    "elder": "elder_futhark",
    "younger": "younger_futhark",
    "short-twig": "short_twig",
    "staveless": "staveless",
    "medieval": "medieval",
    "anglo-saxon": "anglo_saxon",
    "mixed": "mixed",
}


@dataclass
class ImportReport:
    imported: list[dict] = field(default_factory=list)
    rejected: list[dict] = field(default_factory=list)  # {source_record_id, reasons}
    duplicates: list[str] = field(default_factory=list)

    @property
    def counts(self) -> dict:
        return {
            "imported": len(self.imported),
            "rejected": len(self.rejected),
            "duplicates": len(self.duplicates),
        }


def _to_inscription(row: dict, *, source_url: str, dataset_version: str, download_timestamp: str) -> dict:
    signum_raw = row["signum"]
    key_slug = signum_slug(signum_raw)
    coords = None
    if row.get("latitude") is not None and row.get("longitude") is not None:
        coords = {"latitude": row["latitude"], "longitude": row["longitude"]}
    rune_type = _RUNE_TYPE_MAP.get(str(row.get("rune_type", "")).lower(), "unknown")
    return {
        "inscription_id": f"ric-{key_slug}",
        "signum": signum_raw.strip().replace("†", "").strip(),
        "source_database": SOURCE_DATABASE,
        "source_provider": SOURCE_PROVIDER,
        "region": row.get("region"),
        "country": row.get("country") or "Sweden",
        "location": row.get("location"),
        "coordinates": coords,
        "dating": row.get("dating"),
        "rune_type": rune_type,
        "runic_text": row.get("runic_text"),
        "transliteration": row.get("transliteration", ""),
        "normalization": row.get("normalization"),
        "translation_sv": row.get("translation_sv"),
        "translation_en": row.get("translation_en"),
        "alternative_readings": row.get("alternative_readings", []),
        "uncertain_characters": row.get("uncertain_characters", []),
        "carver": row.get("carver"),
        "style": row.get("style"),
        "bibliography": row.get("bibliography", []),
        "scholarly_status": row.get("scholarly_status", "established"),
        "provenance": {
            "dataset_id": "srd-import",
            "source": SOURCE_DATABASE,
            "source_url": source_url,
            "source_record_id": signum_raw.strip(),
            "license": "Use permitted with reporting and attribution (Uppsala University terms)",
            "creator": SOURCE_PROVIDER,
            "attribution": f"{SOURCE_DATABASE}, {SOURCE_PROVIDER}",
            "modification_status": "normalized",
            "download_timestamp": download_timestamp,
            "dataset_version": dataset_version,
            "checksum": sha256_of(canonical_json(row)),
        },
    }


def import_srd(
    rows: list[dict],
    *,
    source_url: str,
    dataset_version: str,
    download_timestamp: str,
) -> ImportReport:
    report = ImportReport()
    seen: dict[str, str] = {}  # signum key -> checksum av raden

    for i, row in enumerate(rows):
        record_id = str(row.get("signum", f"row-{i}"))
        try:
            key = signum_key(row["signum"])
        except (KeyError, SignumError) as exc:
            report.rejected.append({"source_record_id": record_id, "reasons": [str(exc)]})
            continue

        row_checksum = sha256_of(canonical_json(row))
        if key in seen:
            if seen[key] == row_checksum:
                report.duplicates.append(record_id)  # identisk rad: idempotent no-op
            else:
                report.rejected.append({
                    "source_record_id": record_id,
                    "reasons": [f"motstridig dubblett av {key} - till granskningsko, skriver aldrig over"],
                })
            continue

        record = _to_inscription(
            row,
            source_url=source_url,
            dataset_version=dataset_version,
            download_timestamp=download_timestamp,
        )
        valid, errors = validated(record, "inscription")
        if valid is None:
            report.rejected.append({"source_record_id": record_id, "reasons": errors})
            continue
        seen[key] = row_checksum
        report.imported.append(valid)

    return report
