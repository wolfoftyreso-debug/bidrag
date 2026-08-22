/**
 * Sprint 01: genererar query-universum (seo/query-universum.json) ur
 *   seo/intents-100.json            (100 huvudintentioner med slots)
 * × seo/search-language-grammar.json (113 sökspråksmönster, källmärkta)
 * + seo/questions-tier1.json         (343 verkliga frågor, SERP-DERIVED/INFERRED)
 *
 * SANNINGSREGLER:
 *  - Inga sökvolymer någonstans (DATA_UNAVAILABLE — se _kontrakt).
 *  - Varje genererad variant bär pattern_id + source-kedjan
 *    GENERATED(<mönstrets källa>): en variant är aldrig "observerad" bara för
 *    att den genererats — SERP-belagda strängar kommer endast ur
 *    questions-tier1 (SERP-DERIVED) eller mönster märkta SERP_OBSERVED.
 *  - Mönster med platshållare som inte kan fyllas ur intentens slots hoppas
 *    över (felstavning/särskrivning/röstfråga genereras INTE syntetiskt —
 *    de kräver verkliga observationer).
 *
 *   node --experimental-strip-types tools/genqueries.mjs          # skriv
 *   node --experimental-strip-types tools/genqueries.mjs --check  # verifiera i synk
 *
 * Deterministisk: sorterad utdata; --check regenererar och jämför.
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'seo', 'query-universum.json');
const CHECK = process.argv.includes('--check');

const intents = JSON.parse(readFileSync(join(ROOT, 'seo', 'intents-100.json'), 'utf8')).intents;
const grammar = JSON.parse(readFileSync(join(ROOT, 'seo', 'search-language-grammar.json'), 'utf8')).patterns;
const tier1 = JSON.parse(readFileSync(join(ROOT, 'seo', 'questions-tier1.json'), 'utf8')).roots;

// Årtal för aktualitetsmönster: styrs av intentlagret, inte av klockan
// (determinism) — uppdateras redaktionellt vid årsskifte.
const YEAR = '2026';

const norm = (s) => s.toLowerCase().replace(/\s+/g, ' ').trim();
const seen = new Map(); // norm -> query-objekt (första vinner; dubletter räknas)
let duplicates = 0;
function add(q, intent_id, pattern_id, family, source) {
  const n = norm(q);
  if (!n || n.length < 3) return;
  if (seen.has(n)) { duplicates++; return; }
  seen.set(n, { q: n, intent_id, pattern_id, family, source });
}

// 1) Verkliga frågor (tier 1) — den enda SERP-belagda strängkällan.
const rootToIntent = new Map();
for (const it of intents) {
  if (it.term) rootToIntent.set(norm(it.term), it.id);
  if (it.folkterm) rootToIntent.set(norm(it.folkterm), it.id);
}
for (const r of tier1) {
  const iid = rootToIntent.get(norm(r.root)) ?? null;
  for (const qq of r.questions) add(qq.q, iid, null, 'tier1-fråga', qq.source);
}

// 2) Grammatikexpansion per intent.
const fill = (pattern, slots) => {
  let out = pattern; let ok = true;
  out = out.replace(/\{([^}]+)\}/g, (_, name) => {
    if (name in slots && slots[name]) return slots[name];
    ok = false; return '';
  });
  return ok ? out : null;
};

for (const it of intents) {
  const slots = {
    'stöd': it.term, 'officiell term': it.term, 'myndighet': it.myndighet,
    'årtal': YEAR,
  };
  if (it.term) {
    for (const p of grammar) {
      if (!p.pattern.includes('{')) continue; // fasta fraser hanteras globalt nedan
      const q = fill(p.pattern, slots);
      if (q) add(q, it.id, p.id, p.family, `GENERATED(${p.source})`);
    }
  }
  if (it.folkterm) add(it.folkterm, it.id, null, 'vardagligt-namn', 'GENERATED(SLOT:folkterm)');
  if (it.problemfras) add(it.problemfras, it.id, null, 'problem', 'GENERATED(SLOT:problemfras)');
  if (it.term && it.myndighet) add(`${it.myndighet} ${it.term}`, it.id, 'QP-002', 'officiellt-namn', 'GENERATED(SERP_OBSERVED)');
}

// 3) Fasta grammatikfraser (utan platshållare) — en gång, globalt.
for (const p of grammar) {
  if (!p.pattern.includes('{')) add(p.pattern, null, p.id, p.family, `GENERATED(${p.source})`);
}

const queries = [...seen.values()].sort((a, b) => a.q.localeCompare(b.q, 'sv'));
const doc = {
  _kontrakt:
    'Sprint 01: query-universum genererat av tools/genqueries.mjs — redigera ALDRIG för hand. ' +
    'Volymer: DATA_UNAVAILABLE genomgående (fabriceras inte; GSC efter deploy är första verkliga källan). ' +
    'source-fältet skiljer verkliga strängar (SERP-DERIVED/INFERRED ur questions-tier1) från syntetiska ' +
    '(GENERATED(<mönsterkälla>)). En genererad variant är en HYPOTES om sökspråk tills GSC bekräftar den. ' +
    'Felstavningar/särskrivningar/röstfrågor genereras inte syntetiskt. ' +
    'Regenerera efter ändring i intents/grammatik/tier1; verify kör --check.',
  antal: queries.length,
  varav_verkliga: queries.filter((q) => !q.source.startsWith('GENERATED')).length,
  varav_genererade: queries.filter((q) => q.source.startsWith('GENERATED')).length,
  dubbletter_bortrensade: duplicates,
  queries,
};
const json = JSON.stringify(doc, null, 1) + '\n';

if (CHECK) {
  let disk = '';
  try { disk = readFileSync(OUT, 'utf8'); } catch { /* saknas */ }
  if (disk !== json) {
    console.error('seo/query-universum.json är inte i synk — kör: node --experimental-strip-types tools/genqueries.mjs');
    process.exit(1);
  }
  console.log(`query-universum i synk (${doc.antal} queries, ${doc.varav_verkliga} verkliga + ${doc.varav_genererade} genererade).`);
} else {
  writeFileSync(OUT, json);
  console.log(`Skrev ${OUT}: ${doc.antal} queries (${doc.varav_verkliga} verkliga + ${doc.varav_genererade} genererade, ${duplicates} dubbletter borttagna).`);
}
