# SEO-5 — SEO-kontrollplanet (MCP + cron + Postgres)

Blueprint för ett riktigt SEO-kontrollplan i utvecklingsmiljön. **Ingen enda
"magisk SEO-plugin"** — styrkan är kombinationen av extern sök-/konkurrentdata,
Googles egen data, crawler/browser-automation, egna SEO-regler och schemalagd
övervakning.

## Bärande arkitekturprincip

> **MCP är verktygsgränssnittet. Det är inte själva automationen.**

Den kontinuerliga motorn körs genom **cronjobb och köer** och lagrar resultaten i
**Postgres**. Claude Code / Cursor / Codex / Grok använder sedan samma
**bidragskollen-seo-mcp** för att LÄSA resultatet, rekommendera åtgärder och
implementera dem — bakom en uttrycklig godkännandegrind.

```
externa MCP-servrar (Semrush/Ahrefs/DataForSEO/Firecrawl…) ─┐
Googles API:er (GSC/GA/Ads Keyword Planner) ────────────────┤→ cron/kö → Postgres
Chrome DevTools / Playwright (teknisk QA) ──────────────────┘        │
                                                                     ▼
                          bidragskollen-seo-mcp (read-only) ←─ agenten läser & agerar
```

## Säkerhetsposture (obligatorisk)

MCP-servrar kan läsa externa data, exekvera operationer och nå API:er. Därför:

- **Endast granskade servrar** aktiveras.
- **Separata read-only-nycklar** — inget SEO-verktyg får publicera eller radera
  innehåll utan ett uttryckligt godkännandesteg.
- **Inga nycklar i repot** (`npm run verify` skannar). DataForSEO- och Google-
  nycklar läggs i lokal secret storage / central API Core, aldrig i `.mcp.json`.
- `.mcp.json.example` i repot är en **nyckellös mall** — den riktiga `.mcp.json`
  är gitignorerad.

## Leverantörsstacken

| # | Server | Roll | Endpoint / kommando | Kostnad (ca) | Nyckel | Status |
|---|---|---|---|---|---|---|
| 1 | **Semrush MCP** | Operativ huvudplattform: sökord, ranking, share of voice, AI-visibility | `https://mcp.semrush.com/v2/mcp` | 117–139 USD/mån | OAuth | kräver konto |
| 2 | **Ahrefs MCP** | Länk- & konkurrentunderrättelse (backlinks, content gap) | `https://api.ahrefs.com/mcp/mcp` | fr. 129 USD/mån (Lite) | OAuth | kräver konto |
| 3 | **DataForSEO MCP** | Egen SEO-datamotor: SERP, PAA, autocomplete, on-page, AI-omnämnanden | `npx dataforseo-mcp-server@latest` | pay-as-you-go, min. 50 USD | API-nyckel | kräver konto |
| 4 | **Firecrawl MCP** | Konkurrentcrawl (sajtregister, metadata, pris-/textändringar) | `https://mcp.firecrawl.dev/v2/mcp-oauth` | gratis 1 000 sidor/mån | OAuth | kräver konto |
| 5 | **Apify MCP** | Skala över plattformar (social, YouTube, LinkedIn, nyheter) | officiell MCP | fr. 29 USD/mån + användning | API-nyckel | senare |
| 6 | **Chrome DevTools MCP** | Teknisk SEO i riktig Chrome (rendering, nätverk, console, traces) | `npx -y chrome-devtools-mcp@latest` | gratis | — | lokal, redo |
| 7 | **Playwright MCP** | Automatiserade SEO-regressionstester (crawlbarhet, redirects, 404, canonical) | `npx -y @playwright/mcp@latest` | gratis | — | lokal, redo |
| 8 | **Google Search Console** | Klick, impressions, CTR, position, queries, URL Inspection, sitemaps | egen read-only-MCP ovanpå GSC API | gratis | OAuth | kräver koppling |
| 9 | **Google Analytics MCP** | Vilka SEO-sidor leder till faktisk kontroll/konvertering | Googles experimentella MCP | gratis | OAuth | kräver koppling |
| 10 | **Google Ads Keyword Planner** | Sökordsidéer + historiska metriker (KeywordPlanIdeaService) | egen read-only-integration | gratis (Ads-konto) | OAuth | kräver koppling |

Roller: **Semrush** = kontrollcentral · **Ahrefs** = länkar/konkurrenter ·
**DataForSEO** = vår egen maskin (så vi slipper klicka i Semrush för alltid) ·
**Firecrawl** = rent webbmaterial · **GSC** = sanningen om vår egen prestanda.
Vi använder aldrig leverantörernas AI-svar som sanning — bara deras rådata.

## bidragskollen-seo-mcp — verktygskontrakt

En liten **egen, read-only** MCP ovanpå ovanstående. Verktygen delas i två lager:

**LOKALT (fungerar utan externa nycklar — delvis redan byggt i repot):**

| Verktyg | Status i repot |
|---|---|
| `page_audit`, `page_validate_metadata`, `page_validate_canonical`, `page_validate_schema` | ✅ `tools/seocheck.mjs` (QA-crawl av genererade ytan) |
| `page_find_broken_links`, `page_find_orphan_pages` | ✅ `tools/seocheck.mjs` (länkgraf + orphan-BFS) |
| `content_find_cannibalization` | ✅ `tools/seo-cannibalization.mjs` |
| `seo_verify_completion` (indexerbarhetsdomar) | ✅ `tools/indexability.mjs` + `tools/lib/intents.mjs` |
| `content_recommend_internal_links` | delvis ✅ (grafdriven internlänkning i genseo/kunskapsgraf) |
| Maskinförståelse (AI förstår affärsmodellen) | ✅ `tools/semantictest.mjs` |

**EXTERNT (kräver leverantörskonto / Google-koppling — ej byggt):**

`gsc_query_performance`, `gsc_find_declining_pages`, `gsc_find_striking_distance_queries`,
`gsc_inspect_url`, `gsc_list_indexing_errors`, `gsc_submit_sitemap` ·
`keyword_expand`, `keyword_get_historical_metrics`, `keyword_cluster_by_intent` ·
`serp_snapshot`, `serp_compare_competitors`, `serp_calculate_share_of_search` ·
`competitor_crawl`, `competitor_detect_new_pages`, `competitor_detect_price_change`,
`competitor_detect_content_change` · `content_find_gaps`, `content_find_decay` ·
`ai_track_brand_mentions`, `ai_track_citations`, `ai_compare_competitors` ·
`seo_generate_opportunity_queue`.

Varje externt verktyg ska följa repots **503-ärlighet**: utan konfigurerad
nyckel svarar det ärligt "not configured — kräver `<VENDOR>`", aldrig påhittade
siffror.

## Cron/kö-motorn (cadence)

| Jobb | Frekvens | Källa | Skriver till |
|---|---|---|---|
| SERP-snapshots | dagligen | DataForSEO | `serp_snapshots` |
| Search Console-metriker | dagligen | GSC | `gsc_metrics` |
| AI-omnämnanden/citeringar | dagligen | DataForSEO/Apify | `ai_visibility` |
| Konkurrentcrawl | dagligen/veckovis | Firecrawl | `competitor_pages` |
| Backlinks | veckovis | Ahrefs | `backlinks` |
| Teknisk crawl | vid varje deploy | Chrome DevTools/Playwright | `seo_quality_scores` |
| Fullständig SEO-revision | veckovis | alla | `seo_opportunity_queue` |

Vercel Cron finns redan för produktjobb (`vercel.json`); SEO-jobben kan läggas
som egna cron-poster + köhanterare i api:t när datakällorna kopplats.

## Postgres SEO-schema (redo att migrera när pipelinen landar)

Migreras **inte** på förhand — tomma spekulativa tabeller är skräp. Definieras
här så att `npm run db:generate` kan skapa migreringen den dag en datakälla
faktiskt fyller dem. Föreslagna tabeller (Drizzle i `apps/api/src/db/schema.ts`):

```
search_intents(id, canonical_query, applicant_type, need, canonical_url,
               primary_entity, funnel_stage, serp_type, content_status)   ← seo/search-intents.json är dagens fil-version
keyword_intent_mappings(keyword, intent_id, source, verified_at)
seo_pages(id, locale, slug, page_type, entity_id, primary_cluster_id,
          indexation_status, quality_score, data_freshness, ...)          ← indexation_status = INDEX/NOINDEX/… från Indexability-motorn
seo_indexation_status, seo_quality_scores, seo_internal_links, seo_page_versions
serp_snapshots(query, captured_at, positions, domains, features, our_pos, competitor_pos)
competitor_pages(domain, url, title, metadata, detected_at, changed_at)
backlinks(target_url, source_domain, first_seen, lost_at)
ai_visibility(prompt, model, captured_at, mentioned, cited, competing_sources)
gsc_metrics(date, query, page, clicks, impressions, ctr, position, device, country)
seo_opportunity_queue(id, priority, query, page, signal, recommended_action, status)
```

## Off-domain-auktoritet — bygg INTE ett nät av minisajter

Google pekar ut flera likartade domäner som leder till samma slutdestination som
**doorway abuse**, och storskaligt genererat innehåll utan självständigt värde
som **scaled content abuse**. Detta ligger redan i offsite-doktrinen
(`docs/ZERO_COMPROMISE_GATE.md`: ALDRIG PBN/utgångna domäner, satellittestet).

**Koncentrera auktoriteten till bidragskoll.se.** Bygg i stället — allt återanvänder
samma bidragsgraf:

1. **Sökdriven YouTube-kanal** som ett parallellt sökindex (Serie A "Kan jag få
   detta?", B "Så gör du", C "Nytt och öppet", D "Varför du inte kvalificerar").
   Varje video → egen sida på bidragskoll.se (video + kort svar + transkription +
   kapitel + källor + "Kontrollera om jag kan få det"). Takt: 2 sökdrivna
   videor/vecka + 3–5 Shorts + ett veckosvep. Hellre 20 användbara än 300 tomma.
2. **Partnerwidgets** (redovisningsbyråer, inkubatorer, kommunala rådgivare,
   föreningar): gratis "Vilka stöd kan ditt företag få? [org.nr]" → länk till
   full kontroll, "Powered by Bidragskollen" (ej keyword-spam). Ger äkta verktyg
   + legitim extern länk + rätt målgrupp. Även förenings-, enskild-firma-,
   kalender- och deadline-widget.
3. **Data som medier vill citera** (kvartalsvis): *Svenskt bidragsindex*,
   *Bidragsbarometern* (anonymiserad kontrollstatistik), *årlig jämförelse av
   bidragstjänster* (pris, betalvägg, steg, datakvalitet, Time to Answer).
   Nedladdningsbar CSV/JSON + `Dataset` structured data.
4. **Öppet tekniskt lager** på GitHub: svensk bidragstaxonomi, dataschema,
   API-klient, normaliserade statusdefinitioner, open-source bidragskort-komponent,
   exempel på structured data. **Ge inte bort matchningsmotorn eller databasen** —
   publicera standarderna runt den.
5. **Partnerprogram** — 50 verkliga distributionspartners i stället för tusentals
   generiska länkar (widget + partnerdashboard + gemensam guide + datarapport).
6. **SAGA som distributionsmotor**: en databashändelse (`grant.opened/reopened/
   deadline_changed/eligibility_changed/new`) → ompaketerar VERIFIERADE fakta till
   canonical-uppdatering + YouTube-/Short-manus + LinkedIn/FB/IG + nyhetsbrev +
   SMS-kandidat + pressnotis + internlänkförslag. SAGA uppfinner aldrig nya
   sakuppgifter. Allt leder till **kontroll**, aldrig till "läs vår artikel".
7. **Entity-/varumärkessignaler**: samma fakta överallt (namn, juridisk operatör
   Landvex AB, org.nr 559141-7042, redaktionell metod, datakällor). Organization-
   markup med endast **synliga och sanna** uppgifter — redan implementerat i
   `apps/web/index.html` + genseo (org.nr + adress). `sameAs` läggs till först när
   verkliga officiella profiler finns (hitta aldrig på dem).

## Mätetal som styr arbetet (inte bara trafik)

- **Google:** share of search per målgrupp · queries topp 3/10 · impressions · CTR ·
  branded searches · indexerade kvalitetssidor · crawl-/indexeringsfel.
- **AI-modeller:** andel testprompter där Bidragskollen nämns/citeras · vilka
  källor som citeras i stället · om modellen förstår gratis discovery vs betalt
  (mäts redan lokalt av `tools/semantictest.mjs --llm`).
- **Produkt:** **Time to Answer** · kontrollstarter från organiskt · slutförda
  kontroller · öppnade bidragskort · "Ansök själv"-klick · aktiverade bevakningar.
- **Auktoritet:** nya relevanta referensdomäner · länkar från myndigheter/kommuner ·
  omnämnanden utan länk · pressciteringar · partnerinstallationer · YouTube-visningar.

## 90-dagarsupplägg

- **Dag 1–7 — kontrollplanet:** koppla Semrush/Ahrefs/DataForSEO/Firecrawl/Chrome
  DevTools/Playwright + GSC/GA/Ads; första sökordsuniversumet; rankingbaseline mot
  kända konkurrenter; första `bidragskollen-seo-mcp`; SEO-tabeller i Postgres;
  dagliga cronjobb.
- **Dag 8–30 — ytan som ska ranka:** "vilka bidrag kan jag/mitt företag få",
  enskild firma, privatperson, förening, hitta gratis, bevaka, hjälp med ansökan,
  jämför tjänster, Grantigo-alternativ, kalender, nya bidrag, kommande deadlines.
  *(Flera redan byggda: flaggskepp + Query Pages + `/bidragsstatus/`.)*
- **Dag 31–60 — auktoriteten:** YouTube igång; första datarapporten; partnerwidget;
  första 50 partnerkontakterna; jämförelsehub; nyhetsbrev + RSS; automatiskt
  förändringsflöde; systematisk digital PR.
- **Dag 61–90 — skala det som visar signal:** GSC + SERP → position 4–15, hög-
  impression-låg-CTR, konkurrentgap, trafik-utan-kontroll; skala bara sidtyper som
  indexeras, får impressions, löser intentionen och leder till en användarhandling.

## Vad som är byggt i repot nu vs vad som kräver din åtgärd

**Byggt (in-repo, testat, grönt):** den lokala delen av seo-mcp
(`seocheck`/`indexability`/`seo-cannibalization`/`semantictest`), Query Pages +
Indexability-motorn, `/bidragsstatus/`, entitetssignaler (org.nr/adress),
`.mcp.json.example` (nyckellös mall), detta blueprint.

**Kräver din åtgärd (jag assisterar när connectors/nycklar finns):** köp av
Semrush/Ahrefs/DataForSEO/Firecrawl; koppling av GSC/GA/Ads; bygg av de externa
seo-mcp-verktygen + cron/kö + Postgres-migreringen; YouTube-kanal; partnerprogram;
datarapporter. Inget av detta byggs på gissad data.
