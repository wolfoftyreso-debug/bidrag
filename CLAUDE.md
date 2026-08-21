# CLAUDE.md — agentguide för Bidragskoll.se

Läs den här filen först. Den är skriven för Claude-agenter (och människor) som
öppnar repot utan förhistoria och ska kunna arbeta säkert direkt.

## Vad projektet är

**Bidragskoll.se** — svensk konsumenttjänst: berätta din livssituation, systemet
utreder vilka stöd du kan ha rätt till (bostadsbidrag, försörjningsstöd, CSN,
stipendier, projektbidrag m.m.) och förbereder hela ansökan. Affärsmodell:
gratis upptäckt → **39 kr** analysupplåsning → **19 kr per ansökan** som
förbereds i systemet (alla dokument för den ansökan ingår); att ansöka själv
direkt hos myndigheten är alltid gratis och sägs uttryckligen.

Två orubbliga produktprinciper: **en fråga per skärm** (ingen blankett) och
**bedömning, aldrig beslut** ("ser ut att kunna ha rätt till", aldrig "du är
berättigad"). Fler principer i `README.md` §Product principles.

## Vad som redan är byggt

Allt nedan är byggt, testat och pushat — bygg inte om det:

- **`packages/core`** — ren domänmotor (noll I/O): kriterie-DSL, matchpoäng,
  ansökans tillståndsmaskin, budgetmotor, schemadrivna formulär,
  dokumentmallar + rendering, deterministisk ansökningsgranskning
  (`docs/APPLICATION-INTELLIGENCE.md`). 90 enhetstester.
- **`apps/api`** — Fastify 5 + Drizzle + PostgreSQL 16, modulär monolit:
  auth/tenancy, kunskapsgraf (72 stöd, 35 finansiärer, 71 ansökningsscheman,
  36 källor), matchning, ansökningar, dokumentvalv, betalningar (Swish Handel-
  adapter + mock), kvitton med moms, GDPR-självservice, kurators-API,
  bakgrundsjobb. 198 integrationstester.
- **`apps/web`** — svensk React-SPA (Vite): onboarding en-fråga-per-skärm,
  analys/teaser, köpflöden med ångerrättssamtycke, ansökningsarbetsyta,
  dokumentstudio, Mina köp/kvitton, admin.
- **`demo/`** — fristående demo som kör den riktiga motorn i webbläsaren
  (ingen server), med 7 automatiska webbläsarkontroller.
- **Deploy-beredskap** — Vercel serverless-ingång (`api/index.ts`),
  `vercel.json` (bygge, SPA-routning, 5 cron-jobb), `deploy/bootstrap.sql`,
  Dockerfile + `deploy/k8s/` som alternativ väg, CI grön.
- **Publik SEO-yta** — `tools/genseo.mjs` genererar 77 statiska sidor
  (`/bidrag/` + 4 målgruppshubbar + 72 entity-sidor + sitemap + robots) ur
  seeden vid varje Vercel-bygge; QA-crawlas av `tools/seocheck.mjs` i verify.
  Strategi/research i `docs/SEO_*.md`; keyword-databas i `seo/`
  (332 rötter, inga påhittade volymer — allt källmärkt).

Historik: `git log` är detaljerad och ärlig; revisionsrapporter i
`docs/reports/`.

## Arkitektur på en minut

```
packages/core   ← ren TypeScript-domän, inga beroenden på api/web
apps/api        ← importerar core; äger databasen; REST under /v1
apps/web        ← importerar core för typer; pratar bara /v1
api/index.ts    ← Vercel-serverless-wrapper runt exakt samma Fastify-app
demo/           ← bundlar core + kunskapsbas-export till EN html-fil
```

- Node ≥ 22, npm workspaces, TypeScript körs direkt via
  `--experimental-strip-types` (ingen byggkedja i dev).
- **Bygg alltid core före typecheck** — api/web typkontrolleras mot cores
  `dist/`-deklarationer. CI gör detta i rätt ordning; lokalt gör
  `npm run verify` det åt dig.
- Detaljer: `docs/ARCHITECTURE.md`. API-kontraktet: `docs/openapi.json`.

## Databasen

- Schema: `apps/api/src/db/schema.ts` (Drizzle). Migreringar: numrerade
  SQL-filer i `apps/api/drizzle/` — skapas med `npm run db:generate -w apps/api`
  efter schemaändring, appliceras med `npm run db:migrate` (idempotent;
  spårning i `drizzle.__drizzle_migrations`). Skriv aldrig migreringsfiler
  för hand utan drizzle-kit, och redigera aldrig en redan pushad migrering.
- Seed (kunskapsbasen): `npm run db:seed` (källa: `apps/api/src/seed/`).
  Seedade stöd stämplas `ai_curated` — etiketten "AI-sammanställd från
  officiell källa — ej granskad av människa" är medveten ärlighet; endast
  kuratorsflödet får höja till `human_curated`/`human_verified`.
- **`deploy/bootstrap.sql`** = komplett dump (schema + RLS + kunskapsbas +
  migrationsspårning) för att resa en tom PostgreSQL utan Node — används av
  deploy-körboken för att ladda Supabase via connector. Efter bootstrap är
  `npm run db:migrate` en no-op. **Regenerera den när migreringar eller seed
  ändras**: `bash scripts/make-bootstrap.sh` (verifierar rundtur själv).
- RLS: deny-all-policyer (migrering 0005) — Supabases PostgREST kommer inte
  åt något; all åtkomst går genom API:t.

## Kommandon

```bash
# Förstagångsuppsättning (Node 22+, PostgreSQL 16):
npm ci
npm run build -w packages/core   # api/web importerar cores dist — bygg först
createdb bidrag && npm run db:migrate && npm run db:seed
cp .env.example .env             # sätt DATABASE_URL + PORT=3100 (se nedan)

# Utveckling:
npm run dev:api      # API (läser .env i roten; PORT default 3000)
npm run dev:web      # SPA på :5173, proxar /v1 till API_URL (default :3100)
# OBS: vite-proxyn och alla tools/-skript antar API på port 3100 —
# sätt PORT=3100 i .env (eller API_URL) så hänger allt ihop.

# HELA HÄLSOKONTROLLEN I ETT KOMMANDO — kör den före och efter ditt arbete:
npm run verify       # bygge, lint, typecheck, alla tester, bootstrap- och
                     # migreringsrundtur från tom databas, produktionsbygge,
                     # deploy-konfig, hemlighetsskanning. Grön = pushbart.
npm run verify -- --no-db   # utan databassteg

# Delmängder:
npm test                      # core + api; api-tester kör mot TEST_DATABASE_URL
                              # (default postgres://postgres@localhost:5432/bidrag_test;
                              # databasen skapas av npm run verify)
npm run lint                  # = tsc --noEmit (ingen separat linter är konfigurerad)
npm run typecheck             # kräver att core är byggt
npm run demo:build            # bygger demon → artifacts/demo/demo.html (ingen databas)
npm run demo:check            # 7 webbläsarkontroller av demon (kräver Chromium + byggd demo)
npm run verify:ui             # 13 genomklickningar — kräver KÖRANDE api (PORT=3100,
                              # PAYMENTS_MOCK_ENABLED=true) + dev:web + Chromium
npm run verify:sim30          # 30 simulerade användare — kräver körande api som ovan
npm run openapi -w apps/api   # regenererar docs/openapi.json efter API-ändringar
npm run manual                # regenererar systemhandboken docs/MANUAL.md (se nedan)
npm run seo:check             # genererar publika SEO-ytan + kör QA-crawlen
npm run seo:keywords          # bygger seo/keywords.json ur seeden + roots-manual
```

Webbläsare för kontrollerna: `npx playwright install chromium` eller sätt
`CHROMIUM_PATH`.

**Systemhandboken (`docs/MANUAL.md`) är en byggprodukt — redigera den aldrig
för hand.** Den genereras av `tools/genmanual.mjs` ur systemets faktiska
källor (Fastifys routetabell, cores exporter, seeden, `.env.example`,
`package.json`). Reaktivitetsvakt i både verify och CI: en ny API-operation
eller ett nytt npm-skript utan instruktion i generatorns kartor, eller en
ocommittad regenerering, fallerar bygget. Efter varje API-/skript-/seed-
ändring: `npm run manual` och committa. Fjärr-röktest av en deployad miljö:
`BASE_URL=https://… CRON_SECRET=… node tools/deploy-smoke.mjs` — kör hela
köpkedjan i preview, verifierar ärlig 503 i produktion utan Swish.

CI (`.github/workflows/ci.yml`) kör: core-bygge → typecheck → handbokskoll →
core-tester →
api-tester mot riktig Postgres → migrationsdeterminism (drizzle-kit generate
får inte ge nya filer) → backup/restore-övning → web- och api-bygge →
docker-jobb som bygger produktionsimagen och röktestar `/readyz`.
CI kör inte webbläsarkontrollerna (verify:ui, demo:check).

## Miljövariabler & integrationer

**`.env.example` är sanningskällan** — varje variabel är dokumenterad där.
Minimum för lokal drift: `DATABASE_URL` (hemligheterna har dev-defaults;
i produktion kastar config vid start om `DATABASE_URL`, `AUTH_SECRET` eller
`FIELD_ENCRYPTION_KEY` saknas). Produktion kräver därtill: `AUTH_SECRET`,
`FIELD_ENCRYPTION_KEY`, `CRON_SECRET`, `STORAGE_DRIVER=supabase` +
Supabase-trion, `PUBLIC_BASE_URL`, `CORS_ORIGIN`. Integrationer som aktiveras
med nycklar när användaren tecknat avtalen: Resend (e-post), Swish Handel
(betalningar), `ANTHROPIC_API_KEY` (språkförslag). Utan nyckel svarar
respektive yta ärligt 503 — bygg aldrig bort det.

## Mock/demo kontra verklig produktion

| Yta | Mock finns? | Gate |
|---|---|---|
| Betalningar | ja (`PAYMENTS_MOCK_ENABLED`) | tillåts bara när `NODE_ENV !== 'production'` **eller** `VERCEL_ENV === 'preview'` — se `apps/api/src/config.ts`. Skarp produktion kan aldrig mocka. |
| Språkförslag | ja (`GENERATION_MOCK_ENABLED`) | samma villkor |
| Demon | helt fristående | ingen server, inga riktiga köp — simulerar betalvyn med tydlig märkning |

Felsökning av köpflöden i molnet görs alltså i **Vercel Preview**-deployer,
aldrig i Production. `/v1/internal/readiness?probe=true` (Bearer
`CRON_SECRET`) rapporterar ärligt vad som är aktiverat och vad som blockerar.

## Deployment

- **Primär väg: Vercel + Supabase.** `git push` → Vercel bygger och deployar
  (SPA statiskt + hela API:t som en serverless-funktion); Supabase står för
  Postgres, privat `documents`-bucket och pooler; Vercel Cron kör jobben.
- **Agentdriven deploy**: `docs/DEPLOY-AGENT.md` är körboken — följ den om
  Supabase-/Vercel-connectors finns i sessionen. Manuell klickordning:
  `docs/DEPLOY-NU.md`. Helhet och drift: `docs/DEPLOYMENT.md`,
  `docs/OPERATIONS.md`. Aktivering av externa tjänster: `docs/ACTIVATION.md`.
- Repot pushas till **två** remotes: `origin` (wolfoftyreso-debug/bidrag,
  arbetsgren) och `bidragskoll` (wolfoftyreso-debug/bidragskoll, `main` =
  deploygrenen). Pusha färdigt arbete till båda; CI kör på bidragskoll.
  Saknas den andra remoten i din klon:
  `git remote add bidragskoll https://github.com/wolfoftyreso-debug/bidragskoll.git`.

## Kända begränsningar

`docs/LIMITATIONS.md` är den ärliga, numrerade listan — läs den innan du
lovar något. Sammanfattat: Swish/Resend/Anthropic kräver användarens avtal
och nycklar; innehållet är AI-kurerat i väntan på mänsklig granskning;
DPIA/juristgranskning återstår (dokumenterat, inte gjort); fyra måttliga
dev-beroendesårbarheter i drizzle-kits kedja är medvetet accepterade (§11).

## Nästa prioriterade arbete (i ordning)

Läge 2026-08-21: Swish-uppgifterna från banken väntas fortfarande — deployn
görs UTAN Swish (köpen vägrar ärligt 503 tills avtalet finns; hela köpflödet
felsöks i Vercel Preview med mock). När systemet är deployat och klart har
användaren beställt en **fullständig revision** och i samband med den en
**komplettering av systemhandboken** — infrastrukturen finns redan
(`docs/MANUAL.md`, reaktiv via verify/CI); revisionen görs mot den deployade
miljön och handboken fördjupas då skärm för skärm.

1. **Deployn själv** — användaren kör `docs/DEPLOY-AGENT.md` i en session med
   Supabase-/Vercel-connectors. Assistera; gör det du kan via connectorerna.
   Verifiera efteråt utifrån med `tools/deploy-smoke.mjs`.
2. **Demons plan-vy: dokumentförberedelse in-browser** — användarfynd: demon
   länkar till 1177/myndigheten i stället för att visa att systemet förbereder
   ansökan. Core exporterar redan `DOCUMENT_TEMPLATES`, `prefillAnswers`,
   `renderDocument`, `validateDocumentAnswers` och demon bundlar core — visa
   dokumentet som text + kopiera-knapp (artefaktsandlådan blockerar
   nedladdningslänkar).
3. **SEO Tier 1-guiderna** — 12 redaktionella guide-/jämförelsesidor under
   `/guider/` enligt `docs/SEO_STRATEGY.md` (frågematrisen i
   `seo/questions-tier1.json` styr; answer-first, YMYL-språk, källor).
   SERP-luckorna är belagda i `docs/SEO_SERP_RESEARCH.md`. Efter deploy:
   GSC-verifiering + `docs/SEO_BASELINE.md`-loopen.
4. **Mänsklig gransknings-kö** — arbetsflöde som lyfter stöd från
   `ai_curated` till `human_verified` mot levande källor (motförhörets A-fynd).
4. **Full WCAG-genomgång + riktiga användartester** (motförhörets B-fynd).
5. **Produktkontroller i CI** — kör verify:ui/demo:check i CI med
   tjänstecontainrar (Postgres + Chromium).

## Regler för agenter i detta repo

1. **Hitta aldrig på data.** Inga påhittade stöd, belopp, myndighetsregler
   eller personuppgifter. Personnummer efterfrågas aldrig någonstans.
2. **Ärlighet före demo-glans**: mockar och ej aktiverade integrationer ska
   synas och vägra ärligt (503), aldrig låtsas fungera i skarp drift.
3. **Inga hemligheter i repot** — `npm run verify` skannar; `.env.example`
   hålls tom på värden. En läckt nyckel ska roteras, inte bortförklaras.
4. Inga modellnamn/modell-ID:n som författar-attribution i commits, kod
   eller pushade artefakter. (Produktens konfigurerade generationsmodell i
   `.env.example`/`docs/ACTIVATION.md` är produktkonfiguration — undantagen.)
5. Svenska i all användarvänd text. Dokumentation: behåll varje fils
   befintliga språk (flera docs är på engelska — det är medvetet).
6. Kör `npm run verify` grönt innan du pushar; pusha till båda remotes.
   Verify är striktare än CI (CI kör inte deploy-konfig-/hemlighetsstegen
   eller webbläsarkontrollerna) — lita på verify lokalt, CI som andra vakt.
7. Sandlåde-drift (Claude Code remote): Postgres dör ibland — starta om med
   `rm -f /home/user/pgdata/postmaster.pid && su postgres -c "/usr/lib/postgresql/16/bin/pg_ctl -D /home/user/pgdata -o '-k /tmp -p 5432' -l /home/user/pgdata/log start"`.
   API:ts registrerings-rate-limit är ~10/min — vänta ~75 s efter simuleringar
   innan nya kontoflöden.
