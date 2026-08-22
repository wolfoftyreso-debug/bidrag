# GATE 0-RAPPORT — körning 2026-08-22

Första fullständiga körningen av Zero-Compromise Gate
(docs/ZERO_COMPROMISE_GATE.md). Expansionen är FRYST tills gaten är grön.
Detta är läget, utan försköning.

## Domen i en mening

**Gaten är INTE passerad** — tekniken, median, UX:n och den interna
länkningen är nu bevisat gröna (fynd → fix → recrawl → 0) och vaktas av kod
i verify, men **innehållsblocket är RED på bredden** (0 av 332 sökområden
når GREEN; Tier 1-destinationerna är inte byggda), trust-blocket har öppna
blockerare och mätblocket kan inte aktiveras före deploy. Offsite förblir
fryst; byggkön är 25-klusterfasen.

## Fyndliggaren (N fynd → N åtgärdade → recrawl)

| Block | Fynd | Åtgärd | Recrawl |
|---|---|---|---|
| TECHNICAL | **2 CRITICAL**: dubblett-H1 — tre stöd hette alla "Projektstöd" (Arvsfonden/Nordisk kulturfond/Postkodstiftelsen) | genseo disambiguerar kolliderande stödnamn med finansiär i H1, brödsmulor, schema och alla länkankare | **0** (seocheck + gate0 gröna) |
| TECHNICAL övrigt | 0 trasiga interna länkar · 0 orphans · 0 dubblett-titlar · 0 parameterbloat · 0 icke-kanoniska länkformer · 0 tomma sidor · sitemap 1:1 · 404 korrekt | — | 0 |
| UX | **77 fynd**: horisontell overflow 11–96 px på ALLA sidor i 320 px-vy. Tre rotorsaker: faktatabellens `white-space:nowrap` på radrubriker, CTA-knappens nowrap, obrutna käll-URL:er och långa stödnamn i länklistor | 4 CSS-fixar i genseo (fixed tabellayout + radbrytningsregler) | **0 fynd på 77 sidor × 2 vyer** (`tools/gate0-ux.mjs`; bevis-skärmdumpar i artifacts/gate0-shots/) |
| MEDIA | 0 — publika ytan har 0 `<img>` (medvetet: text + inline-SVG i appen), 30 delade tillgångar (OG/ikoner/illustrationer) inventerade, alla inom viktbudget | — | 0 |
| INTERNAL | 0 — maxdjup 2 klick, orphans 0, 0 sidor med >50 % generiska ankare; topp-10 sidor bär 47 % av intern PageRank (hubbarna — avsiktligt) | — | 0 |
| EXTERNA LÄNKAR | 80 unika myndighets-/källänkar — **UNVERIFIABLE_IN_SANDBOX** (utgående HTTP blockeras här) | nytt verktyg `npm run gate:links` körs från nätansluten maskin efter deploy | öppen tills deploy |

**Summa denna körning: 79 fynd → 79 åtgärdade → recrawl → 0 CRITICAL · 0 HIGH.**
Vakterna är nu permanenta: `gate0 --allow-content-red`, `gatekeywords --check`
och seocheck körs i varje verify — en regression fäller bygget.

## Block A — 332 rötter mot faktisk SERP

45 färska sökningar 2026-08-22 (`seo/serp-gate0.json`; USA-index-brasklappen
gäller) + Sprint 01:s 73. Registret `seo/gate0-keywords.json`:

> **GREEN 0 · YELLOW 120 · RED 120 · GREY 92** (av 332)

- **0 GREEN är den ärliga siffran.** Sajten är inte deployad — vi finns
  inte i någon SERP — och ingen destination når "exceptionell" förrän
  gold standard-modulerna finns. GREEN kan dessutom aldrig sättas av kod.
- **120 YELLOW** = entity-sidor och hubbar som finns och är faktakorrekta
  (belopp, källa, kontrolldatum, ansökningsväg) men har 11/18 moduler och
  ~438 ord median — "bra men inte tillräckligt".
- **120 RED** = guiderna/verktygen som inte är byggda (B1–B10, situations-
  manualerna, kalkylatorn, kalendern) plus kluster 10–12 där stöden saknas
  i kunskapsbasen, plus brand (C4).
- **92 GREY** = navigationsterm som myndigheten ska äga eller angränsande
  term (barnbidrag, a-kassa, skatteavdrag) — vår roll är komplementär.

### Vad SERP-omverifieringen faktiskt visade (urval, allt i serp-gate0.json)

- **Utsatta människors frågor ägs av fel aktörer**: sms-lånesajter rankar på
  "fonder att söka pengar ur" och "bidrag ensamstående mamma" (där ett
  familjeforum är etta); Kronofogden och hyresvärdsjuridik äger "kan inte
  betala hyran"; låneförmedlare rankar på "vilka bidrag har jag rätt till".
- **Verktygsformatet slår myndigheten**: homespotter.se och
  foraldrakalkylatorn.se rankar FÖRE Försäkringskassans egen kalkyl på
  "räkna ut bostadsbidrag"; banker äger "studiemedel hur mycket"; CSN är
  5:a på sin egen term "csn fribelopp".
- **Jämförelserna är oägda**: "underhållsstöd eller underhållsbidrag" ägs
  helt av advokatbyråer (FK frånvarande); "studiemedel eller
  omställningsstudiestöd" saknar riktig jämförelsesida; "a-kassa eller
  försörjningsstöd" likaså. B4/B6/B7-blueprintarna träffar öppna fält.
- **Ingen nationell bidragskalender existerar** — bara per-myndighet
  (MUCF, Skolverket). Länkmagneten Bidragskalendern har fritt fält, och
  seedens opensAt/closesAt är datagrunden.
- **AF rankar inte på "starta eget bidrag"** — bokförings- och lånesajter
  äger folktermen för myndighetens eget stöd.
- Kuriosa som visar SERP-kvaliteten: finska myndigheter rankar i två svenska
  stödfrågor; en 24 år gammal PDF rankar på "projektbudget bidragsansökan".
- **Verifierade regeländringar med förklaringsbehov** (kureringsunderlag,
  inte publicerat innehåll än): sanktionsavgift + bidragsspärr 1 juli 2026,
  aktivitetskrav i försörjningsstödet 1 juli 2026, bidragstak 1 jan 2027,
  bostadsbidragets årsinkomstberäkning, grönt avdrag 15 % + slopad
  60-öring, Ladda bilen-föransökan från 1 feb 2026.

## Kvarstående blockerare (ägare)

1. **CONTENT-RED — byggkön** (nästa fas, oförändrad ordning): kurera
   kluster 10–12-stöden → F0 (interaktiv behörighetskontroll,
   ändringshistorik, `/situationer/`) → B1–B10 → pre-check +
   QSDR/ARR-events → belastningstest. Först därefter kan rötter bli GREEN
   via mänsklig sida-mot-sida-jämförelse.
2. **TRUST**: Trust Center-sidorna (H2), namngiven granskare (H5) — H5
   kräver användaren.
3. **MEASUREMENT + extern länkhälsa + brand-SERP**: kräver deployn (C5,
   användaren) — därefter GSC, baseline, `npm run gate:links`.
4. Google Fonts render-block (M1) står kvar som accepterat avsteg tills
   CWV-fältdata finns.

## Offsite-status

FRYST enligt §3 i gaten. Inga domänköp, ingen outreach, inga satelliter.
Outbound authority är redan på plats (80 källänkar). Nästa masterprompt
när gaten är grön: **AUTHORITY & DISTRIBUTION** (1 000-domänskartan).
