"""LEVEL 3 - MODERN EXPERIENCE: moderniseringsmotorn.

Tva generatorer, samma kontrakt (rendering.schema.json):

1. render_modern() - deterministisk mallrenderare fran Level 2. Konservativ
   men mansklig; anvands som referens, fallback och testbar grund.
2. STYLE_SPEC - promptspecifikationen for LLM-lagret (emotion first).
   Den appliceras ALLTID pa den verifierade betydelsen (Level 1/2), aldrig
   pa bilden - stillagret far skapa kansla, inte fakta.

Prioritering (fran produktspecen): begriplighet -> mansklig kansla ->
ordagrannhet -> historisk grammatik. Forbjudna tillagg: nya personer,
platser, datum, dodsorsaker, obelagda relationer, handelser, fejkade citat.
"""

from __future__ import annotations

STYLE_SPEC = """Du far den verifierade betydelsen av en runinskrift (Level 1: kalloversattning; Level 2: strukturerad semantik). Skriv om den till modern svenska enligt:

MAL: lasaren ska omedelbart forsta den manskliga betydelsen och kanna nagot av den. "Det har var en riktig manniska. Det har var viktigt for dem."

PRIORITERA: (1) begriplighet, (2) mansklig kansla, (3) ordagrannhet, (4) historisk grammatik - i den ordningen.

ANVAND: korta moderna meningar, vardagligt sprak, emotionell ton, direkthet.
UNDVIK: alderdomliga formuleringar, bibelsprak, akademiskt sprak, konstiga ordagranna konstruktioner, overdrivet historiserande.

TOLKNING AR TILLATEN for underforstodd betydelse ("for att ingen skulle glomma honom"), MEN LAGG ALDRIG TILL: nya personer, nya platser, exakta datum, dodsorsaker, obelagda relationer, historiska handelser, eller citat som pastas sta pa stenen.

BEVARA KARNAN: vem som reste stenen, for vem, relationen, och att det ar ett minnesmarke.

FORMAT: returnera endast den fardiga svenska texten. Inga fotnoter, ingen analys, inga tekniska reservationer - mycket osakra detaljer loses med naturlig forsiktig formulering."""

GENERATOR = "template-v0.1"

KINSHIP_SV = {
    "father": "pappa", "mother": "mamma", "son": "son", "daughter": "dotter",
    "brother": "bror", "sister": "syster", "husband": "man", "wife": "hustru",
    "kinsman": "frände",
}


def _join_names(names: list[str]) -> str:
    if not names:
        return ""
    if len(names) == 1:
        return names[0]
    return ", ".join(names[:-1]) + " och " + names[-1]


def render_modern(interpretation: dict, *, canonical_translation: str | None = None,
                  rendering_id: str = "ren-unsaved") -> dict:
    """Deterministisk emotion-first-rendering fran Level 2.

    canonical_translation skickas med nar den finns (kand sten) - da ar
    renderingen scholarly_grounded och mallen kan halla sig nara kallan.
    """
    commissioners = [p["name"] for p in interpretation["people"] if p.get("role") == "commissioner"]
    honorees = [p["name"] for p in interpretation["people"] if p.get("role") == "honoree"]
    relation = next((r["type"] for r in interpretation["relationships"]), None)
    actions = interpretation["actions"]
    emotional = interpretation["emotional_context"]

    lines: list[str] = []
    if "memorial_stone_erected" in actions:
        subject = _join_names(commissioners) or "Någon"
        if honorees and relation:
            kin = KINSHIP_SV.get(relation, relation)
            lines.append(f"{subject} reste den här stenen för sin {kin} {_join_names(honorees)}.")
        elif honorees:
            lines.append(f"{subject} reste den här stenen för {_join_names(honorees)}.")
        else:
            lines.append(f"{subject} reste den här stenen till minne av någon de förlorat.")
    if "bridge_built" in actions:
        lines.append("De byggde också bron här — ett minne man kan gå över.")
    if "loss" in emotional:
        lines.append("För att ingen skulle glömma.")
    if "prayer_offered" in actions:
        lines.append("Och en bön: att Gud skulle ta hand om själen.")
    if "runes_carved" in actions and not lines:
        lines.append("Någon högg de här runorna för att lämna ett spår.")

    if not lines:
        # Otillracklig semantik: ingen rendering hellre an en pahittad.
        return {}

    basis = "canonical" if canonical_translation else "formulaic"
    return {
        "rendering_id": rendering_id,
        "interpretation_id": interpretation["interpretation_id"],
        "basis": basis,
        "style": "emotion_first",
        "text_sv": " ".join(lines),
        "scholarly_grounded": basis == "canonical",
        "generator": GENERATOR,
        "reviewed": False,
        "reviewed_by": None,
    }
