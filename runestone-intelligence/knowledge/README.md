# Knowledge — Runestone Intelligence Corpus + Retrieval

Canonical corpus (Layer A) med retrieval-motor:

```
predicted inscription → candidate retrieval → known inscriptions
→ similarity ranking → historical evidence
```

Retrieval kan använda: runföljd, translitterering, geografiskt område,
runtyp, stenens visuella egenskaper, signum, inskriftslängd, namn,
ornamentik. GPS (valfri) ger `nearby known stones → candidate ranking`.

Stone Identification Engine är en separat modellfunktion
(`Likely stone: U 489, 97.8 %`) vars output möjliggör verifieringslagret:
observed reading vs canonical reading.

Corpusposter följer `data-contracts/schemas/inscription.schema.json`;
Uppsala-härledda poster behåller alltid `source_database` /
`source_provider` (ADR-0004). Lagring: PostgreSQL + vector/retrieval store
(se `deployment/`).

## Implementerat (Sprint 6 — RuneKnowledge v0.1)

| Modul | Gör |
|---|---|
| `retrieval.py` | `CorpusIndex`: teckentrigram-grovsökning + editavstånds-omrankning på läsningen, GPS-närhet (haversine, 5 km-radie), filter på runtyp/region. Varje kandidat bär evidens per signal och källförankring (`source_database`, `translation_sv`, `scholarly_status`). Sökning med enbart GPS flaggas `gps_only` — kandidatförslag, aldrig identifiering (ADR-0007). Deterministisk rankning |
| `retrieve.py` | CLI: corpus + läsning (+ ev. GPS/filter) → rankade kandidater + verifieringsutlåtande via `verification/verify.py` |

```bash
python3 retrieve.py --corpus <corpus-dir> --text "iksimbil" --lat 59.85 --lon 17.63
python3 -m unittest discover -s tests   # 14 tester
```

Referensimplementationen är stdlib-only och exakt; vektorstöd (embeddings
för visuella egenskaper/ornamentik) läggs till när bilddata finns — samma
kandidat- och evidensformat behålls.
