# SEO_BASELINE — nollmätning

Datum: 2026-08-21 (före lansering).

| Mätpunkt | Värde | Källa |
|---|---|---|
| Indexerade sidor | 0 | Sajten är inte deployad |
| Organiska klick/impressions | 0 | GSC: DATA_UNAVAILABLE (kräver deploy + verifiering) |
| Rankande queries | 0 | — |
| Publika sidor byggda | 77 (1 huvudhubb + 4 hubbar + 72 entity) | tools/genseo.mjs |
| Sidor som klarar teknisk QA | 77/77 | tools/seocheck.mjs |
| Root keywords i databasen | 332 (142 entity-härledda, 190 kurerade) | seo/keywords.json |
| Frågematris Tier 1 | seo/questions-tier1.json | frågeförfattning ur SERP-research |
| Brand-SERP | "Bidragskoll" utan egen entitet; namngrannar dokumenterade | SEO_COMPETITORS.md |

## Direkt efter deploy (i ordning)

1. Verifiera domänen i Google Search Console + skicka in sitemap.xml.
2. Registrera baslinjevärden här (indexerade sidor, första impressions).
3. Aktivera GSC-loopen (SEO_STRATEGY.md §Mätning).
4. Rank tracking för Tier 1–3 (struktur: keyword · position · URL · datum ·
   SERP-feature — verktyg väljs när data finns; fabricera aldrig positioner).

## Sprint 01-tillägg (2026-08-22)

Nollmätningen ovan gäller oförändrad — sajten är fortfarande inte deployad
(0 indexerade sidor, ingen GSC-data, inga backlinks). Nya mätbara tillgångar
sedan 2026-08-21:

| Mätpunkt | Värde | Källa |
|---|---|---|
| Huvudintentioner kartlagda | 100 | seo/intents-100.json |
| Query-universum | 3 488 (343 verkliga + 3 145 genererade) | seo/query-universum.json |
| SERP-analyserade kluster | 25 (73 sökningar, 558 träffar) | seo/serp-sprint01.json |
| Förstaplats-klassning | 13 ETTA-MÖJLIG / 11 ANGRIP-RUNT / 1 MYNDIGHET-ÄGER | seo/serp-sprint01.json |
| Kunskapsgraf | 250 noder, 1 273 kanter | seo/kunskapsgraf.json |
| Blueprints specade | 10 | docs/SEO_BLUEPRINTS_SPRINT01.md |

Vid deploy tillkommer i steg 2 (utöver listan ovan): omvalidera
serp-sprint01-positionerna mot google.se (USA-index-brasklappen) och
komplettera PAA/featured snippets manuellt; query coverage mäts som andel av
query-universumets varianter med ≥1 impression i GSC (per intent, per källtyp
verklig/genererad — genererade varianter är hypoteser tills GSC bekräftar dem).
