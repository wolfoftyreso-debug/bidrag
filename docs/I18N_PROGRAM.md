# I18N-programmet — flerspråkig Bidragskoll

**Status: fas A levererad (upptäcktsslingan). Styrande dokument för allt
språkarbete.** Beslut 2026-08-28: Bidragskoll ska finnas fullt utbyggd på samma
språkpalett som informationsverige.se.

## Språken

| Kod | Språk | Skrift | Riktning | Kvalitetsläge |
|---|---|---|---|---|
| sv | Svenska | latinsk | LTR | **Källspråk** — all text författas här först |
| so | Somaliska | latinsk | LTR | AI-översatt — **prioriterad mänsklig granskning** |
| ar | Arabiska | arabisk | **RTL** | AI-översatt |
| prs | Dari | arabisk | **RTL** | AI-översatt (egen afghansk-persisk vokabulär — ALDRIG en kopia av fa) |
| en | Engelska | latinsk | LTR | AI-översatt |
| es | Spanska | latinsk | LTR | AI-översatt |
| fr | Franska | latinsk | LTR | AI-översatt |
| fa | Persiska | arabisk | **RTL** | AI-översatt |
| ru | Ryska | kyrillisk | LTR | AI-översatt |
| ti | Tigrinja | geez | LTR | AI-översatt — **prioriterad mänsklig granskning** |
| uk | Ukrainska | kyrillisk | LTR | AI-översatt |

Interna koden `prs` renderas som `lang="fa-AF"` i dokumentroten (BCP 47).

## Ärlighetsgränserna (orubbliga)

1. **AI-översatt-etiketten.** Varje icke-svensk vy visar notisen att
   översättningen är AI-gjord och ännu inte granskad av människa — samma
   doktrin som `ai_curated`-stämpeln i kunskapsbasen. Etiketten tas bort per
   språk först när en mänsklig granskare godkänt språket.
2. **Officiella namn översätts aldrig.** Stödens och myndigheternas namn
   (bostadsbidrag, Försäkringskassan, CSN…) visas på svenska i alla språk —
   det är de namnen användaren möter hos myndigheten. Förklaringen runt
   namnet är på valt språk. Svenska systemtermer utan exakt motsvarighet
   behålls med förklaring: *grundskolan, gymnasiet, enskild firma,
   aktiebolag, kommun, län*.
3. **Ansökan förbereds på svenska.** Dokument och ansökningar som går till
   myndigheter är på svenska — det är så de tas emot. Detta sägs i etiketten.
4. **Juridisk text har bindande svensk lydelse.** Villkor, ångerrättssamtycke
   och kvitton översätts inte i fas A–B; vid annat språk visas notisen
   "Villkoren gäller i sin svenska lydelse". Översättning av juridisk text
   kräver juristgranskning per språk (LIMITATIONS §12 utvidgas).
5. **Belopp och regler ägs fortsatt av källan** — översättning ändrar aldrig
   sakinnehåll. "Hitta aldrig på data" gäller på alla språk.

## Arkitekturen

- **Runtime**: `apps/web/src/i18n/index.tsx` — `I18nProvider` (localStorage-
  persistens, `lang`/`dir` på dokumentroten), `useT()` med
  `{platshållare}`-interpolation och sv-fallback, `LanguagePicker`
  (nativt språknamn först), `TranslationNotice`.
- **Språkfiler**: `apps/web/src/i18n/locales/<kod>.ts` — en fil per språk,
  typad mot källspråkets nyckelmängd (`Record<keyof typeof sv, string>`).
- **RTL**: `styles.css` använder logiska egenskaper (`border-inline-*`,
  `text-align: start`, `inset-inline-end`); dokumentroten får `dir="rtl"`
  för ar/prs/fa; riktningspilen på framhävda val speglas explicit.
- **Vakt**: `tools/i18ncheck.mjs` i verify — fäller bygget om något språk
  saknar nycklar, har okända/tomma nycklar, tappat en platshållare, eller om
  en RTL-fil inte innehåller RTL-skrift. Ny UI-sträng utan alla 11
  översättningar kan alltså inte passera verify.

## Faserna

- **Fas A — LEVERERAD**: upptäcktsslingans UI på alla 11 språk: appskal +
  navigering, inloggning/registrering/återställning, översikten, hela
  intagsdialogen (alla frågor, val och art. 9-samtyckestexter), 404,
  villkorsnotis, ärlighetsnotiser. Kvar på svenska (med notis):
  Matches-ytan, Opportunity, ansökningsarbetsytan, dokumentstudion, konto.
- **Fas A2**: resterande sid-UI (Matches, Opportunity, Applications,
  Documents, Account, Search, Calendar, Inbox, betalvyer) + STATE_LABELS.
  Kuratorsverktygen (Admin, RuleEditor) förblir svenska — intern yta.
- **Fas B — LEVERERAD 2026-08-28**: kunskapsbasens innehåll — översättnings-
  minne i databasen (tabell `kb_translations`, migrering 0014) för stöd-
  sammanfattningar och intakefrågor (223 källtexter × 10 språk, seedade ur
  `apps/api/src/seed/i18n/`). Levereras via API:t per `Accept-Language`
  (webben skickar användarens språkval ur språkväljaren). Nyckeln är den
  EXAKTA svenska källtexten: ändras källan (t.ex. kuratorsredigering) missar
  uppslaget och svenskan visas — ärlig, självreglerande fallback. Vakten i
  `tools/i18ncheck.mjs` (verify) kräver full täckning av källmängden i alla
  10 språk och fäller bygget vid föräldralösa nycklar. Titlar (officiella
  namn), villkorsbeskrivningar, dokument och juridik förblir svenska;
  sökningen (`q=`) matchar fortfarande svensk text. Integrationstest:
  `apps/api/test/kbI18n.test.ts`.
- **Fas C**: publika SEO-ytan — kvalitetsgrindad översättning med hreflang
  (`fa-AF` för dari), börjar med hubbarna och de största entity-sidorna.
  ALDRIG maskinöversatta massidor utan granskning (GATE 0-/spam-risk).
  Demon: efter fas B (bundlar samma innehåll).

## Granskningsprotokollet

Per språk: en mänsklig granskare med målspråket som modersmål går igenom
språkfilen mot sv-källan (facköversättning av bidragstermerna, ton, RTL-
rendering), godkännandet loggas här med datum, och först då byts etiketten
för det språket. **so och ti först** — AI-kvaliteten är svagast där och
målgrupperna är centrala för produkten. Granskningsstatus:

| Språk | Granskad av | Datum |
|---|---|---|
| — ingen granskning genomförd ännu — | | |
