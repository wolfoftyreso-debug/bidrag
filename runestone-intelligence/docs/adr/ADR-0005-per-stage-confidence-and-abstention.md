# ADR-0005: Confidence per steg och abstention som förstaklassfunktion

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

En sammanlagd confidence-siffra kan maskera att en enskild komponent (t.ex.
runigenkänning på en skadad yta) är mycket osäker. Historiska tolkningar kan
dessutom vara vetenskapligt omtvistade — en maskinell tolkning får aldrig
presenteras som etablerad när källorna är oense.

## Beslut

1. Varje pipelinesteg rapporterar egen confidence (image quality, stone id,
   detection, rune recognition, transliteration, normalization, retrieval,
   translation). Aggregat får aldrig maskera svaga delkomponenter.
2. Osäkerhet på runnivå exponeras med kandidater och sannolikheter
   (`Rune 14: ᚢ 61 %, ᚦ 29 %, damaged 10 %`).
3. Abstention är ett officiellt KPI: systemet ska hellre svara
   "Otillräcklig bildkvalitet" än leverera en falskt säker översättning.
   Kalibrering (confidence vs faktisk correctness) mäts i RUNEBENCH.
4. Vetenskaplig statusklassning på varje resultat:
   `Established | Probable | Uncertain | Alternative readings | Insufficient evidence`.
5. Avvikelse mellan visuell läsning och kanonisk inskrift (`MATCH: LOW`)
   triggar alternativ analys, aldrig tyst övertäckning.

## Konsekvenser

- UX:en måste kunna visa per-runa-osäkerhet (design i `docs/PRODUCT.md`).
- Benchmark får två extra metricfamiljer: calibration och abstention quality.
- Systemet blir mindre "imponerande" i svaga fall — det är avsikten.
