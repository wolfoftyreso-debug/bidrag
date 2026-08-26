# SEO SEARCH SURFACE — sökytedominans, intent graph, entity authority, AI-sök

Styrdokument (Master SEO Expansion, 2026-08-26). Kompletterar
`docs/SEO_STRATEGY.md`, `docs/SEO_SITUATION_ONTOLOGY.md`,
`docs/SEO_INFORMATION_ARCHITECTURE.md`, `docs/SEO_INTERNAL_LINKING.md`,
`docs/SEO_RELEASE_GATE.md`. Målet är inte "skriva mycket SEO-innehåll" utan
Sveriges mest kompletta, strukturerade och **konkreta** digitala representation
av bidrag/stöd/finansiering. Bunden av produktdoktrinen §9 (Search Surface ≠
Product Surface).

## 1. Grundmodell: två skilda ytor

- **Search Surface** — stor, publik, indexerbar; leder mot "Kontrollera om detta
  gäller dig". Får vara enorm, men konkret (viktigast först).
- **Product Surface** — minimal personlig produkt. SEO-innehåll får ALDRIG
  sippra in i produkten.

## 2. Intent graph (inte bara keyword-lista)

Modellera `person → situation → need → action → support type → program → call →
provider → eligibility → application`. Varje nod = entity + databaspost + SEO-
topic + filter + internlänkmål + matchningsattribut. **SEO-ontologin och
produktens matchningsontologi använder samma begreppsmodell** (`seo/kunskapsgraf.json`
+ core-matchning).

## 3. `search_language` per koncept

Varje koncept ska ha: officiellt namn · vardagligt namn · synonymer ·
problemformuleringar · frågor · felstavningar · äldre namn · akronymer ·
myndighetstermer · branschtermer. Datakontrakt finns delvis
(`seo/search-language-grammar.json`, `seo/terminologi.json`) — utökas per stöd.
Användaren ska aldrig behöva myndighetens vokabulär.

## 4. Sex efterfrågelager (alla ska täckas)

A Explicit bidragssökning · B Målgrupp · C **Situation** (strategisk vallgrav) ·
D Känt stöd · E Behörighetsfrågor · F Genomförande. Kartläggning i
`seo/intents-100.json`, `seo/questions-tier1.json`; situationslagret i
`docs/SEO_SITUATION_ONTOLOGY.md`.

## 5. Situation-first som vallgrav

Commodity-SEO (företagsbidrag, Vinnova, EU-bidrag) räcker inte. Bygg
**Situation-entiteter** (företag: ska anställa första/långtidsarbetslös/ung, ska
investera i maskiner, energieffektivisera, exportera, digitalisera, etablera på
landsbygd; privatperson: fått barn, separerat, blivit arbetslös/sjukskriven,
lägre inkomst, ökade boendekostnader, vårdar närstående, startar företag). Varje
situation → flera potentiella stöd.

## 6. Combination pages + kvalitetsgrind

Kombinationssidor (`/foretag/investera/maskiner/`, `/privatperson/ensamstaende/barn/`)
endast där värdet är verkligt. **Aldrig** person×situation×kommun×ålder×stöd i
miljontals sidor. En URL indexeras bara om den klarar `indexability_score`.

## 7. SEO Quality Gate (`indexability_score`)

Komponenter: antal relevanta aktuella stöd · unik strukturerad information ·
officiella källor · unik sökintention · verklig efterfrågan · skillnad mot
närmaste sida · internlänkvärde · uppdateringsbarhet · användarnytta. Regler:
`relevant_grants=0` utan självständigt informationsvärde → **noindex**; skiljer
sig bara på ortnamn → noindex; dubblett → slå ihop/canonicalisera; verkligt
unikt stödlandskap → indexera. Utökar `tools/gatekeywords.mjs`/`tools/gate0.mjs`.

## 8. Programmatisk SEO = data-driven

`DATABASE FACTS → TEMPLATE/COMPOSITION → HUMAN-READABLE PAGE`. Aldrig
`KEYWORD → LLM → ARTICLE`. AI får formulera språk, aldrig vara informationskällan.

## 9. Entity pages + permanenta ID:n

- Varje stöd har en **permanent canonical URL** (`/bidrag/bostadsbidrag/`), inte
  `-2026`-varianter per år. Historik = regel-/utlysningsversioner (`ruleVersions`,
  `sourceSnapshots`). Entity authority ackumuleras på stabil URL.
- **Permanenta interna entity-ID:n** för grant/program/call/provider/authority/
  situation/need/applicant type/geography/industry. Slug får ändras; entity-ID
  aldrig. Möjliggör redirects, historik, kunskapsgraf, analys.
- Informationshierarki: ovanför fold namn + en mening + "Kan vara aktuellt för" +
  belopp + status + ansvarig + primär CTA; sedan villkor/beräkning/deadline/
  officiell ansökan; längre detaljer bakom "Visa fullständig information".

## 10. Hubbar

Myndighets-/finansiärshubbar (`/myndigheter/forsakringskassan/`,
`/finansiarer/vinnova/`): vad organisationen är · bevakade stöd · öppna/kommande/
nyligen stängda möjligheter · vanliga målgrupper · förändringar · officiell webb.
CTA: "Kontrollera vilka av dessa som kan gälla dig".

## 11. Deadline-SEO + Freshness Engine + Changelog

- `/kommande-deadlines/` + segment, genererat ur verklig data; passerad period
  uppdaterar sidan, skapar inte tunna månadsarkiv.
- Varje sida: `last_source_check`, `last_material_change`, `next_required_review`,
  `freshness_status` (fresh/review_due/potentially_stale/stale). Stale info ligger
  inte kvar som aktuell — kan noindexeras/eskaleras till review queue (`reviewItems`).
- **Changelog som SEO-asset**: "Senast ändrat …" + vad (deadline/belopp/öppnad/
  villkor). Bygger förtroende + freshness + svåimiterat värde (kräver
  bevakningsmotor).

## 12. Internlänkgraf, breadcrumbs, SERP-upplevelse

- Automatisk internlänkmotor ur ontologin med relevansgränser; ingen orphan-sida.
- Breadcrumbs följer ontologin (Hem → Privatperson → Barnfamilj → Bostad →
  Bostadsbidrag), aldrig artificiella hierarkier.
- Titles svarar på intentionen ("Bostadsbidrag – villkor, belopp och kontroll"),
  ingen clickbait; meta description konkret.

## 13. Question graph + answer blocks

Databas över verkliga frågor (Search Console, autocomplete, relaterade sökningar,
interna sökningar, användarens frågor, myndigheters FAQ) normaliserade till
intents, kopplade till strukturerade regeldata. Answer blocks besvarar viktiga
frågor direkt (människa först, ingen keyword stuffing) + CTA till kontroll.

## 14. AI-sök (AI Overviews / AI Mode)

Information ska vara lätt att förstå, extrahera, verifiera, citera: varje
faktapåstående har tydlig entity + definition + källa + datum + regelversion.
Den strukturen finns delvis (källa + senast kontrollerad + `ruleVersions`) —
utökas till fullständig citerbarhet.

## 15. Bindande krav (release gate)

Alla mandat ovan är kod i verify/CI där det går (quality gate, freshness,
internlänk, noindex). Inga påhittade sökvolymer (DATA_UNAVAILABLE tills GSC).
Ingen schema markup som antyder att Bidragskoll är en myndighet. GATE 0-frysen
för offsite gäller tills gaten är grön (`docs/ZERO_COMPROMISE_GATE.md`).

## 16. Sekvensering

Detta är ett program, inte ett pass. Byggs fasvis efter Open Discovery-pivoten
(produktdoktrinen §12) och GATE 0. Öppna beslut och blockerare: `docs/OPEN_RISKS.md`.
