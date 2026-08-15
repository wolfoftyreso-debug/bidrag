# Verification — RuneVerifier

Systemet frågar aldrig bara språkmodellen "vad betyder detta?". Kedjan
kontrolleras led för led:

```
visual reading → canonical inscription → transliteration → normalization
→ known translation
```

Avvikelse mellan visuell läsning och kanonisk inskrift ger `MATCH: LOW` och
triggar alternativ analys — aldrig tyst övertäckning:

```
VISUAL MODEL: ...kun...     DATABASE: ...kum...     MATCH: LOW
```

Resultat klassas vetenskapligt (`Established | Probable | Uncertain |
Alternative readings | Insufficient evidence`); en maskinell tolkning
presenteras aldrig som etablerad när källorna är oense (plan §39).
Låg-match-fall loggas till error corpus och blir active learning-kandidater.

## Implementerat (Sprint 7 — RuneVerifier v0.1)

`verify.py`:

- `verify_reading(observed, canonical)` → `MATCH HIGH/MEDIUM/LOW` (CER-trösklar
  0.05/0.15), positionsvisa avvikelser via sekvensalignering (en tidig
  insättning kaskadflaggar inte resten) och
  `alternative_analysis_required=true` vid LOW.
- `verify_against_candidates(observed, candidates)` → källförankrat
  utlåtande. Regler: `gps_only`-kandidater kan aldrig ge identifiering;
  presenterad vetenskaplig status **förbättras aldrig** av verifieringen —
  HIGH behåller källans status, MEDIUM nedgraderar `established` till
  `probable`, LOW ger `insufficient_evidence`.

```bash
python3 -m unittest discover -s tests   # 12 tester
```
