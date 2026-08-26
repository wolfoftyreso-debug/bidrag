/**
 * Indexability-rapport (SEO-3/§5, §20). Kör Indexability-motorn över alla
 * sökintentioner (seo/search-intents.json) mot seeden och skriver ut domen per
 * kandidat — INDEX / NOINDEX_FOLLOW / DO_NOT_GENERATE med motivering och antal
 * matchande stöd. Skriver även docs/SEO_QUERY_PAGES.md (byggprodukt).
 *
 *   node --experimental-strip-types tools/indexability.mjs          # skriv rapport
 *   node --experimental-strip-types tools/indexability.mjs --check  # i synk?
 *
 * Delar resolver/motor med genseo via tools/lib/intents.mjs (single source).
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadIntents, resolveIntent, indexabilityVerdict } from './lib/intents.mjs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const OUT = join(ROOT, 'docs', 'SEO_QUERY_PAGES.md');
const CHECK = process.argv.includes('--check');
const { opportunities, CURATED_AT } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));

const rows = loadIntents(ROOT)
  .map((intent) => ({ intent, ...(() => { const s = resolveIntent(intent, opportunities); return { supports: s, ...indexabilityVerdict(intent, s) }; })() }))
  .sort((a, b) => a.intent.canonical_url.localeCompare(b.intent.canonical_url, 'sv'));

const tally = { INDEX: 0, NOINDEX_FOLLOW: 0, DO_NOT_GENERATE: 0 };
for (const r of rows) tally[r.verdict]++;

const L = [];
L.push('# Query Pages & Indexability-domar (SEO-3)');
L.push('');
L.push('> **Byggprodukt — redigera aldrig för hand.** `node --experimental-strip-types tools/indexability.mjs`.');
L.push('> Query Pages är vyer över kunskapsgrafen; Indexability-motorn avgör vilka kombinationer');
L.push('> som förtjänar en indexerbar sida utifrån VERKLIG datatäckning (inga påhittade sökvolymer).');
L.push('');
L.push(`Kurerat läge: **${CURATED_AT}**. Kandidater: **${rows.length}** · INDEX **${tally.INDEX}** · NOINDEX_FOLLOW **${tally.NOINDEX_FOLLOW}** · DO_NOT_GENERATE **${tally.DO_NOT_GENERATE}**.`);
L.push('');
L.push('## Domar');
L.push('');
L.push('| Intention | Canonical | Filter | Matchande stöd | Dom | Motivering |');
L.push('|---|---|---|---|---|---|');
for (const r of rows) {
  const f = r.intent.filter ?? {};
  const filterStr = Object.entries(f).map(([k, v]) => `${k}=${v}`).join(' ∧ ');
  L.push(`| ${r.intent.canonical_query} | \`${r.intent.canonical_url}\` | ${filterStr} | ${r.count} | **${r.verdict}** | ${r.reasons.join('; ')} |`);
}
L.push('');
L.push('## Domtröskeln');
L.push('');
L.push('- **INDEX** — ≥3 matchande stöd: self-canonical + i sitemap.');
L.push('- **NOINDEX_FOLLOW** — 1–2 stöd: genereras för människor, `robots noindex,follow`, utanför sitemap.');
L.push('- **DO_NOT_GENERATE** — 0 stöd: sidan skapas inte (t.ex. aktiviteter som saknar kurerat stöd i KB:n).');
L.push('');
L.push('Aktivitetsintentioner (anställa, köpa maskiner, investering enskild firma) landar i DO_NOT_GENERATE');
L.push('tills kunskapsbasen kurerats för dessa aktiviteter — motorn vägrar ärligt en tom sida.');
L.push('');

const body = L.join('\n');
if (CHECK) {
  let cur = '';
  try { cur = readFileSync(OUT, 'utf8'); } catch { /* saknas */ }
  if (cur !== body) { console.error('docs/SEO_QUERY_PAGES.md är inte i synk — kör tools/indexability.mjs'); process.exit(1); }
  console.log(`SEO_QUERY_PAGES.md i synk (${rows.length} kandidater).`);
} else {
  writeFileSync(OUT, body);
  console.log(`Skrev ${OUT}: ${rows.length} kandidater (INDEX ${tally.INDEX} / NOINDEX ${tally.NOINDEX_FOLLOW} / DO_NOT_GENERATE ${tally.DO_NOT_GENERATE}).`);
}
