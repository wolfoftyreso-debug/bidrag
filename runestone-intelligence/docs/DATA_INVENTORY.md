# Datainventering (Sprint 0)

Komplett inventering av kända källor, deras roll, åtkomst och begränsningar.
Ingen källa importeras utan att den finns i denna inventering med
licensklassning i `docs/LICENSES.md`.

## Källor

### 1. Riksantikvarieämbetet — Runor

- **Roll:** primär kunskapskälla: signum, inskriftsinformation, geografi,
  bilder, rapporter, metadata, länkar till andra kulturarvsobjekt.
- **Omfattning:** cirka **7 200 registrerade inskrifter** (uppdaterad siffra;
  tidigare ofta angiven som ~7 000).
- **Åtkomst:** byggd på öppna länkade data; åtkomst via **K-samsöks API**.
- **Licens:** metadata är CC0. Bildrättigheter varierar per leverantör och
  objekt — antas ALDRIG fria (se ADR-0003).

### 2. Uppsala universitet — Scandinavian Runic-text Database

- **Roll:** central vetenskaplig textkälla; importeras till internt canonical
  format (**Runestone Intelligence Corpus**).
- **Villkor:** får användas i egna applikationer, men användningen ska
  **rapporteras** till Uppsala och databasen ska **anges som källa** när
  information exponeras. Modifierade databaser får **inte** kallas
  "Scandinavian Runic-text Database" (därav eget produktnamn, ADR-0004).
- **Obligatorisk metadata på varje post:**
  `source_database = Scandinavian Runic-text Database`,
  `source_provider = Uppsala University`.

### 3. Hugging Face — Scandinavian Runestone Inscriptions (multimodalt dataset)

- **Roll:** första benchmark- och träningskälla; grund för RUNEBENCH-BASELINE.
- **Omfattning:** **2 615 poster**: fotografi, translitterering, normalisering,
  engelsk översättning, period, provins, signum, inskriftslängd. Byggt
  specifikt för VLM-utvärdering av runinskrifter.
- **Licens:** CC BY-SA 4.0 på datasetnivå; **ingående bilder har individuella
  licenser** — varje bild får egen rights record.
- **Varning:** datasetets inbyggda eval/few-shot-struktur får INTE användas
  som vår train/test-split. Vår split sker på sten-/inskriftsnivå (ADR-0002).

### 4. K-samsök (bredare kulturarvsdata)

- **Roll:** framtida utökning av tränings- och retrievalmaterial; miljontals
  kulturarvsobjekt och flera miljoner kopplade bilder.
- **Licens:** metadata CC0; bildrättigheter per objekt.

### 5. Wikimedia Commons

- **Roll:** kompletterande fotografier där licensen tillåter.
- **Licens:** per fil — klassificeras individuellt.

### 6. 3D-modeller av runstenar

- **Roll:** INTE ett sidospår — grund för syntetisk datagenerering (Layer E).
  Från samma sten genereras: frontalbild, 15°/30°/45° vinkel, delvis skymd,
  låg belysning, hårt solljus, motljus, regn, våt/torr sten, snö, skugga,
  hög/låg kontrast, mobilkameraliknande kompression.
- **Mål:** träna på hur runstenar faktiskt ser ut i fält, inte bara på
  perfekta forskningsfotografier.

### 7. Fältdata (Layer F, efter MVP)

- **Roll:** riktiga mobilbilder från fälttester och (med uttryckligt samtycke)
  användare. Långsiktig datamoat. Aldrig automatiskt ground truth.

## Relaterad forskning (bevakas, konkurrensposition)

- **Stockholms universitet — "AI in the service of runology":** bygger en
  forskningsbaserad assistent ovanpå den skandinaviska runtextdatabasen.
  Bekräftar områdets relevans — och vår differentiering: **bilden är
  ingången**, inte texten.

## Första datainsamlingens mål

```
~7 000+ canonical inscriptions
~2 600 image/text pairs
+ additional legal photographs
+ available 3D models
+ synthetic renderings
```

## Automatisk matchning (STEG 7)

Kärnan i corpusbygget är kopplingen:

```
signum ↔ inscription ↔ image ↔ source ↔ license
```

## Aktiv datainsamling (efter första corpus)

Varje modellmisslyckande ställer frågan: *vilken typ av data saknar
modellen?* (låg kontrast, viss runtyp, stenstil, provins, fotovinkel, skada,
runform). Detta driver nästa träningsdataset — effektivare än slumpmässig
insamling (Active Learning: high uncertainty + high information value).
