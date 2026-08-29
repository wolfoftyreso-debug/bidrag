# Bidragskoll.se

**En personlig rättighets- och stödutredning**: berätta vad du behöver hjälp med,
så tar systemet reda på vad du kan ha rätt till — bostadsbidrag, försörjningsstöd,
studiemedel, stipendier, projektbidrag eller EU-finansiering — och hjälper dig hela
vägen till ansökan, kvitto och beslut. Bidrag är ett av resultaten, inte produkten.

Två hårda produktprinciper styr upplevelsen:

1. **En fråga per skärm.** Ingen blankett, ingen "fyll i din profil". Dialogen
   avgör vilka frågor som behöver ställas härnäst.
2. **Bedömning, aldrig beslut.** Systemet säger "det här ser du ut att kunna ha
   rätt till" (hög sannolikhet / möjlig / behöver utredas) — aldrig "du är
   berättigad". Slutligt beslut fattas alltid av myndigheten.

Ingen bidragskatalog. Systemet är en sammanhängande pipeline:

```
Profil → Intention → Stödutbud → Behörighet → Matchning → Finansieringsplan
      → Ansökningsarbetsyta → Inlämning → Ärende → Svar → Redovisning
```

## Status (honest, qualified)

> **Produktionsarkitektur med verifierad end-to-end-kärna och tydligt
> isolerade integrationsgränser** — inte "produktionsfärdig i stor skala"
> utan kvalificering.

| Dimension | Läge |
|---|---|
| Teknisk kärna | ~85 % byggd, deterministisk och testad |
| Production hardening | pågående — metrics, GDPR-självservice och runbook finns; backup-övning och lasttest är genomförda i dev/CI (se `docs/OPERATIONS.md`), verklig produktionsdrift återstår |
| Kunskapstäckning | 85 kurerade stöd från 36 finansiärer (stämplade `ai_curated` — AI-sammanställda från officiell källa, ej människogranskade), inkl. personliga ersättningar (FK, CSN, Pensionsmyndigheten, socialtjänsten, AF), funktionsnedsättnings-, nyanländ- och utvandringsspår samt lokala/regionala organisationsstöd — bevisar motorn, inte nationell täckning |
| Integrationsmognad | låg per design — assisterad inlämning tills avtalade adaptrar finns |
| Kommersiell modell | **Open Discovery** (produktdoktrinen v2): gratis att upptäcka — se relevanta stöd, varför de matchar, grundvillkor, deadline, officiell källa och "ansök själv"-länk, allt utan betalning. Betalt arbetslager: förberedd ansökan i systemet (19 kr per ansökan — alla dokument för den ansökan ingår; förberedelsen drivs av stödets EGET kurerade ansökningsschema där ett sådant finns (71/85 stöd, 473 fält), annars av de generiska mallarna som då säger att de är generella; PDF till Mina dokument); bevakning/aviseringar planeras. Ingen betalvägg framför matchningsresultaten. Kvitton med löpnummer + moms i kontot. Betalningen är den auktoritativa händelsen; Swish-adaptern väntar ärligt (503) på handelsavtal + certifikat; momsen är fast 25 % standardsats (elektroniskt levererad tjänst till konsument) |
| Produktarkitektur | stark; skala/härda/befolka, inte bygga om |

Nästa prioriterade arbete finns i ordnad lista i `CLAUDE.md` (deploy → de 25 bidragsklustren → mänsklig gransknings-kö → WCAG/användartester);
den ärliga brislistan är `docs/LIMITATIONS.md`.

## Repository layout

| Path | What |
|---|---|
| `packages/core` | Pure domain engine: criteria DSL, layered match scoring, application state machine, budget engine, schema-driven forms, funding-stack compatibility, deadline math. Zero I/O, 90 unit tests. |
| `apps/api` | Fastify + PostgreSQL modular monolith: auth, tenancy, funding knowledge graph, matching, application cases, documents, submissions, correspondence, ingestion, background jobs, curation API. 198 integration tests. |
| `apps/web` | Swedish-first React SPA: onboarding, matches, opportunity detail, application workspace, vault, inbox, admin console. |
| `deploy/k8s` | Kubernetes manifests (deployment, service, ingress, PDB, PVC, secret templates). |
| `demo/` | Fristående demo som kör den verkliga motorn i webbläsaren, plus sju webbläsarkontroller. Se `demo/README.md`. |
| `tools/` | Verifieringsverktyg: 30-användarsimulering, 13 UI-genomklickningar, revisionssviter, schemakontroll, röktester. Se `tools/README.md`. |
| `deploy/bootstrap.sql` | Hela databasen (schema + kunskapsbas) som en körbar SQL-fil — reser en tom PostgreSQL utan Node. Regenereras med `scripts/make-bootstrap.sh`. |
| `scripts/` | `verify.sh` (hälsokontrollen bakom `npm run verify`), backup/restore-övning, lasttest, Swish-beredskap. |
| `docs/` | Dokumentkarta: `ARCHITECTURE` (helheten), `DEPLOYMENT`+`DEPLOY-AGENT`+`DEPLOY-NU` (deploy: helhet / agentdriven körbok / manuell klickordning), `ACTIVATION` (externa tjänster), `OPERATIONS` (drift), `SECURITY`/`PRIVACY` (säkerhet/GDPR), `LIMITATIONS` (ärlig brislista), `APPLICATION-INTELLIGENCE`+`PERFECT-APPLICATION-CONSTITUTION` (styrdokument för ansökningsmotorn). |
| `docs/reports/` | Genererade revisionsrapporter (historiska ögonblicksbilder). |
| `CLAUDE.md` | Ingången för AI-agenter: vad som är byggt, hur allt körs och verifieras, nästa prioriterade arbete. |

## Quick start (local)

Requires Node 22+ and PostgreSQL 16.

```bash
npm ci
createdb bidrag                       # or use DATABASE_URL of your choice
npm run build -w packages/core
npm run db:migrate                    # deterministic SQL migrations
npm run db:seed                       # wave-1 curated funding data
npm run dev:api                       # API on :3000 (worker included)
npm run dev:web                       # SPA on :5173 (proxies /v1 to the API)
```

Tests:

```bash
createdb bidrag_test
npm test                              # core unit + api integration suites
```

Hela hälsokontrollen i ett kommando (bygge, typer, tester, databas från tom,
produktionsbygge, deploy-konfig, hemlighetsskanning):

```bash
npm run verify
```

## Production

**Primär väg: Vercel + Supabase** — GitHub är källan till sanning, `git push`
bygger och deployar (SPA statiskt + hela API:t som en serverless-funktion),
Supabase står för PostgreSQL (RLS deny-all mot PostgREST), privat
dokumentlagring och poolade anslutningar; Vercel Cron kör bakgrundsjobben.
Snabbaste vägen: `docs/DEPLOY-AGENT.md` (agentdriven körbok via
Supabase-/Vercel-connectors, laddar databasen från `deploy/bootstrap.sql`)
eller `docs/DEPLOY-NU.md` (manuell klickordning ~15 min). Helheten:
`docs/DEPLOYMENT.md`; aktivering av Swish/Resend/Anthropic:
`docs/ACTIVATION.md`. Miljövariabler: `.env.example` — committa aldrig värden.

Alternativ (behållen, ej primär): en containerimage (API + pg-boss-worker +
byggd SPA) med manifesten i `deploy/k8s/`. Se `docs/ARCHITECTURE.md` för
helheten och `docs/LIMITATIONS.md` för den ärliga listan över vad som är och
inte är integrerat.

## Product principles (non-negotiable)

1. No fake automation — a case is never "inlämnad" without a verifiable receipt.
2. Every eligibility rule is versioned and traceable to its official source.
3. A match score is an explainable assessment, never the funder's decision.
4. No personnummer for discovery; no external portal credentials, ever.
5. Tenant isolation is a security invariant, tested explicitly.
6. Every material change is auditable; submitted snapshots are immutable.
