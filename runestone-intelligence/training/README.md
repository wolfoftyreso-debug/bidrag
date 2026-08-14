# Training

Ingen träning i Sprint 0–3. Träningsfaser (plan §28): baseline →
specialiserad runigenkänning → full inscription model → retrieval →
translation → synthetic augmentation → field adaptation → continuous
training.

Kostnadsstrategi: `small model → benchmark → error analysis → targeted data
→ larger model` — aldrig "köp GPU → träna stort → hoppas".

Varje träningskörning kräver: versionshanterad config i `configs/`
(refereras från modellregistret), immutable datasetversion, Git-commit och
GPU-miljöbeskrivning. Träning sker i K8s GPU-workers som skalas efter behov;
träningsnivåer och loss-signaler per nivå beskrivs i `docs/ARCHITECTURE.md`.
