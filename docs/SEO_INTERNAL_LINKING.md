# SEO_INTERNAL_LINKING — länkgrafens regler

Datum: 2026-08-21. Implementerat i tools/genseo.mjs; orphan- och
brutna-länkar-vakt i tools/seocheck.mjs (körs av verify).

## Grafens struktur (implementerad)

- **Nedåt:** huvudhubb → målgruppshubbar → entity-sidor (grupperade per
  instrumenttyp, alfabetiskt — deterministiskt, aldrig slumpmässigt).
- **Uppåt:** varje sida bär breadcrumbs (synliga + BreadcrumbList-markup)
  till sin hubb och huvudhubben.
- **I sidled:** "Relaterade stöd" på varje entity-sida — semantiskt härledda
  (samma finansiär först, därefter samma instrumenttyp), max 5, aldrig en
  slumpalgoritm.
- **Mot produkten:** varje sida länkar / (utredningen) och den officiella
  källan (utåtlänk med rel="noopener" — myndighetslänkar är citat och följs).

## Regler

1. Ingen orphan: varje publik sida nås från /bidrag/ inom 2 klick (vaktat).
2. Inga brutna interna länkar (vaktat vid varje bygge).
3. Ankartexter är stödets riktiga namn eller naturliga fraser — aldrig
   mekanisk exact-match-upprepning. Variation kommer naturligt av att
   kortnamn, sammanfattning och kontext skiljer per placering.
4. Guide-sidor (när de byggs) länkar sina entity-sidor med förklarande
   ankare ("se villkoren för bostadsbidrag till barnfamiljer") och
   entity-sidor länkar tillbaka till relevanta guider — parvis, inte enkelriktat.
5. Sidled-länkar ska bära semantik (samma målgrupp/situation/finansiär) —
   inte "senaste artiklar".

## Auktoritetsflöde

Hubbarna är sajtens interna auktoritetsnav: alla entity-sidor länkar upp,
huvudhubben länkar ner till alla fyra hubbarna. När guide-lagret byggs får
Tier 1-guiderna hubblänkar från både entity-sidor och hubbar (de blir grafens
mest inlänkade noder — i paritet med sin SERP-prioritet).
