# ADR-0004: Eget corpusnamn med bevarad källattribution

**Status:** Accepted · **Datum:** 2026-08-14

## Kontext

Uppsala universitet tillåter användning av Scandinavian Runic-text Database i
egna applikationer, men kräver att användningen rapporteras, att databasen
anges som källa när information exponeras, och att modifierade databaser inte
kallas "Scandinavian Runic-text Database".

## Beslut

1. Vår interna, berikade produkt heter **Runestone Intelligence Corpus**.
2. Varje post som härrör från Uppsala-databasen behåller alltid:
   ```
   source_database = Scandinavian Runic-text Database
   source_provider = Uppsala University
   ```
3. Användarvända resultat visar alltid källan (`sources[]` i API-svaret).
4. Formell rapportering till Uppsala görs innan importen tas i produktion
   (åtgärdspunkt i `docs/LICENSES.md`).

## Konsekvenser

- Villkorsefterlevnad är strukturellt garanterad, inte beroende av disciplin.
- Corpuset kan berikas fritt (alternativa läsningar, kopplade bilder,
  confidence) utan att förväxlas med originaldatabasen.
