# LAUNCH CONTROL ROOM — lanseringskontrollrummet

Spår 4 i docs/LAUNCH_DEMAND_INTELLIGENCE.md. Utökar
docs/QUALITY_DASHBOARD_SPEC.md (kvalitetsvyerna behålls oförändrade) med
**lanseringspanelerna**: det som måste synas i realtid när riktiga användare
möter riktiga myndigheter. Status: spec — v0 byggs som statisk rapport ur
samma JSON-källor (QUALITY_DASHBOARD §Byggväg gäller), panelerna blir
levande i takt med att datakällorna aktiveras efter deploy.

## §1 Paneler

| # | Panel | Visar | Datakälla | Finns när |
|---|---|---|---|---|
| 1 | **SEO-ranking** | position per kluster-URL för Sprint 01:s querybas; diff mot föregående vecka; ETTA-MÖJLIG-kluster utan sida | GSC (position/impressions) + seo/serp-sprint01.json + artifacts/seo-audit.json | efter GSC-verifiering |
| 2 | **Trafik** | sessioner/dag på publika ytan, per kluster och hubb; toppdygnskurva mot modellens spikantagande | analytics/CDN-loggar | efter deploy |
| 3 | **Tratten** | seo→genomgång→match→pre-check→klick ut, dag för dag; **QSDR** och **ARR** med deklarerade proxies | instrumenteringseventen (LAUNCH_DEMAND_INTELLIGENCE §5) | efter 25-klusterfasen |
| 4 | **Matchningar** | matchvolym per stöd; stöd som aldrig matchas (död vikt); genomgångar utan match (QSDR-läckage) | API:ts egna data | efter deploy |
| 5 | **Utgående klick per myndighet** | belastningskartans fältdata: klick ut per myndighet/stöd/dag mot modellens routade volymer; deadline-fönster markerade ur seedens kalenderfält | event `klick_ut_myndighet` + AUTHORITY_LOAD_MAP | efter 25-klusterfasen |
| 6 | **Konvertering** | analysupplåsningar, förberedda ansökningar, kvitton; **visar ärligt BLOCKERAT-läge tills Swish finns** (blockerad efterfrågan räknas separat, aldrig som intäkt) | betalnings-/kvittotabellerna + readiness-endpointen | efter deploy (skarpt efter Swish) |
| 7 | **Fel** | 4xx/5xx-kurvor per route, ärliga 503:or per integration (Swish/Resend/generation), rate limit-träffar, event `fel_visat` | /metrics + loggar | efter deploy |
| 8 | **Källändringar** | källdiffar sedan senaste granskning; äldsta "senast verifierad"; stöd vars källa ändrats med publik sida live | source-fetch-jobbet + kuratorsnotifieringarna | finns redan (v0 kan byggas nu) |
| 9 | **Myndighetsdrift** | signaler om att en myndighets e-tjänst/fönster ändrats: källdiff på ansökningssidor + stängda omgångar ur seedens kalenderfält | samma som 8 + opensAt/closesAt | finns redan (v0) |
| 10 | **Spiklarm** | tröskellarm (§2) | paneler 2, 5, 7 | efter deploy |

## §2 Spiklarm (trösklar relativa modellen, inte absoluta)

Absoluta trösklar vore låtsasprecision före fältdata. Larmen definieras
relativt: baslinjen är rullande 7-dagarsmedian, och modellens
spikparametrar (seo/demand-parametrar.json §spik) sätter förväntansbandet.

- **TRAFIKSPIK**: dygnstrafik > 3× rullande median → informativt larm
  (glädjeläge, men kontrollera panel 5 och 7 innan något firas).
- **MYNDIGHETSSPIK**: klick ut till EN myndighet > 5× median samtidigt som
  myndigheten har öppet deadlinefönster → kontrollera att pre-check-vyn
  fungerar och att vi inte skapar sista-dagen-våg (AUTHORITY_LOAD_MAP §3.2).
- **FELSPIK**: 5xx-andel > 1 % av API-anrop över 15 min, eller ärliga 503
  på en yta som SKA vara aktiv → CRITICAL, åtgärdas före allt annat.
- **TRATTBROTT**: QSDR eller ARR faller > 20 % mot 7-dagarsmedian →
  någonting i flödet gick sönder (release? källändring? myndighetsdrift?) —
  korrelera paneler 8–9.
- **RATE-LIMIT-TRÄFFAR**: legitima användare som slår i registrerings-
  gränsen (delade IP:n) → ompröva gränsen/storen (modellens OBS-flagga vid
  miljonscenariot).

Larmväg: kuratorsnotifieringssystemet som redan finns (inga nya kanaler i
v0); CRITICAL-larm speglas i defektlistan (QUALITY_DASHBOARD vy 1).

## §3 Regler

1. Kontrollrummet **läser** — det skapar aldrig egna sanningar. Varje panel
   pekar på en befintlig källa; saknas källan visas DATA_UNAVAILABLE, inte
   ett tomt nollvärde som ser ut som lugn.
2. RED-listan gäller: inga paneler på individnivå, inga känsliga kategorier
   i spårningen — allt är aggregerade räknare.
3. Modellens scenariovärden får visas som **referenslinjer** (märkta
   HYPOTHESIS) men aldrig som mål eller prognos.
4. Varje larm har en mottagare och en runbook-rad (OPERATIONS.md utökas per
   larm när panelen aktiveras) — larm utan ägare är dekoration.
