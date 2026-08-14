# Licensinventering och data governance

**Regel:** ingen träningsdata läggs in i systemet utan provenance. Extern data
licensklassificeras **innan** träning. Vi antar aldrig att
"kulturarvsdata = fria bilder".

## Licensklasser per källa

| Källa | Metadata | Bilder/innehåll | Krav på oss |
|---|---|---|---|
| Runor / K-samsök (RAÄ) | CC0 | Varierar per leverantör och objekt | Egen rights record per bild; ingen antagen frihet |
| Scandinavian Runic-text Database (Uppsala) | Får användas i egna applikationer | — | **Rapportera användningen** till Uppsala; **ange databasen som källa** vid exponering; modifierad version får inte kallas "Scandinavian Runic-text Database" |
| Scandinavian Runestone Inscriptions (HF, 2 615 par) | CC BY-SA 4.0 (datasetnivå) | Individuella licenser per bild | Attribution + ShareAlike på datasetnivå; per-bild rights record |
| Wikimedia Commons | — | Per fil (CC-varianter, PD) | Per-fil klassning, fotografattribution |
| 3D-modeller | Per källa | Per källa | Klassas innan rendering; syntetiska renderingar ärver källmodellens villkor |
| Fältdata (användare) | — | Uttryckligt samtycke krävs | Samtyckesregister; aldrig automatisk ground truth |

## Obligatorisk provenance (alla objekt)

```
dataset_id, source, source_url, source_record_id, license, creator,
attribution, modification_status, download_timestamp, dataset_version, checksum
```

## Obligatorisk rights record (alla bilder)

```
image_id, original_url, local_object, license, photographer,
source_institution, resolution, orientation
```

Maskinläsbara scheman: `data-contracts/schemas/`. Valideringen är körbar och
CI-testad — ett objekt utan giltig provenance kan inte tas in i corpus.

## Namngivning (ADR-0004)

Vår interna, modifierade/berikade produkt heter **Runestone Intelligence
Corpus**. Metadata behåller alltid:

```
source_database = Scandinavian Runic-text Database
source_provider = Uppsala University
```

## IP-gräns

Proprietärt: egna modellvikter, preprocessing, inscription detector, rune
recognition, retrieval ranking, confidence/kalibrering, syntetisk
datagenerering, field adaptation, error-correction pipeline, orchestration,
benchmark tooling, produkt-UX.

Externa data blandas aldrig ihop med egen IP på ett sätt som gör licensläget
oklart — provenance-fältet `license` + `source` avgör alltid vad ett objekt
får användas till.

## Öppna åtgärdspunkter (Sprint 1)

- [ ] Formell rapportering av användning till Uppsala universitet innan
      SRD-importen tas i produktion.
- [ ] Verifiera K-samsöks användarvillkor för bildhämtning i träningssyfte.
- [ ] Per-bild licensskörd ur HF-datasetets metadata till rights records.
