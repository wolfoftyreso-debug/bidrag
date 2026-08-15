"""Translitterering -> normaliserad fornostnordisk form (kedjans andra steg).

v0.1 anvander ett litet SEED-LEXIKON over de vanligaste formelorden i
vikingatida minnesinskrifter (Rundata-konventionens normaliseringar).
Lexikonet ar medvetet ofullstandigt och ska ersattas/utokas med ett
korpushärlett lexikon i Sprint 8+ - det ar en referensimplementation av
kedjan, inte en sprakmodell.

Okanda tokens normaliseras ALDRIG genom gissning: de passerar oforandrade
med resolved=False (typiskt personnamn - vilket formeltolkningen i
translate.py utnyttjar).
"""

from __future__ import annotations

# token i translitterering -> normaliserad form (fornostnordisk/runsvensk).
# Vanliga stavningsvarianter pekar pa samma normalform.
SEED_LEXICON = {
    "auk": "ok", "uk": "ok", "ok": "ok",
    "raisti": "ræisti", "raisþi": "ræisti", "risti": "risti",
    "raistu": "ræistu", "ristu": "ristu",
    "lit": "let", "litu": "letu",
    "raisa": "ræisa", "rita": "retta", "hakua": "haggva",
    "stain": "stæin", "stin": "stæin", "staina": "stæina",
    "þina": "þenna", "þinsa": "þennsa", "þansi": "þannsi", "þino": "þenna",
    "aftir": "æftiR", "aftiR": "æftiR", "iftir": "æftiR", "iftiR": "æftiR",
    "at": "at", "at.": "at",
    "sun": "sun", "son": "sun", "suni": "syni",
    "sin": "sinn", "sina": "sina", "sinn": "sinn",
    "faþur": "faður", "faþur.": "faður", "moþur": "moður",
    "bruþur": "broður", "systur": "systur", "buanta": "boanda",
    "kuþan": "goðan", "kuþa": "goða", "kuþ": "Guð",
    "hialbi": "hialpi", "ant": "and", "anta": "anda", "salu": "salu",
    "merki": "mærki", "bru": "bro", "kirþi": "gærði", "karþi": "gærði",
    "trik": "dræng", "harþa": "harða",
}


def normalize_tokens(transliteration: str) -> list[dict]:
    """-> [{token, normalized, resolved}] i lasordning."""
    result = []
    for token in (transliteration or "").split():
        normalized = SEED_LEXICON.get(token) or SEED_LEXICON.get(token.lower())
        result.append({
            "token": token,
            "normalized": normalized if normalized is not None else token,
            "resolved": normalized is not None,
        })
    return result


def normalization_coverage(tokens: list[dict]) -> float:
    if not tokens:
        return 0.0
    return sum(1 for t in tokens if t["resolved"]) / len(tokens)
