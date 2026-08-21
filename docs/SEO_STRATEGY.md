# SEO_STRATEGY — Bidragskoll.se:s väg till topical authority

Datum: 2026-08-21 · Bygger på: SEO_CURRENT_STATE, SEO_SERP_RESEARCH,
SEO_COMPETITORS (all SERP-data verklig, alla volymer DATA_UNAVAILABLE).

## North star

Om någon i Sverige har en fråga vars verkliga svar är ett bidrag, stöd,
ersättning eller finansiering ska Bidragskoll ha den bästa vägen från frågan
till ett korrekt och begripligt svar. Rankings är en konsekvens, inte målet.

## Positionen (SERP-belagd)

Bidragskoll är **orienteringslagret ovanpå den offentliga informationen** —
aldrig en låtsasmyndighet. Researchen visar exakt var lagret saknas:

1. Ingen aktör besvarar "vilka stöd kan JAG få" (myndigheterna räknar på ett
   stöd i taget; bästa listan ägs av Frälsningsarmén).
2. Problemformuleringarna är oägda ("hjälp med hyran": noll myndighetsträffar)
   och kapas idag delvis av lånesajter — en etisk lucka Bidragskoll fyller
   med bidrag i stället för lån.
3. Jämförelseintent är oägd av myndigheterna (AF jämför inte sina egna fyra
   anställningsstöd; CSN jämför inte sina egna studiestöd).
4. Folktermer matchar inte myndighetsnamn ("starta eget bidrag": AF syns
   inte alls). Bryggsidor folkterm→officiell term är öppen terräng.
5. Kommunalt/regionalt fragmenterade stöd (försörjningsstöd: 6 kommuner i
   topp; glasögonbidrag: 21 regionvarianter) saknar nationell ingång.

## Kannibaliseringspolicy: QUERY → INTENT → CONTENT NODE

3 000–6 000 queries blir ALDRIG 3 000–6 000 sidor. Varje query i
frågematrisen (seo/questions-*.json) bär en nod (primary target URL);
en nod äger ett helt semantiskt kluster. Måltal: 600–1 500 starka noder på
sikt, inte tiotusen tunna. Ny sida skapas bara när intent inte redan ägs av
en befintlig nod (annars: utöka noden). Vakt: seo/keywords.json +
frågematrisen är maskinläsbara och `our_target_url` är obligatorisk innan
en sida byggs.

## Opportunity Score (dokumenterad formel)

`score = 0.25·SERP_weakness + 0.20·business_relevance + 0.15·intent_fit
       + 0.15·authority_gap⁻¹ + 0.10·internal_link_value + 0.10·tool_potential
       + 0.05·freshness_opportunity`  (varje faktor 0–100)

- SERP_weakness: privata/tunna/fragmenterade toppresultat (SERP-DERIVED).
- business_relevance: närhet till produktens kärna (utredning → 39 kr → 19 kr).
- authority_gap⁻¹: lågt när en myndighet äger termen med verktyg (t.ex.
  Pensionsmyndighetens bostadstillägg), högt när SERP:en är oägd.
- OBS: search volume ingår INTE i formeln ännu — den läggs till som faktor
  när verklig volymdata finns (GSC/Keyword Planner). Tills dess prioriterar
  vi bevisad SERP-svaghet + affärsrelevans.

## Tiers

### TIER 1 (25 targets — exceptionell kvalitet före allt annat)
Entity-sidor (finns nu, genererade): fk-bostadsbidrag-barnfamiljer,
kommun-forsorjningsstod, csn-studiemedel, csn-omstallningsstudiestod,
pm-bostadstillagg, fk-underhallsstod, fk-aktivitetsersattning,
af-stod-start-naringsverksamhet, region-glasogonbidrag-barn,
kommun-bostadsanpassningsbidrag, jordbruksverket-startstod-unga,
fk-merkostnadsersattning + hubbarna (4).
Guide-/jämförelsesidor (NÄSTA byggsteg — redaktionellt innehåll, inte
autogenererat): vilka-bidrag-kan-jag-fa, hjalp-med-hyran,
bostadsbidrag-eller-bostadstillagg, studiemedel-eller-omstallningsstudiestod,
anstalla-med-stod (väljaren), lonebidrag, nystartsjobb, bidrag-arbetslos,
lag-pension-stod, stipendier-och-fonder, eu-bidrag-foretag, energistod-foretag.
Frågematris: seo/questions-tier1.json (12–18 frågor per root).

### TIER 2 (nästa 50): resterande entity-sidor med guide-utbyggnad,
problemklustren per livssituation (barnfamilj, student, nyanländ, utvandrare,
funktionsnedsättning), föreningsklustret.
### TIER 3 (nästa 100): jämförelser, process-frågor (avslag/överklagan/
utbetalning/skatt), regionala varianter DÄR stödet faktiskt varierar.
### TIER 4: completeness/authority-noder (lågvolym, hög intention).

## Innehållsregler (YMYL)

- Aldrig "du har rätt till X kr" — alltid "kan ha rätt till"/"ser ut att
  kunna omfattas"; beslutet fattas av myndigheten (redan produktspråk).
- Varje faktapåstående: källa + senast kontrollerad + ai_curated-stämpel
  tills mänsklig granskning höjt den (kuratorsflödet finns).
- Answer first: svaret i första stycket, nyans därefter. Inga fluffintros,
  ingen mallprosa över tusentals sidor, inga tomma FAQ-sektioner.
- Officiella termer används exakt (bidrag ≠ tillägg ≠ ersättning;
  lönebidragets tre lagformer) och ÖVERSÄTTS därefter till enkel svenska.

## Årtal

Evergreen-URL:er (/bidrag/bostadsbidrag-…/) med årtal i title/H1/innehåll
när intent kräver ("Bostadsbidrag 2026"). Aldrig års-URL:er, aldrig
URL-kyrkogårdar. Konkurrenten driva-eget.se:s "bidrag-att-soka-2024"-URL
med 2026-rubrik är avskräckande exempel (dokumenterat i SEO_COMPETITORS).

## Freshness

Sanningsmodellen bär redan CURATED_AT → varje sida visar "Senast
kontrollerad". Källhämtningsjobbet (source-fetch var 6:e timme) + kuratorkön
upptäcker källändringar; när en regel ändras uppdateras seeden → nästa bygge
regenererar ALLA berörda sidor + sitemap-lastmod automatiskt. Årsversioner
(belopp per år) hanteras som seed-uppdateringar, aldrig nya URL:er.

## Mätning & loop (aktiveras efter deploy)

DATA_REQUIRED: Google Search Console (verifiera domänen direkt efter deploy),
därefter GSC-loopen: position 4–15 → förbättra; höga impressions + låg CTR →
title/description; nya queries → in i keyword-universumet; query utan sida →
gap-bedömning. KPI enligt masterdirektivet §56; baslinje i SEO_BASELINE.md.
Experiment loggas i SEO_EXPERIMENTS.md (hypotes → ändring → utfall).

## Vad som INTE görs

Inga doorway pages, ingen massproduktion där bara ortnamn byts (regionsidor
endast där stödet faktiskt varierar OCH SERP:en motiverar), ingen påhittad
FAQ-/rating-markup, inga påhittade volymer, ingen indexering av appens
inloggade vyer (robots.txt + app-routes är användarspecifika).
