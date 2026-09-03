# SEO_CURRENT_STATE — teknisk och innehållsmässig nulägesbild

Datum: 2026-08-21 · Metod: fullständig genomgång av repot (routes, rendering,
metadata, indexeringsytor). Sajten är ännu inte deployad — detta är nolläget
inför lansering.

## Huvudslutsats

**Bidragskoll.se har idag noll publik, indexerbar innehållsyta.** Produkten
är en inloggnings-SPA (Vite + React, klientrenderad). För en sökmotor består
hela sajten av ett tomt `<div id="root">` med EN statisk title/description.
Kunskapsbasen — 84 kurerade stöd med villkor, belopp, källor och färskhet —
är exakt det innehåll som skulle kunna ranka, men den exponeras idag enbart
bakom inloggning via API:t. SEO-arbetet börjar alltså inte med optimering
utan med att **skapa den publika ytan**, genererad ur samma sanningsmodell
som produkten (`apps/api/src/seed/`).

## Inventering

| Yta | Läge | SEO-konsekvens |
|---|---|---|
| Rendering | 100 % klientrenderad SPA (Vite, ingen SSR/SSG/prerender) | Inget primärinnehåll i HTML-svaret; indexering beror helt på JS-rendering |
| Publika routes | `/villkor`, `/aterstall/:token`, login (`*`) — allt annat kräver session | Enda "innehållet" utåt är köpvillkoren |
| Title/meta | En (1) statisk title + description i `apps/web/index.html` för alla vyer | Ingen per-sida-metadata alls; `document.title` sätts aldrig per route |
| robots.txt | Saknas | Odefinierat crawlbeteende |
| Sitemap | Saknas | Ingen upptäckt av framtida innehåll |
| Canonical | Saknas överallt | — |
| Structured data | Ingen (0 förekomster av JSON-LD/schema.org i webben) | Ingen entity-signal för Organization/WebSite |
| Breadcrumbs | Endast in-app-navigering bakom login | — |
| Interna länkar (publikt) | Inga — det finns inga publika sidor att länka mellan | — |
| Bilder/alt | SPA:n är i praktiken bildfri; ej relevant ännu | — |
| Duplicat/tunt innehåll/orphans/404/redirects | Ej tillämpligt — ingen publik yta finns | Grönt fält: inget legacy att sanera, inga URL:er att bryta |
| Vercel-routing | `vercel.json`: allt utom `/v1`, `/assets`, `/api` skrivs om till SPA:ns `index.html` | Statiska filer i `apps/web/dist` serveras dock FÖRE rewrites — en genererad statisk yta kan alltså läggas under t.ex. `/bidrag/` utan att röra appen |
| Core Web Vitals-risk | SPA-bundlen laddas för alla vyer; för publika innehållssidor vore det onödig vikt | Publika sidor bör vara rena statiska HTML-dokument utan app-bundle |
| Query-parametrar/facetter | Inga publika — ingen indexbloat-risk idag | Håll det så: appens vyer ska aldrig indexeras |

## Tillgångar som SEO-arbetet kan bygga på (finns redan)

1. **Sanningsmodellen**: 72 stöd, 35 finansiärer, 36 källor med `sourceUrl`,
   kureringsstämpel och kureringsdatum — allt i `apps/api/src/seed/data.ts`,
   exporterbart utan databas (demo-bygget gör det redan).
2. **Kriterierna som innehåll**: varje stöd bär maskinläsbara villkor med
   klartextbeskrivningar ("Sökande ska vara 40 år eller yngre") — det är
   färdiga, sanna "Vem kan få?"-sektioner.
3. **Ärlighetsprinciperna** (bedömning-aldrig-beslut, källa + senast
   kontrollerad, ai_curated-stämpeln) — exakt den E-E-A-T-disciplin en
   YMYL-yta behöver, redan implementerad i produktspråket.
4. **Deterministisk generering**: demo-byggaren visar mönstret — statiska
   artefakter byggda ur seeden vid varje bygge, alltid i synk.

## Identifierade problem (prioriterade)

| # | Problem | Allvar |
|---|---|---|
| P1 | Ingen publik innehållsyta alls — inget kan ranka | Fundamentalt |
| P2 | Ingen per-sida-metadata, canonical, schema, sitemap, robots | Fundamentalt (löses tillsammans med P1) |
| P3 | Namnrymden är inte tom: Bidragskollen (bidragskollen.app) och Bidragsportalen existerar — brand-SERP och entity-SEO krävs från dag ett | Högt |
| P4 | Appens inloggade vyer får aldrig läcka ut i index (användarspecifikt innehåll) — indexeringspolicy måste sättas innan lansering, inte efter | Högt |
| P5 | Ingen mätning: GSC/analytics kräver deployad sajt + verifiering | Blockerat av deploy |

## Datakällor för sökordsarbetet — ärlig status

| Källa | Status |
|---|---|
| Google Search Console | `DATA_UNAVAILABLE` — sajten är inte deployad/verifierad |
| Google Ads Keyword Planner | `DATA_UNAVAILABLE` — inget annonskonto i miljön |
| Semrush / Ahrefs / DataForSEO | `DATA_UNAVAILABLE` — inga API-nycklar |
| Bing Webmaster Tools | `DATA_UNAVAILABLE` |
| Intern sökdata / analytics | `DATA_UNAVAILABLE` — ingen trafik finns ännu |
| Google SERP (via WebSearch) | **TILLGÄNGLIG** — används för SERP-ownership, frågeformuleringar, konkurrens. Brasklapp: USA-proxat index; kan avvika något från google.se |
| Myndigheternas informationsarkitektur (WebFetch) | **TILLGÄNGLIG** (domän för domän; blockeringar markeras) |
| Kunskapsbasens entiteter | **TILLGÄNGLIG** — 72 stöd med officiell nomenklatur ur källor |

Konsekvens: **inga sökvolymer anges någonstans i detta projekt** förrän
GSC/Keyword Planner/tredjepartskälla är inkopplad. All prioritering tills
dess baseras på SERP-DERIVED-signaler + affärsrelevans, och varje keyword i
masterdatabasen bär sin källmärkning (`volume_source: DATA_UNAVAILABLE`).

## Rekommenderad grundarkitektur (genomförs i detta arbetspass)

En **statisk publik innehållsyta** genererad ur sanningsmodellen vid bygge:

```
tools/genseo.mjs  →  apps/web/dist/bidrag/…  (vid Vercel-bygget)
                     /bidrag/                 huvudhubb (alla stöd, grupperade)
                     /bidrag/<målgruppshubb>/ hubbar (endast där ≥3 stöd finns)
                     /bidrag/<slug>/          72 entity-sidor ur seeden
                     /sitemap.xml  /robots.txt
```

- Rena HTML-dokument (ingen app-bundle) → triviala Core Web Vitals.
- Genereras ur samma data som produkten → kan aldrig ljuga eller divergera;
  varje sida visar källa + "senast kontrollerad" + kureringsstämpel.
- Appen på `/` påverkas inte (filsystemet vinner över SPA-rewriten).
- QA-crawler i `npm run verify` vaktar länkgraf, canonical, metadata,
  strukturerad data och sitemap-täckning vid varje bygge.
