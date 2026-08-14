# ADR-0003: Obligatorisk provenance och per-bild rights records

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

Datagrunden blandar källor med olika villkor: Runor/K-samsök (metadata CC0,
bildrättigheter varierar per leverantör), Uppsala-databasen
(rapporterings- och källhänvisningskrav), HF-datasetet (CC BY-SA 4.0 på
datasetnivå men individuella bildlicenser), Wikimedia (per fil), 3D-modeller
och framtida fältdata (samtyckesbaserad). Antagandet
"kulturarvsdata = fria bilder" är fel och juridiskt riskabelt.

## Beslut

1. Inget objekt tas in i corpus utan komplett provenance-record:
   `dataset_id, source, source_url, source_record_id, license, creator,
   attribution, modification_status, download_timestamp, dataset_version,
   checksum`.
2. Varje bild har en egen rights record: `image_id, original_url,
   local_object, license, photographer, source_institution, resolution,
   orientation` + användningsflaggor (träning/redistribution).
3. Scheman är maskinläsbara (`data-contracts/schemas/`) och valideras i CI —
   ingestion-pipelines får inte skriva objekt som inte validerar.
4. Originaldata muteras aldrig; berikning ger nya versioner med
   `modification_status`.

## Konsekvenser

- Licensläget för varje träningsexempel är alltid avgörbart maskinellt.
- Extern data kan aldrig oavsiktligt blandas in i proprietär IP.
- Något högre ingestionkostnad per källa — accepterat och obligatoriskt.
