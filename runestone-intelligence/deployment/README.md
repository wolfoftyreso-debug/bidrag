# Deployment — self-hosted AWS/Kubernetes

```
AWS
├── Object Storage        raw / processed / datasets / models / evaluation
├── PostgreSQL + PostGIS  corpus, provenance, rights records, registry,
│                         atlas (stones, field observations, geospatial index)
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

## Implementerat

| Fil | Gör |
|---|---|
| `Dockerfile.api` | Referensimage: python-slim, non-root (uid 10001), inga pip-steg (hela kedjan är stdlib). Corpus bakas **inte** in — datasetversioner är immutabla artefakter som monteras vid start |
| `k8s/api-deployment.yaml` | 2 repliker, initContainer hämtar den **Git-pinnade** datasetversionen från object storage (`CORPUS_VERSION` i ConfigMap — byts via commit, aldrig via bucket-skrivning), probes mot `/healthz`, read-only rootfs, corpus monterad read-only, resource limits |
| `k8s/api-configmap.yaml` | Miljökonfig: corpusversion, reader (`null` tills en modell är i PRODUCTION i registret), VLM-endpoint |
| `k8s/api-ingress.yaml` | Exponerar **endast** `/v1/analyze` + `/healthz`; interna endpoints nås aldrig via ingress |
| `k8s/api-secret.template.yaml` | Mall — värden via SealedSecrets/ExternalSecrets, aldrig i Git; ingår inte i kustomization |
| `k8s/corpus-pvc.yaml`, `api-service.yaml`, `api-pdb.yaml`, `namespace.yaml`, `kustomization.yaml` | Volymer, service, disruption budget, namespace, kustomize-rot |

Driftinvarianterna är testade (`tests/test_manifests.py`): probes finns,
non-root, ingen `:latest`-tagg, corpus read-only, pinnad corpusversion,
interna endpoints ej exponerade, PDB-selektor matchar deploymenten.
CI bygger imagen och smoke-testar: healthz + ärlig 422 utan läsare.

```bash
python3 -m unittest discover -s tests   # 6 manifesttester (kräver pyyaml)
kubectl apply -k k8s/                   # deploy (GitOps-flödet applicerar)
```

GPU-workers för träning/inference tillkommer när första modellen tränas
(separata deployments; inference optimeras separat från träning).
