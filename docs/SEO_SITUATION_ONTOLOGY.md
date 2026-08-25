# SEO SITUATION ONTOLOGY — sökuniversum organiserat kring situation, inte bidragsnamn

Rot: produktdoktrinen §7 (`docs/PRODUCT_DOCTRINE.md`). Vi äger namn-/
kategorisökningarna via entity-sidorna (`/bidrag/<stöd>/`), men den försvarbara
vallgraven är **lagret före** dem: användaren beskriver sig själv, inte ett
bidrag. Detta dokument definierar den ontologin och gap-mappar den mot dagens
publika yta.

**Ärlighetsregel (samma som hela seo-programmet):** inga sökvolymer anges —
`DATA_UNAVAILABLE` tills GSC/Keyword Planner kopplats in. Varje nod är märkt
`SERP-DERIVED` (nära de skördade formuleringarna i `docs/SEO_SERP_RESEARCH.md`),
`INFERRED` (rimlig svensk sökfras författad av oss) eller `HYPOTHESIS`. Vi
fabricerar aldrig belopp, regler eller efterfrågan.

Datakällor detta bygger på (bygg inte om dem): `seo/personas.json` (12
personaHYPOTESER), `seo/intents-100.json` (100 intents), `seo/questions-tier1.json`,
`seo/kunskapsgraf.json`, `docs/SEO_AUDIENCE_ATLAS.md`, `docs/SEO_ANSWER_CLUSTERS.md`.

---

## 1. De sex dimensionerna

En situationssökning kan alltid beskrivas i sex dimensioner. Ontologin
korsindexerar dem; en landningssida svarar oftast mot en **kombination**.

| # | Dimension | Fråga sökaren ställer (implicit) | Exempelvärden |
|---|---|---|---|
| D1 | **Vem** (aktör) | vem är jag? | privatperson, hushåll, egenföretagare, aktiebolag, ideell förening, kommun, region |
| D2 | **Situation/tillstånd** | var i livet/verksamheten är jag? | ensamstående förälder, sjukskriven, arbetslös, pensionär, ny i Sverige, nystartat företag, förening med ungdomsverksamhet |
| D3 | **Mål/avsikt** | vad vill jag uppnå? | få ekonomin att gå ihop, plugga som vuxen, anställa, köpa maskin, energieffektivisera, driva projekt |
| D4 | **Förändring/utlösare** | vad har hänt? | separation, arbetslöshet, sjukskrivning, flytt, barn fött, företag startat |
| D5 | **Resurs/begränsning** | vad har/saknar jag? | låg inkomst, höga boendekostnader, deltid, ingen a-kassa, litet kapital |
| D6 | **Behörighetskombination** | vilken kombination gör mig berättigad? | (låg inkomst × barn × hyresrätt) → bostadsbidrag; (AB × första anställd × långtidsarbetslös) → anställningsstöd |

Motorn arbetar internt i D6; **sökaren** uttrycker sig i D1–D5. Ontologins jobb
är att fånga D1–D5-språket och leda in i motorn som avgör D6.

## 2. Situationsnoderna (kandidat-URL:er)

Namnrymd: `/situationer/<slug>/`. Varje nod ankras till minst en persona och
till konkreta stöd som **redan finns** i kunskapsbasen (inga påhittade stöd).
Noden informerar och leder till utredningen; den avgör aldrig behörighet själv.

### 2a. Privatpersoner & hushåll (D1 = individual)

| Nod | Persona | Ankar-stöd i KB (exempel) | Källa |
|---|---|---|---|
| `/situationer/ensamstaende-foralder/` | PER-001 | bostadsbidrag barnfamiljer, underhållsstöd | SERP-DERIVED |
| `/situationer/efter-separation/` | PER-002 | underhållsstöd, bostadsbidrag, bostadstillägg | SERP-DERIVED |
| `/situationer/forsta-egna-boendet/` | PER-003 | bostadsbidrag unga (18–28) | INFERRED |
| `/situationer/plugga-som-vuxen/` | PER-004 | CSN studiemedel, omställningsstudiestöd | SERP-DERIVED |
| `/situationer/studerande-med-barn/` | PER-005 | studiemedel + tilläggsbidrag, bostadsbidrag | SERP-DERIVED |
| `/situationer/nyligen-arbetslos/` | PER-006 | a-kassa-relaterat, bostadsbidrag | INFERRED |
| `/situationer/foralder-till-barn-med-funktionsnedsattning/` | PER-007 | omvårdnadsbidrag, merkostnadsersättning | SERP-DERIVED |
| `/situationer/sjukskriven/` | PER-008 | sjukpenning-relaterat, bostadstillägg | SERP-DERIVED |
| `/situationer/pensionar-med-lag-pension/` | PER-009 | bostadstillägg | SERP-DERIVED |
| `/situationer/ny-i-sverige/` | PER-010 | etableringsersättning-relaterat, CSN | SERP-DERIVED |
| `/situationer/glasogon-till-barn/` | PER-001/007 | regionalt glasögonbidrag barn 8–19 | SERP-DERIVED |
| `/situationer/rad-till-skolans-aktiviteter/` | PER-001 | (skolutflykt/fritids — intagsfrågor finns) | INFERRED |

### 2b. Företag & egenföretagare (D1 = company)

| Nod | Persona | Ankar-stöd i KB (exempel) | Källa |
|---|---|---|---|
| `/situationer/nystartat-foretag/` | — | starta-eget-relaterat, rådgivning | INFERRED |
| `/situationer/anstalla-forsta-medarbetaren/` | PER-011 | anställningsstöd¹ | INFERRED |
| `/situationer/anstalla-langtidsarbetslos/` | PER-011 | nystartsjobb, lönebidrag¹ | SERP-DERIVED |
| `/situationer/kopa-maskin-eller-utrustning/` | — | investeringsstöd¹ | INFERRED |
| `/situationer/energieffektivisera-foretaget/` | — | energistöd¹ | INFERRED |
| `/situationer/kompetensutveckling-i-foretaget/` | — | kompetensstöd¹ | INFERRED |

### 2c. Föreningar & civilsamhälle (D1 = association)

| Nod | Persona | Ankar-stöd i KB (exempel) | Källa |
|---|---|---|---|
| `/situationer/idrottsforening-ungdomsverksamhet/` | PER-012 | LOK-stöd, MUCF-bidrag | SERP-DERIVED |
| `/situationer/forening-behover-lokal/` | PER-012 | Boverket samlingslokaler | SERP-DERIVED |
| `/situationer/forening-vill-driva-projekt/` | PER-012 | Arvsfonden, projektbidrag | INFERRED |

¹ **Blockerare (från efterfrågemodellen, `docs/LAUNCH_DEMAND_INTELLIGENCE.md`
§8 / GATE0_REPORT):** kluster 10–12 (lönebidrag/nystartsjobb/anställningsstöd,
investerings-/energistöd) saknar ännu kuraterat stöd i kunskapsbasen. Dessa
situationsnoder får **inte** byggas som indexerbara sidor förrän stöden är
kurerade — annars blir de tunna sidor utan motoruppbackning (bryter SEO Release
Gate). Kurering före sida.

## 3. Gap-map mot dagens publika yta

Dagens 77 sidor (`tools/genseo.mjs`): `/bidrag/` (1 hubb) + 4 målgruppshubbar +
72 entity-sidor + sitemap + robots. **Fördelning per lager:**

| Doktrinlager | Sidtyp idag | Antal | Täckning |
|---|---|---|---|
| Lager 2–3 (namn/kategori) | entity `/bidrag/<stöd>/` | 72 | STARK |
| Lager 1 (målgrupp, grov) | hubbar `/bidrag/<målgrupp>/` | 4 | TUNN |
| **Lager 1 (situation, fin)** | `/situationer/<slug>/` | **0** | **SAKNAS** |

**Gapet:** hela situationslagret (§2 ovan) — 12 privatpersonsnoder, 6
företagsnoder (varav 5 blockerade av kurering), 3 föreningsnoder — saknar
landningsyta. Det är precis den vallgrav doktrinen §7 pekar ut och som
GATE0_REPORT flaggar som CONTENT-RED (0 av 332 sökområden GREEN; offsite fryst
tills gaten är grön).

**Internlänkning som redan finns att haka i:** entity-sidorna routar in i
motorn (`genseo.mjs:295`). Situationsnoderna ska korslänka **nedåt** till
relevanta entity-sidor och **in** i utredningen — aldrig vara återvändsgränder.

## 4. Byggordning (haka i innehållsmotorn, bygg inte en ny pipeline)

Situationsnoderna är innehållsmotorns F0→F1-leverabler (`docs/CONTENT_ENGINE.md`:
`/situationer/`, interaktiv behörighetskontroll, bevispaket). Ordning:

1. **Avblockera** där kurering krävs (2b-noterna ¹) — kurera stöden först.
2. **Bygg de SERP-DERIVED privatpersonsnoderna** (2a) — starkast belägg, minst
   risk för tunt innehåll.
3. **Föreningsnoderna** (2c) — tydliga ankar-stöd finns redan (LOK, Boverket,
   Arvsfonden).
4. **Företagsnoderna** (2b) i takt med kurering.
5. Varje nod passerar SEO Release Gate (`docs/SEO_RELEASE_GATE.md`) +
   gate0/gatekeywords innan publik. Ingen tunn sida.

## 5. Mätning

När GSC är kopplat: mät situationsnoderna mot D2/D3-frågor
(`seo/questions-tier1.json`), inte mot bidragsnamn. Framgång = sökare **utan**
bidragsnamn i frågan når en förklarad kandidatlista (produktdoktrinen §8,
testkriteriet). Baslinjeloopen: `docs/SEO_BASELINE.md`.
