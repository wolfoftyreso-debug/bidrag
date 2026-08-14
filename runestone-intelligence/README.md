# Runestone Intelligence

**Fota stenen. Systemet läser vad som står.**

Ett produktionshärdat system som från ett vanligt fotografi av en runsten
identifierar, lokaliserar och läser runinskriften, translittererar den, tolkar
den mot en auktoritativ runologisk kunskapsbas och presenterar en
källförankrad svensk översättning med tydlig osäkerhetsredovisning.

Detta är **inte** en wrapper runt en generell multimodal modell och **inte**
en chatbot som vet mycket om runor. Det är ett visuellt lässystem med en
runologisk kunskapsbas och verifieringsmotor bakom sig.

Systemet har **två produkter** (ADR-0006):

1. **Runstenläsaren** — fota → läs → översätt (det användaren ser i V1).
2. **Runestone Atlas** — en kontinuerligt växande, geospatial
   observationsdatabas över verkliga runstenar: position, skick, bilder och
   longitudinell observationshistorik. Se `docs/ATLAS.md`.

## Positionering

Riksantikvarieämbetets **Runor** (~7 200 registrerade inskrifter) och Uppsala
universitets **Scandinavian Runic-text Database** finns redan — vi konkurrerar
inte med databasen, vi använder den som kunskapsinfrastruktur. Vår
differentiering är att **bilden är själva ingången**:

> "Vi har byggt ett system som kan läsa en verklig runsten från ett fotografi."

## Pipeline (aldrig IMAGE → free-form answer)

```
MOBILFOTO → IMAGE QUALITY → INSCRIPTION DETECTION → RECTIFICATION
→ RUNE VISION MODEL → RUNIC SEQUENCE → TRANSLITERATION → NORMALIZATION
→ KNOWLEDGE RETRIEVAL → INTERPRETATION → VERIFICATION → SVENSK ÖVERSÄTTNING
→ CONFIDENCE + UNCERTAINTY → RESULTAT
```

Mellan bild och svar finns alltid ett lager av **strukturerad evidens**.

## Status

**Fas: Sprint 0 — Discovery / Data Foundation.** Ingen modellträning ännu.
Första leveransen är `RUNESTONE DATA FOUNDATION v0.1` (corpus, provenance,
licensing, benchmark, baseline) — inte appen. Se `docs/ROADMAP.md`.

## Repolayout

| Katalog | Innehåll |
|---|---|
| `docs/` | Produktdefinition, arkitektur, datainventering, licenser, roadmap, ADR:er |
| `data-contracts/` | JSON-scheman för inskrifter, provenance, bildrättigheter, dataset, benchmark, modellregister — med körbar validering och tester |
| `datasets/` | Datasetlagren A–F och versioneringspolicy (immutable, `corpus-vX.Y`) |
| `ingestion/` | Importers: Scandinavian Runic-text Database, Runor/K-samsök, multimodala datasetet (2 615 par) |
| `annotation/` | Internt annoteringsverktyg (modellen föreslår, människan verifierar) |
| `benchmark/` | RUNEBENCH v1 + RUNEBENCH-GOLD: kategorier, metrics, splitregler |
| `models/` | Modellregister och modellkort |
| `training/` | Träningskonfigurationer och reproducerbarhetsmetadata |
| `inference/` | Inference-workers och optimering |
| `knowledge/` | Canonical corpus + retrieval (Runestone Intelligence Corpus) |
| `atlas/` | Runestone Atlas: stenobjekt, fältobservationer, stone matching, verifieringstrappa, scan coverage |
| `verification/` | Cross-check: observerad läsning vs kanonisk inskrift |
| `api/` | OpenAPI-kontrakt: `POST /v1/analyze` + interna endpoints |
| `deployment/` | AWS/Kubernetes-arkitektur, GitOps |

## Icke förhandlingsbara regler

Se `docs/ENGINEERING_PRINCIPLES.md`. De viktigaste:

1. Git är source of truth; datasets är versionshanterade och immutable.
2. All data har provenance; extern data licensklassificeras **innan** träning.
3. Ingen production-modell utan benchmark; ingen hallucinerad läsning blir ground truth.
4. Train/test-split sker på **sten-/inskriftsnivå**, aldrig på bildnivå.
5. Osäkerhet exponeras — abstention ("jag vet inte") är ett officiellt KPI.
6. Ingen crowdsourcad bild blir automatiskt sann data — verifieringstrappan
   `unverified → model/database/human/scholar verified` gäller alltid, och
   GPS är en signal, aldrig facit (ADR-0007).
