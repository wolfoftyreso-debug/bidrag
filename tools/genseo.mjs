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
import { mkdirSync, writeFileSync, rmSync, readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadIntents, resolveIntent, indexabilityVerdict, parentOverlapVerdict } from './lib/intents.mjs';
import { computeFundingIndex } from './lib/foretagsindex.mjs';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const outFlag = process.argv.indexOf('--out');
const OUT = outFlag > -1 ? join(ROOT, process.argv[outFlag + 1]) : join(ROOT, 'artifacts', 'seo-site');
const BASE = 'https://bidragskoll.se';

const { opportunities, authorities, CURATED_AT } = await import(join(ROOT, 'apps/api/src/seed/data.ts'));
const authorityByKey = new Map(authorities.map((a) => [a.key, a]));
const CHECKED = CURATED_AT.slice(0, 10);

// Kanonisk entitetsbeskrivning (FAS SEO-2) — enda källan för hur produkten
// beskrivs för Google/AI. Samma text i Organization/WebSite/WebApplication,
// startsidan och flaggskeppssidorna. semanticguard.mjs vaktar att den inte
// divergerar.
const ENTITY = JSON.parse(readFileSync(join(ROOT, 'seo', 'entity.json'), 'utf8'));

// ── I18N fas C: flerspråkiga landningssidor ─────────────────────────────────
// EN substantiell sida per språk (/{lang}/bidrag/) — inte massöversatta
// kopior av hela ytan (doorway-/spamrisk, docs/I18N_PROGRAM.md fas C).
// Sidans egen copy kommer från seo/publik-i18n.json (kurerad); stödens
// sammanfattningar kommer från fas B-översättningarna i seeden. Officiella
// stöd- och myndighetsnamn översätts aldrig.
const PUBLIK_I18N = JSON.parse(readFileSync(join(ROOT, 'seo', 'publik-i18n.json'), 'utf8')).sprak;
const { KB_TRANSLATIONS } = await import(join(ROOT, 'apps/api/src/seed/i18n/index.ts'));
// Språkkoder + HTML-attribut. prs (dari) renderas som fa-AF: en giltig
// BCP 47-tagg som sökmotorer förstår, till skillnad från den interna koden.
const SEO_LOCALES = [
  { code: 'en', hreflang: 'en', dir: 'ltr', native: 'English' },
  { code: 'es', hreflang: 'es', dir: 'ltr', native: 'Español' },
  { code: 'fr', hreflang: 'fr', dir: 'ltr', native: 'Français' },
  { code: 'ar', hreflang: 'ar', dir: 'rtl', native: 'العربية' },
  { code: 'fa', hreflang: 'fa', dir: 'rtl', native: 'فارسی' },
  { code: 'prs', hreflang: 'fa-AF', dir: 'rtl', native: 'دری' },
  { code: 'ru', hreflang: 'ru', dir: 'ltr', native: 'Русский' },
  { code: 'uk', hreflang: 'uk', dir: 'ltr', native: 'Українська' },
  { code: 'so', hreflang: 'so', dir: 'ltr', native: 'Af Soomaali' },
  { code: 'ti', hreflang: 'ti', dir: 'ltr', native: 'ትግርኛ' },
];
// Hela hreflang-klustret: svenska /bidrag/ är x-default och kanonisk källa.
const HREFLANG_CLUSTER = [
  { hreflang: 'sv', url: `${BASE}/bidrag/` },
  ...SEO_LOCALES.map((l) => ({ hreflang: l.hreflang, url: `${BASE}/${l.code}/bidrag/` })),
  { hreflang: 'x-default', url: `${BASE}/bidrag/` },
];
const hreflangTags = () =>
  HREFLANG_CLUSTER.map((a) => `<link rel="alternate" hreflang="${a.hreflang}" href="${a.url}">`).join('\n');

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
  // Föreningshubben bär förenings-klustrets verkliga sökspråk (Semrush se
  // 2026-08-28: "bidrag till förening" 210, "söka bidrag ideell förening" 170,
  // "bidrag ideell förening" 140, "föreningsbidrag" 210 — SERP:en ägs idag av
  // en privat endasidesaktör, dvs. bevisat vinnbar). titleQuery/leadQuery/faq
  // renderas av hubPage; FAQ-frågorna är verkliga PAA-frågor (volumes-filen).
  {
    slug: 'foreningar', title: 'Bidrag för föreningar och civilsamhälle', short: 'Föreningar', types: ['association', 'informal_group'],
    titleQuery: 'Bidrag till förening – stöd för ideella föreningar',
    leadQuery: 'Här finns de statliga och kommunala stöd en ideell förening kan söka — verksamhetsbidrag, projektstöd, aktivitetsstöd och lokalbidrag — samlade med villkor och officiell källa.',
    faq: [
      { q: 'Vilka bidrag kan en ideell förening söka?', a: 'Det finns tre huvudvägar: statliga stöd (till exempel via MUCF, Kulturrådet och Riksidrottsförbundet), kommunala föreningsbidrag hos kultur- och fritidsförvaltningen, och stiftelser eller fonder. Listan på den här sidan visar stöden i Bidragskolls kunskapsbas, var och en med villkor och officiell källa.' },
      { q: 'Hur söker man bidrag till en förening?', a: 'Ansökan görs alltid hos respektive finansiär — kommunala föreningsbidrag hos kommunens kultur- och fritidsförvaltning, statliga stöd i respektive myndighets e-tjänst. Varje stöd på sidan länkar till sin officiella ansökningsväg, och att ansöka själv är alltid gratis.' },
      { q: 'Hur mycket bidrag får en förening?', a: 'Beloppen fastställs av respektive finansiär och varierar med stödform, verksamhet och ort — Bidragskoll anger inga nivåer som inte är fastställda mot källan. Aktuella belopp finns hos den officiella källan som varje stöd länkar till.' },
    ],
  },
  { slug: 'offentlig-sektor', title: 'Statsbidrag och stöd för offentlig sektor och forskning', short: 'Offentlig sektor & forskning', types: ['municipality', 'region', 'public_body', 'university'] },
];

const OG_LOCALE = { sv: 'sv_SE', en: 'en_GB', es: 'es_ES', fr: 'fr_FR', ar: 'ar_AR', fa: 'fa_IR', prs: 'fa_AF', ru: 'ru_RU', uk: 'uk_UA', so: 'so_SO', ti: 'ti_ER' };
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
h3{font-family:var(--serif);font-weight:600;font-size:1.06rem;margin:1.3rem 0 .3rem}
.sprakval{list-style:none;padding:0;display:flex;flex-wrap:wrap;gap:.4rem .9rem;font-size:.95rem}.sprakval li{margin:0}
.card{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:1.1rem 1.3rem;margin:1rem 0}
table.fakta{width:100%;border-collapse:collapse;font-size:.95rem;table-layout:fixed}table.fakta th{text-align:start;font-weight:600;padding:.45rem .6rem .45rem 0;vertical-align:top;width:34%;color:var(--soft);font-size:.86rem}table.fakta td{overflow-wrap:break-word}
table.fakta td{padding:.45rem 0;border-bottom:1px solid var(--line)}table.fakta tr:last-child td{border-bottom:0}
ul{padding-inline-start:1.2rem}li{margin:.35rem 0;max-width:62ch}
.honest{background:var(--warnbg);border-inline-start:3px solid var(--warn);border-start-start-radius:0;border-end-start-radius:0;border-start-end-radius:8px;border-end-end-radius:8px;padding:.75rem 1rem;font-size:.9rem;margin:1rem 0}
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
.snabbsvar{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:.4rem 1.3rem 1rem;margin:1rem 0}
.snabbsvar h2{font-size:1.1rem;margin:.9rem 0 .3rem}
.snabbsvar dt{font-weight:600;margin:.7rem 0 .1rem}.snabbsvar dd{margin:0 0 .2rem;color:var(--soft);max-width:64ch}
.steps{counter-reset:s;list-style:none;padding:0}.steps li{position:relative;padding:.2rem 0 .2rem 2.1rem;margin:.5rem 0;max-width:60ch}
.steps li::before{counter-increment:s;content:counter(s);position:absolute;left:0;top:.15rem;width:1.5rem;height:1.5rem;border-radius:50%;background:var(--blue);color:#fff;font-weight:700;font-size:.85rem;display:grid;place-items:center}
.steps strong{display:block}
.bigcta{display:inline-block;background:var(--blue);color:#fff;text-decoration:none;font-weight:700;padding:.7rem 1.4rem;border-radius:12px;font-size:1.02rem;box-shadow:0 2px 8px rgba(0,86,163,.3);margin:.6rem 0}
`;

// lang/dir/alternates/chrome: fas C. Utan dem renderas sidan som förut (sv).
function layout({ title, description, canonical, crumbs, jsonld, body, lang = 'sv', dir = 'ltr', alternates = '', chrome = null }) {
  const crumbHtml = crumbs
    .map((c, i) => (i === crumbs.length - 1 ? esc(c.name) : `<a href="${c.url}">${esc(c.name)}</a>`))
    .join(' › ');
  return `<!doctype html>
<html lang="${lang}"${dir === 'rtl' ? ' dir="rtl"' : ''}>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<meta name="description" content="${esc(description)}">
<link rel="canonical" href="${canonical}">
${alternates}<meta property="og:site_name" content="Bidragskoll.se">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(description)}">
<meta property="og:url" content="${canonical}">
<meta property="og:type" content="website">
<meta property="og:locale" content="${OG_LOCALE[lang] ?? 'sv_SE'}">
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
<header class="site"><a class="brand" href="/bidrag/"><svg class="brand-mark" viewBox="0 0 100 100" aria-hidden="true"><g fill="none" stroke="#0056A3" stroke-width="15.5" stroke-linecap="round"><line x1="44.5" y1="56" x2="27.5" y2="38"/><line x1="44.5" y1="56" x2="77.5" y2="23"/><line x1="44.5" y1="56" x2="22.5" y2="85"/><line x1="44.5" y1="56" x2="73.5" y2="86"/></g><circle cx="36.5" cy="19" r="12.5" fill="#0056A3"/></svg>Bidragskoll</a><a class="cta" href="${chrome ? chrome.appHref : '/'}">${esc(chrome ? chrome.cta : 'Starta din utredning')}</a></header>
<nav class="crumbs" aria-label="${esc(chrome ? chrome.crumbLabel : 'Du är här')}">${crumbHtml}</nav>
${body}
<footer class="site">
${chrome ? `<p>${esc(chrome.footerAbout)}</p>\n<p>${esc(chrome.footerSource)} · <a href="/villkor">Köpvillkor</a></p>` : `<p><strong>Bidragskoll.se</strong> är en oberoende orienterings- och förberedelsetjänst — inte en myndighet.
Bedömningar är vägledande; beslut fattas alltid av den ansvariga myndigheten eller finansiären.
Att ansöka själv direkt hos källan är alltid gratis.</p>
<p>Källpolicy: varje stöd länkar till sin officiella källa och visar när uppgifterna senast kontrollerades.
Innehållet är AI-sammanställt från officiella källor och ännu inte granskat av människa — kontrollera alltid
aktuella villkor hos källan. · <a href="/villkor">Köpvillkor</a></p>`}
</footer>
</div>
</body>
</html>
`;
}

function baseGraph(canonical, title, crumbs, pageLang = 'sv') {
  return [
    {
      '@type': 'Organization', '@id': `${BASE}/#org`, name: ENTITY.name, legalName: ENTITY.legalName, url: `${BASE}/`,
      description: ENTITY.description.sv,
      // Endast verkliga, publikt synliga uppgifter (samma som köpvillkoren).
      identifier: { '@type': 'PropertyValue', propertyID: 'orgnr', value: ENTITY.orgNumber },
      address: { '@type': 'PostalAddress', streetAddress: ENTITY.address.streetAddress, postalCode: ENTITY.address.postalCode, addressLocality: ENTITY.address.addressLocality, addressCountry: ENTITY.address.addressCountry },
    },
    { '@type': 'WebSite', '@id': `${BASE}/#website`, url: `${BASE}/`, name: ENTITY.name, inLanguage: 'sv', description: ENTITY.description.sv, publisher: { '@id': `${BASE}/#org` } },
    // WebApplication med semantiskt SANN prismodell: upptäckt = 0 kr, förberedd
    // ansökan = separat pris. Aldrig "0 kr" på en funktion som senare kostar.
    {
      '@type': 'WebApplication', '@id': `${BASE}/#app`, name: ENTITY.name, url: `${BASE}/`,
      applicationCategory: 'BusinessApplication', operatingSystem: 'Web', inLanguage: 'sv',
      description: ENTITY.description.sv,
      audience: { '@type': 'Audience', audienceType: ENTITY.audiences.sv.join(', ') },
      offers: [
        { '@type': 'Offer', name: ENTITY.pricing.discovery.label.sv, price: '0', priceCurrency: ENTITY.pricing.discovery.currency, description: 'Upptäck relevanta bidrag och stöd och se länken till den officiella ansökan — utan att betala.' },
        { '@type': 'Offer', name: ENTITY.pricing.applicationPreparation.label.sv, price: String(ENTITY.pricing.applicationPreparation.priceMinor / 100), priceCurrency: ENTITY.pricing.applicationPreparation.currency, description: 'Valfritt: låt systemet förbereda en ansökan med alla dokument som behövs för den.' },
      ],
      publisher: { '@id': `${BASE}/#org` },
    },
    {
      '@type': 'BreadcrumbList',
      itemListElement: crumbs.map((c, i) => ({ '@type': 'ListItem', position: i + 1, name: c.name, item: `${BASE}${c.url}` })),
    },
    { '@type': 'WebPage', url: canonical, name: title, inLanguage: pageLang, dateModified: CHECKED, isPartOf: { '@id': `${BASE}/#website` } },
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

  // Answer Object (FAS SEO-2): kompakt, extraherbart snabbsvar som en sökmotor
  // eller AI-modell kan lyfta rakt av. Samma Q&A visas synligt OCH som FAQPage
  // (Google kräver att FAQ-svaren finns i den synliga texten). De två gratis-
  // frågorna gör affärsmodellen maskinläsbar på varje bidragssida.
  const kravText = krav.slice(0, 3).map((c) => c.description);
  const faq = [
    {
      q: `Kostar det att se om jag kan ha rätt till ${shortTitle(o).toLowerCase()}?`,
      a: `Nej. Att upptäcka stödet och se villkoren i Bidragskoll är gratis, och resultaten är inte låsta bakom en betalvägg. Du betalar bara om du väljer att låta systemet förbereda en ansökan (19 kr per ansökan).`,
    },
    {
      q: 'Kan jag ansöka själv?',
      a: `Ja. Den slutliga ansökan görs alltid hos ${auth?.name ?? 'den ansvariga aktören'}, och att ansöka själv är alltid gratis. Bidragskoll länkar till den officiella källan.`,
    },
    ...(kravText.length
      ? [{ q: `Vem kan få ${shortTitle(o).toLowerCase()}?`, a: `Det avgörs av ${auth?.name ?? 'den ansvariga aktören'}. De viktigaste villkoren enligt källan: ${kravText.join('; ')}.` }]
      : []),
  ];
  // Verkliga användarfrågor (uppmätt efterfrågan) — se PAA_BY_SLUG ovan.
  faq.push(...paaFaqFor(o.slug, o, auth?.name ?? 'den ansvariga aktören', faq));

  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, pageTitle(o), crumbs) };
  const webPageNode = jsonld['@graph'].find((n) => n['@type'] === 'WebPage');
  webPageNode.about = { '@type': 'Thing', name: short, sameAs: o.sourceUrl };
  jsonld['@graph'].push({
    '@type': 'FAQPage',
    mainEntity: faq.map((f) => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })),
  });

  const kluster = KLUSTER_BY_CHILD.get(o.slug);
  const body = `
<p class="eyebrow">${esc(auth?.name ?? '')} · ${esc(INSTRUMENT[o.instrumentType] ?? 'Stöd')}</p>
<h1>${esc(short)}</h1>
<p class="lead">${esc(o.summary)}</p>
${kluster ? `<p class="lead">Del av översikten <a href="/${kluster.path}/">${esc(kluster.h1)}</a> — jämför varianterna och se de vanligaste frågorna där.</p>` : ''}

<div class="card">
<table class="fakta">
<tr><th scope="row">Vem kan söka</th><td>${esc((o.applicantTypes ?? []).map((t) => APPLICANT[t] ?? t).map(cap).join(', '))}</td></tr>
<tr><th scope="row">Belopp</th><td>${esc(belopp)}</td></tr>
<tr><th scope="row">Deadline</th><td>${esc(deadlineText(o))}</td></tr>
<tr><th scope="row">Så ansöker du</th><td>${esc(o.applicationMethod ?? 'Se den officiella källan')}</td></tr>
<tr><th scope="row">Arbetsinsats</th><td>Cirka ${o.estimatedEffortDays} ${o.estimatedEffortDays === 1 ? 'arbetsdag' : 'arbetsdagar'} att förbereda</td></tr>
</table>
</div>

<div class="snabbsvar">
<h2>Snabbsvar</h2>
<dl>${faq.map((f) => `<dt>${esc(f.q)}</dt><dd>${esc(f.a)}</dd>`).join('')}</dl>
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
<div class="path"><strong>Låt Bidragskoll utreda din situation — gratis</strong>
Svara på några frågor så ser du vilka stöd som kan passa dig, varför, och hur du ansöker.
Upptäckten och resultaten är gratis och inte låsta. Vill du att systemet förbereder en
komplett ansökan åt dig kostar det 19 kr per ansökan.
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
function hubPage(hub, entries, queryLinks = []) {
  const canonical = `${BASE}/bidrag/${hub.slug}/`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: hub.short, url: `/bidrag/${hub.slug}/` }];
  // titleQuery: hubbar vars huvudterm har uppmätt sökspråk bär det i titeln
  // (verklig Semrush-data, se HUBS) — övriga behåller katalogtiteln.
  const title = `${hub.titleQuery ?? hub.title} | Bidragskoll`;
  const description = `${entries.length} stöd för ${hub.short.toLowerCase()} — villkor, belopp och ansökan, med källa och senast kontrollerad-datum för varje stöd.`;
  const byInstrument = new Map();
  for (const o of entries) {
    const key = INSTRUMENT[o.instrumentType] ?? 'Övriga stöd';
    if (!byInstrument.has(key)) byInstrument.set(key, []);
    byInstrument.get(key).push(o);
  }
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title, crumbs) };
  if (hub.faq?.length) jsonld['@graph'].push(faqJsonld(hub.faq));
  const body = `
<h1>${esc(hub.title)}</h1>
<p class="lead">${entries.length} stöd i Bidragskolls kunskapsbas riktar sig till ${esc(hub.short.toLowerCase())}.
${hub.leadQuery ? esc(hub.leadQuery) + '\n' : ''}Varje stöd visas med villkor, belopp och officiell källa. Osäker på vad som gäller dig?
<a href="/">Bidragskolls utredning</a> ställer frågorna åt dig — en i taget.</p>
${queryLinks.length ? `<h2>Vanliga sökningar</h2>
<ul class="stodlista">${queryLinks.map((q) => `<li><a href="${q.url}">${esc(q.label)}</a></li>`).join('')}</ul>` : ''}
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
${hub.faq?.length ? `<div class="snabbsvar"><h2>Vanliga frågor</h2>
<dl>${hub.faq.map((f) => `<dt>${esc(f.q)}</dt><dd>${esc(f.a)}</dd>`).join('')}</dl></div>` : ''}
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
  const alternates = hreflangTags() + '\n';
  const body = `
<h1>Bidrag och stöd i Sverige</h1>
<p class="lead">Bidragskoll samlar ${opportunities.length} bidrag, ersättningar och stöd från ${authorities.length}
myndigheter och finansiärer — med villkor, belopp, deadlines och länk till den officiella källan för varje stöd.
Myndigheterna beskriver sina egna stöd var för sig; här får du överblicken, och
<a href="/">utredningen</a> som visar vilka stöd som kan passa just din situation.</p>
<div class="paths">
<div class="path"><strong>Vilka bidrag kan jag få?</strong>Det beror på vem du är. Kontrollera gratis — du behöver inte veta vad bidraget heter.<br><a class="knapp" href="/vilka-bidrag-kan-jag-fa/">Kontrollera din situation</a></div>
<div class="path"><strong>Hitta bidrag gratis</strong>Upptäckten och resultaten är kostnadsfria och inte låsta. Ansök själv hos källan.<br><a class="knapp sekundar" href="/hitta-bidrag-gratis/">Så fungerar det</a></div>
</div>
<p class="lead" style="margin-top:.4rem">Se också <a href="/oppna-bidrag/">öppna bidrag just nu</a>, <a href="/bidragsstatus/">bidragsstatus</a>, <a href="/finansiarer/">finansiärerna</a> bakom bidragen, och <a href="/foretagsbidragsindex/">Företagsbidragsindex</a> — Sveriges företagsstöd i öppna, citerbara siffror.</p>
<p class="lead">Ämnesöversikter: ${KLUSTER.map((k) => `<a href="/${k.path}/">${esc(k.h1)}</a>`).join(' · ')}.</p>
${langPickerHtml()}
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
  return layout({ title, description, canonical, crumbs, jsonld, body, alternates });
}

// ── Flaggskeppssidor (FAS SEO-2): svar → åtgärd → stödinformation ────────────
// Rota, inte /bidrag/-nästlade: detta är huvudintentionerna ("hitta bidrag
// gratis", "vilka bidrag kan jag få") och förtjänar korta auktoritets-URL:er.
const AUDIENCE_PICKER = [
  { label: 'Jag är privatperson', desc: 'Bostadsbidrag, försörjningsstöd, studiestöd, ersättningar och mer.', hub: 'privatpersoner' },
  { label: 'Jag driver företag', desc: 'Stöd för att anställa, investera, digitalisera, exportera och växa.', hub: 'foretag' },
  { label: 'Jag har enskild firma', desc: 'Dubbel kontroll — både ditt företagande och din privata situation.', hub: 'foretag' },
  { label: 'Jag representerar en förening', desc: 'Verksamhetsbidrag, projektstöd och stöd till civilsamhället.', hub: 'foreningar' },
];

function faqJsonld(pairs) {
  return { '@type': 'FAQPage', mainEntity: pairs.map((f) => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })) };
}
function audiencePickerHtml() {
  return `<div class="paths">${AUDIENCE_PICKER.map((a) => `<div class="path"><strong>${esc(a.label)}</strong>${esc(a.desc)}
<a class="knapp" href="/">Kontrollera gratis</a> <a class="knapp sekundar" href="/bidrag/${a.hub}/">Bläddra stöden</a></div>`).join('')}</div>`;
}

function flagshipHittaGratis() {
  const path = '/hitta-bidrag-gratis/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Hitta bidrag gratis', url: path }];
  const title = 'Hitta bidrag gratis – se vad du kan få | Bidragskoll';
  const description = 'Det kostar inget att se vilka bidrag och stöd som kan vara relevanta för dig. Resultaten är inte låsta, och du kan alltid ansöka själv hos den officiella källan.';
  const faq = [
    { q: 'Kostar det något att hitta bidrag i Bidragskoll?', a: 'Nej. Att beskriva din situation och se vilka stöd som kan vara relevanta är gratis, och resultaten är inte låsta bakom en betalvägg.' },
    { q: 'Vad kostar då pengar?', a: 'Bara valfria verktyg: att låta systemet förbereda en komplett ansökan kostar 19 kr per ansökan. Bevakning och administration är valfria tillägg. Att ansöka själv hos myndigheten är alltid gratis.' },
    { q: 'Måste jag veta vilket bidrag jag söker?', a: 'Nej. Du berättar om din situation — Bidragskoll hittar de stöd som kan passa, även sådana du inte kände till.' },
    { q: 'Är Bidragskoll en myndighet?', a: 'Nej. Bidragskoll är en oberoende tjänst och fattar inga beslut. Beslut fattas alltid av den ansvariga myndigheten eller finansiären.' },
  ];
  const jsonld = { '@context': 'https://schema.org', '@graph': [...baseGraph(canonical, title, crumbs), faqJsonld(faq)] };
  const body = `
<p class="eyebrow">Gratis kontroll</p>
<h1>Hitta bidrag gratis</h1>
<p class="lead">Det kostar inget att kontrollera vilka bidrag och stöd som kan vara relevanta för dig i Bidragskoll.
Du ser möjligheterna och kan gå vidare till den officiella ansökan själv. Du betalar bara om du väljer att
använda verktygen för bevakning, administration eller hjälp att förbereda ansökan.</p>
<a class="bigcta" href="/">Kontrollera mina bidrag</a>

<h2>Så funkar det</h2>
<ol class="steps">
<li><strong>Berätta vem du är.</strong> Person eller verksamhet — en fråga i taget, inget formulär.</li>
<li><strong>Se möjliga stöd.</strong> Vi jämför dina uppgifter med aktuella villkor och visar vad som kan passa, och varför.</li>
<li><strong>Välj själv.</strong> Ansök kostnadsfritt själv hos källan, eller använd våra verktyg om du vill ha hjälp.</li>
</ol>

<div class="snabbsvar"><h2>Vanliga frågor</h2>
<dl>${faq.map((f) => `<dt>${esc(f.q)}</dt><dd>${esc(f.a)}</dd>`).join('')}</dl></div>

<h2>Vem gäller det?</h2>
${audiencePickerHtml()}

<div class="honest">Bidragskoll är en oberoende tjänst — inte en myndighet. Bedömningar är vägledande; beslut
fattas alltid av ansvarig myndighet eller finansiär. Innehållet är AI-sammanställt från officiella källor och
ännu inte granskat av människa.</div>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED} · Se hela katalogen på <a href="/bidrag/">alla bidrag och stöd</a>.</p>
`;
  return { path, html: layout({ title, description, canonical, crumbs, jsonld, body }) };
}

function flagshipVilkaBidrag() {
  const path = '/vilka-bidrag-kan-jag-fa/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Vilka bidrag kan jag få?', url: path }];
  const title = 'Vilka bidrag kan jag få? Kontrollera gratis | Bidragskoll';
  const description = 'Vilka bidrag du kan få beror på vem du är och din situation. Kontrollera det gratis — du behöver inte veta vad bidraget heter. Resultaten är inte låsta.';
  const faq = [
    { q: 'Hur vet jag vilka bidrag jag kan få?', a: 'Du behöver inte veta det på förhand. Berätta om din situation, så jämför Bidragskoll den med aktuella villkor och visar vilka stöd som kan vara relevanta.' },
    { q: 'Kostar det att kontrollera?', a: 'Nej. Upptäckten och resultaten är gratis och inte låsta. Du kan gå vidare och ansöka själv hos den officiella källan utan att betala.' },
    { q: 'Gäller det även företag och föreningar?', a: 'Ja. Bidragskoll är för privatpersoner, företag, enskilda näringsidkare och föreningar.' },
    { q: 'Fattar Bidragskoll beslut om bidrag?', a: 'Nej. Bidragskoll är inte en myndighet. Bedömningen är vägledande; beslutet fattas alltid av den ansvariga myndigheten eller finansiären.' },
  ];
  const jsonld = { '@context': 'https://schema.org', '@graph': [...baseGraph(canonical, title, crumbs), faqJsonld(faq)] };
  const body = `
<p class="eyebrow">Kontrollera din situation</p>
<h1>Vilka bidrag kan jag få?</h1>
<p class="lead">Det beror på vem du är och din situation — och du behöver inte känna till bidragets namn.
Kontrollera det gratis här nedan. Upptäckten och resultaten är kostnadsfria och inte låsta bakom en betalvägg,
och du kan alltid ansöka själv hos den officiella källan.</p>

<h2>Välj din utgångspunkt</h2>
${audiencePickerHtml()}

<h2>Så funkar det</h2>
<ol class="steps">
<li><strong>Berätta om din situation.</strong> En fråga i taget — inget formulär, inget personnummer.</li>
<li><strong>Se vilka stöd som kan passa.</strong> Med villkor, belopp och officiell källa för varje stöd.</li>
<li><strong>Ansök själv — eller ta hjälp.</strong> Länken till den officiella ansökan är alltid gratis.</li>
</ol>

<div class="snabbsvar"><h2>Vanliga frågor</h2>
<dl>${faq.map((f) => `<dt>${esc(f.q)}</dt><dd>${esc(f.a)}</dd>`).join('')}</dl></div>

<div class="honest">Bidragskoll är en oberoende orienteringstjänst — inte en myndighet. Innehållet är
AI-sammanställt från officiella källor och ännu inte granskat av människa; kontrollera alltid aktuella
villkor hos källan.</div>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED} · Se även <a href="/hitta-bidrag-gratis/">hitta bidrag gratis</a> och <a href="/bidrag/">hela katalogen</a>.</p>
`;
  return { path, html: layout({ title, description, canonical, crumbs, jsonld, body }) };
}

// ── Query Pages (SEO-3/§4): vyer över grafen, "own the answer" ───────────────
// applicant_type → målgruppshubb, för internlänkning tillbaka in i katalogen.
const HUB_FOR_APPLICANT = { individual: 'privatpersoner', company: 'foretag', association: 'foreningar' };

function queryPage(intent, supports, verdict) {
  const path = intent.canonical_url; // t.ex. /foretag/energistod/
  const canonical = `${BASE}${path}`;
  const hubSlug = HUB_FOR_APPLICANT[intent.applicant_type] ?? 'privatpersoner';
  const hub = HUBS.find((h) => h.slug === hubSlug) ?? HUBS[0];
  const crumbs = [
    { name: 'Bidrag', url: '/bidrag/' },
    { name: hub.short, url: `/bidrag/${hub.slug}/` },
    { name: intent.title_q, url: path },
  ];
  const noindex = verdict.verdict === 'NOINDEX_FOLLOW' || verdict.verdict === 'CANONICAL_TO_PARENT';
  const title = `${intent.title_q} | Bidragskoll`.slice(0, 70);
  const description = `${intent.answer} Kontrollera gratis vilka som passar — resultaten är inte låsta.`.slice(0, 168);
  const sorted = [...supports].sort((a, b) => shortTitle(a).localeCompare(shortTitle(b), 'sv'));
  const faq = [
    { q: intent.canonical_query.charAt(0).toUpperCase() + intent.canonical_query.slice(1) + '?', a: `${intent.answer} Kontrollen i Bidragskoll är gratis och resultaten är inte låsta — du kan alltid ansöka själv hos den officiella källan.` },
    { q: 'Kostar det att kontrollera?', a: 'Nej. Att se vilka stöd som kan passa är gratis. Du betalar bara om du väljer att låta systemet förbereda en ansökan (19 kr per ansökan).' },
    { q: 'Måste jag veta vilket stöd jag söker?', a: 'Nej. Du behöver inte känna till stödets namn — beskriv din situation, så visar Bidragskoll vad som kan passa.' },
  ];
  const jsonld = { '@context': 'https://schema.org', '@graph': [...baseGraph(canonical, title, crumbs), faqJsonld(faq)] };

  const dataView = sorted.length
    ? `<ul class="stodlista">${sorted.map((o) => `<li><a href="/bidrag/${o.slug}/">${esc(anchorTitle(o))}</a><span class="sum">${esc(o.summary)} <em>· ${esc(deadlineText(o))}</em></span></li>`).join('')}</ul>`
    : '<p>Inga aktuella stöd för den här kombinationen i kunskapsbasen just nu.</p>';

  const body = `
<p class="eyebrow">${esc(intent.audience_label)}</p>
<h1>${esc(intent.title_q)}</h1>
<p class="lead">${esc(intent.answer)}</p>
<a class="bigcta" href="/">Kontrollera vilka som passar dig — gratis</a>

<h2>Stöd som kan vara aktuella (${sorted.length})</h2>
<p>Listan bygger på Bidragskolls kunskapsbas och uppdateras när stöden ändras — varje stöd har officiell källa och senast kontrollerad-datum.</p>
${dataView}

<div class="snabbsvar"><h2>Vanliga frågor</h2>
<dl>${faq.map((f) => `<dt>${esc(f.q)}</dt><dd>${esc(f.a)}</dd>`).join('')}</dl></div>

<div class="honest">Bidragskoll är en oberoende tjänst — inte en myndighet. Bedömningar är vägledande; beslut fattas
alltid av ansvarig myndighet eller finansiär. Innehållet är AI-sammanställt från officiella källor och ännu inte
granskat av människa. Att ansöka själv direkt hos källan är alltid gratis.</div>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED} · Se alla stöd för ${esc(hub.short.toLowerCase())} på <a href="/bidrag/${hub.slug}/">${esc(hub.short.toLowerCase())}-hubben</a>.</p>
`;
  let html = layout({ title, description, canonical, crumbs, jsonld, body });
  if (noindex) html = html.replace('</title>', '</title>\n<meta name="robots" content="noindex,follow">');
  return { path, html, noindex };
}

// ── Öppna bidrag (TIME-intent, SERP War Room 2026-08-28) ─────────────────────
// Sökintentionen "öppna bidrag / bidrag att söka just nu" saknar en samlad,
// myndighetsövergripande vy — myndigheterna listar bara sina egna stöd. Sidan
// beräknas helt ur kunskapsbasens deadlinemodell (rolling/recurring/closesAt):
// äkta information gain, inga påhittade datum. "Nya bidrag" byggs MEDVETET
// inte förrän kunskapsbasen ärligt kan spåra nyhet (se docs/SEO_WAR_ROOM.md).
function oppnaBidragPage() {
  const path = '/oppna-bidrag/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Öppna bidrag', url: path }];
  const title = 'Öppna bidrag – löpande stöd och kommande deadlines | Bidragskoll';
  const rolling = opportunities.filter((o) => o.deadlineModel === 'rolling').sort((a, b) => shortTitle(a).localeCompare(shortTitle(b), 'sv'));
  const closingSoon = opportunities.filter((o) => o.closesAt && o.closesAt.slice(0, 10) >= CHECKED).sort((a, b) => a.closesAt.localeCompare(b.closesAt));
  const recurring = opportunities.filter((o) => o.deadlineModel === 'recurring' || o.deadlineModel === 'upcoming_round').sort((a, b) => shortTitle(a).localeCompare(shortTitle(b), 'sv'));
  const description = `${rolling.length} stöd är löpande öppna utan fast deadline och ${recurring.length} öppnar i omgångar — samlade över myndighetsgränserna, med källa och senast kontrollerad-datum.`.slice(0, 168);
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title.slice(0, 70), crumbs) };
  const li = (o, extra = '') => `<li><a href="/bidrag/${o.slug}/">${esc(anchorTitle(o))}</a><span class="sum">${esc(o.summary)}${extra}</span></li>`;
  const body = `
<p class="eyebrow">Levande datavy</p>
<h1>Öppna bidrag just nu</h1>
<p class="lead">Vilka bidrag går att söka just nu? ${rolling.length} av de ${opportunities.length} stöden i
Bidragskolls kunskapsbas är löpande öppna — de har ingen fast deadline utan kan sökas när som helst.
Ytterligare ${recurring.length} öppnar i omgångar hos sina finansiärer. Öppettider ändras hos källan;
varje stöd visar sin officiella källa och när uppgifterna senast kontrollerades.</p>
<p><a class="bigcta" href="/">Kontrollera vilka som passar dig — gratis</a></p>
${closingSoon.length ? `<h2>Stänger snart — satta deadlines i kunskapsbasen</h2>
<ul class="stodlista">${closingSoon.map((o) => li(o, ` <em>· ${esc(deadlineText(o))}</em>`)).join('')}</ul>` : ''}
<h2>Löpande öppna stöd (${rolling.length})</h2>
<p>Stöd utan fast ansökningsdeadline — de söks när behovet uppstår, direkt hos den officiella källan.</p>
<ul class="stodlista">${rolling.map((o) => li(o)).join('')}</ul>
<h2>Öppnar i omgångar (${recurring.length})</h2>
<p>Stöd som öppnar och stänger i återkommande utlysningsomgångar — aktuella omgångstider finns hos respektive finansiär.</p>
<ul class="stodlista">${recurring.map((o) => li(o, ` <em>· ${esc(deadlineText(o))}</em>`)).join('')}</ul>
<div class="honest">Detta är en överblick ur Bidragskolls kunskapsbas, inte en realtidskälla. Ett stöds
öppet/stängt-status avgörs alltid hos den officiella källan, som varje bidragssida länkar till.
Innehållet är AI-sammanställt från officiella källor och ännu inte granskat av människa.</div>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED} · Se även <a href="/bidragsstatus/">bidragsstatus</a> — kunskapsbasens samlade siffror.</p>
`;
  return { path, html: layout({ title: title.slice(0, 70), description, canonical, crumbs, jsonld, body }) };
}

// ── Bidragsstatus (SEO-3/§12): citerbar datavy, beräknad ur seeden ───────────
function bidragsstatusPage() {
  const path = '/bidragsstatus/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Bidragsstatus', url: path }];
  const title = 'Bidragsstatus – öppna stöd, deadlines och nya möjligheter | Bidragskoll';
  const description = `Aktuell status för ${opportunities.length} bidrag och stöd: hur många som är löpande öppna, återkommande och har satt deadline — per målgrupp. Uppdaterad ur kunskapsbasen.`.slice(0, 168);
  const rolling = opportunities.filter((o) => o.deadlineModel === 'rolling');
  const recurring = opportunities.filter((o) => o.deadlineModel === 'recurring');
  const dated = opportunities.filter((o) => o.closesAt);
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title.slice(0, 70), crumbs) };
  const perHub = HUBS.map((h) => ({ h, n: opportunities.filter((o) => (o.applicantTypes ?? []).some((t) => h.types.includes(t))).length }));
  const body = `
<p class="eyebrow">Levande datavy</p>
<h1>Bidragsstatus</h1>
<p class="lead">Aktuell överblick över de ${opportunities.length} bidrag och stöd som finns i Bidragskolls kunskapsbas,
från ${authorities.length} myndigheter och finansiärer. Siffrorna beräknas direkt ur kunskapsbasen. Öppettider
och deadlines ändras hos källan — kontrollera alltid det aktuella hos respektive finansiär.</p>
<div class="card"><table class="fakta">
<tr><th scope="row">Löpande öppna (ingen fast deadline)</th><td>${rolling.length} stöd</td></tr>
<tr><th scope="row">Återkommande (öppnar i omgångar)</th><td>${recurring.length} stöd</td></tr>
<tr><th scope="row">Med satt datum i kunskapsbasen</th><td>${dated.length} stöd</td></tr>
<tr><th scope="row">Totalt i kunskapsbasen</th><td>${opportunities.length} stöd</td></tr>
</table></div>
<h2>Per målgrupp</h2>
<ul class="stodlista">${perHub.map(({ h, n }) => `<li><a href="/bidrag/${h.slug}/">${esc(h.title)}</a><span class="sum">${n} stöd</span></li>`).join('')}</ul>
${dated.filter((o) => o.closesAt.slice(0, 10) >= CHECKED).length ? `<h2>Närmast satta deadlines</h2>
<ul class="stodlista">${dated
    .filter((o) => o.closesAt.slice(0, 10) >= CHECKED)
    .sort((a, b) => a.closesAt.localeCompare(b.closesAt))
    .map((o) => `<li><a href="/bidrag/${o.slug}/">${esc(anchorTitle(o))}</a><span class="sum">${esc(deadlineText(o))}</span></li>`)
    .join('')}</ul>` : ''}
<div class="honest">Detta är en överblick ur kunskapsbasen, inte en realtidskälla. Enskilda stöds öppet/stängt-status
avgörs alltid hos den officiella källan, som varje bidragssida länkar till.</div>
<p class="kalla"><strong>Senast uppdaterad ur kunskapsbasen:</strong> ${CHECKED} · Se <a href="/oppna-bidrag/">öppna bidrag just nu</a> · <a href="/vilka-bidrag-kan-jag-fa/">Kontrollera din situation</a></p>
`;
  return { path, html: layout({ title: title.slice(0, 70), description, canonical, crumbs, jsonld, body }) };
}

// ── Företagsbidragsindex: verklig beräknad datavy + metodik ──────────────────
// Ärlighet framför siffror: bara reproducerbara metrics ur seeden; resten
// redovisas som "uppgift saknas" med skäl. Samma sanningslager driver sidan.
const FBI = computeFundingIndex(opportunities, authorities, CURATED_AT);
const FBI_REGISTRY = JSON.parse(readFileSync(join(ROOT, 'seo', 'foretagsbidragsindex-metrics.json'), 'utf8'));

// ── Verkliga användarfrågor (PAA) på entity-sidorna ──────────────────────────
// Källa: seo/volumes-semrush-se.json (Semrush phrase_questions, db=se) — de
// faktiska formuleringar människor söker på. Svaren syntetiseras DETERMINISTISKT
// ur seeden (summary/villkor/ansökningsväg); belopp och tider som inte är
// fastställda mot källan besvaras ärligt med hänvisning — aldrig en påhittad
// siffra. Frågesetten fästs bara på entydiga entity-sidor; huvudtermen
// 'bostadsbidrag' ägs av kommande klusterhubb (SEO_OPPORTUNITIES §3) och
// fästs medvetet inte på någon av de två specifika bostadsbidragssidorna.
const PAA_QUESTIONS = JSON.parse(readFileSync(join(ROOT, 'seo', 'volumes-semrush-se.json'), 'utf8')).questions ?? {};
// Huvudtermernas frågeset ägs av klusterhubbarna (seo/kluster.json) — här
// ligger bara set vars term entydigt ägs av EN entity-sida.
const PAA_BY_SLUG = {
  'pm-bostadstillagg': ['bostadstillägg'],
  'fk-underhallsstod': ['underhållsstöd'],
  'fk-aktivitetsstod': ['aktivitetsstöd'],
};
// Kurerade extra-frågor (sanna, allmänt kända förhållanden — inte statistik).
const PAA_EXTRA = {};

// ── Klusterhubbar: hubben äger huvudtermen, entity-sidorna det specifika ─────
const KLUSTER = JSON.parse(readFileSync(join(ROOT, 'seo', 'kluster.json'), 'utf8')).kluster;
const KLUSTER_BY_CHILD = new Map();
for (const k of KLUSTER) for (const s of k.childSlugs) KLUSTER_BY_CHILD.set(s, k);

/** Ärligt svar på en verklig användarfråga, härlett ur seeden — aldrig påhittade nivåer. */
function paaAnswer(q, o, authName) {
  const lq = q.toLowerCase();
  if (/^vad (är|betyder)/.test(lq)) {
    return `${o.summary} De fullständiga villkoren finns hos ${authName}.`;
  }
  if (/hur (söker|ansöker|anmäler)/.test(lq)) {
    return `${o.applicationMethod ?? 'Se den officiella källan.'} Att ansöka själv är alltid gratis — Bidragskoll länkar till den officiella källan.`;
  }
  if (/hur mycket|hur högt|hur höga|belopp|kapital|hur räknas/.test(lq)) {
    return `Beloppet fastställs av ${authName} och beror på din situation. Bidragskoll anger inga nivåer som inte är fastställda mot källan — aktuella belopp finns hos den officiella källan, och den kostnadsfria genomgången ställer följdfrågorna som påverkar just din nivå.`;
  }
  if (/när (får|kommer|betalas|kan man)|hur lång tid|hur länge|betalas .* ut/.test(lq)) {
    return `Tider och perioder styrs av ${authName} och kan variera — se den officiella källan för aktuella handläggnings- och utbetalningstider.`;
  }
  return `Det avgörs av villkoren hos ${authName} — se den officiella källan. Bidragskolls kostnadsfria genomgång ställer följdfrågorna som avgör hur det ser ut i just din situation.`;
}

/** Svarskategori — används för att inte upprepa samma mallsvar på flera frågevarianter. */
function paaCategory(lq) {
  if (/^vad (är|betyder)/.test(lq)) return 'vad';
  if (/hur (söker|ansöker|anmäler)/.test(lq)) return 'ansok';
  if (/hur mycket|hur högt|hur höga|belopp|kapital|hur räknas/.test(lq)) return 'belopp';
  if (/när (får|kommer|betalas|kan man)|hur lång tid|hur länge|betalas .* ut/.test(lq)) return 'tid';
  return 'ovrigt';
}

/**
 * PAA-frågorna för en entity-sida: dedupe mot standard-FAQ:n OCH per
 * svarskategori (högst en fråga per mallsvar — den med störst volym vinner,
 * listorna är volymsorterade). Aldrig fler än 5 utöver de kurerade extra.
 */
function paaFaqFor(slug, o, authName, existing) {
  const terms = PAA_BY_SLUG[slug] ?? [];
  const seen = new Set(existing.map((f) => f.q.toLowerCase().replace(/[^a-zåäö0-9 ]/g, '').trim()));
  const usedCats = new Set();
  const out = [...(PAA_EXTRA[slug] ?? [])];
  for (const term of terms) {
    for (const item of PAA_QUESTIONS[term] ?? []) {
      const lq = item.question.toLowerCase();
      // Vem-kan-få-varianter täcks redan av standardfrågan "Vem kan få X?".
      if (/^(vem (kan få|får|har rätt)|vad krävs)/.test(lq)) continue;
      const cat = paaCategory(lq);
      if (usedCats.has(cat)) continue;
      const key = lq.replace(/[^a-zåäö0-9 ]/g, '').trim();
      if (seen.has(key)) continue;
      seen.add(key);
      usedCats.add(cat);
      out.push({ q: item.question.charAt(0).toUpperCase() + item.question.slice(1) + '?', a: paaAnswer(item.question, o, authName) });
      if (out.length >= 5 + (PAA_EXTRA[slug]?.length ?? 0)) return out;
    }
  }
  return out;
}

function foretagsindexPage() {
  const path = '/foretagsbidragsindex/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Företagsbidragsindex', url: path }];
  const title = 'Företagsbidragsindex Sverige – öppna företagsstöd i siffror | Bidragskoll';
  const description = `Sveriges företagsstöd i siffror ur Bidragskolls kunskapsbas: ${FBI.metrics.openCompanyGrants.value} öppna företagsstöd, per finansieringsområde, finansiär och stödtyp. Öppna, reproducerbara data — inga påhittade siffror.`.slice(0, 168);
  const vf = FBI.metrics.verifiedAvailableFunding;
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title.slice(0, 70), crumbs) };
  jsonld['@graph'].push({
    '@type': 'Dataset', name: 'Företagsbidragsindex Sverige', inLanguage: 'sv',
    description: 'Aggregerad, reproducerbar statistik över företagsstöd i Sverige ur Bidragskolls kunskapsbas: antal öppna stöd, per finansieringsområde, finansiär och stödtyp.',
    creator: { '@id': `${BASE}/#org` }, isAccessibleForFree: true, dateModified: CHECKED,
    url: canonical, license: 'https://creativecommons.org/licenses/by/4.0/',
  });
  const dimList = (arr, labelFn = (k) => k) => `<ul class="stodlista">${arr.slice(0, 12).map((d) => `<li><span>${esc(labelFn(d.key))}</span><span class="sum">${d.count} stöd</span></li>`).join('')}</ul>`;
  const SECTOR_SV = { culture: 'Kultur', innovation: 'Innovation', technology: 'Teknik', energy: 'Energi', environment: 'Miljö/klimat', education: 'Utbildning', agriculture: 'Jordbruk', civil_society: 'Civilsamhälle', rural: 'Landsbygd', youth: 'Ungdom', sports: 'Idrott', research: 'Forskning' };
  const INSTR_SV = { public_grant: 'Statligt bidrag', eu_grant: 'EU-stöd', project_grant: 'Projektbidrag', loan: 'Lån', travel_grant: 'Resebidrag', stipend: 'Stipendium' };
  const body = `
<p class="eyebrow">Öppna data · uppdaterad ur kunskapsbasen</p>
<h1>Företagsbidragsindex Sverige</h1>
<p class="lead">Sveriges företagsstöd i siffror — beräknat direkt ur Bidragskolls kunskapsbas och fritt att citera.
Vi publicerar bara siffror som går att reproducera ur verifierade källor. Där uppgift saknas säger vi det, i
stället för att gissa.</p>
<div class="card"><table class="fakta">
<tr><th scope="row">Öppna företagsstöd</th><td>${FBI.metrics.openCompanyGrants.value}</td></tr>
<tr><th scope="row">Öppnar snart (känt datum/omgång)</th><td>${FBI.metrics.upcomingCompanyGrants.value}</td></tr>
<tr><th scope="row">Med satt deadline</th><td>${FBI.metrics.grantsWithDeadlineDate.value} <span style="color:var(--soft)">(övriga är löpande/återkommande)</span></td></tr>
<tr><th scope="row">Verifierad tillgänglig finansiering</th><td>Maxbelopp känt för ${vf.knownCount} av ${vf.totalCount} stöd (${vf.coveragePct} % täckning). Summa av kända maxbelopp: ${kr(vf.sumKnownMinor)}. <strong>Resten: uppgift saknas.</strong></td></tr>
</table></div>
<a class="bigcta" href="/">Kontrollera vilka stöd som passar ditt företag — gratis</a>

<h2>Per finansieringsområde</h2>
${dimList(FBI.dimensions.bySector, (k) => SECTOR_SV[k] ?? cap(k))}
<h2>Per finansiär</h2>
${dimList(FBI.dimensions.byProvider)}
<h2>Per stödtyp</h2>
${dimList(FBI.dimensions.byInstrument, (k) => INSTR_SV[k] ?? cap(k))}

<h2>Vad vi ännu inte mäter — och varför</h2>
<p>För att aldrig publicera påhittad statistik redovisar vi öppet vilka mått som ännu saknar reproducerbar data:</p>
<ul>${FBI.unavailable.map((u) => `<li><strong>${esc(u.metric)}:</strong> ${esc(u.reason)}</li>`).join('')}</ul>

<div class="honest">Företagsbidragsindex speglar Bidragskolls kunskapsbas (kurerad, ännu inte hela marknaden) och är
inte en myndighetsstatistik. Varje siffra kan reproduceras ur samma data. Historik börjar samlas löpande.</div>
<p class="kalla"><strong>Senast uppdaterad ur kunskapsbasen:</strong> ${CHECKED} · Metodikversion ${FBI.methodologyVersion} · <a href="/foretagsbidragsindex/metodik/">Metodik och definitioner</a> · Källa: Företagsbidragsindex, Bidragskoll.se</p>
`;
  return { path, html: layout({ title: title.slice(0, 70), description, canonical, crumbs, jsonld, body }) };
}

function foretagsindexMetodikPage() {
  const path = '/foretagsbidragsindex/metodik/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Företagsbidragsindex', url: '/foretagsbidragsindex/' }, { name: 'Metodik', url: path }];
  const title = 'Företagsbidragsindex – metodik och definitioner | Bidragskoll';
  const description = 'Så beräknas Företagsbidragsindex: varje måtts definition, formel, datakälla och kända begränsningar. Mått utan reproducerbar data publiceras inte — de redovisas öppet.';
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title.slice(0, 70), crumbs) };
  const pub = FBI_REGISTRY.metrics.filter((m) => m.public);
  const priv = FBI_REGISTRY.metrics.filter((m) => !m.public);
  const body = `
<p class="eyebrow">Metodik</p>
<h1>Företagsbidragsindex — metodik och definitioner</h1>
<p class="lead">Varje mått har en definition, en formel, en datakälla och kända begränsningar. Samma beräkning driver
den publika sidan och (framtida) API — ingen kanal skapar sin egen version av fakta. Baslinje: ${esc(FBI_REGISTRY.baseline)}</p>
<h2>Publicerade mått</h2>
${pub.map((m) => `<div class="card"><h2 style="margin-top:0;font-size:1.1rem">${esc(m.name)}</h2>
<p>${esc(m.description ?? '')}</p>
<table class="fakta">
${m.formula ? `<tr><th scope="row">Formel</th><td><code>${esc(m.formula)}</code></td></tr>` : ''}
<tr><th scope="row">Enhet</th><td>${esc(m.unit)}</td></tr>
<tr><th scope="row">Datakvalitet</th><td>${esc(m.quality)}</td></tr>
<tr><th scope="row">Begränsningar</th><td>${esc(m.limitations ?? '—')}</td></tr>
</table></div>`).join('')}
<h2>Mått som ännu inte publiceras (kräver data)</h2>
<p>Följande mått beräknas inte förrän det finns reproducerbar data — vi visar aldrig en gissad siffra:</p>
<ul>${priv.map((m) => `<li><strong>${esc(m.name)}:</strong> ${esc(m.requiresData ?? '')}</li>`).join('')}</ul>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED} · Tillbaka till <a href="/foretagsbidragsindex/">Företagsbidragsindex</a></p>
`;
  return { path, html: layout({ title, description, canonical, crumbs, jsonld, body }) };
}

// ── Finansiärssidor (SEO-063): entiteter i grafen, en sida per finansiär ─────
const KIND_LABEL = {
  state_agency: 'Statlig myndighet', municipality: 'Kommun', region: 'Region',
  foundation: 'Stiftelse', eu_body: 'EU-organ', ngo: 'Organisation', other: 'Finansiär',
};
function funderPage(auth, grants) {
  const path = `/finansiarer/${auth.key}/`;
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Finansiärer', url: '/finansiarer/' }, { name: auth.name, url: path }];
  const noindex = grants.length < 2; // tunn near-dubblett av den enda bidragssidan
  const title = `${auth.name} – stöd och bidrag | Bidragskoll`.slice(0, 70);
  const description = `${auth.name} finansierar ${grants.length} ${grants.length === 1 ? 'stöd' : 'stöd'} i Bidragskolls kunskapsbas. Se villkor, deadlines och officiell källa — och kontrollera gratis vad som kan passa dig.`.slice(0, 168);
  const sorted = [...grants].sort((a, b) => shortTitle(a).localeCompare(shortTitle(b), 'sv'));
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title, crumbs) };
  const wp = jsonld['@graph'].find((n) => n['@type'] === 'WebPage');
  wp.about = { '@type': 'GovernmentOrganization', name: auth.name, url: auth.website ?? undefined };
  const body = `
<p class="eyebrow">${esc(KIND_LABEL[auth.kind] ?? 'Finansiär')}</p>
<h1>${esc(auth.name)}</h1>
<p class="lead">${esc(auth.name)} finansierar ${grants.length} ${grants.length === 1 ? 'stöd' : 'stöd'} i Bidragskolls kunskapsbas.
Varje stöd visas med villkor, deadline och officiell källa. Osäker på vad som gäller dig?
<a href="/">Kontrollera din situation gratis</a>.</p>
<h2>Stöd från ${esc(auth.name)}</h2>
<ul class="stodlista">${sorted.map((o) => `<li><a href="/bidrag/${o.slug}/">${esc(anchorTitle(o))}</a><span class="sum">${esc(o.summary)} <em>· ${esc(deadlineText(o))}</em></span></li>`).join('')}</ul>
<div class="honest">Bidragskoll är en oberoende tjänst — inte ${esc(auth.name)} eller någon annan myndighet. Bedömningar är
vägledande; beslut fattas alltid av finansiären. Innehållet är AI-sammanställt från officiella källor.</div>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED}${auth.website ? ` · <strong>Officiell webbplats:</strong> <a href="${esc(auth.website)}" rel="noopener">${esc(auth.website)}</a>` : ''} · Se alla <a href="/finansiarer/">finansiärer</a>.</p>
`;
  let html = layout({ title, description, canonical, crumbs, jsonld, body });
  if (noindex) html = html.replace('</title>', '</title>\n<meta name="robots" content="noindex,follow">');
  return { path, html, noindex };
}
function funderIndexPage(funders) {
  const path = '/finansiarer/';
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: 'Bidrag', url: '/bidrag/' }, { name: 'Finansiärer', url: path }];
  const title = 'Finansiärer – myndigheter och finansiärer bakom bidragen | Bidragskoll';
  const description = `${funders.length} myndigheter, kommuner, regioner och stiftelser som finansierar bidrag och stöd — med aktuella utlysningar, deadlines och officiella källor.`.slice(0, 168);
  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, title.slice(0, 70), crumbs) };
  const sorted = [...funders].sort((a, b) => a.auth.name.localeCompare(b.auth.name, 'sv'));
  const body = `
<h1>Finansiärer bakom bidragen</h1>
<p class="lead">${funders.length} myndigheter, kommuner, regioner och stiftelser finansierar de stöd som finns i
Bidragskolls kunskapsbas. Här ser du vem som står bakom vad. Du behöver inte känna till finansiären för att hitta
rätt stöd — <a href="/vilka-bidrag-kan-jag-fa/">kontrollera din situation</a> så gör vi jobbet.</p>
<ul class="stodlista">${sorted.map(({ auth, grants }) => `<li><a href="/finansiarer/${auth.key}/">${esc(auth.name)}</a><span class="sum">${grants.length} ${grants.length === 1 ? 'stöd' : 'stöd'}${auth.kind && KIND_LABEL[auth.kind] ? ` · ${esc(KIND_LABEL[auth.kind])}` : ''}</span></li>`).join('')}</ul>
<p class="kalla"><strong>Senast kontrollerad:</strong> ${CHECKED}</p>
`;
  return { path, html: layout({ title: title.slice(0, 70), description, canonical, crumbs, jsonld, body }) };
}

// ── Bygg ─────────────────────────────────────────────────────────────────────
if (outFlag === -1) rmSync(OUT, { recursive: true, force: true });
mkdirSync(join(OUT, 'bidrag'), { recursive: true });

/**
 * Klusterhubb (SEO_OPPORTUNITIES §3): sidan som ÄGER huvudtermen. Doktrin-
 * ordningen svar → väljare → verktyg (CTA) → datavy → förklaring → FAQ → källor.
 * All löptext är kurerad i seo/kluster.json (sann mekanik, aldrig belopp);
 * datavyn hämtas ur seeden; FAQ:n bär huvudtermens verkliga PAA-frågor.
 */
function klusterPage(k) {
  const children = k.childSlugs.map((s) => opportunities.find((o) => o.slug === s)).filter(Boolean);
  const primary = children[0];
  const auth = authorities.find((a) => a.key === primary?.authorityKey);
  const authName = auth?.name ?? 'den ansvariga aktören';
  const canonical = `${BASE}/${k.path}/`;
  // Relativa crumb-URL:er — baseGraph/layout prefixar BASE själva (absoluta
  // här gav dubblerad bas i BreadcrumbList-markupen).
  const crumbs = [
    { name: 'Bidrag', url: '/bidrag/' },
    { name: k.h1, url: `/${k.path}/` },
  ];

  // FAQ: gratis-frågan + kurerade extra + huvudtermens PAA (en per svarskategori).
  const faq = [
    {
      q: `Kostar det att se om jag kan ha rätt till ${k.headTerm}?`,
      a: 'Nej. Att upptäcka stödet och se villkoren i Bidragskoll är gratis, och resultaten är inte låsta bakom en betalvägg. Du betalar bara om du väljer att låta systemet förbereda en ansökan (19 kr per ansökan).',
    },
    ...(k.extraFaq ?? []),
  ];
  const usedCats = new Set();
  for (const term of k.paaTerms ?? []) {
    for (const item of PAA_QUESTIONS[term] ?? []) {
      const lq = item.question.toLowerCase();
      const cat = paaCategory(lq);
      if (usedCats.has(cat)) continue;
      usedCats.add(cat);
      let a;
      if (cat === 'vad') a = k.svar.split('. ').slice(0, 2).join('. ') + '.';
      else if (cat === 'ansok') a = `${primary?.applicationMethod ?? 'Se den officiella källan.'} Att ansöka själv är alltid gratis — Bidragskoll länkar till den officiella källan.`;
      else if (cat === 'belopp') a = `Beloppet fastställs av ${authName} och beror på din situation. Bidragskoll anger inga nivåer som inte är fastställda mot källan — aktuella belopp finns hos den officiella källan, och den kostnadsfria genomgången ställer följdfrågorna som påverkar just din nivå.`;
      else if (cat === 'tid') a = `Tider och perioder styrs av ${authName} och kan variera — se den officiella källan för aktuella handläggnings- och utbetalningstider.`;
      else a = `Det avgörs av villkoren hos ${authName} — se den officiella källan. Bidragskolls kostnadsfria genomgång ställer följdfrågorna som avgör hur det ser ut i just din situation.`;
      faq.push({ q: item.question.charAt(0).toUpperCase() + item.question.slice(1) + '?', a });
      if (faq.length >= 7) break;
    }
    if (faq.length >= 7) break;
  }

  const jsonld = { '@context': 'https://schema.org', '@graph': [...baseGraph(canonical, k.title, crumbs), faqJsonld(faq)] };
  jsonld['@graph'].push({
    '@type': 'ItemList',
    name: k.h1,
    itemListElement: children.map((o, i) => ({ '@type': 'ListItem', position: i + 1, name: shortTitle(o), url: `${BASE}/bidrag/${o.slug}/` })),
  });

  const avgorareOpp = k.avgorare ? opportunities.find((o) => o.slug === k.avgorare.slug) : null;
  const body = `
<p class="eyebrow">Översikt · ${esc(authName)}</p>
<h1>${esc(k.h1)}</h1>
<p class="lead">${esc(k.svar)}</p>

<h2>Vilken variant gäller dig?</h2>
<div class="paths">
${children.map((o, i) => {
  const v = (k.valjare ?? [])[i];
  return `<div class="path"><strong>${esc(v?.fraga ?? shortTitle(o))}</strong>${esc(o.summary)}<br><a class="knapp" href="/bidrag/${o.slug}/">${esc(shortTitle(o))}</a></div>`;
}).join('\n')}
</div>
${avgorareOpp && k.avgorare ? `<p class="lead">${esc(k.avgorare.text)} <a href="/bidrag/${avgorareOpp.slug}/">${esc(shortTitle(avgorareOpp))}</a>.</p>` : ''}

<p><a class="bigcta" href="/">Kontrollera din situation — gratis</a></p>

<div class="card">
<table class="fakta">
${children.map((o) => `<tr><th scope="row"><a href="/bidrag/${o.slug}/">${esc(shortTitle(o))}</a></th><td>${esc(deadlineText(o))} · ${esc(o.applicationMethod ?? 'Se källan')}</td></tr>`).join('\n')}
</table>
</div>

<h2>Så fungerar det</h2>
<p>${esc(k.forklaring)}</p>

<div class="snabbsvar">
<h2>Vanliga frågor</h2>
<dl>${faq.map((f) => `<dt>${esc(f.q)}</dt><dd>${esc(f.a)}</dd>`).join('')}</dl>
</div>

<p class="kalla"><strong>Officiella källor:</strong> ${children.map((o) => `<a href="${esc(o.sourceUrl)}" rel="noopener">${esc(shortTitle(o))} hos ${esc(authorities.find((a) => a.key === o.authorityKey)?.name ?? 'källan')}</a>`).join(' · ')}.
<br><strong>Senast kontrollerad:</strong> ${CHECKED}</p>`;

  return layout({ title: `${k.title} | Bidragskoll`, description: k.description, canonical, crumbs, jsonld, body });
}


// ── I18N fas C: en (1) flerspråkig landningssida per språk ──────────────────
// Substantiell, inte en doorway: hela katalogen med officiella namn (aldrig
// översatta) + fas B:s översatta sammanfattningar, plus kurerad copy ur
// seo/publik-i18n.json. Detaljsidorna förblir svenska och sidan säger det.
function langLandingPage(loc) {
  const t = PUBLIK_I18N[loc.code];
  const kb = KB_TRANSLATIONS[loc.code] ?? {};
  const tr = (text) => kb[text] ?? text;
  const path = `/${loc.code}/bidrag/`;
  const canonical = `${BASE}${path}`;
  const crumbs = [{ name: t.crumbBidrag, url: path }];
  const fill = (str) => str.replace('{n}', String(opportunities.length)).replace('{m}', String(authorities.length));
  const hubLabel = { privatpersoner: t.hubPrivatpersoner, foretag: t.hubForetag, foreningar: t.hubForeningar, 'offentlig-sektor': t.hubOffentlig };

  const jsonld = { '@context': 'https://schema.org', '@graph': baseGraph(canonical, t.title, crumbs, loc.hreflang) };
  const sections = HUBS.map((hub) => {
    const entries = opportunities
      .filter((o) => (o.applicantTypes ?? []).some((x) => hub.types.includes(x)))
      .sort((a, b) => shortTitle(a).localeCompare(shortTitle(b), 'sv'));
    if (!entries.length) return '';
    return `<h3>${esc(hubLabel[hub.slug])} — ${esc(t.supportsCount.replace('{n}', String(entries.length)))}</h3>
<ul class="stodlista">${entries
      .map((o) => `<li><a href="/bidrag/${o.slug}/">${esc(anchorTitle(o))}</a><span class="sum">${esc(tr(o.summary))}</span></li>`)
      .join('')}</ul>`;
  }).join('\n');

  // Språkvalet är både navigering och en tydlig hreflang-signal för sökmotorn.
  const others = [
    `<li><a href="/bidrag/">Svenska</a></li>`,
    ...SEO_LOCALES.filter((l) => l.code !== loc.code).map((l) => `<li><a href="/${l.code}/bidrag/">${esc(l.native)}</a></li>`),
  ].join('');

  const body = `
<h1>${esc(t.h1)}</h1>
<p class="lead">${esc(fill(t.lead))}</p>
<div class="honest">${esc(t.aiTranslated)}</div>
<p><a class="bigcta" href="/?sprak=${loc.code}">${esc(t.cta)}</a></p>

<h2>${esc(t.howHeading)}</h2>
<p>${esc(t.howBody)}</p>

<h2>${esc(t.groupsHeading)}</h2>
<p>${esc(t.swedishDetails)} ${esc(t.officialNamesNote)}</p>
${sections}

<div class="honest">${esc(t.honest)}</div>

<h2>${esc(t.otherLanguages)}</h2>
<ul class="sprakval">${others}</ul>

<p class="kalla"><strong>${esc(t.lastChecked)}:</strong> ${CHECKED} · <a href="/bidrag/">${esc(t.toSwedishCatalogue)}</a></p>
`;
  return {
    path,
    html: layout({
      title: t.title, description: t.description, canonical, crumbs, jsonld, body,
      lang: loc.hreflang, dir: loc.dir, alternates: hreflangTags() + '\n',
      chrome: {
        appHref: `/?sprak=${loc.code}`, cta: t.cta, crumbLabel: t.crumbBidrag,
        footerAbout: t.footerAbout, footerSource: t.footerSource,
      },
    }),
  };
}

function langPickerHtml() {
  return `<p class="lead">Andra språk: ${SEO_LOCALES.map((l) => `<a href="/${l.code}/bidrag/">${esc(l.native)}</a>`).join(' · ')}.</p>`;
}

const pages = [];
const noindexPaths = new Set(); // genererade men EJ i sitemap (NOINDEX_FOLLOW)
function emit(path, html, opts = {}) {
  const dir = join(OUT, path);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, 'index.html'), html);
  const url = `/${path.replace(/\\/g, '/')}/`.replace(/\/+/g, '/');
  pages.push(url);
  if (opts.noindex) noindexPaths.add(url);
}

// ── Indexability-motorn: resolvera intentioner mot grafen, döm varje kandidat ─
const HUB_TYPES = { individual: ['individual'], company: ['company', 'economic_association'], association: ['association', 'informal_group'] };
const INTENTS = loadIntents(ROOT).map((intent) => {
  const supports = resolveIntent(intent, opportunities);
  const base = indexabilityVerdict(intent, supports);
  // §29 CANONICAL_TO_PARENT: om intentionen inte smalnar av sin målgruppshubb
  // (samma stöduppsättning) tillför den inget eget sökvärde. Realiseras som
  // noindex (samma effekt: inte ett självständigt sökresultat; länkar följs).
  const parentSupports = opportunities.filter((o) => (o.applicantTypes ?? []).some((t) => (HUB_TYPES[intent.applicant_type] ?? []).includes(t)));
  if (base.verdict === 'INDEX' && parentOverlapVerdict(supports, parentSupports)) {
    return { intent, supports, verdict: 'CANONICAL_TO_PARENT', count: supports.length, reasons: ['smalnar inte av målgruppshubben — inget eget sökvärde'], score: supports.length };
  }
  return { intent, supports, ...base };
});
// Query-länkar per hubb (INDEX + NOINDEX; DO_NOT_GENERATE länkas aldrig).
const queryLinksByHub = {};
for (const r of INTENTS) {
  if (r.verdict === 'DO_NOT_GENERATE') continue;
  const hubSlug = HUB_FOR_APPLICANT[r.intent.applicant_type] ?? 'privatpersoner';
  (queryLinksByHub[hubSlug] ??= []).push({ url: r.intent.canonical_url, label: r.intent.title_q });
}

const hubEntries = HUBS.map((hub) => ({
  hub,
  entries: opportunities.filter((o) => (o.applicantTypes ?? []).some((t) => hub.types.includes(t))),
})).filter(({ entries }) => entries.length >= 3);

emit('bidrag', indexPage(hubEntries));
for (const { hub, entries } of hubEntries) emit(join('bidrag', hub.slug), hubPage(hub, entries, queryLinksByHub[hub.slug] ?? []));
for (const o of [...opportunities].sort((a, b) => a.slug.localeCompare(b.slug))) emit(join('bidrag', o.slug), entityPage(o));

// I18N fas C: flerspråkiga landningssidor (en per språk).
for (const loc of SEO_LOCALES) {
  const p = langLandingPage(loc);
  emit(p.path.replace(/^\/|\/$/g, ''), p.html);
}

// Klusterhubbar — hubben äger huvudtermen (länkas från /bidrag/-index; barnen länkar upp).
for (const k of KLUSTER) emit(k.path, klusterPage(k));

// Flaggskeppssidorna + bidragsstatus (root). Länkas från /bidrag/-index så de
// nås i orphan-BFS:en, och länkar tillbaka in i katalogen.
for (const p of [flagshipHittaGratis(), flagshipVilkaBidrag(), bidragsstatusPage(), oppnaBidragPage(), foretagsindexPage(), foretagsindexMetodikPage()]) emit(p.path.replace(/^\/|\/$/g, ''), p.html);

// Query Pages (vyer över grafen). Endast INDEX + NOINDEX_FOLLOW genereras.
let idx = 0, noidx = 0, skipped = 0;
for (const r of INTENTS) {
  if (r.verdict === 'DO_NOT_GENERATE') { skipped++; continue; }
  const p = queryPage(r.intent, r.supports, r);
  emit(p.path.replace(/^\/|\/$/g, ''), p.html, { noindex: p.noindex });
  if (p.noindex) noidx++; else idx++;
}

// Finansiärssidor (SEO-063): grafentitet per finansiär. INDEX vid ≥2 stöd,
// annars NOINDEX_FOLLOW (tunn near-dubblett av den enda bidragssidan).
const funders = authorities
  .map((auth) => ({ auth, grants: opportunities.filter((o) => o.authorityKey === auth.key) }))
  .filter(({ grants }) => grants.length >= 1);
emit('finansiarer', funderIndexPage(funders).html);
let fIdx = 0, fNo = 0;
for (const { auth, grants } of funders) {
  const p = funderPage(auth, grants);
  emit(p.path.replace(/^\/|\/$/g, ''), p.html, { noindex: p.noindex });
  if (p.noindex) fNo++; else fIdx++;
}

// Sitemap + robots. NOINDEX_FOLLOW-sidor genereras men står UTANFÖR sitemapen.
const sitemapUrls = pages.filter((p) => !noindexPaths.has(p));
const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${sitemapUrls.map((p) => `  <url><loc>${BASE}${p}</loc><lastmod>${CHECKED}</lastmod></url>`).join('\n')}
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

console.log(`Genererade ${pages.length} publika sidor (query: ${idx} INDEX/${noidx} NOINDEX/${skipped} DO_NOT_GENERATE · finansiärer: ${fIdx} INDEX/${fNo} NOINDEX) + 404.html + sitemap.xml + robots.txt → ${OUT}`);
