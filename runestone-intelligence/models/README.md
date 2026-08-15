# Models — modellregister

Varje modell registreras enligt
`data-contracts/schemas/model-registry-entry.schema.json` med komplett
reproducerbarhetsmetadata: `model_version`, `dataset_version`, `code_commit`,
`training_config`, `base_model`, `hyperparameters`, `gpu_environment`,
`evaluation_version`.

## Statusflöde

```
TRAINING → CANDIDATE → BENCHMARKED → STAGING → PRODUCTION → RETIRED
```

`BENCHMARKED`/`STAGING`/`PRODUCTION` kräver `benchmark_results` — maskinellt
enforcerat i valideringen. Varje modell kan alltid återkallas till exakt
datasetversion och Git-commit.

## Planerade modeller

`runestone-vision-x.y` (kärnmodellen), image quality, inscription detector,
rectification, stone identification, translation. Se `docs/ARCHITECTURE.md`.

## Baseline-runner (Sprint 4, Phase 1)

| Modul | Gör |
|---|---|
| `adapters.py` | Adapterinterface + tre diagnostiska baselines: `oracle` (harness-sanity — ska ge seq acc 1.0), `abstain` (abstention-golv), `constant` (prior-golv: train-partitionens vanligaste translitterering, ärligt låg confidence). Alla flaggade `is_diagnostic` — de är mätstickor, aldrig "baseline-resultat" |
| `http_vlm.py` | Riktig baseline: OpenAI-kompatibel endpoint (Gemma via vLLM/Ollama) med bild + strikt JSON-prompt. Konfig via `VLM_ENDPOINT`/`VLM_MODEL`/`VLM_API_KEY`. Saknad bild, ogiltigt svar eller transportfel blir abstention med orsak — aldrig en gissning åt modellens fördel |
| `run_baselines.py` | Kör valda adaptrar mot RUNEBENCH-fall → predictions + rapport per adapter + `summary.md`-jämförelse (Baseline Report) |

```bash
python3 run_baselines.py --cases <runebench>/cases.jsonl \
  --corpus <corpus-dir> --out-dir /tmp/baselines \
  --adapters abstain,constant,http_vlm --images-dir <bilder> --include-oracle

python3 -m unittest discover -s tests   # 13 tester
```

Phase 1-frågan (plan §44) besvaras här: kör `http_vlm` (generell VLM/Gemma)
och senare den specialiserade modellen mot **samma fall** — den
specialiserade måste vinna för att motivera vidare komplexitet (princip 12).
Skarp VLM-körning kräver en serverad modell och nedladdade benchmarkbilder;
allt övrigt är på plats.
