# DEPLOY-AGENT — körbok för agentdriven deploy via connectors

**Målgrupp: en Claude-session med Vercel-connector kopplad (in-house: Vercel + Neon Postgres).**
Användaren har bett om snabbaste vägen med minsta möjliga klipp-och-klistra.
Din uppgift är att göra allt som connectorerna tillåter och bara lämna kvar
det som kräver användarens egna klick. Fråga aldrig användaren om något du
kan ta reda på eller göra själv.

Bakgrund: repot är produktionsklart (CI grön, serverless-ingången röktestad).
Manuell klickordning finns i `docs/DEPLOY-NU.md` — den är reservvägen om
en connector saknas eller saknar en förmåga.

## Steg 0 — förutsättningar

1. Kör `ToolSearch` efter `vercel` (och `neon` om en Neon-connector finns).
   Vercel-connectorn behövs. Saknas den: be användaren koppla den under
   claude.ai → Settings → Connectors (Vercel: `https://mcp.vercel.com`) och
   avsluta turen — gissa inte vidare. **In-house-stacken är Vercel + Neon
   Postgres** (ingen Supabase); objektlagringen bor i databasen
   (`STORAGE_DRIVER=postgres`), så ingen extern bucket behövs.
2. Läs `.env.example` — den är sanningskällan för vilka variabler som finns
   och vad de betyder.

## Steg 1 — Neon Postgres (Vercel Storage → Postgres)

1. Skapa en **Neon Postgres**-databas för projektet, region **eu-north-1**
   (Stockholm/Frankfurt närmast). Enklast via Vercel: projektet → **Storage →
   Create → Postgres (Neon)** — då kopplas anslutningssträngarna in i projektets
   env automatiskt (`DATABASE_URL` m.fl.). Alternativt en fristående Neon-databas
   och klistra in strängarna själv.
2. **Anslutningssträngar**: Neon ger en **poolad** host (`...-pooler.neon.tech`,
   för runtime → `DATABASE_URL`) och en **direkt** host (för migreringar →
   `DIRECT_DATABASE_URL`). Båda med `?sslmode=require`. Skapar Vercel-integrationen
   dem åt dig räcker det att verifiera formen; annars bygg dem av Neons dashboard-
   värden.
3. **Ladda databasen**: kör `deploy/bootstrap.sql` mot Neon (Neon SQL Editor,
   `psql "$DIRECT_DATABASE_URL" -f deploy/bootstrap.sql`, eller Neon-connectorn).
   Filen är komplett och verifierad genom rundtur mot tom databas: hela schemat
   (15 migreringar, RLS-policyer, drizzles migrationstabell) + hela kunskapsbasen
   som INSERT-satser (inkl. fas B:s översättningsminne), inga psql-metakommandon. ~1,0 MB. Kör mot den DIREKTA
   anslutningen, aldrig via poolern.
4. **Verifiera räkningarna** — allt annat är ett fel:
   `funding_opportunities=85, funding_authorities=36,
   application_schemas=71, sources=37, kb_translations=11410,
   drizzle.__drizzle_migrations=14`.
5. **Objektlagring**: ingen bucket. `STORAGE_DRIVER=postgres` lägger
   dokument/uppladdningar i tabellen `storage_objects` i Neon — privat, åtkomst
   bara genom API:ts tenantkontroll. Migreringen skapade tabellen; inget mer görs.
   Filen regenereras med `bash scripts/make-bootstrap.sh` efter varje migrerings-
   eller seedändring (skriptet rundtursverifierar själv).

## Steg 2 — hemligheter (lokalt i din sandlåda)

```sh
openssl rand -hex 32   # AUTH_SECRET
openssl rand -hex 32   # FIELD_ENCRYPTION_KEY
openssl rand -hex 24   # CRON_SECRET
```

## Steg 3 — env-blocket (EN inklistring för användaren)

Neon-strängarna kommer från Vercel Storage-integrationen (eller Neons dashboard).
Formen: `postgresql://<user>:<lösenord>@<host>-pooler.<region>.aws.neon.tech/<db>?sslmode=require`
(poolad, → `DATABASE_URL`) och samma utan `-pooler` (direkt, → `DIRECT_DATABASE_URL`).

Sätt ihop ETT komplett env-block (Vercels miljövariabelfält tar emot ett helt
inklistrat .env-block och fyller alla nycklar på en gång):

```
DATABASE_URL=...            # Neon pooler (...-pooler...neon.tech, ?sslmode=require)
DIRECT_DATABASE_URL=...     # Neon direkt (utan -pooler)
PG_POOL_MAX=2
AUTH_SECRET=...
FIELD_ENCRYPTION_KEY=...
CRON_SECRET=...
STORAGE_DRIVER=postgres
STRIPE_SECRET_KEY=sk_test_...      # test i preview, live först i produktion
STRIPE_WEBHOOK_SECRET=whsec_...    # från Stripe-webhooken mot /v1/webhooks/payments/stripe
PUBLIC_BASE_URL=https://<projekt>.vercel.app
CORS_ORIGIN=https://<projekt>.vercel.app
PAYMENTS_MOCK_ENABLED=true         # valfritt i preview; utelämna för att tvinga skarp Stripe
```

Projektet **`bidragskoll`** är redan skapat och länkat i Vercel (ingen import
behövs). Ge användaren blocket och exakt dessa instruktioner:

1. Vercel → projektet **bidragskoll** → **Settings → Environment Variables**,
   klistra in hela blocket i nyckelfältet — alla rader fylls i automatiskt.
   (Använder du Vercel Storage → Postgres läggs `DATABASE_URL` m.fl. in
   automatiskt — dubblera inte.)
2. **`PAYMENTS_MOCK_ENABLED`: bocka ur Production** — den ska bara gälla Preview
   (koden vägrar mock i skarp produktion oavsett, men flaggan ska ändå inte ligga där).
3. **Stripe-webhook**: skapa en endpoint i Stripe mot
   `<PUBLIC_BASE_URL>/v1/webhooks/payments/stripe` (event `checkout.session.completed`)
   och klistra in dess signing secret som `STRIPE_WEBHOOK_SECRET` (se docs/ACTIVATION.md §3).
4. **Deployments → Redeploy** (eller pusha till `main`).

`PUBLIC_BASE_URL`/`CORS_ORIGIN` kan behöva justeras efter första deployn
när den faktiska `*.vercel.app`-adressen är känd — gör det via
Vercel-connectorn om den kan skriva env-variabler, annars be användaren.

## Steg 4 — verifiera (via connectorerna + deploy-smoke)

1. Vercel-connectorn: bekräfta att deployn är klar; läs byggloggen vid fel.
2. Readiness: `GET https://<projekt>.vercel.app/v1/internal/readiness?probe=true`
   med `Authorization: Bearer <CRON_SECRET>`. Förväntat ärligt svar med Neon +
   Postgres-lagring + Stripe: `database: ready`, `storage: ready` (postgres),
   `payments: ready` (Stripe konfigurerat) — och `email_resend`/
   `generation_anthropic` som kvarvarande blockerare tills de aktiveras enligt
   `docs/ACTIVATION.md`. Utan Stripe-nycklar blir `payments` en blockerare (mock).
   Obs: sandlådans proxy kan blockera utgående anrop — går det inte att
   nå URL:en själv, ge användaren det färdiga curl-kommandot.
3. Kör fjärr-röktestet om nätet tillåter (annars ge användaren kommandot):
   `BASE_URL=https://<preview-url> CRON_SECRET=<värdet> node tools/deploy-smoke.mjs`
   — i preview verifierar det HELA kedjan (konto → intag → matchningar GRATIS
   (Open Discovery) → 402 → 19 kr → ansökan → kvitton); mot produktions-URL:en
   verifierar det att 19 kr-köpet vägrar ärligt (503) tills Swish finns.
4. Be användaren öppna **preview-URL:en** (varje push till en gren får en)
   och köra samma flöde med ögonen. Mockbetalningarna fungerar ENDAST i
   preview — aldrig i produktion.

## Steg 5 — efterarbete

- Domän: Vercel → Settings → Domains → `bidragskoll.se`; uppdatera sedan
  `PUBLIC_BASE_URL`/`CORS_ORIGIN`.
- Resend/Anthropic/Swish: `docs/ACTIVATION.md`; varje aktivering kvitteras
  av readiness-proben.

## Regler

- Hitta aldrig på data eller värden — fråga hellre eller läs källan.
- Committa aldrig hemligheter; env-block lämnas i chatten, inte i repot.
- Skapa inget utanför gratisnivån utan uttrycklig bekräftelse.
- Om en connector saknar en förmåga: säg det ärligt och fall tillbaka på
  motsvarande steg i `docs/DEPLOY-NU.md`.
