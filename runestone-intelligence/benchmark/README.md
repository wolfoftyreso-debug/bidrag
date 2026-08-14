# RUNEBENCH

Benchmark är grinden för allt: **ingen modell räknas som "bättre" utan
benchmark, och ingen modell går till production utan benchmark-resultat.**

## RUNEBENCH v1 — kategorier

Testsetet är helt separerat från träningen (split på inskriftsnivå,
ADR-0002). Mål: ≥100 testfall per kategori när datamängden tillåter.

| Kat. | Innehåll |
|---|---|
| A | Clean images |
| B | Real field photos |
| C | Low resolution |
| D | Oblique angle |
| E | Damaged inscriptions |
| F | Partial inscriptions |
| G | Low contrast |
| H | Weathered stone |
| I | Unknown stone (id aldrig i träningen — mäter generalisering) |
| J | Long inscriptions |
| K | Rare rune forms |
| L | Non-Viking inscriptions |

## RUNEBENCH-BASELINE

Byggs från det multimodala datasetet (2 615 par) — men **inte** med
datasetets inbyggda eval/few-shot-struktur; vår egen sten-nivå-split gäller.
Benchmarkstege: Generic VLM → Gemma baseline → Fine-tuned Gemma →
Specialized Rune Vision → +retrieval → +language reasoning.

## RUNEBENCH-GOLD

Mindre, manuellt verifierat dataset, kvalitetssäkrat mot auktoritativa
källor. Ingen automatisk datasetimport blir ground truth utan kontroll
(`gold=true` kräver `verified_by`, maskinellt enforcerat). Detta är den
slutliga sanningskällan för modellutvärdering.

## Metrics

| Metric | Mäter |
|---|---|
| Character Error Rate | runläsning |
| Rune Accuracy | per tecken |
| Sequence Accuracy | hela inskriften rätt |
| Transliteration CER | translitterering |
| Word Error Rate | ordnivå |
| Normalization accuracy | normalisering |
| Translation similarity | översättning |
| Stone identification accuracy | känd sten |
| **Calibration** | confidence vs faktisk correctness |
| **Abstention quality** | hur bra modellen säger "jag vet inte" — officiellt KPI |

## Testfallsformat

`data-contracts/schemas/benchmark-case.schema.json`. Fall med
`expected.abstention_expected=true` mäter att systemet hellre svarar
"Otillräcklig bildkvalitet" än hallucinerar.

## Initiala KPI-mål

Rune recognition ≥95 % (clean), transliteration ≥90 % sequence-level
(välbevarade), known-stone identification ≥95 %, translation acceptability
≥95 % (human-reviewed, tydliga inskrifter).
