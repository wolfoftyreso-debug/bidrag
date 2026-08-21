/**
 * Genererar Bidragskolls PUBLIKA, INDEXERBARA innehållsyta ur sanningsmodellen
 * (apps/api/src/seed/data.ts) — samma data som driver produkten, så sidorna
 * kan aldrig divergera från kunskapsbasen:
 *
 *   /bidrag/                     huvudhubb — alla stöd, grupperade
 *   /bidrag/<målgruppshubb>/     hubbar (endast där ≥3 stöd finns)
 *   /bidrag/<slug>/              en entity-sida per stöd (72 st)
 *   /sitemap.xml  /robots.txt
 *
 * Principer (docs/SEO_STRATEGY.md): entity-first, ärlig YMYL-svenska
 * ("kan ha rätt till", aldrig garantier), källa + senast kontrollerad +
 * kureringsstämpel på varje sida, rena statiska HTML-dokument utan JS
 * (triviala Core Web Vitals), schema.org Organization/WebSite/BreadcrumbList/
 * WebPage — ingen påhittad FAQ-/rating-markup. Inga tomma SEO-sektioner:
 * sektioner renderas bara när seeden har data.
 *
 *   node tools/genseo.mjs                      # → artifacts/seo-site/
 *   node tools/genseo.mjs --out apps/web/dist  # Vercel-bygget
 *
 * Deterministisk: sorterad utdata, datum ur seedens CURATED_AT (aldrig now).
 */
import { mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const outFlag = process.argv.indexOf('--out');
const OUT = outFlag > -1 ? join(ROOT, process.argv[outFlag + 1]) : join(ROOT, 'artifacts', 'seo-site');
const BASE = 'https://bidragskoll.se';

const { opportunities, authorities, CURATED_AT } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const authorityByKey = new Map(authorities.map((a) => [a.key, a]));
const CHECKED = CURATED_AT.slice(0, 10);

// ── Etiketter (speglar produktens språk) ─────────────────────────────────────
const INSTRUMENT = {
  public_grant: 'Statligt bidrag', eu_grant: 'EU-stöd', scholarship: 'Stipendium', stipend: 'Stipendium',
  travel_grant: 'Resebidrag', project_grant: 'Projektbidrag', social_benefit: 'Ersättning',
  educational_support: 'Studiestöd', loan: 'Lån',
};
const APPLICANT = {
  individual: 'privatpersoner', company: 'företag', association: 'föreningar',
  economic_association: 'ekonomiska föreningar', informal_group: 'informella grupper',
  municipality: 'kommuner', region: 'regioner', public_body: 'offentliga organ', university: 'lärosäten',
};
const HUBS = [
  { slug: 'privatpersoner', title: 'Bidrag och ersättningar för privatpersoner', short: 'Privatpersoner', types: ['individual'] },
  { slug: 'foretag', title: 'Stöd och bidrag för företag', short: 'Företag', types: ['company', 'economic_association'] },
  { slug: 'foreningar', title: 'Bidrag för föreningar och civilsamhälle', short: 'Föreningar', types: ['association', 'informal_group'] },
  { slug: 'offentlig-sektor', title: 'Statsbidrag och stöd för offentlig sektor och forskning', short: 'Offentlig sektor & forskning', types: ['municipality', 'region', 'public_body', 'university'] },
];

const esc = (s) => String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const kr = (minor) => `${Math.round(minor / 100).toLocaleString('sv-SE')} kr`;
const shortTitle = (o) => (o.title.split(' — ').pop() ?? o.title).trim();
const cap = (s) => s.charAt(0).toUpperCase() + s.slice(1);

function metaDescription(o) {
  const s = `${o.summary} Se villkor, belopp och hur du ansöker — med källa och senast kontrollerad-datum.`;
  if (s.length <= 158) return s;
  return s.slice(0, 155).replace(/\s+\S*$/, '') + '…';
}
// Titelsystem (§27): naturligt, unikt, ≤70 tecken. Stöd med samma kortnamn
// ("Projektstöd" finns hos flera finansiärer) särskiljs med finansiärens namn.
const titleCollisions = (() => {
  const counts = new Map();
  for (const o of opportunities) {
    const k = cap(shortTitle(o));
    counts.set(k, (counts.get(k) ?? 0) + 1);
  }
  return new Set([...counts.entries()].filter(([, n]) => n > 1).map(([k]) => k));
})();

function pageTitle(o) {
  const short = cap(shortTitle(o));
  const auth = authorityByKey.get(o.authorityKey)?.name ?? '';
  const base = titleCollisions.has(short) ? `${short} – ${auth}` : short;
  const candidates = [
    `${base} – villkor, belopp och ansökan | Bidragskoll`,
    `${base} – så fungerar stödet | Bidragskoll`,
    `${base} | Bidragskoll`,
  ];
  for (const c of candidates) if (c.length <= 70) return c;
  return `${base.slice(0, 55).replace(/\s+\S*$/, '')}… | Bidragskoll`;
}
function deadlineText(o) {
  if (o.closesAt) return `Ansökan stänger ${o.closesAt.slice(0, 10)}`;
  if (o.deadlineModel === 'rolling') return 'Löpande ansökan — ingen fast deadline';
  return 'Nästa ansökningsomgång är inte publicerad ännu';
}

// ── Gemensam sidram ──────────────────────────────────────────────────────────
const CSS = `
:root{--blue:#2050d8;--deep:#142f83;--ink:#16203a;--soft:#5b6579;--line:#e3e6ec;--bg:#f7f8fa;--card:#fff;--warnbg:#fdf6e3;--warn:#a05a08}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.65 ui-sans-serif,system-ui,-apple-system,'Segoe UI',Roboto,Arial,sans-serif;-webkit-font-smoothing:antialiased}
.wrap{max-width:760px;margin:0 auto;padding:1.2rem 1rem 3rem}
header.site{display:flex;justify-content:space-between;align-items:center;gap:1rem;padding:.4rem 0 1rem}
.brand{font-weight:800;font-size:1.15rem;color:var(--deep);text-decoration:none}.brand::before{content:'';display:inline-block;width:.6rem;height:.6rem;margin-right:.4rem;border-radius:3px;background:linear-gradient(135deg,var(--blue),var(--deep))}
.cta{background:var(--blue);color:#fff;text-decoration:none;font-weight:600;padding:.5rem .95rem;border-radius:9px;font-size:.92rem;white-space:nowrap}
nav.crumbs{font-size:.82rem;color:var(--soft);margin:0 0 .8rem}nav.crumbs a{color:var(--soft)}
h1{font-size:1.65rem;line-height:1.25;letter-spacing:-.015em;margin:.1rem 0 .35rem}
.eyebrow{font-size:.8rem;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--soft)}
.lead{font-size:1.06rem;color:var(--ink);max-width:64ch}
h2{font-size:1.22rem;margin:1.6rem 0 .5rem}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:1.1rem 1.3rem;margin:1rem 0}
table.fakta{width:100%;border-collapse:collapse;font-size:.95rem}table.fakta th{text-align:left;font-weight:600;padding:.45rem .6rem .45rem 0;vertical-align:top;white-space:nowrap;color:var(--soft);font-size:.86rem}
table.fakta td{padding:.45rem 0;border-bottom:1px solid var(--line)}table.fakta tr:last-child td{border-bottom:0}
ul{padding-left:1.2rem}li{margin:.35rem 0;max-width:62ch}
.honest{background:var(--warnbg);border-left:3px solid var(--warn);border-radius:0 8px 8px 0;padding:.75rem 1rem;font-size:.9rem;margin:1rem 0}
.paths{display:grid;gap:.8rem;grid-template-columns:1fr;margin:.6rem 0}
.path{border:1px solid var(--line);border-radius:10px;padding:.9rem 1.05rem;background:var(--card)}
.path strong{display:block;margin-bottom:.2rem}
.path a.knapp{display:inline-block;margin-top:.5rem;background:var(--blue);color:#fff;text-decoration:none;font-weight:600;padding:.45rem .9rem;border-radius:8px;font-size:.9rem}
.path a.knapp.sekundar{background:#fff;color:var(--blue);border:1px solid var(--blue)}
.stodlista{list-style:none;padding:0}.stodlista li{border-bottom:1px solid var(--line);padding:.7rem 0;margin:0;max-width:none}
.stodlista a{font-weight:600;text-decoration:none;color:var(--blue)}.stodlista .sum{display:block;font-size:.9rem;color:var(--soft);max-width:70ch}
.kalla{font-size:.86rem;color:var(--soft);border-top:1px solid var(--line);margin-top:1.6rem;padding-top:.9rem}
footer.site{margin-top:2.2rem;border-top:1px solid var(--line);padding-top:1rem;font-size:.84rem;color:var(--soft)}
a{color:var(--blue)}@media(min-width:640px){.paths{grid-template-columns:1fr 1fr}}
`;

function layout({ title, description, canonical, crumbs, jsonld, body }) {
  const crumbHtml = crumbs
    .map((c, i) => (i === crumbs.length - 1 ? esc(c.name) : `<a href="${c.url}">${esc(c.name)}</a>`))
    .join(' › ');
  return `<!doctype html>
<html lang="sv">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<meta name="description" content="${esc(description)}">
<link rel="canonical" href="${canonical}">
<meta property="og:site_name" content="Bidragskoll.se">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(description)}">
<meta property="og:url" content="${canonical}">
<meta property="og:type" content="website">
<script type="application/ld+json">${JSON.stringify(jsonld)}</script>
<style>${CSS}</style>
</head>
<body>
<div class="wrap">
<header class="site"><a class="brand" href="/bidrag/">Bidragskoll.se</a><a class="cta" href="/">Starta din utredning</a></header>
<nav class="crumbs" aria-label="Du är här">${crumbHtml}</nav>
${body}
<footer class="site">
<p><strong>Bidragskoll.se</strong> är en oberoende orienterings- och förberedelsetjänst — inte en myndighet.
Bedömningar är vägledande; beslut fattas alltid av den ansvariga myndigheten eller finansiären.
Att ansöka själv direkt hos källan är alltid gratis.</p>
<p>Källpolicy: varje stöd länkar till sin officiella källa och visar när uppgifterna senast kontrollerades.
Innehållet är AI-sammanställt från officiella källor och ännu inte granskat av människa — kontrollera alltid
aktuella villkor hos källan. · <a href="/villkor">Köpvillkor</a></p>
</footer>
</div>
</body>
</html>
`;
}

function baseGraph(canonical, title, crumbs) {
  return [
    {
      '@type': 'Organization', '@id': `${BASE}/#org`, name: 'Bidragskoll.se', url: `${BASE}/`,
      description: 'Oberoende svensk tjänst som hjälper dig hitta bidrag, stöd och ersättningar du kan ha rätt till — och förbereder ansökan.',
    },
    { '@type': 'WebSite', '@id': `${BASE}/#website`, url: `${BASE}/`, name: 'Bidragskoll.se', inLanguage: 'sv', publisher: { '@id': `${BASE}/#org` } },
    {
      '@type': 'BreadcrumbList',
      itemListElement: crumbs.map((c, i) => ({ '@type': 'ListItem', position: i + 1, name: c.name, item: `${BASE}${c.url}` })),
    },
    { '@type': 'WebPage', url: canonical, name: title, inLanguage: 'sv', dateModified: CHECKED, isPartOf: { '@id': `${BASE}/#website` } },
  ];
}

// ── Entity-sidor ─────────────────────────────────────────────────────────────
function hubsFor(o) {
  return HUBS.filter((h) => (o.applicantTypes ?? []).some((t) => h.types.includes(t)));
}
function relatedTo(o) {
  const sameAuthority = opportunities.filter((x) => x.slug !== o.slug && x.authorityKey === o.authorityKey);
  const sameType = opportunities.filter(
    (x) => x.slug !== o.slug && x.instrumentType === o.instrumentType && x.authorityKey !== o.authorityKey,
  );
  const picked = [];
  for (const x of [...sameAuthority, ...sameType]) {
    if (picked.length >= 5) break;
    if (!picked.includes(x)) picked.push(x);
  }
  return picked;
}

function entityPage(o) {
  const auth = authorityByKey.get(o.authorityKey);
  const short = cap(shortTitle(o));
  const canonical = `${BASE}/bidrag/${o.slug}/`;
  const hub = hubsFor(o)[0] ?? HUBS[0];
  const crumbs = [
    { name: 'Bidrag', url: '/bidrag/' },
    { name: hub.short, url: `/bidrag/${hub.slug}/` },
    { name: short, url: `/bidrag/${o.slug}/` },
  ];
  const krav = (o.criteria ?? []).filter((c) => c.kind === 'hard' || c.kind === 'mandatory');
  const styrker = (o.criteria ?? []).filter((c) => c.kind === 'weighted');
  const evidens = o.evidenceRequirements ?? [];
  const rel = relatedTo(o);

  const belopp = o.maxAmountMinor
    ? `Upp till ${kr(o.maxAmountMinor)}${o.maxFundingSharePercent ? ` (max ${o.maxFundingSharePercent} % av kostnaden)` : ''}`
    : o.maxFundingSharePercent
      ? `Upp till ${o.maxFundingSharePercent} % av godkänd kostnad — beloppet varierar, se källan`
      : 'Varierar — se den officiella källan';

  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, pageTitle(o), crumbs) };
  jsonld['@graph'][3].about = { '@type': 'Thing', name: short, sameAs: o.sourceUrl };

  const body = `
<p class="eyebrow">${esc(auth?.name ?? '')} · ${esc(INSTRUMENT[o.instrumentType] ?? 'Stöd')}</p>
<h1>${esc(short)}</h1>
<p class="lead">${esc(o.summary)}</p>

<div class="card">
<table class="fakta">
<tr><th scope="row">Vem kan söka</th><td>${esc((o.applicantTypes ?? []).map((t) => APPLICANT[t] ?? t).map(cap).join(', '))}</td></tr>
<tr><th scope="row">Belopp</th><td>${esc(belopp)}</td></tr>
<tr><th scope="row">Deadline</th><td>${esc(deadlineText(o))}</td></tr>
<tr><th scope="row">Så ansöker du</th><td>${esc(o.applicationMethod ?? 'Se den officiella källan')}</td></tr>
<tr><th scope="row">Arbetsinsats</th><td>Cirka ${o.estimatedEffortDays} ${o.estimatedEffortDays === 1 ? 'arbetsdag' : 'arbetsdagar'} att förbereda</td></tr>
</table>
</div>

${o.description && o.description !== o.summary ? `<h2>Vad är ${esc(shortTitle(o).toLowerCase())}?</h2>\n<p>${esc(o.description)}</p>` : ''}

${krav.length ? `<h2>Vem kan få stödet?</h2>
<p>Så här ser villkoren ut enligt den officiella källan. Bedömningen nedan är vägledande —
det slutliga beslutet fattas alltid av ${esc(auth?.name ?? 'den ansvariga myndigheten')}.</p>
<ul>${krav.map((c) => `<li>${esc(c.description)}</li>`).join('')}</ul>` : ''}

${styrker.length ? `<h2>Det här stärker ansökan</h2>
<ul>${styrker.map((c) => `<li>${esc(c.description)}</li>`).join('')}</ul>` : ''}

${evidens.length ? `<h2>Underlag som brukar behövas</h2>
<ul>${evidens.map((e) => `<li>${esc(e.description)}${e.mandatory ? ' <strong>(obligatoriskt)</strong>' : ''}</li>`).join('')}</ul>` : ''}

<h2>Två vägar vidare</h2>
<div class="paths">
<div class="path"><strong>Ansök själv — gratis</strong>
Den slutliga ansökan görs alltid i den officiella tjänsten, och det kostar ingenting.
${o.applicationUrl ? `<a class="knapp sekundar" href="${esc(o.applicationUrl)}" rel="noopener">Till ${esc(auth?.name ?? 'källan')}</a>` : ''}</div>
<div class="path"><strong>Låt Bidragskoll utreda din situation</strong>
Svara på några frågor så ser du vilka stöd som kan passa dig — upptäckten är gratis,
den fullständiga analysen kostar 39 kr och en färdigförberedd ansökan 19 kr.
<a class="knapp" href="/">Starta utredningen</a></div>
</div>

<div class="honest">Uppgifterna på den här sidan är AI-sammanställda från den officiella källan och ännu inte
granskade av människa. Regler, belopp och datum kan ändras — kontrollera alltid aktuella villkor hos källan
innan du skickar in en ansökan.</div>

${rel.length ? `<h2>Relaterade stöd</h2>
<ul class="stodlista">${rel.map((r) => `<li><a href="/bidrag/${r.slug}/">${esc(cap(shortTitle(r)))}</a><span class="sum">${esc(r.summary)}</span></li>`).join('')}</ul>` : ''}

<p class="kalla"><strong>Källa:</strong> <a href="${esc(o.sourceUrl)}" rel="noopener">${esc(o.sourceUrl)}</a><br>
<strong>Senast kontrollerad:</strong> ${CHECKED}${auth?.website ? ` · <strong>Myndighet:</strong> <a href="${esc(auth.website)}" rel="noopener">${esc(auth.name)}</a>` : ''}</p>
`;

  return layout({ title: pageTitle(o), description: metaDescription(o), canonical, crumbs, jsonld, body });
}

// ── Hubbar ───────────────────────────────────────────────────────────────────
function hubPage(hub, entries) {
  const canonical = `${BASE}/bidrag/${hub.slug}/`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: hub.short, url: `/bidrag/${hub.slug}/` }];
  const title = `${hub.title} | Bidragskoll`;
  const description = `${entries.length} stöd för ${hub.short.toLowerCase()} — villkor, belopp och ansökan, med källa och senast kontrollerad-datum för varje stöd.`;
  const byInstrument = new Map();
  for (const o of entries) {
    const key = INSTRUMENT[o.instrumentType] ?? 'Övriga stöd';
    if (!byInstrument.has(key)) byInstrument.set(key, []);
    byInstrument.get(key).push(o);
  }
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title, crumbs) };
  const body = `
<h1>${esc(hub.title)}</h1>
<p class="lead">${entries.length} stöd i Bidragskolls kunskapsbas riktar sig till ${esc(hub.short.toLowerCase())}.
Varje stöd visas med villkor, belopp och officiell källa. Osäker på vad som gäller dig?
<a href="/">Bidragskolls utredning</a> ställer frågorna åt dig — en i taget.</p>
${[...byInstrument.entries()]
  .sort(([a], [b]) => a.localeCompare(b, 'sv'))
  .map(
    ([label, list]) => `<h2>${esc(label)}</h2>
<ul class="stodlista">${list
      .sort((a, b) => shortTitle(a).localeCompare(shortTitle(b), 'sv'))
      .map((o) => `<li><a href="/bidrag/${o.slug}/">${esc(cap(shortTitle(o)))}</a><span class="sum">${esc(o.summary)}</span></li>`)
      .join('')}</ul>`,
  )
  .join('')}
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED} · Innehållet är AI-sammanställt från officiella källor — kontrollera alltid aktuella villkor hos respektive källa.</p>
`;
  return layout({ title, description, canonical, crumbs, jsonld, body });
}

function indexPage(hubEntries) {
  const canonical = `${BASE}/bidrag/`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }];
  const title = 'Bidrag och stöd i Sverige – hela katalogen | Bidragskoll';
  const description = `${opportunities.length} bidrag, ersättningar och stöd från ${authorities.length} myndigheter och finansiärer — samlade med villkor, belopp, deadlines och officiella källor.`;
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title, crumbs) };
  const body = `
<h1>Bidrag och stöd i Sverige</h1>
<p class="lead">Bidragskoll samlar ${opportunities.length} bidrag, ersättningar och stöd från ${authorities.length}
myndigheter och finansiärer — med villkor, belopp, deadlines och länk till den officiella källan för varje stöd.
Myndigheterna beskriver sina egna stöd var för sig; här får du överblicken, och
<a href="/">utredningen</a> som visar vilka stöd som kan passa just din situation.</p>
${hubEntries
  .map(
    ({ hub, entries }) => `<h2><a href="/bidrag/${hub.slug}/">${esc(hub.title)}</a></h2>
<p>${entries.length} stöd — bland annat ${esc(
      entries.slice(0, 3).map((o) => shortTitle(o)).join(', '),
    )}.</p>`,
  )
  .join('')}
<div class="honest">Bidragskoll är en oberoende tjänst — inte en myndighet. Innehållet är AI-sammanställt
från officiella källor och ännu inte granskat av människa; varje sida visar sin källa och när uppgifterna
senast kontrollerades. Att ansöka själv direkt hos myndigheten är alltid gratis.</div>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED}</p>
`;
  return layout({ title, description, canonical, crumbs, jsonld, body });
}

// ── Bygg ─────────────────────────────────────────────────────────────────────
if (outFlag === -1) rmSync(OUT, { recursive: true, force: true });
mkdirSync(join(OUT, 'bidrag'), { recursive: true });

const pages = [];
function emit(path, html) {
  const dir = join(OUT, path);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, 'index.html'), html);
  pages.push(`/${path.replace(/\\/g, '/')}/`.replace(/\/+/g, '/'));
}

const hubEntries = HUBS.map((hub) => ({
  hub,
  entries: opportunities.filter((o) => (o.applicantTypes ?? []).some((t) => hub.types.includes(t))),
})).filter(({ entries }) => entries.length >= 3);

emit('bidrag', indexPage(hubEntries));
for (const { hub, entries } of hubEntries) emit(join('bidrag', hub.slug), hubPage(hub, entries));
for (const o of [...opportunities].sort((a, b) => a.slug.localeCompare(b.slug))) emit(join('bidrag', o.slug), entityPage(o));

// Sitemap + robots. OBS: skriver bara sina egna filer — rör aldrig appens.
const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${pages.map((p) => `  <url><loc>${BASE}${p}</loc><lastmod>${CHECKED}</lastmod></url>`).join('\n')}
</urlset>
`;
writeFileSync(join(OUT, 'sitemap.xml'), sitemap);
writeFileSync(
  join(OUT, 'robots.txt'),
  `User-agent: *\nAllow: /\n\n# Appens inloggade vyer är användarspecifika och ska inte indexeras.\nDisallow: /projekt\nDisallow: /ansokningar\nDisallow: /konto\nDisallow: /dokument\nDisallow: /admin\nDisallow: /inkorg\n\nSitemap: ${BASE}/sitemap.xml\n`,
);

console.log(`Genererade ${pages.length} publika sidor + sitemap.xml + robots.txt → ${OUT}`);
