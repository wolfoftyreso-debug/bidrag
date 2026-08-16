"""RUNESTONE MASTER DATABASE - assembleringsvyn (ADR-0009).

Varje fysisk sten blir ETT kunskapsobjekt: identitet, position, bilder,
inskrift, tolkning, personer och kallor - inte bara en textstrang.
Detta ar en deterministisk VY over de kontraktsvaliderade lagren
(L1 inscription + image-rights + stone + L2 interpretation + L3 rendering);
den lagrar ingenting sjalv och far ALDRIG mutera Level 1 - assert i koden.

    PHOTO -> IDENTIFY -> RETRIEVE (denna vy) -> EXPLAIN
"""

from __future__ import annotations


def assemble_master(
    inscription: dict,
    *,
    images: list[dict] | None = None,
    stone: dict | None = None,
    interpretation: dict | None = None,
    rendering: dict | None = None,
) -> dict:
    """Bygger master-objektet for en sten. Kastar ValueError om nagon del
    pastas hora till en annan inskrift - vyer far inte blanda stenar."""
    iid = inscription["inscription_id"]
    images = images or []
    for img in images:
        if img.get("inscription_id") not in (None, iid):
            raise ValueError(f"bild {img['image_id']} hor till {img['inscription_id']}, inte {iid}")
    if interpretation and (interpretation.get("basis") or {}).get("inscription_id") not in (None, iid):
        raise ValueError("interpretation hor till annan inskrift")
    if stone and stone.get("inscription_id") not in (None, iid):
        raise ValueError("stenobjektet hor till annan inskrift")

    official = [i for i in images if i.get("layer") in ("B", "C", "D", "E")]
    field_photos = [i for i in images if i.get("layer") == "F"]

    location = None
    coords = inscription.get("coordinates") or (stone or {}).get("location")
    if coords:
        location = {"latitude": coords["latitude"], "longitude": coords["longitude"],
                    "accessibility": (stone or {}).get("accessibility")}

    people = []
    relationships = []
    if interpretation:
        people = [{"name": p["name"], "role": p.get("role")}
                  for p in interpretation.get("people", [])]
        relationships = [r["type"] for r in interpretation.get("relationships", [])]

    master = {
        "identity": {
            "id": iid,
            "signum": inscription["signum"],
            "country": inscription.get("country"),
            "region": inscription.get("region"),
            "municipality": (stone or {}).get("municipality"),
            "rune_type": inscription.get("rune_type"),
            "dating": inscription.get("dating"),
        },
        "location": location,
        "visual": {
            "official_photographs": [
                {"image_id": i["image_id"], "license": i["license"],
                 "photographer": i.get("photographer"),
                 "institution": i.get("source_institution")} for i in official],
            "field_photographs": [
                {"image_id": i["image_id"], "observation_id": i.get("observation_id")}
                for i in field_photos],
            "image_fingerprints": [],  # fylls av identifieringsmotorn (Sprint 5+)
        },
        "inscription": {
            "runes": inscription.get("runic_text"),
            "transliteration": inscription["transliteration"],
            "normalization": inscription.get("normalization"),
            "scholarly_translation": {
                "sv": inscription.get("translation_sv"),
                "en": inscription.get("translation_en"),
            },
            "alternative_readings": inscription.get("alternative_readings", []),
            "scholarly_status": inscription.get("scholarly_status"),
        },
        "interpretation": {
            "modern_sv": (rendering or {}).get("text_sv"),
            "style": (rendering or {}).get("style"),
            "scholarly_grounded": (rendering or {}).get("scholarly_grounded"),
            "reviewed": (rendering or {}).get("reviewed"),
        },
        "people": people,
        "relationships": relationships,
        "sources": {
            "source_database": inscription["source_database"],
            "source_provider": inscription["source_provider"],
            "enrichments": [e["source"] for e in inscription.get("enrichments", [])],
            "bibliography": inscription.get("bibliography", []),
            "image_licenses": sorted({i["license"] for i in images}),
            "user_observations": [i.get("observation_id") for i in field_photos
                                  if i.get("observation_id")],
        },
        "atlas": {
            "stone_id": (stone or {}).get("stone_id"),
            "atlas_status": (stone or {}).get("atlas_status"),
            "current_condition": (stone or {}).get("current_condition"),
            "observation_count": (stone or {}).get("observation_count"),
            "last_observation": (stone or {}).get("last_observation"),
        },
    }

    # L1-invariant: vyn far aldrig andra kalltexten.
    assert master["inscription"]["transliteration"] == inscription["transliteration"]
    assert master["inscription"]["scholarly_translation"]["sv"] == inscription.get("translation_sv")
    return master
