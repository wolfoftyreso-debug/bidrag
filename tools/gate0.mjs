/**
 * GATE 0 — Zero-Compromise Gate, deterministisk del
 * (docs/ZERO_COMPROMISE_GATE.md). Körs mot den genererade publika ytan
 * (artifacts/seo-site — kör `npm run seo:build` först).
 *
 * Block som körs här (resten av gaten: se doktrinen):
 *   C  Teknisk totalcrawl — nolltolerans utöver seocheck: dubblett-H1,
 *      tomma/tunna sidor, icke-kanonisk intern länkform (redirect-kedjor),
 *      parameterbloat, extern länkinventering (HTTP-status kan inte
 *      verifieras från sandlådan — flaggas till deploy-smoke).
 *   D  Bildinventering 100 % — varje <img> på publika ytan + OG-/ikon-
 *      tillgångar + appens illustrationer: alt, dimensioner, filvikt.
 *   E  Intern auktoritetskarta — länkgraf med in/ut-länkar, djup, PageRank,
 *      ankarfördelning, auktoritetskoncentration, Tier 1-djup.
 *   B  Innehållsmatris — 18 modulpunkter per sida (maskinella proxies;
 *      GREEN kräver även mänsklig granskning — se doktrinen).
 *
 * Utdata: artifacts/gate0-report.json + summering på stdout.
 * Exit 1 om CRITICAL- eller HIGH-fynd finns (gaten är kod, inte checklista).
 *   --allow-content-red: innehålls-RED (byggkön) fäller inte exit-koden —
 *   används i verify tills 25-klusterfasen levererat; tekniken fäller alltid.
 */
import { readFileSync, writeFileSync, mkdirSync, existsSync, statSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SITE = join(ROOT, 'artifacts', 'seo-site');
const ALLOW_CONTENT_RED = process.argv.includes('--allow-content-red');
const findings = [];
const add = (grade, block, page, what) => findings.push({ grade, block, page, what });

// ── Samla alla sidor ────────────────────────────────────────────────────────
const pages = [];
(function walk(dir) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (e.name === 'index.html') pages.push(p);
  }
})(join(SITE, 'bidrag'));
pages.sort();
const urlOf = (p) => p.slice(SITE.length).replace(/index\.html$/, '');
const html = new Map(pages.map((p) => [urlOf(p), readFileSync(p, 'utf8')]));

const text = (h) => h.replace(/<script[\s\S]*?<\/script>/g, ' ').replace(/<style[\s\S]*?<\/style>/g, ' ').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
const wordCount = (h) => text(h).split(' ').length;

// ── C: Teknisk totalcrawl (utöver seocheck) ─────────────────────────────────
const h1Seen = new Map();
const externalLinks = new Map(); // url -> [pages]
for (const [url, h] of html) {
  const h1 = (h.match(/<h1[^>]*>([\s\S]*?)<\/h1>/) ?? [])[1]?.replace(/<[^>]+>/g, '').trim();
  if (h1) {
    if (h1Seen.has(h1)) add('CRITICAL', 'TECHNICAL', url, `dubblett-H1 ("${h1.slice(0, 50)}…") — samma som ${h1Seen.get(h1)}`);
    else h1Seen.set(h1, url);
  }
  const words = wordCount(h);
  if (words < 80) add('CRITICAL', 'TECHNICAL', url, `tom/nästan tom sida (${words} ord)`);

  for (const m of h.matchAll(/href="([^"]+)"/g)) {
    const href = m[1];
    if (/^https?:\/\//.test(href)) {
      if (!href.startsWith('https://bidragskoll.se')) {
        if (!externalLinks.has(href)) externalLinks.set(href, []);
        externalLinks.get(href).push(url);
        if (!href.startsWith('https://')) add('HIGH', 'TECHNICAL', url, `extern länk utan https: ${href}`);
      }
      continue;
    }
    if (href.startsWith('#') || href.startsWith('mailto:')) continue;
    if (href.includes('?')) add('CRITICAL', 'TECHNICAL', url, `parameterbloat i intern länk: ${href}`);
    if (href.startsWith('/bidrag') && !href.endsWith('/') && !href.includes('.'))
      add('CRITICAL', 'TECHNICAL', url, `icke-kanonisk intern länkform (saknar avslutande /): ${href} — ger redirect-kedja`);
  }
}

// ── D: Bildinventering 100 % ────────────────────────────────────────────────
const media = [];
for (const [url, h] of html) {
  for (const m of h.matchAll(/<img\b[^>]*>/g)) {
    const tag = m[0];
    const attr = (n) => (tag.match(new RegExp(`${n}="([^"]*)"`)) ?? [])[1];
    const rec = { page: url, src: attr('src') ?? null, alt: attr('alt'), width: attr('width'), height: attr('height'), srcset: attr('srcset') ?? null };
    media.push(rec);
    if (rec.alt === undefined) add('CRITICAL', 'MEDIA', url, `<img> utan alt-attribut: ${rec.src}`);
    if (!rec.width || !rec.height) add('HIGH', 'MEDIA', url, `<img> utan width/height (CLS-risk): ${rec.src}`);
    if (rec.src && !rec.src.startsWith('data:')) {
      const f = join(ROOT, 'apps/web/public', rec.src.replace(/^\//, ''));
      if (!existsSync(f) && !existsSync(join(SITE, rec.src.replace(/^\//, '')))) add('CRITICAL', 'MEDIA', url, `bildfil saknas: ${rec.src}`);
    }
  }
}
// OG-/ikon-tillgångar (refereras i head på varje sida — måste finnas och väga rimligt)
const assets = [
  ['og/bidragskoll-og.png', 300 * 1024], ['favicon.svg', 20 * 1024], ['favicon.ico', 40 * 1024],
  ['icon-32.png', 10 * 1024], ['icon-180.png', 40 * 1024], ['icon-192.png', 40 * 1024],
  ['icon-512.png', 150 * 1024], ['site.webmanifest', 4 * 1024],
];
const assetInventory = [];
for (const [rel, maxBytes] of assets) {
  const f = join(ROOT, 'apps/web/public', rel);
  if (!existsSync(f)) { add('CRITICAL', 'MEDIA', '/', `delad tillgång saknas: /${rel}`); continue; }
  const size = statSync(f).size;
  assetInventory.push({ asset: `/${rel}`, bytes: size });
  if (size > maxBytes) add('HIGH', 'MEDIA', '/', `/${rel} väger ${Math.round(size / 1024)} kB (> ${Math.round(maxBytes / 1024)} kB-budget)`);
}
// Appens illustrationer: dekorativa (alt="" är policy — IMAGE_STANDARD.md)
const illDir = join(ROOT, 'apps/web/public/illustrationer');
const illustrations = existsSync(illDir) ? readdirSync(illDir).filter((f) => f.endsWith('.svg')) : [];
for (const f of illustrations) {
  const size = statSync(join(illDir, f)).size;
  assetInventory.push({ asset: `/illustrationer/${f}`, bytes: size });
  if (size > 30 * 1024) add('MEDIUM', 'MEDIA', '/', `illustration ${f} väger ${Math.round(size / 1024)} kB`);
}

// ── E: Intern auktoritetskarta ──────────────────────────────────────────────
const urls = [...html.keys()];
const outLinks = new Map(); const inLinks = new Map(); const anchors = new Map();
for (const u of urls) { outLinks.set(u, []); inLinks.set(u, []); }
for (const [url, h] of html) {
  for (const m of h.matchAll(/<a\b[^>]*href="(\/bidrag[^"]*)"[^>]*>([\s\S]*?)<\/a>/g)) {
    const target = m[1].endsWith('/') ? m[1] : m[1] + '/';
    if (!html.has(target) || target === url) continue;
    outLinks.get(url).push(target);
    inLinks.get(target).push(url);
    const anchor = m[2].replace(/<[^>]+>/g, '').trim().toLowerCase();
    if (!anchors.has(target)) anchors.set(target, new Map());
    anchors.get(target).set(anchor, (anchors.get(target).get(anchor) ?? 0) + 1);
  }
}
// Djup (BFS från huvudhubben)
const depth = new Map([['/bidrag/', 0]]);
let queue = ['/bidrag/'];
while (queue.length) {
  const next = [];
  for (const u of queue) for (const t of outLinks.get(u) ?? []) if (!depth.has(t)) { depth.set(t, depth.get(u) + 1); next.push(t); }
  queue = next;
}
for (const u of urls) if (!depth.has(u)) add('CRITICAL', 'INTERNAL', u, 'orphan — nås inte via crawlbara länkar från huvudhubben');
const maxDepth = Math.max(...[...depth.values()]);
for (const [u, d] of depth) if (d > 3) add('HIGH', 'INTERNAL', u, `crawldjup ${d} (> 3 klick från hubben)`);
// PageRank (förenklad, d=0.85, 40 iterationer — deterministisk)
let pr = new Map(urls.map((u) => [u, 1 / urls.length]));
for (let i = 0; i < 40; i++) {
  const next = new Map(urls.map((u) => [u, 0.15 / urls.length]));
  for (const u of urls) {
    const outs = outLinks.get(u);
    if (!outs.length) continue;
    const share = (0.85 * pr.get(u)) / outs.length;
    for (const t of outs) next.set(t, next.get(t) + share);
  }
  pr = next;
}
const ranked = [...pr.entries()].sort((a, b) => b[1] - a[1]);
const top10Share = ranked.slice(0, 10).reduce((s, [, v]) => s + v, 0);
// Ankarfördelning: varje sida ska ha ≥1 beskrivande ankare (inte bara "läs mer")
for (const [target, map] of anchors) {
  const total = [...map.values()].reduce((a, b) => a + b, 0);
  const generic = [...map.entries()].filter(([a]) => /^(läs mer|klicka här|här|mer)$/.test(a)).reduce((s, [, n]) => s + n, 0);
  if (generic / total > 0.5) add('HIGH', 'INTERNAL', target, `>50 % generiska ankare ("läs mer" m.fl.) av ${total}`);
}

// ── B: Innehållsmatris — 18 modulpunkter (maskinella proxies) ───────────────
// Proxies mot faktisk sid-HTML; en modul räknas bara om dess kännetecken finns.
const MODULES = [
  ['direkt_svar', (h) => /<p class="ingress"|<h1[\s\S]{0,600}?<p/.test(h)],
  ['grundvillkor', (h) => /Vem kan få|Grundvillkor|Vem kan söka/i.test(h)],
  ['belopp', (h) => /Belopp|kr\b|kronor/i.test(h)],
  ['exempel', (h) => /Exempel|Räkneexempel|Typfall/i.test(h)],
  ['situationer', (h) => /situation|Om du (är|har|bor)/i.test(h)],
  ['fragor_faq', (h) => /Vanliga frågor|FAQPage|<details/i.test(h)],
  ['kalkylator', (h) => /kalkylator|räkna ut din/i.test(h)],
  ['eligibility_check', (h) => /behörighetskontroll|kolla om du|Svara på .* frågor/i.test(h)],
  ['ansokningsmanual', (h) => /Så ansöker du|steg för steg/i.test(h)],
  ['dokumentchecklista', (h) => /underlag|dokument du behöver|checklista/i.test(h)],
  ['relaterade_stod', (h) => /Relaterade stöd/i.test(h)],
  ['jamforelser', (h) => /skillnaden mellan|jämför|eller/i.test(h) && /<table/.test(h)],
  ['vanliga_fel', (h) => /Vanliga fel|Vanliga misstag|avslag beror/i.test(h)],
  ['forandringar_2026', (h) => /2026/.test(h) && /ändra|nytt|höjs|sänks|från och med/i.test(h)],
  ['primarkallor', (h) => /Källa|Officiell källa/i.test(h)],
  ['officiell_ansokningsvag', (h) => /Ansök hos|Ansök direkt|myndigheten är alltid gratis|Till ansökan/i.test(h)],
  ['uppdateringsdatum', (h) => /kontrollerad|dateModified/i.test(h)],
  ['unik_data', (h) => /Bidragskolls (data|analys|genomgång)|vår (genomgång|analys) visar/i.test(h)],
];
const contentMatrix = [];
for (const [url, h] of html) {
  const mods = Object.fromEntries(MODULES.map(([k, fn]) => [k, fn(h)]));
  const have = Object.values(mods).filter(Boolean).length;
  contentMatrix.push({ page: url, moduler: have, av: MODULES.length, detalj: mods, ord: wordCount(h) });
}
// Tier 1 = klustersidorna som ska bära lanseringen. Innan de byggts pekar
// registret (seo/gate0-keywords.json) klusterintenten mot närmaste sida —
// innehålls-graden sätts där; här flaggas den samlade bilden.
const median = (arr) => arr.slice().sort((a, b) => a - b)[Math.floor(arr.length / 2)];
const medOrd = median(contentMatrix.map((c) => c.ord));
const medMod = median(contentMatrix.map((c) => c.moduler));
if (medMod < 12) add(ALLOW_CONTENT_RED ? 'CONTENT-RED' : 'HIGH', 'CONTENT', '(hela ytan)',
  `medianen är ${medMod}/${MODULES.length} innehållsmoduler och ${medOrd} ord — Tier 1-nivån (docs/CONTENT_ENGINE.md gold standard) är inte nådd; byggkön = 25-klusterfasen`);

// ── Rapport ─────────────────────────────────────────────────────────────────
const grades = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0, 'CONTENT-RED': 0 };
for (const f of findings) grades[f.grade]++;
const report = {
  _kontrakt: 'Genererad av tools/gate0.mjs (Zero-Compromise Gate, deterministiska blocken B–E). Extern länkstatus kan inte verifieras från sandlådan (utgående HTTP blockeras) — den kontrollen ligger i tools/deploy-smoke.mjs efter deploy. SERP-blocket (A) bor i seo/gate0-keywords.json.',
  sidor: urls.length,
  fynd: { ...grades, lista: findings.sort((a, b) => a.grade.localeCompare(b.grade)) },
  teknik: { externa_lankar_unika: externalLinks.size, externa_lankar_status: 'UNVERIFIABLE_IN_SANDBOX — verifieras av deploy-smoke' },
  media: { img_element: media.length, delade_tillgangar: assetInventory, illustrationer: illustrations.length },
  intern_auktoritet: {
    max_djup: maxDepth,
    orphans: urls.filter((u) => !depth.has(u)).length,
    pagerank_topp10: ranked.slice(0, 10).map(([u, v]) => ({ url: u, pr: Math.round(v * 10000) / 10000 })),
    topp10_andel_av_auktoritet: Math.round(top10Share * 1000) / 10,
    median_inlankar: median(urls.map((u) => inLinks.get(u).length)),
    median_utlankar: median(urls.map((u) => outLinks.get(u).length)),
  },
  innehall: { median_moduler: medMod, av: MODULES.length, median_ord: medOrd, per_sida: contentMatrix },
  externa_lankar: [...externalLinks.entries()].map(([url, ps]) => ({ url, pages: ps.length })).sort((a, b) => b.pages - a.pages),
};
mkdirSync(join(ROOT, 'artifacts'), { recursive: true });
writeFileSync(join(ROOT, 'artifacts', 'gate0-report.json'), JSON.stringify(report, null, 2) + '\n');

console.log(`GATE 0 (deterministiska blocken): ${urls.length} sidor crawlade`);
console.log(`  fynd: CRITICAL ${grades.CRITICAL} · HIGH ${grades.HIGH} · MEDIUM ${grades.MEDIUM} · LOW ${grades.LOW} · CONTENT-RED ${grades['CONTENT-RED']}`);
console.log(`  media: ${media.length} <img> på publika ytan, ${assetInventory.length} tillgångar inventerade`);
console.log(`  intern auktoritet: maxdjup ${maxDepth}, orphans ${report.intern_auktoritet.orphans}, topp-10 bär ${report.intern_auktoritet.topp10_andel_av_auktoritet} % av PageRank`);
console.log(`  innehåll: median ${medMod}/${MODULES.length} moduler, ${medOrd} ord`);
console.log(`  externa länkar: ${externalLinks.size} unika (status verifieras i deploy-smoke)`);
for (const f of findings.filter((f) => f.grade === 'CRITICAL' || f.grade === 'HIGH').slice(0, 20)) console.log(`  [${f.grade}] ${f.page} — ${f.what}`);
console.log('→ artifacts/gate0-report.json');
if (grades.CRITICAL + grades.HIGH > 0) { console.error('GATE 0: FAIL (CRITICAL/HIGH-fynd finns)'); process.exit(1); }
console.log('GATE 0 (deterministiska blocken): PASS' + (grades['CONTENT-RED'] ? ' — men CONTENT-RED kvarstår (byggkön)' : ''));
