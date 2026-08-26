# IMPLEMENTATION LOG — Master Control Prompt

Kronologisk logg över faktiskt genomförda förändringar under masterprompt-
uppdraget. Varje post: datum · fas · arbetsström · vad · filer · tester ·
status. Detta är ett driftdokument, inte marknadsföring.

Arbetsströmmar (§28): 1 Core product · 2 Discovery/matching ·
3 Application preparation · 4 Grant data/editorial · 5 Payments/entitlements ·
6 Security/privacy · 7 SEO/content · 8 Analytics/conversion ·
9 Competitor intelligence · 10 Operations/support.

---

## 2026-08-25 — FAS 0: Fullständig nulägesrevision

- **Ström:** 1, 10
- **Vad:** Inventerade repo, routes (~91 API-registreringar / 51 openapi-
  operationer, 21 web-routes, 77 statiska SEO-sidor), datamodell (37 tabeller),
  auth, betalning, SEO-rendering. Körde testsviterna.
- **Bevis:** core 100/100, api 211/211, verify 15/15.
- **Filer:** `docs/CURRENT_STATE_AUDIT.md` (ny), `docs/OPEN_RISKS.md` (ny),
  `docs/CONTROL_REPORT.md` (ny), detta dokument (nytt).
- **Databas:** inga ändringar (endast revision).
- **API:** inga ändringar.
- **Status:** PASS. Baslinje etablerad. Inga P0-kodblockerare; externa
  blockerare (Swish-cert, GSC) dokumenterade. Nästa: FAS 1 (sökandekontext-
  ingång + fritext-discovery, doktrin-vaktat).

## 2026-08-26 — FAS 1 (del 1): hybrid sökandekontext-ingång + enskild firma-dubbelkontext

- **Ström:** 1, 2
- **Beslut:** Användarval — hybrid (AskUserQuestion): lätt sökandekontext
  ("Vem gäller det?") FÖRE situationsdialogen, utan att bryta situations-först-
  doktrinen. (§10.1 vs PRODUCT_DOCTRINE §2 löst.)
- **Vad:** Nytt steg 0 `who` i `apps/web/src/pages/Onboarding.tsx`: Mig själv /
  Mitt företag / Min enskilda firma / En förening. "Mig själv" → dagens
  situations-tvåval oförändrat (doktrinankarna kvar). Företag/förening → sätter
  track+applicantType, hoppar till "Vad vill du åstadkomma?" (skippar pr-who).
  Enskild firma → dubbelkontext: personspåret + förifyllt self_employed/
  sole_trader; p-age → p-biz-sector (skippar p-employment/p-biz-form).
- **Filer:** `apps/web/src/pages/Onboarding.tsx` (Answers.audience, StepId 'who',
  nextStep who/p-age/pr-intent, Step 'who'-render, initial+reset 'who',
  progress). UI-harness: `tools/uicheck/uicheck1,9,11,12,13.mjs` (Mig själv-
  brygga efter "Kom igång" — annars stannar de på nya steg 0); ny
  `tools/uicheck/faas1-who.mjs` (E2E-bevis).
- **Databas/API/miljö:** inga ändringar (rent frontend + intag).
- **Tester:** typecheck rent (core+api+web); `tools/doctrine.mjs` PASS (A/B/C);
  `npm run verify` 15/15; `npm run verify:ui` (uicheck12+13) KLAR; `faas1-who`
  KLAR (mobil 420px). Skärmbilder: artifacts/faas1-01 ("Vem gäller det?"),
  artifacts/faas1-02 (enskild firma → verksamhetens sektor, skip bevisat).
- **Status:** PASS. Kvar i FAS 1: P1-b fritext-discovery (kräver
  ANTHROPIC_API_KEY) + demons intagsparitet (LOW, marknadsartefakt).
- **Rollback:** `git revert` av FAS 1-committen; onboarding återgår till
  situations-tvåval som steg 0.

## 2026-08-26 — Doktrinkorrigering: Open Discovery (betalmodellen vänds)

- **Ström:** 1, 7
- **Beslut:** Produktägaren (masterkorrigering): bort med betalvägg-före-
  resultat som huvudmodell → **Open Discovery** (gratis att upptäcka; betalt att
  genomföra/bevaka/administrera). Auktoriserad; sekvenseras fasvis.
- **Vad (denna commit — doc/intent only):** `docs/PRODUCT_DOCTRINE.md` omskriven
  till v2 (7 bindande principer, gratis/betalt-gränsen, per-bidrag-kvalificering,
  bidragsinkorg, hårda kontrollkriterier, Search vs Product Surface,
  migreringsstatus §12). `docs/SEO_SEARCH_SURFACE.md` ny (Master SEO Expansion:
  intent graph, search_language, sex efterfrågelager, quality gate, entity-ID,
  freshness, changelog, question graph, AI-sök). `OPEN_RISKS` R9/R10.
- **Databas/API/kod:** inga ändringar ännu. `tools/doctrine.mjs` check C
  OFÖRÄNDRAD (speglar fortfarande den byggda teasern) — revideras i paywall-
  removal-fasen så doc+check+kod ändras ihop.
- **Öppet beslut (BLOCKER):** R9 personnummer — ej byggt, avvaktar produktägaren.
- **Status:** PASS (doc/intent). Nästa faser: (P) paywall-removal → Open
  Discovery i Matches/payments; (Q) per-bidrag-kvalificering; (R) bevakningslager;
  (S) SEO search surface. Verify 15/15.
- **Rollback:** `git revert` av denna commit återställer doktrin v1.

## 2026-08-26 — Open Discovery i kod (betalvägg framför resultat borttagen)

- **Ström:** 1 (Core product), 5 (Payments/entitlements)
- **Beslut:** Produktägaren (AskUserQuestion): "Matchningar gratis nu" + "Ja,
  inför personnummer". Denna post = matchningar gratis (personnummer = egen fas).
- **Vad:** API matches alltid fulla/gratis; analysis-unlock/unlock-status/
  isProjectUnlocked pensionerade; funding-stack av-gatead. Webb + demo: teaser/
  paywall borttagna. doctrine.mjs check C flippad (Open Discovery-vakt). Tester
  omriktade till 19 kr-maskineriet (moms 19,00 = 15,20 + 3,80). uicheck12/13 +
  alla 7 demokontroller omskrivna.
- **Filer:** apps/api/src/routes/{projects,payments}.ts; apps/web/src/pages/
  Matches.tsx; demo/main.tsx + demo/checks/*.mjs; tools/doctrine.mjs;
  tools/uicheck/uicheck12,13.mjs; apps/api/test/{payments,swish,adversarial,
  documentStudio,gdpr,helpers}; docs (PRODUCT_DOCTRINE §12, README, CLAUDE,
  MANUAL, openapi, OPEN_RISKS).
- **Databas:** ingen migrering (schema kind-enum behåller 'analysis_unlock' för
  historiska rader; inga nya inserts använder den).
- **Tester:** api 207/207 · verify 15/15 · verify:ui KLAR · demo:check 7/7.
- **Status:** PASS. Commit 8b907d7, båda remotes.
- **Rollback:** `git revert 8b907d7`.
- **Nästa:** personnummer-identitet (R9/R11, DPIA/BankID) + bevakningslagret.

## 2026-08-26 — Identitetsbeslut: bara födelseår (personnummer/BankID förkastat) + M11 stängd

- **Ström:** 1 (Core product), 4 (Grant data), 6 (Security/privacy)
- **Beslut:** Produktägaren: *"Ingen bankid behövs. ingen ansökan sker från
  systemet idag. Så vi nöjer sig med födelseår så det enda som fylls i av den
  sökande är födelseår och signatur om det behövs."* → personnummer + BankID
  (R9/R11) **förkastas**; grundregel #1 (inget personnummer) står oförändrad.
- **Vad:** Enda personliga fältet i intaget = **födelseår**. Onboarding (webb) +
  demo: p-age blev ett födelseårsfält (år i [nu−120, nu]) i stället för
  åldersband; härleder exakt ålder → per-gräns-fakta `person.ageYears`,
  `age60Plus`, `age62Plus`, `age67Plus` (utöver `ageUnder29`/`age40OrYounger`/
  `age66Plus`/`ageBand`). **M11 stängd:** seedens kriterier pekar nu på rätt
  åldersgräns var för sig — `csn-sm-h2`/`csn-us-h2`/`csn-ss-h3` → 60,
  `csn-oss-h2` → 62, `pm-afs-m1` → 67; `af-ee-h3` behåller 66 (korrekt).
- **Filer:** `apps/web/src/pages/Onboarding.tsx`, `demo/main.tsx` (YearInput),
  `apps/api/src/seed/data.ts` (5 kriterier), `deploy/bootstrap.sql` +
  `seo/kunskapsgraf.json` (regen). Tester/harnesser omställda till födelseår:
  `apps/api/test/{scenarios,personalJourney}.test.ts`, `tools/simulate30.mjs`,
  `tools/gendocs.mjs`, `tools/uicheck/{uicheck1,4,11,12,13,faas1-who}.mjs`,
  `demo/checks/{check,bizcheck,backcheck,savecheck,kontocheck,vidarecheck,ctxcheck}.mjs`.
- **Databas:** ingen migrering (fakta är fria punktsökvägar); seed bumpade 5
  regelset till nya versioner; bootstrap.sql regenererad (rundtur verifierad).
- **Tester:** verify 15/15 · verify:ui KLAR (uicheck12+13) · demo:check 7/7 ·
  api-sviterna gröna (scenarios+personalJourney 28/28 riktade).
- **Status:** PASS.
- **Rollback:** `git revert` av denna commit; intaget återgår till åldersband +
  age66Plus-proxyn (återöppnar M11).
- **Nästa:** (B) ansökningskanal-revision — exakt vilka ingångar varje stöd har
  som alternativ och hur de kan tas emot.

## 2026-08-26 — Ansökningskanal-revision (Task B): ingångar per stöd + mottagning

- **Ström:** 4 (Grant data/editorial), 3 (Application preparation)
- **Beslut:** Produktägaren: *"Vi kontrollerar exakt vilka ingångar alla
  ansökningar har som alternativ, hur de kan mottas."* Eftersom ingen ansökan
  lämnas direkt från systemet idag måste varje stöd ha känd, korrekt ingång.
- **Vad:** Ny deterministisk generator `tools/appchannels.mjs` läser
  sanningsmodellen och skriver `docs/APPLICATION_CHANNELS.md`: per stöd — vilka
  ingångar (kanaltaggar: Mina sidor, e-tjänst, blankett, besök, mellanhand,
  kontakt) som alternativ, hur ansökan mottas (autentisering: e-leg 24, ingen
  inloggning 34, myndighetskonto 9, EU Login 5) och den kurerade metodtexten +
  officiell URL. Kanaltaggarna EXTRAHERAS ur den kurerade texten — inga påhittade
  kanaler. `--check`-läge (drift-vakt).
- **Fynd:** Alla 72 stöd har officiell `applicationUrl` och angiven mottagning.
  **18/72 bär ännu den generiska standardtexten** ("Ansökan görs i finansiärens
  officiella ansökningstjänst.") — URL finns men exakt ingång i klartext saknas;
  listade som prioriterad kureringskö i dokumentet.
- **Filer:** `tools/appchannels.mjs` (ny), `docs/APPLICATION_CHANNELS.md` (ny,
  byggprodukt), `docs/PRODUCT_DOCTRINE.md` §3-pekare.
- **Databas/API:** inga ändringar (ren revision ur befintliga seedfält).
- **Tester:** `appchannels.mjs --check` grönt; verify 15/15 (oförändrad — nytt
  verktyg är inte npm-skript, ingen MANUAL-reaktivitet berörd).
- **Status:** PASS.
- **Nästa (kurering):** fyll de 18 generiska metodtexterna med exakt ingång
  (kuratorsflödet) — höjer samtidigt kanaltäckningen i dokumentet automatiskt.

## 2026-08-26 — FAS SEO-2: Semantic Authority & Machine Understanding (Release A)

- **Ström:** 7 (SEO/content), 1 (Core product)
- **Beslut:** Produktägaren: gör Open Discovery-modellen maskinläsbar så att
  Google/AI/LLM:er kan dra rätt slutsatser utan gissningar. Enkel frontend, rik
  maskinläsbar struktur.
- **Vad:**
  - **Kanonisk entitetsbeskrivning** `seo/entity.json` (SV+EN, 10 påståenden,
    prismodell) som enda källa. Konsumeras av genseo, startsidan, guard, test.
  - **Structured data**: genseo Organization/WebSite + ny WebApplication med
    semantiskt sann prismodell (2 Offer: upptäckt 0 kr, förberedd ansökan 19 kr);
    startsidan (`apps/web/index.html`) fick samma JSON-LD + gratis-modellens
    title/description/OG.
  - **Answer Objects**: Snabbsvar-block + FAQPage på alla 72 bidragssidor
    ("Kostar det? Nej" / "Kan jag ansöka själv? Ja" / villkor).
  - **Flaggskeppssidor** (root, statiska): `/hitta-bidrag-gratis/` +
    `/vilka-bidrag-kan-jag-fa/` — svar → åtgärd → stödinfo, målgruppsval, FAQ.
    genseo 77→79 sidor; seocheck crawlar nu hela ytan; vercel.json undantar dem.
  - **Motsägelserevision**: rättade live-ytor som sa emot Open Discovery —
    genseo (39 kr på 72 sidor), Terms.tsx, config.ts (död `analysisPriceMinor`
    borttagen), genmanual/MANUAL (teaser/upplåsning), demo-kommentar.
  - **Kontrollgrindar (permanent regression)**: `tools/semanticguard.mjs`
    (motsägelseskanning + entitetskonsistens, i verify) och
    `tools/semantictest.mjs` (maskinförståelse: 10 kärnpåståenden offline i
    verify; `--llm`-läge för modellverifiering med ANTHROPIC_API_KEY).
  - **Docs**: `docs/SEO_SEMANTIC_AUTHORITY.md` (hela lagret + de 10 frågorna +
    deferred Release B/C).
- **Filer:** `seo/entity.json` (ny), `tools/{semanticguard,semantictest}.mjs`
  (nya), `docs/SEO_SEMANTIC_AUTHORITY.md` (ny), `tools/genseo.mjs`,
  `tools/seocheck.mjs`, `tools/genmanual.mjs`+`docs/MANUAL.md`, `vercel.json`,
  `apps/web/index.html`, `apps/web/src/pages/Terms.tsx`, `apps/api/src/config.ts`,
  `demo/main.tsx`, `scripts/verify.sh`.
- **Databas/API:** inga endpoints ändrade (config: död prisfält borttaget).
- **Tester:** verify 17/17 (två nya steg: semantic guard + maskinförståelse) ·
  verify:ui KLAR · demo:check 7/7. `semantictest --llm` kräver nyckel (ej i denna
  miljö) — offline-läget grönt.
- **Status:** PASS (Release A).
- **Deferred (Release B/C):** situations-SEO-familjen (`/privatperson/*`,
  `/foretag/*`), citerbara datavyer (`/aktuella-bidrag/`, `/bidragskalender/`,
  `/nya-bidrag/`), per-stöd GovernmentService-ontologi, `semantictest --llm` i CI.

## 2026-08-26 — SEO-3/4: Bidragsgrafen + Query Pages + Own the Answer (Release A)

- **Ström:** 7 (SEO/content), 2 (Discovery/matching), 4 (Grant data)
- **Beslut:** Produktägaren: SEO-sidor ska vara VYER över kunskapsgrafen, inte
  fristående artiklar; Query Pages med hård Indexability-motor mot
  kombinationsspam; "own the answer" (svar→verktyg→data→förklaring). Husregel:
  ingen påhittad sökvolym/SERP-data.
- **Vad:**
  - **Sökintentionsregister** `seo/search-intents.json` (13 intentioner, filter
    över grafen, query_variants; search_volume=null — inga påhittade siffror).
  - **Query Pages** genererade som vyer över seeden (`tools/genseo.mjs`):
    svar → CTA → levande datavy (matchande aktiva stöd) → FAQ (FAQPage) →
    honesty. Länkade från målgruppshubbarna ("Vanliga sökningar") + tillbaka.
  - **Indexability-motorn** (delad `tools/lib/intents.mjs`): INDEX (≥3 stöd) /
    NOINDEX_FOLLOW (1–2, robots noindex + utanför sitemap) / DO_NOT_GENERATE (0).
    Dom: 13 kandidater → **9 INDEX · 1 NOINDEX · 3 DO_NOT_GENERATE** (aktiviteterna
    anställa/maskiner/investering saknar kurerat stöd → ärligt vägrade).
  - **Citerbar datavy** `/bidragsstatus/` — öppna/återkommande/daterade stöd +
    per målgrupp, beräknat ur seeden (deterministiskt, CURATED_AT).
  - **seocheck** crawlar hela ytan, NOINDEX-medveten sitemap-paritet, nya
    målgruppsprefix; **vercel.json** serverar de nya rot-prefixen statiskt.
  - **Rapport** `docs/SEO_QUERY_PAGES.md` (`tools/indexability.mjs`, `--check` i
    verify) + `docs/SEO_FUNDING_GRAPH.md` (entitetsmodell, kontrollrapport §20,
    deferred).
- **Filer:** `seo/search-intents.json`, `tools/lib/intents.mjs`,
  `tools/indexability.mjs`, `docs/SEO_{FUNDING_GRAPH,QUERY_PAGES}.md` (nya);
  `tools/genseo.mjs`, `tools/seocheck.mjs`, `vercel.json`, `scripts/verify.sh`.
- **Databas/API/webbapp/demo:** inga ändringar (ren SEO/generatoryta).
- **Tester:** verify 18/18 (nytt steg: Indexability-domar i synk). SEO-ytan
  79 → 90 sidor. verify:ui/demo:check ej berörda (ingen app-/demokod ändrad).
- **Status:** PASS (Release A).
- **Deferred (Release B/C — kräver extern data/produktarbete):** situations-/
  aktivitetsnoder + kurering (öppnar DO_NOT_GENERATE-intentionerna),
  `/bidragskalender/` + `/nya-bidrag/`-feed + `/bidragsindex/` + förändrings-
  historik + proveniensgraf, SERP Intelligence + Content Gap Engine + SEO Control
  Center + opportunity queue (kräver GSC/SERP), "Why this/Why not" + "Similar
  grants" (appfunktioner), org-nr → första bidragsbild (licensierad datakälla).

## 2026-08-26 — SEO-5: SEO-kontrollplanet (MCP + cron + Postgres) — grunden

- **Ström:** 7 (SEO/content), 10 (Operations)
- **Beslut:** Produktägaren: bygg ett riktigt SEO-kontrollplan i utvecklings-
  miljön via MCP (Semrush/Ahrefs/DataForSEO/Firecrawl/Chrome DevTools/Playwright
  + GSC/GA/Ads), cron→Postgres, egen read-only seo-mcp; bygg INTE minisajt-nät —
  koncentrera auktoriteten. **Merparten är operativt/externt** (kräver köp av
  prenumerationer + koppling av Google-konton) → jag byggde den durabla in-repo-
  grunden och den lokala delen; resten är körbok.
- **Vad (in-repo, testat):**
  - **Blueprint** `docs/SEO_CONTROL_PLANE.md`: arkitekturprincipen (MCP =
    verktygsgränssnitt, cron/kö = motorn), leverantörsstacken (roller/endpoints/
    kostnader), säkerhetsposture (read-only, godkännandegrind, inga nycklar i
    repot), hela `bidragskollen-seo-mcp`-verktygskontraktet (LOKALT vs EXTERNT),
    cron-cadence, Postgres SEO-schema (migreras när pipelinen landar — inga
    spekulativa tomma tabeller), off-domain-strategin (YouTube-sökindex,
    partnerwidgets, publikt bidragsindex, öppet tekniskt lager, SAGA) med
    korsref till `docs/ZERO_COMPROMISE_GATE.md` (anti-PBN/doorway), mätetalen,
    90-dagarsupplägget, samt "byggt nu vs kräver din åtgärd".
  - **Lokal seo-mcp-kapabilitet:** `tools/seo-cannibalization.mjs`
    (content_find_cannibalization) — 89 indexerbara sidor, 0 risker.
  - **Entitetssignaler (§7):** Organization-markup fick verkliga, publikt synliga
    uppgifter — org.nr 559141-7042 + adress (från köpvillkoren) i `seo/entity.json`,
    genseo och `apps/web/index.html`. Inga påhittade `sameAs`.
  - **`.mcp.json.example`** (nyckellös mall) + `.mcp.json`/`.cursor/mcp.json`
    gitignorerade.
- **Databas/API/webbapp/demo:** inga funktionsändringar (index.html: structured
  data). Postgres-schemat dokumenterat, ej migrerat.
- **Tester:** verify 18/18. verify:ui/demo:check ej berörda (ingen app-/demokod).
- **Status:** PASS (grunden).
- **Kräver din åtgärd:** köp Semrush/Ahrefs/DataForSEO/Firecrawl; koppla GSC/GA/
  Ads; bygg de externa seo-mcp-verktygen + cron/kö + Postgres-migreringen;
  YouTube; partnerprogram; datarapporter. Jag assisterar när connectors/nycklar finns.
