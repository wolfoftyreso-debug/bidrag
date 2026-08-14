# ADR-0006: Runestone Atlas är en förstaklassprodukt från Sprint 0

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

Varje foto som skickas in för översättning bär mer information än frågan
"vad står det?": position, tidpunkt, kamera, väder, skick. Samlat över tid
blir det en longitudinell, geospatial observationsdatabas över verkliga
runstenar — potentiellt lika värdefull som modellen själv, och grunden för
scan coverage (fältuppdrag), förändringsdetektion och upptäckt av luckor i
befintliga register.

Att efterinstallera ett observationslager är dyrt; att bära det från början
är billigt — det är samma provenance-arkitektur som corpus redan använder.

## Beslut

1. Systemet har två produkter: **Runstenläsaren** (V1-UI:t) och **Runestone
   Atlas** (observationslagret). V1-användaren ser fortfarande bara
   Fota → Läs → Översätt.
2. `stone` och `field-observation` är förstaklassobjekt i data contracts
   från Sprint 0, med GPS, samtycke, verifieringsstatus och provenance.
3. Varje analyserat foto skapar (med samtycke) en fältobservation kopplad
   till ett stenobjekt — känt eller kandidat (`candidate_unknown`).
4. Okända stenar blir Unknown Runestone Observations som kan matchas senare;
   kandidater som visar sig kända märks `merged`, historiken bevaras.
5. Skickhistorik (`condition_timeline`) modelleras från start som grund för
   förändringsdetektion; larm är modellhypoteser tills mänskligt verifierade.
6. Scan coverage är härledd data (beräknas ur observationer), aldrig en egen
   sanningskälla.

## Konsekvenser

- Ingestion-, API- och mobilflödena skriver observationer från dag ett;
  ingen senare migrering av "gamla foton utan metadata".
- Samtyckeshantering (per observation, versionshanterad) måste finnas i V1:s
  fotoflöde även om atlasen inte syns i UI:t.
- Datamoat-komponent 3 (field dataset) får en konkret datamodell i stället
  för en ambition.
