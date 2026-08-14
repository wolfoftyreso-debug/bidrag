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
