# Runestone Atlas — observationslagret

Projektet har **två produkter i samma system**:

1. **Runstenläsaren** — fota → läs → översätt (det användaren ser i V1).
2. **Runestone Atlas** — en kontinuerligt växande, geospatial databas över
   verkliga runstenar och hur de faktiskt ser ut ute i världen.

Den andra kan på sikt bli minst lika värdefull som modellen. Atlasen är en
förstaklassdel av arkitekturen från Sprint 0 — även om V1-användaren bara ser
"Fota → Vad står det?".

## Flödet när någon fotar

```
MOBILFOTO (image + GPS + timestamp + device metadata)
        │
        ▼
   STONE MATCHING
        │
   ┌────┴────┐
   │         │
KÄND STEN  OKÄND STEN
   │         │
verifiera  skapa kandidat (Unknown Runestone Observation)
   │         │
   └────┬────┘
        ▼
  RUNESTONE ATLAS
  (position, bilder, riktning, skick, datum,
   identifiering, inskriftsdata, observationshistorik)
```

## Varje sten är ett objekt, inte en bild

`data-contracts/schemas/stone.schema.json`: officiellt signum (null för
kandidater), position med källa och precision, historisk plats, aktuellt
skick, första/senaste observation, `condition_timeline` — en **longitudinell
observationshistorik**, inte bara en katalog över var stenen står.

Varje fotografering är en `field-observation`
(`field-observation.schema.json`): GPS (valfri), väder, kamera, observerat
skick, bilder, matchningsresultat med evidens, verifieringsstatus och
samtycke.

## GPS är en stark signal — aldrig facit

Folk kan stå 100 meter bort och fotografera. Identiteten avgörs av en
kombinerad score:

```
visual similarity + GPS proximity + inscription similarity
+ stone geometry + known location (+ ornament, runbandslayout)
→ stone identity score
```

**Maskinellt enforcerat:** en observation kan inte få `match: matched` med
enbart `gps_proximity` som evidens (domäninvariant i validatorn, ADR-0007).

## Stenhård regel: verifieringstrappan

Ingen crowdsourcad bild blir automatiskt "sann data". Varje observation
startar som:

```
UNVERIFIED OBSERVATION
   → MODEL VERIFIED
   → DATABASE MATCHED
   → HUMAN VERIFIED
   → SCHOLAR VERIFIED
```

Varje steg uppåt kräver `verified_by` (spårbart). Endast observationer med
uttryckligt `consent.training_use = true` kan bli träningskandidater, och en
Layer F-bild kan inte markeras `training_allowed` utan `consent_ref` — båda
enforceas i valideringen.

## Fotografens andra liv för bilderna

Användaren skickar in ett foto för att få texten översatt. Med samtycke blir
samma foto samtidigt en fältobservation: olika ljus, kameror, vinklar, väder,
vegetation, snö, erosion, nya skador — mer värdefullt än ytterligare 1 000
perfekta museifotografier.

## Scan coverage — crowdsourcat fältuppdragssystem

Atlasen vet per sten: antal användare, fotografier, datum, kameratyper,
senaste observation. Därmed också motsatsen:

```
U 112: 0 moderna observationer
```

Systemet kan generera fältuppdrag: *"De här 25 runstenarna saknar moderna
fotografier."* Coverage är härledd data — den beräknas ur observationerna
och lagras inte som egen sanning.

## Okända stenar och registerkvalitet

Fotografen behöver inte veta vad stenen heter. Vid `no_match` skapas en
kandidatsten (`atlas_status: candidate_unknown`) som senare kan matchas av
expert eller när databasen förbättras — eller visa sig vara en lucka eller
felaktighet i befintliga register. En kandidat som visar sig vara en känd
sten märks `merged` med `merged_into` (historiken kastas aldrig).

## Förändringsdetektion

Med tillräckligt många observationer av samma sten över tid:

```
2026: runa intakt → 2028: erosion → 2030: ytterligare skada
```

`condition_timeline` med `change_detected` gör att systemet kan säga *"den
här inskriften har förändrats sedan föregående observation"*. Det gör
produkten till ett **digitalt observationssystem för kulturarv**, inte bara
en översättningsapp. Larm om förändring är en modellhypotes tills den är
mänskligt verifierad (samma trappa som allt annat).

## Den självförstärkande loopen

```
EXISTING CORPUS → TRAIN MODEL → MOBILE APP → PEOPLE TAKE PHOTOS
→ NEW FIELD DATA → VERIFY / IDENTIFY → BETTER DATASET → RETRAIN MODEL ─┐
        ▲                                                              │
        └──────────────────────────────────────────────────────────────┘
```

Systemet blir bättre genom användning — utan att vi bygger funktioner
användarna inte bryr sig om.

## Integritet

- GPS och enhetsmetadata lagras bara med samtycke (`consent_version`
  versionshanteras; samtycket är per observation, inte per konto).
- Bidragsgivare är pseudonymiserade i corpus (`attribution: "Anonymized
  field contributor"`); koppling till person hålls utanför datasetlagret.
- Samtycke kan återkallas → observationen tas ur framtida datasetversioner
  (immutabla historiska versioner dokumenterar borttag i manifestet).
