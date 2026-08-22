# SEO RELEASE GATE — Bidragskoll.se

Ingen release av den publika ytan utan att gaten är grön. Gaten är
**deterministisk kod, inte checklista på papper**: den bor i
`npm run verify` (steg "Publika SEO-ytan…") och CI, och den FAILAR bygget.

## Vad gaten redan verifierar (kod, per sida × 77)

`tools/seocheck.mjs`:
- exakt en `<h1>`; `<title>` unik och ≤ 70 tecken; meta description unik ≤ 170
- canonical = sidans exakta URL; `lang="sv"`
- JSON-LD parsar och innehåller Organization + BreadcrumbList + WebPage
- **og:image, twitter:card, favicon-länk, theme-color** (Audit 01-tillägget)
- alla interna länkar pekar på existerande sidor; ingen orphan (BFS från
  huvudhubben); sitemap 1:1 mot genererade sidor (varken fler eller färre)
- **404.html** finns, är noindex, bär den hjälpsamma §40-texten och står
  utanför sitemapen
- robots.txt pekar på sitemapen

`tools/gate0.mjs --allow-content-red` (Zero-Compromise Gate, samma
verify-steg): dubblett-H1, tomma sidor, icke-kanoniska interna länkformer,
parameterbloat, bildinventering, orphans/djup/ankare via länkgrafen.
`tools/gatekeywords.mjs --check`: 332-rotregistret i synk.
Utanför verify (kräver Chromium resp. nät): `npm run gate:ux` (320 px +
desktop, alla sidor), `npm run gate:links` (extern länkhälsa efter deploy).

`tools/seokeywords.mjs --check`, `tools/genqueries.mjs --check`,
`tools/genkgraf.mjs --check`: datalagren i synk med sanningsmodellen.
`tools/genmanual.mjs --check`: reaktiva handboken. Drizzle-determinism,
hemlighetsskanning och deploy-konfig ingår i samma verify.

## Canonical-policy (beslutas här, aldrig ad hoc)

- **Trailing slash**: katalogform med avslutande snedstreck är kanonisk
  (`/bidrag/slug/`). Genereras och länkas alltid så.
- **Värd/protokoll**: `https://bidragskoll.se` (apex, https) är enda kanoniska
  bas — www→apex och http→https redirectas permanent (verifieras vid deploy).
- **Query-parametrar**: publika ytan använder inga; skulle spårnings-
  parametrar förekomma pekar canonical alltid på parameterfri URL.
- **Paginering/filter/sortering**: existerar inte i dag; införs de får varje
  vy antingen självkanonisk unik URL med eget innehåll eller noindex —
  beslutet tas i detta dokument innan koden skrivs.
- **404**: noindex, utanför sitemap, canonical till /404 (aldrig soft-200).

## Robots-policy

Allow allt publikt; Disallow endast appens inloggade vyer (/projekt,
/ansokningar, /konto, /dokument, /admin, /inkorg). Staging/preview: Vercel
preview-domäner ska inte indexeras (X-Robots-Tag för preview — verifieras i
deploy-smoke efter deploy). Renderingsresurser blockeras aldrig.

## Prestanda-mål (interna, hårdare än Googles minimum)

Publika ytan: HTML ≤ 20 kB/sida (idag 8–16), inga tredjepartsskript, JS = 0
på svarssidorna, LCP-mål < 1,8 s och CLS < 0,05 i fältdata (mäts efter
deploy; DATA_UNAVAILABLE tills dess). Kända avsteg: Google Fonts-CSS:en är
render-blockerande (backlog M1) — accepterat varumärkesbeslut tills fältdata
säger annat; fallback-stacken renderar direkt via display=swap.

## Manuell del av gaten (Tier 1)

För Tier 1-sidor (blueprints B1–B10) räcker inte koden: mänsklig slutgranskning
av namngiven granskare krävs (modul 18 — blockerat av beslut H5), plus
kvalitetsloopens steg 1–11 (CONTENT_ENGINE §8) och Perfection Score ≥ 95
(§47) där **ett felaktigt belopp = FAIL oavsett totalpoäng**.

## Efter deploy tillkommer i gaten

Indexeringskontroll av nypublicerade sidor · GSC-fel (coverage) ·
CWV-fältdata mot målen · länkhälsa mot myndighetsdomäner (M8) ·
brand-SERP-kontroll enligt schema (§28).
