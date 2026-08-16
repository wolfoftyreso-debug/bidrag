"""RuneKnowledge v0.1 - candidate retrieval mot canonical corpus (plan §17-18).

    predicted inscription -> candidate retrieval -> known inscriptions
    -> similarity ranking -> historical evidence

Sokning kombinerar signaler och redovisar dem separat per kandidat -
samma evidensfilosofi som stone identity score (ADR-0007):

  inscription_similarity  - teckentrigram-Jaccard + editavstand pa lasningen
  gps_proximity           - narhet till stenens kanda koordinater
  filter                  - rune_type / region begransar kandidatmangden

GPS ar en signal, aldrig facit: en sokning med ENBART GPS flaggas
gps_only=true och far aldrig ligga till grund for en bekraftad
identifiering - den foreslar kandidater for rankning.

Stdlib-only och deterministisk: samma corpus + samma fraga ger samma
rankning (sekundarsortering pa inscription_id).
"""

from __future__ import annotations

import json
import math
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "benchmark"))
from metrics import edit_distance  # noqa: E402

_WORDISH = re.compile(r"[^\w]+", re.UNICODE)

RERANK_POOL = 50  # trigram-grovsokning -> editavstand-omrankning av toppen


def normalize_text(text: str) -> str:
    """Gemener, skiljetecken -> mellanslag, kollapsad whitespace.

    Translitterationer innehaller skada-/skiljemarkorer (:, -, ...) som inte
    ar lasinnehall; de ska inte paverka likhetsmatningen."""
    return " ".join(_WORDISH.sub(" ", (text or "").lower()).split())


def trigrams(text: str) -> set[str]:
    padded = f"  {normalize_text(text)} "
    return {padded[i:i + 3] for i in range(len(padded) - 2)} if padded.strip() else set()


def jaccard(a: set, b: set) -> float:
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)


def edit_similarity(a: str, b: str) -> float:
    a, b = normalize_text(a), normalize_text(b)
    if not a or not b:
        return 0.0
    return 1.0 - edit_distance(a, b) / max(len(a), len(b))


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp, dl = math.radians(lat2 - lat1), math.radians(lon2 - lon1)
    a = math.sin(dp / 2) ** 2 + math.cos(p1) * math.cos(p2) * math.sin(dl / 2) ** 2
    return 2 * r * math.asin(math.sqrt(a))


def proximity_score(distance_km: float, *, radius_km: float = 5.0) -> float:
    """1.0 vid stenen, linjart avtagande till 0 vid radius_km.

    Folk fotograferar fran hundra meters hall och GPS driver - men en sten
    5 km bort ar inte "har". Radien ar medvetet snal."""
    return max(0.0, 1.0 - distance_km / radius_km)


@dataclass
class Candidate:
    inscription_id: str
    signum: str
    score: float
    evidence: dict = field(default_factory=dict)   # signal -> varde (bara berakningsbara)
    gps_only: bool = False
    source: dict = field(default_factory=dict)     # historical evidence: kalla + oversattning

    def to_dict(self) -> dict:
        return {
            "inscription_id": self.inscription_id,
            "signum": self.signum,
            "score": round(self.score, 4),
            "evidence": {k: round(v, 4) for k, v in self.evidence.items()},
            "evidence_types": sorted(self.evidence),
            "gps_only": self.gps_only,
            "source": self.source,
        }


class CorpusIndex:
    def __init__(self, inscriptions: list[dict]):
        self._items = []
        for ins in inscriptions:
            self._items.append({
                "record": ins,
                "trigrams": trigrams(ins.get("transliteration", "")),
            })

    def records(self) -> list[dict]:
        return [item["record"] for item in self._items]

    def get(self, inscription_id: str) -> dict | None:
        return next((item["record"] for item in self._items
                     if item["record"]["inscription_id"] == inscription_id), None)

    @classmethod
    def from_corpus_dir(cls, corpus_dir: Path) -> "CorpusIndex":
        lines = (Path(corpus_dir) / "inscriptions.jsonl").read_text(encoding="utf-8").splitlines()
        return cls([json.loads(l) for l in lines if l.strip()])

    def search(
        self,
        *,
        query_text: str | None = None,
        gps: tuple[float, float] | None = None,
        rune_type: str | None = None,
        region: str | None = None,
        top_k: int = 5,
    ) -> list[Candidate]:
        if not query_text and gps is None:
            raise ValueError("sokning kraver lasning (query_text) och/eller GPS")

        pool = [
            item for item in self._items
            if (rune_type is None or item["record"].get("rune_type") == rune_type)
            and (region is None or (item["record"].get("region") or "").lower() == region.lower())
        ]

        scored: list[Candidate] = []
        if query_text:
            q_tri = trigrams(query_text)
            coarse = sorted(
                ((jaccard(q_tri, item["trigrams"]), item) for item in pool),
                key=lambda pair: (-pair[0], pair[1]["record"]["inscription_id"]),
            )[:RERANK_POOL]
            for tri_sim, item in coarse:
                record = item["record"]
                text_sim = 0.5 * tri_sim + 0.5 * edit_similarity(query_text, record.get("transliteration", ""))
                evidence = {"inscription_similarity": text_sim}
                prox = self._proximity(record, gps)
                if prox is not None:
                    evidence["gps_proximity"] = prox
                    score = 0.8 * text_sim + 0.2 * prox
                else:
                    score = text_sim
                scored.append(self._candidate(record, score, evidence, gps_only=False))
        else:
            # Enbart GPS: kandidatforslag, aldrig identifiering (ADR-0007).
            for item in pool:
                record = item["record"]
                prox = self._proximity(record, gps)
                if prox is not None and prox > 0.0:
                    scored.append(self._candidate(
                        record, prox, {"gps_proximity": prox}, gps_only=True))

        scored.sort(key=lambda c: (-c.score, c.inscription_id))
        return scored[:top_k]

    @staticmethod
    def _proximity(record: dict, gps: tuple[float, float] | None) -> float | None:
        coords = record.get("coordinates")
        if gps is None or not coords:
            return None
        dist = haversine_km(gps[0], gps[1], coords["latitude"], coords["longitude"])
        return proximity_score(dist)

    @staticmethod
    def _candidate(record: dict, score: float, evidence: dict, *, gps_only: bool) -> Candidate:
        return Candidate(
            inscription_id=record["inscription_id"],
            signum=record["signum"],
            score=score,
            evidence=evidence,
            gps_only=gps_only,
            source={
                "source_database": record.get("source_database"),
                "source_provider": record.get("source_provider"),
                "transliteration": record.get("transliteration"),
                "translation_sv": record.get("translation_sv"),
                "scholarly_status": record.get("scholarly_status"),
            },
        )
