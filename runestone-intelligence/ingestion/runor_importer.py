"""Runor/K-samsok-importer (Riksantikvarieambetet) - STEG 5.

Berikar canonical-inskrifter med geografi och bildreferenser fran
RAA:s oppna data. Metadata ar CC0; bildrattigheter varierar per objekt
och antas ALDRIG fria (ADR-0003).

Berikningsregler (princip 8: originaldata muteras aldrig):

- Endast TOMMA falt fylls (coordinates, region, location, dating).
  Befintliga SRD-varden skrivs aldrig over.
- Varje fyllt falt loggas sparbart i `enrichments` med kalla + record-id.
- Konflikt (Runor-koordinat >200 m fran befintlig) -> granskningsko,
  aldrig tyst val av ena kallan.
- Bildreferenser blir image-rights-poster; okand licens ger
  training_allowed=false tills klassad.

Kallformat: JSONL-fixtur som speglar K-samsoks faltinnehall; adaptern till
det verkliga API-svaret (JSON-LD) skrivs vid skarp atkomst - kontraktsytan
ar densamma.
"""

from __future__ import annotations

import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parents[1] / "knowledge"))

from contracts import canonical_json, sha256_of, validated  # noqa: E402
from hf_importer import classify_license  # noqa: E402
from retrieval import haversine_km  # noqa: E402
from signum import SignumError, signum_key  # noqa: E402

SOURCE = "Runor / K-samsok (Riksantikvarieambetet)"
CONFLICT_DISTANCE_KM = 0.2

ENRICHABLE_FIELDS = ("coordinates", "region", "location", "dating")


@dataclass
class RunorReport:
    enriched: list[dict] = field(default_factory=list)      # nya inskriftsversioner
    untouched: list[str] = field(default_factory=list)      # inskrifter utan ny info
    images: list[dict] = field(default_factory=list)        # image-rights-poster
    pairings: list[dict] = field(default_factory=list)      # {image_id, signum}
    review_queue: list[dict] = field(default_factory=list)  # konflikter + okanda signum

    @property
    def counts(self) -> dict:
        return {"enriched": len(self.enriched), "untouched": len(self.untouched),
                "images": len(self.images), "review": len(self.review_queue)}


def _runor_value(row: dict, field_name: str):
    if field_name == "coordinates":
        if row.get("latitude") is None or row.get("longitude") is None:
            return None
        return {"latitude": row["latitude"], "longitude": row["longitude"]}
    return row.get(field_name)


def enrich_with_runor(
    inscriptions: list[dict],
    runor_rows: list[dict],
    *,
    source_url: str,
    dataset_version: str,
    download_timestamp: str,
) -> RunorReport:
    report = RunorReport()
    by_key: dict[str, dict] = {}
    for ins in inscriptions:
        try:
            by_key[signum_key(ins["signum"])] = ins
        except SignumError:
            continue

    enriched_ids: set[str] = set()

    for i, row in enumerate(runor_rows):
        record_id = str(row.get("raa_id", f"row-{i}"))
        signum_raw = row.get("signum")
        if not signum_raw:
            report.review_queue.append({"source_record_id": record_id,
                                        "reason": "Runor-post utan signum"})
            continue
        try:
            key = signum_key(signum_raw)
        except SignumError as exc:
            report.review_queue.append({"source_record_id": record_id, "reason": str(exc)})
            continue

        inscription = by_key.get(key)
        if inscription is None:
            report.review_queue.append({
                "source_record_id": record_id, "signum": signum_raw,
                "reason": f"signum {key} finns inte i corpus - mojlig lucka i SRD-importen"})
            continue

        # Koordinatkonflikt: bada kallorna har varden som pekar olika.
        existing = inscription.get("coordinates")
        proposed = _runor_value(row, "coordinates")
        conflict = False
        if existing and proposed:
            distance = haversine_km(existing["latitude"], existing["longitude"],
                                    proposed["latitude"], proposed["longitude"])
            if distance > CONFLICT_DISTANCE_KM:
                conflict = True
                report.review_queue.append({
                    "source_record_id": record_id, "signum": signum_raw,
                    "reason": f"koordinatkonflikt: {distance:.2f} km mellan SRD och Runor "
                              "- till granskning, ingen kalla valjs tyst"})

        filled = [f for f in ENRICHABLE_FIELDS
                  if not inscription.get(f) and _runor_value(row, f) is not None
                  and not (f == "coordinates" and conflict)]

        # Bildreferenser -> egna rights records (licens per objekt).
        for j, image_ref in enumerate(row.get("images", [])):
            image_id = f"img-runor-{record_id.lower()}-{j}"
            license_text, rights_status, training, redistribution = classify_license(
                image_ref.get("license"))
            image_record = {
                "image_id": image_id,
                "inscription_id": None,  # satts av matchern
                "original_url": image_ref.get("url", ""),
                "local_object": f"raw/images/runor/{image_id}.jpg",
                "license": license_text,
                "photographer": image_ref.get("photographer"),
                "source_institution": image_ref.get("institution") or SOURCE,
                "resolution": {"width": int(image_ref.get("width", 0) or 0),
                               "height": int(image_ref.get("height", 0) or 0)},
                "orientation": image_ref.get("orientation", "unknown"),
                "rights_status": rights_status,
                "usage": {"training_allowed": training,
                          "redistribution_allowed": redistribution,
                          "verified_by": "license-policy-v1" if rights_status != "unknown" else None,
                          "verified_at": download_timestamp if rights_status != "unknown" else None},
                "layer": "B",
                "observation_id": None,
                "consent_ref": None,
                "provenance": {
                    "dataset_id": "runor-import",
                    "source": SOURCE,
                    "source_url": source_url,
                    "source_record_id": f"{record_id}/image/{j}",
                    "license": "CC0 (metadata); image rights per object",
                    "creator": image_ref.get("photographer"),
                    "attribution": f"{image_ref.get('institution') or SOURCE}; "
                                   f"foto: {image_ref.get('photographer') or 'okand'}, {license_text}",
                    "modification_status": "unmodified",
                    "download_timestamp": download_timestamp,
                    "dataset_version": dataset_version,
                    "checksum": sha256_of(canonical_json(image_ref)),
                },
            }
            valid, errors = validated(image_record, "image-rights")
            if valid is None:
                report.review_queue.append({"source_record_id": f"{record_id}/image/{j}",
                                            "reason": f"validering: {errors}"})
                continue
            report.images.append(valid)
            report.pairings.append({"image_id": image_id, "signum": signum_raw})

        if not filled:
            report.untouched.append(inscription["inscription_id"])
            continue

        updated = dict(inscription)
        for f in filled:
            updated[f] = _runor_value(row, f)
        updated["provenance"] = dict(inscription["provenance"], modification_status="enriched")
        updated["enrichments"] = list(inscription.get("enrichments", [])) + [{
            "source": SOURCE, "source_record_id": record_id,
            "license": "CC0 (metadata)", "fields": filled,
        }]

        valid, errors = validated(updated, "inscription")
        if valid is None:
            report.review_queue.append({"source_record_id": record_id,
                                        "reason": f"validering: {errors}"})
            continue
        report.enriched.append(valid)
        enriched_ids.add(valid["inscription_id"])

    return report


def apply_enrichment(inscriptions: list[dict], report: RunorReport) -> list[dict]:
    """Ny inskriftslista dar berikade versioner ersatter originalen
    (originalen finns kvar oforandrade i foregaende datasetversion)."""
    by_id = {rec["inscription_id"]: rec for rec in report.enriched}
    return [by_id.get(ins["inscription_id"], ins) for ins in inscriptions]
