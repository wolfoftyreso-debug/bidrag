/**
 * Sprint 01: kunskapsgrafen v1 (seo/kunskapsgraf.json) — genereras ur
 * sanningsmodellen (apps/api/src/seed/data.ts) + intentlagret
 * (seo/intents-100.json). Grafen är innehållsmotorns lager 6
 * (docs/CONTENT_ENGINE.md §3/§7): den driver internlänkning, relaterade stöd,
 * situationssidor och framtida rekommendationer — samma data som produkten,
 * så grafen kan aldrig divergera från kunskapsbasen.
 *
 * Nodtyper v1: stod, myndighet, malgrupp (hubbar), kriterium (faktafält),
 * intent (kluster/situation/process ur intents-100 — entity-intents pekar
 * redan på stödnoden och dubbleras inte).
 * Kanttyper: stod-ges_av->myndighet · stod-riktar_sig_till->malgrupp ·
 * stod-kraver/vager_in->kriterium · intent-besvaras_av->stod ·
 * intent-i_kluster-> (cluster_id) · stod-relaterad->stod (delar ≥2 kriteriefält
 * och samma målgruppshubb — grunden för "relaterade stöd"-modulen).
 *
 *   node --experimental-strip-types tools/genkgraf.mjs          # skriv
 *   node --experimental-strip-types tools/genkgraf.mjs --check  # i synk?
 *
 * Deterministisk: sorterad utdata; inga datum ur klockan (CURATED_AT).
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'seo', 'kunskapsgraf.json');
const CHECK = process.argv.includes('--check');

const { opportunities, authorities, CURATED_AT } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const intents = JSON.parse(readFileSync(join(ROOT, 'seo', 'intents-100.json'), 'utf8')).intents;

const HUBS = [
  { slug: 'privatpersoner', types: ['individual'] },
  { slug: 'foretag', types: ['company', 'economic_association'] },
  { slug: 'foreningar', types: ['association', 'informal_group'] },
  { slug: 'offentlig-sektor', types: ['municipality', 'region', 'public_body', 'university'] },
];

const nodes = [];
const edges = [];
const addNode = (id, type, label, extra = {}) => nodes.push({ id, type, label, ...extra });
const addEdge = (from, rel, to) => edges.push({ from, rel, to });

// Myndigheter
for (const a of authorities) addNode(`myndighet:${a.key}`, 'myndighet', a.name, { url: a.website ?? null });
// Målgruppshubbar
for (const h of HUBS) addNode(`malgrupp:${h.slug}`, 'malgrupp', h.slug, { url: `/bidrag/${h.slug}/` });

// Stöd + kriterier + kanter
const factNodes = new Set();
const oppFacts = new Map(); // slug -> Set(factPath)
for (const o of opportunities) {
  addNode(`stod:${o.slug}`, 'stod', o.title, {
    url: `/bidrag/${o.slug}/`, instrument: o.instrumentType, deadlineModel: o.deadlineModel ?? null,
  });
  addEdge(`stod:${o.slug}`, 'ges_av', `myndighet:${o.authorityKey}`);
  for (const h of HUBS) {
    if ((o.applicantTypes ?? []).some((t) => h.types.includes(t))) {
      addEdge(`stod:${o.slug}`, 'riktar_sig_till', `malgrupp:${h.slug}`);
    }
  }
  const facts = new Set();
  for (const cr of o.criteria ?? []) {
    if (!cr?.factPath) continue;
    facts.add(cr.factPath);
    if (!factNodes.has(cr.factPath)) {
      factNodes.add(cr.factPath);
      addNode(`kriterium:${cr.factPath}`, 'kriterium', cr.factPath);
    }
    addEdge(`stod:${o.slug}`, cr.kind === 'weighted' ? 'vager_in' : 'kraver', `kriterium:${cr.factPath}`);
  }
  oppFacts.set(o.slug, facts);
}

// Relaterade stöd: delar ≥2 kriteriefält OCH minst en gemensam hubb.
const hubOf = new Map(opportunities.map((o) => [o.slug,
  new Set(HUBS.filter((h) => (o.applicantTypes ?? []).some((t) => h.types.includes(t))).map((h) => h.slug))]));
const slugs = opportunities.map((o) => o.slug).sort();
for (let i = 0; i < slugs.length; i++) {
  for (let j = i + 1; j < slugs.length; j++) {
    const a = slugs[i], b = slugs[j];
    const shared = [...oppFacts.get(a)].filter((f) => oppFacts.get(b).has(f));
    const hubShared = [...hubOf.get(a)].some((h) => hubOf.get(b).has(h));
    if (shared.length >= 2 && hubShared) addEdge(`stod:${a}`, 'relaterad', `stod:${b}`);
  }
}

// Intents (kluster/situation/process — entity-intents ÄR stödnoden, dubbleras ej)
for (const it of intents) {
  if (it.typ === 'entity') continue;
  addNode(`intent:${it.id}`, 'intent', it.amne, { typ: it.typ, leader: it.leader, cluster_id: it.cluster_id, prio: it.prio });
  if (it.node?.startsWith('/bidrag/')) {
    const slug = it.node.split('/')[2];
    if (oppFacts.has(slug)) addEdge(`intent:${it.id}`, 'besvaras_av', `stod:${slug}`);
  }
}

nodes.sort((a, b) => a.id.localeCompare(b.id, 'sv'));
edges.sort((a, b) => (a.from + a.rel + a.to).localeCompare(b.from + b.rel + b.to, 'sv'));

const doc = {
  _kontrakt:
    'Kunskapsgrafen v1 — genererad av tools/genkgraf.mjs ur seeden + seo/intents-100.json; redigera ALDRIG för hand. ' +
    'Grafen är lager 6 i docs/CONTENT_ENGINE.md: internlänkning, relaterade stöd och situationsnoder hämtar härifrån. ' +
    "'relaterad'-kanter = delar ≥2 kriteriefält och minst en målgruppshubb (deterministisk heuristik v1 — " +
    'redaktionell kurering kan skärpa den senare, i generatorn, inte i filen). Regenerera vid seed-/intentändring; verify kör --check.',
  genererad_ur_seed: CURATED_AT,
  antal_noder: nodes.length,
  antal_kanter: edges.length,
  noder_per_typ: Object.fromEntries([...nodes.reduce((m, n) => m.set(n.type, (m.get(n.type) ?? 0) + 1), new Map())].sort()),
  nodes, edges,
};
const json = JSON.stringify(doc, null, 1) + '\n';

if (CHECK) {
  let disk = '';
  try { disk = readFileSync(OUT, 'utf8'); } catch { /* saknas */ }
  if (disk !== json) {
    console.error('seo/kunskapsgraf.json är inte i synk — kör: node --experimental-strip-types tools/genkgraf.mjs');
    process.exit(1);
  }
  console.log(`kunskapsgrafen i synk (${doc.antal_noder} noder, ${doc.antal_kanter} kanter).`);
} else {
  writeFileSync(OUT, json);
  console.log(`Skrev ${OUT}: ${doc.antal_noder} noder, ${doc.antal_kanter} kanter`, doc.noder_per_typ);
}
