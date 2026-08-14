# Ingestion

Importers som bygger Runestone Corpus v0.1 (Sprint 1). Gemensam regel: en
importer får inte skriva ett objekt som inte validerar mot data contracts —
valideringen (`data-contracts/validator.py`) körs i pipelinen, inte bara i CI.

## Planerade importers

| Importer | Källa | Output |
|---|---|---|
| `srd_importer` | Scandinavian Runic-text Database (Uppsala) | `inscription`-poster, Layer A |
| `runor_importer` | Runor-metadata (RAÄ), ~7 200 inskrifter | berikning: geografi, rapporter, kopplade objekt |
| `ksamsok_connector` | K-samsöks API | kulturarvsobjekt + bildreferenser |
| `hf_runestones_importer` | Scandinavian Runestone Inscriptions (2 615 bild/text-par) | `image-rights` + parade inskriftsreferenser, Layer B/C |
| `wikimedia_harvester` | Wikimedia Commons | bilder med per-fil licensklassning |
| `matcher` | — | automatisk matchning `signum ↔ inscription ↔ image ↔ source ↔ license` (STEG 7) |

## Pipelineordning (STEG 4–7)

1. Importera SRD → canonical inskrifter med obligatorisk provenance.
2. Importera Runor/K-samsök-metadata → berika, behåll `modification_status`.
3. Importera 2 615-bilddatasetet → per-bild rights records
   (datasetnivå CC BY-SA 4.0; bildlicenser individuella).
4. Kör matchern → corpuskopplingar; omatchade objekt hamnar i en
   granskningskö, de gissas aldrig ihop.

## Krav på varje importer

- Deterministisk och omkörningsbar (idempotent per `source_record_id`).
- Skriver rådata oförändrad till `raw/` + checksummad (`sha256:`).
- Fullständig provenance per post; licens klassad innan objektet blir
  träningskandidat (`rights_status=unknown` ⇒ `training_allowed=false`).
- Loggar avvisade poster med valideringsfel — avvisningar är datainventering.
