# Datasets

## Sex lager

| Layer | Innehåll |
|---|---|
| **A — Canonical text** | Alla runinskrifter och metadata (Runestone Intelligence Corpus) |
| **B — Historical photographs** | Alla lagligt återanvändbara fotografier |
| **C — Modern photographs** | Nyare bilder från öppna källor och egna fältinsamlingar |
| **D — 3D** | Tillgängliga 3D-modeller av runstenar |
| **E — Synthetic** | Renderade bilder från 3D-modeller (vinklar, ljus, väder, kompression) |
| **F — Field data** | Riktiga mobilbilder från användare och fälttester (samtyckesbaserade) |

## Versionering

- Varje dataset är **immutable**: `corpus-v0.1`, `corpus-v0.2`, ...
- Varje version har ett manifest enligt
  `data-contracts/schemas/dataset-manifest.schema.json` med checksum,
  källförteckning och splitpolicy.
- Originaldata muteras aldrig; berikning ⇒ ny version med `parent_version`.
- Split deklareras i manifestet och sker alltid på `inscription_id`
  (ADR-0002), med separat unknown-stone-testset.

## Lagring

Datafiler bor i object storage (`raw/`, `processed/`, `datasets/`), aldrig i
Git. Git innehåller manifest, scheman, ingestion-kod och splitdefinitioner —
det räcker för att reproducera varje version exakt.
