# Translation — RuneTranslation v0.1

Kedjans sista steg (plan §22), med prioriterad ordning och aldrig
`IMAGE → LLM guesses meaning`:

```
RUNE → TRANSLITERATION → NORMALIZATION → TRANSLATION
```

## Policyordning (`translate.py`)

1. **Canonical** — verifieringen har bekräftat en känd inskrift
   (MATCH HIGH/MEDIUM): källans översättning används, källförankrad med
   `source_database`/`source_provider`/signum. Normalfallet för kända stenar.
2. **Formulaic** — okänd sten vars läsning följer den väldokumenterade
   minnesformeln: regelbaserad delöversättning där formelord översätts och
   oupplösta tokens (typiskt personnamn) behålls markerade. Kräver
   täckningströskel 0.6 — under den vägrar den hellre än gissar. Status
   alltid `uncertain`.
3. **Abstain** — läsning som motsäger en känd sten (mismatch) eller text
   utan igenkännbar struktur: `insufficient_evidence`, ingen översättning.
   En mismatch faller **aldrig** tillbaka till formelöversättning —
   verifieringen har redan underkänt läsningen.

## Moduler

| Modul | Gör |
|---|---|
| `runes.py` | Yngre futharken (långkvist + kortkvistvarianter, medeltida tillägg) → translitterering. Okända tecken blir `?` med rapporterad position — aldrig tyst borttagna. Äldre futharken/anglosaxiska läggs till per expansionsplanen (§48) |
| `normalize.py` | Seed-lexikon över minnesformelns vanligaste ord (Rundata-konventionens normalformer). Medvetet ofullständigt — ersätts med korpushärlett lexikon. Okända tokens passerar oförändrade med `resolved=false` |
| `translate.py` | Policykedjan ovan + `formulaic_translation` med per-token-redovisning |

Integrerat i `knowledge/retrieve.py`: CLI:t ger nu kandidater + verdict +
översättningsblock i ett anrop.

```bash
python3 -m unittest discover -s tests   # 18 tester
```

Formelöversättningen är avsiktligt torr och ordagrann ("Burkil reste
stenen denna efter Ulf son sin") — lättläst ordföljd är en senare
förbättring; korrekthet och ärlighet går före flyt (§22: inte historiskt
förskönande).
