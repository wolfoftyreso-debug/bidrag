"""Wikimedia Commons-skordare - sista importern i Sprint 1-2-scopet.

Per-fil licensklassning ar obligatorisk: Commons blandar CC0/CC BY/
CC BY-SA/PD med filer som inte alls far ateranvandas kommersiellt.
Samma whitelist-policy som ovriga importers (okand licens =>
training_allowed=false, redistribution_allowed=false) plus
fotografattribution enligt CC-kraven.

Kallformat: JSONL-fixtur som speglar Commons imageinfo/extmetadata-falten;
den skarpa API-adaptern (commons.wikimedia.org/w/api.php) skrivs vid
atkomst - kontraktsytan ar identisk. Signum plockas fran strukturerade
falt/kategorier nar det finns; kopplingen VERIFIERAS alltid av matchern.
"""

from __future__ import annotations

import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from contracts import canonical_json, sha256_of, validated  # noqa: E402
from hf_importer import classify_license  # noqa: E402
from signum import SignumError, signum_key  # noqa: E402

SOURCE = "Wikimedia Commons"

# Public domain-varianter som Commons anvander.
_PD_LICENSES = {"pd", "public domain", "pd-self", "pd-old", "cc0"}


def classify_commons_license(license_text: str | None) -> tuple[str, str, bool, bool]:
    text = (license_text or "").strip()
    if text.lower() in _PD_LICENSES:
        return (text or "unknown", "open", True, True)
    return classify_license(text)


@dataclass
class WikimediaReport:
    imported: list[dict] = field(default_factory=list)
    pairings: list[dict] = field(default_factory=list)
    rejected: list[dict] = field(default_factory=list)
    unclassified: list[str] = field(default_factory=list)

    @property
    def counts(self) -> dict:
        return {"imported": len(self.imported), "pairings": len(self.pairings),
                "rejected": len(self.rejected), "unclassified": len(self.unclassified)}


def harvest_wikimedia(
    rows: list[dict],
    *,
    dataset_version: str,
    download_timestamp: str,
) -> WikimediaReport:
    report = WikimediaReport()
    seen: set[str] = set()

    for i, row in enumerate(rows):
        file_name = str(row.get("file", f"row-{i}"))
        slug = "".join(c if c.isalnum() else "-" for c in file_name.lower()).strip("-")
        image_id = f"img-wm-{slug[:60]}"
        if image_id in seen:
            continue

        license_text, rights_status, training, redistribution = classify_commons_license(
            row.get("license"))
        artist = row.get("artist")

        record = {
            "image_id": image_id,
            "inscription_id": None,  # matchern verifierar - aldrig importern
            "original_url": row.get("url", ""),
            "local_object": f"raw/images/wikimedia/{image_id}.jpg",
            "license": license_text,
            "photographer": artist,
            "source_institution": SOURCE,
            "resolution": {"width": int(row.get("width", 0) or 0),
                           "height": int(row.get("height", 0) or 0)},
            "orientation": row.get("orientation", "unknown"),
            "rights_status": rights_status,
            "usage": {"training_allowed": training,
                      "redistribution_allowed": redistribution,
                      "verified_by": "license-policy-v1" if rights_status != "unknown" else None,
                      "verified_at": download_timestamp if rights_status != "unknown" else None},
            "layer": "C",
            "observation_id": None,
            "consent_ref": None,
            "provenance": {
                "dataset_id": "wikimedia-harvest",
                "source": SOURCE,
                "source_url": row.get("url", ""),
                "source_record_id": file_name,
                "license": license_text or "unknown",
                "creator": artist,
                "attribution": f"{artist or 'okand'}, {license_text}, via Wikimedia Commons",
                "modification_status": "unmodified",
                "download_timestamp": download_timestamp,
                "dataset_version": dataset_version,
                "checksum": sha256_of(canonical_json(row)),
            },
        }
        valid, errors = validated(record, "image-rights")
        if valid is None:
            report.rejected.append({"source_record_id": file_name, "reasons": errors})
            continue

        seen.add(image_id)
        report.imported.append(valid)
        if rights_status == "unknown":
            report.unclassified.append(image_id)

        signum_raw = row.get("signum")
        if signum_raw:
            try:
                signum_key(signum_raw)
                report.pairings.append({"image_id": image_id, "signum": signum_raw})
            except SignumError:
                report.rejected.append({"source_record_id": file_name,
                                        "reasons": [f"otolkbart signum {signum_raw!r} - bilden importerad utan koppling"]})

    return report
