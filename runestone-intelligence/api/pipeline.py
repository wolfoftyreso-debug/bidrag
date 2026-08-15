"""Orkestreringen bakom POST /v1/analyze (plan §34, arkitekturen §50).

    image -> reader -> runic sequence -> retrieval -> verification
          -> translation -> confidence per steg -> resultat

Regler som enforceas har:

- Abstention ar ett forstaklassutfall: olasbar bild eller saknad modell ger
  ett 422-svar med orsak och rekommendation - aldrig en gissning.
- Sammanlagd confidence ar MINIMUM av de berakningsbara stegen: ett
  aggregat far aldrig maskera en svag delkomponent (plan §20).
- Steg som inte kan matas i v0.1 (image quality, detection) rapporteras
  som null - inte som pahittade varden.
- Med samtycke skrivs varje analys som en faltobservation till Atlas
  (ADR-0006); verifieringsstatusen foljer verifieringsutfallet och
  GPS-regeln arvs fran retrieval (ADR-0007).
"""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

_ROOT = Path(__file__).parents[1]
for sub in ("knowledge", "verification", "translation", "data-contracts"):
    sys.path.insert(0, str(_ROOT / sub))

from retrieval import CorpusIndex  # noqa: E402
from translate import translate  # noqa: E402
from validator import validate_record  # noqa: E402
from verify import verify_against_candidates  # noqa: E402

MODEL_VERSION = "runestone-pipeline-0.1"

ABSTENTION_RECOMMENDATIONS = {
    "insufficient_image_quality": "Flytta kameran narmare och undvik motljus.",
    "no_inscription_detected": "Fa med hela inskriften i bild.",
    "unreadable_inscription": "Forsok fran en annan vinkel eller med battre ljus.",
}


def _overall_confidence(stages: dict) -> float | None:
    values = [v for v in stages.values() if isinstance(v, (int, float))]
    return round(min(values), 4) if values else None


class AnalyzePipeline:
    def __init__(self, index: CorpusIndex, reader):
        self.index = index
        self.reader = reader

    def analyze(self, image_bytes: bytes | None, *,
                gps: tuple[float, float] | None = None,
                consent: dict | None = None,
                inference_timestamp: str = "1970-01-01T00:00:00Z") -> dict:
        """-> {"status": 200|422, "body": {...}, "observation": dict|None}"""
        if not image_bytes:
            return {"status": 400, "body": {"error": "image saknas"}, "observation": None}

        reading = self.reader.read(image_bytes)
        if reading["abstained"] or not reading.get("transliteration"):
            reason = ("insufficient_image_quality"
                      if "bild" in (reading.get("note") or "") else "unreadable_inscription")
            return {
                "status": 422,
                "body": {"reason": reason,
                         "recommendation": ABSTENTION_RECOMMENDATIONS[reason],
                         "image_quality": None,
                         "note": reading.get("note")},
                "observation": None,
            }

        text = reading["transliteration"]
        candidates = [c.to_dict() for c in self.index.search(query_text=text, gps=gps, top_k=5)]
        verdict = verify_against_candidates(text, candidates)
        translation = translate(text, verdict)

        # Identifiering presenteras ENDAST nar verifieringen bekraftat den:
        # en LOW-match (mismatch) ar en kandidat under utredning, inte en
        # identifierad sten (plan §19).
        identification = verdict.get("identification") if verdict.get("status") == "verified" else None
        stage_confidence = {
            "image_quality": None,          # matbar forst med Image Quality Model
            "stone_identification": identification["identification_score"] if identification else None,
            "inscription_detection": None,  # matbar forst med detektorn
            "rune_recognition": reading["confidence"],
            "transliteration": reading["confidence"],
            "normalization": translation.get("coverage"),
            "historical_retrieval": candidates[0]["score"] if candidates else None,
            "translation": (0.95 if translation.get("method") == "canonical"
                            else translation.get("coverage") if translation.get("method") == "formulaic"
                            else None),
        }

        sources = []
        if identification and verdict.get("source"):
            src = verdict["source"]
            sources.append({
                "source_database": src.get("source_database"),
                "inscription": identification.get("signum"),
                "source_record": identification.get("inscription_id"),
                "translation_source": src.get("source_database")
                if translation.get("method") == "canonical" else None,
                "image_source": None,
            })

        body = {
            "result": {
                "stone_id": identification.get("signum") if identification else None,
                "identification_confidence": identification.get("identification_score")
                if identification else None,
                "transliteration": text,
                "translation_sv": translation.get("translation_sv"),
                "confidence": _overall_confidence(stage_confidence),
                "scholarly_status": translation.get("scholarly_status"),
            },
            "stage_confidence": stage_confidence,
            "uncertainties": reading.get("uncertainties", []),
            "verification": verdict.get("verification"),
            "sources": sources,
            "model": {"model_version": MODEL_VERSION,
                      "inference_timestamp": inference_timestamp},
        }
        observation = self._observation(reading, verdict, gps, consent, inference_timestamp)
        return {"status": 200, "body": body, "observation": observation}

    def _observation(self, reading: dict, verdict: dict, gps, consent: dict | None,
                     timestamp: str) -> dict | None:
        """Faltobservation till Atlas - endast med samtycke, alltid validerad."""
        if not consent or not consent.get("media_storage"):
            return None

        identification = (verdict.get("identification")
                          if verdict.get("status") == "verified" else None)
        top = (verdict.get("suggestions") or [None])[0]
        if identification:
            match = {"status": "matched",
                     "matched_stone_id": f"stone-{identification['inscription_id'].removeprefix('ric-')}",
                     "identity_score": identification["identification_score"],
                     "evidence": list(identification.get("evidence_types", []))}
            verification_status, verified_by = "database_matched", "runeverifier-v0.1"
            stone_id = match["matched_stone_id"]
        else:
            match = {"status": "no_match" if not top else "candidate",
                     "matched_stone_id": None, "identity_score": None, "evidence": []}
            verification_status, verified_by = "unverified", None
            stone_id = None

        obs_id = f"obs-api-{abs(hash((timestamp, reading.get('transliteration')))) % 10**10}"
        record = {
            "observation_id": obs_id,
            "stone_id": stone_id,
            "captured_at": timestamp,
            "gps": {"latitude": gps[0], "longitude": gps[1], "accuracy_m": None} if gps else None,
            "device": None, "weather": None, "condition_observed": None,
            "images": [f"img-api-{obs_id.removeprefix('obs-')}"],
            "reading_confidence": reading.get("confidence"),
            "match": match,
            "verification_status": verification_status,
            "verified_by": verified_by,
            "verified_at": timestamp if verified_by else None,
            "consent": {
                "media_storage": bool(consent.get("media_storage")),
                "training_use": bool(consent.get("training_use")),
                "consent_version": consent.get("consent_version", "consent-v1"),
                "consented_at": consent.get("consented_at", timestamp),
            },
            "provenance": {
                "dataset_id": "field-observations",
                "source": "Runestone API field capture",
                "source_url": "https://api.internal/analyze",
                "source_record_id": obs_id,
                "license": f"user-contributed, {consent.get('consent_version', 'consent-v1')}",
                "creator": None,
                "attribution": "Anonymized field contributor",
                "modification_status": "unmodified",
                "download_timestamp": timestamp,
                "dataset_version": "v0.1",
                "checksum": "sha256:" + hashlib.sha256(
                    f"{obs_id}:{reading.get('transliteration')}".encode()).hexdigest(),
            },
        }
        errors = validate_record(record, "field-observation")
        if errors:  # en ogiltig observation skrivs aldrig - hellre ingen
            return None
        return record
