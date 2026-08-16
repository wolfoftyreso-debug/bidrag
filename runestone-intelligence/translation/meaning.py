"""LEVEL 2 - INTERPRETED MEANING: strukturerad semantik ur en inskrift.

Deterministisk, regelbaserad extraktion ur minnesformelns struktur:
personer (oupplosta tokens), relationer (slaktord), handlingar, syfte och
emotionell kontext. Varje element citerar sina kalltokens - Level 2 ar
systemets forstaelse, sparbar till Level 1, aldrig automatisk sanning
(derivation.reviewed=false tills manniska granskat).
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from normalize import normalize_tokens  # noqa: E402

GENERATOR = "meaning-extractor-v0.1"

RELATION_TYPES = {
    "faður": "father", "moður": "mother", "sun": "son", "syni": "son",
    "broður": "brother", "systur": "sister", "boanda": "husband",
}

MEMORIAL_VERBS = {"ræisti", "ræistu", "let", "letu", "ræisa", "retta", "haggva"}
CARVING_VERBS = {"risti", "ristu"}
MEMORIAL_PREPOSITIONS = {"æftiR", "at"}
PRAYER_WORDS = {"Guð", "hialpi"}
BRIDGE_WORDS = {"bro"}
POSSESSIVES = {"sinn", "sina"}


def extract_meaning(transliteration: str, *, basis_source: str,
                    inscription_id: str | None = None,
                    observation_id: str | None = None,
                    interpretation_id: str = "int-unsaved") -> dict:
    tokens = normalize_tokens(transliteration)

    memorial_verb_pos = next((i for i, t in enumerate(tokens)
                              if t["normalized"] in MEMORIAL_VERBS), None)
    preposition_pos = next((i for i, t in enumerate(tokens)
                            if t["normalized"] in MEMORIAL_PREPOSITIONS), None)

    people = []
    for i, t in enumerate(tokens):
        if t["resolved"]:
            continue  # formelord ar aldrig personer; oupplost token = namnkandidat
        role = None
        if memorial_verb_pos is not None and i < memorial_verb_pos:
            role = "commissioner"
        elif preposition_pos is not None and i > preposition_pos:
            role = "honoree"
        people.append({"name": t["token"].capitalize(), "source_token": t["token"],
                       "position": i, "role": role})

    relationships = [{"type": RELATION_TYPES[t["normalized"]], "source_token": t["token"]}
                     for t in tokens if t["normalized"] in RELATION_TYPES]

    normalized_set = {t["normalized"] for t in tokens}
    actions = []
    if memorial_verb_pos is not None and ("stæin" in normalized_set or "stæina" in normalized_set):
        actions.append("memorial_stone_erected")
    if normalized_set & CARVING_VERBS:
        actions.append("runes_carved")
    if normalized_set & BRIDGE_WORDS:
        actions.append("bridge_built")
    if PRAYER_WORDS <= normalized_set or "hialpi" in normalized_set:
        actions.append("prayer_offered")

    purpose = ["remembrance"] if preposition_pos is not None else []
    if "prayer_offered" in actions:
        purpose.append("piety")
    if not purpose:
        purpose = ["unknown"]

    emotional_context = []
    if "memorial_stone_erected" in actions or preposition_pos is not None:
        emotional_context.append("memorial")
    if relationships:
        emotional_context.append("family")
    if preposition_pos is not None:
        emotional_context.append("loss")
    if "prayer_offered" in actions:
        emotional_context.append("faith")
    if "goðan" in normalized_set or "dræng" in normalized_set:
        emotional_context.append("pride")

    return {
        "interpretation_id": interpretation_id,
        "basis": {"source": basis_source,
                  "inscription_id": inscription_id,
                  "observation_id": observation_id,
                  "transliteration": transliteration},
        "people": people,
        "relationships": relationships,
        "actions": actions,
        "purpose": purpose,
        "emotional_context": emotional_context,
        "derivation": {"generator": GENERATOR, "reviewed": False, "reviewed_by": None},
    }
