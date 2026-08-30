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

> **Läsanvisning (2026-08-30):** det här avsnittet är den ursprungliga
> kandidatlistan — hypoteser, inte byggda sidor. Vad som faktiskt finns, med
> slugar och domar, står i **§3**. Kandidaterna nedan behålls som karta över
> ontologins bredd och som kö för kommande noder.

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

¹ **Blockerare — UPPDATERAD 2026-08-28 (SERP War Room):** kluster 10–12
(lönebidrag/nystartsjobb/anställa med stöd) är **stängda** — stöden är
kurerade (af-lonebidrag, af-nystartsjobb) och klusterhubben
`/bidrag/lonebidrag/` byggd; efterfrågemodellens korgmappning rättad.
Principen kvarstår för framtida noder: situationsnoder får **inte** byggas
som indexerbara sidor förrän stöden är kurerade — annars blir de tunna sidor
utan motoruppbackning (bryter SEO Release Gate). Kurering före sida.

## 3. Byggd status — situationslagret finns (2026-08-30)

Situationslagret är **byggt** och genereras av `tools/genseo.mjs` (funktionerna
`situationPage` / `situationIndexPage`) ur `seo/situationer.json` +
`tools/lib/situationer.mjs`. Namnrymden är `/situationer/<slug>/` med
katalogsidan `/situationer/`.

**Den bärande mekaniken:** en nod skriver aldrig sin egen stödlista. Noden
deklarerar en **faktaprofil** i samma faktavägar som kunskapsbasens kriterier,
och **motorn** (`packages/core`, samma kriterie-DSL som produkten kör) avgör
vilka stöd profilen för framåt. Ankarregeln är avsiktligt strängare än
"matchar filtret": inget hårt eller obligatoriskt kriterium får fallera, och
minst ett obligatoriskt/viktat kriterium måste passera — hårda kriterier
(sökandetyp, land) räknas alltså inte som träff, annars skulle noden dra in
hela målgruppshubben. Varje rad i listan bär sitt **skäl**: seedens egen
kriteriebeskrivning, inte ny copy.

Profilen får bara innehålla fakta som är **definitionsmässigt sanna** för
situationen. "Förälder med barn hemma" vet vi; "låg inkomst" vet vi inte — det
är en fråga motorn ställer, inte något sidan får anta. Frågorna sidan visar är
dessutom **ordagranna intagsfrågor ur seeden** vars kriterium faktiskt passerar
på profilen; `tools/schemacheck-seo.mjs` fäller bygget annars.

| Nod | Målgrupp | Stöd | Dom |
|---|---|---|---|
| `/situationer/foralder-med-barn-hemma/` | privatperson | 12 | INDEX |
| `/situationer/arbetslos/` | privatperson | 5 | INDEX |
| `/situationer/funktionsnedsattning-i-familjen/` | privatperson | 5 | INDEX |
| `/situationer/yrkesverksam-konstnar/` | privatperson | 5 | INDEX |
| `/situationer/ideell-forening/` | förening | 5 | INDEX |
| `/situationer/hoga-boendekostnader/` | privatperson | 4 | INDEX |
| `/situationer/studera-som-vuxen/` | privatperson | 3 | INDEX |
| `/situationer/flytta-utomlands/` | privatperson | 3 | INDEX |
| `/situationer/ny-i-sverige/` | privatperson | 2 | NOINDEX_FOLLOW |
| `/situationer/pensionar/` | privatperson | 1 | NOINDEX_FOLLOW |
| `/situationer/ekonomin-racker-inte/` | privatperson | 1 | NOINDEX_FOLLOW |
| `/situationer/nedsatt-arbetsformaga/` | privatperson | 1 | NOINDEX_FOLLOW |

Domen är samma indexerbarhetsdoktrin som Query Pages (§29,
`tools/lib/intents.mjs`): ≥3 stöd → INDEX, 1–2 → NOINDEX_FOLLOW (genereras och
länkas, står utanför sitemapen), 0 → DO_NOT_GENERATE. De fyra NOINDEX-noderna
är alltså inte misslyckanden utan **kureringssignaler**: sidan finns för
människor, tävlar inte i Google, och blir indexerbar av sig själv när fler stöd
kurerats. Ingen tunn sida publiceras.

**Nära-dubbletter fäller bygget.** Två noder som resolverar till exakt samma
stöduppsättning är samma sida med olika rubrik. Det stoppade tre kandidater
under bygget: `efter-separation` och `barn-i-skolan` gav identiskt resultat med
`foralder-med-barn-hemma` (att lägga till fakta kan bara utöka en lista, aldrig
smalna av den), och `forening-med-ungdomsverksamhet` gav identiskt resultat med
`ideell-forening`.

**Kvar av §2-ontologin, och varför:**

- **Företagsnoderna (2b)** är inte byggda. Utöver kureringsblockeraren finns
  ett nyupptäckt hinder: `project.*`-fakta kan i dag inte bära en ärlig fråga
  (`docs/PERFECTION_BACKLOG.md` M16 — sex kriterier prövar
  `project.sector eq "culture"` med olika breda frågor, från "Är projektet ett
  kulturprojekt?" till "Är projektet ett filmprojekt?"). Situationsnoder får
  därför inte byggas på `project.*` förrän frågorna är exakt lika breda som
  sina kriterier. Klusterhubbarna `/bidrag/starta-eget-bidrag/` och
  `/bidrag/lonebidrag/` täcker de två starkaste företagsintentionerna redan.
- **`ung-vuxen`** stoppades av samma klass av fynd: `person.ageUnder29` är
  överlastad — två stöd delar faktavägen men prövar 18–28 respektive 19–29
  (M15). Noden byggs när faktavägen delats.

## 4. Byggordning (haka i innehållsmotorn, bygg inte en ny pipeline)

Situationsnoderna är innehållsmotorns F0→F1-leverabler (`docs/CONTENT_ENGINE.md`:
`/situationer/`, interaktiv behörighetskontroll, bevispaket). Ordning:

1. ~~**Bygg privatpersonsnoderna** (2a)~~ — **LEVERERAT 2026-08-30**, 8 noder
   (7 INDEX + 4 NOINDEX, se §3).
2. ~~**Föreningsnoderna** (2c)~~ — **LEVERERAT**: `/situationer/ideell-forening/`.
   De två finare föreningsnoderna föll på dubblettregeln (samma stöduppsättning)
   och byggs när kunskapsbasen skiljer dem åt.
3. **Dela de överlastade faktavägarna** (`docs/PERFECTION_BACKLOG.md` M15–M16)
   — det är den enda blockeraren för `ung-vuxen` och för hela företagslagret.
4. **Företagsnoderna** (2b) i takt med kurering *och* M16.
5. Varje nod passerar SEO Release Gate (`docs/SEO_RELEASE_GATE.md`) +
   gate0/gatekeywords innan publik. Ingen tunn sida.

## 4b. Konkurrensläge (Grantigo, bekräftat 2026-08-25)

Skärmdumpsbelagd konkurrentanalys (`docs/SEO_COMPETITORS.md` §D) skärper
prioriteringen:

- **Privatpersonslagret (2a) är okontesterat.** Grantigo är B2B/B2G, kräver
  organisationsnummer och saknar helt en privatpersonsväg. Situationsnoderna i
  2a har ingen direkt kommersiell motståndare — **högsta prioritet**.
- **Föreningslagret (2c) är delvis omtvistat.** Grantigo rör in i förening/
  ungdom via MUCF/Arvsfonden i sin content-marketing, men utan situations-
  ingång. Vår finare situationsnod ("idrottsförening med ungdomsverksamhet")
  slår deras segmentsida ("Föreningar & idrott").
- **Företagslagret (2b) överlappar Grantigos kärna** (R&D/innovation/EU:
  Vinnova, Horizon, Formas, ERC, EIC). Konkurrera **inte** huvudlöst där — och
  det är ändå kurerings-blockerat (¹). Vår vinkel är plain-language *behov*
  ("anställa första", "köpa maskin", "energieffektivisera"), inte
  finansiärnamn, för den SME som inte är en innovationssökande R&D-aktör.
- **Contentmotorn är bredare än produkten.** Grantigos marknadsföring (§D3c) är
  situations-/behovsdriven över lantbruk, småprojekt, kultur, förening och barn/
  unga — men alltid i verksamhets-/projektram, aldrig privatperson. På förening/
  kultur/lantbruk möter vi alltså aktiv content; på privatperson gör vi det inte.
- **Löftes-/leverans-gapet är copy-kilen.** Grantigos content lovar "beskriv vad
  ni vill göra → se vad ni matchas med", men produkten kräver org-nr +
  adressformulär före värde. Situationssidorna ska aldrig sälja *insikten*
  (Grantigo äger den redan) — de ska bevisa *hur lite användaren behöver veta
  och göra* (ingen org-nr, inget formulär, inget projekt) innan en förklarad
  kandidatlista. Det är löftet Grantigo ger men inte håller.

## 5. Mätning

När GSC är kopplat: mät situationsnoderna mot D2/D3-frågor
(`seo/questions-tier1.json`), inte mot bidragsnamn. Framgång = sökare **utan**
bidragsnamn i frågan når en förklarad kandidatlista (produktdoktrinen §8,
testkriteriet). Baslinjeloopen: `docs/SEO_BASELINE.md`.
