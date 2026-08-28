/**
 * content_find_cannibalization (bidragskollen-seo-mcp, lokal kapabilitet) —
 * scannar den genererade publika ytan efter kannibaliseringsrisk: två
 * indexerbara sidor som tävlar om samma sökintention (kraftigt överlappande
 * titeltoken). Deterministisk, ingen extern data — den delen av SEO-
 * kontrollplanet som fungerar UTAN Semrush/Ahrefs/GSC.
 *
 *   node tools/seo-cannibalization.mjs [katalog]   # default artifacts/seo-site
 *
 * Rådgivande (exit 0): exakta titeldubbletter fångas redan av seocheck; detta
 * lyfter FUZZY-risker som en människa/agent bör titta på. Skriver även
 * artifacts/seo-cannibalization.json för kontrollplanet.
 */
import { readFileSync, readdirSync, statSync, existsSync, writeFileSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = process.argv[2] ? join(ROOT, process.argv[2]) : join(ROOT, 'artifacts', 'seo-site');
if (!existsSync(SITE)) { console.error(`${SITE} saknas — kör tools/genseo.mjs först`); process.exit(1); }

const STOP = new Set(['och', 'för', 'att', 'i', 'på', 'du', 'din', 'ditt', 'kan', 'få', 'med', 'en', 'ett', 'de', 'som', 'är', 'so']);

/**
 * Granskade par (förälder/barn i klusterarkitekturen): en hubb och dess
 * barnsida handlar om SAMMA ämne per design — token-överlappet är semantisk
 * verklighet, inte två sidor som tävlar om samma intention. Hubben äger
 * huvudtermen/orienteringen, barnsidan det konkreta stödet (villkor + ansökan);
 * de länkar varandra. Varje post här kräver en motivering — listan är ett
 * granskningsprotokoll, inte en tystnadsknapp.
 */
const REVIEWED_PAIRS = new Map([
  ['/bidrag/ekonomiskt-bistand/ ⟷ /bidrag/kommun-forsorjningsstod/',
    'klusterhubb ⟷ barnsida (SEO_ANSWER_CLUSTERS #3): hubben äger paraplytermen + PAA, barnsidan det sökbara stödet — granskad 2026-08-28'],
]);
const pairKey = (a, b) => [a, b].sort().join(' ⟷ ');
const pages = [];
function walk(dir, rel) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p, `${rel}${name}/`);
    else if (name === 'index.html') pages.push([rel, readFileSync(p, 'utf8')]);
  }
}
walk(SITE, '/');

// Precision-fix (hardening-audit fynd 1): jämför den DISTINKTIVA delen av titeln —
// segmentet före "–"/"|" (entitetens/intentionens namn) — inte titelboilerplaten
// ("… – villkor, belopp och ansökan | Bidragskoll", "… – stöd och bidrag"). Utan
// detta ger den delade mallen falska 0.5-träffar mellan alla entitetssidor.
const norm = (s) => s.split(/[–|]/)[0].toLowerCase().replace(/[^a-zåäö0-9\s]/g, '').split(/\s+/).filter((w) => w && !STOP.has(w));
const docs = pages
  .filter(([, html]) => !/name="robots" content="noindex/.test(html)) // bara indexerbara tävlar
  .map(([path, html]) => {
    const title = html.match(/<title>([^<]*)<\/title>/)?.[1] ?? '';
    const h1 = html.match(/<h1[^>]*>([^<]*)<\/h1>/)?.[1] ?? '';
    // Signalen = distinkt titelsegment + H1 (fångar intention även när titelnamnet är kort).
    return { path, title, tokens: new Set([...norm(title), ...norm(h1 + ' |')]) };
  });

const jaccard = (a, b) => {
  let inter = 0;
  for (const t of a) if (b.has(t)) inter++;
  return inter / (a.size + b.size - inter || 1);
};

const THRESHOLD = 0.6;
const risks = [];
for (let i = 0; i < docs.length; i++) {
  for (let j = i + 1; j < docs.length; j++) {
    if (docs[i].tokens.size < 2 || docs[j].tokens.size < 2) continue;
    const sim = jaccard(docs[i].tokens, docs[j].tokens);
    if (sim >= THRESHOLD) {
      const reviewed = REVIEWED_PAIRS.get(pairKey(docs[i].path, docs[j].path));
      risks.push({ a: docs[i].path, b: docs[j].path, similarity: Math.round(sim * 100) / 100, titleA: docs[i].title, titleB: docs[j].title, ...(reviewed ? { reviewed } : {}) });
    }
  }
}
risks.sort((x, y) => y.similarity - x.similarity);

mkdirSync(join(ROOT, 'artifacts'), { recursive: true });
writeFileSync(join(ROOT, 'artifacts', 'seo-cannibalization.json'), JSON.stringify({ indexablePages: docs.length, threshold: THRESHOLD, risks }, null, 2));

console.log(`Kannibaliseringskoll: ${docs.length} indexerbara sidor, tröskel ${THRESHOLD}.`);
const open = risks.filter((r) => !r.reviewed);
const cleared = risks.filter((r) => r.reviewed);
for (const r of cleared) console.log(`  GRANSKAD  ${r.a}  ⟷  ${r.b} — ${r.reviewed}`);
if (!open.length) {
  console.log('Inga ogranskade kannibaliseringsrisker — varje indexerbar sida äger en egen intention.');
} else {
  console.log(`${open.length} risk(er) att granska:`);
  for (const r of open) console.log(`  ${r.similarity}  ${r.a}  ⟷  ${r.b}\n         "${r.titleA}"  /  "${r.titleB}"`);
}
