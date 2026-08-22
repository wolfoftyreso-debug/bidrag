# Bidragskoll SEO Discovery Sprint 01 — order, leveranser, resultat

Status: **GENOMFÖRD 2026-08-22** (första körningen). Detta dokument är både
sprintordern (uppdraget, arbetsfördelningen, acceptanskriterierna) och
resultatloggen. Nästa sprint kopierar strukturen.

## Uppdraget (ordern)

> Kartlägg de 100 viktigaste svenska bidragsintentionerna, expandera dem till
> ett verkligt query-universum, analysera Google-SERP på de 25 högst
> prioriterade klustren och leverera de första 10 Gold Standard Content
> Blueprints. Implementera ännu inte massinnehåll.

Ordningen därefter: Discovery → 25 SERP-kluster → 10 Gold Standard-sidor →
mät → förbättra → skala till 100 → därefter 300+.

## Leveranser och acceptanskriterier

| # | Leverans | Fil | Acceptanskriterium | Utfall |
|---|---|---|---|---|
| 1 | 100 huvudintentioner | `seo/intents-100.json` | 100 st; prioritet utan påhittade volymer; slots för querygenerering; entity-delen härledd ur seeden | **KLART** — 25 kluster + 10 situationer + 7 process/jämförelse + 58 entity |
| 2 | Query-universum | `tools/genqueries.mjs` → `seo/query-universum.json` | 2 000–4 000 varianter; varje variant källmärkt (verklig vs genererad); generator med `--check`; inga syntetiska felstavningar | **KLART** — 3 488 queries (343 verkliga SERP-DERIVED/INFERRED + 3 145 genererade ur 113 grammatikmönster; 417 dubbletter rensade) |
| 3 | SERP-analys 25 kluster | `seo/serp-sprint01.json` | Verkliga sökningar; endast faktiskt returnerade domäner/URL:er; feasibility-klass + motivering per kluster; metodbrasklappar | **KLART** — 73 sökningar, 558 registrerade träffar; 13 ETTA-MÖJLIG / 11 ANGRIP-RUNT / 1 MYNDIGHET-ÄGER |
| 4 | Myndigheternas gap map | `docs/SEO_GAP_MAP.md` | Per stark myndighetsyta: bäst på / försöker inte / kräver känt namn / kalkylator / fragmentering — allt SERP-belagt | **KLART** |
| 5 | 10 Gold Standard-blueprints | `docs/SEO_BLUEPRINTS_SPRINT01.md` | Per sida: målqueries, varför bättre än topp 3 (evidens), obligatoriska moduler av de 20, verktygskomponent ur core, källor, CAS-krav ≥90 | **KLART** — 10 blueprints ur ETTA-MÖJLIG-klustren |
| 6 | Erfarenhets-/originaldatamotorn | `seo/beviljade-projekt.schema.json`, `seo/erfarenheter.schema.json` | Datakontrakt klara (byggdes i CONTENT_ENGINE-passet); ingestion startar EFTER licensgenomgång (beslut §11.3) | **KONTRAKT KLARA** — data = fas F2 |
| 7 | Kunskapsgrafen v1 | `tools/genkgraf.mjs` → `seo/kunskapsgraf.json` | Genererad ur seeden+intents (aldrig handredigerad); noder stod/myndighet/målgrupp/kriterium/intent; relaterad-kanter deterministiska; `--check` | **KLART** — 250 noder, 1 273 kanter |
| 8 | Baseline | `docs/SEO_BASELINE.md` §Sprint 01 | Nollmätningen dokumenterad + exakt lista på vad som fångas vid deploy | **KLART** — pre-launch: 0 indexerade sidor (sajten ej deployad) |

## Huvudresultat: var förstaplats är realistisk (SERP-belagt)

**13 kluster ETTA-MÖJLIG** — ingen aktör äger intentionen i dag:

| Kluster | Starkaste beviset ur SERP-datan |
|---|---|
| 17 vilka bidrag kan jag få | Bästa svaret är Frälsningsarméns statiska lista; 2 av topp 4 har fel intent; ingen myndighet KAN äga frågan (spänner över flera myndigheter) — Bidragskolls hemmaplan |
| 18 bidrag barnfamilj/ensamstående | Privat kalkylator (endast bostadsbidrag) tar redan etta; ensamstående-SERP:en är undersökningens svagaste (nyhet, lagtext 1992, lånesajt, donationssida i topp 4) |
| 16 hjälp med hyran (akut) | Toppen är tre Malmö-forumtrådar; ett låneforum rankar på desperationsfrågan; ingen myndighet på akutfrågan |
| 3 försörjningsstöd | Kommunlotteri + nämnd-PDF:er; Socialstyrelsen syns inte på beloppsfrågan; nationell konsumentyta saknas |
| 2 bostadsbidrag ⇄ bostadstillägg | Ingen myndighet försöker ens jämföra; juridik-Q&A och nischsajt toppar skillnadsfrågan |
| 8 underhållsstöd/underhållsbidrag | FK frånvarande i topp 8 på sin egen produkt; ~7 utbytbara juristbyråer + små kalkylatorsajter |
| 12 anställa med stöd (väljaren) | Ingen returnerad sida jämför på riktigt; AF frånvarande/sist; en /preview/-URL rankar |
| 13 starta eget-bidrag | AF (stödets ägare) frånvarande i samtliga tre SERP:ar; toppinnehållet har sinsemellan motstridiga belopp |
| 14 glasögonbidrag barn | 21 regioner kan per definition inte göra nationella jämförelsen; vårdgivarsidor (fel målgrupp) rankar etta; optikerkedjor kapar resten |
| 6 studiemedel ⇄ omställningsstudiestöd | Irrelevanta träffar (folkhögskolepersonal, engelska, teknisk skräpfil) på väljar-frågan; CSN jämför aldrig sina egna stöd |
| 10 lönebidrag | Forumtrådar rankar etta på arbetstagarfrågan; hur-mycket toppas av opinionsartiklar |
| 21 stipendier & fonder | Samma småsajt (http, utan TLS) rankar dubbelt i samma SERP; enda starka aktören (Global Grant) har betalvägg |
| 22 föreningsbidrag | RF:s huvudsida först på plats 8 på sitt eget stöd; en föråldrad PDF från 2020 rankar tvåa; ingen räknare finns |

**11 kluster ANGRIP-RUNT** (1, 4, 5, 7, 9, 11, 15, 19, 23, 24, 25): myndigheten
äger namntermen (ofta med kalkylator i SERP: FK, PM) — vi angriper frågorna
**före** (behovsspråk: "hjälp med hyran pensionär" har noll myndigheter),
**mellan** (jämförelser/kombinationer: "studiemedel + bostadsbidrag samtidigt"
ägs av en högskolesida och SEO-bloggar) och **efter** (avslag, ändringar).

**1 kluster MYNDIGHET-ÄGER** (20 låg pension): Pensionsmyndigheten tar etta
med rätt intent på problemformuleringen, äger termen och har kalkylatorn synlig
i SERP:en. Att jaga etta där är fel resursanvändning — pensionärscaset fångas i
samlingsvyn (17) och via anhörig-/mörkertalsvinklarna.

Tre SERP-övergripande mönster (nya, belagda i denna sprint):
1. **Privata kalkylatorer slår myndigheter** även när myndigheten har eget
   verktyg (foraldrakalkylatorn.se före FK; gratiskalkyl.se före CSN/FK) —
   verktygsformatet rankar. Bidragskolls motor i webbläsaren är exakt detta.
2. **Lånesajter parasiterar på nödställda intentioner** (Advisa på
   bostadsbidrag/rättighetsfrågor, låneforum på "akut hjälp med hyran", Qred på
   "starta företag utan pengar") — att ta dessa positioner är även konsumentskydd.
3. **Myndigheterna förlorar sina egna termer till fel sidtyp**: FK:s vårtáriktade
   sidor, Boverkets handläggarhandbok, regionernas vårdgivarsidor och AF:s
   nyhetssidor rankar i stället för konsumentsidorna.

## Metodbrasklappar (gäller alla slutsatser)

Sökverktyget använder ett USA-index — ordningen kan avvika från google.se
(särskilt: AF:s/Kassakollens svaga synlighet och de finska träffarna i kluster
25 ska omverifieras). People Also Ask/featured snippets var inte observerbara
(DATA_UNAVAILABLE). Inga sökvolymer finns någonstans — prioriteringar bygger på
SERP-struktur + målgruppsatlas, och omprövas mot GSC-data efter deploy.
Positioner = returnerad ordning, inte verifierad google.se-ranking.

## Arbetsfördelning (30-personersmodellen, när teamet finns)

Sprintens moment mappar på `docs/SEO_TEAM_PLAN.md`: domängrupperna äger
kluster/blueprints inom sitt område (privatpersoner: 1–3, 7–9, 14–18, 20;
arbete/studier: 4–6, 10–13, 19; förening/kultur: 21–22; företag/miljö/jordbruk:
23–25) · data/graf-gruppen äger generatorerna (genqueries, genkgraf, ingestion
F2) · SEO/IA-gruppen äger SERP-omvalidering mot google.se + GSC · UX/verktyg
bygger blueprintarnas kalkylator-/väljarkomponenter · huvudredaktionen äger
CAS-granskningen (tröskel 90).

## Nästa steg (i ordning)

1. **Bygg blueprint-sidorna** (`docs/SEO_BLUEPRINTS_SPRINT01.md`) — först nu
   börjar innehållsproduktion, en sida i taget genom kvalitetsloopen
   (CONTENT_ENGINE §8), aldrig batch.
2. **Efter deploy**: omvalidera SERP-datan mot google.se (PAA/snippets +
   svenskt index) och starta GSC-baseline-loopen (`docs/SEO_BASELINE.md`).
3. **F2**: licensgenomgång → ingestion av beviljade projekt (schema klart).
4. **Skala 25 → 100**: intents-100 har redan nästa 75; samma SERP-metod per
   nytt kluster innan innehåll byggs.
