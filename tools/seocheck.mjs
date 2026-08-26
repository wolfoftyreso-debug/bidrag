/**
 * SEO-QA-crawler för den genererade publika ytan (tools/genseo.mjs).
 * Ingen server krävs — crawlar utdatakatalogen som filer och verifierar det
 * en teknisk SEO-audit annars gör för hand:
 *
 *  - exakt en <h1> per sida
 *  - <title> finns, unik och ≤ 70 tecken
 *  - meta description finns, unik och ≤ 170 tecken
 *  - canonical finns och matchar sidans faktiska sökväg
 *  - JSON-LD parsar och innehåller Organization + BreadcrumbList
 *  - lang="sv"
 *  - alla interna länkar under /bidrag/ pekar på sidor som existerar
 *  - ingen orphan: varje sida nås från /bidrag/ via interna länkar (BFS)
 *  - sitemap.xml listar exakt de genererade sidorna (inga fler, inga färre)
 *  - robots.txt finns och pekar på sitemapen
 *
 *   node tools/seocheck.mjs [katalog]   # default artifacts/seo-site
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = process.argv[2] ? join(ROOT, process.argv[2]) : join(ROOT, 'artifacts', 'seo-site');
const BASE = 'https://bidragskoll.se';

let errors = 0;
const err = (m) => { console.error('FEL: ' + m); errors++; };

// Hitta alla genererade sidor.
const pages = new Map(); // urlPath -> html
function walk(dir, rel) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) walk(p, `${rel}${name}/`);
    else if (name === 'index.html') pages.set(rel, readFileSync(p, 'utf8'));
  }
}
if (!existsSync(join(SITE, 'bidrag'))) { err(`${SITE}/bidrag saknas — kör tools/genseo.mjs först`); process.exit(1); }
// Crawla hela den genererade ytan: /bidrag/ + flaggskepp + Query Pages på rot.
walk(SITE, '/');
// Statiska sidprefix (allt annat i href, t.ex. /villkor, /konto, /, är SPA-vyer
// som inte genereras här och därför inte länkgranskas). Query Pages ligger under
// målgruppsprefixen /foretag/ /privatperson/ /forening/ /enskild-firma/.
const STATIC = ['/bidrag/', '/hitta-bidrag-gratis/', '/vilka-bidrag-kan-jag-fa/', '/bidragsstatus/', '/foretag/', '/privatperson/', '/forening/', '/enskild-firma/'];
// Toppnivåingångar för orphan-BFS (faktiska sidor, länkade från appens nav /
// katalogindex). Query Pages nås därifrån via målgruppshubbarnas länkar.
const BFS_SEEDS = ['/bidrag/', '/hitta-bidrag-gratis/', '/vilka-bidrag-kan-jag-fa/', '/bidragsstatus/'];
const noindexPages = new Set();

const titles = new Map();
const descriptions = new Map();
const linkGraph = new Map();

for (const [path, html] of pages) {
  if (/name="robots" content="noindex/.test(html)) noindexPages.add(path);
  const h1s = html.match(/<h1[\s>]/g) ?? [];
  if (h1s.length !== 1) err(`${path}: ${h1s.length} st <h1> (ska vara exakt 1)`);

  const title = html.match(/<title>([^<]*)<\/title>/)?.[1];
  if (!title) err(`${path}: <title> saknas`);
  else {
    if (title.length > 70) err(`${path}: title ${title.length} tecken (>70): "${title}"`);
    if (titles.has(title)) err(`${path}: title dubblerad med ${titles.get(title)}`);
    titles.set(title, path);
  }

  const desc = html.match(/<meta name="description" content="([^"]*)"/)?.[1];
  if (!desc) err(`${path}: meta description saknas`);
  else {
    if (desc.length > 170) err(`${path}: description ${desc.length} tecken (>170)`);
    if (descriptions.has(desc)) err(`${path}: description dubblerad med ${descriptions.get(desc)}`);
    descriptions.set(desc, path);
  }

  const canonical = html.match(/<link rel="canonical" href="([^"]*)"/)?.[1];
  if (canonical !== `${BASE}${path}`) err(`${path}: canonical är ${canonical}, väntade ${BASE}${path}`);

  if (!/<html lang="sv">/.test(html)) err(`${path}: lang="sv" saknas`);

  // Perfektionsgaten (§11–13): social metadata + varumärkes-head på varje sida.
  if (!html.includes('property="og:image"')) err(`${path}: og:image saknas`);
  if (!html.includes('name="twitter:card"')) err(`${path}: twitter:card saknas`);
  if (!html.includes('rel="icon"')) err(`${path}: favicon-länk saknas`);
  if (!html.includes('name="theme-color"')) err(`${path}: theme-color saknas`);

  const ld = html.match(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/)?.[1];
  if (!ld) err(`${path}: JSON-LD saknas`);
  else {
    try {
      const parsed = JSON.parse(ld);
      const types = (parsed['@graph'] ?? []).map((n) => n['@type']);
      for (const need of ['Organization', 'BreadcrumbList', 'WebPage']) {
        if (!types.includes(need)) err(`${path}: JSON-LD saknar ${need}`);
      }
    } catch (e) { err(`${path}: JSON-LD parsar inte (${e.message})`); }
  }

  const links = [...html.matchAll(/href="(\/[^"#]*)"/g)]
    .map((m) => m[1])
    .filter((l) => STATIC.some((pre) => l.startsWith(pre)));
  linkGraph.set(path, links);
  for (const l of links) if (!pages.has(l)) err(`${path}: intern länk till ${l} som inte existerar`);
}

// Orphan-koll: BFS från de statiska ingångarna (katalogen + flaggskeppssidorna,
// som är toppnivåingångar länkade från appens nav).
const reachable = new Set();
const queue = BFS_SEEDS.filter((p) => pages.has(p));
while (queue.length) {
  const p = queue.shift();
  if (reachable.has(p)) continue;
  reachable.add(p);
  for (const l of linkGraph.get(p) ?? []) if (pages.has(l)) queue.push(l);
}
for (const p of pages.keys()) if (!reachable.has(p)) err(`${p}: orphan — nås inte från /bidrag/ via interna länkar`);

// Sitemap: exakt de genererade sidorna.
const sitemapPath = join(SITE, 'sitemap.xml');
if (!existsSync(sitemapPath)) err('sitemap.xml saknas');
else {
  const locs = [...readFileSync(sitemapPath, 'utf8').matchAll(/<loc>([^<]*)<\/loc>/g)].map((m) => m[1].replace(BASE, ''));
  for (const l of locs) if (!pages.has(l)) err(`sitemap listar ${l} som inte genererats`);
  if (locs.some((l) => noindexPages.has(l))) err('sitemap listar en NOINDEX-sida (ska stå utanför sitemapen)');
  // NOINDEX_FOLLOW-sidor genereras men står medvetet utanför sitemapen.
  for (const p of pages.keys()) if (!locs.includes(p) && !noindexPages.has(p)) err(`sitemap saknar ${p}`);
}

// 404-sidan (§40): måste finnas, vara noindex och stå utanför sitemapen.
const nfPath = join(SITE, '404.html');
if (!existsSync(nfPath)) err('404.html saknas');
else {
  const nf = readFileSync(nfPath, 'utf8');
  if (!nf.includes('name="robots" content="noindex"')) err('404.html är inte noindex');
  if (!/hjälpa dig/.test(nf)) err('404.html saknar den hjälpsamma texten (§40)');
}

// Robots.
const robotsPath = join(SITE, 'robots.txt');
if (!existsSync(robotsPath)) err('robots.txt saknas');
else if (!readFileSync(robotsPath, 'utf8').includes(`Sitemap: ${BASE}/sitemap.xml`)) err('robots.txt pekar inte på sitemapen');

console.log(`Kontrollerade ${pages.size} sidor: ${errors === 0 ? 'SEO-QA GODKÄND' : errors + ' fel'}`);
process.exit(errors ? 1 : 0);
