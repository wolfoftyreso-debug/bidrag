# QUALITY DASHBOARD SPEC — intern kvalitetskontroll

Mål (§46): en intern yta där kvalitetsläget syns i realtid, med målet
**0 critical defects**. Status: spec (backlog M10) — meningsfull fullt ut
först efter deploy när fältdata finns; datakällorna byggs redan nu.
Lanseringspanelerna (trafik, tratt/QSDR/ARR, myndighetsbelastning, spiklarm)
specas separat i `docs/LAUNCH_CONTROL_ROOM.md` och delar byggväg med denna.

## Datakällor (finns idag → matas in)

| Signal | Källa (finns) |
|---|---|
| Indexerbara sidor, titlar/desc/canonical/schema-fel, orphans, sitemap-diff | tools/seocheck.mjs (körs i verify/CI — gör exit-koden till datapunkt) |
| Ordmängd, moduler, länkdjup, ankartexter, sidvikt, render-block | tools/seoaudit.mjs → artifacts/seo-audit.json |
| Datalager i synk (keywords/queries/kunskapsgraf/manual) | --check-verktygens exitkoder |
| Källfärskhet + källdiffar | source-fetch-jobbet (snapshot/diff var 6:e timme) + curator-reminders |
| Stale matches | stale-match-recalc-jobbet |
| Testhälsa | verify (14 steg), CI, uicheck/demo-checks |

## Tillkommer efter deploy

GSC coverage/fel · CWV-fältdata mot målen i SEO_RELEASE_GATE · extern
länkhälsa (M8) · brand-SERP-status (§28) · användarfeedback per kategori
(H1: fakta/språk/navigering/saknas/tekniskt) · visuell regression (M6).

## Vyer

1. **Defektlistan** (huvudvyn): CRITICAL/HIGH öppna, per lager — tom lista är
   målbilden. Speglar PERFECTION_BACKLOG maskinellt.
2. **Sidhälsa**: per publik sida — moduler, CAS/Perfection Score (§47),
   källstatus, senast kontrollerad, feedbackvolym; sorterbar på "sämst först".
3. **Källhälsa**: källor med diff sedan senaste granskning; äldsta
   "senast verifierad"; flaggan "Källan har förändrats sedan senaste kontroll".
4. **Trend**: verify-/CI-historik, audit-siffror över tid (audit-json:erna
   är daterade artefakter — behåll dem).

## Byggväg

v0 = statisk rapport genererad ur ovanstående JSON-källor (samma mönster som
seoaudit) och läsbar i admin-vyn; v1 = levande vy i appens admin med
jobbstatus; larm via kuratorsnotifieringarna som redan finns. Ingen ny
infrastruktur förrän v0 visat vilka signaler som faktiskt används.
