# Bidrag.se — Arkitekturrapport: migrering till Vercel + Supabase

Datum: 2026-08-16 · Status: kodmigrering klar och verifierad; plattformskoppling
(Supabase-projekt, Vercel-projekt, domän) återstår som konfigurationssteg.

## 1. Nuvarande arkitektur (före migreringen)

Monorepo (npm workspaces): `packages/core` (ren domänmotor, noll I/O),
`apps/api` (Fastify 5 + Drizzle + PostgreSQL 16), `apps/web` (Vite React SPA).
Egen auth (scrypt + JWT/rotating refresh, httpOnly-cookies), pg-boss-jobb i en
långlivad process, dokument på lokal disk, deploy som containerimage mot
Kubernetes-manifest. 107 API-tester + 48 domäntester, allt grönt.

Forensisk revision (20 punkter) fann fyra verkliga deployblockerare för
serverless — och noll AWS-beroenden (endast kommentarer i k8s-manifest):

1. Migreringar + pg-boss-worker startas i processen (`index.ts`)
2. Dokumentvalvet skriver till lokal disk (`UPLOAD_DIR`)
3. Jobbschemaläggning kräver den långlivade workern
4. Supabase-specifikt: `public`-schemat utan RLS är läsbart via PostgREST
   för alla med anon-nyckeln

Inga hemligheter i Git (verifierat med skanning; testvärden i vitest-config är
avsiktliga och ofarliga). Inga hårdkodade produktions-URL:er — allt går via
`PUBLIC_BASE_URL`/`CORS_ORIGIN`; SPA:n anropar bara `/v1` på samma origin.

## 2. Målarkitektur

GitHub (källa till sanning) → Vercel (statisk SPA + hela API:t som EN
serverless-funktion) → Supabase (PostgreSQL via pooler, privat Storage-bucket).
Vercel Cron ersätter worker-schemat. Ingen Kubernetes, ingen gateway, ingen
Redis, ingen AWS. Medvetet tråkigt.

## 3. Migrerade komponenter

| Komponent | Lösning |
|---|---|
| API-runtime | `api/index.ts` — Fastify-appen oförändrad bakom en serverless-handler; instans delas mellan varma anrop. Bevisad med röktest genom handlern: hela köpresan inkl. cookies, kvitto och cron |
| Bakgrundsjobb | jobbkroppar extraherade till `jobs/tasks.ts`; körs av pg-boss (container) ELLER `/v1/internal/cron/:job` (Vercel Cron, Bearer `CRON_SECRET`, timing-safe jämförelse, 404 utan konfigurerad hemlighet). Alla jobb idempotenta |
| Dokumentlagring | driver-gräns i `services/storage.ts`: `disk` (dev/test/container) och `supabase` (privat bucket via service-nyckel, enbart server-side). GDPR-radering använder samma gräns |
| Migreringar | flyttade ur kallstart; `npm run db:migrate` som deploysteg mot `DIRECT_DATABASE_URL` (5432) — aldrig DDL via transaktionspoolern |
| Supabase-härdning | migrering 0005: RLS PÅ (deny-all) för samtliga tabeller + revoke av anon/authenticated-grants; invarianttest tvingar RLS på varje framtida tabell |
| Deploy-konfig | `vercel.json`: build, output, en funktion (60 s/1024 MB), rewrites (SPA-fallback + `/v1`), fyra cron-scheman |

## 4. Behållna komponenter (medvetet — regel 19)

- **Egen auth i stället för Supabase Auth.** Dokumenterat starkt skäl:
  komplett, testad auth med tenants/roller/invites/rotating refresh är
  sammanvävd med behörighetsmodellen. Byte = stor omskrivning utan
  beta-värde. Kan omprövas senare.
- **Auktorisering i applikationslagret** (tenant-scopad på varje query,
  verifierat av isolationstester). RLS används som deny-all-mur mot
  PostgREST-vägen — inte som applikationens behörighetsmodell.
- **Drizzle-migreringar** (versionerade i Git) i stället för Supabase CLI:s
  migreringssystem — samma garanti, noll omskrivning.
- **Vendor-integrationerna server-side i API:t** (`services/paymentProviders`,
  `services/email`, `services/receipts` = mönstrets `client/types/mapper`).
  Supabase Edge Functions införs INTE nu: att flytta fungerande server-side-kod
  till en andra runtime vore infrastruktur utan krav. Dokumenterat som
  framtida beslut om integrationsytan växer.
- **Dockerfile + `deploy/k8s/`** som alternativ egen-drift-väg (valideras i CI,
  driftas inte).

## 5. Borttagna/avvecklade beteenden

- Migreringar vid processtart (kapplöpningsrisk i serverless) — nu deploysteg.
- Direkta `fs`-anrop i rutter (dokument, GDPR) — nu bakom storage-drivern.
- Antagandet om en långlivad process för schemaläggning.

## 6. Vendor-integrationer (alla server-side, mönstret validate → secret → call → normalize)

| Vendor | Status |
|---|---|
| Swish | adapter vägrar ärligt (503) tills `SWISH_MERCHANT_ALIAS` + `SWISH_CERT_PATH` (handelsavtal + mTLS) finns; webhook-ytan svarar 503 tills signaturverifiering kan ske |
| Resend | transaktionsmail (kvitton m.m.) via server-side fetch; SMTP-fallback; utan båda bokförs 'skipped' |
| ClamAV | valfri (`CLAMAV_ADDRESS`); utan den märks filer ärligt `scan_unavailable` |
| Betalningens sanning | alltid server-side: bekräftad betalning → bokförd transaktion → kvitto → upplåsning; webbläsaren kan aldrig påstå att betalning skett |

## 7. Miljövariabler

Kompletta i `.env.example` (namn, aldrig värden). Kritiska för Vercel-drift:
`DATABASE_URL` (poolad 6543), `DIRECT_DATABASE_URL` (5432, migreringar),
`AUTH_SECRET`, `FIELD_ENCRYPTION_KEY`, `STORAGE_DRIVER=supabase`,
`SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_STORAGE_BUCKET`,
`CRON_SECRET`, `PG_POOL_MAX=2`, `PUBLIC_BASE_URL`, `CORS_ORIGIN`,
`RESEND_API_KEY`, `EMAIL_FROM`, säljaruppgifterna för kvitton. Dev/Preview/
Production hålls isär i Vercels miljöhantering.

## 8. Databasmigreringar

0000 initial · 0001 index · 0002 invites · 0003 payments · 0004 receipts ·
0005 RLS deny-all. Deterministiska, committade, körs i CI och som deploysteg.
Regel: ny tabell ⇒ RLS i samma migrering (CI-invariant vägrar annars).

## 9. Deployprocedur

Se `docs/DEPLOYMENT.md` (runbook). Kort: Supabase-projekt + privat bucket →
migrera+seeda via direktanslutning → importera repot i Vercel → env-vars →
domän. Därefter: `git push` = deploy; schemaändring = migrering i Git +
`db:migrate` före koddeploy.

## 10. Återstående blockerare för beta

1. **Plattformskonton** (kan inte göras härifrån): skapa Supabase-projekt +
   Vercel-projekt, lägga in hemligheter, peka domänen.
2. **Verifiera Supabase Storage-drivern mot ett riktigt projekt** — koden är
   skriven mot Storage-API:et men har inte kunnat integrationstestas utan
   riktiga nycklar (disk-drivern är fullt testad).
3. **Swish-handelsavtal + certifikat** och **momsklassning med redovisningen**
   — betalflödet är annars komplett (mock-vägen är avstängd i produktion).
4. **Resend-nyckel + avsändardomän** (SPF/DKIM) för riktiga kvittomail.

## 11. Känd teknisk skuld

- Rate limiting per funktionsinstans (inte globalt) — acceptabelt för beta;
  global limitering är ett framtida beslut om behovet uppstår, inte en gateway.
- `/metrics` är inte exponerad på Vercel (medvetet); beta-observability =
  Vercels funktionsloggar + strukturerade pino-loggar + audit-tabellen.
  Larmkoppling är ett konfigurationssteg, inte kod.
- pg-boss-schemat ligger kvar i databasen även på Vercel-vägen (oanvänt men
  ofarligt); städas om container-vägen pensioneras.
- Kalla starter: första anropet i en ny funktionsinstans bygger Fastify-appen
  (~hundratals ms); acceptabelt för beta.

## 12. AWS

Ingenting kräver AWS. Inga SDK-beroenden, inga tjänsteantaganden i kod.
De enda förekomsterna av ordet är kommentarer i de behållna k8s-manifesten
(alternativvägen) och gäller generisk egen drift.
