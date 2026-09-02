/**
 * MOTORSIMULERING I STOR SKALA (revision 2026-09-01).
 *
 * simulate30 kör 30 handskrivna personor genom API:t. Det här kör MOTORN
 * (packages/core, samma computeMatch + spårfilter som produkten) mot ett
 * systematiskt genererat faktarum: tusentals koherenta personor per
 * sökandetyp, byggda ur seedens egna faktavägar och värdedomäner, med
 * åldersfakta härledda EXAKT som intagen härleder dem. Ingen server, ingen
 * databas, ingen rate-limit.
 *
 * Mäter och flaggar:
 *   DÖD        stöd som ingen persona av rätt typ någonsin blir 'eligible' för
 *   UNIVERSELL stöd som nästan alla av sin typ blir eligible för utan att
 *              ett enda obligatoriskt villkor prövats
 *   NOLL       personor som efter spårfiltret inte får ett enda synligt stöd
 *   LÄCKA      sektorsgrindat stöd synligt för en persona på personspåret
 *              (audit-relevans-regeln, men över hela faktarummet)
 *   ÅLDER      konkreta felmatchningar vid åldersgränserna med produktens
 *              härledning (M15) — deterministiskt bevis, inte statistik
 *   FRÅGEBÖRDA hur många öppna frågor en persona möter, och vilka frågor
 *              som avgör flest stöd (§7 informationsvärde)
 *   DATUMSVEP  status per månad ett år framåt för alla stöd med datum/modell
 *
 *   node --experimental-strip-types tools/simulate-engine.mjs [--n=4000] [--strict] [--seed=1]
 *
 * Rapporterar alltid; --strict avslutar med 1 vid DÖD eller LÄCKA (de är
 * kod-/seedfel, inte kureringsläge). Deterministisk: egen PRNG med frö.
 * Utdata: artifacts/simulate-engine.json
 */
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { mkdirSync, writeFileSync } from 'node:fs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const arg = (k, d) => { const a = process.argv.find((x) => x.startsWith(`--${k}=`)); return a ? a.slice(k.length + 3) : d; };
const N = Number(arg('n', 4000));
const STRICT = process.argv.includes('--strict');
let seed = Number(arg('seed', 1)) >>> 0 || 1;
const rnd = () => { seed ^= seed << 13; seed >>>= 0; seed ^= seed >>> 17; seed ^= seed << 5; seed >>>= 0; return seed / 4294967296; };
const pick = (a) => a[Math.floor(rnd() * a.length)];
const chance = (p) => rnd() < p;

const core = await import(join(ROOT, 'packages/core/dist/index.js'));
const { computeMatch, detectTrack, relevantForTrack } = core;
const derive = core.deriveAgeFacts ?? ((age) => ({
  'person.ageYears': age, 'person.ageUnder29': age <= 28, 'person.age24Plus': age >= 24, 'person.age40OrYounger': age <= 40,
  'person.age60Plus': age >= 60, 'person.age62Plus': age >= 62, 'person.age66Plus': age >= 66, 'person.age67Plus': age >= 67,
  'person.ageBand': age < 20 ? 'under20' : age <= 28 ? '20-28' : age <= 65 ? '29-65' : '66plus',
}));
const { opportunities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const REF = '2026-09-01';

// ── Faktarummet ur seeden ──────────────────────────────────────────────────
const domain = new Map(); // factPath -> { bool, values:Set, array }
for (const o of opportunities) for (const c of o.criteria ?? []) {
  const d = domain.get(c.factPath) ?? { bool: false, values: new Set(), array: false };
  if (c.op === 'is_true' || c.op === 'is_false') d.bool = true;
  if (c.op === 'eq') d.values.add(c.expected);
  if (c.op === 'in') for (const v of c.expected) d.values.add(v);
  if (c.op === 'includes') { d.array = true; d.values.add(c.expected); }
  if (c.op === 'intersects') { d.array = true; for (const v of c.expected) d.values.add(v); }
  domain.set(c.factPath, d);
}
const AGE_KEYS = new Set(Object.keys(derive(30)));
const TYPES = ['individual', 'association', 'informal_group', 'company', 'economic_association', 'foundation', 'municipality', 'region', 'public_body', 'university', 'school'];
const PERSONAL_TYPES = new Set(['individual']);
const BUSINESS_SECTORS = [...(domain.get('project.sector')?.values ?? [])].filter((s) => s !== 'personal');

const INTAKE = process.argv.includes('--intake');
/**
 * Speglar intagen (apps/web Onboarding + demo/main.tsx buildFacts):
 *  - personspåret: privatperson, project.sector = 'personal' (F-RELEVANS)
 *  - enskild firma: SAMMA sökandetyp 'individual' + selfEmployed + egen sektor
 *  - projektspåret: privatperson/informell grupp med projekt — här ställs
 *    "yrkesverksam konstnär" (pr-artist); organisationer får sektor + projekt-
 *    fakta; projektledarfakta (doktorsexamen) hör till projektspåret
 * --intake: bara de fakta intaget faktiskt sätter — resten okänt, så
 * frågebördan mäts som användaren möter den.
 */
function persona(type) {
  const f = { 'applicant.type': type, 'applicant.country': chance(0.92) ? 'SE' : pick(['NO', 'DE', 'FI']) };
  const fillRest = (prefixes, p) => {
    if (INTAKE) return;
    for (const [path, d] of domain) {
      if (!prefixes.some((pre) => path.startsWith(pre)) || AGE_KEYS.has(path) || path in f) continue;
      if (d.array) { const vals = [...d.values]; const k = Math.floor(rnd() * Math.min(4, vals.length + 1)); const set = new Set(); for (let i = 0; i < k; i++) set.add(pick(vals)); f[path] = [...set]; continue; }
      if (d.bool) f[path] = chance(p);
      else if (d.values.size) f[path] = pick([...d.values]);
    }
  };
  if (type === 'individual') {
    const age = 16 + Math.floor(rnd() * 80);
    Object.assign(f, derive(age));
    const track = chance(0.8) ? 'personal' : 'project';
    f['person.track'] = track;
    if (track === 'personal') {
      const emp = pick(['working', 'unemployed', 'retired', 'studying', 'self_employed', 'sick']);
      f['person.employmentStatus'] = emp;
      if (emp === 'studying') f['person.isOrPlansStudying'] = true;
      f['person.receivesPension'] = emp === 'retired';
      f['person.registeredUnemployed'] = emp === 'unemployed';
      f['person.selfEmployed'] = emp === 'self_employed';
      f['person.hasChildrenAtHome'] = chance(0.4);
      f['person.householdType'] = pick(['single', 'couple']);
      if (emp === 'sick') f['person.reducedWorkCapacityLongTerm'] = chance(0.6);
      const band = pick(['under15', '15-25', '25-40', 'over40']);
      f['person.lowHouseholdIncome'] = band === 'under15' || band === '15-25';
      if (band === 'under15') f['person.incomeInsufficientForBasicNeeds'] = true;
      if (emp === 'self_employed') { f['person.businessForm'] = 'sole_trader'; if (chance(0.85)) f['project.sector'] = pick(BUSINESS_SECTORS); }
      else f['project.sector'] = 'personal';
      fillRest(['person.'], 0.3);
      if (f['person.hasChildrenAtHome'] === false) for (const k of Object.keys(f)) if (/^person\.child/.test(k)) f[k] = false;
    } else {
      f['person.professionalArtist'] = chance(0.5);
      if (chance(0.9)) f['project.sector'] = pick(BUSINESS_SECTORS);
      fillRest(['person.', 'project.'], 0.4);
    }
  } else {
    if (chance(0.9)) f['project.sector'] = pick(BUSINESS_SECTORS);
    if (type === 'informal_group') f['person.professionalArtist'] = chance(0.5);
    fillRest(['organisation.', 'project.', 'person.'], 0.45);
  }
  return f;
}

function runOne(facts, referenceDate = REF) {
  const rows = opportunities.map((o) => ({
    slug: o.slug, instrumentType: o.instrumentType, sectors: o.sectors, applicantTypes: o.applicantTypes, opportunity: o,
    result: computeMatch({
      criteria: o.criteria ?? [], facts, evidenceRequirements: o.evidenceRequirements ?? [], availableEvidenceKinds: [],
      referenceDate, deadline: o.closesAt ?? null, deadlineModel: o.deadlineModel, estimatedEffortDays: o.estimatedEffortDays, lastVerifiedAt: o.lastVerifiedAt ?? null,
    }),
  }));
  const visible = relevantForTrack(rows, detectTrack(facts), { selfEmployed: facts['person.selfEmployed'] === true, sector: facts['project.sector'] });
  return { rows, visible };
}

// ── Kör ────────────────────────────────────────────────────────────────────
const perType = Object.fromEntries(TYPES.map((t) => [t, t === 'individual' ? N : ['association', 'company'].includes(t) ? Math.round(N / 2) : Math.round(N / 10)]));
const stat = new Map(opportunities.map((o) => [o.slug, { eligible: 0, unknown: 0, excluded: 0, seen: 0, visible: 0 }]));
const zero = {}; const burden = []; const questionValue = new Map(); const leaks = new Map(); let personas = 0;
const t0 = Date.now();
for (const type of TYPES) {
  for (let i = 0; i < perType[type]; i++) {
    const facts = persona(type); personas++;
    const { rows, visible } = runOne(facts);
    const visSlugs = new Set(visible.map((r) => r.slug));
    let shown = 0; const qs = new Set();
    for (const r of rows) {
      const s = stat.get(r.slug); const st = r.result.eligibilityStatus;
      if ((r.opportunity.applicantTypes ?? []).includes(type)) { s.seen++; s[st]++; }
      if (!visSlugs.has(r.slug) || st === 'excluded') continue;
      s.visible++; shown++;
      for (const m of r.result.missingFacts) { qs.add(m.question); questionValue.set(m.question, (questionValue.get(m.question) ?? 0) + 1); }
      // LÄCKA: personspår + stöd med sektorsgrind ≠ personal som ändå syns
      if (facts['project.sector'] === 'personal') {
        const gated = (r.opportunity.criteria ?? []).some((c) => c.factPath === 'project.sector' && !(c.op === 'eq' && c.expected === 'personal'));
        if (gated) leaks.set(r.slug, (leaks.get(r.slug) ?? 0) + 1);
      }
    }
    if (shown === 0) zero[type] = (zero[type] ?? 0) + 1;
    if (type === 'individual' && facts['person.track'] === 'personal') burden.push(qs.size);
  }
}
const ms = Date.now() - t0;

// ── Analys ─────────────────────────────────────────────────────────────────
const fynd = [];
const dead = [], universal = [];
for (const o of opportunities) {
  const s = stat.get(o.slug); if (!s.seen) continue;
  const mand = (o.criteria ?? []).filter((c) => c.kind !== 'hard').length;
  // DÖD = uteslutet för VARJE persona av rätt typ (aldrig eligible, aldrig ens
  // unknown). Ett stöd som bara väntar på svar eller på nästa omgång är inte
  // dött. I intagsläget är eligible/unknown-fördelningen inte meningsfull
  // (nästan allt väntar på svar), så DÖD/UNIVERSELL mäts bara i standardläget.
  if (!INTAKE && s.eligible === 0 && s.unknown === 0) { dead.push(o.slug); fynd.push({ kat: 'DÖD', slug: o.slug, detalj: `uteslutet för samtliga ${s.seen} personor av rätt typ` }); }
  if (!INTAKE && mand === 0 && s.eligible / s.seen > 0.9) { universal.push(o.slug); fynd.push({ kat: 'UNIVERSELL', slug: o.slug, detalj: `${Math.round(100 * s.eligible / s.seen)} % eligible utan ett enda obligatoriskt villkor` }); }
  if (!INTAKE && s.eligible === 0 && s.unknown > 0 && s.unknown / s.seen < 0.05) fynd.push({ kat: 'SÄLLSYNT', slug: o.slug, detalj: `aldrig eligible; bara ${s.unknown} av ${s.seen} ens unknown — kombinationen är extremt smal eller faktum saknas i intaget` });
}
for (const [slug, n] of leaks) fynd.push({ kat: 'LÄCKA', slug, detalj: `synligt för ${n} personspårs-personor trots sektorsgrind` });
for (const [type, n] of Object.entries(zero)) fynd.push({ kat: 'NOLL', slug: type, detalj: `${n} av ${perType[type]} personor fick inget synligt stöd` });

// ÅLDER — deterministiskt bevis vid gränserna med produktens härledning.
const ageProof = [];
for (const age of [17, 18, 19, 28, 29, 30]) {
  const facts = { 'applicant.type': 'individual', 'applicant.country': 'SE', ...derive(age), 'person.employmentStatus': 'unemployed', 'person.registeredUnemployed': true, 'project.sector': 'personal', 'person.paysHousingCost': true, 'person.lowHouseholdIncome': true, 'person.reducedWorkCapacityLongTerm': true };
  const { rows } = runOne(facts);
  const get = (slug) => rows.find((r) => r.slug === slug)?.result.eligibilityStatus;
  const bbu = get('fk-bostadsbidrag-unga'), ae = get('fk-aktivitetsersattning');
  const bbuRight = age >= 18 && age <= 28 ? bbu !== 'excluded' : bbu === 'excluded';
  const aeRight = age >= 19 && age <= 29 ? ae !== 'excluded' : ae === 'excluded';
  ageProof.push({ age, bostadsbidragUnga: bbu, aktivitetsersattning: ae, ok: bbuRight && aeRight });
  if (!(bbuRight && aeRight)) fynd.push({ kat: 'ÅLDER', slug: `${age} år`, detalj: `bostadsbidrag unga=${bbu} (rätt: ${age >= 18 && age <= 28 ? 'ej excluded' : 'excluded'}), aktivitetsersättning=${ae} (rätt: ${age >= 19 && age <= 29 ? 'ej excluded' : 'excluded'})` });
}

// DATUMSVEP
const sweep = [];
for (const o of opportunities) {
  if (!o.closesAt && o.deadlineModel === 'rolling') continue;
  const statuses = [];
  for (let m = 0; m < 12; m++) {
    const d = new Date(Date.UTC(2026, 8 + m, 1)).toISOString().slice(0, 10);
    const r = computeMatch({ criteria: [], facts: {}, evidenceRequirements: [], availableEvidenceKinds: [], referenceDate: d, deadline: o.closesAt ?? null, deadlineModel: o.deadlineModel });
    statuses.push(r.eligibilityStatus === 'excluded' ? 'stängd' : r.eligibilityStatus === 'unknown' ? 'väntar' : 'öppen');
  }
  sweep.push({ slug: o.slug, model: o.deadlineModel, closesAt: o.closesAt ?? null, statuses });
  if (o.closesAt && statuses.every((s) => s !== 'öppen')) fynd.push({ kat: 'DATUM', slug: o.slug, detalj: `closesAt ${o.closesAt} — ${statuses[0]} hela året framåt; ${o.deadlineModel === 'one_time' ? 'engångsomgång som passerat' : 'nästa omgång ej kurerad'}` });
}

burden.sort((a, b) => a - b);
const q = (p) => burden[Math.min(burden.length - 1, Math.floor(p * burden.length))];
const topQ = [...questionValue].sort((a, b) => b[1] - a[1]).slice(0, 12);

// ── Rapport ────────────────────────────────────────────────────────────────
console.log(`Motorsimulering${INTAKE ? ' (intagsläge: bara intagets fakta kända)' : ''}: ${personas} personor × ${opportunities.length} stöd = ${(personas * opportunities.length).toLocaleString('sv-SE')} matchningar på ${(ms / 1000).toFixed(1)} s`);
console.log(`Fördelning: ${Object.entries(perType).map(([t, n]) => `${t} ${n}`).join(', ')}`);
console.log('\nÅLDERSGRÄNSERNA (produktens härledning):');
for (const a of ageProof) console.log(`  ${String(a.age).padStart(2)} år  bostadsbidrag unga=${a.bostadsbidragUnga.padEnd(8)} aktivitetsersättning=${a.aktivitetsersattning.padEnd(8)} ${a.ok ? '✓' : '✗ FEL'}`);
console.log(`\nFRÅGEBÖRDA (privatpersoner, unika öppna frågor): p50 ${q(0.5)} · p90 ${q(0.9)} · max ${burden[burden.length - 1]}`);
console.log('Frågor med högst informationsvärde (antal stöd de avgör, summerat):');
for (const [qq, n] of topQ) console.log(`  ${String(n).padStart(6)}  ${qq}`);
console.log(`\nDATUMSVEP: ${sweep.length} stöd med datum/modell kontrollerade 12 månader framåt`);
const byKat = {}; for (const f of fynd) byKat[f.kat] = (byKat[f.kat] ?? 0) + 1;
console.log(`\nFYND: ${fynd.length} — ${Object.entries(byKat).map(([k, v]) => `${k} ${v}`).join(' · ') || 'inga'}`);
for (const f of fynd) console.log(`  ${f.kat.padEnd(10)} ${f.slug.padEnd(42)} ${f.detalj}`);

mkdirSync(join(ROOT, 'artifacts'), { recursive: true });
writeFileSync(join(ROOT, 'artifacts', 'simulate-engine.json'), JSON.stringify({ personas, perType, ms, stat: Object.fromEntries(stat), ageProof, burden: { p50: q(0.5), p90: q(0.9), max: burden[burden.length - 1] }, topQuestions: topQ, sweep, fynd }, null, 2));
const hard = fynd.filter((f) => f.kat === 'DÖD' || f.kat === 'LÄCKA');
if (STRICT && hard.length) { console.error(`--strict: ${hard.length} fynd i klass DÖD/LÄCKA`); process.exit(1); }
