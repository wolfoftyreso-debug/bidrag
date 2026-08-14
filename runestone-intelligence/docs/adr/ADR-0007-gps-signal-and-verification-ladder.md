# ADR-0007: GPS är signal (aldrig facit) och verifieringstrappa för fältdata

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

GPS-närhet är en enormt stark identifieringssignal (databasen vet att U 489
står 43 meter bort), men folk fotograferar från 100 meters håll, GPS driver,
och stenar står ibland tätt. Samtidigt är crowdsourcade bilder av okänd
kvalitet: att låta dem bli "sann data" automatiskt skulle förgifta både
corpus och träningsdata.

## Beslut

### GPS som signal

Stenidentitet avgörs alltid av en kombinerad score:

```
visual similarity + GPS proximity + inscription similarity
+ stone geometry + known location (+ ornament, runbandslayout)
→ stone identity score
```

**Invariant (maskinellt enforcerad):** `match.status = matched` kräver minst
en evidens utöver `gps_proximity`. GPS ensam kan aldrig bekräfta identitet —
bara föreslå kandidater för rankning.

### Verifieringstrappa

Varje fältobservation startar som `UNVERIFIED OBSERVATION` och kan höjas till:

```
MODEL VERIFIED → DATABASE MATCHED → HUMAN VERIFIED → SCHOLAR VERIFIED
```

**Invarianter (maskinellt enforcerade):**

- All status över `unverified` kräver `verified_by` (spårbar aktör/modell).
- Träningsanvändning kräver uttryckligt `consent.training_use = true`;
  en Layer F-bild kan inte få `training_allowed` utan `consent_ref`.
- Endast `human_verified`/`scholar_verified` kan bidra till RUNEBENCH-GOLD
  (gold kräver redan `verified_by` per ADR/benchmark-kontraktet).

## Konsekvenser

- Identifieringsmotorn måste alltid producera evidenslistan, inte bara en
  siffra — det gör matchningar granskningsbara.
- Crowdsourcing kan upptäcka registerfel utan att registret korrumperas:
  avvikelser blir kandidater/flaggor, aldrig tysta överskrivningar.
- Verifieringsarbetet blir en synlig kö (annotation-verktyget) i stället
  för ett dolt antagande.
