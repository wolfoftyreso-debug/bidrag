/**
 * SEO-REVISIONSVERKTYGET: djupgranskning av den genererade publika ytan,
 * bortom seocheck:s pass/fail-QA. Mäter det en revision behöver kvantifiera:
 *
 *  Per sida: ordmängd, sidvikt, rubrikstruktur, interna/externa länkar,
 *  länkdjup från huvudhubben (BFS), gold standard-moduler (CONTENT_ENGINE §5)
 *  som faktiskt finns, JSON-LD-typer, render-blockerande externa resurser.
 *
 *  Aggregerat: fördelningar, ankartext-topplista, tunna sidor, dubblettrisk
 *  (delade inledningsstycken), modultäckning, och TÄCKNINGSREVISIONEN:
 *  hur många av intents-100 har en levande nod, och hur stor andel av
 *  query-universumets varianter pekar mot en nod som existerar.
 *
 *   node tools/seoaudit.mjs [katalog]   # default artifacts/seo-site
 *   → skriver artifacts/seo-audit.json + läsbar summering till stdout
 *
 * Sanningsregler: mäter bara det som går att mäta lokalt. Rankingar, volymer,
 * CWV-fältdata och indexering är DATA_UNAVAILABLE tills sajten är deployad —
 * verktyget påstår aldrig något om dem.
 */
import { readFileSync, readdirSync, statSync, existsSync, writeFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = process.argv[2] ? join(ROOT, process.argv[2]) : join(ROOT, 'artifacts', 'seo-site');

const pages = new Map(); // urlPath -> { html, bytes }
function walk(dir, rel) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p, `${rel}${name}/`);
    else if (name === 'index.html') pages.set(rel, { html: readFileSync(p, 'utf8'), bytes: statSync(p).size });
  }
}
if (!existsSync(join(SITE, 'bidrag'))) { console.error(`${SITE}/bidrag saknas — kör tools/genseo.mjs först`); process.exit(1); }
walk(join(SITE, 'bidrag'), '/bidrag/');

const strip = (h) => h.replace(/<script[\s\S]*?<\/script>/g, ' ').replace(/<style[\s\S]*?<\/style>/g, ' ').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();

// Gold standard-moduler (CONTENT_ENGINE §5) som går att detektera i markup.
const MODULES = {
  '1 direkt svar': (h) => /<p class="lead"/.test(h),
  '3 officiell status': (h) => /AI-sammanställd|ej granskad/i.test(h),
  '6 belopp': (h) => /Belopp<\/th>/.test(h),
  '8 ansökningsväg': (h) => /Två vägar vidare|ansök/i.test(h),
  '10 deadline': (h) => /Ansökan<\/th>|stänger|Löpande/i.test(h),
  '12 relaterade stöd': (h) => /Relaterade stöd/.test(h),
  '17 officiell källa': (h) => /class="kalla"/.test(h),
  '20 senast kontrollerad': (h) => /Senast kontrollerad/.test(h),
};
const MISSING_MODULES = ['2 enkel svenska (separat)', '4 behörighetskontroll (interaktiv)', '5 diskvalificerande villkor', '7 scenarier', '9 dokumentchecklista', '11 vanliga fel', '13 jämförelser', '14 erfarenheter', '15 beviljade exempel', '16 ändringshistorik', '18 namngiven granskare', '19 metodbeskrivning'];

const perPage = [];
const linkGraph = new Map();
const anchors = new Map();
const leads = new Map(); // första 120 tecken av brödtext → sidor (dubblettrisk)

for (const [path, { html, bytes }] of pages) {
  const text = strip(html);
  const words = text.split(' ').length;
  const h2 = (html.match(/<h2[\s>]/g) ?? []).length;
  const internal = [...html.matchAll(/<a[^>]*href="(\/bidrag\/[^"#]*)"[^>]*>([^<]*)</g)];
  const external = (html.match(/href="https?:\/\/(?!bidragskoll\.se)/g) ?? []).length;
  linkGraph.set(path, internal.map((m) => m[1]));
  for (const m of internal) {
    const a = m[2].trim().slice(0, 60);
    if (a) anchors.set(a, (anchors.get(a) ?? 0) + 1);
  }
  const renderBlocking = (html.match(/<link rel="stylesheet" href="https?:\/\//g) ?? []).length;
  const mods = Object.entries(MODULES).filter(([, fn]) => fn(html)).map(([k]) => k);
  const lead = text.slice(text.indexOf('›') + 1, text.indexOf('›') + 141);
  if (!leads.has(lead)) leads.set(lead, []);
  leads.get(lead).push(path);
  perPage.push({ path, words, bytes, h2, internalLinks: internal.length, externalLinks: external, renderBlocking, modules: mods });
}

// Länkdjup (BFS från /bidrag/).
const depth = new Map([['/bidrag/', 0]]);
const q = ['/bidrag/'];
while (q.length) {
  const p = q.shift();
  for (const l of linkGraph.get(p) ?? []) {
    if (pages.has(l) && !depth.has(l)) { depth.set(l, depth.get(p) + 1); q.push(l); }
  }
}
for (const row of perPage) row.depth = depth.get(row.path) ?? null;

// Täckningsrevision mot intents-100 + query-universum.
const intents = JSON.parse(readFileSync(join(ROOT, 'seo', 'intents-100.json'), 'utf8')).intents;
const universe = JSON.parse(readFileSync(join(ROOT, 'seo', 'query-universum.json'), 'utf8')).queries;
const liveNode = (node) => node != null && pages.has(node);
const intentCoverage = intents.map((it) => ({ id: it.id, typ: it.typ, prio: it.prio, live: liveNode(it.node) }));
const nodeByIntent = new Map(intents.map((it) => [it.id, liveNode(it.node)]));
const qCovered = universe.filter((u) => u.intent_id && nodeByIntent.get(u.intent_id)).length;

const sorted = (k) => [...perPage].sort((a, b) => a[k] - b[k]);
const median = (arr) => arr[Math.floor(arr.length / 2)];
const summary = {
  datum: new Date(JSON.parse(readFileSync(join(ROOT, 'seo', 'serp-sprint01.json'), 'utf8')).datum + 'T00:00:00Z') && undefined, // datum sätts av rapporten, inte klockan
  antal_sidor: pages.size,
  ord: { min: sorted('words')[0], median: median(sorted('words')).words, max: sorted('words').at(-1) },
  tunna_sidor_under_300_ord: perPage.filter((p) => p.words < 300).map((p) => ({ path: p.path, words: p.words })),
  sidvikt_byte: { min: sorted('bytes')[0].bytes, median: median(sorted('bytes')).bytes, max: sorted('bytes').at(-1).bytes },
  render_blockerande_externa: perPage.filter((p) => p.renderBlocking > 0).length,
  lankdjup: { max: Math.max(...perPage.map((p) => p.depth ?? 99)), fordelning: perPage.reduce((m, p) => ((m[p.depth] = (m[p.depth] ?? 0) + 1), m), {}) },
  interna_lankar: { median: median(sorted('internalLinks')).internalLinks, min: sorted('internalLinks')[0].internalLinks },
  ankartexter_topp: [...anchors.entries()].sort((a, b) => b[1] - a[1]).slice(0, 10),
  dubblettrisk_delad_inledning: [...leads.values()].filter((v) => v.length > 1).length,
  modultackning: Object.keys(MODULES).map((k) => ({ modul: k, sidor: perPage.filter((p) => p.modules.includes(k)).length })),
  moduler_som_saknas_helt: MISSING_MODULES,
  tackning: {
    intents_med_levande_nod: intentCoverage.filter((i) => i.live).length,
    intents_totalt: intents.length,
    per_typ: ['kluster', 'situation', 'process', 'jamforelse', 'entity'].map((t) => ({
      typ: t, live: intentCoverage.filter((i) => i.typ === t && i.live).length, totalt: intentCoverage.filter((i) => i.typ === t).length,
    })),
    queries_mot_levande_nod: qCovered,
    queries_totalt: universe.length,
    andel_pct: Math.round((qCovered / universe.length) * 1000) / 10,
  },
};
delete summary.datum;

writeFileSync(join(ROOT, 'artifacts', 'seo-audit.json'), JSON.stringify({ summary, perPage }, null, 1));
console.log(JSON.stringify(summary, null, 1));
