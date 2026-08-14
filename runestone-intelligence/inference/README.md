# Inference

Inference-workers i Kubernetes, optimerade separat från träning (latency,
GPU-kostnad, minne, concurrency mäts i Sprint 11 — Hardening).

Orkestrerar pipelinen: image quality → detection → rectification → rune
vision → retrieval → verification → translation → confidence. Varje steg
rapporterar egen confidence; abstention (`422`-svaret i `api/openapi.yaml`)
är ett förstaklassutfall, inte ett fel.

Varje inferens loggar modellversion + timestamp för källförankring och
reproducerbarhet. Misslyckade/osäkra fall matas till error corpus
(långsiktig datamoat, komponent 4).
