# Deployment — self-hosted AWS/Kubernetes

```
AWS
├── Object Storage        raw / processed / datasets / models / evaluation
├── PostgreSQL            corpus, provenance, rights records, registry
├── Vector / Retrieval Store
├── Model Registry
├── Training Workers      GPU, skalas efter behov
├── Inference Workers     optimeras separat från träning
└── API
```

## GitOps-regler

- Alla förändringar går via Git — Git är source of truth.
- Ingen manuell produktion direkt i buckets.
- Manifester och infra-kod versioneras här; miljöer ska kunna återskapas
  från repo + immutable datasetversioner.
- Objektlayout: `raw/` (omuterat original, checksummat), `processed/`,
  `datasets/<name>-<version>/`, `models/<name>-<version>/`, `evaluation/`.

Hardening (Sprint 11) mäter latency, GPU-kostnad, failure modes,
confidence-kalibrering, minne, concurrency och API-stabilitet innan Public
MVP (Sprint 12).
