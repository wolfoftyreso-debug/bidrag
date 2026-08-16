# RUNESTONE DATA FOUNDATION — statusrapport v0.1

**Datum:** 2026-08-16 · **Branch:** `claude/runestone-intelligence-project-bavh3w`

Sammanfattning av vad som är byggt, verifierat och blockerat. Detta är
"första leveransen" enligt plan §53 — med den ärliga kvalificeringen att
allt är byggt och testat **mot syntetiska fixturer**; skarp data väntar på
spärrarna nedan.

## Byggt och CI-grindat (10 testsviter, ~200 tester)

| Komponent | Status | Nyckelgaranti |
|---|---|---|
| Data contracts (10 scheman) | ✅ | Provenance obligatorisk; split på stennivå schematekniskt tvingad; gold kräver manuell verifiering; production-modell kräver benchmark; L2/L3 spårbara till L1 |
| Atlas-kontrakten | ✅ | Verifieringstrappa, samtycke per observation, GPS-signal-regeln maskinell |
| Ingestion-motorn | ✅ | SRD-, HF-, Runor- och Wikimedia-importers; idempotens; motstridiga dubbletter → granskningskö; berikning muterar aldrig, loggas per fält; licenswhitelist (okänd ⇒ aldrig träningsbar) |
| Corpusbygge + versionering | ✅ | Deterministisk (explicit timestamp+seed ⇒ bit-identisk output); immutabla manifest; unknown-stone-holdout stabil över versioner |
| Coverage-/gaprapport | ✅ | De sex strategiska datafrågorna besvaras maskinellt per corpusversion |
| RUNEBENCH + evaluering | ✅ | CER/WER/kalibrering/abstention; träningsstenar kan inte läcka in; false confidence mäts explicit; rapport kopplas direkt till modellregistret |
| Baseline-runner | ✅ | Diagnostiska golv (oracle/abstain/constant) + HTTP-VLM-adapter (Gemma via vLLM/Ollama); adaptern ljuger aldrig åt modellens fördel |
| Retrieval (RuneKnowledge v0.1) | ✅ | Trigram+edit på läsning, GPS-närhet som signal, evidens per kandidat, gps_only kan aldrig identifiera |
| Verifiering (RuneVerifier v0.1) | ✅ | MATCH HIGH/MEDIUM/LOW, positionsvisa avvikelser, vetenskaplig status nedgraderas men förbättras aldrig |
| Översättning (RuneTranslation v0.1) | ✅ | Kedjan runor→translitterering→normalisering→svenska; policyn canonical→formulaic→abstain; mismatch översätts aldrig |
| Identity Lock + trenivåmodellen | ✅ | ≥0.95 lock / 0.70–0.95 review / <0.70 fallback; L1 orörd, L2 semantik, L3 emotion-first med STYLE_SPEC |
| API-orkestrering | ✅ | `POST /v1/analyze` (+ research mode, explore, trail, kartfeed); confidence = min över mätbara steg; abstention som 422; image quality-gate v0 |
| Kartvyn | ✅ | GeoJSON-feed + Mapbox-demoklient; licensspärr för publika foton; kontolös avbockning; vägbeskrivningslänkar |
| Master-vyn | ✅ | Ett kunskapsobjekt per sten; muterar aldrig L1; vägrar blanda stenar |
| Deployment | ✅ | Dockerfile + K8s-manifest med testade driftinvarianter; CI bygger imagen och smoke-testar |

## Skarpa spärrar (utanför koden — i prioritetsordning)

1. **Uppsala-rapporteringen.** Användningen av Scandinavian Runic-text
   Database ska rapporteras formellt innan skarp import (`docs/LICENSES.md`).
   *Ägare: människa. Blockar: allt skarpt corpusarbete.*
2. **Skarpa källadaptrar.** SRD-distributionens filformat, K-samsöks
   JSON-LD-API och Commons API — kontraktsytorna är fastlagda i respektive
   importer; endast parsning tillkommer.
3. **Bild- och koordinatskörd.** Nedladdning till object storage med
   rights records; coverage-rapporten mäter framsteget.
4. **Serverad vision-modell.** Gemma/VLM-endpoint för skarp Phase 1-baseline
   (`http_vlm` är klar att peka om).
5. **MVP-stenarna.** Välj 10–20 välkända stenar (turiststråk:
   Gamla Uppsala/Sigtuna/Vallentuna/Täby), säkra foton+koordinater+texter,
   och mät WOW-måttet: *fotograferar personen en andra sten?*

## Beslutspunkter för nästa fas

- **Gate 1 (Phase 1-frågan):** kör generell VLM mot RUNEBENCH på skarpa
  bilder. Slår en specialiserad modell den? Om nej — analysera innan mer
  komplexitet byggs (princip 12).
- **Mobilklient:** endpoints (`analyze`, `explore`, `trail`, `map`) är
  stabila nog att bygga mot; kartreferensklienten visar kontraktet.
- **LLM-generatorn för L3:** STYLE_SPEC är klar; kör den mot verifierade
  översättningar när modellval/budget är beslutat. Renderaren är fallback.

## Reproducerbarhet

Allt i denna rapport kan återskapas från repot: `python3 -m unittest
discover -s tests` i varje katalog, `build_corpus.py` mot fixturer ger
bit-identisk output för samma input, och CI kör hela kedjan inklusive
Docker-smoke på varje push.
