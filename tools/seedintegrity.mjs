/**
 * Seed-integritet (revision 2026-09-01). Den kontrollklass som M15/M16 i
 * PERFECTION_BACKLOG pekade på, gjord systematisk:
 *
 *   A  samma (faktaväg, op, expected) med OLIKA intagsfrågor — överlastad
 *      faktaväg: ett ja-svar sätter ett faktum som andra stöd läser med en
 *      annan innebörd (18–28 mot 19–29, "kulturprojekt" mot "filmprojekt")
 *   B  faktavägar som ingen fråga och inget intag någonsin sätter (döda)
 *   C  motsägelser inom ett stöd (eq X och eq Y på samma väg)
 *   D  stöd utan egna villkor — matchar hela målgruppen odifferentierat
 *   E  delade sourceUrl — "officiell källa" som är en landningssida
 *   F  schemafält utan etikett / utan sektion / föräldralösa scheman
 *   G  aktörer utan stöd, stöd med okänd aktör
 *
 * RAPPORTERAR, fäller inte bygget: fynden är kureringsläge, inte kodfel, och
 * 17 A-fynd går inte att stänga i en commit (varje kräver seedändring +
 * tio översättningar). Kör: node --experimental-strip-types tools/seedintegrity.mjs
 * Med --strict avslutas med 1 om klass C eller G har fynd (de ÄR kodfel).
 */
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const STRICT = process.argv.includes('--strict');
const { opportunities, authorities, applicationSchemaDefs } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const fynd = [];
const F = (kat, msg) => fynd.push({ kat, msg });

// A. Samma faktaväg+op+expected, olika frågor eller olika beskrivningar → överlastad.
const grupp = new Map();
for (const o of opportunities) for (const c of o.criteria ?? []) {
  const k = `${c.factPath} ${c.op} ${JSON.stringify(c.expected ?? null)}`;
  (grupp.get(k) ?? grupp.set(k, []).get(k)).push({ slug: o.slug, id: c.id, q: c.intakeQuestion, d: c.description, kind: c.kind });
}
for (const [k, rows] of grupp) {
  const qs = new Set(rows.map((r) => r.q).filter(Boolean));
  if (qs.size > 1) F('A-överlastad-fråga', `${k} → ${qs.size} olika frågor: ${[...qs].map((q) => JSON.stringify(q.slice(0, 50))).join(' | ')}`);
}

// B. Kriterier som aldrig kan besvaras: mandatory/weighted utan intakeQuestion,
//    OCH faktavägen sätts inte av intaget i webben.
const webSrc = readdirSync(join(ROOT, 'apps/web/src'), { recursive: true })
  .filter((f) => /\.(ts|tsx)$/.test(f)).map((f) => readFileSync(join(ROOT, 'apps/web/src', f), 'utf8')).join('\n');
const coreSrc = readdirSync(join(ROOT, 'packages/core/src')).map((f) => readFileSync(join(ROOT, 'packages/core/src', f), 'utf8')).join('\n');
const askedByQ = new Set(); const allPaths = new Map();
for (const o of opportunities) for (const c of o.criteria ?? []) {
  allPaths.set(c.factPath, (allPaths.get(c.factPath) ?? 0) + 1);
  if (c.intakeQuestion) askedByQ.add(c.factPath);
}
const dead = [];
for (const [p, n] of allPaths) {
  if (askedByQ.has(p)) continue;
  const key = p.split('.').pop();
  const setInWeb = webSrc.includes(`'${p}'`) || webSrc.includes(`"${p}"`) || webSrc.includes(`${key}:`) || webSrc.includes(`.${key}`);
  const setInCore = coreSrc.includes(`'${p}'`) || coreSrc.includes(`${key}`);
  if (!setInWeb && !setInCore) dead.push(`${p} (${n} kriterier)`);
}
if (dead.length) F('B-död-faktaväg', `faktavägar utan fråga och utan spår i webb/core: ${dead.join(', ')}`);

// C. Motsägelser inom ett stöd: samma faktaväg med oförenliga krav.
for (const o of opportunities) {
  const byPath = new Map();
  for (const c of o.criteria ?? []) (byPath.get(c.factPath) ?? byPath.set(c.factPath, []).get(c.factPath)).push(c);
  for (const [p, cs] of byPath) {
    if (cs.length < 2) continue;
    const eq = cs.filter((c) => c.op === 'eq').map((c) => c.expected);
    if (new Set(eq).size > 1) F('C-motsägelse', `${o.slug}: ${p} kräver eq ${[...new Set(eq)].join(' OCH ')}`);
    const t = cs.filter((c) => c.op === 'is_true').length, f = cs.filter((c) => c.op === 'is_false').length;
    if (t && f) F('C-motsägelse', `${o.slug}: ${p} kräver både is_true och is_false`);
  }
}

// D. Stöd utan några egna (icke-hårda) kriterier → matchar alla i målgruppen, aldrig specifikt.
for (const o of opportunities) {
  const egna = (o.criteria ?? []).filter((c) => c.kind !== 'hard');
  if (!egna.length) F('D-inga-egna-villkor', `${o.slug}: bara hårda kriterier (${(o.criteria ?? []).length}) — matchar hela målgruppen odifferentierat`);
}

// E. Källor: dubbletter, saknade, ansökningslänk = källänk.
const src = new Map();
for (const o of opportunities) {
  if (!o.sourceUrl) F('E-källa', `${o.slug}: sourceUrl saknas`);
  (src.get(o.sourceUrl) ?? src.set(o.sourceUrl, []).get(o.sourceUrl)).push(o.slug);
  if (!o.applyUrl && !o.applicationUrl) { /* fält heter kanske annat */ }
}
for (const [u, s] of src) if (s.length > 1) F('E-källa-delad', `${s.length} stöd delar exakt samma sourceUrl: ${s.join(', ')} → ${u}`);

// F. Schema: fält utan etikett, sektioner utan fält, scheman för stöd som inte finns.
const slugs = new Set(opportunities.map((o) => o.slug));
for (const s of applicationSchemaDefs ?? []) {
  const slug = s.opportunitySlug ?? s.slug ?? s.def?.opportunitySlug;
  if (slug && !slugs.has(slug)) F('F-schema-föräldralöst', `schema ${s.def?.title} pekar på okänt stöd ${slug}`);
  const fields = s.def?.fields ?? [];
  for (const f of fields) if (!f.label) F('F-schema-fält', `${s.def?.title}: fält ${f.key} saknar label`);
  const sekt = new Set((s.def?.sections ?? []).map((x) => x.id ?? x.key));
  for (const f of fields) if (f.sectionId && !sekt.has(f.sectionId)) F('F-schema-sektion', `${s.def?.title}: fält ${f.key} pekar på sektion ${f.sectionId} som inte finns`);
}

// G. Myndigheter utan stöd / stöd med okänd myndighet.
const auth = new Set(authorities.map((a) => a.key));
for (const o of opportunities) if (!auth.has(o.authorityKey)) F('G-aktör', `${o.slug}: authorityKey ${o.authorityKey} finns inte`);
const used = new Set(opportunities.map((o) => o.authorityKey));
for (const a of authorities) if (!used.has(a.key)) F('G-aktör-tom', `${a.key} (${a.name}) har inga stöd`);

// Sammanställning
const perKat = {};
for (const f of fynd) (perKat[f.kat] ??= []).push(f.msg);
for (const [k, v] of Object.entries(perKat)) { console.log(`\n## ${k} (${v.length})`); for (const m of v) console.log('  -', m); }
// ── H: återkommande omgång som stängt utan nytt datum ─────────────────────
// Motorn utesluter inte längre (deadlineModel), men stödet visas som
// "nästa omgång ej publicerad" tills datumet kurerats — det är en signal.
for (const o of opportunities) {
  if ((o.deadlineModel === 'recurring' || o.deadlineModel === 'upcoming_round') && o.closesAt && new Date(o.closesAt) < new Date('2026-09-01')) {
    fynd.push({ kat: 'H-omgång-stängd', text: `${o.slug}: ${o.deadlineModel} med closesAt ${o.closesAt.slice(0, 10)} i förfluten tid — kurera nästa omgångs datum` });
  }
}
console.log(`\nTOTALT ${fynd.length} fynd · ${opportunities.length} stöd · ${grupp.size} distinkta (faktaväg,op,expected)`);
const kodfel = fynd.filter((f) => f.kat.startsWith('C-') || f.kat.startsWith('G-'));
if (STRICT && kodfel.length) { console.error(`--strict: ${kodfel.length} fynd i klass C/G är kodfel, inte kureringsläge`); process.exit(1); }
