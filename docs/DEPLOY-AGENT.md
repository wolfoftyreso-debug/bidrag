# DEPLOY-AGENT — körbok för agentdriven deploy via connectors

**Målgrupp: en Claude-session med Vercel-connector kopplad (in-house: Vercel + Neon Postgres).**
Användaren har bett om snabbaste vägen med minsta möjliga klipp-och-klistra.
Din uppgift är att göra allt som connectorerna tillåter och bara lämna kvar
det som kräver användarens egna klick. Fråga aldrig användaren om något du
kan ta reda på eller göra själv.

Bakgrund: repot är produktionsklart (CI grön, serverless-ingången röktestad).
Manuell klickordning finns i `docs/DEPLOY-NU.md` — den är reservvägen om
en connector saknas eller saknar en förmåga.

## Vad Vercel-connectorn FAKTISKT kan (kontrollerat 2026-08-30)

Hela connectorns verktygsyta genomsökt. Spara tid: den **kan inte** göra de
två steg som blockerar deployn.

| Behov | Finns i connectorn? |
|---|---|
| Lista team/projekt/deployer, läsa projektinställningar | ja |
| Läsa byggloggar, runtime-loggar och felkluster | ja (`get_runtime_logs`, `get_runtime_errors`) |
| Hämta en deployad URL trots att sandlådans proxy blockerar den | ja (`web_fetch_vercel_url`) — **använd den, inte curl** |
| Skapa projekt från git-repo, deploya, pausa, domänköp | ja |
| **Skriva miljövariabler** | **NEJ** |
| **Skapa Neon/Postgres-store (Storage-integrationen)** | **NEJ** |

Steg 1 och steg 3 nedan är därför **operatörssteg**, inte agentsteg. Agenten
förbereder hemligheter och env-blocket; användaren klistrar in.

## Nulägesdiagnos (2026-08-30, mätt via connectorn)

Projektet `bidragskoll` (`prj_7tNuXcIfB39QjwAwltyLmkt4WJ1C`, team `hypbit`)
är länkat till `wolfoftyreso-debug/bidragskoll` och **bygger grönt vid varje
push** — den statiska ytan är live och korrekt routad. Men API-funktionen
kraschar på varje anrop:

```
GET /readyz → 500 FUNCTION_INVOCATION_FAILED
Error: Missing required environment variable DATABASE_URL
    at required (file:///var/task/apps/api/dist/config.js:14:15)
```

Ingen databas är alltså kopplad ännu; ingen env är inklistrad. Cron-jobben
fallerar av samma skäl var 15:e minut. Detta är väntat och ärligt beteende
(config kastar hellre än att starta halvt), inte en regression — och det är
exakt vad steg 1 och 3 åtgärdar.

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
4. **Verifiera räkningarna** — allt annat är ett fel. Kör detta mot databasen
   efter laddningen:

   ```sql
   select (select count(*) from public.funding_opportunities)  -- 85
        , (select count(*) from public.funding_authorities)    -- 36
        , (select count(*) from public.application_schemas)    -- 71
        , (select count(*) from public.sources)                -- 37
        , (select count(*) from public.kb_translations)        -- 11410
        , (select count(*) from drizzle.__drizzle_migrations); -- 15
   ```

   **Rättat 2026-08-30:** raden ovan sa tidigare `drizzle.__drizzle_migrations=14`.
   Rätt tal är **15**, bevisat genom att ladda `deploy/bootstrap.sql` i en tom
   databas och räkna. `scripts/verify.sh` har hela tiden hävdat rätt tal (det
   räknar `apps/api/drizzle/*.sql`); det var körboken som var fel, och en
   operatör som följde den hade trott att laddningen misslyckades.
5. **Objektlagring**: ingen bucket. `STORAGE_DRIVER=postgres` lägger
   dokument/uppladdningar i tabellen `storage_objects` i Neon — privat, åtkomst
   bara genom API:ts tenantkontroll. Migreringen skapade tabellen; inget mer görs.
   Filen regenereras med `bash scripts/make-bootstrap.sh` efter varje migrerings-
   eller seedändring (skriptet rundtursverifierar själv).

### ⚠ RLS-fällan: körtidsrollen MÅSTE äga tabellerna

Uppmätt 2026-09-01 i en bootstrap-laddad databas: **alla 39 tabeller har
`relrowsecurity = true` och `relforcerowsecurity = false`.** Det är
deny-all-policyerna från migrering 0005, medvetet djupförsvar.

Konsekvensen är subtil och farlig. PostgreSQL låter **tabellägaren** gå förbi
RLS när FORCE inte är satt. Alltså:

- Kör runtime med **samma roll** som laddade `bootstrap.sql` → allt fungerar.
- Kör runtime med en **annan roll** (t.ex. om Vercels Storage-integration
  skapar en separat applikationsroll) → varje `select` returnerar **noll
  rader, utan felmeddelande**. API:t startar, `/readyz` svarar `{"ok":true}`,
  och produkten hittar inga stöd alls. Ingenting i loggarna säger varför.

Verifiera därför direkt efter env-inklistringen, med `DATABASE_URL`:s egen
roll:

```sql
select current_user,
       (select count(*) from public.funding_opportunities) as syns;
-- syns måste vara 85. Är den 0 är rollen inte ägare — ladda om bootstrap
-- med rätt roll, eller kör: alter table <tabell> owner to <körtidsroll>;
```

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

### Vad varje variabel gör, och vad som går sönder utan den

Härlett ur `apps/api/src/config.ts` och `apps/api/src/db/`, inte ur den här
körboken — så listan kan inte drifta ifrån koden utan att någon märker det.

| Variabel | Utan den | Klass |
|---|---|---|
| `DATABASE_URL` | Funktionen **kraschar vid start** i produktion (`Missing required environment variable`) — hela API:t 500:ar | HÅRD |
| `AUTH_SECRET` | Samma krasch | HÅRD |
| `FIELD_ENCRYPTION_KEY` | Samma krasch | HÅRD |
| `STORAGE_DRIVER=postgres` | Faller tillbaka på `disk` — filer skrivs till serverless-instansens **flyktiga** filsystem och försvinner | TYST FEL |
| `CORS_ORIGIN` | Faller tillbaka på `http://localhost:5173` — webben blockeras av CORS mot sitt eget API | TYST FEL |
| `PUBLIC_BASE_URL` | Samma localhost-fallback — länkar i kvitton och mejl pekar fel | TYST FEL |
| `CRON_SECRET` | `internal.ts` avvisar varje anrop utan giltig Bearer → **alla fem cron-jobb slutar fungera** | TYST FEL |
| `DIRECT_DATABASE_URL` | Migreringar körs via pooleren, vilket är en känd felkälla (`db/migrate.ts`) | RISK |
| `PG_POOL_MAX=2` | Default är 10 per instans — serverless multiplicerar det och kan slå i Neons anslutningstak | RISK |
| `STRIPE_SECRET_KEY` / `STRIPE_WEBHOOK_SECRET` | Köpytan vägrar ärligt 503 (`no_payment_provider`) — allt annat fungerar | AVSIKTLIG |
| `ANTHROPIC_API_KEY` | Språkförslag svarar ärligt 503 | AVSIKTLIG |

De tre HÅRDA syns direkt. De fyra TYSTA är farligast: appen startar och ser
frisk ut, men lagring, CORS, länkar eller cron är trasiga. `deploy-smoke`
fångar CORS och lagring; cron-hålet syns bara i loggarna.

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
när den faktiska `*.vercel.app`-adressen är känd. **Connectorn kan inte
skriva env-variabler** (se tabellen högst upp) — be alltid användaren.
Produktionsadressen är i dag `https://bidragskoll.vercel.app`.

## Steg 4 — verifiera (via connectorerna + deploy-smoke)

1. Vercel-connectorn: bekräfta att deployn är klar; läs byggloggen vid fel.
   Vid 500 på API-vägarna: `get_runtime_errors` visar inget för krascher som
   sker vid modulinläsning (appen hinner aldrig logga) — använd
   `get_runtime_logs`, som fångar dem.
2. Readiness: `GET https://<projekt>.vercel.app/v1/internal/readiness?probe=true`
   med `Authorization: Bearer <CRON_SECRET>`. Förväntat ärligt svar med Neon +
   Postgres-lagring + Stripe: `database: ready`, `storage: ready` (postgres),
   `payments: ready` (Stripe konfigurerat) — och `email_resend`/
   `generation_anthropic` som kvarvarande blockerare tills de aktiveras enligt
   `docs/ACTIVATION.md`. Utan Stripe-nycklar blir `payments` en blockerare (mock).
   Obs: sandlådans proxy blockerar `*.vercel.app` för curl (CONNECT 403).
   Använd connectorns `web_fetch_vercel_url` i stället — den når deployen.
   Kräver anropet en egen `Authorization`-header (readiness-proben gör det)
   kan connectorn inte sätta den; ge då användaren det färdiga curl-kommandot.
3. Kör fjärr-röktestet om nätet tillåter (annars ge användaren kommandot):
   `BASE_URL=https://<preview-url> CRON_SECRET=<värdet> node tools/deploy-smoke.mjs`
   — i preview verifierar det HELA kedjan (konto → intag → matchningar GRATIS
   (Open Discovery) → 402 → 19 kr → ansökan → kvitton); mot produktions-URL:en
   verifierar det att 19 kr-köpet vägrar ärligt (503) tills Swish finns.
4. Be användaren öppna **preview-URL:en** (varje push till en gren får en)
   och köra samma flöde med ögonen. Mockbetalningarna fungerar ENDAST i
   preview — aldrig i produktion.

## Produktionsartefakten är genomtestad lokalt (2026-09-01)

Innan dina två steg kördes hela produktionskedjan mot **produktionsbygget**
(`apps/api/dist`) med `NODE_ENV=production` och den **bootstrap-laddade**
databasen — alltså exakt den artefakt och exakt de data som hamnar på Neon.

| Kontroll | Utfall |
|---|---|
| `deploy-smoke` i produktionsläge (utan betalprovider) | ALLT OK — 49 gratis matchningar, 402-grind med 1900 öre, köp vägrar ärligt 503 `no_payment_provider` |
| `deploy-smoke` i previewläge (`VERCEL_ENV=preview` + mock) | ALLT OK — hela köpkedjan, kvitto `BS-2026-000001`, ansökan `SELECTED`, Mina köp listar köpet |
| Cron utan `CRON_SECRET` | 401 — vakten håller |
| Alla fem cron-jobb med token | 200. `source-fetch` rapporterade `fetched: 37, failed: 0` — **vilket var falskt**: alla 37 fick `HTTP 403` från sandlådans proxy, men jobbet räknade bara transportfel som `failed`. Räknaren är rättad (revision 2026-09-01, se docs/reports/REVISION_2026-09-01.md). Källornas verkliga nåbarhet mäts först efter deploy, utanför proxyn. |
| `STORAGE_DRIVER=postgres` | Bevisad: 38 byte uppladdade, byte-identiskt tillbakalästa, 1 rad i `storage_objects` |

Slutsatsen: går något fel efter dina steg sitter felet i **konfigurationen
eller i Neon**, inte i artefakten. Börja då med RLS-kontrollen ovan.

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
