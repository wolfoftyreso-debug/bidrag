"""Kartvyn - GeoJSON-feed for Mapbox (ADR-0009: Explore ar karnfunktion).

Varje sten blir en Feature med position, signum, foto och avbockning:

- **Foto:** ENDAST bilder med usage.redistribution_allowed=true exponeras i
  den publika feeden - en rights record ger visningsratt, inte tvartom
  (ADR-0003). Attribution foljer alltid med. Anvandarens EGNA faltfoton
  (Layer F, matchade via observation) ar alltid synliga for anvandaren
  sjalv - de skickas som own_photos separat.
- **Avbockning:** 'visited' satts fran anvandarens seen-lista (klientstyrd
  i V1 - inga konton). Kartan visar bockade stenar annorlunda.
- **Vagbeskrivning:** fardiga dir-lankar (Google/Apple) per sten; i appen
  anvands Mapbox Directions med samma koordinater.

Stdlib-only och deterministisk; servern exponerar feeden via POST /v1/map.
"""

from __future__ import annotations


def directions_links(latitude: float, longitude: float) -> dict:
    dest = f"{latitude},{longitude}"
    return {
        "google": f"https://www.google.com/maps/dir/?api=1&destination={dest}&travelmode=walking",
        "apple": f"https://maps.apple.com/?daddr={dest}&dirflg=w",
        "coordinates": {"latitude": latitude, "longitude": longitude},
    }


def _display_photo(images: list[dict]) -> dict | None:
    """Forsta publikt visningsbara fotot: redistribution_allowed kravs.
    Faltfoton (Layer F) ar aldrig publika har - de hor till agaren."""
    for img in images:
        if img.get("layer") == "F":
            continue
        if img.get("usage", {}).get("redistribution_allowed"):
            return {
                "image_id": img["image_id"],
                "url": img.get("original_url"),
                "license": img.get("license"),
                "attribution": (img.get("provenance") or {}).get("attribution")
                or f"{img.get('photographer') or 'okand'}, {img.get('license')}",
            }
    return None


def stones_geojson(
    inscriptions: list[dict],
    images: list[dict] | None = None,
    *,
    seen: set[str] | None = None,
    own_observations: list[dict] | None = None,
) -> dict:
    """-> GeoJSON FeatureCollection for kartlagret.

    seen: signum/inscription_id som anvandaren bockat av.
    own_observations: anvandarens egna faltobservationer (fran klienten
    eller kontolost lokalt arkiv) - {stone_ref, image_ids}.
    """
    seen = seen or set()
    images = images or []
    by_inscription: dict[str, list[dict]] = {}
    for img in images:
        iid = img.get("inscription_id")
        if iid:
            by_inscription.setdefault(iid, []).append(img)

    own_by_ref: dict[str, list[str]] = {}
    for obs in own_observations or []:
        ref = obs.get("stone_ref")
        if ref:
            own_by_ref.setdefault(ref, []).extend(obs.get("image_ids", []))

    features = []
    skipped_no_coordinates = []
    for ins in inscriptions:
        coords = ins.get("coordinates")
        if not coords:
            skipped_no_coordinates.append(ins["inscription_id"])
            continue
        iid = ins["inscription_id"]
        signum = ins["signum"]
        visited = signum in seen or iid in seen
        own_photos = own_by_ref.get(signum, []) + own_by_ref.get(iid, [])
        features.append({
            "type": "Feature",
            "geometry": {"type": "Point",
                         "coordinates": [coords["longitude"], coords["latitude"]]},
            "properties": {
                "id": iid,
                "signum": signum,
                "visited": visited or bool(own_photos),
                "photo": _display_photo(by_inscription.get(iid, [])),
                "own_photos": own_photos,
                "region": ins.get("region"),
                "translation_sv": ins.get("translation_sv"),
                "scholarly_status": ins.get("scholarly_status"),
                "directions": directions_links(coords["latitude"], coords["longitude"]),
                "source_database": ins.get("source_database"),
            },
        })

    return {
        "type": "FeatureCollection",
        "features": features,
        "meta": {
            "total": len(features),
            "visited": sum(1 for f in features if f["properties"]["visited"]),
            "skipped_no_coordinates": skipped_no_coordinates,
        },
    }
