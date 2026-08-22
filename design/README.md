# Bidragskoll.se — designsystem "Bläck"

Paketerat 2026-08-22 ur Claude Design (Designsystem.dc.html).

## Innehåll
- `bidragskoll.css` — komplett stilark med nya tokens och komponenter.
  Förs tillbaka till `apps/web/src/styles.css`, `demo/demo.css` och `tools/genseo.mjs`.
- `illustrationer/` — 22 figurer som fristående SVG (viewBox 0 0 96 96, skalbara).
- `designsystem.html` — dokumentationssidan (levande exempel, nyckelskärmar, röst & ton).

## Viktigaste ändringarna mot gamla systemet
| Område | Förut | Nu |
|---|---|---|
| Neutraler | kalla grå (#f5f6f8 …) | varma (#f7f5f0, #fffdf9, #e6e2d8) |
| Primär | blå #2050d8 | dämpad indigo #3d4a8c (deep #232c58) |
| Sekundärtext | #5b6579 | #57534a (höjd kontrast ~6.5:1) |
| Typsnitt | systemstack | Public Sans (UI) + Source Serif 4 (h1/h2, poäng, .brand) |
| Knappar | gradient | platta + indigo-tonad skugga (--shadow-btn) |
| Skuggor | mycket lätta | tydligare djup (--shadow, --shadow-lift) |
| Nytt | — | Illustrationssystem + mönstret .fraga-framhavd |

## Nya mönster
- **.fraga-framhavd** — för de 3–5 frågor som väger tyngst: indigo-mjuk panel,
  96px-scen i vit rundel, 29px seriffrubrik, illustrerade val (.choice.ikon).
  Max en per flödessteg.
- **Illustrationer** — en figur per ämne (Boende=hus, Familj=familj, Ekonomi=mynt …).
  Regler i CSS-kommentaren under "Illustrationer".

## Orubbliga produktprinciper (oförändrade)
En fråga per skärm · Bedömning aldrig beslut · F-STABIL · F-INFO ·
Ärlighet före glans · Gratisvägen sägs alltid intill köpknappar.
