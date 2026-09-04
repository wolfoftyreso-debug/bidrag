/**
 * Vakt för behörighetskontrollen (CONTENT_ENGINE F0 modul 4/5) — körs i verify + CI:
 *
 *  1. Varje klusterhubb (seo/kluster.json) får ett frågeset, och varje fråga
 *     är ORDAGRANT seedens intagsfråga eller produktens födelseårsfråga —
 *     verktyget hittar aldrig på en fråga (SEO_SITUATION_ONTOLOGY §3-regeln).
 *  2. Motorn ger rätt utfall på kända scenarier: alla-ja + vuxen ⇒ minst ett
 *     stöd "ja"; alla-nej ⇒ inget "ja"; inga svar ⇒ allt "utred" (obesvarat
 *     räknas aldrig som uppfyllt).
 *  3. Den genererade ytan bär verktyget: /assets/precheck.js finns, varje
 *     klusterhubb har #precheck + inbäddad data som parsar och matchar
 *     byggets frågeset, plus den statiska fallbacken med frågorna synliga.
 *
 *   node tools/precheckcheck.mjs
 */
import { existsSync, readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildPrecheck, evaluatePrecheck, BIRTH_YEAR_QUESTION } from './precheck/logic.mjs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const { opportunities, authorities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const KLUSTER = JSON.parse(readFileSync(join(ROOT, 'seo/kluster.json'), 'utf8')).kluster;
const authName = new Map(authorities.map((a) => [a.key, a.name]));
const seedQuestions = new Set(opportunities.flatMap((o) => (o.criteria ?? []).map((c) => c.intakeQuestion).filter(Boolean)));

let errors = 0;
const fail = (m) => { console.log('  FEL  ' + m); errors += 1; };

for (const k of KLUSTER) {
  const children = k.childSlugs.map((s) => opportunities.find((o) => o.slug === s)).filter(Boolean).map((o) => ({
    ...o, title: o.title, authority: authName.get(o.authorityKey) ?? o.authorityKey,
  }));
  const data = buildPrecheck(k, children);
  if (!data.questions.length) fail(`${k.path}: inga frågor — verktyget kan inte bedöma något`);
  for (const q of data.questions) {
    if (q.type === 'birthYear' ? q.text !== BIRTH_YEAR_QUESTION : !seedQuestions.has(q.text)) fail(`${k.path}: frågan står inte ordagrant i seeden: "${q.text}"`);
  }
  // Scenario A: alla ja, född 1990 ⇒ minst ett stöd ser ut att kunna gälla.
  const yes = Object.fromEntries(data.questions.map((q) => [q.id, q.type === 'birthYear' ? 1990 : true]));
  const rA = evaluatePrecheck(data, yes);
  if (!rA.some((r) => r.status === 'ja')) fail(`${k.path}: alla-ja gav inget "ja" (${rA.map((r) => `${r.slug}=${r.status}`).join(', ')})`);
  // Scenario B: alla nej ⇒ inget "ja".
  const no = Object.fromEntries(data.questions.map((q) => [q.id, q.type === 'birthYear' ? 1990 : false]));
  const rB = evaluatePrecheck(data, no);
  if (rB.some((r) => r.status === 'ja')) fail(`${k.path}: alla-nej gav ett "ja"`);
  // Scenario C: inga svar ⇒ inget "ja" (obesvarat är aldrig uppfyllt) och saknade frågor listas.
  const rC = evaluatePrecheck(data, {});
  if (rC.some((r) => r.status === 'ja')) fail(`${k.path}: utan svar gav ett "ja"`);
  if (rC.some((r) => r.status === 'utred' && !r.missing.length)) fail(`${k.path}: "utred" utan listade frågor`);
  console.log(`  ${k.path}: ${data.questions.length} frågor · ${data.children.length} stöd · alla-ja ⇒ ${rA.filter((r) => r.status === 'ja').length} ja · alla-nej ⇒ ${rB.filter((r) => r.status === 'nej').length} nej · tomt ⇒ ${rC.filter((r) => r.status === 'utred').length} utred`);

  // Den genererade sidan (om ytan finns).
  const page = join(ROOT, 'artifacts/seo-site', k.path, 'index.html');
  if (existsSync(page)) {
    const html = readFileSync(page, 'utf8');
    if (!html.includes('id="precheck"')) fail(`${k.path}: sidan saknar #precheck`);
    if (!html.includes('src="/assets/precheck.js"')) fail(`${k.path}: sidan laddar inte /assets/precheck.js`);
    const m = html.match(/<script type="application\/json" id="precheck-data">([\s\S]*?)<\/script>/);
    if (!m) fail(`${k.path}: inbäddad data saknas`);
    else {
      const embedded = JSON.parse(m[1].replace(/\\u003c/g, '<').replace(/\\u003e/g, '>'));
      if (embedded.questions.length !== data.questions.length) fail(`${k.path}: sidans frågeset (${embedded.questions.length}) ≠ byggets (${data.questions.length})`);
    }
    for (const q of data.questions) if (!html.includes(q.text.replace(/&/g, '&amp;'))) fail(`${k.path}: frågan syns inte statiskt: "${q.text}"`);
  }
}
const asset = join(ROOT, 'artifacts/seo-site/assets/precheck.js');
if (existsSync(join(ROOT, 'artifacts/seo-site'))) {
  if (!existsSync(asset)) fail('artifacts/seo-site/assets/precheck.js saknas');
  else {
    const kb = Math.round(readFileSync(asset).length / 1024);
    if (kb > 120) fail(`precheck.js väger ${kb} kB (> 120 kB) — Core Web Vitals-budgeten`);
    else console.log(`  /assets/precheck.js: ${kb} kB`);
  }
}

if (errors) { console.log(`precheckcheck: ${errors} fel`); process.exit(1); }
console.log(`precheckcheck OK: ${KLUSTER.length} klusterhubbar — frågor ordagrant ur seeden, motorns utfall på tre scenarier, sidorna bär verktyget.`);
