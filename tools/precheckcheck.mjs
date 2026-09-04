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
  if (rC.some((r) => r.status === 'utred' && !r.missing.length && !r.roundPending)) fail(`${k.path}: "utred" utan listade frågor`);
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
// Stödsidorna: verktyget finns exakt där seeden har frågor att ställa, bär
// underlagslistan, och motorn ger rätt utfall per stöd.
let medVerktyg = 0; let utanVerktyg = 0;
for (const o of opportunities) {
  const data = buildPrecheck({ path: `bidrag/${o.slug}`, headTerm: o.title }, [{ ...o, authority: authName.get(o.authorityKey) ?? o.authorityKey }]);
  const page = join(ROOT, 'artifacts/seo-site/bidrag', o.slug, 'index.html');
  const html = existsSync(page) ? readFileSync(page, 'utf8') : null;
  if (!data.questions.length) {
    utanVerktyg += 1;
    if (html && html.includes('id="precheck"')) fail(`${o.slug}: verktyg utan frågor`);
    continue;
  }
  medVerktyg += 1;
  for (const q of data.questions) if (q.type === 'birthYear' ? q.text !== BIRTH_YEAR_QUESTION : !seedQuestions.has(q.text)) fail(`${o.slug}: frågan står inte i seeden: "${q.text}"`);
  if (data.children[0].evidence.length !== (o.evidenceRequirements ?? []).length) fail(`${o.slug}: underlagslistan i verktyget ≠ seedens`);
  // Alla ja + det födelseår som passar stödets åldersvillkor (ung, vuxen, pensionär).
  const allMandatoryAsked = (o.criteria ?? []).filter((c) => c.kind === 'mandatory').every((c) => c.intakeQuestion);
  const rank = { ja: 2, utred: 1, nej: 0 };
  const rA = [1955, 1990, 2003].map((y) => evaluatePrecheck(data, Object.fromEntries(data.questions.map((q) => [q.id, q.type === 'birthYear' ? y : true])))[0]).sort((a, b) => rank[b.status] - rank[a.status])[0];
  if (rA.status === 'nej') fail(`${o.slug}: alla-ja gav "nej" (${rA.reasons.filter((e) => e.outcome === 'fail').map((e) => e.description).join('; ')})`);
  if (allMandatoryAsked && rA.status !== 'ja' && !rA.roundPending) fail(`${o.slug}: alla-ja gav "${rA.status}" trots att alla obligatoriska villkor har frågor`);
  if (rA.roundPending && !rA.roundNote) fail(`${o.slug}: stängd omgång utan förklaring`);
  const [rC] = evaluatePrecheck(data, {});
  if (rC.status === 'ja') fail(`${o.slug}: utan svar gav "ja"`);
  if (html) {
    if (!html.includes('id="precheck"')) fail(`${o.slug}: sidan saknar verktyget trots ${data.questions.length} frågor`);
    for (const q of data.questions) if (!html.includes(q.text.replace(/&/g, '&amp;'))) fail(`${o.slug}: frågan syns inte statiskt: "${q.text}"`);
  }
}
console.log(`  stödsidor: ${medVerktyg} med verktyg · ${utanVerktyg} utan (seeden har inga intagsfrågor där)`);

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
console.log(`precheckcheck OK: ${KLUSTER.length} klusterhubbar + ${medVerktyg} stödsidor — frågor ordagrant ur seeden, underlagslistan före utklick, motorns utfall på scenarierna, sidorna bär verktyget.`);
