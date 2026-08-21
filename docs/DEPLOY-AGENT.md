# DEPLOY-AGENT — körbok för agentdriven deploy via connectors

**Målgrupp: en Claude-session med Supabase- och Vercel-connectors kopplade.**
Användaren har bett om snabbaste vägen med minsta möjliga klipp-och-klistra.
Din uppgift är att göra allt som connectorerna tillåter och bara lämna kvar
det som kräver användarens egna klick. Fråga aldrig användaren om något du
kan ta reda på eller göra själv.

Bakgrund: repot är produktionsklart (CI grön, serverless-ingången röktestad).
Manuell klickordning finns i `docs/DEPLOY-NU.md` — den är reservvägen om
en connector saknas eller saknar en förmåga.

## Steg 0 — förutsättningar

1. Kör `ToolSearch` efter `supabase` respektive `vercel`. Båda connectorerna
   behövs. Saknas någon: be användaren koppla den under claude.ai →
   Settings → Connectors (Supabase: `https://mcp.supabase.com/mcp`,
   Vercel: `https://mcp.vercel.com`) och avsluta turen — gissa inte vidare.
2. Läs `.env.example` — den är sanningskällan för vilka variabler som finns
   och vad de betyder.

## Steg 1 — Supabase-projektet (via connectorn)

1. Lista organisationer; skapa projekt **`bidragskoll`**, region
   **`eu-north-1`** (Stockholm). Bekräfta kostnaden med användaren om
   verktyget kräver det (gratisnivån räcker för preview-testning).
2. **Databaslösenordet**: om skapandeverktyget genererar/returnerar ett
   lösenord — spara det för anslutningssträngarna. Om inte: be användaren
   göra EN sak i Supabase-dashboarden (Project Settings → Database →
   Reset database password) och klistra in det till dig. Det är flödets
   enda oundvikliga hemlighetsinklistring.
3. **Ladda databasen**: kör `deploy/bootstrap.sql` genom connectorn
   (apply_migration/execute_sql). Filen är komplett och verifierad genom
   rundtur mot tom databas: hela schemat (12 migreringar, RLS-policyer,
   drizzles migrationstabell) + hela kunskapsbasen som INSERT-satser,
   inga psql-metakommandon. ~396 KB — dela på satsgränser om verktyget
   har storleksgräns (aldrig mitt i en sats; strängar innehåller `;`).
   Filen regenereras med `bash scripts/make-bootstrap.sh` efter varje
   migrerings- eller seedändring (skriptet rundtursverifierar själv).
4. **Verifiera räkningarna** — allt annat är ett fel:
   `funding_opportunities=72, funding_authorities=35,
   application_schemas=71, sources=36, drizzle.__drizzle_migrations=12`.
5. **Bucket**: skapa privat lagringsbucket `documents`
   (`insert into storage.buckets (id, name, public)
   values ('documents','documents',false);` — eller storage-verktyget om
   connectorn har ett).
6. Hämta via connectorn: projekt-URL (= `SUPABASE_URL`) och
   `service_role`-nyckeln. Exponerar connectorn inte service-nyckeln:
   användaren kopierar den från Project Settings → API (Reveal) — säg
   exakt var den finns.

## Steg 2 — hemligheter (lokalt i din sandlåda)

```sh
openssl rand -hex 32   # AUTH_SECRET
openssl rand -hex 32   # FIELD_ENCRYPTION_KEY
openssl rand -hex 24   # CRON_SECRET
```

## Steg 3 — env-blocket (EN inklistring för användaren)

Bygg anslutningssträngarna själv av projektreferensen + lösenordet:

- `DATABASE_URL` (pooler, transaction mode):
  `postgresql://postgres.<ref>:<lösenord>@aws-0-eu-north-1.pooler.supabase.com:6543/postgres`
- `DIRECT_DATABASE_URL` (direkt):
  `postgresql://postgres:<lösenord>@db.<ref>.supabase.co:5432/postgres`

Verifiera värdformerna mot vad connectorn/dashboarden faktiskt visar om du
kan. Sätt ihop ETT komplett env-block (Vercels miljövariabelfält tar emot
ett helt inklistrat .env-block och fyller alla nycklar på en gång):

```
DATABASE_URL=...
DIRECT_DATABASE_URL=...
PG_POOL_MAX=2
AUTH_SECRET=...
FIELD_ENCRYPTION_KEY=...
CRON_SECRET=...
STORAGE_DRIVER=supabase
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
SUPABASE_STORAGE_BUCKET=documents
PUBLIC_BASE_URL=https://<projekt>.vercel.app
CORS_ORIGIN=https://<projekt>.vercel.app
PAYMENTS_MOCK_ENABLED=true
```

Ge användaren blocket och exakt dessa instruktioner:

1. Öppna **vercel.com/new** → Import → `wolfoftyreso-debug/bidragskoll`
   (logga in med GitHub). Rör inga bygginställningar — `vercel.json` styr.
2. Fäll ut **Environment Variables**, klistra in hela blocket i
   nyckelfältet — alla rader fylls i automatiskt.
3. **`PAYMENTS_MOCK_ENABLED`: bocka ur Production** — den ska bara gälla
   Preview (koden vägrar mock i skarp produktion oavsett, men flaggan ska
   ändå inte ligga där).
4. Klicka **Deploy**.

`PUBLIC_BASE_URL`/`CORS_ORIGIN` kan behöva justeras efter första deployn
när den faktiska `*.vercel.app`-adressen är känd — gör det via
Vercel-connectorn om den kan skriva env-variabler, annars be användaren.

## Steg 4 — verifiera (via connectorerna + deploy-smoke)

1. Vercel-connectorn: bekräfta att deployn är klar; läs byggloggen vid fel.
2. Readiness: `GET https://<projekt>.vercel.app/v1/internal/readiness?probe=true`
   med `Authorization: Bearer <CRON_SECRET>`. Förväntat ärligt svar:
   `database: ready` + `payments_swish`/`email_resend`/`generation_anthropic`
   som blockerare (de aktiveras enligt `docs/ACTIVATION.md`).
   Obs: sandlådans proxy kan blockera utgående anrop — går det inte att
   nå URL:en själv, ge användaren det färdiga curl-kommandot.
3. Kör fjärr-röktestet om nätet tillåter (annars ge användaren kommandot):
   `BASE_URL=https://<preview-url> CRON_SECRET=<värdet> node tools/deploy-smoke.mjs`
   — i preview verifierar det HELA kedjan (konto → teaser-gate → 39 kr →
   analys → 402 → 19 kr → ansökan → kvitton); mot produktions-URL:en
   verifierar det att köpen vägrar ärligt (503) tills Swish finns.
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
