# ADR-0002: Train/test-split på sten-/inskriftsnivå, aldrig bildnivå

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

Samma runsten förekommer ofta i flera fotografier (olika vinklar, år,
fotografer). En random split på bildnivå lägger samma sten i både train och
test — modellen kan då memorera stenen i stället för att lära sig läsa runor,
och benchmarksiffrorna blir systematiskt för optimistiska.

Det befintliga multimodala datasetet (2 615 par) innehåller en egen liten
eval/few-shot-struktur; den är inte byggd för vårt syfte och får inte
återanvändas som vår split.

## Beslut

1. All split sker på **STONE / INSCRIPTION ID** (signum/inskrifts-id) —
   alla bilder av samma sten hamnar i samma partition.
2. Ett separat **UNKNOWN-STONE TEST SET** skapas: stenar vars id aldrig
   förekommer i träningen, för att mäta äkta generalisering.
3. Datasetmanifest deklarerar sin splitpolicy maskinläsbart
   (`dataset-manifest.schema.json`: `split_policy.unit = "inscription_id"`)
   och valideras i CI.

## Konsekvenser

- Benchmark-resultat mäter läsförmåga, inte igenkänning av memorerade stenar.
- Stone Identification Engine utvärderas separat — där är igenkänning målet.
- Färre effektiva testbilder per kategori; kompenseras med syntetisk data
  (Layer E) där facittexten är känd.
