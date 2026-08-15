# Roadmap

Byggordning: **DATA FOUNDATION → CORPUS → PROVENANCE → BENCHMARK → BASELINE**
→ först därefter egen modellträning.

## Första tekniska målet

Inte "kan vi översätta runor?" (det finns data för det), utan:

> **Kan en specialiserad visionmodell slå en generell multimodal modell på
> fotografier av riktiga runinskrifter?**

Ja → projektet har en teknisk kärna. Nej → analysera varför innan vi bygger
vidare.

## Leveransordning

1. **RUNESTONE DATA FOUNDATION v0.1** — canonical corpus, image corpus,
   provenance, licensing, source mapping, benchmark, train/val/test-split,
   baseline evaluation, första error analysis.
2. **RUNEVISION v0.1**
3. **RUNEVERIFIER v0.1**
4. **RUNESTONE MOBILE v1.0**

## Sprintplan

| Sprint | Namn | Leverans |
|---|---|---|
| 0 | **Discovery** *(klar)* | Datainventering, licensinventering, source mapping, dataset schema, benchmark definition, ADR:er — inkl. **Atlas-kontrakten** (stone, field-observation, samtycke, verifieringstrappa; ADR-0006/0007). **Ingen modellträning.** |
| 1 | **Corpus ingestion** *(pågår)* | Rundata/SRD-importer, Runor metadata-importer, K-samsök-connector, image provenance pipeline, dataset versioning → **Runestone Corpus v0.1**. Motorn (signum, SRD-/HF-importers, matcher, split, manifest, e2e-CLI) är byggd och testad mot fixturer; skarp körning väntar på Uppsala-rapportering + källformatadapter |
| 2 | Image corpus | Licensierade bilder, Wikimedia (där licens tillåter), RAÄ-data (där användning tillåts), befintliga multimodala dataset → **Image Corpus v0.1** |
| 3 | **Benchmark** *(harness klart)* | **RUNEBENCH** + **RUNEBENCH-GOLD** + automatiserad evaluation. Ingen modell räknas som "bättre" utan benchmark. Metrics, casebygge och evalueringsharness är byggda och testade; skarpa testfall väntar på riktig corpusdata (Sprint 1-spärrar) och bildannotering för kategorierna B/D/E/G/H/K/L |
| 4 | **Baseline models** *(runner klar)* | Generic VLM, Gemma baseline, OCR/HTR-pipeline, specialized sequence baseline → **Baseline Report v0.1**. Adapterramverk, diagnostiska golv (oracle/abstain/constant), HTTP-VLM-adapter och rapportgenerator byggda och testade; skarp VLM-körning kräver serverad modell + benchmarkbilder |
| 5 | Rune Vision | Första specialiserade runläsaren → **RuneVision v0.1** |
| 6 | **Retrieval** *(v0.1 klar)* | image reading → text retrieval → candidate ranking → **RuneKnowledge v0.1**: trigram+editavstånd på läsning, GPS-närhet som signal, filter, evidens per kandidat, gps_only-flagga |
| 7 | **Verification** *(v0.1 klar)* | Cross-check model reading vs known inscription → **RuneVerifier v0.1**: MATCH HIGH/MEDIUM/LOW, positionsvisa avvikelser, alternativ analys vid LOW, vetenskaplig status nedgraderas men förbättras aldrig |
| 8 | **Translation** *(v0.1 klar)* | runic → transliteration → normalization → Swedish → **RuneTranslation v0.1**: runmappning (yngre futharken), seed-lexikon för normalisering, policykedja canonical → formulaic → abstain; mismatch översätts aldrig |
| 9 | Synthetic data | 3D-integrering; tusentals/miljontals syntetiska variationer med känd facittext → **Synthetic Rune Corpus v0.1** |
| 10 | Field test | ≥25 stenar, flera provinser, olika väder/ljus/kameror/avstånd — första skarpa Atlas-observationerna med full samtyckes- och verifieringskedja |
| 11 | Hardening | Latency, GPU-kostnad, failure modes, confidence-kalibrering, minne, concurrency, API-stabilitet. API-orkestreringen (`POST /v1/analyze` med pluggbar läsare, confidence-min-aggregat, 422-abstention, Atlas-observationer med samtycke) är byggd och testad i förväg |
| 12 | **Public MVP** | Endast **Fota → Läs → Översätt**; backend redan byggd för hela arkitekturen |

## Träningsstrategi (Phase 1–8)

Baseline → specialiserad runigenkänning → full inscription model → retrieval
→ translation → synthetic augmentation → field adaptation → continuous
training (misslyckanden blir nya träningsfall).

## Första KPI:er

| KPI | Mål |
|---|---|
| Rune recognition | ≥95 % character-level accuracy (clean benchmark) |
| Transliteration | ≥90 % sequence-level correctness (välbevarade inskrifter) |
| Known-stone identification | ≥95 % (kända benchmarkstenar) |
| Translation | Human-reviewed acceptability ≥95 % (tydliga inskrifter) |
| **Abstention** | Hellre "Otillräcklig bildkvalitet" än falskt säker översättning — officiellt KPI |

## Kostnadsstrategi

```
small model → benchmark → error analysis → targeted data → larger model
```

Inte: köp GPU-kapacitet → träna stort → hoppas. GPU-workers skalas efter
behov; inference optimeras separat från träning.

## Långsiktig expansion

```
Swedish runestones → Scandinavia → Elder Futhark → Younger Futhark
→ Medieval runes → Anglo-Saxon runes → Germanic runic corpus
```

Slutprodukten är inte "Swedish Runestone Translator" utan **Runic Vision
Intelligence**.

## Långsiktig datamoat

1. Specialized model (runformer + stenbilder)
2. Canonical corpus (strukturerad runologisk kunskapsbas)
3. Field dataset (riktiga mobilbilder andra saknar) — realiseras som
   **Runestone Atlas** med observationshistorik, scan coverage och
   förändringsdetektion (`docs/ATLAS.md`)
4. **Error corpus** (alla fall där systemet haft svårt — potentiellt extremt värdefullt)

Atlas-loopen gör systemet självförstärkande: corpus → modell → app → foton
→ verifierad fältdata → bättre dataset → omträning.
