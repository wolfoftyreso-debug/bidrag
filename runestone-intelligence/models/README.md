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
