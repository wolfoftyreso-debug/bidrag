# Innehållsmotorn — styrdokument för Bidragskolls kunskaps- och auktoritetssystem

Status: **DOKTRIN, FÖRSTA KODIFIERINGEN** · 2026-08-22
Detta dokument styr allt redaktionellt och SEO-drivet innehållsarbete. Det
operationaliserar produktägarens utredning ("hur Bidragskoll bygger en
innehållsmotor som kan slå myndighetssidorna") mot den faktiska kodbasen.
Evidensklasser som i övriga SEO-dokument: VERIFIED / INFERRED / HYPOTHESIS /
DATA_REQUIRED. Syskondokument: `docs/SEO_STRATEGY.md` (kanaltaktik),
`docs/SEO_AUDIENCE_ATLAS.md` (målgrupper), `docs/SEO_AUTHORITY_MAP.md` (källor),
`docs/SEO_RETENTION_STRATEGY.md` (RED-listan), `seo/` (datalagren).

## 0. Central strategi (oförhandlingsbar)

Bidragskoll ska inte överträffa myndigheten som myndighet. Bidragskoll ska
överträffa myndigheterna som **sammanhängande användarupplevelse** — allt som
händer **före, mellan och efter** myndighetssidorna. Myndigheten svarar "vad
gäller för vårt stöd"; Bidragskoll svarar: vad har hänt dig, vilka stöd kan vara
relevanta, i vilken ordning ska de kontrolleras, vilka krav uppfyller du, vad
saknas, hur görs en korrekt ansökan, vad har fungerat för liknande projekt,
vilka fel bör undvikas, vart går du nu, när behöver du återkomma.

Mätregeln: en sida publiceras inte för att den är lång, utan för att den
**vet, förklarar, jämför eller hjälper bättre** än bästa existerande sökträff.
En 3 000-ordsartikel som återberättar Försäkringskassan är sämre än källan;
1 200 ord + frågeträd + scenarier + relaterade stöd + vanliga fel +
ändringshistorik + nästa steg kan vara en bättre sökträff.

### Externa faktapåståenden — verifierade 2026-08-22

| Påstående | Status | Källa |
|---|---|---|
| Google premierar originalanalys/förstahandserfarenhet; "scaled content abuse" (massgenererade sidor utan mervärde) är spampolicy; köpta rankinglänkar är länkspam | VERIFIED | Google Search Central (people-first content, spam policies) |
| MUCF bedömer projektansökningar i tre grunder: syfte och relevans; innehåll och metoder; resultat och effekter | VERIFIED | mucf.se/bidrag/bedomning-av-ansokningar + "Så handlägger MUCF" |
| Arvsfonden: 10 000+ projekt stödda sedan 1970; sökbar projektdatabas från 2015 och framåt | VERIFIED | arvsfonden.se/projekt/alla-projekt |
| Vinnova: sökbar projektdatabas + öppna data och API | VERIFIED | vinnova.se/sok-finansiering/projekt/ + /om-oss/om-webbplatsen/oppna-data |
| Tillväxtverket: Projektbanken (nationell + EU-finansiering) och Projektkartan med geografisk fördelning, data från 2015 | VERIFIED | tillvaxtverket.se Projektbanken/Nypscentralen |
| Öppna datalagen främjar vidareutnyttjande men ger inte automatisk tillgång; sekretess/GDPR/licenser bedöms separat | VERIFIED (princip) | lag (2022:818); tillämpning per källa = DATA_REQUIRED |
| Google garanterar inte indexering/placering | VERIFIED | Google Search Central |

## 1. Realistiska förstaplatsmål per sökintention

Vi delar sökmarknaden. Myndigheten *ska* vinna navigations- och
transaktionsqueries på sina egna stöd — vi skickar användaren rätt, snabbt.
Bidragskolls förstaplatsmål ligger där ingen enskild myndighet har incitament
eller mandat:

| Intention | Mål | Strategi |
|---|---|---|
| "Försäkringskassan logga in" | Inte relevant | Skicka rätt |
| "Ansök om bostadsbidrag" | Myndigheten först | Kort vägledning + överlämning |
| "Vad är X?" | Topp 3, ibland 1 | Snabbare, begripligare förklaring |
| "Vilka bidrag kan jag få?" | **1** | Myndighetsöverskridande matchning (motorn) |
| "Bidrag för [situation]" | **1** | Situationsmanual + frågeträd |
| "Kan X kombineras med Y?" | **1** | Källbelagd kombinationsmatris |
| "Vanliga fel när man söker X" | **1** | Evidensbaserad ansökningsmanual |
| "Exempel på beviljade projekt" | **1** | Egen analyserad projektdatabas |
| "Varför avslag?" | **1** | Avslagsbibliotek + nästa steg |
| "Bidrag att söka nu" / deadlines | **1** | Aktualitets-/deadlineplattform |
| "Hur skriver man projektbudgeten?" | **1** | Mall + kontrollverktyg + exempel |

Målen är ambitioner, inte garantier (Google garanterar ingenting — VERIFIED).

## 2. Fem redaktionella doktriner — en per stödtyp

Ordet "bidrag" döljer fem olika system. En innehållsmall räcker inte.
Seedens befintliga fält (instrument, sector, criteria) bär redan klassningen.

| Doktrin | Stödtyp | Innehållsfokus | Förbjudet |
|---|---|---|---|
| **A. Regelstyrda ersättningar** (social_benefit, delar av educational_support) | Bostadsbidrag, underhållsstöd, CSN… | Behovsupptäckt, behörighetsfrågor, beräkning, scenarier, inkomständring, kombinationer, återbetalningsrisk, officiell överlämning | "Vinnande ansökan"-språk — villkoren uppfylls eller inte |
| **B. Behovsprövade stöd** | Försörjningsstöd, kommunala fonder, hjälpfonder | Vilka omständigheter bedöms, vilka underlag, hur behov dokumenteras, kommun-/givarskillnader, vad händer sen, integritet | Löften, moralisering |
| **C. Konkurrensutsatta projektbidrag** | Arvsfonden, MUCF, Vinnova, kultur, forskning | Bedömningskriterier, projektlogik, mål/aktivitet/resultat/budget-koppling, medfinansiering, tidigare beviljade, avslagsorsaker, redovisning/återkrav | "Chans att beviljas" utan statistik |
| **D. Företagsstöd/subventioner** | Anställningsstöd, investeringsstöd, regionalstöd | Storlek/bransch/geografi, stödberättigande kostnader, starttidpunkt, statsstöd/de minimis, medfinansiering, skatt, compliance | Döljande av statsstödsvillkor |
| **E. Stipendier/stiftelser** | Stipendier, mindre stiftelser | Ändamålsmatchning, ansökningstext, underlag, geografisk anknytning, deadlines, återanvändning av ansökan, hitta okända stiftelser | Fabricerade stiftelselistor |

Språkregeln över alla fem: **ansökningsberedskap, kriterietäckning,
dokumentationsgrad, identifierade frågetecken** — aldrig "chans att bli
beviljad" utan publicerad statistik, aldrig "rätt till stöd" om bedömningen är
indikativ.

## 3. De sju lagren — mappade mot kodbasen

Kärnprincipen: **samma fakta skrivs aldrig manuellt på 40 sidor.** Fakta bor i
strukturerade lager; sidor genereras/uppdateras därifrån. Detta är redan husets
arkitektur — genseo bygger 170 sidor ur seeden i dag.

| Lager | Innehåll | Status i kodbasen |
|---|---|---|
| 1. **Faktalagret** | Regler, belopp, datum, ansvarig aktör | **FINNS**: `apps/api/src/seed/` (85 stöd, 36 finansiärer, 37 källor, CURATED_AT, källänkar); källbevakning via source-fetch-jobbet |
| 2. **Bedömningslagret** | Behörighetskrav, diskvalificerande villkor, kriterier | **FINNS**: kriterie-DSL:en i `packages/core` (criteria + descriptions driver redan F-INFO-inforutorna och matchpoängen) |
| 3. **Processlagret** | Ansökan, bilagor, budget, beslut, redovisning | **FINNS delvis**: 71 ansökningsscheman + dokumentmallar + deterministisk granskning (`docs/APPLICATION-INTELLIGENCE.md`); publika processmanualer saknas |
| 4. **Erfarenhetslagret** | Beviljade projekt, avslag, intervjuer, lärdomar | **NYTT**: datakontrakt i `seo/beviljade-projekt.schema.json` + `seo/erfarenheter.schema.json` (denna körning); data = nästa fas |
| 5. **Verktygslagret** | Kalkylatorer, mallar, scorecards, jämförelser | **FINNS som motor**: core körs redan i webbläsaren (demon bundlar den) — behörighetskontroll/frågeträd/granskning kan exponeras publikt utan ny motor |
| 6. **Innehållsgrafen** | Relationer stöd↔situation↔fråga | **FINNS**: `tools/genseo.mjs` (170 sidor, länkgraf QA-crawlas), `docs/SEO_INFORMATION_ARCHITECTURE.md`, `docs/SEO_INTERNAL_LINKING.md`. Situationskanten stöd↔situation finns nu som körbar kod (`tools/lib/situationer.mjs`), inte bara som dokument; entitetskanterna som JSON-LD-graf (`docs/SCHEMA_ENGINE.md`) |
| 7. **Feedbacklagret** | GSC, användarbeteende, ändringar | **VÄNTAR PÅ DEPLOY**: `docs/SEO_BASELINE.md`-loopen; ändringsdetektering finns (source-fetch snapshot/diff) |

Konsekvens: när en källa ändras uppdateras stödsidan, situationsmanualen,
jämförelsen, kalkylatorn och FAQ-svaret **ur samma lager** — aldrig 40
handredigeringar. Varje ny innehållstyp som byggs måste ansluta till ett lager,
inte lagra egna kopior av fakta.

## 4. Innehållstyperna

| Typ | Kärna | Doktrin | Status |
|---|---|---|---|
| 4.1 Kanonisk bidragssida | Levande produktsida för kunskap: vad/vem/vem inte/belopp/datum/ansökan/underlag/efteråt/relaterat/källa/kontrolldatum/ändringar | alla | **FINNS v1** (72 entity-sidor via genseo); gap: se §5 |
| 4.2 Situationsmanualer | Utgår från problemet, inte bidragsnamnet ("nyseparerad", "hyran för hög") | A/B | **FINNS v1** (2026-08-30): 12 noder under `/situationer/` + katalogsida, genererade ur faktaprofiler som **motorn** resolverar mot seeden — listan skrivs aldrig för hand och varje rad bär sitt skäl (seedens kriteriebeskrivning). Se `docs/SEO_SITUATION_ONTOLOGY.md` §3. Gap: fler noder kräver att överlastade faktavägar delas (PERFECTION_BACKLOG M15–M16) |
| 4.3 Målgruppshandböcker | Hubbar med ordning: vanligaste situationer → relevanta stöd → kontrollordning → överlapp → nästa steg | alla | **FINNS embryo** (4 målgruppshubbar); ska bli handböcker, inte länklistor |
| 4.4 Ansökningsmanualer | Per större konkurrensutsatt program: förberedelse → kriterieläsning → logik → QA → handläggning → beslut | C/D | PLANERAD |
| 4.5 Bedömarens perspektiv | Strukturera **publicerade** kriterier: "vad måste handläggaren kunna verifiera?" (MUCF:s tre grunder = pilotfall, VERIFIED) | C | PLANERAD — motorn har redan granskningslogiken |
| 4.6 Budgetmanualer | Stödberättigande kostnader, schabloner, medfinansiering, moms, likviditet — per budgetlogik | C/D | PLANERAD — budgetmotorn i core finns |
| 4.7 Avslagsbiblioteket | Strukturerat efter grund; skiljer formell avvisning / konkurrens / budget / medelsbrist; rättbart vs. meningslöst utan förändring | B/C/D | PLANERAD — kräver erfarenhetslagret |
| 4.8 Efter-beslutet | Beslutsbrev, budgetändring, dokumentation, redovisning, återkrav, slutrapport | C/D | PLANERAD — skapar återkommande användning |
| 4.9 Jämförelse/kombination | "Nystartsjobb eller lönebidrag", "bostadsbidrag + andra ersättningar" — källbelagt, versionsstyrt | alla | PLANERAD — ingen myndighet har incitamentet |
| 4.10 Ändringsartiklar | Strukturerade förändringsobjekt: vad/när/vem/belopp/åtgärd/uppdaterade sidor/tidigare lydelse/källa | alla | PLANERAD — source-fetch-diffen är råvaran |

**Endast fyra egentliga artikeltyper** därutöver: förändringsanalys,
originalrapport, verifierad erfarenhet/fallstudie, expertförklaring.
"Sju tips"-texter publiceras bara om de bygger på verkliga data, intervjuer
eller dokumenterade mönster.

## 5. Gold standard för Tier 1-sidor (20 moduler)

Ingen Tier 1-sida publiceras utan flera av: (1) direkt svar på första skärmen,
(2) sammanfattning på enkel svenska, (3) officiell status, (4) behörighets-
kontroll, (5) diskvalificerande villkor, (6) belopp/beräkningslogik,
(7) scenarier, (8) ansökningssteg, (9) dokumentchecklista, (10) tidslinje,
(11) vanliga fel, (12) relaterade stöd, (13) jämförelser, (14) verifierade
erfarenheter, (15) beviljade exempel, (16) förändringshistorik, (17) officiell
källa, (18) namngiven granskare, (19) metodbeskrivning, (20) senast faktiskt
kontrollerad.

Nulägesgap på dagens genererade entity-sidor (INFERRED ur genseo-mallen):
1, 2, 3, 12, 17, 20 **finns**; 4–5 finns som kriterielista men inte som
interaktiv kontroll; 6–11, 13–16, 18–19 **saknas**. Modul 4/5 kan byggas ur
bedömningslagret utan nytt innehåll (motorn i webbläsaren); 16 ur
source-fetch-diffen; 18 kräver bemanningsbeslut (§10).

**Datumregel:** "senast kontrollerad" sätts ALDRIG om utan verklig kontroll.
CURATED_AT i seeden är sanningen; ett nytt datum kräver ny källäsning.

## 6. Erfarenhetsmotorn — vallgraven

Offentligt råmaterial (allt VERIFIED, se §0-tabellen): Vinnovas projektdatabas
+ API, Arvsfondens projektdatabas (2015+), Tillväxtverkets Projektbank/-karta,
Jordbruksverkets stödmottagarsökning, MUCF:s kriterier och exempel.
Myndigheterna visar projekten **var för sig** — Bidragskolls unika lager är den
**myndighetsöverskridande originalanalysen**: organisationstyper, storlekar,
målgrupper, formuleringsmönster, geografi, samarbetsformer, medfinansierings-
frekvens, växande ämnen, beviljandegrader **där de publicerats**, likhet med
användarens planerade projekt.

Datakontrakt (denna körning, schema utan data — regel 1: hitta aldrig på):

- `seo/beviljade-projekt.schema.json` — normaliserad projektpost: källa,
  källdatabas-ID, finansiär, program, år, belopp, mottagartyp, geografi,
  ämneskategori, hämtningsdatum, licens-/villkorsfält. Datasetet fylls
  **endast** ur publicerade databaser, med metod + avgränsning + analysdatum
  + antal + "vad går/går inte att slut­leda" + länk till originalen på varje
  analys­sida.
- `seo/erfarenheter.schema.json` — strukturerad erfarenhet: stöd, sökandetyp/
  storlek (aldrig onödig persondata), omgång, belopp/intervall, utfall,
  handläggningstid, kompletteringar, svåraste moment, viktigaste lärdom,
  **verifieringsnivå**.

**Evidensnivåer (obligatoriska på allt erfarenhetsinnehåll):**
- **A — officiellt verifierad**: publicerat beslut, officiell databas, statistik.
- **B — dokumentverifierad**: beslutsbrev el. underlag kontrollerat och
  avidentifierat av redaktionen.
- **C — intervjubaserad**: identifierad person, inget dokument.
- **D — obekräftad**: får generera forskningsfrågor, aldrig presenteras som
  säker kunskap.

Inget öppet forum. Erfarenheter lämnas via strukturerat formulär och granskas
redaktionellt före publicering. Juridik: öppna datalagen främjar
vidareutnyttjande men ger ingen automatisk rätt — tillgång, sekretess, GDPR,
licenser och villkor bedöms **per källa** innan ingestion byggs (DATA_REQUIRED:
licensgenomgång per databas är första steget i fas E1, §9).

## 7. Innehållsgrafen

Nodtyper (utökar dagens genseo-graf): stöd · målgrupp · problem · livshändelse
· företagsbehov · organisationstyp · myndighet · processfas · deadline ·
geografi · jämförelse · beviljat projekt · manual · mall · kalkylator ·
förändring.

Informationsarkitektur (målbild; URL-form anpassas till kodbasen och
`docs/SEO_INFORMATION_ARCHITECTURE.md` — dagens `/bidrag/` + hubbar behålls):
`/bidrag/` `/situationer/` `/for-privatpersoner/` `/for-foretag/`
`/for-foreningar/` `/manualer/` `/beviljade-projekt/` `/mallar-och-verktyg/`
`/jamforelser/` `/deadlines/` `/myndigheter/` `/andringar/`
`/rapporter-och-data/`. Sitemap delas per innehållstyp när ytan växer;
seocheck-crawlens orphan-BFS och länkgrafskontroll gäller varje ny nodtyp
(ingen sida utan crawlbar väg och naturlig ankartext).

## 8. Kvalitetsmotorn

**Upprepa kvalitetsprocessen — inte texten.** Kvalitetsloop för varje
Tier 1-sida: (1) query/intent-kontroll → (2) SERP-analys → (3) primärkälle-
review → (4) faktamodellering (in i rätt lager!) → (5) första version →
(6) originalitetskontroll mot SERP → (7) domänspecialistgranskning →
(8) juridisk/språklig kontroll → (9) internlänkning → (10) teknisk SEO →
(11) render/mobil → (12) publicering → (13) indexeringskontroll → (14) GSC-
uppföljning → (15) revidering → (16) ny faktakontroll vid förändring.
Steg 9–11 är redan deterministiska (seocheck); steg 16 triggas av
source-fetch-diffen.

**Content Authority Score (tröskel: Tier 1 ≥ 90, Tier 2 ≥ 85, övrigt
indexerbart ≥ 80; under 80 = förbättra, slå ihop eller noindex):**
faktakorrekthet/primärkällor 20 · unikt användarvärde 20 · fullständig
intentionslösning 15 · originaldata/erfarenhet 10 · expertgranskning/
transparens 10 · aktualitet/versionshantering 10 · internlänkning/semantik 5 ·
teknisk SEO/prestanda 5 · tillgänglighet/begriplighet 5.

**Författarskap och transparens** (Google-rekommendation, VERIFIED): varje
viktigt innehåll visar research/skribent/faktagranskare med relevant kompetens,
källor, hur automatisering använts, senaste kontroll, och vad som är officiell
fakta vs. analys vs. erfarenhet. "Bidragskolls redaktion" räcker inte på
Tier 1. Specialistprofiler per domän (socialförsäkring, arbetsmarknad,
företagsstöd, EU, förening, forskning, jordbruk, stiftelser, projektekonomi,
juridik/dataskydd) — **kräver bemanning, se beslut §10**.

## 9. Byggordning — bevispaketet före skalan

Ingen massproduktion. Faserna byggs i ordning, varje fas har en mätbar
utgångskontroll. (Detta ersätter "SEO Tier 1-guiderna" som separat punkt i
CLAUDE.md — guiderna ingår i F1.)

- **F0 — Fundament (kan byggas utan ny data):** modul 4/5 (interaktiv
  behörighetskontroll ur bedömningslagret) och modul 16 (ändringshistorik ur
  source-diffen) på befintliga entity-sidor; `/situationer/`-nodtypen i genseo;
  Content Authority Score som checklista i granskningsflödet.
  **Modul 4/5 LEVERERAD 2026-09-04 på de fyra klusterhubbarna**
  (`tools/precheck/`): cores riktiga kriteriemotor bundlad till
  `/assets/precheck.js` (25 kB, defer, progressiv förbättring med statisk
  frågelista som fallback), seedens intagsfrågor ordagrant + produktens
  födelseårsfråga, en fråga i taget, resultat per stöd med skäl, "ansök själv
  — gratis"-länk och beslutsraden. Vakt: `tools/precheckcheck.mjs` (verify +
  CI) + `tools/uicheck/precheckcheck-browser.mjs`. Entity-sidorna får modulen
  när klustren växer (F1). `/situationer/` levererad 2026-08-30.
- **F1 — Bevispaketet:** 25 gold-standard-kluster (kanonisk sida +
  situationsmanual + frågeguide + relaterade stöd + överlämning + länkkarta +
  ändringsbevakning) · 10 stora situationsmanualer (separation, arbetslöshet,
  varierande inkomst, studiestart, sjukdom, nytt barn, företagsstart, första
  anställningen, investering, föreningsprojekt) · 10 ansökningsmanualer ·
  5 bedömningsverktyg (grundbehörighet, ansökningsberedskap, budgetkontroll,
  dokumentkontroll, mål–aktivitet–resultat) — verktygen är tunna UI-lager på
  core-motorn.
- **F2 — Erfarenhetslagret v1:** licensgenomgång per källdatabas →
  ingestion → 100 normaliserade beviljade projekt → 10 fallstudier,
  5 temaanalyser, sökbara exempel. Originalanalys, aldrig omskrivna
  projektbeskrivningar.
- **F3 — Länkbara nationella tillgångar:** Nationell bidragskalender
  (deadlinedata finns i seeden) · Beviljade projekt-explorer · Sveriges
  bidragsrapport, första upplagan · öppna data/API (CSV/JSON/kalenderflöde) —
  aldrig köpta länkar, aldrig dolda widgetlänkar; länken tillbaka valfri,
  synlig, varumärkesbaserad.
- **F4 — Skala:** fler kluster/manualer, styrt av GSC-data (feedbacklagret),
  aldrig av ordvolym.

Organisation vid full bemanning (RECOMMENDED, användarens 30-personsmodell):
5 domängrupper à 4 (privatpersoner/sociala; arbete/studier; företag/innovation;
förening/kultur; miljö/jordbruk/regionalt) + data/graf 3 + SEO/IA 2 +
UX/verktyg 2 + digital PR 1 + huvudredaktion/juridik/QA 2. Alla grupper
arbetar med samma objekttyper och källstandard — ingen egen artikelvärld.

## 10. Förbudslistan (absolut)

Aldrig: en sida per frågevariation (6 000 varianter) · kvalitet mätt i ord ·
myndighetstext omskriven med synonymer · ogrundade "öka chansen"-tips ·
användarberättelser som bevis för juridiska regler · nytt datum utan verklig
uppdatering · köpta länkar · hundratals identiska kommun-/regionsidor
(kategorier med parameter, se authority map) · AI-publicering utan käll- och
kvalitetskontroll · indikativ bedömning kallad "rätt till stöd" · öppet forum
med okontrollerade ekonomiska råd. RED-listan i `docs/SEO_RETENTION_STRATEGY.md`
gäller ovanpå allt detta.

## 11. Beslut som krävs av produktägaren

1. **Godkänn fasordningen F0→F4** (F0 är ren utveckling och kan starta direkt;
   F1:s 25 kluster kräver prioriteringslista — förslag: utgå från
   `docs/SEO_ANSWER_CLUSTERS.md` ordnat enligt atlasens C→B→A→D).
2. **Namngivna granskare** (§8): gold standard-modul 18 kräver riktiga personer
   med redovisad kompetens. Utan det taket ligger Tier 1-score < 90.
3. **Licensgenomgång före F2**: godkänn att ingestion byggs först efter
   villkorsbedömning per databas (Vinnova API, Arvsfonden, Projektbanken, SJV).
4. **Erfarenhetsformuläret**: nivå B kräver rutin för dokumentkontroll +
   avidentifiering — bemannings- och integritetsbeslut.
5. **30-personsmodellen**: bekräfta eller skala ned; doktrinen fungerar även
   med mindre team men då förlängs faserna, inte kvaliteten.

---

*Uppdateringsregel: detta dokument ändras när doktrin ändras — inte för varje
ny sida. Verifierade påståenden i §0 dateras; äldre än 12 månader ⇒ omkontroll.*
