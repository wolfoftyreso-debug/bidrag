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
