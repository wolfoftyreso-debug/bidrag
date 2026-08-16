"""Context Engine v0 - berattar MER an det som star skrivet (ADR-0010).

Malet: turisten ska fa veta sa mycket som gar att veta om varje sten och
dess skapare - period, ristare, stil, skrift, seder, kristnande - i en
historisk kontext. Den harda regeln ar KALLSTATUS per block:

  established         belagt om JUST DENNA sten (ur corpusfalt: ristare,
                      stil, datering, region, skick)
  interpreted         harlett ur inskriftens innehall (L2: personer,
                      relationer, handlingar)
  general_background  allman, valetablerad kunskap om perioden/seden -
                      sann om epoken, INTE ett pastaende om denna sten

Blocken komponeras till en lasbar berattelse, men statusen foljer alltid
med sa att UI:t kan skilja "om den har stenen" fran "om tiden den restes i".
Biblioteket ar versionerat (library:<id>@v1) och far endast innehalla
okontroversiell standardkunskap; djupare berattelser genereras senare av
LLM-lagret under CONTEXT_SPEC - aldrig fria fakta om en enskild sten.
"""

from __future__ import annotations

LIBRARY_VERSION = "v1"

# Allmant bakgrundsbibliotek - medvetet forsiktig standardkunskap.
GENERAL_LIBRARY = {
    "runestone_custom": (
        "De flesta svenska runstenarna restes under sen vikingatid, ungefar "
        "950-1100. En runsten var oftast ett minnesmarke som familjen reste "
        "efter en dod anhorig - men ocksa ett offentligt dokument: den "
        "visade vem som arvde, vad familjen betydde och att man ville bli "
        "ihagkommen. Stenarna placerades dar folk passerade: vid vagar, "
        "broar, vadstallen och tingsplatser."
    ),
    "younger_futhark": (
        "Inskriften ar ristad med den yngre futharken - vikingatidens "
        "runrad med bara 16 tecken. Eftersom tecknen var farre an sprakets "
        "ljud kunde samma runa sta for flera ljud, och det ar en av "
        "anledningarna till att lasningen kraver tolkning."
    ),
    "christianization": (
        "Manga runstenar bar kors eller boner. De restes under den tid da "
        "Sverige holl pa att bli kristet, runt ar 1000, och stenarna ar "
        "ofta de aldsta sparen av kristen tro pa platsen - resta av "
        "familjer som levde mitt i religionsskiftet."
    ),
    "bridge_deed": (
        "Att bygga en bro och rista det i sten var en from garning: bron "
        "hjalpte bade resande har och - trodde man - den dodes sjal pa "
        "andra sidan. Brostenarna ar darfor bade vagmarken och boner."
    ),
    "carver_craft": (
        "Runristare var hantverkare, och nagra signerade sina verk - men "
        "de flesta stenar ar osignerade. Nar ristaren ar okand kan stilen "
        "anda avsloja ungefar nar och ibland i vilken krets stenen hoggs."
    ),
}

# Ornamentikstilar (Graslunds stilgruppering) - grova, etablerade dateringsfingervisningar.
STYLE_LIBRARY = {
    "RAK": ("oornamenterat runband med raka avslut", "brukar foras till tidigt 1000-tal"),
    "Fp": ("runband med fagelperspektiv pa rundjuret", "brukar foras till ca 1010-1050"),
    "Pr 1": ("tidig profilstil pa rundjuret", "brukar foras till ca 1010-1040"),
    "Pr 2": ("profilstil, andra fasen", "brukar foras till ca 1020-1050"),
    "Pr 3": ("utvecklad profilstil", "brukar foras till ca 1045-1075"),
    "Pr 4": ("sen profilstil med rikare slingor", "brukar foras till ca 1060-1100"),
    "Pr 5": ("den sista stilfasen", "brukar foras till ca 1100-1130"),
}

CONTEXT_SPEC = """Du far ett stenobjekt med kallstatus-markta kontextblock (established/interpreted/general_background) samt Level 1-2-data. Skriv en fordjupad historisk berattelse for en besokare vid stenen enligt:

MAL: lasaren ska fa veta sa mycket som gar att VETA - och kanna epoken.
HARDA REGLER: pastaenden om JUST DENNA sten far endast bygga pa established/interpreted-block. Allt annat formuleras uttryckligen som tidsbild ("pa den har tiden...", "brukar dateras..."). Hitta ALDRIG pa: namn, handelser, dodsorsaker, resor, slaktband eller ristare som inte finns i blocken. Osakerhet loses med arlig formulering, inte med pahitt.
TON: konkret, mansklig, nyfiken - inte larobok. Svensk lattlast prosa."""


def _block(kind: str, topic: str, text: str, source: str) -> dict:
    return {"kind": kind, "topic": topic, "text_sv": text, "source": source}


def build_context(inscription: dict | None, interpretation: dict | None = None) -> dict:
    """Bygger kontextblocken for en sten (eller for en okand sten: enbart
    tolknings- och bakgrundsblock). Deterministisk; varje block bar kalla."""
    blocks: list[dict] = []
    ins = inscription or {}

    # ESTABLISHED - belagt om just denna sten, direkt ur corpusfalt.
    if ins.get("dating"):
        blocks.append(_block(
            "established", "datering",
            f"Stenen dateras till vikingatid (källans dateringskod: {ins['dating']}).",
            "corpus:dating"))
    if ins.get("carver"):
        blocks.append(_block(
            "established", "ristare",
            f"Ristare enligt källan: {ins['carver']}. Att namnet är känt gör "
            "stenen ovanlig — de flesta ristare förblev anonyma.",
            "corpus:carver"))
    style = ins.get("style")
    if style and style in STYLE_LIBRARY:
        desc, dating_hint = STYLE_LIBRARY[style]
        blocks.append(_block(
            "established", "stil",
            f"Ornamentiken hör till stilgruppen {style} ({desc}); stilen {dating_hint}.",
            f"corpus:style+library:styles@{LIBRARY_VERSION}"))
    if ins.get("region"):
        blocks.append(_block(
            "established", "plats",
            f"Stenen hör hemma i {ins['region']}"
            + (f", {ins.get('location')}" if ins.get("location") else "") + ".",
            "corpus:region"))

    # INTERPRETED - harlett ur inskriftens innehall (L2).
    if interpretation:
        people = interpretation.get("people", [])
        commissioners = [p["name"] for p in people if p.get("role") == "commissioner"]
        honorees = [p["name"] for p in people if p.get("role") == "honoree"]
        if commissioners or honorees:
            who = " och ".join(commissioners) if commissioners else "Någon"
            text = f"Inskriften nämner människor vid namn: {who} lät resa stenen"
            if honorees:
                text += f" till minne av {' och '.join(honorees)}"
            text += ". Namnen är det närmaste vi kommer personerna själva."
            blocks.append(_block("interpreted", "människorna", text, "interpretation:people"))

    # GENERAL BACKGROUND - epoken och sederna, alltid markt som bakgrund.
    blocks.append(_block("general_background", "seden",
                         GENERAL_LIBRARY["runestone_custom"],
                         f"library:runestone_custom@{LIBRARY_VERSION}"))
    if ins.get("rune_type") in ("younger_futhark", "short_twig", "staveless"):
        blocks.append(_block("general_background", "skriften",
                             GENERAL_LIBRARY["younger_futhark"],
                             f"library:younger_futhark@{LIBRARY_VERSION}"))
    actions = (interpretation or {}).get("actions", [])
    if "prayer_offered" in actions:
        blocks.append(_block("general_background", "kristnandet",
                             GENERAL_LIBRARY["christianization"],
                             f"library:christianization@{LIBRARY_VERSION}"))
    if "bridge_built" in actions:
        blocks.append(_block("general_background", "brobygget",
                             GENERAL_LIBRARY["bridge_deed"],
                             f"library:bridge_deed@{LIBRARY_VERSION}"))
    if not ins.get("carver"):
        blocks.append(_block("general_background", "ristaren",
                             GENERAL_LIBRARY["carver_craft"],
                             f"library:carver_craft@{LIBRARY_VERSION}"))

    return {
        "blocks": blocks,
        "library_version": LIBRARY_VERSION,
        "kinds_present": sorted({b["kind"] for b in blocks}),
    }


def compose_story(context: dict, rendering: dict | None = None) -> str:
    """Komponerar blocken till en lasbar berattelse. Ordning: manniskorna
    forst (kansla), sedan det belagda om stenen, sist tidsbilden."""
    order = {"interpreted": 0, "established": 1, "general_background": 2}
    parts: list[str] = []
    if rendering and rendering.get("text_sv"):
        parts.append(rendering["text_sv"])
    for block in sorted(context["blocks"], key=lambda b: order[b["kind"]]):
        parts.append(block["text_sv"])
    return "\n\n".join(parts)
