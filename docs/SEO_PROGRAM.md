# SEO-programmet — ticket-liggare (SEO-001)

Enda kontrollytan för master-ticket-backloggen. Varje ticket avbildas mot den
**faktiska kodbasen** med evidens. Statusmodell: `TODO` · `READY` ·
`IN_PROGRESS` · `BLOCKED_EXTERNAL` · `BLOCKED_TECHNICAL` · `VERIFY` · `DONE`.

Regel: en ticket är `DONE` bara med evidens (fil/verktyg/gate). Externt beroende
(licens, Google-OAuth, DNS, socialt konto) → `BLOCKED_EXTERNAL`, adaptern/
dokumentationen byggs, ingen falsk implementation.

Relaterade styrdokument: `SEO_CONTROL_PLANE.md` (MCP/cron/Postgres),
`SEO_FUNDING_GRAPH.md` (graf + Query Pages), `SEO_SEMANTIC_AUTHORITY.md`
(entitet + maskinförståelse), `SEO_QUERY_PAGES.md` (Indexability-domar),
`ZERO_COMPROMISE_GATE.md` (offsite/anti-doorway), `IMPLEMENTATION_LOG.md`
(kronologisk evidens).

## Sammanfattning

Mycket av backloggen levererades redan i FAS SEO-2/3/4/5. Nedan är den ärliga
status-avbildningen. **Gate:** `npm run verify` kör nu SEO-regressionerna
(seocheck, semanticguard, semantictest, indexability, seo-dataqa) — 18→19 steg.

| Status | Antal | Innebörd |
|---|---|---|
| DONE | ~45 | byggt + testat i repot |
| PARTIAL | ~25 | grunddelen byggd, resten kräver större feature eller extern data |
| BLOCKED_EXTERNAL | ~30 | kräver licens/Google-OAuth/DNS/konto — adapter+doc byggs, aldrig falsk impl |
| TODO (byggbart) | ~26 | oblockerat, byggs i kommande batchar ur verklig data |

## EPIC A — Styrning, baseline, doktrin

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-001 | **DONE** | denna fil |
| SEO-002 | **DONE** | `docs/CURRENT_STATE_AUDIT.md` |
| SEO-003 | PARTIAL | `tools/seocheck.mjs` crawlar genererade ytan; deployad-crawl-baseline kräver deployad domän (BLOCKED_EXTERNAL) |
| SEO-004 | **DONE** | `seo/entity.json` (canonical produktdefinition) + `tools/semanticguard.mjs` |
| SEO-005 | **DONE** | Open Discovery-korrigeringen; `tools/semanticguard.mjs` fäller betalvägg-språk |
| SEO-006 | **DONE** | fyra canonical målgrupper i `entity.json`, hubbar, Query Pages |
| SEO-007 | **DONE** | `docs/ZERO_COMPROMISE_GATE.md` + `SEO_CONTROL_PLANE.md` §off-domain (anti-doorway/PBN) |
| SEO-008 | PARTIAL | canonical host = `https://bidragskoll.se` i kod; www/non-www-redirect = Vercel/DNS (BLOCKED_EXTERNAL) |

## EPIC B — SEO Control Plane & MCP

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-009 | **DONE** | `docs/SEO_CONTROL_PLANE.md` |
| SEO-010 | PARTIAL | schema dokumenterat i `SEO_CONTROL_PLANE.md`; migreras när en datakälla fyller det (medvetet ej tomma tabeller) |
| SEO-011–016 | BLOCKED_EXTERNAL | leverantörsabstraktion + adaptrar (Semrush/Ahrefs/DataForSEO/Firecrawl/Apify) — kräver konton/nycklar |
| SEO-017 | READY | Chrome DevTools MCP gratis/lokal — `.mcp.json.example` klar; kan kopplas i miljön på begäran |
| SEO-018 | READY | Playwright MCP gratis/lokal; Playwright används redan i `verify:ui`/`demo:check` |
| SEO-019 | BLOCKED_EXTERNAL | GSC-adapter — kräver Google-OAuth + verifierad domän |
| SEO-020 | BLOCKED_EXTERNAL | GA Data API — kräver Google-OAuth |
| SEO-021 | BLOCKED_EXTERNAL | Ads Keyword Planner — kräver Ads-konto |
| SEO-022 | PARTIAL | lokala seo-mcp-verktyg byggda: `page_audit`/`validate`/`orphan`/`broken` (`seocheck`), `content_find_cannibalization` (`seo-cannibalization`), `seo_verify_completion` (`indexability`), `ai_run_semantic_comprehension_test` (`semantictest`); full MCP-serverwrapper + externa verktyg återstår |
| SEO-023 | BLOCKED_EXTERNAL | Opportunity Queue kräver GSC/SERP-data |

## EPIC C — Teknisk SEO & routing

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-024 | **DONE** | route-inventory i `CURRENT_STATE_AUDIT.md`; robots + vercel-rewrite klassificerar publikt/privat |
| SEO-025 | **DONE** | typade metadata per sidtyp i `tools/genseo.mjs`; `seocheck` kräver unik title/description/canonical |
| SEO-026 | PARTIAL | canonical i kod; host-redirect = Vercel/DNS (BLOCKED_EXTERNAL) |
| SEO-027 | TODO | 410 för borttagna resurser — inga borttagna URL:er ännu; låg prio |
| SEO-028 | **DONE** | hela publika SEO-ytan är statisk HTML (meningsfull utan JS); personlig matchning klientdriven efter interaktion |
| SEO-029 | **DONE** | `robots.txt` genereras (`genseo`); `seocheck` verifierar |
| SEO-030 | PARTIAL | en sitemap idag; sitemap-index per sidtyp = TODO |
| SEO-031 | **DONE** | privata routes disallow i robots + genereras aldrig; app-vyer noindex via SPA |
| SEO-032 | PARTIAL | preview/staging noindex = Vercel-miljökonfig (delvis BLOCKED_EXTERNAL) |
| SEO-033 | **DONE** | Organization/WebSite/WebApplication/BreadcrumbList/WebPage/FAQPage; VideoObject/Dataset läggs till när de sidorna byggs |
| SEO-034 | **DONE** | breadcrumbs visuellt + `BreadcrumbList` på alla sidtyper |
| SEO-035 | **DONE** | OG/Twitter per sida; `seocheck` kräver og:image/twitter:card |
| SEO-036 | TODO | prestandabudget ej formaliserad (CWV trivialt för statiska sidor) |
| SEO-037 | PARTIAL | a11y-härdning gjord (motförhörets B1); full WCAG-baseline = TODO (OPEN_RISKS) |

## EPIC D — Kunskapsgraf & källdata

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-038 | **DONE** | `seo/kunskapsgraf.json` + `docs/SEO_FUNDING_GRAPH.md` (ontologi) |
| SEO-039 | **DONE** | seed-entiteter (`apps/api/src/seed/data.ts`) |
| SEO-040 | **DONE** | relationer i grafen (`tools/genkgraf.mjs`) |
| SEO-041 | PARTIAL | `sourceUrl` + `lastVerifiedAt` per stöd; full source-snapshot-infra = större feature (TODO) |
| SEO-042 | PARTIAL | `version` per stöd; change-events = TODO |
| SEO-043 | PARTIAL | `verificationStatus`/freshness finns; `tools/seo-dataqa.mjs` gatear nu källtäckning |
| SEO-044 | TODO | dedup — ej aktuellt problem (ingen multi-källa-ingestion ännu) |
| SEO-045 | PARTIAL | `deadlineModel`-livscykel; `seo-dataqa` gatear stale-open (SEO-120) |
| SEO-046 | TODO | förändringshistorik — kräver events |
| SEO-047 | PARTIAL | källa per stöd; per-claim-proveniens = TODO |
| SEO-048 | PARTIAL | källpolicy i sidfot + `docs/APPLICATION_CHANNELS.md`; dedikerad `/datakallor/` = TODO |

## EPIC E — Publika sidtyper & konvertering

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-049 | PARTIAL | SPA-startsida med målgruppsval + en-fråga-per-skärm; "radikalt enkel"-passet mot statisk hero = TODO |
| SEO-050–053 | PARTIAL | `/bidrag/{privatpersoner,foretag,foreningar}/`-hubbar finns; dedikerade toppnivåhubbar = TODO |
| SEO-054 | **DONE** | 72 canonical bidragssidor (`genseo` entityPage) med status/deadline/källa/CTA |
| SEO-055 | PARTIAL | "Kontrollera"-CTA → app-onboarding; riktad per-stöd-eligibility = app-feature |
| SEO-056 | **DONE** | "Ansök själv — gratis" officiell länk, synlig utan betalplan |
| SEO-057 | PARTIAL | watchlist-route finns i appen; SEO-CTA "Bevaka detta bidrag" = TODO |
| SEO-058 | **DONE** | `/vilka-bidrag-kan-jag-fa/` |
| SEO-059 | TODO | `/vilka-bidrag-kan-mitt-foretag-fa/` (org-nr-verktyg först; lookup BLOCKED_EXTERNAL) |
| SEO-060 | **DONE** | `/hitta-bidrag-gratis/` |
| SEO-061 | TODO | `/bevaka-bidrag/` |
| SEO-062 | TODO | `/forbered-bidragsansokan/` |
| SEO-063 | **DONE (denna batch)** | `/finansiarer/` + 35 finansiärssidor (15 INDEX/20 NOINDEX), indexability-gatade |
| SEO-064 | TODO | situation-/behovssidor (`/situationer/`) |
| SEO-065 | TODO | geografisidor (`/lan/`, `/kommuner/`) |

## EPIC F — Query Pages, indexering, internlänkning

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-066 | PARTIAL | `seo/query-universum.json` finns; verifierade volymer BLOCKED_EXTERNAL |
| SEO-067 | **DONE** | `seo/search-intents.json` (intent → canonical URL) |
| SEO-068 | **DONE** | Query Page-generator (`genseo` + `tools/lib/intents.mjs`) |
| SEO-069 | **DONE** | Indexability Score (`tools/lib/intents.mjs`, `indexability.mjs`) — INDEX/NOINDEX_FOLLOW/DO_NOT_GENERATE |
| SEO-070 | PARTIAL | länkgraf finns (kunskapsgraf); dedikerad kant-motor = TODO |
| SEO-071 | PARTIAL | relaterade/länkar renderas grafdrivet på entity-/query-sidor |
| SEO-072 | **DONE** | orphan-detektor (`seocheck` BFS) |
| SEO-073 | **DONE** | `tools/seo-cannibalization.mjs` |
| SEO-074 | **DONE** | broken-link/redirect (`seocheck` intern länkgraf) |

## EPIC G — Konkurrentanalys & bäst-i-test

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-075–078 | TODO/BLOCKED_EXTERNAL | konkurrentdatabas/snapshots/crawl — kräver Firecrawl/DataForSEO |
| SEO-079–085 | TODO | mystery-shopping/testmotor/jämförelsehub — kräver verifierad konkurrentdata + redaktionell grind; grund i `docs/SEO_COMPETITORS.md` |
| SEO-086 | TODO | varumärkeskollision — utredningsdokument (ingen kod) |

## EPIC H — Publika dataresurser

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-087 | TODO (byggbart) | Bidragskalender ur seedens deadlines — nästa batch |
| SEO-088/089 | TODO | Nya/Ändrade bidrag — kräver change-events (SEO-042/046) |
| SEO-090 | TODO (byggbart) | Kommande deadlines ur seeden — nästa batch |
| SEO-091 | **DONE** | `/bidragsstatus/` |
| SEO-092 | TODO | Bidragsindex — kräver historiska tidsserier |
| SEO-093/094 | TODO | RSS/JSON-feed + Dataset-markup |

## EPIC I — YouTube, socialt, SAGA

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-095–101 | BLOCKED_EXTERNAL | YouTube-konto + SAGA-integration; strategi i `SEO_CONTROL_PLANE.md` §off-domain |

## EPIC J — Partnerskap & länkförtjäning

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-102–109 | TODO/BLOCKED_EXTERNAL | widgets kräver embed-infra + org-nr-lookup (licensierad data); partnerprogram = affär |

## EPIC K — Analytics, AI-synlighet, optimering

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-110–115 | BLOCKED_EXTERNAL | event-taxonomi/TTA/funnel/share-of-search/striking-distance/decay — kräver GA/GSC |
| SEO-116 | **DONE** | Semantic Comprehension Test (`tools/semantictest.mjs`, offline + `--llm`) |
| SEO-117 | BLOCKED_EXTERNAL | AI mention/citation tracker — kräver modell-/SERP-åtkomst |
| SEO-118 | BLOCKED_EXTERNAL | SEO Control Center-dashboard — kräver datakällorna ovan |

## EPIC L — QA, release, fortlöpande kontroll

| # | Status | Evidens / anmärkning |
|---|---|---|
| SEO-119 | **DONE** | SEO-regressionssvit i `npm run verify`: seocheck + semanticguard + semantictest + indexability + seo-dataqa |
| SEO-120 | **DONE (denna batch)** | `tools/seo-dataqa.mjs` deadline-accuracy (inget engångsstöd stale-open) |
| SEO-121 | **DONE (denna batch)** | `tools/seo-dataqa.mjs` source-accuracy (varje stöd har källa + ansökningslänk) |
| SEO-122 | **DONE** | `seocheck` NOINDEX-medveten sitemap-paritet + `indexability` |
| SEO-123 | **DONE** | orphan/broken-link-regression (`seocheck`) |
| SEO-124 | PARTIAL | kuratorsflöde finns; SEO-specifik content-review = TODO |
| SEO-125 | PARTIAL | evidens per modul i `IMPLEMENTATION_LOG.md` |
| SEO-126 | TODO | full slutrevision — efter att externa delar kopplats |

## Nästa oblockerade tickets (byggbara ur verklig data)

Prioriterad kö som INTE kräver externa nycklar/konton:

1. **SEO-087 Bidragskalender** + **SEO-090 Kommande deadlines** — vyer ur seedens `opensAt`/`closesAt`/`deadlineModel`.
2. **SEO-059 `/vilka-bidrag-kan-mitt-foretag-fa/`** + **SEO-061 `/bevaka-bidrag/`** + **SEO-062 `/forbered-bidragsansokan/`** — flaggskepp/own-the-answer-sidor.
3. **SEO-064 situationssidor** (`/situationer/`) — kräver kurering av situation→stöd (öppnar även DO_NOT_GENERATE-intentioner).
4. **SEO-030 sitemap-index** per sidtyp.
5. **SEO-048 `/datakallor/`** + **SEO-086 varumärkesutredning** (dokument).

## Kräver din åtgärd (BLOCKED_EXTERNAL — jag bygger adapter+doc, aldrig falsk impl)

Köp/koppla: Semrush, Ahrefs, DataForSEO, Firecrawl (EPIC B) · Google Search
Console, Analytics, Ads Keyword Planner (EPIC B/K) · YouTube + SAGA (EPIC I) ·
DNS för host-redirect (SEO-008/026). När connectors/nycklar finns bygger jag de
externa adaptrarna, cron/kön, Postgres-migreringen och de datadrivna dashboards
som resten av backloggen hänger på.
