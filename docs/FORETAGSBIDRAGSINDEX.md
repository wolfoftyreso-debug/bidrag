# Företagsbidragsindex Sverige — modul och status

Målet: en levande, citerbar datatillgång som producerar sidan, statistiken,
rapporten, nyhetsbrevet, API:t, sociala datapunkter, widgets och medieunderlag
**från samma verifierade sanningslager** — infrastruktur, inte content marketing
(§90). Bärande regel: **får aldrig hitta på statistik** (§1). Saknas uppgift →
"uppgift saknas eller har inte kunnat verifieras".

## Nulägesinventering (§62) — den ärliga verkligheten

Modulen ska "börja från befintlig databas". Den är:

- **85 kurerade stöd**, varav **27 riktar sig till företag/ekonomisk förening**
  (siffrorna beräknas av `computeFundingIndex` ur seeden — kontrollera dem med
  `npm run seo:build` i stället för att lita på den här raden).
- **Verifierat maxbelopp känt för 1 av 25** (4 % täckning). "4,82 miljarder"
  vore ren fabrikation — publiceras aldrig.
- **Ingen tidsserie, inga dagliga snapshots, inga change-events, inga
  awards/disbursements-tabeller.** (`source_snapshots` finns för enskilda
  ansökningar, inte aggregerad marknadsdata.)

Därför bygger denna release den **reproducerbara delen fullt ut** och redovisar
öppet vad som saknar data — i stället för tomt scaffolding eller påhittade tal.

## Byggt (verkligt, testat, grönt)

- **Intern domäntjänst** `tools/lib/foretagsindex.mjs` (§76 API-first internally):
  beräknar bara reproducerbara metrics ur seeden; resten returneras som
  `unavailable` med explicit skäl. Deterministisk (CURATED_AT).
- **Metric Registry** `seo/foretagsbidragsindex-metrics.json` (§16/§43): varje
  mått med definition, formel, enhet, kvalitet, begränsning + `requiresData`-skäl
  för de som ännu inte publiceras.
- **Publika sidor** (statiska, serverrenderade, `tools/genseo.mjs`):
  - `/foretagsbidragsindex/` — verkliga siffror: **25 öppna företagsstöd**,
    6 öppnar snart, per finansieringsområde/finansiär/stödtyp, verifierad
    finansiering med **ärlig 4 % täckning**, och en öppen "vad vi ännu inte
    mäter"-sektion. `Dataset` structured data (CC BY 4.0, isAccessibleForFree).
    "Kontrollera ditt företag"-CTA (§69).
  - `/foretagsbidragsindex/metodik/` — hela registret publikt (definitioner,
    formler, begränsningar; ingen påhittad indexpoäng).
- **Reproducerbarhetsgrind** (§80): `tools/seo-dataqa.mjs` räknar om ur seeden
  och fäller bygget om den publicerade siffran inte matchar. I verify.

## Ärlighetsval som gjordes (och varför)

- **Inget composite-indexvärde ("118,4")** publiceras — det kräver en historisk
  baslinje som inte finns (§7). Ingen godtycklig AI-poäng.
- **Ingen "pengar som frusit inne"** (§13) — jämförbar programbudget vs
  beviljanden saknas.
- **Verifierad finansiering** summerar bara kända maxbelopp och visar täckningen.
- **Inga mottagarprofiler** — data saknas, och skulle kräva n≥10 + tillåten
  återanvändning (§14/§65).

## Kräver data eller infrastruktur (deferred — exakt prerekvisit per del)

Byggs inte på gissad data. Det här är §17-rapporten "vilka data saknas":

| Del (§) | Blockerare |
|---|---|
| Dagliga snapshots + historik (§8/§17) | Live-DB + cron + realtid; `funding_index_snapshots`-tabell (schema i `SEO_CONTROL_PLANE.md`). Historik börjar samlas vid deploy. |
| Composite index + delindex (§7) | Kräver ovan (baslinjeperiod). |
| Nya/ändrade/stängda stöd (§6.4–6.5) | Change-events/versionshistorik. |
| Beviljanden/utbetalningar/ansökningsstatistik (§12/§64) | Import av officiell öppen data — finns ej i kunskapsbasen. |
| Månadsrapport-generator + faktavalidering (§21–24/§66–68) | Kräver historik + `ANTHROPIC_API_KEY` för narrativ (LLM formulerar, aldrig skapar siffror). |
| Nyhetsbrev + social distribution (§25/§26) | Kräver historik + befintlig e-post/SAGA-aktivering. |
| Publikt API + scoped keys + webhooks (§27–32/§55) | Kräver API Core-utbyggnad + auth; datamodell i `SEO_CONTROL_PLANE.md`. |
| Widgets + citation builder + chart embeds (§33–37/§73) | Embed-/CORS-infra; bygger på API:t ovan. |
| Admin control center + anomaly detection (§18/§42–47) | Kräver snapshot-pipelinen. |
| Länk-/citat-intelligence (§48–50) | GSC/Semrush/Ahrefs (BLOCKED_EXTERNAL, se `SEO_CONTROL_PLANE.md`). |

## Definition of Done — avbildning (§89)

DONE: drivs från verklig databas · kärnmetrics (öppna/öppnar snart/per
dimension) · reproducerbar publik statistik · source lineage (varje stöd har
källa) · publik indexsida + metodik · Dataset-markup · CTA till kärnprodukten.

REQUIRES-DATA/INFRA (ovan tabell): dagliga snapshots · historik · composite
index · rapportgenerator · nyhetsbrev · API/scoped keys · widgets · datasets-
nedladdning · admin · anomaly detection · full deploy.

Detta är den ärliga, reproducerbara grunden. Den växer till full plattform i takt
med att historik samlas och officiell öppen data importeras — aldrig genom att
fylla hål med påhittade siffror.
