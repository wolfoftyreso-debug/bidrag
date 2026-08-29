# Föräldralösa UI-genomklickningar (karantän 2026-08-29)

De här skripten kördes en gång men **går inte att köra i dag**. De låg kvar i
`tools/uicheck/` utan att ingå i `npm run verify:ui`, vilket gjorde dem till
en fälla: de såg ut som täckning men var trasiga. De ligger kvar här i stället
för att raderas — materialet är värt att återanvända om flödena ska täckas
igen — men ingen ska tro att de bevisar något.

Uppmätt 2026-08-29 (körande api :3100 + dev:web :5173, rate-limiten utesluten
genom omkörning i isolering):

| Skript | Faller på | Orsak |
|---|---|---|
| `uicheck1.mjs` | `text=Hur gammal är du?` | Intaget frågar efter **födelseår**, inte ålder (uppgift #89 — födelseår ersatte personnummer). |
| `uicheck3.mjs` | `select[aria-label="Aktiv organisation"]` | Organisationsväljaren har ändrats/tagits bort. |
| `uicheck4.mjs` | timeout i intaget | Intagsflödet omarbetat sedan skriptet skrevs. |
| `uicheck5.mjs` | timeout i intaget | Samma. |
| `uicheck6.mjs` | `text=Lås upp din bidragsanalys — 39 kr` | **Betalväggen finns inte.** 39 kr-analysupplåsningen är borttagen (Open Discovery); `tools/semanticguard.mjs` förbjuder till och med formuleringen. |
| `uicheck7.mjs` | `text=Lås upp din bidragsanalys — 39 kr` | Samma borttagna betalvägg. Skriptet testar även dokumentpaketen 19/49/79 kr. |
| `uicheck10.mjs` | `POST /v1/projects/:id/analysis-unlock` | Endpointen tillhör den borttagna 39 kr-modellen. |
| `uicheck11.mjs` | `text=Lås upp din bidragsanalys — 39 kr` | Samma borttagna betalvägg. |
| `faas1-who.mjs` | timeout i intaget | Intagsflödet omarbetat. |

**Att återuppliva ett skript** = skriv om det mot dagens flöde, lägg tillbaka
det i `tools/uicheck/` och koppla in det i `verify:ui` i `package.json`. Ett
skript som inte körs av `verify:ui` hör inte hemma i `tools/uicheck/`.

De fem som lever och körs av `npm run verify:ui`: `uicheck2`, `uicheck8`,
`uicheck9`, `uicheck12`, `uicheck13`.
