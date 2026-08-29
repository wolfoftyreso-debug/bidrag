# CURRENT STATE AUDIT — FAS 0 (Master Control Prompt)

Revisionsdatum: 2026-08-25. Metod: källkods-, schema-, konfig- och testläsning
med bevis (fil:rad, testutdata). Inga antaganden godtas som nulägesbeskrivning.
Detta är baslinjen som alla efterföljande faser mäts mot.

**Övergripande dom: PASS (med prioriterad backlog).** Systemet är väsentligt mer
byggt än masterpromptens generiska mall antar. Produktens produktionsgrund —
auth, lösenordsåterställning, betalningsidempotens, privat lagring, migreringar,
RLS, deterministisk matchning, ansökningsförberedelse, statisk SEO-yta — finns
och är testtäckt (311 tester gröna). De genuina luckorna är produkt- och
innehållsexpansion (fritext-discovery, explicit sökandekontext-ingång,
situations-SEO-lagret) och externa blockerare (Swish-cert, GSC), inte trasig
produktionsgrund.

---

## 0. Bevisbas (denna körning)

| Kontroll | Resultat | Bevis |
|---|---|---|
| Core-tester | **100 passed (12 filer)** | `npm test -w packages/core` |
| API-tester (mot Postgres) | **211 passed (25 filer)** | `TEST_DATABASE_URL=… npm test` |
| Full verify | **15/15 PASS** (denna session, upprepat) | `npm run verify` |
| Core-bygge | OK | `npm run build -w packages/core` |

## 1. Repo- och arkitekturöversikt (§5 bindande utgångspunkt — VERIFIERAD)

| Krav i prompt | Nuläge | Bevis |
|---|---|---|
| monorepo, npm workspaces | ✓ | rot-`package.json`, `packages/`, `apps/` |
| packages/core ren domän | ✓ 15 moduler, 100 tester | `packages/core/src/*.ts` (index-barrel) |
| apps/api Fastify 5 | ✓ | `apps/api/src/server.ts`, 14 route-moduler |
| Drizzle + PostgreSQL 16 | ✓ 37 tabeller, 12 migreringar | `apps/api/src/db/schema.ts`, `apps/api/drizzle/` |
| apps/web Vite + React SPA | ✓ 18 sidor, 21 routes | `apps/web/src/pages/`, `App.tsx` |
| egen auth scrypt + roterande refresh | ✓ | `apps/api/src/auth/{password,tokens}.ts` |
| httpOnly-cookies | ✓ httpOnly + secure(prod) + SameSite=Lax | `apps/api/src/routes/auth.ts:18` |
| Vercel serverless-ingång | ✓ | `api/index.ts`, `vercel.json` |
| Supabase Postgres + privat storage | ✓ disk/supabase-driver | `apps/api/src/services/storage.ts` |
| Vercel Cron + CRON_SECRET | ✓ Bearer-skyddat | `apps/api/src/routes/internal.ts:19` |
| ingen AWS | ✓ (inget AWS-beroende funnet) | — |

Cores domänmoduler: types, criteria, matching, stateMachine, budget, schema,
stacking, deadlines, validation, documents, documentTemplates, consistency,
language, generation, relevance.

## 2. Routematris (sammanfattning)

**API:** ~91 route-registreringar över 14 moduler; `docs/openapi.json` = 42
paths / 51 operationer. Fördelning: applications 15, payments 13, admin 11,
auth 10, team 7, projects 7, documentStudio 5, profiles 4, documents 4,
correspondence 3, opportunities 2, notifications 2, internal 2, gdpr 2.
Full operationstabell genereras i `docs/MANUAL.md` (reaktiv i verify/CI).

**Web:** 21 routes (`App.tsx`). Publika: `/`(login), `/villkor`,
`/aterstall/:token`. Skyddade (bakom auth-skal): översikt, projekt, ansökningar,
kalender, sök, dokument, inkorg, admin, konto, opportunity, ansökan.

**Statisk SEO-yta:** 77 sidor genereras av `tools/genseo.mjs` (`/bidrag/` +
4 målgruppshubbar + 72 entity-sidor + sitemap + robots). Verklig HTML, ej tomt
SPA-skal — QA-crawlas av `tools/seocheck.mjs` och `tools/gate0.mjs`.

## 3. Datamodell (37 tabeller — VERIFIERAD)

tenants, users, memberships, invites, refreshTokens, generatedDocuments,
passwordResetTokens, recoveryCodes, applicantProfiles, externalIdentifiers,
projects, fundingAuthorities, fundingProgrammes, fundingOpportunities,
ruleVersions, sources, sourceSnapshots, reviewItems, matches, fundingStacks,
applicationSchemas, applicationCases, budgetLines, canonicalAnswers, documents,
caseDocuments, submissions, submissionReceipts, correspondenceEvents, decisions,
reportingRequirements, paymentMilestones, payments, receipts, notifications,
reminders, auditEvents.

Mot masterpromptens §11-önskelista: kärnentiteterna finns (profiler+fakta+
historik via applicantProfiles/canonicalAnswers/auditEvents; bidragsdata via
fundingOpportunities/ruleVersions/sources/sourceSnapshots; matchning via
matches/reviewItems; betalning via payments/receipts; ansökan via
applicationCases/applicationSchemas/budgetLines/documents/submissions).
Regelversionering (`ruleVersions`) och källsnapshots (`sourceSnapshots`) finns.
Migrering 0005 = RLS deny-all.

## 4. De tre kärnmotorerna (§3) — mognadsbedömning

| Motor | Mognad | Bevis / lucka |
|---|---|---|
| **Discovery Engine** | **PARTIAL** | Situations-först intag med dynamisk frågeordning (`Onboarding.tsx`, demo) + `freeIntent` fångas. **Lucka:** fritext-narrativ → strukturerad faktaextraktion med bekräftelse (§3.1/§12) är inte primär väg; intaget är val-baserat. |
| **Eligibility Engine** | **STARK** | Deterministisk kriterie-DSL (`criteria.ts`), `matching.ts`, `relevance.ts`, regelversioner, match-status, F-RELEVANS-vakt. Motsvarar §13 väl. |
| **Application Preparation** | **STARK** | applicationSchemas/Cases, budgetLines, canonicalAnswers, documents, submissions + deterministisk granskning (`consistency.ts`, `validation.ts`, `docs/APPLICATION-INTELLIGENCE.md`). Motsvarar §15 väl. |

## 5. Sökandekontexter (§2) — VERIFIERAD i domänen

Cores `types.ts` stödjer: individual, company, association, informal_group,
**sole_trader**, economic_association, municipality, region, public_body,
university. De fyra promptkraven (privatperson, företag, enskild firma, förening)
är alltså modellerade, inklusive enskild firma-dubbelkontexten.

**Lucka (P1):** intagets FÖRSTA val är situations-först ("Jag har svårt att få
ekonomin…" vs "Jag söker pengar till ett projekt…"), inte den explicita
fyrvägs-sökandekontexten som §10.1 föreskriver. sole_trader/company viks idag in
i projekt-grenen. (Detta är en medveten doktrinfråga — se §6 nedan.)

## 6. Doktrinkonflikt att lösa (prompt §10.1 vs PRODUCT_DOCTRINE)

Masterpromptens §10.1 vill ha **sökandekontext först** ("Vem söker du för?" →
Mig själv / Mitt företag / Min enskilda firma / En förening), därefter sekundära
ingångar (standard / behov / känd möjlighet). Vår låsta `PRODUCT_DOCTRINE.md` §2
kräver **situation först, aldrig förkunskap**. Dessa är förenliga: "vem söker du
för" är kontext, inte bidragsnamn. Rekommendation: FAS 1 inför den explicita
sökandekontexten som steg 0, med situations-ingången som primär sekundärväg —
utan att bryta doktrinens invariant (bevakas av `tools/doctrine.mjs`).

## 7. Betalning & entitlement (§14) — VERIFIERAD

- **Lösenordsåterställning finns och är härdad** (motsäger promptens antagande
  att det är en öppen P0): `request-password-reset` + `reset-password`
  (`auth.ts:159,214`), token hashas (SHA-256), 1h utgång, `usedAt` engångsbruk,
  generiskt svar, audit-event. Sessionsåterkallelse vid byte finns.
- **Swish:** adapter (`services/integrations/swish.ts`) + mock-provider
  (`paymentProviders.ts`) gatad av `config.paymentsMockEnabled` = endast när
  `NODE_ENV!=='production'` **eller** `VERCEL_ENV==='preview'`. Skarp produktion
  kan aldrig mocka. Utan avtal/cert vägrar ytan ärligt (503) — dokumenterat.
- payments/receipts/entitlement-tabeller finns; idempotens och kvitton med moms
  är byggda och testade (api-sviten).

**Extern blockerare (ej kodlucka):** Swish Handel-avtal + klientcertifikat
saknas. Exakt var det sätts: `.env` (`SWISH_*`, base64-cert) — se
`docs/ACTIVATION.md`, `.env.example`.

## 8. Säkerhet & integritet (§14/§23) — VERIFIERAD baslinje

httpOnly+secure+SameSite=Lax-cookies + `originGuard` (CSRF), CRON_SECRET-bearer,
storage server-side service-nyckel (aldrig i klient), RLS deny-all (0005),
scrypt, roterande refresh (32 slumpbyte + SHA-256), rate-limit (registrering
~10/min). Adversariell svit + red team-pass 03 körda (tasks #79–80). Kända
residualer: LIMITATIONS §13 (delad rate-limit-store i serverless), §14 (SSRF
DNS-rebinding-residual) — dokumenterade, låg exponering.

## 9. SEO-rendering (§8/§17) — VERIFIERAD

Publika sidor = förgenererad statisk HTML (ej SPA-skal). robots.txt disallowar
app-vyer (`/projekt`, `/ansokningar`, `/konto`, `/dokument`, `/admin`,
`/inkorg`); preview-sidor får `<meta robots noindex>`; app-skalet är
klient-endast och ligger utanför sitemap. **Lucka (P2/P3):** `/situationer/`-
lagret (situations-SEO) ej byggt — se `docs/SEO_SITUATION_ONTOLOGY.md`.

## 10. Dokumentkarta (prompt §8 → befintliga docs)

| Prompt efterfrågar | Finns som | Status |
|---|---|---|
| PRODUCT_DOCTRINE.md | `PRODUCT_DOCTRINE.md` | ✓ (låst, kod-vaktad) |
| CURRENT_STATE_AUDIT.md | **detta dokument** | ✓ ny |
| ARCHITECTURE.md | `ARCHITECTURE.md` | ✓ |
| DATA_MODEL.md | schema.ts + ARCHITECTURE | LUCKA (namngivet dok saknas) |
| GRANT_ONTOLOGY.md | kunskapsgraf.json + SEO_SITUATION_ONTOLOGY | PARTIAL |
| MATCHING_ENGINE.md | matching.ts + APPLICATION-INTELLIGENCE | LUCKA (namngivet) |
| APPLICATION_PREPARATION.md | `APPLICATION-INTELLIGENCE.md` | ✓ (motsvarande) |
| PAYMENTS_AND_ENTITLEMENTS.md | kod + LIMITATIONS + ACTIVATION | LUCKA (namngivet) |
| SECURITY_AND_PRIVACY.md | `SECURITY.md` + `PRIVACY.md` | ✓ |
| SEO_STRATEGY.md | `SEO_STRATEGY.md` | ✓ |
| CONTENT_QUALITY_STANDARD.md | LANGUAGE_GUIDE + CONTENT_ENGINE | PARTIAL |
| COMPETITOR_INTELLIGENCE.md | `SEO_COMPETITORS.md` (Grantigo §D) | ✓ (motsvarande) |
| ANALYTICS_AND_KPIS.md | `QUALITY_DASHBOARD_SPEC.md` | PARTIAL |
| DEPLOYMENT_RUNBOOK.md | DEPLOYMENT + OPERATIONS + DEPLOY-AGENT | ✓ |
| IMPLEMENTATION_LOG.md | `IMPLEMENTATION_LOG.md` | ✓ ny |
| CONTROL_REPORT.md | `CONTROL_REPORT.md` | ✓ ny |
| OPEN_RISKS.md | `OPEN_RISKS.md` (+ LIMITATIONS) | ✓ ny |

## 11. Prioriterad problemlista (P0–P3)

**P0 (produktion & säker grund):** Inga öppna kodblockerare funna. Auth,
lösenordsåterställning, betalningsidempotens, privata dokument, migreringar och
RLS finns och är testtäckta. Enda P0-klass som återstår är **externa
blockerare**: Swish Handel-avtal + certifikat (kod klar, väntar avtal); GSC-
anslutning (dokumenterat steg).

**P1 (produktens differentiering):**
- P1-a Explicit sökandekontext-ingång ("Vem söker du för?" 4-väg) före
  situationsingången (§10.1) — utan att bryta doktrinen.
- P1-b Fritext-discovery: narrativ → strukturerad faktaextraktion med
  bekräftelse/korrigering och konfliktmarkering (§3.1/§12). Kräver
  `ANTHROPIC_API_KEY`; utan nyckel ärlig 503 + val-baserat intag som fallback.

**P2 (ansökningsförberedelse):** Redan STARK; kvarstår: enskild firma-
dubbelkontext i intaget (schema stödjer det; UI-flödet viker in det),
readiness-komponenter som explicit lista (delvis i APPLICATION-INTELLIGENCE).

**P3 (SEO-dominans):** `/situationer/`-lagret (ontologin klar), fler
finansiärssidor, jämförelsesida Grantigo (källbelagd), GSC-loop. Offsite/social
**fryst tills GATE 0 grön** (`docs/ZERO_COMPROMISE_GATE.md`).

## 12. Antaganden i masterprompten som motbevisas

1. "Password reset är öppen P0" → **finns och är härdad** (§7 ovan).
2. "Produkten kan vara en app-first ansökningsgenerator" → intaget är redan
   situations-först, doktrin-vaktat.
3. "AWS" → projektet använder Vercel + Supabase, inget AWS.
4. "Bidrag.se splittrar auktoritet" → domänbytet till Bidragskoll.se är gjort
   (task #57); ingen aktiv innehållssplittring funnen i repot.
5. Doknamnen i §8 saknas → merparten finns under etablerade namn (§10 ovan).

## 13. Externa blockerare (exakt vad som saknas)

| Blockerare | Var det sätts | Verifierbart utan? |
|---|---|---|
| Swish Handel-avtal + klientcert | `.env` `SWISH_*` (base64) | Ja — mock i preview, ärlig 503 i prod |
| Resend API-nyckel (e-post) | `.env` `RESEND_API_KEY` | Ja — ärlig 503 utan |
| ANTHROPIC_API_KEY (fritext/språk) | `.env` | Ja — ärlig 503 + fallback |
| Search Console | GSC-verifiering efter deploy | Nej — kräver deployad domän |
| Supabase-produktionsprojekt | `.env` Supabase-trio | Delvis — bootstrap.sql lokalt |

## 14. FAS 0 kontrollgrind — status

| Krav | Status |
|---|---|
| Repoöversikt | ✓ |
| Routematris | ✓ (§2) |
| Databaskatalog | ✓ (§3, 37 tabeller) |
| Authrevision | ✓ (§7–8) |
| Betalningsrevision | ✓ (§7) |
| SEO-baseline | ✓ (§9) |
| Testresultat från nuvarande kod | ✓ (311 gröna) |
| P0–P3-lista | ✓ (§11) |
| Motbevisade antaganden | ✓ (§12) |
| Externa blockerare | ✓ (§13) |
| Ingen implementation utan baseline | ✓ |
| Mobil/desktop-skärmbilder | PARTIAL — demons intag verifierat (tidigare skärmbild); full autentiserad webbflödes-skärmbild kräver körande api+web+auth (FAS 1). |

**FAS 0: PASS** (med ovan noterad PARTIAL på autentiserad flödes-skärmbild).
