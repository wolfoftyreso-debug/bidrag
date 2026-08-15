"""RuneVerifier v0.1 - cross-check observerad lasning mot kanonisk inskrift
(plan §19).

    visual reading -> canonical inscription -> MATCH HIGH/MEDIUM/LOW

Avvikelser redovisas per position och lag match triggar alternativ analys -
aldrig tyst overtackning. Verifieringen avgor ocksa vilken vetenskaplig
status resultatet kan fa: en maskinell tolkning far aldrig presenteras som
etablerad nar lasningen inte stammer med kallan (plan §39).
"""

from __future__ import annotations

import sys
from difflib import SequenceMatcher
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parents[1] / "benchmark"))
sys.path.insert(0, str(Path(__file__).parents[1] / "knowledge"))
from metrics import cer  # noqa: E402
from retrieval import normalize_text  # noqa: E402

# CER-transklar for matchniva. HIGH ar avsiktligt strang: en runa fel av
# tjugo ar redan MEDIUM - det ar precis de fallen som ska granskas.
MATCH_HIGH_MAX_CER = 0.05
MATCH_MEDIUM_MAX_CER = 0.15


def _mismatches(observed: str, canonical: str) -> list[dict]:
    """Positionsvisa avvikelser via sekvensalignering (inte naiv zip -
    en insattning tidigt i strangen ska inte flagga allt efterfoljande)."""
    out: list[dict] = []
    matcher = SequenceMatcher(a=canonical, b=observed, autojunk=False)
    for op, c1, c2, o1, o2 in matcher.get_opcodes():
        if op == "equal":
            continue
        out.append({
            "op": {"replace": "substitution", "delete": "missing", "insert": "extra"}[op],
            "canonical_position": c1,
            "canonical": canonical[c1:c2],
            "observed": observed[o1:o2],
        })
    return out


def verify_reading(observed: str, canonical: str) -> dict:
    obs, canon = normalize_text(observed), normalize_text(canonical)
    reading_cer = cer(canon, obs)
    if reading_cer is None:
        raise ValueError("kanonisk lasning ar tom - inget att verifiera mot")

    if reading_cer <= MATCH_HIGH_MAX_CER:
        match = "HIGH"
    elif reading_cer <= MATCH_MEDIUM_MAX_CER:
        match = "MEDIUM"
    else:
        match = "LOW"

    return {
        "match": match,
        "cer": round(reading_cer, 4),
        "mismatches": _mismatches(obs, canon),
        "alternative_analysis_required": match == "LOW",
    }


def verify_against_candidates(observed: str, candidates: list[dict]) -> dict:
    """Verifierar lasningen mot retrieval-kandidater (dict-form fran
    Candidate.to_dict) och producerar ett kallforankrat utlatande.

    Regler:
    - gps_only-kandidater kan aldrig ge en bekraftad identifiering
      (GPS ar signal, inte facit - ADR-0007); de rapporteras som forslag.
    - scholarly_status foljer med fran kallan och forbattras aldrig av
      verifieringen: LOW match nedgraderar presentationen till
      insufficient_evidence, HIGH match behaller kallans status.
    """
    if not candidates:
        return {"status": "no_candidates", "identification": None, "verification": None,
                "suggestions": []}

    verifiable = [c for c in candidates if not c.get("gps_only")]
    suggestions = [c for c in candidates if c.get("gps_only")]
    if not verifiable:
        return {"status": "gps_only_suggestions", "identification": None,
                "verification": None, "suggestions": suggestions}

    best = verifiable[0]
    canonical = (best.get("source") or {}).get("transliteration") or ""
    verification = verify_reading(observed, canonical)

    source_status = (best.get("source") or {}).get("scholarly_status")
    presented_status = source_status if verification["match"] == "HIGH" else (
        source_status if verification["match"] == "MEDIUM" and source_status in
        ("uncertain", "alternative_readings", "insufficient_evidence") else
        ("probable" if verification["match"] == "MEDIUM" else "insufficient_evidence")
    )

    return {
        "status": "verified" if verification["match"] != "LOW" else "mismatch",
        "identification": {
            "inscription_id": best["inscription_id"],
            "signum": best["signum"],
            "identification_score": best["score"],
            "evidence_types": best.get("evidence_types", []),
        },
        "verification": verification,
        "presented_scholarly_status": presented_status,
        "source": best.get("source"),
        "suggestions": suggestions,
    }
