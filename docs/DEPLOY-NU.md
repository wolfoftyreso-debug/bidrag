# Deploya fullversionen NU — exakt klickordning

Målet: en körbar fullversion på Vercel + Supabase på ~15 minuter, testbar
hela vägen inklusive köpflödena (simulerade betalningar i preview-miljön).
Repot är färdigt: `vercel.json`, serverless-entryn och CI är gröna.
Detaljer och felsökning: `docs/DEPLOYMENT.md`. Aktivering av riktiga
integrationer efteråt: `docs/ACTIVATION.md`. Har sessionen Supabase- och
Vercel-connectors är `docs/DEPLOY-AGENT.md` den snabbare, agentdrivna vägen.

> Jag (byggagenten) kan inte utföra dessa steg åt dig — de kräver dina
> konton, och den här miljöns nätverk når inte Vercel/Supabase. Allt som
> går att förbereda i repot är förberett.

## Steg 1 — Supabase (~5 min)

1. [supabase.com](https://supabase.com) → **New project**
   - Namn: `bidragskoll` · Region: **EU (Stockholm, eu-north-1)** · databas-lösenord: generera och SPARA.
2. När projektet startat: **Connect** (knappen uppe till höger) →
   - **Transaction pooler** (port **6543**) → kopiera URI:n → detta blir `DATABASE_URL`
   - **Direct connection** (port **5432**) → kopiera URI:n → detta blir `DIRECT_DATABASE_URL`
   - Byt `[YOUR-PASSWORD]` mot lösenordet i båda.
3. **Storage** (vänstermenyn) → **New bucket** → namn `documents` → **Private** ✓.
4. **Project Settings → API**:
   - Project URL → `SUPABASE_URL`
   - `service_role`-nyckeln (Reveal) → `SUPABASE_SERVICE_ROLE_KEY` — hemlig, aldrig i klient.

## Steg 2 — Generera hemligheter (1 min, i valfri terminal)

```bash
openssl rand -hex 32   # → AUTH_SECRET
openssl rand -hex 32   # → FIELD_ENCRYPTION_KEY
openssl rand -hex 24   # → CRON_SECRET
```

## Steg 3 — Vercel (~5 min)

1. [vercel.com/new](https://vercel.com/new) → **Import Git Repository** →
   välj `wolfoftyreso-debug/bidragskoll` (godkänn GitHub-appen om den frågar).
2. Bygginställningar: **rör ingenting** — `vercel.json` i repot styr allt
   (Framework Preset får gärna stå som "Other").
3. **Environment Variables** — lägg in följande för **Production, Preview
   och Development** (bocka i alla tre):

   | Nyckel | Värde |
   |---|---|
   | `DATABASE_URL` | pooler-URI:n (6543) från steg 1 |
   | `DIRECT_DATABASE_URL` | direkt-URI:n (5432) från steg 1 |
   | `PG_POOL_MAX` | `2` |
   | `AUTH_SECRET` | från steg 2 |
   | `FIELD_ENCRYPTION_KEY` | från steg 2 |
   | `CRON_SECRET` | från steg 2 |
   | `STORAGE_DRIVER` | `supabase` |
   | `SUPABASE_URL` | från steg 1 |
   | `SUPABASE_SERVICE_ROLE_KEY` | från steg 1 |
   | `SUPABASE_STORAGE_BUCKET` | `documents` |
   | `PUBLIC_BASE_URL` | `https://<ditt-projekt>.vercel.app` (uppdatera när domänen pekas) |
   | `CORS_ORIGIN` | samma som `PUBLIC_BASE_URL` |
   | `PAYMENTS_MOCK_ENABLED` | `true` — **endast i Preview** (bocka ur Production!) |

   Mockbetalningarna fungerar bara i preview-deployer (`VERCEL_ENV=preview`);
   i Production är de strukturellt avstängda oavsett flaggan. Det är så du
   felsöker hela köpflödet före Swish-avtalet: öppna preview-URL:en för en
   branch-push i stället för produktions-URL:en.
4. **Deploy**.

## Steg 4 — Migrera och seeda databasen (~3 min, från din dator)

```bash
git clone https://github.com/wolfoftyreso-debug/bidragskoll.git && cd bidragskoll
npm ci
DATABASE_URL="<DIRECT_DATABASE_URL>" npm run db:migrate   # ALLTID direktanslutningen (5432)
DATABASE_URL="<DIRECT_DATABASE_URL>" npm run db:seed      # 84 stöd, 36 finansiärer, 70 scheman, 38 källor
```

Alternativ utan Node på din dator: kör `deploy/bootstrap.sql` mot den tomma
databasen (t.ex. i Supabase SQL Editor) — den innehåller schema + hela
kunskapsbasen och ger exakt samma slutläge.

## Steg 5 — Verifiera

```bash
curl -H "Authorization: Bearer <CRON_SECRET>" \
  "https://<ditt-projekt>.vercel.app/v1/internal/readiness?probe=true"
```

Förväntat ärligt svar: `database: ready`; `payments_swish`, `email_resend`
och `generation_anthropic` som blockerare tills du aktiverar dem enligt
`docs/ACTIVATION.md`. Registrera sedan ett konto i UI:t och kör hela
flödet: intag → teaser → (i preview) simulerad betalning → analys →
förbered ansökan (19 kr, simulerad) → dokument → kvitton under Mina köp.

## Därefter (i egen takt)

1. **Domänen**: Vercel → Settings → Domains → `bidragskoll.se` (uppdatera
   sedan `PUBLIC_BASE_URL`/`CORS_ORIGIN`).
2. **Resend, Anthropic, Swish**: exakta steg och verifieringskommandon i
   `docs/ACTIVATION.md`; varje aktivering kvitteras av readiness-proben.
3. **Icke-tekniska lanseringsvillkor** (DPIA, juristgranskning, mänsklig
   granskning av kunskapsbasen): listade sist i `docs/ACTIVATION.md`.
