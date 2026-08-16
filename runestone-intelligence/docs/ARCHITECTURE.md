# Arkitektur

## Slutlig målarkitektur

```
                         USER
                           │
                           ▼
                    MOBILE PHOTO
                           │
                           ▼
                  IMAGE QUALITY MODEL
                           │
                           ▼
                 INSCRIPTION DETECTOR
                           │
                           ▼
                SURFACE RECTIFICATION
                           │
                           ▼
                  RUNE VISION MODEL
                           │
                           ▼
                    RUNE SEQUENCE
                           │
             ┌─────────────┴─────────────┐
             │                           │
             ▼                           ▼
       RUNIC CORPUS                LANGUAGE MODEL
             │                           │
             └─────────────┬─────────────┘
                           ▼
                    RETRIEVAL ENGINE
                           │
                           ▼
                    VERIFICATION
                           │
                           ▼
                    TRANSLATION
                           │
                           ▼
                  CONFIDENCE ENGINE
                           │
                           ▼
                    USER RESULT
```

Systemet får **aldrig** hoppa direkt från `IMAGE → free-form answer`.

## Modellmoduler (inte en gigantisk modell)

| # | Modell | Uppgift | Output |
|---|---|---|---|
| 1 | **Image Quality Model** | blur, exponering, kontrast, upplösning, perspektiv, synlig inskriftsandel | `image_quality: 0.91` + rekommendation ("Flytta kameran närmare") |
| 2 | **Stone / Inscription Detector** | lokalisera `stone`, `inscription`, `rune_band`, `ornament`, `damage` | masker/boxar — språkmodellen slipper tolka hela landskapsbilden |
| 3 | **Inscription Rectification** | krökta/lutande/snett fotograferade ytor | `raw image → mask → perspective estimation → surface normalization → rectified inscription` |
| 4 | **Rune Vision Model** (kärnmodellen) | rektifierad inskriftsbild → runsekvens | både text (`ᚼᛅᚾ ᚱᛅᛁᛋᛏᛁ ...`) och strukturerad per-tecken-output med kandidater + confidence — diagnostiserbar |
| 5 | **Stone Identification Engine** | identifiera känd sten via kombinerad score: visual similarity + GPS proximity + inscription similarity + stone geometry + known location — GPS ensam räcker aldrig (ADR-0007) | `Likely stone: U 489, 97.8 %` + evidenslista |
| 6 | **Knowledge/Retrieval Engine** | predicted inscription → candidate retrieval → similarity ranking → historical evidence | retrieval på runföljd, translitterering, geografi, runtyp, visuella egenskaper, signum, inskriftslängd, namn, ornamentik |
| 7 | **Verification Engine** | cross-check `visual reading` vs `canonical inscription` | MATCH HIGH/LOW; låg match triggar alternativ analys |
| 8 | **Translation layer** | översättning först efter stabiliserad runtext | `RUNE → TRANSLITERATION → NORMALIZATION → TRANSLATION`, aldrig `IMAGE → LLM guesses meaning` |
| 9 | **Confidence Engine** | separat confidence per steg | sammanlagd confidence får aldrig maskera svaga delkomponenter |

## Träningsnivåer (flera loss-/evalsignaler)

1. **Character level** — runform → runtecken
2. **Sequence level** — runtecken → runföljd
3. **Transliteration level** — runföljd → vetenskaplig translitterering
4. **Linguistic level** — translitterering → normaliserad språkform
5. **Translation level** — normaliserad språkform → modern svenska

## Gemma/VLM-komponenten

En modern multimodal Gemma-modell används som **baseline** och potentiell
språk-/tolkningskomponent — inte som enda runläsare. Benchmarkstegen:

```
Generic VLM → Gemma baseline → Fine-tuned Gemma → Specialized Rune Vision
→ Rune Vision + retrieval → Rune Vision + retrieval + language reasoning
```

Om en specialiserad modell inte slår en generell modell på rätt uppgift byggs
ingen mer komplexitet förrän orsaken är identifierad (ADR-0001).

## Confidence-arkitektur

Varje steg rapporterar egen confidence:

```
Image quality             96 %
Stone identification      94 %
Inscription detection     98 %
Rune recognition          91 %
Transliteration           93 %
Normalization             88 %
Historical retrieval      97 %
Translation               94 %
```

Om tre runor är osäkra ska resultatet säga det.

## Källförankring (reproducerbarhet)

Varje resultat kopplas till: källdatabas, inskrift (signum), source record,
translation source, image source, modellversion (`RuneVision v0.8`) och
inference timestamp.

## Identity Lock — Known/Unknown Stone Path (ADR-0008)

Identifiering är prioritet #1. För en känd sten läses runorna inte om från
noll — den verifierade posten hämtas och modellen blir moderniseringsmotor:

```
PHOTO → VISUAL IDENTIFICATION → KNOWN STONE?
  ├── ≥0.95  LOCK      → FETCH VERIFIED RECORD → MODERN INTERPRETATION
  ├── 0.70–0.95 REVIEW → jämför kandidater
  └── <0.70  FALLBACK  → RUNIC READING → TRANSCRIPTION → INTERPRETATION
```

Tre nivåer sparas per sten: **L1 SOURCE TRUTH** (ändras aldrig av
modellen), **L2 INTERPRETED MEANING** (strukturerad semantik, spårbar till
L1), **L3 MODERN EXPERIENCE** (emotion first — stillagret appliceras på
verifierad betydelse, aldrig på bilden). Kontrakt: `interpretation`,
`rendering`; vägval: `knowledge/identity.py`.

## Atlas-flödet (parallellt med läsflödet)

Varje analyserat foto skriver — med samtycke — en fältobservation:

```
MOBILFOTO (image + GPS + timestamp + device)
   → STONE MATCHING ─ känd sten → verifiera ─┐
                    └ okänd sten → kandidat ─┴→ RUNESTONE ATLAS
                                                (position, bilder, skick,
                                                 observationshistorik)
```

Verifieringstrappan `unverified → model_verified → database_matched →
human_verified → scholar_verified` gäller all fältdata. Se `docs/ATLAS.md`,
`atlas/README.md`, ADR-0006/0007.

## Infrastruktur (self-hosted AWS/Kubernetes)

```
AWS
├── Object Storage        (raw / processed / datasets / models / evaluation)
├── PostgreSQL + PostGIS  (canonical corpus, provenance, rights records,
│                          atlas: stones + field observations)
├── Vector / Retrieval Store
├── Model Registry
├── Training Workers      (GPU, skalas efter behov)
├── Inference Workers     (optimeras separat från träning)
└── API
```

Alla förändringar går via Git (GitOps). Ingen manuell produktion direkt i
buckets. Se `deployment/README.md`.

## Research mode

Behövs inte i konsument-V1, men backend byggs så att forskningsoutput
(original image → detected inscription → rune candidates → transliteration →
normalization → matches → alternative readings → sources) kan exponeras utan
att kärnan byggs om.

## Arkitekturbeslut

Se `docs/adr/` — varje väsentligt beslut har en Architecture Decision Record.
