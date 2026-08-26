# CONTROL REPORT — Master Control Prompt

Senaste kontrollgrindsdom per fas. Uppdateras efter varje fas. Format enligt
masterpromptens §29.

---

## FAS 0 — Fullständig nulägesrevision

**Status: PASS** (en PARTIAL: autentiserad webbflödes-skärmbild skjuts till FAS 1).

**Mål:** Fastställa nuläget med tekniska bevis innan någon implementation.

**Verifierat nuläge:** Systemet är väsentligt byggt och testtäckt (311 tester
gröna, verify 15/15). Monorepo + core(15 moduler) + Fastify-api(37 tabeller,
12 migreringar, RLS deny-all) + Vite-SPA(18 sidor) + 77 statiska SEO-sidor.
Auth, lösenordsåterställning (hashat token, 1h, engångs), betalningsidempotens,
privat storage, CRON-skydd verifierade. Discovery = situations-först men
fritext-extraktion är minimal. Eligibility + Application Preparation starka.

**Genomförda förändringar:** Endast dokumentation (revision + operativa loggar).
Ingen kod- eller schemaändring.

**Filer:** `docs/CURRENT_STATE_AUDIT.md`, `docs/IMPLEMENTATION_LOG.md`,
`docs/CONTROL_REPORT.md`, `docs/OPEN_RISKS.md` (alla nya).

**Databas:** inga ändringar. **API:** inga ändringar. **Miljö:** inga ändringar.

**Tester:** `npm test -w packages/core` → 100 passed. `npm test` (api) →
211 passed. `npm run verify` → 15/15 PASS.

**Säkerhetskontroll:** cookie-flaggor, CSRF-guard, CRON-bearer, RLS deny-all,
scrypt, refresh-rotation verifierade i kod. Inga hemligheter i repo (verify-
skanning grön).

**SEO-kontroll:** publika sidor = statisk HTML; robots disallowar app-vyer;
preview noindex. Situationslager ännu ej byggt (P2/P3).

**Acceptanskriterier (FAS 0-grind):** samtliga PASS utom mobil/desktop-skärmbild
= PARTIAL (autentiserat flöde kräver körande stack; demons intag är verifierat).

**Kvarstående problem:** se `docs/OPEN_RISKS.md` och CURRENT_STATE_AUDIT §11.

**Externa blockerare:** Swish Handel-avtal + cert; GSC; Supabase-prod; Resend;
Anthropic-nyckel. Alla dokumenterade med exakt var de sätts (CURRENT_STATE §13).

**Rollback:** dokument-only; `git revert` av FAS 0-committen återställer helt.

**Nästa fas:** FAS 1 — sökandekontext-ingång ("Vem söker du för?") + fritext-
discovery, utan att bryta produktdoktrinens invariant (doctrine.mjs-vaktad).

---

## FAS 1 (del 1) — Hybrid sökandekontext-ingång + enskild firma-dubbelkontext

**Status: PASS.**

**Mål:** Ge §10.1:s sökandekontext-struktur utan att bryta situations-först-
doktrinen (§2). Beslut via AskUserQuestion: hybrid.

**Verifierat nuläge:** Intaget öppnade direkt med situations-tvåvalet; de fyra
sökandekontexterna fanns i domänen men veks in i situationsgrenarna.

**Genomförda förändringar:** Nytt steg 0 "Vem gäller det?" (Mig själv / Mitt
företag / Min enskilda firma / En förening). Mig själv → situations-tvåvalet
oförändrat. Företag/förening → track+applicantType satta, direkt till
situationsfrågan. Enskild firma → personspår + förifyllt self_employed/
sole_trader, p-age→p-biz-sector (dubbelkontext: person + verksamhet).

**Filer:** `apps/web/src/pages/Onboarding.tsx`; UI-harness uicheck1/9/11/12/13
(Mig själv-brygga); ny `tools/uicheck/faas1-who.mjs`.

**Databas/API/miljö:** inga ändringar.

**Tester:** typecheck rent; `tools/doctrine.mjs` PASS (situations-först hålls);
`npm run verify` 15/15; `npm run verify:ui` (uicheck12+13) KLAR; `faas1-who`
KLAR. Skärmbilder: artifacts/faas1-01, faas1-02.

**Säkerhetskontroll:** endast intag/routing, inga nya endpoints/data. Inga
hemligheter (verify-skanning grön).

**SEO-kontroll:** ej berört (onboarding är noindex app-vy).

**Acceptanskriterier (FAS 1-grind):** Samtliga fyra sökandekontexter fungerar
✓; ingen behöver ange bidragsnamn ✓; redan känd info efterfrågas inte igen
(enskild firma skippar sysselsättning/driftsform) ✓; mobilflödet testat (420px)
✓; känd-bidrag-ingång som sekundär väg = EJ ÄNNU (P1, öppen); fritext-discovery
= EJ ÄNNU (P1-b, kräver ANTHROPIC_API_KEY).

**Kvarstående problem:** P1-b fritext-discovery; demons intagsparitet (LOW);
uicheck1/9 har pre-existerande staleness bortom FAS 1 (ej i verify:ui).

**Externa blockerare:** ANTHROPIC_API_KEY för fritext-discovery (nästa del).

**Rollback:** `git revert` av FAS 1-committen.

**Nästa fas:** FAS 1 (del 2) fritext-discovery + känd-bidrag-sekundärväg, eller
FAS enligt användarens prioritering.
