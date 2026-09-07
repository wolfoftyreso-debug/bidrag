# Överlämning av Bidragskoll.se — läget 2026-09-05

Skriven för den som tar över utan förhistoria. Allt nedan går att verifiera
i repot; ingenting kräver att man litar på den här texten. Läs i ordning:
den här sidan (15 min) → `CLAUDE.md` (agentguiden, 20 min) →
`docs/BETA_HANDOVER.md` (operatörens handgrepp) → `docs/LIMITATIONS.md`
(det ärliga registret över vad som inte är gjort).

## 1. Var koden finns

| Repo | Roll | Gren |
|---|---|---|
| `github.com/wolfoftyreso-debug/bidragskoll` | **deploygrenen** — Vercel bygger från `main`; CI kör här | `main` |
| `github.com/wolfoftyreso-debug/bidrag` | arbetsrepot — samma historik, samma commits | `claude/bidrag-se-production-build-hdabqp` |

Båda står på samma commit (senast `44c03fa`, 175 commits). Allt färdigt
arbete pushas till båda. Historiken i `git log` är detaljerad och ärlig:
varje commit säger vad som ändrades och varför, inklusive fynd på vägen.

Åtkomst till repona ges av kontoägaren (wolfoftyreso-debug) — det kan inte
göras härifrån.

## 2. Vad det är, i tre meningar

Bidragskoll är en svensk konsumenttjänst: användaren berättar sin
livssituation en fråga i taget, systemet bedömer vilka stöd (bostadsbidrag,
försörjningsstöd, CSN, stipendier, projektbidrag …) personen ser ut att
kunna ha rätt till, och förbereder hela ansökan. Att upptäcka är gratis och
olåst; det enda köpet är **19 kr per förberedd ansökan**; att ansöka själv
hos myndigheten är alltid gratis och sägs uttryckligen. Två orubbliga
principer: **en fråga per skärm** och **bedömning, aldrig beslut**.

Styrdokument: `docs/PRODUCT_DOCTRINE.md` (positioneringen, som också är kod i
`tools/doctrine.mjs`), `docs/LANGUAGE_GUIDE.md` (rösten, som också är kod i
`tools/langcheck.mjs`), `docs/PERFECTION_BASELINE.md` + `docs/PERFECTION_BACKLOG.md`.

## 3. Vad som är byggt och verifierat

| Del | Innehåll | Bevis |
|---|---|---|
| `packages/core` | ren domänmotor: kriterie-DSL, matchning, tillståndsmaskin, budget, scheman, dokumentmallar, granskning | 100 enhetstester |
| `apps/api` | Fastify 5 + Drizzle + PostgreSQL 16: auth/tenancy, kunskapsgraf (**84 stöd, 36 finansiärer, 70 ansökningsscheman, 38 källor**), matchning, ansökningar, dokumentvalv, betalningar (Stripe + Swish + mock), kvitton med moms, GDPR-självservice, kuratorskö med protokoll, jobb, vakthund | 233 integrationstester |
| `apps/web` | svensk React-SPA i **11 språk**: intag en fråga per skärm, analys, köp med ångerrättssamtycke, arbetsyta, dokumentstudio, konto/kvitton, admin | 6 UI-genomklickningar, axe 0 brott i 12 vyer |
| Publik SEO-yta | 169 statiska sidor ur seeden (stödsidor, hubbar, situationer, finansiärer, 11 språklandningar) + **behörighetskontroll** i webbläsaren på 4 klusterhubbar och 82 stödsidor + sitemap/robots/JSON-LD | SEO-QA, schemavakt, gatens UX-block (93 sidor × 2 vyer, 0 fynd) |
| `demo/` | hela motorn i en HTML-fil utan server | 10 webbläsarkontroller |
| Deploy | Vercel serverless + Neon Postgres (`vercel.json`, `api/index.ts`, `deploy/bootstrap.sql`), Docker/k8s som alternativ | CI grön; `tools/deploy-smoke.mjs` för fjärrtest |
| Kvalitetsvakter | `npm run verify` = **26 steg** (bygge, typer, tester, databas från tom, doktrin, språk, i18n, seed-integritet, motorsimulering 11 000 personor, SEO, behörighetskontroll, hemlighetsskanning) | grönt vid senaste körning 2026-09-05 |

Rapporter från den senaste veckan (alla i `docs/reports/`):
`BETA_READINESS_2026-09-03` (vad som återstår till beta),
`KURERING_2026-09-03`, `KURATORSMINIMUM_2026-09-03` (vilka stöd en människa
måste granska först), `SEMRUSH_2026-09-03` (sökmarknaden), `SPRAK_2026-09-04`
(språkrevisionen), `LOADTEST_2026-09-05` (belastning), `TEST_2026-09-05`
(systemtestet med 14 fynd — **läs den sist, det är att-göra-listan**).

## 4. Vad som INTE är gjort — och varför

Allt som kräver konton, avtal, DNS eller mänskliga beslut väntar på
operatören. Exakt lista med kontrollkommandon: `docs/BETA_HANDOVER.md`.
Kortversion:

1. **Deployn** är inte gjord: Neon-databas + miljövariabler i Vercel,
   domänen `bidragskoll.se` pekar fortfarande på parkering. Körboken är
   `docs/DEPLOY-AGENT.md`; hemligheterna (AUTH_SECRET, FIELD_ENCRYPTION_KEY,
   CRON_SECRET) genererades i chatten 2026-09-01 och finns **inte** i repot —
   generera nya med `openssl rand -hex 32` om de inte finns kvar.
2. **Två beslut som bara ägaren kan ta** (BETA_HANDOVER §0): vilket bolag som
   säljer (kvittot säger Landvex AB, Stripe-kontot heter Sommarliden Holding
   — måste vara samma juridiska person), och vilken e-postdomän (Resend-kontot
   har nått planens domängräns).
3. **Swish Handel** väntar på bankens avtal — köp vägrar ärligt med 503 tills
   dess; hela köpflödet felsöks med mock i Vercel Preview, aldrig i produktion.
4. **Mänsklig granskning av kunskapsbasen**: alla 84 stöd är märkta
   "AI-sammanställd från officiell källa — ej granskad av människa". Kön och
   protokollet finns i `/admin`; passet kräver människor
   (`KURATORSMINIMUM`: lista A, 25 stöd, före första inbjudan).
5. **DPIA** (`docs/DPIA.md`) är ett utkast med [ANSVARIG]-fält att fylla i
   och underteckna innan behandlingen av hälsouppgifter börjar. Juristgranskning
   av villkor/samtycke återstår.
6. **Supportbrevlåda** saknas; "mejla oss" på 404-sidan och `/villkor` har
   ingen adress.

Öppen teknisk backlog med prioritet: `docs/PERFECTION_BACKLOG.md`. De fem
HIGH-posterna från systemtestet (M26–M30): tabeller spränger mobilen på fem
vyer, analysen blir ett andra formulär, köplöftet håller inte för 13
schemalösa stöd, gratisvägen saknar länk där köpet sker, prestandan viker
på stora matchtabeller (index saknas).

## 5. Så kör du det lokalt (30 min)

```bash
npm ci
npm run build -w packages/core          # api/web importerar cores dist
createdb bidrag && npm run db:migrate && npm run db:seed
cp .env.example .env                    # DATABASE_URL, PORT=3100, PAYMENTS_MOCK_ENABLED=true
npm run dev:api                         # API på :3100
npm run dev:web                         # SPA på :5173 (proxar /v1)
npm run verify                          # hela hälsokontrollen — grön = pushbart
```

Alla kommandon och deras syfte: `CLAUDE.md` §Kommandon och
`docs/MANUAL.md` (genererad systemhandbok, 96 API-operationer). Sandlådans
egenheter (Postgres som dör, kalla tester): `CLAUDE.md` §Regler punkt 7.

## 6. Reglerna som inte får brytas

1. **Hitta aldrig på data** — inga stöd, belopp eller regler ur minnet; allt
   ur officiell källa med adress och datum. Personnummer efterfrågas aldrig.
2. **Ärlighet före demo-glans** — mockar och saknade integrationer syns och
   vägrar med 503; de låtsas aldrig fungera i skarp drift.
3. **Inga hemligheter i repot** — verify skannar; en läckt nyckel roteras.
4. **Svenska är källspråket** — ny text kräver alla 11 språk; officiella namn
   översätts aldrig. Vakterna fäller bygget annars.
5. **`npm run verify` grönt före push; pusha till båda remotes.**

## 7. Hur man fortsätter med en agent

`CLAUDE.md` är skriven för exakt det: en ny Claude-session som öppnar repot
ska kunna arbeta säkert direkt. Den innehåller prioritetsordningen
(§Nästa prioriterade arbete), vad som redan finns (bygg inte om), och
vakterna. Systemhandboken regenereras med `npm run manual` och fäller bygget
om en ny API-operation eller ett nytt skript saknar beskrivning.

## 8. Kontaktytor och konton som används

| Tjänst | Status | Var |
|---|---|---|
| Vercel (projekt `bidragskoll`) | konfigurerat, ej deployat | `docs/DEPLOY-AGENT.md` |
| Neon Postgres | ej skapad | DEPLOY-AGENT steg 1 |
| Stripe | adapter + webhook klara, live-nycklar saknas; kontofråga öppen | BETA_HANDOVER §0, §3 |
| Swish Handel | adapter klar, avtal saknas | `docs/ACTIVATION.md` |
| Resend (e-post) | adapter klar, domän ej verifierad (plangräns) | BETA_HANDOVER §0, §4 |
| Anthropic (språkförslag) | valfritt, avstängt i beta | `docs/ACTIVATION.md` |
| Semrush | använt för sökdata; snapshot i `seo/volumes-semrush-se.json` | `docs/reports/SEMRUSH_2026-09-03.md` |

Inga nycklar till någon av tjänsterna finns i repot eller i den här filen.
