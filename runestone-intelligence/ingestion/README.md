# Ingestion

Motorn som bygger Runestone Corpus (Sprint 1, STEG 4–7). Gemensam regel: en
importer får inte skriva ett objekt som inte validerar mot data contracts —
valideringen (`data-contracts/validator.py`) körs i pipelinen, inte bara i CI.

## Implementerat

| Modul | Gör |
|---|---|
| `signum.py` | Signum-normalisering: `"U 9001"`, `"u9001"`, `"  u  9001"` → nyckel `u:9001`; †-markering blir `lost`-metadata; okända provinskoder avvisas hellre än gissas |
| `srd_importer.py` | SRD-export → canonical `inscription`-poster med obligatorisk provenance och `source_database`/`source_provider` (ADR-0004). Idempotent per signum; motstridiga dubbletter går till granskningskö, skriver aldrig över |
| `hf_importer.py` | 2 615-bilddatasetet → `image-rights` med per-bild licensklassning via whitelist — allt oigenkänt blir `unknown` + `training_allowed=false`. Sätter aldrig `inscription_id` själv |
| `matcher.py` | STEG 7: verifierar källans påstådda signum-koppling mot corpus. Utfall: matched / unmatched (granskningskö) / ambiguous. Gissar aldrig |
| `versioning.py` | Deterministisk hashbaserad split på `inscription_id` (ADR-0002) med `unknown_stone_test`-holdout; stabil när nya stenar tillkommer. Immutable manifest med checksumma |
| `build_corpus.py` | End-to-end CLI: import → matchning → split → manifest → review queue → rapport. Timestamp och seed ges explicit ⇒ bit-identisk output för samma input |

## Körning

```bash
python3 build_corpus.py \
  --srd fixtures/srd_sample.jsonl \
  --images fixtures/hf_sample.jsonl \
  --out /tmp/corpus-v0.1 --version v0.1 \
  --timestamp 2026-08-15T00:00:00Z --seed 20260815

python3 -m unittest discover -s tests   # 22 tester
```

Output: `inscriptions.jsonl`, `images.jsonl`, `manifest.json`, `split.json`,
`review_queue.json`, `report.json`.

## Fixturer, inte riktig data

Pipelinen körs mot syntetiska fixturer (`fixtures/`, signumnummer 9001+
existerar inte i verkliga korpusar) tills två spärrar är lösta:

1. Formell rapportering av användningen till Uppsala universitet
   (`docs/LICENSES.md`).
2. Adapter till den verkliga SRD/Rundata-distributionens filformat —
   kontraktsytan (validering, provenance, idempotens) är redan fastlagd,
   endast parsningen av källformatet tillkommer.

Riktig data lagras i object storage, aldrig i Git.

## Kvarstående importers (Sprint 1–2)

`runor_importer` (RAÄ-metadata, ~7 200 inskrifter), `ksamsok_connector`
(kulturarvsobjekt + bilder), `wikimedia_harvester` (per-fil licensklassning).

## Krav på varje importer

- Deterministisk och omkörningsbar (idempotent per `source_record_id`).
- Skriver rådata oförändrad till `raw/` + checksummad (`sha256:`).
- Fullständig provenance per post; licens klassad innan objektet blir
  träningskandidat (`rights_status=unknown` ⇒ `training_allowed=false`).
- Loggar avvisade poster med orsak — avvisningar är datainventering.
