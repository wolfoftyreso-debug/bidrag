# LAUNCH & DEMAND INTELLIGENCE — Bidragskoll.se

Styrdokument för den operativa lanserings- och belastningsmodellen
(masterprompt 5). Fyra spår: **efterfrågemodellen**, **ansökningsberedskapen**,
**myndighetsbelastningskartan** och **kontrollrummet**. Systemet ska inte bara
generera trafik — det ska hantera efterfrågan på riktiga stöd hos riktiga
myndigheter utan att skapa kaos, för användare eller för förvaltningen.

**Nordstjärnan:** vi optimerar för *kvalificerad tillgång till stöd*, inte för
trafik. Trafik är ett medel; måtten som räknas är QSDR och Application
Readiness Rate (§5).

## §1 Sanningsregeln för allt i detta dokument

Bidragskoll har inga fältdata före deploy. Därför:

- **Trafikvolymer är INPUT i scenarier** (10 000 / 100 000 / 1 000 000
  organiska sessioner/mån) — aldrig prognoser. Ingen siffra ur modellen får
  citeras som "förväntad trafik".
- Varje beteendeantagande är märkt `HYPOTHESIS` med motivering och
  kalibreringskälla i `seo/demand-parametrar.json`. Systemfakta avlästa ur
  kodbasen/seeden är märkta `VERIFIED`. Det som inte kan vetas är
  `DATA_UNAVAILABLE` — och lämnas synligt tomt.
- Modellens fråga är **"vad blir kritiskt VID volym X?"** — aldrig
  "vilken volym får vi?".

## §2 Spår 1 — Efterfrågemodellen

Verktyg: `node --experimental-strip-types tools/demandmodel.mjs`
(→ `artifacts/demand-model.json`; `--check` i verify kör sanity utan att
skriva). Deterministisk kedja:

1. **Scenarioinput** fördelas över de 25 bidragsklustren med vikt =
   priovikt (Sprint 01) × SERP-feasibility (ETTA-MÖJLIG/ANGRIP-RUNT/
   MYNDIGHET-ÄGER ur `seo/serp-sprint01.json`).
2. **Tratten**: session → startad genomgång → slutförd → ≥1 verifierad match
   → utgående klick till myndighet → påbörjad förberedelse. Varje steg är en
   hypotesandel som byts mot fältdata efter deploy.
3. **Routing**: klustrets utgående klick fördelas på klustrets stöd
   (kunskapsgrafens `besvaras_av`-kanter + blueprint-korgar) och aggregeras
   per myndighet, med spikmultiplikator per deadlinemodell.
4. **Teknisk last**: publika ytan är statisk (0 serverless — VERIFIED,
   arkitekturens viktigaste lanseringsegenskap); endast genomgångar driver
   API/databas. Modellen räknar topptimmens RPS och jämför mot verifierade
   gränser (rate limits) och mot `DATA_UNAVAILABLE`-tak som MÅSTE slås upp
   (Vercel-plan, Supabase-pool) när scenariot kräver det.

**Modellkörningens huvudresultat** (avläs alltid färsk körning, inte detta
dokument): det som binder först är **inte compute** — även 1 000 000
sessioner/mån ger ~13 API-RPS i topptimmen tack vare den statiska ytan.
Det som binder är (a) **kunskapsbas-gapet** i kluster 10–12 (lönebidrag,
nystartsjobb, anställa med stöd: ETTA-MÖJLIG i SERP men stöden finns inte i
kunskapsbasen — sidor där vore återvändsgränder), (b) **betalvägen**
(blockerad tills Swish-avtalet finns — ärlig 503, blockerad efterfrågan ≠
intäkt), (c) vid miljonscenariot **delade IP:n mot registreringens rate
limit** och att rate-limit-storen är in-memory per serverless-instans.

## §3 Spår 2 — Ansökningsberedskapen (Application Readiness)

Målet: användare som skickas vidare ska ha **kontrollerat grundvillkoren**
och **veta vilka underlag som behövs** — och uppenbart irrelevanta ansökningar
ska filtreras bort *innan* de belastar myndigheten. Detta byggs inte från
noll — motorn finns; spåret är att koppla den till överlämningsögonblicket:

| Beredskapssteg | Befintlig mekanism (VERIFIED i kodbasen) |
|---|---|
| Filtrera uppenbart irrelevant | Kriterie-DSL:ens hårda gates i matchmotorn + spårrelevans (`relevantForTrack`, F-RELEVANS/F-BRANSCH) — irrelevanta stöd visas aldrig |
| Inga slutsatser på obesvarat | F-HOPP-vakten: genomlysning avslutas inte med avgörande frågor obesvarade |
| Grundvillkorskontroll | Matchens kriterieutfall per stöd (uppfyllt/okänt/ej uppfyllt) visas som "kontrollera detta innan du ansöker"-lista |
| Underlagslista | `evidenceRequirements` per ansökningsschema + dokumentmallarna (`DOCUMENT_TEMPLATES`) — "det här behöver du ha framme" |
| Överlämningsgate | Den deterministiska granskningen (docs/APPLICATION-INTELLIGENCE.md): en förberedd ansökan lämnar inte systemet utan READY-status |

**Pre-check-vyn** (byggs i 25-klusterfasen): innan utgående klick visas
grundvillkoren som ja/nej/okänt ur användarens egna svar + underlagslistan.
Ingen ny sanning skapas — vyn är en projektion av match- och schemadata som
redan finns. Bedömningsspråket gäller obrutet: "ser ut att kunna" — pre-checken
är en förberedelse, aldrig ett besked.

## §4 Spår 3 — Myndighetsbelastningskartan

Egen karta: `docs/AUTHORITY_LOAD_MAP.md` — genererad insikt ur seeden
(deadlinemodeller, autentiseringsvägar, digitala ansökningsvägar per
myndighet) + modellens routade klickvolymer per scenario. Kartans etik:
Bidragskoll ska **jämna ut** mötet mellan medborgare och förvaltning, inte
skapa anstormningar — deadline-drivna myndigheter får spridda, förberedda
sökande i stället för panikvågor (pre-checken + kalendervyn är verktygen).

## §5 Måtten: QSDR och Application Readiness Rate

**QSDR — Qualified Support Discovery Rate** *(användarens definition,
ordagrant)*: "andelen användare som från en initial problemfråga landar i
minst ett verifierat relevant stöd och förstår nästa steg."

> QSDR = (sessioner med ≥1 relevant match **och** visad nästa steg-vy) /
> (sessioner som startar från problemingång)

"Förstår nästa steg" kan inte mätas direkt — proxyt är deklarerat: användaren
har nått vyn som visar konkret nästa steg (myndighet, väg, underlag) för minst
ett matchat stöd. Proxyt redovisas alltid som proxy.

**Application Readiness Rate (ARR)** *(ordagrant)*: "andelen vidarekopplade
som kontrollerat grundvillkor och vet vilka underlag som behövs."

> ARR = (utgående klick där pre-checken visats slutförd **och**
> underlagslistan visats) / (alla utgående klick)

**Instrumenteringsevents** (byggs i 25-klusterfasen; inga tredjepartsskript på
publika ytan — SEO_RELEASE_GATE:s prestandaregel gäller):

| Event | Trattposition | Mått |
|---|---|---|
| `seo_till_genomgang` | statisk sida → app | trattsteg 1 (kalibrerar hypotes) |
| `genomgang_startad` / `genomgang_slutford` | intaget | QSDR-nämnare / trattsteg 2 |
| `match_visad` (antal, stödslugs) | analys | trattsteg 3 |
| `nasta_steg_visad` (stödslug) | pre-check-vyn | QSDR-täljare |
| `grundvillkor_kontrollerade` (stödslug) | pre-check-vyn | ARR-täljare |
| `underlagslista_visad` (stödslug) | pre-check-vyn | ARR-täljare |
| `klick_ut_myndighet` (stödslug, myndighet) | överlämning | ARR-nämnare; belastningskartans fältdata |
| `forberedelse_paborjad` / `analys_upplast` | betalväg | efter Swish-aktivering |
| `fel_visat` (typ) | överallt | kontrollrummets felkurva |

Eventen är aggregerade räknare utan känsliga kategorier — RED-listan gäller
(ingen spårning kopplad till hälsa/ekonomisk utsatthet på individnivå).

## §6 Spår 4 — Kontrollrummet

Spec: `docs/LAUNCH_CONTROL_ROOM.md` (utökar QUALITY_DASHBOARD_SPEC med
lanseringspanelerna: ranking, trafik, tratt, utgående klick per myndighet,
fel, källändringar, spiklarm). Kontrollrummet läser samma event som §5 —
inga nya sanningskällor.

## §7 Kalibreringsloopen (efter deploy)

1. GSC + events ger fältdata per kluster och trattsteg.
2. Varje `HYPOTHESIS` i `seo/demand-parametrar.json` byts mot uppmätt värde
   (statusbyte till `MEASURED` + källa + period) — modellen körs om och
   scenarierna blir kalibrerade i stället för hypotetiska.
3. Avvikelse hypotes↔fält dokumenteras (inte tystas) — det är modellens
   lärande, och kontrollrummet visar diffen.

## §8 Nästa fas (användarens beställning)

De första **25 bidragsklustren byggs färdiga från sökfråga till
myndighetsöverlämning** (svarssida → genomgång → pre-check → underlagslista →
överlämning) och **belastningstestas** (scripts/loadtest.mjs + modellens
topptimmesvolymer som testfall) — det verkliga produktbeviset. Blockerare
som modellen redan pekat ut och som ingår i fasen: kunskapsbas-gapet i
kluster 10–12 (kurera lönebidrag, nystartsjobb och anställningsstöden innan
sidorna byggs).
