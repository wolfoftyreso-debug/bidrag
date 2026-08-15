"""Runtecken -> translitterering (kedjans forsta steg, plan §22).

v0.1 tacker yngre futharken (langkvist + kortkvist-varianter) plus nagra
medeltida tillagg - det ar vad de svenska vikingatida inskrifterna kraver.
Aldre futharken och anglosaxiska runor laggs till per expansionsplanen
(plan §48).

Okanda tecken blir ALDRIG tyst borttagna eller gissade: de ersatts med
platshallaren '?' och rapporteras med position, sa att osakerheten foljer
med hela vagen till anvandaren (plan §21).
"""

from __future__ import annotations

# Yngre futharken, langkvist. 'R' ar palatalt r (yr-runan) enligt
# vetenskaplig konvention; 'þ' behalls som þ.
YOUNGER_FUTHARK = {
    "ᚠ": "f", "ᚢ": "u", "ᚦ": "þ", "ᚬ": "o", "ᚱ": "r", "ᚴ": "k",
    "ᚼ": "h", "ᚾ": "n", "ᛁ": "i", "ᛅ": "a", "ᛋ": "s", "ᛏ": "t",
    "ᛒ": "b", "ᛘ": "m", "ᛚ": "l", "ᛦ": "R",
}

# Kortkvist-/stuprunevarianter och senare tillagg.
VARIANTS = {
    "ᚡ": "f", "ᚧ": "þ", "ᚿ": "n", "ᛆ": "a", "ᛌ": "s", "ᛐ": "t",
    "ᛖ": "e", "ᛧ": "R", "ᚮ": "o", "ᛂ": "e", "ᛑ": "d", "ᚵ": "g",
    "ᛔ": "p", "ᛜ": "ng", "ᛄ": "j",
}

# Skiljetecken i inskrifter: ordavgransare -> mellanslag.
SEPARATORS = {"᛬", "᛫", "᛭", "·", "×", ":", "+", "|"}

RUNE_MAP = {**YOUNGER_FUTHARK, **VARIANTS}


def transliterate_runes(rune_text: str) -> dict:
    """-> {transliteration, unknown: [{position, char}], coverage}

    coverage = andel runtecken som kunde translittereras. Whitespace och
    separatorer raknas inte in i taljaren eller namnaren.
    """
    out: list[str] = []
    unknown: list[dict] = []
    rune_count = 0
    known_count = 0

    for pos, char in enumerate(rune_text or ""):
        if char.isspace() or char in SEPARATORS:
            out.append(" ")
            continue
        rune_count += 1
        mapped = RUNE_MAP.get(char)
        if mapped is None:
            out.append("?")
            unknown.append({"position": pos, "char": char})
        else:
            known_count += 1
            out.append(mapped)

    return {
        "transliteration": " ".join("".join(out).split()),
        "unknown": unknown,
        "coverage": (known_count / rune_count) if rune_count else 0.0,
    }
