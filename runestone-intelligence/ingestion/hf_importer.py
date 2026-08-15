"""Importer for det multimodala datasetet Scandinavian Runestone Inscriptions
(2 615 bild/text-par, Hugging Face).

Producerar image-rights-poster (Layer B/C). Datasetet ar CC BY-SA 4.0 pa
datasetniva men ingaende bilder har individuella licenser - darfor
licensklassas varje bild for sig, och en okand licens ger ALDRIG
training_allowed=true (enforceras aven av domaninvarianten i validatorn).

Datasetets inbyggda eval/few-shot-struktur importeras avsiktligt inte som
split - var split sker pa inskriftsniva i versioning.py (ADR-0002).
"""

from __future__ import annotations

from dataclasses import dataclass, field

from contracts import canonical_json, sha256_of, validated
from signum import SignumError, signum_slug

# Licens -> (rights_status, training_allowed, redistribution_allowed).
# Medvetet whitelist: allt som inte kanns igen blir unknown/false/false.
_LICENSE_POLICY = {
    "cc0": ("open", True, True),
    "public domain": ("open", True, True),
    "cc by 4.0": ("attribution_required", True, True),
    "cc by 3.0": ("attribution_required", True, True),
    "cc by-sa 4.0": ("share_alike", True, True),
    "cc by-sa 3.0": ("share_alike", True, True),
}


def classify_license(license_text: str | None) -> tuple[str, str, bool, bool]:
    """-> (normaliserad licenstext, rights_status, training_allowed, redistribution_allowed)"""
    text = (license_text or "").strip()
    policy = _LICENSE_POLICY.get(text.lower())
    if policy is None:
        return (text or "unknown", "unknown", False, False)
    status, train, redist = policy
    return (text, status, train, redist)


@dataclass
class ImageImportReport:
    imported: list[dict] = field(default_factory=list)
    rejected: list[dict] = field(default_factory=list)
    unclassified_licenses: list[str] = field(default_factory=list)  # image_id med unknown-licens
    pairings: list[dict] = field(default_factory=list)  # {image_id, signum} - kallans pastadda koppling, verifieras av matchern

    @property
    def counts(self) -> dict:
        return {
            "imported": len(self.imported),
            "rejected": len(self.rejected),
            "unclassified_licenses": len(self.unclassified_licenses),
        }


def import_hf_images(
    rows: list[dict],
    *,
    source_url: str,
    dataset_version: str,
    download_timestamp: str,
) -> ImageImportReport:
    report = ImageImportReport()
    seen: set[str] = set()

    for i, row in enumerate(rows):
        record_id = str(row.get("id", f"row-{i}"))
        image_id = f"img-hf-{record_id.lower()}"
        if image_id in seen:
            continue  # idempotent per kall-id

        license_text, rights_status, training, redistribution = classify_license(row.get("image_license"))

        # Signum ar onskvart men inte obligatoriskt har - okopplade bilder
        # matchas (eller hamnar i granskningsko) i matcher.py, gissas aldrig.
        signum_raw = row.get("signum")
        signum_note = None
        if signum_raw:
            try:
                signum_slug(signum_raw)
            except SignumError as exc:
                signum_raw = None
                signum_note = str(exc)

        record = {
            "image_id": image_id,
            "inscription_id": None,  # satts av matchern, aldrig av importern
            "original_url": row.get("image_url", ""),
            "local_object": f"raw/images/hf/{image_id}.jpg",
            "license": license_text,
            "photographer": row.get("photographer"),
            "source_institution": "Scandinavian Runestone Inscriptions (Hugging Face)",
            "resolution": {"width": int(row.get("width", 0) or 0), "height": int(row.get("height", 0) or 0)},
            "orientation": row.get("orientation", "unknown"),
            "rights_status": rights_status,
            "usage": {
                "training_allowed": training,
                "redistribution_allowed": redistribution,
                "verified_by": "license-policy-v1" if rights_status != "unknown" else None,
                "verified_at": download_timestamp if rights_status != "unknown" else None,
            },
            "layer": row.get("layer", "C"),
            "observation_id": None,
            "consent_ref": None,
            "provenance": {
                "dataset_id": "hf-runestones",
                "source": "Scandinavian Runestone Inscriptions",
                "source_url": source_url,
                "source_record_id": record_id,
                "license": "CC BY-SA 4.0 (dataset level); per-image licenses individual",
                "creator": row.get("photographer"),
                "attribution": "Scandinavian Runestone Inscriptions dataset (CC BY-SA 4.0); "
                               f"image: {row.get('photographer') or 'unknown photographer'}, {license_text}",
                "modification_status": "unmodified",
                "download_timestamp": download_timestamp,
                "dataset_version": dataset_version,
                "checksum": sha256_of(canonical_json(row)),
            },
        }

        valid, errors = validated(record, "image-rights")
        if valid is None:
            if signum_note:
                errors = errors + [f"signum: {signum_note}"]
            report.rejected.append({"source_record_id": record_id, "reasons": errors})
            continue

        seen.add(image_id)
        report.imported.append(valid)
        if rights_status == "unknown":
            report.unclassified_licenses.append(image_id)
        if signum_raw:
            report.pairings.append({"image_id": image_id, "signum": signum_raw})

    return report
