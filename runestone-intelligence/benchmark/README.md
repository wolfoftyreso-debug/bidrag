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

## Implementerat (Sprint 3)

| Modul | Gör |
|---|---|
| `metrics.py` | CER, WER, rune accuracy, sequence accuracy, calibration (ECE) och abstention-metrics (true abstentions, **false confidence**, over-abstentions, F1). Odefinierade mätningar blir `null`, aldrig fejkade nollor |
| `build_benchmark.py` | Corpusversion → benchmarkfall. Endast test-/unknown-stone-partitioner (träningsstenar kan inte läcka in); deterministisk kategorisering I/C/J/A; unknown-stone-fall döljer identiteten (`inscription_id`/`signum` = null); `gold=false` alltid — promotion sker manuellt |
| `evaluate.py` | Cases + predictions → rapport med totalmetrics, per kategori och per fall. Saknade predictions rapporteras som `missing`, aldrig tyst. Metrics-blocket har samma nycklar som `model-registry-entry.benchmark_results.metrics` — resultatet kopplas direkt till registret |

Kategorierna B/D/E/G/H/K/L kräver bildannotering och sätts via
annotation-verktyget; builderns automatiska regler täcker I (unknown stone),
C (lågupplöst), J (lång inskrift) och A (default).

## Körning

```bash
python3 build_benchmark.py --corpus /tmp/corpus-v0.1 --out /tmp/runebench --version v1
python3 evaluate.py --cases /tmp/runebench/cases.jsonl \
  --predictions predictions.jsonl --out report.json --version v1
python3 -m unittest discover -s tests   # 15 tester
```

Predictionsformat, en rad per fall:
`{"case_id": "rb-...", "transliteration": "...", "confidence": 0.93, "abstained": false}`

## Initiala KPI-mål

Rune recognition ≥95 % (clean), transliteration ≥90 % sequence-level
(välbevarade), known-stone identification ≥95 %, translation acceptability
≥95 % (human-reviewed, tydliga inskrifter).
