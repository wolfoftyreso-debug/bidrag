/**
 * Bygger master keyword-databasen (seo/keywords.json) ur två källor:
 *
 *  1. ENTITY-HÄRLEDDA rötter — genereras ur kunskapsbasens 72 stöd
 *     (apps/api/src/seed/data.ts). Alltid i synk med sanningsmodellen:
 *     nya stöd i seeden blir automatiskt nya rötter vid nästa körning.
 *  2. MANUELLT KURERADE rötter — seo/roots-manual.json (kategori-, problem-,
 *     jämförelse- och myndighetstermer utanför entiteterna).
 *
 * ÄRLIGHETSKONTRAKT: sökvolym, CPC och difficulty sätts ALDRIG av det här
 * verktyget — de är null med volume_source/difficulty_source =
 * DATA_UNAVAILABLE tills Search Console/Keyword Planner/tredjepartsdata
 * kopplats in (se docs/SEO_CURRENT_STATE.md). SERP-fält fylls endast i från
 * dokumenterad SERP-research (docs/SEO_SERP_RESEARCH.md), aldrig ur minnet.
 *
 *   node tools/seokeywords.mjs          # skriver seo/keywords.json
 *   node tools/seokeywords.mjs --check  # fallerar om filen inte är aktuell
 *
 * Deterministisk: inga tidsstämplar, sorterad utdata.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'seo', 'keywords.json');
const CHECK = process.argv.includes('--check');

const { opportunities, authorities } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const manual = JSON.parse(readFileSync(join(ROOT, 'seo', 'roots-manual.json'), 'utf8'));

const authorityName = new Map(authorities.map((a) => [a.key, a.name]));

function normalize(s) {
  return s
    .toLowerCase()
    .replace(/[—–-]/g, ' ')
    .replace(/[^a-zåäöé0-9\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function row(overrides) {
  return {
    keyword: null,
    normalized_keyword: null,
    root_keyword: null,
    question: null,
    search_volume: null,
    volume_source: 'DATA_UNAVAILABLE',
    cpc: null,
    difficulty: null,
    difficulty_source: 'DATA_UNAVAILABLE',
    intent: null,
    user_state: null,
    entity: null,
    category: null,
    subcategory: null,
    audience: null,
    serp_features: null,
    current_top_domain: null,
    current_top_url: null,
    authority_type: null,
    our_target_url: null,
    page_type: null,
    opportunity_score: null,
    priority: null,
    status: 'planned',
    source: null,
    notes: null,
    ...overrides,
  };
}

const rows = [];

// 1. Entity-härledda rötter: stödets vardagsnamn (delen efter "—") är roten;
//    myndighetsnamnet + kortnamnet är en navigational variant.
for (const o of opportunities) {
  const short = (o.title.split(' — ').pop() ?? o.title).trim();
  const auth = authorityName.get(o.authorityKey) ?? o.authorityKey;
  const target = `/bidrag/${o.slug}/`;
  rows.push(
    row({
      keyword: short.toLowerCase(),
      normalized_keyword: normalize(short),
      root_keyword: normalize(short),
      intent: 'informational',
      entity: o.slug,
      category: o.instrumentType,
      audience: (o.applicantTypes ?? []).join('|') || null,
      our_target_url: target,
      page_type: 'entity',
      source: 'entity-derived',
    }),
    row({
      keyword: `${auth.toLowerCase()} ${short.toLowerCase()}`,
      normalized_keyword: normalize(`${auth} ${short}`),
      root_keyword: normalize(short),
      intent: 'navigational',
      entity: o.slug,
      category: o.instrumentType,
      audience: (o.applicantTypes ?? []).join('|') || null,
      our_target_url: target,
      page_type: 'entity',
      source: 'entity-derived',
    }),
  );
}

// 2. Manuellt kurerade rötter.
const TYPE_INTENT = {
  category: 'informational',
  problem: 'informational',
  comparison: 'comparison',
  'authority-term': 'informational',
  audience: 'informational',
  'year-pattern': 'informational',
};
for (const r of manual.roots) {
  rows.push(
    row({
      keyword: r.root,
      normalized_keyword: normalize(r.root),
      root_keyword: normalize(r.root),
      intent: TYPE_INTENT[r.type] ?? 'informational',
      category: r.cluster,
      audience: r.audience,
      page_type: r.cluster === 'brand' ? 'brand' : r.type === 'comparison' ? 'comparison' : 'hub-or-guide',
      source: `manual:${r.type}`,
      notes: r.note ?? null,
    }),
  );
}

// Deduplicera på normaliserad form (entity-härledd vinner över manuell).
const seen = new Map();
for (const r of rows) {
  const key = r.normalized_keyword;
  if (!seen.has(key) || (seen.get(key).source.startsWith('manual') && r.source === 'entity-derived')) {
    seen.set(key, r);
  }
}
const deduped = [...seen.values()].sort((a, b) => a.normalized_keyword.localeCompare(b.normalized_keyword, 'sv'));

const doc = {
  _kontrakt:
    'Master keyword-databas. search_volume/cpc/difficulty är null tills verklig källa finns (GSC/Keyword Planner/Semrush/Ahrefs/DataForSEO) — fabricera aldrig. SERP-fält fylls endast från dokumenterad research i docs/SEO_SERP_RESEARCH.md. Frågematrisen (query variants per root) ligger i seo/questions-*.json och mappas QUERY→INTENT→CONTENT NODE innan sidor skapas.',
  antal_roots: deduped.length,
  keywords: deduped,
};

const content = JSON.stringify(doc, null, 2) + '\n';
if (CHECK) {
  let existing = null;
  try { existing = readFileSync(OUT, 'utf8'); } catch { /* saknas */ }
  if (existing !== content) {
    console.error('seo/keywords.json är inte aktuell mot seeden/roots-manual — kör `npm run seo:keywords` och committa.');
    process.exit(1);
  }
  console.log(`Keyword-databasen är aktuell (${deduped.length} rötter).`);
} else {
  writeFileSync(OUT, content);
  console.log(`Skrev seo/keywords.json: ${deduped.length} rötter (${rows.length - deduped.length} dubbletter sammanslagna).`);
}
