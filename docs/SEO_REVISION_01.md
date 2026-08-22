# SEO-REVISION 01 — fullständig lägesrevision av sökprogrammet

Datum: 2026-08-22 · Revisor: agentkörning med deterministisk mätning
Underlag: `tools/seoaudit.mjs` (nytt revisionsverktyg — körs om vid varje
revision, utdata i `artifacts/seo-audit.json`), `seo/serp-sprint01.json`
(73 verkliga sökningar), `seo/intents-100.json`, `seo/query-universum.json`,
färsk brand-SERP-kontroll 2026-08-22, samtliga SEO-styrdokument.
Evidensklasser som alltid: uppmätt lokalt = fakta; SERP = USA-indexbrasklapp;
rankingar/volymer/CWV-fältdata/indexering = **DATA_UNAVAILABLE tills deploy**.

---

## 0. Domen i en mening

**Fundamentet är ovanligt starkt (teknik, datalager, research) men produkten
är osynlig: sajten är inte deployad, noll sidor indexerade, och 8 av de 13
kluster där förstaplats är belagd möjlig saknar ännu en sida — allt värde
ligger uppströms om två flaskhalsar: deployn och bevispaketets sidor.**

## 1. Scorecard

| Område | Betyg | En rad |
|---|---|---|
| Teknisk on-site | **GRÖN (A–)** | 77 sidor: 0 orphans, maxdjup 2, unika titlar ≤70/desc ≤170, ren JSON-LD, 1:1-sitemap, 0 dubblettinledningar. Enda avdraget: fonterna render-blockerar (R6). |
| Innehållsdjup & moduler | **GUL (C)** | 8 av gold standard-20 moduler finns; 12 saknas helt — inkl. de som SERP-datan visar vinner (verktyg, scenarier, vanliga fel, ändringshistorik). |
| Intenttäckning | **GUL (C+)** | 74/100 intents har levande nod — men 8/13 ETTA-MÖJLIG-kluster saknar sida, 8/10 situationer saknas, 6/6 processintents saknas. |
| Auktoritet & entitet | **RÖD (E)** | "bidragskoll" ägs av annan aktörs app (Bidragskollen) och förväxlas med redovisningstermen "bidragskalkyl"; egen entitet obefintlig (ej deployad). |
| Off-site | **RÖD (E)** | 0 bakåtlänkar (naturligt: ingen sajt). Länkbara tillgångar (F3) obyggda. |
| Mätning | **RÖD — BLOCKERAD** | GSC/index/rankingar omöjliga före deploy. Baseline-loopen står redo (docs/SEO_BASELINE.md). |
| Research & datalager | **GRÖN (A)** | Unik position: 73 verkliga SERP-sökningar klassade, 100 intents, 3 488 queries, kunskapsgraf 250 noder, 10 blueprints, doktrin + kvalitetsloop. Få konkurrenter i nischen har detta. |
| Organisation & process | **GUL** | Kvalitetsloopen och CAS-gaten definierade men obemannade: namngivna granskare (modul 18) saknas — hård gate för Tier 1. |

## 2. Uppmätta fakta (seoaudit.mjs, 77 sidor)

- **Ordmängd**: median 437, min 278 (huvudhubben), max 830. Endast 1 sida
  under 300 ord. Doktrinen mäter inte kvalitet i ord — men mot topp 3-guider
  på 1 000+ ord är dagens entity-sidor *fakta-ark*, inte *svar på hela
  intentionen* (modulerna är gapet, inte texten).
- **Länkgraf**: maxdjup 2 klick från huvudhubben (1 hubb → 4 målgruppshubbar
  → 72 entity); median 8 interna länkar/sida, min 5; 0 orphans; ankartexterna
  är naturliga stödnamn (topp: målgruppshubbar + stödtitlar) — ingen
  ankartextspam, ingen "läs mer"-svans.
- **Modultäckning mot gold standard-20** (CONTENT_ENGINE §5):
  finns på alla/nästan alla sidor: direkt svar (77), ansökningsväg (77),
  officiell källa (77), senast kontrollerad (77), ärlighetsstämpel (72),
  belopp (72), relaterade stöd (72), deadline (55 — resten saknar publicerat
  datum i källan, vilket redovisas ärligt).
  **Saknas helt (12)**: interaktiv behörighetskontroll (4), diskvalificerande
  villkor som egen sektion (5), scenarier (7), dokumentchecklista (9),
  vanliga fel (11), jämförelser (13), erfarenheter (14), beviljade exempel
  (15), ändringshistorik (16), namngiven granskare (18), metodbeskrivning
  (19), separat enkel-svenska-sammanfattning (2).
- **Sidvikt**: 8–16 kB HTML — trivialt snabbt. **Men**: Bläck-designen
  införde en render-blockerande extern stylesheet (Google Fonts) på alla 77
  sidor (R6).
- **Dubblettrisk**: 0 delade inledningsstycken — varje sida har unik lead.

## 3. Täckningsrevisionen — kartan mot verkligheten

| Intenttyp | Levande nod | Saknas |
|---|---|---|
| entity | **58/58** | — |
| kluster | 14/25 | **11**, varav **8 är ETTA-MÖJLIG**: avgöraren (2), studiestödsväljaren (6), lönebidrag (10), anställningsväljaren (12), hyres-akuten (16), samlingsvyn (17), barnfamilj/ensamstående (18), fonder (21) — plus 11, 19, 23 |
| situation | 2/10 | 8 (nyseparerad, sjukskriven, nytt barn, ny i Sverige, student med barn, deltid, första anställningen, starta förening) |
| process | 0/6 | alla (budget, vanliga fel, avslag, deadlines-nu, a-kassa vs försörjningsstöd, ändringar) |
| **Totalt** | **74/100** | **26** |

Query-universum: nominellt pekar **85,8 %** (2 994/3 488) av varianterna mot
en nod som existerar — **men det är en teknisk siffra, inte en svarssiffra**:
en entity-sida *besvarar* namn-, belopp- och ansökningsintenten men inte
avslags- (486 varianter), fel-, jämförelse- eller kombinationsfamiljerna som
genererats mot samma stöd. Ärlig svarstäckning ligger väsentligt lägre och
kan först mätas mot GSC efter deploy.

**Slutsatsen skär rakt in i prioriteringen**: allt research-arbete pekade ut
13 kluster där etta är möjlig — och 8 av dem har ingen sida. Blueprints för
exakt dessa finns redan (`docs/SEO_BLUEPRINTS_SPRINT01.md`, B1–B10).

## 4. Brand- och entitetsläget (färsk SERP 2026-08-22)

Sökningen "bidragskoll" returnerar: konkurrentappen **Bidragskollen**
(GitHub-repo + Mindful Innovations) i toppen, därefter en vägg av
**"bidragskalkyl"**-resultat (företagsekonomisk term: Björn Lundén, Hogia,
Wikipedia). Två fynd:
1. Namngrannen Bidragskollen är verklig och rankar — känd sedan
   `docs/SEO_COMPETITORS.md`, nu bekräftad igen.
2. **Nytt fynd**: termförväxlingen med *bidragskalkyl* betyder att Googles
   språkförståelse idag läser "bidragskoll" delvis som ett redovisningsord.
   Entitetsbygget (Organization-schema finns redan; efter deploy: konsekvent
   namnbruk "Bidragskoll.se", om-oss-sida, sameAs-länkar, omnämnanden) är
   inte kosmetika utan nödvändig disambiguering.

## 5. Numrerade fynd, prioriterade

| # | Fynd | Allvar | Åtgärd |
|---|---|---|---|
| R1 | **Sajten är inte deployad** — 0 indexerade sidor, ingen GSC, inga CWV-fältdata; hela mätområdet blockerat | BLOCKERARE | Deployn (docs/DEPLOY-AGENT.md) är fortfarande åtgärd nr 1; direkt därefter GSC-verifiering + sitemap-insändning + google.se-omvalidering av sprint01-SERP:en |
| R2 | **8 av 13 ETTA-MÖJLIG-kluster saknar sida** — researchens hela poäng är obyggd | KRITISK | Bygg B1–B10 i blueprintordningen (B1 samlingsvyn → B2 hyres-akuten → B3 försörjningsstöd → B4 avgöraren → B5 ensamstående …), en i taget genom kvalitetsloopen |
| R3 | **12 av 20 gold standard-moduler saknas helt** — särskilt de SERP-bevisat vinnande: interaktiv behörighetskontroll (privata kalkylatorer slår myndigheter), scenarier, vanliga fel, ändringshistorik | HÖG | F0 är ren utveckling och kan börja före deploy: modul 4 ur bedömningslagret (motorn kör redan i webbläsaren), modul 16 ur source-fetch-diffen |
| R4 | **Namngivna granskare saknas** (modul 18) — CAS ≥ 90 kan inte nås; YMYL-trovärdigheten vilar idag enbart på källlänkar + ärlighetsstämpel | HÖG (beslut) | Produktägarbeslut CONTENT_ENGINE §11.2 — kan inte lösas av agenten |
| R5 | **Ärlig svarstäckning ≪ nominella 85,8 %** — avslags-/fel-/kombinationsfamiljerna (>1 000 genererade varianter) har ingen sida som besvarar dem | HÖG | Täcks av B-sidorna + processintents (budget/avslag/vanliga fel = CONTENT_ENGINE 4.6–4.7); mät verklig täckning i GSC efter deploy |
| R6 | **Render-blockerande Google Fonts på alla 77 sidor** (infört med Bläck) — preconnect + display=swap finns, men extern CSS ligger i kritiska vägen | MEDEL | Acceptera till deploy (varumärkesbeslut, fallback-stack renderar direkt); mät LCP i fält efter deploy; om CWV påverkas: självhosta fonterna som statiska filer i bygget |
| R7 | **Entitetsförväxling**: "bidragskoll" ≈ Bidragskollen (annan aktör) + bidragskalkyl (redovisningsterm) | MEDEL | Efter deploy: konsekvent "Bidragskoll.se" i titlar (görs redan), om-oss/kontakt-sidor, sameAs, och brand-SERP-bevakning i baseline-loopen |
| R8 | **0 bakåtlänkar, 0 länkbara tillgångar** | MEDEL (för tidigt) | F3 (bidragskalendern, projekt-explorern, Sveriges bidragsrapport) startar först när bevispaketet finns — rätt ordning, inget att ändra |
| R9 | Deadline-modulen saknas på 22 sidor för att källan inte publicerat datum — korrekt ärlighet, men "Nästa omgång inte publicerad ännu" kan berikas med källans senaste kända mönster när ändringsbevakningen (modul 16) byggs | LÅG | Ingår i F0/modul 16 |

**Styrkor att inte röra**: 0 orphans, djup ≤ 2, unika titlar/beskrivningar
med kollisionskaskaden, ren JSON-LD utan påhittad FAQ/rating-markup,
ärlighetsstämpeln (AI-sammanställd/ej granskad) som ingen konkurrent vågar
visa, deterministisk generering ur sanningsmodellen (kan aldrig divergera),
och QA-vakterna i verify/CI som håller allt detta sant vid varje ändring.

## 6. Var vi står — sammanfattning mot planen

```
Research/doktrin  ████████████████████  KLART (unik position)
Teknisk grund     ███████████████████░  A– (R6 kvar)
Entity-sidor v1   ██████████████░░░░░░  72/72 byggda, 8/20 moduler
Bevispaketet      ░░░░░░░░░░░░░░░░░░░░  0/10 blueprints byggda ← nästa
F0-modulerna      ░░░░░░░░░░░░░░░░░░░░  0/2 byggda (kan börja nu)
Deploy/mätning    ░░░░░░░░░░░░░░░░░░░░  BLOCKERAT på användarens deploy
Off-site/F3       ░░░░░░░░░░░░░░░░░░░░  Medvetet ej startat
```

## 7. Rekommenderad ordning härifrån

1. **F0 (kan börja omedelbart, ingen deploy krävs)**: interaktiv
   behörighetskontroll på entity-sidorna (modul 4 — motorn finns i
   webbläsaren) + ändringshistorik (modul 16 — source-diffen finns) +
   `/situationer/`-nodtypen i genseo.
2. **B1–B5** genom kvalitetsloopen (samlingsvyn, hyres-akuten,
   försörjningsstöd, avgöraren, ensamstående) — stänger 5 av de 8 obyggda
   ETTA-MÖJLIG-klustren och hela situationsgapet börjar slutas.
3. **Deployn** (användarens steg) → GSC + sitemap + google.se-omvalidering →
   baseline-loopen live. R1 löses bara här.
4. **B6–B10**, därefter F2 (licensgenomgång → beviljade projekt) och F3
   (länkbara tillgångar).
5. **Beslut som väntar på produktägaren**: namngivna granskare (R4),
   fasordningens bekräftelse (CONTENT_ENGINE §11).

## 8. DATA_UNAVAILABLE-listan (påstås inte förrän data finns)

Rankingar och positioner på google.se · sökvolymer · impressions/klick/CTR ·
query coverage i verklig mening · CWV-fältdata (LCP/INP/CLS) · indexeringsgrad
· backlink-profil · PAA/featured snippets för sprint01-klustren.

*Omkörning: `node tools/genseo.mjs && node tools/seoaudit.mjs` — nästa
revision (SEO-REVISION 02) görs efter deploy mot levande index och GSC.*
