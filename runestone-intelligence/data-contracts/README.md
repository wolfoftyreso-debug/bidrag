# Data contracts

Maskinläsbara kontrakt för allt som får finnas i corpus. Detta är STEG 3 i
startordningen: provenance-schemat implementerat och CI-enforcerat innan
någon import körs.

## Scheman (`schemas/`)

| Schema | Objekt |
|---|---|
| `provenance` | Obligatorisk härkomst för varje objekt (ADR-0003) |
| `inscription` | Canonical inskrift i Runestone Intelligence Corpus (plan §5) |
| `image-rights` | Rights record per bild — aldrig antagen frihet (plan §7) |
| `dataset-manifest` | Immutable datasetversion med splitpolicy på inskriftsnivå (plan §32, ADR-0002) |
| `benchmark-case` | RUNEBENCH-testfall inkl. gold-flagga och abstention (plan §24–26) |
| `model-registry-entry` | Reproducerbar modellmetadata + statusflöde (plan §32–33) |
| `stone` | Atlasobjekt: position, skick, observationshistorik, kandidat/känd (ADR-0006) |
| `field-observation` | Fältobservation: GPS, enhet, samtycke, matchningsevidens, verifieringstrappa (ADR-0007) |

## Domäninvarianter utöver schemana

Enforceas i `validator.domain_invariants`:

- `rights_status = unknown` ⇒ `training_allowed` måste vara `false`.
- Status `BENCHMARKED`/`STAGING`/`PRODUCTION` kräver `benchmark_results`.
- `gold = true` kräver `verified_by` (ingen automatisk import blir gold).
- `inscription_id = null` tillåts endast för kategori I (unknown stone).
- `split_policy.unit` är `const: inscription_id` — bildnivåsplit är
  schematekniskt omöjlig.
- `match.status = matched` kräver minst en evidens utöver `gps_proximity`
  och ett `matched_stone_id` — GPS är signal, aldrig facit.
- Verifieringsstatus över `unverified` kräver `verified_by`.
- Layer F-bild med `training_allowed = true` kräver `consent_ref`
  (uttryckligt användarsamtycke per observation).
- `registered_known`-sten kräver `official_signum`; `merged` kräver
  `merged_into`.

## Körning

```bash
python3 validate_all.py                 # validera examples/
python3 validate_all.py <katalog>       # validera godtycklig recordkatalog
python3 -m unittest discover -s tests   # kontraktstester
```

Stdlib-only (ingen pip-install) så att samma validering kan köras i varje
ingestion-worker och i CI.

## Exempel

`examples/` innehåller **syntetiska** poster som demonstrerar formatet.
De är inte verkliga vetenskapliga läsningar — verkliga poster skapas av
ingestion-pipelinen med riktig provenance.
