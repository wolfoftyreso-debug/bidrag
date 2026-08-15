"""RuneTranslation v0.1 - kedjans sista steg med strikt policyordning
(plan §22: oversattning forst nar runtexten stabiliserats; aldrig
IMAGE -> LLM guesses meaning).

Policyordning:

1. CANONICAL   - verifieringen har bekraftat en kand inskrift
                 (MATCH HIGH/MEDIUM): kallans oversattning anvands,
                 kallforankrad och versionsangiven. Detta ar normalfallet
                 for kanda stenar.
2. FORMULAIC   - okand sten men lasningen foljer den valdokumenterade
                 minnesformeln: regelbaserad deloversattning dar formelord
                 oversatts och oupplosta tokens (typiskt namn) behalls
                 markerade. Kraver tackningstroskeln; redovisar per token.
3. ABSTAIN     - annars: insufficient_evidence. Hellre inget svar an en
                 fabricerad oversattning (plan §45 Abstention).

Modern svenska ska vara lattlast men inte historiskt forskonande.
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from normalize import normalization_coverage, normalize_tokens  # noqa: E402

# Svenska glosor for normaliserade formelord. Medvetet torr och ordagrann.
SWEDISH_GLOSSARY = {
    "ok": "och", "ræisti": "reste", "risti": "ristade",
    "ræistu": "reste", "ristu": "ristade", "let": "lät", "letu": "läto",
    "ræisa": "resa", "retta": "uppresa", "haggva": "hugga",
    "stæin": "stenen", "stæina": "stenarna",
    "þenna": "denna", "þennsa": "denna", "þannsi": "denna",
    "æftiR": "efter", "at": "efter",
    "sun": "son", "syni": "son", "sinn": "sin", "sina": "sina",
    "faður": "fader", "moður": "moder", "broður": "broder",
    "systur": "syster", "boanda": "make",
    "goðan": "god", "goða": "goda", "Guð": "Gud",
    "hialpi": "hjälpe", "and": "ande", "anda": "ande", "salu": "själ",
    "mærki": "märket", "bro": "bron", "gærði": "gjorde",
    "dræng": "ung man", "harða": "mycket",
}

FORMULA_COVERAGE_THRESHOLD = 0.6  # under detta: abstention, inte gissning
MIN_TOKENS_FOR_FORMULA = 3


def formulaic_translation(transliteration: str) -> dict | None:
    """Regelbaserad deloversattning av minnesformeln. None om tackningen
    ar for lag for att vara arlig."""
    tokens = normalize_tokens(transliteration)
    if len(tokens) < MIN_TOKENS_FOR_FORMULA:
        return None
    coverage = normalization_coverage(tokens)
    if coverage < FORMULA_COVERAGE_THRESHOLD:
        return None

    words: list[str] = []
    detail: list[dict] = []
    for t in tokens:
        gloss = SWEDISH_GLOSSARY.get(t["normalized"]) if t["resolved"] else None
        if gloss is not None:
            words.append(gloss)
            detail.append({**t, "swedish": gloss, "kind": "formula"})
        else:
            # Oupplost token: behall som namn/okant (versal som namn),
            # aldrig oversatt genom gissning.
            words.append(t["token"].capitalize())
            detail.append({**t, "swedish": None, "kind": "unresolved"})

    return {
        "translation_sv": " ".join(words),
        "normalization": " ".join(t["normalized"] for t in tokens),
        "coverage": round(coverage, 3),
        "tokens": detail,
    }


def translate(observed_transliteration: str, verdict: dict | None = None) -> dict:
    """Producerar oversattningsblocket for ett analysresultat.

    verdict: utlatandet fran verification.verify_against_candidates (eller
    None nar ingen retrieval gjorts).
    """
    # 1. Kallforankrad oversattning fran verifierad kand inskrift.
    if verdict and verdict.get("status") == "verified":
        source = verdict.get("source") or {}
        if source.get("translation_sv"):
            return {
                "translation_sv": source["translation_sv"],
                "method": "canonical",
                "translation_source": {
                    "source_database": source.get("source_database"),
                    "source_provider": source.get("source_provider"),
                    "signum": (verdict.get("identification") or {}).get("signum"),
                },
                "scholarly_status": verdict.get("presented_scholarly_status"),
                "abstained": False,
            }

    # 2. Formelbaserad deloversattning - endast utan motsagande verifiering.
    if not verdict or verdict.get("status") in ("no_candidates", "gps_only_suggestions"):
        formulaic = formulaic_translation(observed_transliteration)
        if formulaic is not None:
            return {
                **formulaic,
                "method": "formulaic",
                "translation_source": {"source_database": None,
                                       "note": "regelbaserad formeltolkning, ej kallbelagd"},
                "scholarly_status": "uncertain",
                "abstained": False,
            }

    # 3. Abstention: mismatch mot kand sten, eller okand text utan formel.
    reason = ("lasningen motsager kand inskrift - alternativ analys kravs"
              if verdict and verdict.get("status") == "mismatch"
              else "otillracklig grund for oversattning")
    return {
        "translation_sv": None,
        "method": "abstain",
        "reason": reason,
        "scholarly_status": "insufficient_evidence",
        "abstained": True,
    }
