/**
 * SEMANTIC COMPREHENSION TEST (FAS SEO-2) — testar inte om Google kan CRAWLA
 * sidan, utan om en maskin faktiskt FÖRSTÅR affärsmodellen enbart av den
 * publika HTML-texten. Detta är ett ovanligt men värdefullt QA-lager och ett
 * permanent regressionsskydd för den semantiska markpositionen (Open Discovery).
 *
 * Två lägen:
 *   • Offline (standard): deterministisk "surface-presence"-kontroll — varje av
 *     de 10 kärnpåståendena (seo/entity.json → claims) ska kunna dras ur den
 *     extraherbara publika texten. Kör överallt, utan nät, utan nyckel.
 *   • --llm: skickar den publika texten till Claude (ANTHROPIC_API_KEY) och
 *     ställer de 10 frågorna; FAIL om modellen tror att resultaten är
 *     betalväggade, att man måste välja bidrag först, eller att Bidragskoll är
 *     en myndighet. Utan nyckel: ärligt SKIPPED (exit 0).
 *
 *   node tools/semantictest.mjs            # offline, deterministisk
 *   node tools/semantictest.mjs --llm      # + modellförståelse (kräver nyckel)
 *
 * Publika ytor: startsidan (apps/web/index.html) + den genererade SEO-ytan
 * (artifacts/seo-site — kör tools/genseo.mjs först). Deterministisk offline.
 */
import { readFileSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const LLM = process.argv.includes('--llm');
const SITE = join(ROOT, 'artifacts', 'seo-site');

// ── Extrahera publik text (synlig text + JSON-LD, som en maskin läser) ───────
function publicText(html) {
  const ld = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].map((m) => m[1]).join('\n');
  const meta = [...html.matchAll(/<meta[^>]+(?:name|property)="(?:description|og:description|og:title)"[^>]+content="([^"]*)"/g)].map((m) => m[1]).join(' ');
  const title = html.match(/<title>([^<]*)<\/title>/)?.[1] ?? '';
  const visible = html
    .replace(/<script[\s\S]*?<\/script>/g, ' ')
    .replace(/<style[\s\S]*?<\/style>/g, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&[a-z]+;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  return `${title}\n${meta}\n${visible}\n${ld}`;
}

const SURFACES = [];
const idx = join(ROOT, 'apps/web/index.html');
if (existsSync(idx)) SURFACES.push({ name: 'startsidan (index.html)', text: publicText(readFileSync(idx, 'utf8')) });
const siteFiles = [
  ['hitta bidrag gratis', 'hitta-bidrag-gratis/index.html'],
  ['vilka bidrag kan jag få', 'vilka-bidrag-kan-jag-fa/index.html'],
  ['bidragskatalogen', 'bidrag/index.html'],
  ['ett faktiskt bidrag', 'bidrag/fk-bostadsbidrag-barnfamiljer/index.html'],
];
let siteOk = true;
for (const [name, rel] of siteFiles) {
  const p = join(SITE, rel);
  if (existsSync(p)) SURFACES.push({ name, text: publicText(readFileSync(p, 'utf8')) });
  else siteOk = false;
}
if (!siteOk) console.warn('OBS: artifacts/seo-site saknas delvis — kör `node tools/genseo.mjs` för full täckning. Kör offline-kontrollen på det som finns.\n');

const ALL = SURFACES.map((s) => s.text).join('\n\n').toLowerCase();

// ── Offline: de 10 påståendena ska ha stöd i den publika texten ──────────────
const entity = JSON.parse(readFileSync(join(ROOT, 'seo/entity.json'), 'utf8'));
const anyOf = (...res) => res.some((re) => re.test(ALL));
const CHECKS = [
  ['1. Upptäcker stöd man inte känner till', () => anyOf(/upptäck/, /du behöver inte känna till/, /behöver inte veta/)],
  ['2. Behöver inte veta vilket bidrag', () => anyOf(/behöver inte känna till bidragets namn/, /behöver inte veta/, /du behöver inte känna till/)],
  ['3. För privatpersoner, företag, enskild firma, föreningar', () => /privatperson/.test(ALL) && /företag/.test(ALL) && (/enskild/.test(ALL) || /näringsidkare/.test(ALL)) && /förening/.test(ALL)],
  ['4. Upptäckt/resultat är gratis', () => /gratis/.test(ALL) && anyOf(/upptäck/, /kontrollera/, /se vilka/)],
  ['5. Resultaten är inte betalväggade', () => anyOf(/inte låsta/, /inte låst/, /inte betalväggade/, /inte bakom en betalvägg/)],
  ['6. Kan ansöka själv hos officiell aktör', () => anyOf(/ansöka själv/, /ansök själv/, /ansöka själv hos/)],
  ['7. Länkar till officiella källor', () => anyOf(/officiell(a)? källa/, /officiella ansökningskällor/, /officiell ansökan/, /till källan/)],
  ['8. Har ett valfritt betalt verktygslager', () => anyOf(/valfri/, /19 kr/, /förbered/) && /kr/.test(ALL)],
  ['9. Verktyg för bevakning/administration/ansökningsförberedelse', () => anyOf(/bevakning/, /förbereda (en )?ansökan/, /administrera/, /förberedd ansökan/)],
  ['10. Är inte en myndighet / fattar inga beslut', () => anyOf(/inte en myndighet/, /inte en myndighet och fattar/, /beslut fattas alltid/, /oberoende/)],
];

let fails = 0;
console.log(`Semantic comprehension — offline surface presence (${SURFACES.length} ytor):`);
for (const [label, fn] of CHECKS) {
  const ok = fn();
  if (!ok) fails++;
  console.log(`  ${ok ? '✓' : '✗ SAKNAS'}  ${label}`);
}
if (fails) {
  console.error(`\n${fails}/10 kärnpåståenden saknar stöd i den publika texten — maskinen kan inte härleda affärsmodellen. FAIL.`);
  process.exit(1);
}
console.log('\nOffline: alla 10 kärnpåståenden har stöd i den publika texten. PASS.');

// ── LLM-läge: låt en modell läsa texten och svara på de 10 frågorna ──────────
if (!LLM) {
  console.log('(Kör med --llm för att låta en modell verifiera förståelsen. Kräver ANTHROPIC_API_KEY.)');
  process.exit(0);
}
const KEY = process.env.ANTHROPIC_API_KEY;
if (!KEY) {
  console.log('\n--llm begärt men ANTHROPIC_API_KEY saknas → SKIPPED (ärligt). Sätt nyckeln för modellverifiering.');
  process.exit(0);
}

const QUESTIONS = [
  'Vad gör Bidragskoll?',
  'Måste användaren redan veta vilket bidrag den söker?',
  'Vilka kan använda tjänsten?',
  'Kostar det att se relevanta bidrag?',
  'Kan användaren ansöka själv?',
  'Vad kostar pengar?',
  'Är Bidragskoll en myndighet?',
  'Varifrån kommer informationen om stöden?',
  'Vad skiljer tjänsten från en vanlig bidragsdatabas?',
  'Vad ska en person som inte vet vilka stöd den kan få göra?',
];
const model = process.env.SEMANTIC_TEST_MODEL || 'claude-opus-4-8';
const prompt = `Du får ENBART den publika texten från en webbtjänst nedan. Svara kort på varje fråga UTIFRÅN ENBART texten, och returnera ett JSON-objekt: {"answers":[10 strängar],"verdicts":{"paywalled":bool,"mustPickGrantFirst":bool,"isAuthority":bool,"understandsFreeVsPaid":bool}}. paywalled=true om du tror att man måste betala för att SE resultaten. mustPickGrantFirst=true om du tror att man först måste välja/veta vilket bidrag man söker. isAuthority=true om du tror att tjänsten är en myndighet. understandsFreeVsPaid=true om du tydligt kan skilja gratis upptäckt från det valfria betalda verktygslagret.\n\nFRÅGOR:\n${QUESTIONS.map((q, i) => `${i + 1}. ${q}`).join('\n')}\n\nPUBLIK TEXT:\n"""\n${SURFACES.map((s) => `### ${s.name}\n${s.text}`).join('\n\n').slice(0, 40000)}\n"""`;

console.log(`\nLLM-verifiering (${model}) …`);
let data;
try {
  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: { 'content-type': 'application/json', 'x-api-key': KEY, 'anthropic-version': '2023-06-01' },
    body: JSON.stringify({ model, max_tokens: 1500, messages: [{ role: 'user', content: prompt }] }),
  });
  if (!res.ok) { console.error(`API-fel ${res.status}: ${(await res.text()).slice(0, 200)}`); process.exit(1); }
  const body = await res.json();
  const txt = body.content?.map((c) => c.text).join('') ?? '';
  data = JSON.parse(txt.match(/\{[\s\S]*\}/)?.[0] ?? '{}');
} catch (e) { console.error('LLM-anrop misslyckades: ' + e.message); process.exit(1); }

const v = data.verdicts ?? {};
(data.answers ?? []).forEach((a, i) => console.log(`  Q${i + 1}: ${a}`));
const llmFails = [];
if (v.paywalled) llmFails.push('modellen tror att resultaten är betalväggade');
if (v.mustPickGrantFirst) llmFails.push('modellen tror att man måste välja bidrag först');
if (v.isAuthority) llmFails.push('modellen tror att Bidragskoll är en myndighet');
if (v.understandsFreeVsPaid === false) llmFails.push('modellen kan inte skilja gratis upptäckt från betalt verktygslager');
if (llmFails.length) {
  console.error('\nLLM-FAIL:\n - ' + llmFails.join('\n - ') + '\n→ Ändra informationsarkitekturen och testa igen.');
  process.exit(1);
}
console.log('\nLLM: modellen förstår affärsmodellen korrekt (inte betalväggad, inget förkunskapskrav, inte myndighet, gratis vs betalt tydligt). PASS.');
