# Atlas — Runestone Atlas-tjänsten

Observationslagret: geospatial databas över verkliga runstenar med
longitudinell observationshistorik. Full beskrivning i `docs/ATLAS.md`;
besluten i ADR-0006 och ADR-0007.

## Ansvar

- **Stone store:** `stone`-objekt (kända + kandidater) med position, skick,
  `condition_timeline` och observationsräknare.
- **Observation store:** `field-observation`-poster från mobilflödet, med
  GPS, enhetsmetadata, samtycke och verifieringsstatus.
- **Stone matching:** kombinerad identity score (visual + GPS + inscription
  + geometry + known location). GPS ensam kan aldrig ge match — enforceras
  av data contracts.
- **Verifieringstrappa:** `unverified → model_verified → database_matched →
  human_verified → scholar_verified`; höjning sker via annotation-verktyget
  eller matchern, alltid med `verified_by`.
- **Scan coverage:** härledd vy (användare/foton/datum/kameror per sten +
  stenar utan moderna observationer) → fältuppdrag.
- **Change detection (senare):** jämför observationer över tid, flaggar
  `change_detected` som hypotes för mänsklig verifiering.

## Explore (ADR-0009)

`explore.py`: **NÄSTA RUNSTEN** (närmaste stenar med avstånd + gång-/körtid,
seen-flaggning, radiefilter) och **RUNESTONE TRAIL** (girig
närmaste-granne-slinga med total längd och tidsestimat). Exponeras via
`POST /v1/explore`. Deterministisk fågelvägsgeometri — riktig ruttning är
en senare integrationsfråga.

## Gränssnitt

- Skrivs till av inference-pipelinen (varje analyserat foto med samtycke).
- Läses av retrieval/identification (GPS → nearby known stones) och av
  training (Layer F-kandidater med `training_use`-samtycke).
- Exponeras senare som karta/coverage-vyer — inte en del av V1-UI:t.

Datakontrakt: `data-contracts/schemas/stone.schema.json`,
`field-observation.schema.json`. Implementation byggs efter Data Foundation
v0.1 (lagring: PostgreSQL + PostGIS enligt `deployment/`).
