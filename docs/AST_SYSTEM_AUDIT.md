# AST System Audit — har vi byggt det system vi säger att vi byggt?

Full kontroll- och verifieringsoperation (DEL I–XXIII). Regel: lita inte på docs/
tickets/kommentarer — verifiera kod, data, runtime, rendering, SEO-output. Varje
punkt klassad; **UNKNOWN är inte ett godkänt slutläge**. Verifierat mot faktisk
kod + genererad yta denna session.

## Domar

| DEL | Område | Dom | Evidens (verifierat) |
|---|---|---|---|
| I | Produktens kärntes (discovery, inte sökportal) | **VERIFIED** | `tools/doctrine.mjs` + `semanticguard.mjs` fäller bygget om intag kräver förkunskap eller värde-före-betalning bryts |
| II | Fyra sökandekontexter | **VERIFIED** | `Onboarding.tsx` who-steg: Mig själv/Företag/Enskild firma/Förening; enskild firma = dubbelkontext (personspår + self_employed/sole_trader) |
| III | Zero-knowledge discovery | **PARTIAL** | Situations-först fungerar utan bidragsnamn (VERIFIED); org-nr-autohämtning för företag = **BLOCKED_EXTERNAL** (licensierad datakälla saknas); privat = bara födelseår (ingen PII) |
| IV | Progressive eligibility | **VERIFIED** | matchmotorn ställer bara följdfrågor som påverkar eligibility; öppna frågor sorteras efter hur många stöd de avgör (F-STABIL, §7) |
| V | Resultat före betalning | **VERIFIED** | Open Discovery; matches ogatade (`routes/projects.ts` — inget isProjectUnlocked/402); `semanticguard` vaktar. **DEAD_CODE borttaget denna audit** (se nedan) |
| VI | Bidrag som personlig inkorg | **PARTIAL** | matcheligibility-states finns (eligible/unknown/excluded) + ansökningens tillståndsmaskin; en enhetlig "inkorg"-vy saknas |
| VII | Bevakningsmotorn (hela profilen) | **PARTIAL** | watchlist-route + deadline-scan-cron finns; "bevaka hela min profil" (profil × marknadsevent → omvärdering) ej fullt eventdriven |
| VIII | Varför / varför inte | **VERIFIED** | `packages/core` ger per-kriterium-förklaring + missingFacts + uteslutningsskäl; inga nakna match-% |
| IX | Data som produkt (strukturerad sanning) | **PARTIAL** | 21/21 kärnfält finns (slug…deadlineModel, källa, verifieringstid, version) — grants är strukturerade, inte textblobbar. **MISSING:** förändringshistorik, per-call-period, normaliserade kostnadskategorier, per-claim-proveniens |
| X | Official source first + accuracy | **PARTIAL** | `sourceUrl` 100 % + separat `applicationUrl` (`seo-dataqa`); source/deadline/status/eligibility-accuracy mot LEVANDE officiell källa = **BLOCKED_EXTERNAL** (kräver nät till myndighetssidor + mänsklig verifiering) |
| XI | Enhetlig kunskapsgraf | **VERIFIED** | `seo/kunskapsgraf.json` ur seeden; discovery (core), SEO (genseo), index — allt ur samma seed. Inga parallella semantiska världar |
| XII | SEO: äg svaret | **VERIFIED** | flaggskepp + Query Pages i ordning svar→verktyg→data (`genseo`) |
| XIII | URL-/länkarkitektur | **PARTIAL** | kärna finns (/bidrag, /finansiarer, /foretag|privatperson|forening/query, /bidragsstatus, /foretagsbidragsindex, /hitta-bidrag-gratis, /vilka-bidrag-kan-jag-fa). **MISSING:** /situationer, /behov, /branscher, /lan, /kommuner, /bidragskalender, /nya-bidrag, /andrade-bidrag, /kommande-deadlines, /bevaka-bidrag, /vilka-bidrag-kan-mitt-foretag-fa, /jamfor* (spårade i `SEO_PROGRAM.md`) |
| XIV | Programmatic guardrail | **VERIFIED** | Indexability-motorn + §29-enforcement (`intents.mjs` + `seo-dataqa.mjs`): INDEX/NOINDEX/CANONICAL_TO_PARENT/MERGE/REMOVE_410/DO_NOT_GENERATE |
| XV | Internlänkning som graf | **VERIFIED** | `seocheck` orphan-BFS = 0 orphans; grafdrivna relaterade länkar |
| XVI | Search intent ownership | **PARTIAL** | `seo/search-intents.json` (intent→canonical URL); ranking/konkurrens/GSC-data per intent = **BLOCKED_EXTERNAL** |
| XVII | Google control plane | **BLOCKED_EXTERNAL** | kräver GSC/Analytics/SERP-koppling (`SEO_CONTROL_PLANE.md`) |
| XVIII | MCP + seo-mcp | **PARTIAL** | lokala seo-mcp-verktyg byggda (seocheck/indexability/cannibalization/semantictest); externa MCP + full serverwrapper = **BLOCKED_EXTERNAL** |
| XIX | Konkurrentlandskapet | **PARTIAL** | `SEO_COMPETITORS.md` finns; live konkurrentdata/crawl = **BLOCKED_EXTERNAL** (Firecrawl/DataForSEO) |
| XX | Konkurrentsvagheter | **PARTIAL** | dokumenterat i `SEO_COMPETITORS.md`; live-verifiering = **BLOCKED_EXTERNAL** |
| XXI | Bäst i test (reproducerbar plattform) | **MISSING** | testplattform ej byggd — kräver konkurrentåtkomst (mystery shopping) |
| XXII | Konkurrentkritik = fakta | **NOT_APPLICABLE (ännu)** | ingen publik jämförelse publicerad; policyn kodifierad (`ZERO_COMPROMISE_GATE.md`, `SEO_CONTROL_PLANE.md`) |
| XXIII | AI-/GEO-synlighet | **PARTIAL** | `semantictest` offline VERIFIED (10/10); full multi-modell + AI-citat-tracking = **BLOCKED_EXTERNAL** (modellåtkomst/nät) |

**Ingen punkt lämnas i UNKNOWN.**

## Åtgärdat denna audit (DEAD_CODE — verkliga fynd, borttagna)

Fyndet från §V-adversarial-svepet: den borttagna betalvägg-teasern lämnade
död kod som ingen längre refererade:

1. **`demo/main.tsx`** — `TEASER_CATEGORY` + `TEASER_LEVEL` konstanter: definierade
   men aldrig refererade (grep bekräftade 0 användningar). Borttagna. `likelihoodOf`
   (som fortfarande används av `Likelihood`-komponenten) bevarad.
2. **`apps/web/src/styles.css`** — `.blurred-name` + hela `.rapport-*`-blocket
   (F-EXKLUSIV "exklusiv låst analys"): ingen tsx använder klasserna längre efter
   Open Discovery. Borttaget. `.checkbox-row`-basregeln (live, används i 4 komponenter)
   orörd.

Verifierat efter: typecheck rent · `npm run demo:build` KLAR · verify 19/19.

## Kvarstående (stale, ej borttaget — motivering)

- `payments.kind`-enumets `analysis_unlock`-värde + default: behålls medvetet för
  historiska rader (schema-kommentar); nya köp använder alltid `application_unlock`
  explicit, så defaulten träffas aldrig. Att ändra defaulten kräver en migrering
  för ren kosmetik — ej motiverat. `Account.tsx` mappar värdet för visning av ev.
  historiska kvitton (defensivt, inte dött i en produktionsdatabas med historik).

## Sammanfattande dom

**Kärnprodukten och den publika SEO-ytan är VERIFIED** (discovery-tes, fyra
kontexter, progressive eligibility, resultat-före-betalning, varför/varför-inte,
enhetlig graf, own-the-answer, programmatic guardrail, internlänkning). **PARTIAL**
där en större feature återstår men grunden finns (datamodellens historik/proveniens,
inkorg/bevakning, URL-familjen, search-intent-ägande). **BLOCKED_EXTERNAL** för allt
som kräver Google/Semrush/Ahrefs/konkurrentdata/licensierad org-nr-källa. **MISSING**:
bäst-i-test-plattformen. Vi har byggt det vi säger — utom där externa datakällor
eller obyggda features tydligt är utpekade som sådana, aldrig som färdiga.
