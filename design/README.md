# Bidragskoll.se — designsystem "Signal"

Paketerat 2026-08-28 ur Claude Design (designsystemv2signal.html). Ersätter
riktning "Bläck" — samma varma neutraler, samma form och typografi, men en
klarare signalblå identitet och ett nytt märke.

## Innehåll
- `bidragskoll.css` — komplett stilark med nya tokens och komponenter.
  Förs tillbaka till `apps/web/src/styles.css`, `demo/demo.css` och `tools/genseo.mjs`.
- `illustrationer/` — 30 figurer som fristående SVG (viewBox 0 0 96 96, skalbara).
  Speglas till `apps/web/public/illustrationer/`; demon inlinar de tre den använder.
  Filerna är dekorativa (`<img alt="">`) och bär därför inget eget aria-namn.
- `designsystem.html` — dokumentationssidan (levande exempel, nyckelskärmar, röst & ton).

## Viktigaste ändringarna: Bläck → Signal (2026-08-28)
| Område | Bläck | Signal |
|---|---|---|
| Primär | #0056A3 | **#1273d4** (klarare signalblå) |
| Primär mörk / djup | #004481 / #003a6d | **#0d5cae / #0a3f78** |
| Primär mjuk | #e8f0f8 | **#e8f2fd** |
| Fokusring | rgba(0,86,163,.28) | **rgba(18,115,212,.30)** |
| Knappskugga | rgba(0,86,163,.28) | **rgba(10,63,120,.26)** |
| Ny token | — | **--primary-light #6fb2f0** (taklinjen i märket, ljusa accenter) |
| Logotyp | kompassmärke | **taklinje + bock på rundad blå ruta** — "hem" och "bedömt" i en form; under ~24px bär bocken ensam |
| Illustrationer | konturer #232c58, primär #3d4a8c, ljus #8a97d4, mjuk #eef0f9 | **ommålade** till #0a3f78 / #1273d4 / #6fb2f0 / #e8f2fd — samma geometri |
| Figurbibliotek | 22 figurer | **30** (nya: bibliotek, brevlåda, buss, lekplats, myndighetshus, sjukhus, spårvagn, torgstånd) |
| Oförändrat | ytor, text, semantiska färger, radier, skuggor, typsnitt | identiska |

Logotypen bor i `apps/web/public/logo-mark.svg` (enda källan). `node tools/genbrand.mjs`
härleder favicon, app-ikoner och OG-bild ur den — ändra märket, kör skriptet, allt följer med.

## Tidigare ändringar (→ Bläck)
| Område | Förut | Bläck |
|---|---|---|
| Neutraler | kalla grå (#f5f6f8 …) | varma (#f7f5f0, #fffdf9, #e6e2d8) |
| Sekundärtext | #5b6579 | #57534a (höjd kontrast ~6.5:1) |
| Typsnitt | systemstack | Public Sans (UI) + Source Serif 4 (h1/h2, poäng, .brand) |
| Knappar | gradient | platta + indigo-tonad skugga (--shadow-btn) |
| Skuggor | mycket lätta | tydligare djup (--shadow, --shadow-lift) |
| Nytt | — | Illustrationssystem + mönstret .fraga-framhavd |

## Nya mönster
- **.fraga-framhavd** — för de 3–5 frågor som väger tyngst: mjuk blå panel,
  96px-scen i vit rundel, 29px seriffrubrik, illustrerade val (.choice.ikon).
  Max en per flödessteg.
- **Illustrationer** — en figur per ämne (Boende=hus, Familj=familj, Ekonomi=mynt …).
  Regler i CSS-kommentaren under "Illustrationer".

## Orubbliga produktprinciper (oförändrade)
En fråga per skärm · Bedömning aldrig beslut · F-STABIL · F-INFO ·
Ärlighet före glans · Gratisvägen sägs alltid intill köpknappar.
