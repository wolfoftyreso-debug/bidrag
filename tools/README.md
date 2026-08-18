# Verifieringsverktyg

Skript som verifierar systemet på nivåer enhetstesterna inte når: verkliga
användarresor genom API:t, webbläsargenomklickningar av gränssnittet och
revisioner av kunskapsbasen.

## Förutsättningar

`playwright` och `esbuild` är deklarerade devDependencies och installeras av
`npm ci`. Själva webbläsaren laddas inte ner automatiskt — kör en gång:

```bash
npx playwright install chromium
```

I miljöer som redan har en webbläsare (t.ex. en förberedd container) räcker
det att peka ut den med `CHROMIUM_PATH` eller `PLAYWRIGHT_BROWSERS_PATH`.

Alla webbläsarskript använder `tools/lib/browser.mjs`, som hittar chromium
portabelt. Sätt `CHROMIUM_PATH` eller `PLAYWRIGHT_BROWSERS_PATH` om din
miljö lägger webbläsaren på ett eget ställe; annars låter det Playwright
välja sin egen installerade webbläsare. Körningsartefakter hamnar i
`artifacts/` (styrs med `ARTIFACTS_DIR`).

## Körningar

```bash
npm run verify:sim30      # 30 påhittade användare genom hela flödet mot API:t
npm run verify:ui         # webbappens huvudflöden + prismodellen (19 kr/ansökan)
npm run verify:schemas    # schematäckning mot kunskapsbasen
npm run verify:smoke      # 402 → köp → kvitto → ansökan, mot ett körande API
```

`verify:sim30`, `verify:ui` och `verify:smoke` kräver ett körande API
(`npm run dev:api`) med `PAYMENTS_MOCK_ENABLED=true`; `verify:ui` kräver
dessutom webbappen (`npm run dev:web`).

## Innehåll

- `simulate30.mjs` — 30 persona genom intag, matchning, betalning och dokument; rapporterar avvikelser
- `uicheck/` — 13 webbläsargenomklickningar av den riktiga webbappen, byggda upp över tid; `uicheck12` täcker intag/teaser/kvitto, `uicheck13` prismodellen
- `audit/` — revisionssviter: red team (`audit-red`, `audit-red2`), master (`audit-master`), AI-motorn (`audit-ai`)
- `schemacheck.mjs` — kontrollerar ansökningsschemanas täckning mot stöden
- `serverless-smoke.mjs` — röktest av den serverlösa ingången (Vercel)
- `smoke-appfee.mjs` — prismodellens kedja: 402 utan kredit → köp 19 kr → kvitto → ansökan skapad
- `gendocs.mjs`, `gendocs-long.mjs` — genererar alla dokumentmallar för granskning av rendering och radbrytning

Rapporterna från revisionerna ligger i `docs/reports/`.
