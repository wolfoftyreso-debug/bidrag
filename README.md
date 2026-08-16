# Bidrag.se

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

Not a grant directory. The system is a continuous pipeline:

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
| Production hardening | pågående — metrics, GDPR-självservice och runbook finns; verklig klusterdrift, backup-övning och lasttest återstår |
| Kunskapstäckning | 51 kurerade stöd från 29 finansiärer, inkl. personliga ersättningar (FK, CSN, Pensionsmyndigheten, socialtjänsten) — bevisar motorn, inte nationell täckning |
| Integrationsmognad | låg per design — assisterad inlämning tills avtalade adaptrar finns |
| Kommersiell modell | engångsupplåsning av analysen (39 kr): teaser → betalning bekräftad → kvitto (löpnummer, momsspecifikation, omskickbart) → full rapport. Betalningen är den auktoritativa händelsen; Swish-adaptern väntar ärligt (503) på handelsavtal + certifikat; momsklassning stäms av med redovisningen före produktion |
| Produktarkitektur | stark; skala/härda/befolka, inte bygga om |

Nästa fas är **Production Hardening + Knowledge Expansion** (se
`docs/OPERATIONS.md` och `docs/LIMITATIONS.md`), inte fler UI-funktioner.

## Repository layout

| Path | What |
|---|---|
| `packages/core` | Pure domain engine: criteria DSL, layered match scoring, application state machine, budget engine, schema-driven forms, funding-stack compatibility, deadline math. Zero I/O, 43 unit tests. |
| `apps/api` | Fastify + PostgreSQL modular monolith: auth, tenancy, funding knowledge graph, matching, application cases, documents, submissions, correspondence, ingestion, background jobs, curation API. 36 integration tests. |
| `apps/web` | Swedish-first React SPA: onboarding, matches, opportunity detail, application workspace, vault, inbox, admin console. |
| `deploy/k8s` | Kubernetes manifests (deployment, service, ingress, PDB, PVC, secret templates). |
| `docs/` | Architecture, security, privacy/GDPR, limitations. |

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

## Production

**Primär väg: Vercel + Supabase** — GitHub är källan till sanning, `git push`
bygger och deployar (SPA statiskt + hela API:t som en serverless-funktion),
Supabase står för PostgreSQL (RLS deny-all mot PostgREST), privat
dokumentlagring och poolade anslutningar; Vercel Cron kör bakgrundsjobben.
Hela proceduren: `docs/DEPLOYMENT.md`. Miljövariabler: `.env.example` —
committa aldrig värden.

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
