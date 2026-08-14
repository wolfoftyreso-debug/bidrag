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
