# CLAUDE.md — agentguide för Bidragskoll.se

Läs den här filen först. Den är skriven för Claude-agenter (och människor) som
öppnar repot utan förhistoria och ska kunna arbeta säkert direkt.

## Vad projektet är

**Bidragskoll.se** — svensk konsumenttjänst: berätta din livssituation, systemet
utreder vilka stöd du kan ha rätt till (bostadsbidrag, försörjningsstöd, CSN,
stipendier, projektbidrag m.m.) och förbereder hela ansökan. Affärsmodell
(**Open Discovery**, produktdoktrinen v2): **gratis att upptäcka** — se
matchningar, varför de matchar, grundvillkor, deadline, källa och "ansök
själv"-länk utan betalning → **betalt arbetslager: 19 kr per förberedd ansökan**
(alla dokument ingår; bevakning planeras). Ingen betalvägg framför resultaten;
att ansöka själv direkt hos myndigheten är alltid gratis och sägs uttryckligen.
(Den tidigare 39 kr-analysupplåsningen är borttagen — se `docs/PRODUCT_DOCTRINE.md`.)

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
  auth/tenancy, kunskapsgraf (85 stöd, 36 finansiärer, 71 ansökningsscheman,
  38 källor), matchning, ansökningar, dokumentvalv, betalningar (Stripe Checkout
  + Swish Handel-adaptrar + mock), kvitton med moms, GDPR-självservice, kurators-API,
  bakgrundsjobb. 213 integrationstester.
- **`apps/web`** — svensk React-SPA (Vite): onboarding en-fråga-per-skärm,
  analys/teaser, köpflöden med ångerrättssamtycke, ansökningsarbetsyta,
  dokumentstudio, Mina köp/kvitton, admin.
- **`demo/`** — fristående demo som kör den riktiga motorn i webbläsaren
  (ingen server), med 10 automatiska webbläsarkontroller.
- **Deploy-beredskap** — Vercel serverless-ingång (`api/index.ts`),
  `vercel.json` (bygge, SPA-routning, 5 cron-jobb), `deploy/bootstrap.sql`,
  Dockerfile + `deploy/k8s/` som alternativ väg, CI grön.
- **Publik SEO-yta** — `tools/genseo.mjs` genererar 170 statiska sidor ur seeden
  vid varje Vercel-bygge: `/bidrag/` + 4 målgruppshubbar + 4 klusterhubbar + en
  entity-sida per stöd + `/finansiarer/` + Query Pages + 11 språklandningssidor +
  **situationslagret** (`/situationer/`) + sitemap + robots. QA-crawlas av
  `tools/seocheck.mjs` och `tools/schemacheck-seo.mjs` i verify.
  Strategi/research i `docs/SEO_*.md`; keyword-databas i `seo/`
  (332 rötter, inga påhittade volymer — allt källmärkt).
- **Situationslagret** — `/situationer/<slug>/` (12 noder + katalogsida). En nod
  skriver aldrig sin egen stödlista: den deklarerar en **faktaprofil** i
  `seo/situationer.json` och **motorn** (`packages/core`, samma kriterie-DSL som
  produkten) avgör vilka stöd profilen för framåt — varje rad bär seedens egen
  kriteriebeskrivning som skäl. Profilen får bara innehålla definitionsmässigt
  sanna fakta, och frågorna sidan visar måste stå ordagrant i seeden. Doktrin +
  domar: `docs/SEO_SITUATION_ONTOLOGY.md` §3. Vakt: `tools/lib/situationer.mjs`
  + `tools/schemacheck-seo.mjs`.
- **Schema Engine** — entitetsgrafen (JSON-LD) genereras ur samma seed;
  `docs/SCHEMA_ENGINE.md` är styrdokumentet. Regeln: schema får bara påstå det
  som står i seeden OCH syns på sidan.
- **Launch & Demand Intelligence** — `docs/LAUNCH_DEMAND_INTELLIGENCE.md`
  (fyra spår + QSDR/ARR-måtten), scenariomodellen `tools/demandmodel.mjs`
  (`npm run demand:model`; trafik är INPUT i scenarier, aldrig prognos; alla
  antaganden HYPOTHESIS-märkta i `seo/demand-parametrar.json`),
  `docs/AUTHORITY_LOAD_MAP.md` (myndighetsbelastning ur seeden),
  `docs/LAUNCH_CONTROL_ROOM.md` (lanseringspaneler + spiklarm).
- **Zero-Compromise Gate (GATE 0)** — `docs/ZERO_COMPROMISE_GATE.md`
  (gaten + offsite-doktrinen: outbound först, Authority Desk, länkmagneter,
  ALDRIG PBN/utgångna domäner, satellittestet) + `docs/GATE0_REPORT.md`
  (senaste dom). Verktyg i verify: `tools/gate0.mjs` (totalcrawl, media,
  länkgraf/PageRank, innehållsmatris), `tools/gatekeywords.mjs`
  (332-rotregistret GREEN/YELLOW/RED/GREY mot `seo/serp-gate0.json`);
  utanför verify: `npm run gate:ux` (320px+desktop, kräver Chromium),
  `npm run gate:links` (extern länkhälsa, kräver nät — efter deploy).
  **OFFSITE ÄR FRYST tills gaten är grön.**

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
  deploy-körboken för att ladda en tom Neon/Postgres. Efter bootstrap är
  `npm run db:migrate` en no-op. **Regenerera den när migreringar eller seed
  ändras**: `bash scripts/make-bootstrap.sh` (verifierar rundtur själv).
- RLS: deny-all-policyer (migrering 0005) som djupförsvar — all åtkomst går
  genom API:t; ingen direktexponerad databas-yta.

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
npm run demo:check            # 10 webbläsarkontroller av demon (kräver Chromium + byggd demo)
npm run verify:ui             # 5 genomklickningar — kräver KÖRANDE api (PORT=3100,
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
`FIELD_ENCRYPTION_KEY`, `CRON_SECRET`, `STORAGE_DRIVER=postgres` (Neon in-house;
`supabase` finns kvar som alternativ), `PUBLIC_BASE_URL`, `CORS_ORIGIN`.
Integrationer som aktiveras med nycklar: Stripe (betalningar, lanseringsrälsen —
`STRIPE_SECRET_KEY`+`STRIPE_WEBHOOK_SECRET`), Swish Handel (betalningar, när
avtalet är klart), Resend (e-post), `ANTHROPIC_API_KEY` (språkförslag). Utan nyckel svarar
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

- **Primär väg: Vercel + Neon (in-house).** `git push` → Vercel bygger och deployar
  (SPA statiskt + hela API:t som en serverless-funktion); Neon Postgres står för
  databasen + pooler; dokument/uppladdningar bor i databasen (`STORAGE_DRIVER=postgres`,
  tabell `storage_objects` — privat, ingen bucket); Vercel Cron kör jobben.
- **Agentdriven deploy**: `docs/DEPLOY-AGENT.md` är körboken — följ den om
  Vercel-connectorn finns i sessionen. Manuell klickordning:
  `docs/DEPLOY-NU.md`. Helhet och drift: `docs/DEPLOYMENT.md`,
  `docs/OPERATIONS.md`. Aktivering av externa tjänster: `docs/ACTIVATION.md`.
- Repot pushas till **två** remotes: `origin` (wolfoftyreso-debug/bidrag,
  arbetsgren) och `bidragskoll` (wolfoftyreso-debug/bidragskoll, `main` =
  deploygrenen). Pusha färdigt arbete till båda; CI kör på bidragskoll.
  Saknas den andra remoten i din klon:
  `git remote add bidragskoll https://github.com/wolfoftyreso-debug/bidragskoll.git`.

## Produktdoktrinen

**Från situation till möjlighet — inte från bidragsnamn till ansökan.**
Bidragskoll är en **upptäcktsmotor**, inte en sökmotor: användaren ska aldrig
behöva känna till stödets namn, kategori, myndighet eller stödform för att få
värde. Styrande dokument: `docs/PRODUCT_DOCTRINE.md` (positionering, de fyra
lagren, den bärande invarianten). Doktrinen är **kod** — `tools/doctrine.mjs`
körs i verify och fäller bygget om en intagsyta börjar kräva förkunskap eller om
värde-före-betalning-ordningen bryts. Nulägesdom: `docs/DOCTRINE_AUDIT.md`.
Situations-SEO-ontologin (vallgraven före namnsökningar): `docs/SEO_SITUATION_ONTOLOGY.md`.

## Perfektionsdoktrinen

**PERFECTION IS THE PRODUCT** — perfektion = frånvaro av friktion,
inkonsekvens och slarv i alla lager. Styrande dokument: `docs/PERFECTION_BASELINE.md`
(graderad audit, omkörs efter varje större pass) + `docs/PERFECTION_BACKLOG.md`
(CRITICAL/HIGH först — inga små trasigheter accepteras). Design:
`docs/DESIGN_CONSTITUTION.md` (källa: `design/`). Språk: `docs/LANGUAGE_GUIDE.md`
+ `seo/terminologi.json`. Release: `docs/SEO_RELEASE_GATE.md` (gaten är kod i
verify/CI, inte checklista). Entity/press: `docs/ENTITY_FOOTPRINT.md`,
`docs/TRUST_CENTER_SPEC.md`. Återkommande: `docs/RED_TEAM_CHECKLIST.md`.

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
   Vercel-connectorn (in-house: Vercel + Neon). Assistera; gör det du kan via connectorerna.
   Verifiera efteråt utifrån med `tools/deploy-smoke.mjs`.
2. **Demons plan-vy: dokumentförberedelse in-browser — LEVERERAD 2026-08-28**
   (F-FÖRBERED). Planvyn har nu "Förbered ansökan": cores dokumentmotor körd i
   webbläsaren med mallar filtrerade per stödtyp, förifyllnad ur utredningen,
   validering och dokumentet som text + kopiera-knapp. Vakt:
   `demo/checks/forberedcheck.mjs`. **F-SPECIFIK 2026-08-28**: förberedelsen
   drivs av stödets EGET kurerade ansökningsschema (71/85 stöd, 473 fält) med
   myndighetens sektioner, gränser och vägledning, plus ansökningssätt och
   kurerad underlagslista (37/85). Stöd utan schema faller tillbaka på de
   generiska mallarna och säger att de är generella. Kvar: kurera schema för
   de 14 återstående stöden och underlagslistor för de 48 som saknar.
3. **De 25 bidragsklustren färdiga sökfråga→myndighetsöverlämning +
   belastningstest** — produktbeviset (`docs/LAUNCH_DEMAND_INTELLIGENCE.md`
   §8) och det som stänger GATE 0:s CONTENT-RED (`docs/GATE0_REPORT.md` —
   0 av 332 sökområden GREEN; offsite fryst tills gaten är grön). Innehåller innehållsmotorns F0→F1 (`docs/CONTENT_ENGINE.md`:
   interaktiv behörighetskontroll, ändringshistorik, ~~`/situationer/`~~
   (LEVERERAT 2026-08-30 — 12 noder, `docs/SEO_SITUATION_ONTOLOGY.md` §3),
   bevispaketet; `seo/questions-tier1.json` + `docs/SEO_ANSWER_CLUSTERS.md`
   styr) **plus** pre-check-vyn (grundvillkor + underlagslista före utklick),
   instrumenteringseventen för QSDR/ARR, och belastningstest mot modellens
   topptimmesvolymer (`scripts/loadtest.mjs`). Kluster 10–12
   (lönebidrag/nystartsjobb/anställa med stöd) är stängda: stöden är kurerade
   och klusterhubben /bidrag/lonebidrag/ byggd (SERP War Room 2026-08-28). Därefter **F2**
   erfarenhetslagret (licensgenomgång först; datakontrakt i
   `seo/beviljade-projekt.schema.json` + `seo/erfarenheter.schema.json`) →
   **F3** länkbara tillgångar. Öppna beslut: CONTENT_ENGINE §11. Efter deploy:
   GSC-verifiering + `docs/SEO_BASELINE.md`-loopen.
4. **Google Preferred Sources** — rekognoserat 2026-08-29, EJ byggt.
   `docs/PREFERRED_SOURCES.md` är beslutsunderlaget: domänen är inte
   indexerad (DNS pekar på parkering, hela ytan noindex), Googles
   dokumentation gick inte att nå från sandlådan, och projektet saknar
   analytics helt. Verifieringsordning och sömmen finns dokumenterade —
   börja med frågan om Sverige/svenska alls stöds. Blockeras av deployn (#1).
5. **Mänsklig gransknings-kö** — arbetsflöde som lyfter stöd från
   `ai_curated` till `human_verified` mot levande källor (motförhörets A-fynd).
6. **Full WCAG-genomgång + riktiga användartester** (motförhörets B-fynd).
7. **Produktkontroller i CI** — kör verify:ui/demo:check i CI med
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
5. Svenska är källspråket för all användarvänd text; webben är flerspråkig
   enligt `docs/I18N_PROGRAM.md` (11 språk, informationsverige-paletten).
   Ny UI-sträng i översatta ytor = nyckel i `apps/web/src/i18n/locales/sv.ts`
   + alla 10 översättningar. **Ny användarvänd text i kunskapsbasen**
   (sammanfattning, intagsfråga, villkorstext, ansökningssätt, underlag,
   belopp, schemats titel/sektion/fältetikett/vägledning) = post i alla tio
   filerna i `apps/api/src/seed/i18n/` — `tools/i18ncheck.mjs` i verify
   fäller annars, och `npm run i18n:cov` visar täckningen per innehållstyp.
   Officiella stöd-/myndighetsnamn översätts aldrig; ansökningar och juridik
   förblir svenska (bara presentationen översätts — motorn kör mot svenskan).
   Dokumentation: behåll varje fils befintliga språk (flera docs är på
   engelska — det är medvetet).
6. Kör `npm run verify` grönt innan du pushar; pusha till båda remotes.
   Verify är striktare än CI (CI kör inte deploy-konfig-/hemlighetsstegen
   eller webbläsarkontrollerna) — lita på verify lokalt, CI som andra vakt.
7. Sandlåde-drift (Claude Code remote): Postgres dör ibland — starta om med
   `rm -f /home/user/pgdata/postmaster.pid && su postgres -c "/usr/lib/postgresql/16/bin/pg_ctl -D /home/user/pgdata -o '-k /tmp -p 5432' -l /home/user/pgdata/log start"`.
   API:ts registrerings-rate-limit är ~10/min — vänta ~75 s efter simuleringar
   innan nya kontoflöden.
   **Känd sandlådeflakighet:** den FÖRSTA `npm run verify` efter en
   Postgres-omstart fäller ofta steget "API-tester" på en 30 s-timeout
   (oftast `gdpr.test.ts > metrics endpoint`). Verifierat tre gånger
   2026-08-29/30: sviten är grön både fristående (`npm test -w apps/api`,
   225/225) och i nästa verify-körning. Det är kall databas + kall
   modulinläsning, inte en regression — kör om verify en gång innan du
   felsöker vidare.
