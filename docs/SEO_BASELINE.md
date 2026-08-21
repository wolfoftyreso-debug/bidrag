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
