# Demon

En fristående HTML-fil som kör produktens **verkliga** matchningsmotor
(`@bidrag/core`) och den kurerade kunskapsbasen helt i webbläsaren. Inget
skickas någonstans — hela genomlysningen sker lokalt hos besökaren.

## Bygga

```bash
npm run demo:build      # → artifacts/demo/demo.html
```

Skriptet bygger `@bidrag/core` om det behövs, exporterar kunskapsbasen ur
seed-datan (`demo/demo-opportunities.json`, härledd — versionshanteras inte)
och bundlar allt till en enda självförsörjande fil.

## Verifiera

Kontrollerna kör i en riktig webbläsare; installera den en gång med
`npx playwright install chromium` (se `tools/README.md`).

```bash
npm run demo:check      # sju webbläsarkontroller mot den byggda demon
```

| Kontroll | Vad den bevisar |
|---|---|
| `check.mjs` | grundflödet: intag → teaser → betalning → rapport med källor och kriterier |
| `bizcheck.mjs` | företagarspåret, inklusive att AB-krav redovisas ärligt |
| `backcheck.mjs` | man kan gå tillbaka och ändra svar utan ny betalvägg |
| `savecheck.mjs` | sparat läge överlever omladdning; "börja om" rensar det |
| `kontocheck.mjs` | kvitto och kontovy |
| `vidarecheck.mjs` | F-TEASER/F-VIDARE/F-ÄNDRA/F-HOPP: blurrad teaser utan läckage, plan per valt stöd, ändringsbara svar |
| `ctxcheck.mjs` | §7 informationsvärde: varje öppen fråga säger vilket stöd den avgör, och frågor som inte kan gälla ställs aldrig |

## Filer

- `main.tsx` — hela demoapplikationen (intag, teaser, betalvägg, rapport, plan, konto)
- `demo.css` — demons designsystem, speglar webbappens
- `build.mjs` — bygger allt i ett kommando
- `build-html.mjs` — inline:ar en färdig bundle (används av `build.mjs`)
