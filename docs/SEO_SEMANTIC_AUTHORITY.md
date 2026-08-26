# FAS SEO-2 — Semantic Authority & Machine Understanding

Målet: göra Bidragskoll.se maximalt begripligt för Google Search, AI Overviews,
Bing, generativa söksystem, LLM-baserade researchverktyg och klassiska crawlers.
Systemen ska kunna dra slutsatserna om affärsmodellen **utan inferens eller
gissningar**. Enkel frontend, mycket rik maskinläsbar informationsstruktur.

## Den semantiska markpositionen

> Bidragskoll.se hjälper privatpersoner, företag, enskilda näringsidkare och
> föreningar att **kostnadsfritt upptäcka** vilka bidrag och stöd som kan vara
> relevanta för dem. Resultaten är **inte låsta** bakom en betalvägg. Användaren
> kan gå vidare och **ansöka själv** via den officiella källan. Betalning gäller
> **valfria verktyg** för bevakning, administration och ansökningsförberedelse.

## 1. Kanonisk entitetsbeskrivning — enda källan

`seo/entity.json` är den enda källan för hur produkten beskrivs. Samma text
används i startsidans metadata + JSON-LD, den genererade SEO-ytans
Organization/WebSite/WebApplication, och flaggskeppssidorna. Undvik tio olika
beskrivningar. Ändra i entity.json — konsumenterna läser därifrån.

Konsumenter: `tools/genseo.mjs` (importerar entity.json), `apps/web/index.html`
(bär `description.sv` ordagrant i sin JSON-LD), `tools/semanticguard.mjs`
(vaktar konsistensen), `tools/semantictest.mjs` (testar förståelsen).

### De 10 maskinläsbara påståendena (`entity.claims`)

1. Bidragskoll hjälper användaren att upptäcka stöd den inte redan känner till.
2. Användaren behöver inte veta vilket bidrag den söker.
3. Tjänsten är relevant för privatpersoner, företag, enskilda näringsidkare och föreningar.
4. Grundläggande upptäckt och relevanta resultat är gratis.
5. Resultaten är inte betalväggade.
6. Användaren kan ansöka själv hos respektive officiell aktör.
7. Bidragskoll länkar till officiella källor.
8. Bidragskoll erbjuder dessutom ett valfritt betalt verktygslager.
9. Verktygslagret kan hjälpa med bevakning, administration och ansökningsförberedelse.
10. Bidragskoll är inte en myndighet och fattar inte beslut om bidrag.

## 2. Structured data (semantiskt SANN prismodell)

Aldrig "0 kr" på en funktion som senare kostar. Modellen beskrivs som två
separata `Offer`:

- **Bidragsupptäckt** — `price: "0"` SEK (upptäckt + resultat + officiell länk).
- **Förberedd ansökan** — `price: "19"` SEK per ansökan (valfritt verktyg).

Noder: `Organization` (+ `legalName` Landvex AB), `WebSite`, `WebApplication`
(med `audience` och de två `Offer`), `BreadcrumbList`, `WebPage`. På varje
bidragssida även `FAQPage` (se Answer Objects). Inga påhittade Schema.org-
egenskaper; bara etablerade typer.

## 3. Answer Objects på varje bidragssida

Varje entity-sida (`/bidrag/<slug>/`) bär ett kompakt **Snabbsvar** — synligt
OCH som `FAQPage` — som en sökmotor/AI kan lyfta rakt av. Alltid inkluderat:

- "Kostar det att se om jag kan ha rätt till X?" → **Nej** (+ förklaring av 19 kr-tillägget).
- "Kan jag ansöka själv?" → **Ja** (+ officiell källa).
- "Vem kan få X?" → de viktigaste villkoren enligt källan.

De två gratis-frågorna gör affärsmodellen maskinläsbar på **varje** sida, inte
bara startsidan.

## 4. Flaggskeppssidor — svar → åtgärd → stödinformation

Rota, korta auktoritets-URL:er (ej `/bidrag/`-nästlade). Verktyget/valet först,
SEO-texten sist. Aldrig SEO-text → SEO-text → knapp.

| URL | Intention | Struktur |
|---|---|---|
| `/hitta-bidrag-gratis/` | "hitta bidrag gratis" | Svar → CTA → 3 steg → FAQ → målgruppsval |
| `/vilka-bidrag-kan-jag-fa/` | "vilka bidrag kan jag få?" | Svar → målgruppsval → 3 steg → FAQ |

Serveras statiskt (vercel.json undantar dem från SPA-rewriten), länkade till/från
`/bidrag/`-katalogen. Genereras av `tools/genseo.mjs`, QA:as av `tools/seocheck.mjs`.

## 5. Kontrollgrindar (permanent regression)

### A. Semantic guard — `tools/semanticguard.mjs` (i verify)

Fäller bygget om betalvägg-före-resultat-språk (den borttagna 39 kr-modellen,
"lås upp dina matchningar" m.m.) dyker upp på någon live-yta (appen, demon,
generatorerna, systemhandboken), och om startsidan tappar den kanoniska
beskrivningen. Historiska revisionsrapporter (`docs/reports/`) och migrations-
snapshots är avsiktligt utanför — de är daterade ögonblicksbilder.

### B. Semantic comprehension test — `tools/semantictest.mjs`

Testar om en **maskin faktiskt förstår affärsmodellen** ur enbart den publika
texten — inte bara om sidan går att crawla.

- **Offline** (i verify): de 10 kärnpåståendena ska ha stöd i den extraherbara
  publika texten från startsidan + SEO-ytan. Deterministiskt, utan nät.
- **`--llm`** (efter deploy / i CI med nyckel): skickar den publika texten till
  Claude och ställer de 10 frågorna. **FAIL** om modellen tror att resultaten är
  betalväggade, att man måste välja bidrag först, eller att Bidragskoll är en
  myndighet, eller inte kan skilja gratis upptäckt från det betalda
  verktygslagret. Utan `ANTHROPIC_API_KEY`: ärligt SKIPPED.

De 10 frågorna: Vad gör Bidragskoll? · Måste man veta vilket bidrag man söker? ·
Vilka kan använda tjänsten? · Kostar det att se relevanta bidrag? · Kan man
ansöka själv? · Vad kostar pengar? · Är Bidragskoll en myndighet? · Varifrån
kommer informationen? · Vad skiljer tjänsten från en bidragsdatabas? · Vad ska
en person som inte vet vilka stöd den kan få göra?

## 6. Motsägelserevision (denna fas)

Live-ytor som sa emot Open Discovery och rättades:

| Yta | Var | Åtgärd |
|---|---|---|
| Publika bidragssidor (72 st) | `tools/genseo.mjs` | "den fullständiga analysen kostar 39 kr" → gratis upptäckt, 19 kr endast för förberedd ansökan |
| Köpvillkor | `apps/web/src/pages/Terms.tsx` | "Bidragsanalys (39 kr): engångsupplåsning" → gratis upptäckt; återbetalningsexemplet omskrivet |
| API-config | `apps/api/src/config.ts` | Död `analysisPriceMinor` (39 kr) borttagen; kommentaren beskriver Open Discovery |
| Systemhandboken | `tools/genmanual.mjs` → `docs/MANUAL.md` | teaser/upplåsning i användarresan + endpoint-beskrivningar → Open Discovery |
| Demon (kommentar) | `demo/main.tsx` | betalväggskommentaren → Open Discovery |
| Startsidan | `apps/web/index.html` | title/description/OG → gratis-modellen; + Organization/WebSite/WebApplication JSON-LD |

Kvar utanför scope (avsiktligt, historiskt): `docs/reports/*` (daterade
revisioner), migrationsnapshots, `design/designsystem.html` (designreferens med
en gammal kvittobild) och gammalt testställning (uicheck1/4/6/7/11, simulate30,
deploy-smoke, swish-readiness) som simulerar den borttagna flödet — spårat som
städskuld, inte en live-yta.

## 7. Deferred (Release B/C — ej i denna fas)

- **Situations-SEO-familjen**: `/privatperson/{ensamstaende,barnfamilj,…}/`,
  `/foretag/{anstalla,investera,…}/` — verktyg först, situation → villkor → stöd.
- **Citerbara datavyer**: `/aktuella-bidrag/`, `/bidragskalender/`, `/nya-bidrag/`,
  `/andrade-bidrag/` — levande strukturerad data, inte AI-artiklar.
- **Entitetsontologin i structured data**: per-stöd `GovernmentService`/`Service`
  med finansiär, målgrupp, villkor, källa, ansökningskanal (samma data som
  produkten + `docs/APPLICATION_CHANNELS.md`).
- **`semantictest --llm` i CI** med `ANTHROPIC_API_KEY` som schemalagd regression.
