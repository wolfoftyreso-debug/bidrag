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
// Gate 0: länkankare till stöd med kolliderande namn bär finansiären, så att
// tre olika "Projektstöd" aldrig får identiska ankartexter mot olika mål.
const anchorTitle = (o) => {
  const bare = cap(shortTitle(o));
  return titleCollisions.has(bare) ? `${bare} – ${authorityByKey.get(o.authorityKey)?.name ?? ''}` : bare;
};
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
  // Red team F8: lova bara "belopp" i titeln när stödet faktiskt har ett
  // beloppstak att visa — annars utlovar titeln innehåll sidan inte har.
  const hasAmount = o.maxAmountMinor != null || o.maxFundingSharePercent != null;
  const candidates = [
    `${base} – ${hasAmount ? 'villkor, belopp och ansökan' : 'villkor och ansökan'} | Bidragskoll`,
    `${base} – så fungerar stödet | Bidragskoll`,
    `${base} | Bidragskoll`,
  ];
  for (const c of candidates) if (c.length <= 70) return c;
  return `${base.slice(0, 55).replace(/\s+\S*$/, '')}… | Bidragskoll`;
}
function deadlineText(o) {
  // Red team F5: ett closesAt-datum på ett återkommande stöd får inte renderas
  // som en enda hård slutdeadline — då döljs att stödet öppnar igen, och ett
  // passerat datum ser ut som den aktuella deadlinen. Rama in det som "nästa
  // omgång" och behåll den återkommande naturen.
  if (o.closesAt) {
    const date = o.closesAt.slice(0, 10);
    return o.deadlineModel === 'recurring'
      ? `Återkommande stöd — nästa ansökningsomgång stänger ${date} (kontrollera aktuella datum hos källan)`
      : `Ansökan stänger ${date}`;
  }
  if (o.deadlineModel === 'rolling') return 'Löpande ansökan — ingen fast deadline';
  if (o.deadlineModel === 'recurring') return 'Återkommande stöd — ansökan öppnar i omgångar, se den officiella källan';
  return 'Nästa ansökningsomgång är inte publicerad ännu';
}

// ── Gemensam sidram ──────────────────────────────────────────────────────────
/* Designsystemet "Bläck" (design/bidragskoll.css) — varma neutraler, Bidragskoll-blå
   (#0056A3), Public Sans + Source Serif 4. Fonterna laddas via länk i layout()
   (preconnect + display=swap) så sidan renderar direkt med fallback-stacken. */
const CSS = `
:root{--blue:#0056A3;--deep:#003a6d;--ink:#1f1d18;--soft:#57534a;--line:#e6e2d8;--bg:#f7f5f0;--card:#fffdf9;--warnbg:#f5edd8;--warn:#8a6510;--sans:'Public Sans',ui-sans-serif,system-ui,-apple-system,'Segoe UI',Roboto,Arial,sans-serif;--serif:'Source Serif 4',Georgia,serif}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.65 var(--sans);-webkit-font-smoothing:antialiased}
.wrap{max-width:760px;margin:0 auto;padding:1.2rem 1rem 3rem}
header.site{display:flex;justify-content:space-between;align-items:center;gap:1rem;padding:.4rem 0 1rem}
.brand{display:inline-flex;align-items:center;gap:.45rem;font-family:var(--sans);font-weight:800;font-size:1.15rem;letter-spacing:-.015em;color:var(--blue);text-decoration:none}.brand-mark{width:1.4rem;height:1.4rem;flex-shrink:0;display:block}
.cta{background:var(--blue);color:#fff;text-decoration:none;font-weight:600;padding:.5rem .95rem;border-radius:10px;font-size:.92rem;white-space:nowrap;box-shadow:0 2px 6px rgba(0, 86, 163,.28)}
nav.crumbs{font-size:.82rem;color:var(--soft);margin:0 0 .8rem}nav.crumbs a{color:var(--soft)}
h1{font-family:var(--serif);font-weight:600;font-size:1.7rem;line-height:1.25;letter-spacing:-.015em;margin:.1rem 0 .35rem}
.eyebrow{font-size:.8rem;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--soft)}
.lead{font-size:1.06rem;color:var(--ink);max-width:64ch}
h2{font-family:var(--serif);font-weight:600;font-size:1.25rem;margin:1.6rem 0 .5rem}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:1.1rem 1.3rem;margin:1rem 0}
table.fakta{width:100%;border-collapse:collapse;font-size:.95rem;table-layout:fixed}table.fakta th{text-align:left;font-weight:600;padding:.45rem .6rem .45rem 0;vertical-align:top;width:34%;color:var(--soft);font-size:.86rem}table.fakta td{overflow-wrap:break-word}
table.fakta td{padding:.45rem 0;border-bottom:1px solid var(--line)}table.fakta tr:last-child td{border-bottom:0}
ul{padding-left:1.2rem}li{margin:.35rem 0;max-width:62ch}
.honest{background:var(--warnbg);border-left:3px solid var(--warn);border-radius:0 8px 8px 0;padding:.75rem 1rem;font-size:.9rem;margin:1rem 0}
.paths{display:grid;gap:.8rem;grid-template-columns:1fr;margin:.6rem 0}
.path{border:1px solid var(--line);border-radius:10px;padding:.9rem 1.05rem;background:var(--card)}
.path strong{display:block;margin-bottom:.2rem}
.path a.knapp{display:inline-block;margin-top:.5rem;background:var(--blue);color:#fff;text-decoration:none;font-weight:600;padding:.45rem .9rem;border-radius:8px;font-size:.9rem;box-shadow:0 2px 6px rgba(0, 86, 163,.28)}
.path a.knapp.sekundar{background:var(--card);color:var(--blue);border:1px solid var(--blue);box-shadow:none}
.stodlista{list-style:none;padding:0}.stodlista li{border-bottom:1px solid var(--line);padding:.7rem 0;margin:0;max-width:none}
.stodlista a{font-weight:600;text-decoration:none;color:var(--blue)}.stodlista .sum{display:block;font-size:.9rem;color:var(--soft);max-width:70ch}
.kalla{font-size:.86rem;color:var(--soft);border-top:1px solid var(--line);margin-top:1.6rem;padding-top:.9rem}
footer.site{margin-top:2.2rem;border-top:1px solid var(--line);padding-top:1rem;font-size:.84rem;color:var(--soft)}
a{color:var(--blue)}@media(min-width:640px){.paths{grid-template-columns:1fr 1fr}}
@media(max-width:380px){.cta{white-space:normal;text-align:center}}
.kalla a{overflow-wrap:anywhere}
.stodlista a,.relaterade a{overflow-wrap:anywhere}
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
<meta property="og:locale" content="sv_SE">
<meta property="og:image" content="${BASE}/og/bidragskoll-og.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Bidragskoll.se — Berätta din situation. Se vilka stöd du ser ut att kunna ha rätt till.">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="${esc(title)}">
<meta name="twitter:description" content="${esc(description)}">
<meta name="twitter:image" content="${BASE}/og/bidragskoll-og.png">
<meta name="theme-color" content="#0056A3">
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="/icon-180.png">
<link rel="manifest" href="/site.webmanifest">
<script type="application/ld+json">${JSON.stringify(jsonld).replace(/</g, '\\u003c').replace(/>/g, '\\u003e')}</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&family=Source+Serif+4:opsz,wght@8..60,600;8..60,700&display=swap">
<style>${CSS}</style>
</head>
<body>
<div class="wrap">
<header class="site"><a class="brand" href="/bidrag/"><svg class="brand-mark" viewBox="0 0 100 100" aria-hidden="true"><g fill="none" stroke="#0056A3" stroke-width="15.5" stroke-linecap="round"><line x1="44.5" y1="56" x2="27.5" y2="38"/><line x1="44.5" y1="56" x2="77.5" y2="23"/><line x1="44.5" y1="56" x2="22.5" y2="85"/><line x1="44.5" y1="56" x2="73.5" y2="86"/></g><circle cx="36.5" cy="19" r="12.5" fill="#0056A3"/></svg>Bidragskoll</a><a class="cta" href="/">Starta din utredning</a></header>
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
  // Gate 0: kolliderande stödnamn ("Projektstöd" ×3) disambigueras med
  // finansiären i H1/brödsmulor/schema — dubblett-H1 är nolltolerans.
  const short = anchorTitle(o);
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
<ul class="stodlista">${rel.map((r) => `<li><a href="/bidrag/${r.slug}/">${esc(anchorTitle(r))}</a><span class="sum">${esc(r.summary)}</span></li>`).join('')}</ul>` : ''}

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
      .map((o) => `<li><a href="/bidrag/${o.slug}/">${esc(anchorTitle(o))}</a><span class="sum">${esc(o.summary)}</span></li>`)
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

// Äkta 404 (§40 i perfektionsdoktrinen): hjälpsam, lugn, med vägar vidare.
// Serveras av Vercel med statuskod 404 för okända /bidrag/-vägar (SPA-
// rewriten exkluderar /bidrag/ i vercel.json). Ingen sitemap-post, noindex.
const notFound = layout({
  title: 'Sidan finns inte | Bidragskoll',
  description: 'Vi hittar inte sidan — men vi kan fortfarande hjälpa dig hitta stödet.',
  canonical: `${BASE}/404`,
  crumbs: [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Sidan finns inte' }],
  jsonld: { '@context': 'https://schema.org', '@graph': [] },
  body: `
<p class="eyebrow">Fel 404</p>
<h1>Vi hittar inte sidan — men vi kan fortfarande hjälpa dig hitta stödet</h1>
<p class="lead">Sidan kan ha flyttats, eller så blev adressen fel. Ingen fara: allt vårt innehåll når du härifrån.</p>
<div class="paths">
<div class="path"><strong>Se alla stöd</strong>Hela kunskapsbasen, grupperad efter vem stödet gäller.<br><a class="knapp" href="/bidrag/">Till översikten</a></div>
<div class="path"><strong>Berätta din situation</strong>Svara på några frågor så visar vi vilka stöd som ser ut att kunna gälla dig.<br><a class="knapp sekundar" href="/">Starta genomgången</a></div>
</div>
<p class="kalla">Verkar en länk vara trasig? Det vill vi veta — mejla oss så rättar vi den.</p>`,
}).replace('</title>', '</title>\n<meta name="robots" content="noindex">');
writeFileSync(join(OUT, '404.html'), notFound);

console.log(`Genererade ${pages.length} publika sidor + 404.html + sitemap.xml + robots.txt → ${OUT}`);
