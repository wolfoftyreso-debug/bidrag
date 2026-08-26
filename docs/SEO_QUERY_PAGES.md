# Query Pages & Indexability-domar (SEO-3)

> **Byggprodukt — redigera aldrig för hand.** `node --experimental-strip-types tools/indexability.mjs`.
> Query Pages är vyer över kunskapsgrafen; Indexability-motorn avgör vilka kombinationer
> som förtjänar en indexerbar sida utifrån VERKLIG datatäckning (inga påhittade sökvolymer).

Kurerat läge: **2026-08-13T00:00:00Z**. Kandidater: **13** · INDEX **9** · NOINDEX_FOLLOW **1** · DO_NOT_GENERATE **3**.

## Domar

| Intention | Canonical | Filter | Matchande stöd | Dom | Motivering |
|---|---|---|---|---|---|
| bidrag enskild firma investering | `/enskild-firma/investeringsstod/` | applicant=company ∧ activity=investment | 0 | **DO_NOT_GENERATE** | aktiviteten "investment" saknar kurerat stöd i kunskapsbasen |
| bidrag ideell förening | `/forening/civilsamhallesstod/` | applicant=association ∧ sector=civil_society | 14 | **INDEX** | 14 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| bidrag idrottsförening | `/forening/idrottsstod/` | applicant=association ∧ sector=sports | 3 | **INDEX** | 3 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| kulturbidrag förening | `/forening/kulturbidrag/` | applicant=association ∧ sector=culture | 15 | **INDEX** | 15 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| bidrag ungdomsförening | `/forening/ungdomsstod/` | applicant=association ∧ sector=youth | 8 | **INDEX** | 8 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| bidrag för att anställa | `/foretag/bidrag-for-att-anstalla/` | applicant=company ∧ activity=hiring | 0 | **DO_NOT_GENERATE** | aktiviteten "hiring" saknar kurerat stöd i kunskapsbasen |
| bidrag köpa maskiner företag | `/foretag/bidrag-for-maskiner/` | applicant=company ∧ activity=equipment_investment | 0 | **DO_NOT_GENERATE** | aktiviteten "equipment_investment" saknar kurerat stöd i kunskapsbasen |
| energistöd företag | `/foretag/energistod/` | applicant=company ∧ sector=energy | 3 | **INDEX** | 3 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| innovationsstöd företag | `/foretag/innovationsstod/` | applicant=company ∧ sector=innovation | 4 | **INDEX** | 4 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| jordbruksstöd företag | `/foretag/jordbruksstod/` | applicant=company ∧ sector=agriculture | 2 | **NOINDEX_FOLLOW** | endast 2 matchande stöd — för tunt för att tävla i Google |
| miljöstöd företag | `/foretag/miljostod/` | applicant=company ∧ sector=environment | 5 | **INDEX** | 5 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| ekonomiskt stöd och ersättningar privatperson | `/privatperson/ersattningar/` | applicant=individual ∧ instrument=social_benefit | 20 | **INDEX** | 20 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |
| studiestöd och bidrag för studier | `/privatperson/studiestod/` | applicant=individual ∧ instrument=educational_support | 5 | **INDEX** | 5 matchande stöd; materiellt mer specifik än målgruppshubben; varje stöd har officiell källa |

## Domtröskeln

- **INDEX** — ≥3 matchande stöd: self-canonical + i sitemap.
- **NOINDEX_FOLLOW** — 1–2 stöd: genereras för människor, `robots noindex,follow`, utanför sitemap.
- **DO_NOT_GENERATE** — 0 stöd: sidan skapas inte (t.ex. aktiviteter som saknar kurerat stöd i KB:n).

Aktivitetsintentioner (anställa, köpa maskiner, investering enskild firma) landar i DO_NOT_GENERATE
tills kunskapsbasen kurerats för dessa aktiviteter — motorn vägrar ärligt en tom sida.
