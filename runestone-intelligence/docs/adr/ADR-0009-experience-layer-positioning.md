# ADR-0009: Upplevelselager, inte översättningsapp — Explore och nordisk datamodell

**Status:** Accepted · **Datum:** 2026-08-16

## Kontext

Marknadsbedömningen: intresset för runstenar är bevisat (Runor riktar sig
uttryckligen även till personer som står vid en sten; det finns ~2 500
runstenar i Sverige, ~7 200 registrerade inskrifter, och en befintlig
konsumentapp med karta/foton/tolkningar). Men "översätt runor" ensamt är en
smal affär. Det som bär kommersiellt är att göra runstenar till en fysisk,
interaktiv upplevelse: *"Point your camera at history. See a rune. Know
its story."* — Shazam för runstenar + berättande kulturarv.

## Beslut

### 1. Produkten är ett digitalt lager ovanpå det fysiska runarvet

Flödet är FOTA → IDENTIFIERA → BERÄTTA (inte FOTA → LÄS VARJE RUNA →
GISSA; ADR-0008). Berättelsen levereras i nivåer: kontext ("För ungefär
1 000 år sedan stod några människor här"), mänsklig betydelse (L3), och
"VAD STÅR DET EGENTLIGEN?" (L1/vetenskaplig läsning) för den som vill.
Tolkning skapar känsla; fakta hittas aldrig på (STYLE_SPEC-förbuden).

### 2. Explore är en kärnfunktion, inte en extrafunktion

Efter varje identifierad sten: **NÄSTA RUNSTEN → 1,4 km** med tid till
fots/med bil, och senare **RUNESTONE TRAIL** (N stenar · X km · ca Y h).
Det gör produkten till en historisk upptäcktsapp och skapar
runstensjakten — samt öppnar för museer, kommuner, turistorganisationer
och skolor. Motorn bor i `atlas/explore.py` och drivs av samma
geodata som identifieringen.

### 3. Datamodellen är nordisk-generisk från början

Objektet är `RunicInscription`/sten — aldrig "SwedishRunestone". Fälten
`country`, `region`, `municipality`, `rune_type`, `runic_tradition`,
`language`, `dating` gör att Sverige → Norge/Danmark/Island/Finland →
äldre futhark/futhorc är datautvidgningar, inte ombyggen. Flerspråkiga
tolkningar (sv/en/de/fr/ja) är L3-varianter i samma kontrakt.

### 4. Databasen byggs först — MVP:t mäter WOW

Strategiskt beslut: bygg RUNESTONE MASTER DATABASE (identitet, position,
bilder + fingerprints, inskrift, tolkningar, personer, källor) före UI och
betalning. Corpus-luckorna mäts maskinellt (`ingestion/coverage_report.py`)
mot de sex frågorna: identifierbara inskrifter, lagliga bilder,
koordinater, etablerade läsningar/översättningar, bildmatchningsbara
objekt, datagap.

MVP: 10–20 välkända stenar. Framgångsmåttet är INTE "tycker du om appen?"
utan: **fotograferar personen en andra sten?** Ingen betalmodell före
bevisat WOW.

### 5. Unverified → verified-kedjan gäller även produktupplevelsen

Skillnaden mellan "detta är den etablerade läsningen" (källförankrad) och
"systemet tror att stenen säger detta" (UNVERIFIED kandidat) ska alltid
vara synlig för användaren. Nya kandidatposter uppgraderas via
verifieringstrappan (ADR-0007) — aldrig automatiskt.

## Konsekvenser

- `atlas/explore.py` med nearby/trail blir del av kärn-API:et.
- Coverage-rapporten blir styrdokument för datainsamlingen (Sprint 1–2).
- Positioneringstexten i produkt/README ändras från "runläsare" till
  upplevelselager; den tekniska kärnan (identifiering + corpus) är oförändrad.
- Datamoaten formuleras som kopplingen fysisk sten → bilder → position →
  inskrift → källor → personer → tolkningar → moderna berättelser.
