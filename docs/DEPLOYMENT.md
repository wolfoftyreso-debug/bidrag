# Deployment — Vercel + Supabase (primär väg)

Målarkitekturen är avsiktligt tråkig: GitHub är källan till sanning, Vercel
bygger och kör applikationen, Supabase är den hanterade Postgres-, lagrings-
och driftplattformen. Ingen Kubernetes, ingen gateway, ingen Redis, ingen AWS.

```
git push → GitHub → Vercel build → Preview/Production
                         │
          SPA (statisk)  +  API (en serverless-funktion, api/index.ts)
                         │
                 Supabase PostgreSQL (pooler)
                 Supabase Storage (privat bucket)
                 Vercel Cron → /v1/internal/cron/:job
```

## 1. Supabase-projekt

1. Skapa projekt (region EU, t.ex. `eu-north-1`).
2. Hämta från projektinställningarna:
   - **Pooled connection string** (Supavisor, port 6543, transaction mode) → `DATABASE_URL`
   - **Direct connection string** (port 5432) → `DIRECT_DATABASE_URL`
   - **Project URL** → `SUPABASE_URL`
   - **service_role key** → `SUPABASE_SERVICE_ROLE_KEY` (endast server-side!)
3. Skapa en **privat** Storage-bucket `documents` (public = OFF). Nedladdning
   går alltid genom API:ts tenantkontroll — aldrig publika bucket-URL:er.
4. Kör migreringarna mot direktanslutningen:

   ```bash
   DIRECT_DATABASE_URL='postgres://...:5432/postgres' \
   DATABASE_URL='postgres://...:5432/postgres' \
   AUTH_SECRET=... FIELD_ENCRYPTION_KEY=... \
   npm run db:migrate
   npm run db:seed        # kunskapsbasen (idempotent)
   ```

   Migrering 0005 slår på RLS (deny-all) för samtliga tabeller och återkallar
   PostgREST-rollernas grants — utan den är `public`-schemat läsbart för alla
   som har anon-nyckeln. Invarianttestet `invariants.test.ts` vägrar godkänna
   en ny tabell utan RLS.

## 2. Vercel-projekt

1. Importera GitHub-repot. `vercel.json` styr allt: SPA byggs till
   `apps/web/dist`, hela API:t körs som en funktion (`api/index.ts`),
   `/v1/*` skrivs om dit, allt annat faller tillbaka till SPA:n.
2. Lägg in miljövariablerna från `.env.example` under **Environment
   Variables**, med separata värden för Production/Preview/Development.
   Minimum för drift:
   `DATABASE_URL` (poolad!), `DIRECT_DATABASE_URL`, `AUTH_SECRET`,
   `FIELD_ENCRYPTION_KEY`, `STORAGE_DRIVER=supabase`, `SUPABASE_URL`,
   `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_STORAGE_BUCKET=documents`,
   `CRON_SECRET`, `PUBLIC_BASE_URL`, `CORS_ORIGIN`, `PG_POOL_MAX=2`. Säljaruppgifterna på kvittona
   (Landvex AB, org.nr 559141-7042, Antennvägen 2, 135 48 Tyresö) är
   standardvärden i koden; `SELLER_NAME`/`SELLER_ORG_NUMBER`/
   `SELLER_VAT_NUMBER`/`SELLER_ADDRESS` behöver bara sättas om
   bolagsuppgifterna ändras.
   E-post är INTE ett produktionskrav: kvitton är förstaklass i kontot
   (Mina köp), notiser finns i Inkorgen, inbjudningar har delbara länkar
   och lösenordsåterställning fungerar via engångs-återställningskoder
   (Konto & data). Länk-vägen för återställning kräver en kanal och är
   annars avstängd fail-closed (503) — se docs/LIMITATIONS.md §4.
3. Peka produktionsdomänen (bidragskoll.se) på projektet; sätt `PUBLIC_BASE_URL`
   och `CORS_ORIGIN` till `https://bidragskoll.se`.
4. Vercel Cron (definierad i `vercel.json`) anropar jobben med
   `Authorization: Bearer $CRON_SECRET` automatiskt. Utan satt `CRON_SECRET`
   är cron-ytan avstängd (404).

## 3. Deployflöde

- **Kodändring**: `git push` → Vercel bygger → Preview-URL → merge till
  huvudbranchen → Production. Ingen manuell serverhantering.
- **Schemaändring**: skriv migrering (drizzle-kit generate / handskriven SQL
  i `apps/api/drizzle/`), committa, kör `npm run db:migrate` mot
  `DIRECT_DATABASE_URL` som deploysteg **innan** koden som behöver schemat går
  live. Klicka aldrig fram schemaändringar i Supabase-konsolen utan att samma
  ändring finns som migrering i Git.
- **Ny tabell**: `ENABLE ROW LEVEL SECURITY` ingår i tabellens migrering
  (invarianttestet stoppar annars CI).

## 4. Serverless-avvikelser (medvetna)

| Beteende | Container (Dockerfile/K8s) | Vercel |
|---|---|---|
| Migreringar | vid uppstart | deploysteg (`db:migrate`) — aldrig vid kallstart |
| Bakgrundsjobb | pg-boss-worker i processen | Vercel Cron → `/v1/internal/cron/:job` (samma jobbkroppar, idempotenta) |
| Dokumentlagring | disk (persistent volym) | Supabase Storage (`STORAGE_DRIVER=supabase`) |
| Pool | `PG_POOL_MAX` valfri | `PG_POOL_MAX=2` + poolad anslutning (Supavisor) |
| Rate limiting | per process | per funktionsinstans (svagare; acceptabelt för beta, dokumenterad skuld) |
| `/metrics` | skrapas internt | ej exponerad (rewrites släpper inte igenom) |

## 5. Verifiering efter deploy

Kör alltid readiness-proben först — den säger ärligt vilka integrationer som
är aktiva och vilka som blockerar:

```bash
curl -H "Authorization: Bearer $CRON_SECRET" \
  "https://<domän>/v1/internal/readiness?probe=true"
# ok:true = allt aktiverat; blockers-listan säger annars exakt vad som saknas
```

```bash
curl -s https://bidragskoll.se/healthz                     # {"ok":true}
curl -s https://bidragskoll.se/v1/internal/cron/retention  # 404 (hemlighet krävs)
# Registrera testkonto i UI:t, kör hela flödet: intake → teaser → (Swish när
# konfigurerad) → kvitto → analys. Ladda upp + ned ett dokument (Storage-vägen).
```

## 6. Swish-milstolpen (körs när avtal + certifikat finns)

1. Handelsavtal (Swish Handel) via banken → hämta ut kommerscertifikatet.
2. Koda om till base64 och lägg i Vercel-miljön: `SWISH_MERCHANT_ALIAS`,
   `SWISH_CERT_BASE64`, `SWISH_KEY_BASE64` (+ ev. `SWISH_KEY_PASSPHRASE`).
   Callback-URL:en är `https://<domän>/v1/webhooks/payments/swish` — måste
   vara https på port 443 (Vercel uppfyller det).
3. **MSS-test först** (Swish testmiljö med testcertifikat):
   `SWISH_API_BASE=https://mss.cpc.getswish.net` i preview →
   `BASE_URL=https://<preview> node scripts/swish-readiness.mjs`
   — verifierar mTLS-handskakningen, payment request, QR, verifierad status,
   kvitto och upplåsning.
4. **Produktionstest med en riktig 39 kr-betalning**: samma skript mot
   produktionsdomänen, betala med Swish-appen, verifiera kvittot under
   Mina köp (och kvittomailet om Resend är aktiverat — e-post är inget
   produktionskrav), återbetala i Swish-portalen.
5. Säkerhetsmodellen (byggd och testad): callbacken är osignerad och används
   bara som väckning — bekräftelse sker enbart efter statushämtning
   server-till-server över mTLS med beloppskontroll. Tappade callbacks
   räddas av verify-on-read i statuspollingen.

## 7. Hemligheter

- Inga hemligheter i Git — `.env.example` innehåller bara namn. En hemlighet
  som råkat committas ÄR komprometterad: rotera den, städa inte bara historiken.
- `SUPABASE_SERVICE_ROLE_KEY` (och ev. mailkanal-hemligheter om en kanal
  senare konfigureras) får aldrig nå webbläsaren; de läses enbart i
  API-funktionen. SPA:n har inga `VITE_`-hemligheter alls — den pratar bara
  med `/v1` på samma origin.
- Rotationsordning vid läckage: AUTH_SECRET → alla sessioner ogiltiga (avsett);
  service-nyckel roteras i Supabase-konsolen; Swish-cert via banken.

## Alternativ väg: container (behållen, ej primär)

`Dockerfile` + `deploy/k8s/` finns kvar för egen drift (en image med API +
worker + SPA). Den vägen kör pg-boss-workern och diskdriver med persistent
volym. Vercel-vägen är den primära; container-vägen valideras av CI:s
Docker-bygge men driftas inte åt någon.
