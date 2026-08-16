# ADR-0008: Identity Lock, Known/Unknown Stone Path och trenivåmodellen

**Status:** Accepted · **Datum:** 2026-08-16

## Kontext

För en känd runsten är det fel att läsa runorna från noll vid varje foto:
den verifierade posten i corpus är snabbare, stabilare och vetenskapligt
förankrad. Modellens roll för kända stenar är inte "runtolkare" utan
**moderniseringsmotor**. Samtidigt får en okänd sten aldrig blockeras av
att den saknas i corpus — det är så systemet lär sig nya stenar utan att
förstöra den verifierade databasen.

## Beslut

### 1. Identifiering är prioritet #1 — IDENTITY LOCK

```
PHOTO → VISUAL IDENTIFICATION → KNOWN STONE?
  ├── YES → FETCH VERIFIED RECORD → MODERN INTERPRETATION
  └── NO  → RUNIC READING → TRANSCRIPTION → INTERPRETATION → MODERN LANGUAGE
```

Trösklar (`knowledge/identity.py`):

| Identity score | Läge | Beteende |
|---|---|---|
| ≥ 0.95 | **LOCK** | Verifierad post hämtas; runorna läses inte om |
| 0.70–0.95 | **REVIEW** | Flera kandidater jämförs innan beslut |
| < 0.70 | **FALLBACK** | Unknown Stone Path: faktisk runläsning |

Spärrar som gäller oavsett score: en `gps_only`-kandidat kan aldrig ge
LOCK/REVIEW (ADR-0007), och en LOW-match från verifieringen bryter LOCK —
motsäger läsningen den kanoniska texten är identiteten inte låst
(avvikelsen kan vara fel sten, eller en förändring på stenen → Atlas).
En mismatch *binder* omvänt bara när kandidaten var plausibel
(score ≥ 0.70); under det behandlas stenen som okänd, inte motsagd.

### 2. Tre sparade nivåer per sten

| Nivå | Innehåll | Kontrakt | Regel |
|---|---|---|---|
| **L1 — SOURCE TRUTH** | Det akademiska materialet exakt som det är (signum, translitterering, normalisering, vetenskaplig översättning, källa) | `inscription` | Ändras **aldrig** av modellen |
| **L2 — INTERPRETED MEANING** | Strukturerad semantik: personer, relationer, handlingar, syfte, emotionell kontext | `interpretation` | Spårbar till L1 (`basis`), varje element citerar källtokens, `reviewed=false` tills människa granskat |
| **L3 — MODERN EXPERIENCE** | Det användaren läser (emotion first) | `rendering` | Refererar alltid L2; `basis=canonical` kräver `scholarly_grounded=true`, `formulaic` får aldrig påstå det |

Maskinella invarianter i validatorn: L2 med `basis=canonical` kräver
`inscription_id`; L3-`scholarly_grounded` måste följa basis åt båda hållen.

### 3. Stillagret appliceras på betydelsen, aldrig på bilden

`translation/presentation.py`: `STYLE_SPEC` (emotion first — prioritering
begriplighet → känsla → ordagrannhet → grammatik; förbjudna tillägg: nya
personer/platser/datum/dödsorsaker/obelagda relationer/händelser/fejkade
citat) körs på L1/L2 — pipelinen är
`VERIFIED MEANING → STYLE LAYER`, aldrig `IMAGE → STYLE`. En deterministisk
mallrenderare finns som referens/fallback; LLM-generatorn anges alltid
spårbart i `generator`.

## Konsekvenser

- Known Stone Path blir snabb, reproducerbar och källförankrad; modellens
  kreativitet är inlåst i L3 där den inte kan korrumpera fakta.
- Unknown Stone Path producerar ny kunskap (kandidatstenar, observationer)
  utan att röra den verifierade databasen.
- Corpusbygget (Runestone Intelligence Corpus v1) bekräftas som produktens
  viktigaste tillgång — identifiering slår läsning för kända stenar.
