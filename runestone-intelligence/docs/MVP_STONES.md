# MVP-stenarna — urval, verifiering och körordning

MVP:t (ADR-0009): 10–20 välkända stenar. Måttet: **fotograferar personen
en andra sten?** Detta dokument är arbetslistan.

## Urvalskriterier

En MVP-sten ska uppfylla samtliga:

1. **Besökbar:** står utomhus vid turiststråk, `accessibility: easy`.
2. **Identifierbar:** ≥2 licensklara referensfoton från olika vinklar
   (redistribution_allowed för kartvisning; training_allowed för modellen).
3. **Källkomplett:** etablerad translitterering + översättning i SRD/Runor,
   `scholarly_status: established` (MVP:t ska inte behöva hantera omtvistade
   läsningar).
4. **Geografiskt klustrad:** stenarna ska bilda 2–3 kluster så att
   Explore/NÄSTA RUNSTEN har verklig effekt inom gång-/cykelavstånd.
5. **Koordinatverifierad:** position kontrollerad mot Runor och helst i fält.

## Kandidatlista (KANDIDATER — inget är MVP-klart förrän verifierat)

> **Regel:** varje rad ska verifieras mot Runor innan användning — signum,
> position, skick och läsning. Ingen rad i denna lista är ground truth.

| Kluster | Kandidat | Trolig signum | Status |
|---|---|---|---|
| Täby/Vallentuna (Jarlabanke-stråket) | Jarlabanke bro-stenarna | U 164, U 165 | ☐ verifiera |
| Täby/Vallentuna | Lingsbergsstenarna | U 240, U 241 | ☐ verifiera |
| Täby/Vallentuna | Granbyhällen | U 337 | ☐ verifiera |
| Uppsala | Stenen ur byggplanens exempel | U 489 | ☐ verifiera |
| Uppsala/Gamla Uppsala | kompletteras vid fältrekognosering | — | ☐ välj |
| Sigtuna | kompletteras vid fältrekognosering | — | ☐ välj |
| Mälardalen väst | Anundshögsstenen | Vs 13 | ☐ verifiera |
| Södermanland | Gripsholmsstenen (Ingvarståget) | Sö 179 | ☐ verifiera |
| Östergötland (flaggskepp) | Rökstenen | Ög 136 | ☐ verifiera — världens mest kända; L-kategori i benchmark (lång inskrift) |

Fyll på till 10–20 via coverage-rapporten: välj stenar som redan har
bilder + koordinater + etablerad text i corpus (query:
`q5_image_matchable` ∩ `scholarly_status=established` ∩ kluster).

## Verifieringschecklista per sten

- [ ] Signum bekräftat mot Runor (post-URI sparad som `source_record_id`)
- [ ] Koordinater bekräftade (Runor + fältbesök; `location.source` satt)
- [ ] L1 komplett: translitterering, normalisering, översättning, källa
- [ ] ≥2 foton med klar licens (rights records skapade; attribution ifylld)
- [ ] L2 extraherad och **mänskligt granskad** (`derivation.reviewed=true`)
- [ ] L3 emotion-first-text skriven/granskad (`reviewed=true`)
- [ ] Identity Lock-test: fältfoto → lock ≥0.95 mot rätt sten
- [ ] Explore-test: NÄSTA RUNSTEN pekar på rimlig granne i klustret

## Körordning när spärrarna släpper

1. **Skicka Uppsala-rapporteringen** (`docs/outreach/uppsala-report-draft.md`).
2. **Kör skarpa adaptrar** (miljö med nätverksegress krävs — denna
   utvecklingsmiljö blockerar extern trafik, verifierat 2026-08-16):
   SRD-dump → `srd_importer`, K-samsök → `runor_importer`-radformat,
   Commons → `wikimedia_harvester`.
3. **Bygg `corpus-v1.0`** med `build_corpus.py` (explicit timestamp+seed),
   kör `coverage_report.py` → gap-listan styr komplettering.
4. **Frys RUNEBENCH v1** från test-/unknown-partitionerna; promota
   MVP-stenarnas verifierade fall till GOLD (`verified_by`).
5. **Kör Phase 1-baselinen** (`run_baselines.py --adapters http_vlm` mot
   serverad Gemma) → Baseline Report v0.1 → **Gate 1-beslutet**.
6. **Fältrekognosera klustren** (foton i olika ljus/vinklar per sten →
   Layer F med samtycke; komplettera Uppsala-/Sigtuna-raderna).
7. **MVP-mätning:** instrumentera "andra stenen-måttet" i mobilklienten
   (andel sessioner med ≥2 analyserade stenar + tid däremellan).
