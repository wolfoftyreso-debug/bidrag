# Annotation

Internt annoteringsverktyg (byggs efter Data Foundation v0.1). Princip:
**systemet föreslår, människan verifierar** — ingen expert ska annotera allt
från scratch.

Annotatören ska kunna: se originalbild, zooma, markera inskriftsområde,
markera runor, ange runtecken, ange osäkerhet, se canonical text, jämföra
modellens prediction, acceptera/förkasta, skapa alternativ läsning.

Output valideras mot `data-contracts` (uncertain_characters,
alternative_readings) och blir träningskandidater — aldrig automatiskt
ground truth. Prioritering styrs av active learning: high uncertainty ×
high information value (t.ex. runformer där modellen konsekvent misslyckas).
