"""Explore - NASTA RUNSTEN och RUNESTONE TRAIL (ADR-0009).

Efter en identifierad sten ska anvandaren omedelbart se nasta:

    🪨 U 329 — 1,4 km — ca 18 min promenad / 4 min med bil

och senare hela slingor:

    RUNESTONE TRAIL: 7 stenar · 12,4 km · ca 2 h

Motorn ar ren geometri over corpus-/atlasposter med koordinater:
deterministisk, stdlib-only, och medvetet enkel (fagelvag + schablonfart).
Riktig ruttning (vagar, kollektivtrafik) ar en senare integrationsfraga -
upptacktskanslan kraver den inte.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "knowledge"))
from retrieval import haversine_km  # noqa: E402

WALK_MIN_PER_KM = 12.0   # ~5 km/h
DRIVE_MIN_PER_KM = 1.5   # ~40 km/h landsvagsschablon
DRIVE_OVERHEAD_MIN = 2.0  # parkera, ga sista biten


def _position(record: dict) -> tuple[float, float] | None:
    coords = record.get("coordinates") or (record.get("location") or {})
    lat, lon = coords.get("latitude"), coords.get("longitude")
    if lat is None or lon is None:
        return None
    return (lat, lon)


def _entry(record: dict, distance_km: float, seen: set[str]) -> dict:
    key = record.get("signum") or record.get("stone_id") or record.get("inscription_id")
    return {
        "signum": record.get("signum"),
        "id": record.get("inscription_id") or record.get("stone_id"),
        "distance_km": round(distance_km, 2),
        "walk_min": round(distance_km * WALK_MIN_PER_KM),
        "drive_min": round(distance_km * DRIVE_MIN_PER_KM + DRIVE_OVERHEAD_MIN),
        "seen": key in seen,
        "accessibility": record.get("accessibility"),
    }


def nearby(records: list[dict], position: tuple[float, float], *,
           limit: int = 5, exclude_seen: set[str] | None = None,
           max_km: float | None = None) -> list[dict]:
    """Narmaste stenar fran en position, narmast forst. Poster utan
    koordinater kan inte foreslas (de rapporteras av coverage-rapporten,
    tystas inte har). Redan sedda stenar flaggas men doljs bara om
    exclude_seen anvands som filter av anroparen via 'seen'-faltet."""
    seen = exclude_seen or set()
    scored = []
    for record in records:
        pos = _position(record)
        if pos is None:
            continue
        dist = haversine_km(position[0], position[1], pos[0], pos[1])
        if max_km is not None and dist > max_km:
            continue
        scored.append((dist, record))
    scored.sort(key=lambda pair: (pair[0], pair[1].get("signum") or ""))
    return [_entry(rec, dist, seen) for dist, rec in scored[:limit]]


def trail(records: list[dict], start: tuple[float, float], *,
          count: int = 7) -> dict:
    """Girig narmaste-granne-slinga fran startpunkten: enkel, deterministisk
    och tillrackligt bra for upptacktskanslan."""
    remaining = [r for r in records if _position(r) is not None]
    route: list[dict] = []
    position = start
    total_km = 0.0

    while remaining and len(route) < count:
        dist, nxt = min(
            ((haversine_km(position[0], position[1], *_position(r)), r) for r in remaining),
            key=lambda pair: (pair[0], pair[1].get("signum") or ""))
        total_km += dist
        route.append(_entry(nxt, dist, set()))
        position = _position(nxt)
        remaining.remove(nxt)

    return {
        "stones": route,
        "count": len(route),
        "total_km": round(total_km, 1),
        "walk_min_estimate": round(total_km * WALK_MIN_PER_KM),
    }
