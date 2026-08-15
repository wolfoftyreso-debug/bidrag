"""STEG 7: automatisk matchning signum <-> inscription <-> image <-> source <-> license.

Kallans pastadda koppling (bildens signum-falt) verifieras mot corpus -
den antas inte. Tre utfall:

  matched    - signum finns i corpus: bilden far inscription_id
  unmatched  - signum saknas i corpus eller bilden saknar signum:
               granskningsko, aldrig gissning
  ambiguous  - flera corpusposter med samma nyckel (ska inte kunna handa
               efter idempotent import, men matchern litar inte pa det)

Omatchade bilder ar ocksa data: de kan avsloja luckor i corpus eller fel i
kallans metadata.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from signum import SignumError, signum_key


@dataclass
class MatchReport:
    matched: list[dict] = field(default_factory=list)      # uppdaterade image-poster
    unmatched: list[dict] = field(default_factory=list)    # {image_id, signum, reason}
    ambiguous: list[dict] = field(default_factory=list)    # {image_id, signum, candidates}

    @property
    def counts(self) -> dict:
        return {
            "matched": len(self.matched),
            "unmatched": len(self.unmatched),
            "ambiguous": len(self.ambiguous),
        }


def match_images(
    inscriptions: list[dict],
    images: list[dict],
    pairings: list[dict],
) -> MatchReport:
    report = MatchReport()

    by_key: dict[str, list[dict]] = {}
    for ins in inscriptions:
        try:
            key = signum_key(ins["signum"])
        except SignumError:
            continue  # redan avvisad av importern; ska inte forekomma
        by_key.setdefault(key, []).append(ins)

    claimed = {p["image_id"]: p["signum"] for p in pairings}
    images_by_id = {img["image_id"]: img for img in images}

    for image_id, image in images_by_id.items():
        signum_raw = claimed.get(image_id)
        if not signum_raw:
            report.unmatched.append({
                "image_id": image_id, "signum": None,
                "reason": "bilden saknar signum i kallan",
            })
            continue
        try:
            key = signum_key(signum_raw)
        except SignumError as exc:
            report.unmatched.append({"image_id": image_id, "signum": signum_raw, "reason": str(exc)})
            continue

        candidates = by_key.get(key, [])
        if not candidates:
            report.unmatched.append({
                "image_id": image_id, "signum": signum_raw,
                "reason": f"signum {key} finns inte i corpus",
            })
        elif len(candidates) > 1:
            report.ambiguous.append({
                "image_id": image_id, "signum": signum_raw,
                "candidates": [c["inscription_id"] for c in candidates],
            })
        else:
            matched = dict(image)
            matched["inscription_id"] = candidates[0]["inscription_id"]
            report.matched.append(matched)

    return report
