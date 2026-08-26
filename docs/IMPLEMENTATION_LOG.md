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
