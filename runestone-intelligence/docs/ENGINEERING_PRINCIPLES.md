# Engineering principles

Projektets tolv regler. De är inte ambitioner — de är constraints som
enforceas i kod, CI och review.

1. **Git är source of truth.** Ingen manuell produktion direkt i buckets.
2. **Datasets är versionshanterade** och immutable (`corpus-v0.1`, `corpus-v0.2`, ...).
3. **Alla data har provenance** (`data-contracts/schemas/provenance.schema.json`, CI-validerad).
4. **Alla modeller har reproducerbar träningsmetadata:** `model_version`,
   `dataset_version`, `code_commit`, `training_config`, `base_model`,
   `hyperparameters`, `gpu_environment`, `evaluation_version`.
5. **Ingen production-modell utan benchmark.** Registry-status
   `PRODUCTION`/`STAGING` kräver benchmark-resultat (valideras maskinellt).
6. **Ingen hallucinerad läsning betraktas som ground truth.**
7. **Osäkerhet exponeras** — per steg, per runa; abstention är ett KPI.
8. **Originaldata muteras aldrig** — berikning sker i nya versioner med
   `modification_status`-spårning.
9. **Extern data licensklassificeras innan träning.**
10. **Train/test-split sker på sten-/inskriftsnivå**, aldrig på bildnivå.
    Dessutom ett separat UNKNOWN-STONE TEST SET för generalisering.
11. **Alla modeller kan återkallas till exakt datasetversion och Git-commit.**
12. **Specialiserad modell ska bevisas bättre än generell baseline innan
    komplexiteten ökas.**
