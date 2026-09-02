/**
 * Systemhandbokens generator: bygger docs/MANUAL.md ur systemets FAKTISKA
 * källor — den registrerade routetabellen (Fastify), cores exporter
 * (dokumentmallar, tillståndsmaskin), kunskapsbasens seed, .env.example och
 * package.json. Så hålls handboken reaktiv: ändras systemet måste handboken
 * regenereras, och `npm run verify` fallerar tills det är gjort.
 *
 *   npm run manual            # skriver docs/MANUAL.md
 *   npm run manual -- --check # fallerar om docs/MANUAL.md inte är aktuell
 *
 * VAKTEN: varje API-operation och varje npm-skript MÅSTE ha en beskrivning i
 * kartorna nedan. En ny route utan beskrivning stoppar verify — det är så
 * "varenda funktion har instruktion" förblir sant och inte bara en ambition.
 * Determinism: ingen tidsstämpel, allt sorterat — samma källor ⇒ samma fil.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'docs', 'MANUAL.md');
const CHECK = process.argv.includes('--check');

// ── API-operationernas instruktioner ─────────────────────────────────────────
// Nyckel: "METOD /full/sökväg" exakt som i Fastifys routetabell.
const OPS = {
  'GET /healthz': 'Processhälsa — 200 så länge processen lever. Används av lastbalanserare/Docker HEALTHCHECK.',
  'GET /readyz': 'Riktig beredskap — kör `select 1` mot databasen, 503 om den inte svarar. Vänta på 200 efter deploy.',
  'GET /metrics': 'Prometheus-mått (bidrag_*-prefix). Exponeras inte i Vercel-driften — läs funktionsloggarna där.',
  'GET /v1/openapi.json': 'Maskinläsbart API-kontrakt (OpenAPI 3.1) för de schema-registrerade ytorna.',

  'POST /v1/auth/register': 'Skapa konto: e-post + lösenord + visningsnamn → 201 med inloggad session (cookie). Rate-limitad (~10/min per IP).',
  'POST /v1/auth/login': 'Logga in; sätter access-cookien och returnerar användaren.',
  'POST /v1/auth/refresh': 'Byt refresh-token mot ny access-token — webben gör detta automatiskt vid 401.',
  'POST /v1/auth/logout': 'Logga ut och ogiltigförklara refresh-tokenen.',
  'GET /v1/auth/me': 'Vem är jag: användare + medlemskap. Webben anropar den vid varje sidladdning.',
  'POST /v1/auth/request-password-reset': 'Beställ återställningslänk via e-post. Utan e-postkanal: ärlig 503 — använd återställningskoderna i stället.',
  'POST /v1/auth/reset-password': 'Sätt nytt lösenord med token ur återställningslänken.',
  'POST /v1/auth/recovery-codes': 'Generera engångs-återställningskoder (visas EN gång — spara dem). Kanal-lös reservväg när e-post saknas.',
  'GET /v1/auth/recovery-codes': 'Status för koderna: hur många oanvända som finns kvar.',
  'POST /v1/auth/recover-with-code': 'Återställ lösenordet med en oanvänd engångskod.',

  'GET /v1/profiles': 'Lista tenantens sökandeprofiler (person eller organisation).',
  'POST /v1/profiles': 'Skapa profil med fakta från intaget (`facts` är kanoniska fältvägar, t.ex. person.professionalArtist).',
  'PATCH /v1/profiles/:id': 'Uppdatera profilfakta — matchningarna räknas om deterministiskt.',
  'POST /v1/profiles/:id/external-identifiers': 'Registrera extern identifierare (org.nr/OID) — fältkrypteras (AES-256-GCM) före lagring. Personnummer tas aldrig emot.',

  'GET /v1/projects': 'Lista projekt/utredningar.',
  'POST /v1/projects': 'Skapa projekt: profil + intention (fritext) + fakta. Detta är intagets slutresultat.',
  'GET /v1/projects/:id': 'Hämta projektet med status och fakta.',
  'PATCH /v1/projects/:id': 'Uppdatera projektets fakta/intention; svar på öppna följdfrågor sparas hit.',
  'POST /v1/projects/:id/matches': 'Räkna om matchningarna mot alla {{ANTAL_STOD}} stöd (idempotent, deterministisk).',
  'GET /v1/projects/:id/matches': 'Hämta analysen — alltid fullständig och gratis (Open Discovery): varje stöd med förklaring per kriterium, källa och färskhet. Ingen betalvägg framför resultaten.',
  'POST /v1/projects/:id/funding-stack': 'Bygg finansieringsplan av valda stöd; kontrollerar kombinerbarhet och dubbelfinansiering.',
  'POST /v1/projects/:id/application-purchase': 'Köp en ansökningsförberedelse (19 kr — alla dokument för den ansökan ingår). Kräver `immediateDeliveryConsent: true` (ångerrätten) — annars 400. Utan betalprovider: ärlig 503.',
  'GET /v1/projects/:id/receipt': 'Kvitto för projektets köp (förberedd ansökan).',
  'GET /v1/projects/:id/document-credits': 'Kvarvarande dokumentkrediter (härledda ur bekräftade betalningar — aldrig ur klienten).',
  'POST /v1/projects/:id/document-pack': 'Köp dokumentpaket i dokumentstudion (samtyckeskrav + 503-ärlighet som övriga köp).',
  'POST /v1/projects/:id/generated-documents': 'Generera ett dokument ur en mall: svar valideras, förifylls ur projektet och renderas deterministiskt.',
  'GET /v1/projects/:id/generated-documents': 'Lista projektets genererade dokument.',

  'GET /v1/funding-opportunities': 'Sök/lista stödkatalogen (delad läsyta — inga persondata).',
  'GET /v1/funding-opportunities/:id': 'Stödets detaljer: kriterier med proveniens, belopp, deadline, källa + färskhet, kureringsstämpel (t.ex. ai_curated).',

  'GET /v1/applications': 'Lista ansökningsärenden.',
  'POST /v1/applications': 'Skapa ansökan för projekt + stöd. Utan förbrukningsbar 19 kr-kredit: 402 med pris — webben visar köpflödet.',
  'GET /v1/applications/:id': 'Hämta ärendet: schema-drivna fält, budget, dokument, tillstånd, historik.',
  'PATCH /v1/applications/:id': 'Spara fältsvar (autosparas från arbetsytan).',
  'POST /v1/applications/:id/transition': 'Flytta ärendet i tillståndsmaskinen — vaktade övergångar kan inte forceras (se tillståndstabellen nedan).',
  'GET /v1/applications/:id/validate': 'Strukturvalidering: obligatoriska fält, bilagor, budgetregler.',
  'GET /v1/applications/:id/review': 'Deterministisk granskning (Application Intelligence): READY/NOT_READY med prioriterade luckor, konsistens- och språkkontroller.',
  'POST /v1/applications/:id/budget-lines': 'Lägg budgetrad (heltal i ören; aktivitet↔kostnads-länk).',
  'DELETE /v1/applications/:id/budget-lines/:lineId': 'Ta bort budgetrad.',
  'POST /v1/applications/:id/documents': 'Koppla dokument ur valvet till ärendet.',
  'POST /v1/applications/:id/submit': 'Starta inlämning. Utan avtalad adapter: assisterat paket (validerad payload + hash + officiell URL) — aldrig låtsad automatik.',
  'POST /v1/applications/:id/submissions/:submissionId/confirm-external': 'Användaren bekräftar att den externa inlämningen är gjord, med kvittouppgift — först då blir ärendet SUBMITTED.',
  'POST /v1/applications/:id/decision': 'Registrera myndighetens beslut (bifall/avslag) med underlag.',
  'POST /v1/applications/:id/reporting-requirements': 'Lägg återrapporteringskrav med deadline efter bifall.',
  'POST /v1/applications/:id/suggest-field': 'Språkförslag för ett fält (generation mode). Kräver ANTHROPIC_API_KEY; annars ärlig 503. Varje förslag passerar cores deterministiska vakter och sparas aldrig utan användarens godkännande.',

  'GET /v1/documents': 'Lista dokumentvalvet.',
  'POST /v1/documents': 'Ladda upp (multipart, max 20 MB): magic-byte-kontroll, sha256, ev. ClamAV — utan skanner märks filen scan_unavailable.',
  'GET /v1/documents/:id/download': 'Ladda ner ur valvet.',
  'DELETE /v1/documents/:id': 'Radera dokument.',
  'GET /v1/generated-documents/:id/download': 'Ladda ner genererat dokument som PDF.',

  'GET /v1/payments/:id/status': 'Betalningens tillstånd — webben pollar tills confirmed. Swish verifieras alltid server-till-server (mTLS), aldrig på callbackens ord.',
  'GET /v1/payments/:id/qr': 'Swish-QR för desktopflödet (proxad, tokenskyddad).',
  'GET /v1/payments/:id/receipt': 'Kvittot som strukturerad data.',
  'GET /v1/payments/:id/receipt.pdf': 'Kvittot som PDF (löpnummer BS-ÅÅÅÅ-NNNNNN, 25 % moms, ångerrättsrad).',
  'POST /v1/payments/:id/receipt-email': 'Mejla kvittot (kräver e-postkanal; kvittot finns alltid kvar i kontot).',
  'POST /v1/payments/:id/resend-receipt': 'Skicka om kvittomejlet.',
  'POST /v1/payments/:id/mock-confirm': 'Bekräfta SIMULERAD betalning — finns bara när mock är tillåten (aldrig i skarp produktion; 404 annars).',
  'GET /v1/purchases': 'Mina köp: alla köp med kvittonummer och belopp.',
  'POST /v1/webhooks/payments/:provider': 'Betalleverantörens callback. Osignerad by design: används bara som väckning — bekräftelse sker via verifierad statushämtning. 503 utan konfigurerad provider.',

  'POST /v1/tenants': 'Skapa organisationstenant (för team).',
  'GET /v1/tenant/members': 'Lista teamets medlemmar och roller.',
  'DELETE /v1/tenant/members/:userId': 'Ta bort medlem ur teamet.',
  'GET /v1/tenant/invites': 'Lista utestående inbjudningar.',
  'POST /v1/tenant/invites': 'Bjud in via e-post (hashad token; ägarroll kan aldrig delas ut via inbjudan).',
  'DELETE /v1/tenant/invites/:id': 'Återkalla inbjudan.',
  'GET /v1/invites/:token': 'Visa inbjudan (delbar länk).',
  'POST /v1/invites/:token/accept': 'Acceptera inbjudan och gå med i tenanten.',
  'GET /v1/tenant/export': 'GDPR-export (art. 15/20): all tenantdata som strukturerad fil. Endast ägarrollen.',
  'DELETE /v1/tenant': 'GDPR-radering (art. 17): kaskaderar genom alla tenantägda tabeller. Kräver typad bekräftelse; kvitton bevaras enligt bokföringslagen.',

  'GET /v1/correspondence': 'Bidragsinkorgen: myndighetsmeddelanden användaren registrerat (uppladdning/vidarebefordran/manuellt). Inga portalinloggningar lagras någonsin.',
  'POST /v1/correspondence': 'Registrera post; klassificeras deterministiskt och matchas mot ärende med mänsklig override.',
  'PATCH /v1/correspondence/:id': 'Ändra klassificering/ärendekoppling.',

  'GET /v1/notifications': 'In-app-notiser (deadlines, kuratorspåminnelser m.m.).',
  'POST /v1/notifications/:id/read': 'Markera notis som läst.',

  'GET /v1/admin/sources': 'Kuratorskonsolen: källregistret med färskhet.',
  'POST /v1/admin/sources': 'Registrera ny officiell källa.',
  'POST /v1/admin/sources/:id/fetch': 'Hämta källan nu → snapshot + diff i klarspråk till granskningskön.',
  'GET /v1/admin/sources/:id/snapshots': 'Källans snapshothistorik.',
  'GET /v1/admin/review-queue': 'Granskningskön: upptäckta källändringar som väntar på människa.',
  'POST /v1/admin/review-queue/:id/apply': 'Applicera föreslagen regeländring som ny regelversion.',
  'POST /v1/admin/review-queue/:id/resolve': 'Avfärda/lös köpost med motivering.',
  'GET /v1/admin/opportunities': 'Stödlistan ur kuratorsperspektiv (kureringsstatus).',
  'POST /v1/admin/opportunities/:id/rule-versions': 'Publicera ny regelversion (append-only, tidsdaterad, spårbar till källa).',
  'POST /v1/admin/opportunities/:id/verify': 'Höj kureringsstämpeln (ai_curated → human_curated/human_verified) efter kontroll mot levande källa — enda vägen dit.',
  'GET /v1/admin/stale-matches': 'Matchningar som blivit inaktuella av regeländringar.',

  'GET /v1/internal/readiness': 'Aktiveringsberedskap: databas/Swish/Resend/Anthropic som ready/mock/not_configured + blockerare. Bearer CRON_SECRET; `?probe=true` gör ofarliga verifieringsanrop.',
  'GET /v1/internal/cron/:job': 'Kör bakgrundsjobb (source-fetch, deadline-scan, stale-match-recalc, curator-reminders, retention). Vercel Cron anropar med Bearer CRON_SECRET; utan hemligheten är ytan 404.',
  'POST /v1/internal/cron/:job': 'Samma som GET — båda metoderna accepteras av Vercel Cron.',
};

// ── npm-skriptens instruktioner ──────────────────────────────────────────────
const SCRIPTS = {
  build: 'Bygger core → api → web (i den ordningen; api/web kräver cores dist).',
  test: 'Alla tester: core (enhetstester) + api (integration mot TEST_DATABASE_URL).',
  typecheck: 'tsc --noEmit i alla tre paketen — kräver att core är byggt.',
  lint: 'Samma som typecheck (ingen separat linter är konfigurerad).',
  'dev:api': 'API:t i utvecklingsläge (läser .env i roten; sätt PORT=3100).',
  'dev:web': 'Vite-devservern på :5173, proxar /v1 till API_URL (default :3100).',
  'db:migrate': 'Applicerar migreringarna i apps/api/drizzle/ (idempotent).',
  'db:seed': 'Seedar kunskapsbasen ({{ANTAL_STOD}} stöd; idempotent, append-only regelversioner).',
  'demo:build': 'Bygger den fristående demon → artifacts/demo/demo.html (ingen databas).',
  'demo:check': 'Demons 10 webbläsarkontroller (kräver Chromium + byggd demo).',
  'verify:sim30': '30 simulerade användare genom hela flödet — kräver körande API (:3100, mock på).',
  'verify:ui': '5 UI-genomklickningar (uicheck2/8/9/12/13) — kräver körande API + dev:web + Chromium. Föräldralösa skript ligger i tools/uicheck/foraldralosa/ med orsak per skript.',
  'verify:schemas': 'Ansökningsschemanas täckning mot stöden — kräver körande API.',
  'verify:relevans': 'Relevansrevisionen: 10 personor mot alla stöd — inga sektorsgrindade stöd utanför personens situation, inga överexkluderingar (F-RELEVANS). Ingen server krävs.',
  'verify:smoke': 'Prismodellens kedja (402 → 19 kr → ansökan) — kräver körande API.',
  verify: 'HELA hälsokontrollen (scripts/verify.sh): bygge, typer, tester, databas från tom, produktionsbygge, deploy-konfig, hemligheter, handbokens aktualitet.',
  manual: 'Regenererar denna handbok ur källorna (tools/genmanual.mjs).',
  'seo:keywords': 'Bygger master keyword-databasen seo/keywords.json ur seeden + seo/roots-manual.json (aldrig påhittade volymer — se docs/SEO_STRATEGY.md).',
  'seo:build': 'Genererar den publika, indexerbara ytan (/bidrag/… + sitemap + robots) ur kunskapsbasen — samma sanningsmodell som produkten.',
  'seo:check': 'SEO-QA-crawlen: titlar, canonical, JSON-LD, intern länkgraf, orphans och sitemap-täckning för den genererade ytan, plus entitetsgrafens vakt (utgivare, geografi, målgrupp, ärliga datum mot seeden).',
  'demand:model': 'Lanseringsscenariomodellen (docs/LAUNCH_DEMAND_INTELLIGENCE.md): fördelar scenariotrafik (INPUT, aldrig prognos) över klustren, räknar tratt, myndighetsbelastning och teknisk last → artifacts/demand-model.json.',
  'gate:0': 'Zero-Compromise Gate, deterministiska blocken (docs/ZERO_COMPROMISE_GATE.md): teknisk totalcrawl, bildinventering, intern länkgraf/PageRank, innehållsmatris → artifacts/gate0-report.json. Failar på CRITICAL/HIGH.',
  'gate:ux': 'Gatens UX-block: alla publika sidor i 320 px + 1280 px — overflow, H1, tomma ankare, återvändsgränder + bevis-skärmdumpar. Kräver byggd yta + Chromium.',
  'gate:keywords': 'Gatens block A: statusregistret seo/gate0-keywords.json (GREEN/YELLOW/RED/GREY per keyword-rot mot SERP-observationerna).',
  'sim:engine': 'Motorsimulering: ~11 000 genererade personor × alla stöd direkt mot packages/core — döda/universella stöd, nollresultat, sektorsläckor, åldersgränser, datumsvep. Rapporterar; --strict fäller på DÖD/LÄCKA.',
  'sim:engine:intake': 'Samma simulering med bara intagets fakta kända — mäter frågebördan (öppna frågor per persona) och vilka frågor som avgör flest stöd.',
  'seed:integrity': 'Seedens integritet: överlastade faktavägar, döda fakta, motsägelser, delade källor, schemafel (rapporterar; --strict fäller på klass C/G).',
  'i18n:cov': 'Mäter hur stor del av kunskapsbasens användarvända text som finns i översättningsminnet, per innehållstyp (docs/I18N_PROGRAM.md §Täckningen i siffror). Fäller inget bygge — otolkad text är ett kureringsläge, inte ett fel.',
  'gate:links': 'Extern länkhälsa för myndighetslänkarna på publika ytan — körs från nätansluten maskin (t.ex. efter deploy); sandlådan saknar utgående nät.',
};

// ── Samla fakta ur källorna ──────────────────────────────────────────────────
const { buildServer } = await import(join(ROOT, 'apps/api/src/server.ts'));
const app = await buildServer();
await app.ready();
const tree = app.printRoutes({ commonPrefix: false });
await app.close();

const routes = [];
{
  const stack = [];
  for (const raw of tree.split('\n')) {
    const m = raw.match(/^([│├└─\s]*)(\S+) \(([A-Z, ]+)\)/);
    if (!m) continue;
    const depth = Math.round(m[1].replace(/[├└]── $/, '').length / 4);
    stack[depth] = m[2];
    stack.length = depth + 1;
    const full = stack.join('');
    if (full === '*') continue;
    for (const method of m[3].split(', ')) {
      if (method === 'HEAD' || method === 'OPTIONS') continue;
      routes.push(`${method} ${full}`);
    }
  }
  routes.sort();
}

const missingOps = routes.filter((r) => !OPS[r]);
if (missingOps.length) {
  console.error('HANDBOKEN OFULLSTÄNDIG — dessa operationer saknar instruktion i tools/genmanual.mjs:');
  for (const r of missingOps) console.error('  ' + r);
  process.exit(1);
}

const pkg = JSON.parse(readFileSync(join(ROOT, 'package.json'), 'utf8'));
const missingScripts = Object.keys(pkg.scripts).filter((s) => !SCRIPTS[s]);
if (missingScripts.length) {
  console.error('HANDBOKEN OFULLSTÄNDIG — dessa npm-skript saknar beskrivning: ' + missingScripts.join(', '));
  process.exit(1);
}

const core = await import(join(ROOT, 'packages/core/dist/index.js'));
const seed = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const envExample = readFileSync(join(ROOT, '.env.example'), 'utf8');

// Gruppera API-ytan för läsbarhet.
function groupOf(path) {
  if (/^\/(healthz|readyz|metrics)$|^\/v1\/openapi/.test(path)) return 'Systemytor';
  if (path.startsWith('/v1/auth')) return 'Konto & inloggning';
  if (path.startsWith('/v1/profiles')) return 'Profiler';
  if (path.startsWith('/v1/projects')) return 'Projekt, matchning & köp';
  if (path.startsWith('/v1/funding-opportunities')) return 'Stödkatalogen';
  if (path.startsWith('/v1/applications')) return 'Ansökningar';
  if (path.startsWith('/v1/documents') || path.startsWith('/v1/generated-documents')) return 'Dokument';
  if (path.startsWith('/v1/payments') || path.startsWith('/v1/purchases') || path.startsWith('/v1/webhooks')) return 'Betalningar & kvitton';
  if (path.startsWith('/v1/tenant') || path.startsWith('/v1/invites')) return 'Team & GDPR';
  if (path.startsWith('/v1/correspondence')) return 'Bidragsinkorgen';
  if (path.startsWith('/v1/notifications')) return 'Notiser';
  if (path.startsWith('/v1/admin')) return 'Kuratorskonsolen';
  if (path.startsWith('/v1/internal')) return 'Interna jobb';
  return 'Övrigt';
}
const GROUP_ORDER = ['Konto & inloggning', 'Profiler', 'Projekt, matchning & köp', 'Stödkatalogen', 'Ansökningar', 'Dokument', 'Betalningar & kvitton', 'Team & GDPR', 'Bidragsinkorgen', 'Notiser', 'Kuratorskonsolen', 'Interna jobb', 'Systemytor', 'Övrigt'];
const grouped = new Map(GROUP_ORDER.map((g) => [g, []]));
for (const r of routes) grouped.get(groupOf(r.split(' ')[1])).push(r);

// Miljövariabler ur .env.example: sektion → [{name, desc}]
const envSections = [];
{
  let section = null;
  let comment = [];
  for (const line of envExample.split('\n')) {
    const sec = line.match(/^# ── (.+?) ─+/);
    if (sec) { section = { title: sec[1].trim(), vars: [] }; envSections.push(section); comment = []; continue; }
    if (/^#/.test(line)) { comment.push(line.replace(/^#\s?/, '').trim()); continue; }
    const v = line.match(/^([A-Z_]+)=/);
    if (v && section) {
      section.vars.push({ name: v[1], desc: comment.join(' ').slice(0, 220) });
      comment = [];
    } else if (line.trim() === '') comment = [];
  }
}

// ── Skriv handboken ──────────────────────────────────────────────────────────
const L = [];
const p = (s = '') => L.push(s);

p('# Bidragskoll.se — systemhandbok');
p();
p('> **GENERERAD FIL — redigera aldrig för hand.** Handboken byggs ur systemets');
p('> faktiska källor (routetabellen, cores exporter, kunskapsbasens seed,');
p('> `.env.example`, `package.json`) av `tools/genmanual.mjs`. Regenerera med');
p('> `npm run manual`. `npm run verify` fallerar om handboken inte är aktuell,');
p('> och om någon API-operation eller något kommando saknar instruktion.');
p();
p('## 1. Vad systemet är');
p();
p('Bidragskoll.se utreder vilka stöd en person kan ha rätt till utifrån');
p('livssituationen och förbereder hela ansökan. **Open Discovery:** upptäckten');
p('och resultaten är gratis och inte låsta — det enda som kostar är att förbereda');
p('en ansökan i systemet (19 kr per ansökan; alla dokument för den ansökan ingår).');
p('Att ansöka själv direkt hos myndigheten är alltid gratis och sägs uttryckligen.');
p('Två orubbliga principer: **en fråga per skärm**');
p('och **bedömning, aldrig beslut**. Systemet påstår aldrig att något är');
p('inlämnat utan verifierbart kvitto, och hittar aldrig på data.');
p();
p('## 2. Användarresan, moment för moment');
p();
p('1. **Konto** — registrera med e-post + lösenord (inga personnummer, någonsin).');
p('   Skapa gärna engångs-återställningskoder under Konto & data direkt: de är');
p('   reservvägen om e-postkanalen inte är aktiverad.');
p('2. **Intaget** — en fråga per skärm om livssituationen. Varje fråga går att');
p('   backa till och ändra. Känsliga frågan om funktionsnedsättning/långvarig');
p('   sjukdom i familjen är frivillig på riktigt: "Vill inte svara" respekteras,');
p('   faktumet lämnas osatt och frågan återkommer aldrig (art. 9-samtycke');
p('   tidsstämplas när den besvaras).');
p('3. **Analysen (gratis, Open Discovery)** — räknas mot alla stöd och visas');
p('   direkt: varje stöd med namn, sannolikhet och förklaring. Ingen betalvägg,');
p('   inga låsta matchningar — resultaten är fria att se.');
p('4. **Förberedd ansökan (19 kr/ansökan)** — det enda köpet: köpet kräver');
p('   ikryssat samtycke till omedelbar leverans (ångerrätten upphör —');
p('   distansavtalslagen); utan kryss vägrar servern (400). Betala med Swish (QR');
p('   på desktop, app-länk i mobil). Kvittot med löpnummer och 25 % moms hamnar');
p('   under Mina köp direkt.');
p('5. **Analysen** — varje stöd visas med sannolikhet, förklaring per kriterium,');
p('   källa med färskhet och kureringsstämpel ("AI-sammanställd från officiell');
p('   källa — ej granskad av människa" tills en kurator höjt den). Obesvarade');
p('   följdfrågor sorteras efter hur många stöd de avgör; svar går att ändra i');
p('   efterhand under Dina svar.');
p('6. **Vägvalet per stöd** — antingen gratis "ansök själv"-länk till');
p('   myndigheten, eller **Förbered ansökan i systemet (19 kr)**: ansökan');
p('   förifylls ur intaget och alla dokument för den ansökan ingår.');
p('7. **Ansökningsarbetsytan** — schema-drivna fält (autosparas), budget i ören');
p('   med aktivitet↔kostnads-koppling, dokument ur valvet, deterministisk');
p('   granskning som säger READY/NOT_READY med prioriterade luckor i stället');
p('   för tomt beröm.');
p('8. **Dokumentstudion** — mallarna i §5 renderas till PDF under Mina');
p('   dokument; språkförslag (om aktiverat) passerar deterministiska vakter och');
p('   sparas aldrig utan ditt godkännande.');
p('9. **Inlämning** — utan myndighetsadapter förbereder systemet ett assisterat');
p('   paket och du bekräftar själv den externa inlämningen med kvittouppgift;');
p('   först då blir ärendet SUBMITTED. Ingen låtsasautomatik.');
p('10. **Efteråt** — beslut registreras, återrapporteringskrav får deadlines,');
p('    kalendern och notiserna håller ordning. Kvitton ligger kvar under Mina');
p('    köp (PDF + ev. e-post). Konto & data ger GDPR-export och radering som');
p('    självservice.');
p();
p('## 3. Kuratorns arbetsflöde (admin)');
p();
p('Kräver rollen administrator/data_curator. Källregistret hämtar officiella');
p('källor på schema (6 h); ändringar blir snapshot-diffar i klarspråk i');
p('granskningskön. Människan avgör: applicera som ny regelversion (append-only,');
p('spårbar) eller avfärda med motivering. Kureringsstämpeln höjs endast via');
p('verify-flödet efter kontroll mot levande källa — `ai_curated` →');
p('`human_curated`/`human_verified`. Inaktuella matchningar listas och räknas');
p('om. Inget regelinnehåll autopubliceras någonsin.');
p();
p('## 4. Funktionskatalog — hela API-ytan');
p();
p(`Samtliga ${routes.length} operationer, grupperade. Webbappen använder exakt dessa ytor —`);
p('katalogen är därmed också webbens funktionskarta.');
p();
for (const [group, ops] of grouped) {
  if (!ops.length) continue;
  p(`### ${group}`);
  p();
  p('| Operation | Instruktion |');
  p('|---|---|');
  for (const op of ops) p(`| \`${op}\` | ${OPS[op]} |`);
  p();
}
p('## 5. Dokumentmallarna');
p();
p('| Mall | Mottagare | Sektioner | Frågor |');
p('|---|---|---|---|');
for (const t of core.DOCUMENT_TEMPLATES) {
  p(`| **${t.title}** (\`${t.key}\`) — ${t.description} | ${t.recipientLabel} | ${t.sections.length} | ${t.questions.length} |`);
}
p();
p('Förifyllnad (`prefillAnswers`), validering (`validateDocumentAnswers`) och');
p('rendering (`renderDocument`) är deterministiska och ligger i `packages/core`.');
p();
p('## 6. Ansökans tillståndsmaskin');
p();
p('Tillstånd: ' + core.APPLICATION_STATES.map((s) => `\`${s}\``).join(' → ') + '.');
p();
p('Vaktade övergångar (kan aldrig forceras via API:t):');
p();
p('| Övergång | Krav |');
p('|---|---|');
for (const [k, v] of Object.entries(core.GUARDED_TRANSITIONS)) p(`| \`${k}\` | ${v} |`);
p();
p('## 7. Kunskapsbasen i siffror');
p();
p(`${seed.opportunities.length} stöd från ${seed.authorities.length} finansiärer, ${seed.applicationSchemaDefs.length} ansökningsscheman, ${seed.seedSources.length} källor (kurerade ${seed.CURATED_AT.slice(0, 10)}).`);
p('Allt seedat innehåll stämplas `ai_curated` tills en människa granskat det.');
p();
p('| Finansiär | Stöd |');
p('|---|---|');
{
  const byAuth = new Map();
  for (const o of seed.opportunities) byAuth.set(o.authorityKey, (byAuth.get(o.authorityKey) ?? 0) + 1);
  for (const a of [...seed.authorities].sort((x, y) => x.name.localeCompare(y.name, 'sv'))) {
    p(`| ${a.name} | ${byAuth.get(a.key) ?? 0} |`);
  }
}
p();
p('## 8. Miljövariabler');
p();
p('`.env.example` är sanningskällan — tabellen nedan genereras ur den.');
p();
for (const s of envSections) {
  p(`### ${s.title}`);
  p();
  p('| Variabel | Beskrivning |');
  p('|---|---|');
  for (const v of s.vars) p(`| \`${v.name}\` | ${v.desc || '—'} |`);
  p();
}
p('## 9. Kommandon');
p();
p('| Kommando | Gör |');
p('|---|---|');
for (const [name, desc] of Object.entries(SCRIPTS)) {
  if (pkg.scripts[name]) p(`| \`npm run ${name}\` | ${desc} |`);
}
p();
p('## 10. Drift, deploy och gränser');
p();
p('- Deploy: `docs/DEPLOY-AGENT.md` (agentdriven) / `docs/DEPLOY-NU.md` (manuell);');
p('  helhet `docs/DEPLOYMENT.md`; drift `docs/OPERATIONS.md`.');
p('- Fjärr-röktest av deployad miljö: `BASE_URL=https://… node tools/deploy-smoke.mjs`');
p('  (+ `CRON_SECRET` för readiness). I preview körs hela köpkedjan med mock;');
p('  i produktion utan Swish verifieras att köpen vägrar ärligt (503).');
p('- Mock kan aldrig aktiveras i skarp produktion (`NODE_ENV=production` utan');
p('  `VERCEL_ENV=preview`) — vakten ligger i `apps/api/src/config.ts` och');
p('  regressionstestas i `apps/api/test/previewMockGate.test.ts`.');
p('- Ärliga begränsningar: `docs/LIMITATIONS.md`. Säkerhet: `docs/SECURITY.md`.');
p('  GDPR: `docs/PRIVACY.md`. Aktivering av Swish/Resend/Anthropic:');
p('  `docs/ACTIVATION.md`.');
p();
p('## 11. Så hålls handboken aktuell (reaktiviteten)');
p();
p('Handboken är en byggprodukt, inte ett dokument som kan glömmas: den');
p('genereras ur routetabellen, cores exporter, seeden, `.env.example` och');
p('`package.json`. `npm run verify` regenererar den och fallerar om (a) den');
p('committade filen skiljer sig från källorna, eller (b) en ny API-operation');
p('eller ett nytt kommando saknar instruktion. En ny funktion kan alltså inte');
p('nå `main` utan sin rad i handboken.');
p();

// Reaktivt antal: instruktionskartorna skrivs före seeden laddas, så talet
// substitueras här. Ett hårdkodat "72" överlevde annars tre kureringspass.
const content = L.join('\n').replaceAll('{{ANTAL_STOD}}', String(seed.opportunities.length));
if (CHECK) {
  let existing = null;
  try { existing = readFileSync(OUT, 'utf8'); } catch { /* saknas */ }
  if (existing !== content) {
    console.error('docs/MANUAL.md är INTE aktuell — kör `npm run manual` och committa.');
    process.exit(1);
  }
  console.log(`Handboken är aktuell (${routes.length} operationer, ${Object.keys(pkg.scripts).length} kommandon).`);
} else {
  writeFileSync(OUT, content);
  console.log(`Skrev docs/MANUAL.md (${routes.length} operationer dokumenterade).`);
}
