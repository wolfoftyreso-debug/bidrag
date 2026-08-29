# I18N-programmet — flerspråkig Bidragskoll

**Status: fas A, A2, B och C v1 levererade; fas D (förberedelselagret)
är identifierad men inte påbörjad — se §Täckningen i siffror.** Styrande dokument för allt
språkarbete. Beslut 2026-08-28: Bidragskoll ska finnas fullt utbyggd på samma
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
- **Fas C v1 — LEVERERAD 2026-08-28**: publika SEO-ytan. EN substantiell
  landningssida per språk på `/{lang}/bidrag/` (10 sidor), byggd av kurerad
  copy (`seo/publik-i18n.json`, 23 strängar × 11 språk) + fas B:s översatta
  sammanfattningar för hela katalogen (129 stödrader per sida). Komplett,
  ömsesidigt hreflang-kluster med `x-default` → svenska katalogen; `fa-AF`
  för dari; `lang`/`dir=rtl` per sida; logiska CSS-egenskaper i den publika
  mallen. Länken in i appen bär `?sprak=xx`, så språket följer med från
  sökresultatet hela vägen in i utredningen. Vakt: `tools/seocheck.mjs`
  kräver rätt `lang`/`dir`, full hreflang-reciprocitet och att varje
  alternate pekar på en sida som finns; `tools/i18ncheck.mjs` vaktar
  strängfilen.

  **Medvetet INTE gjort (och varför):** entity-sidorna per stöd översätts
  inte — deras substans (beskrivning, villkorstexter, ansökningsväg) ligger
  utanför fas B:s omfattning, så en översatt entity-sida skulle bli en
  halvsvensk sida. Målgrupps- och klusterhubbar per språk byggs inte heller:
  det vore 40+ näst intill identiska sidor per språk, dvs. precis den
  doorway-/skalprofil GATE 0 förbjuder. **Expansionsgrind:** fler sidor per
  språk först när (a) motsvarande källtexter är översatta och (b) språket
  passerat granskningsprotokollet nedan.

  Demon: efter fas B/C (bundlar samma innehåll) — ej påbörjad.

## Täckningen i siffror (mätt 2026-08-29)

`tools/i18ncheck.mjs` vaktar att översättningsminnet är **komplett mot sin
egen källmängd** — men säger ingenting om hur stor del av kunskapsbasen den
mängden utgör. Den andelen sjunker varje gång ny svensk text kureras in.
`npm run i18n:cov` mäter just det, per innehållstyp:

| Innehållstyp | Översatt | Andel |
|---|---|---|
| `summary` — stödets sammanfattning | 85/85 | **100 %** |
| `criteria.intakeQuestion` — intagsfråga | 179/179 | **100 %** |
| `criteria.description` — villkorstext | 0/348 | 0 % |
| `schema.fieldLabel` — fältetikett | 2/473 | 0 % |
| `schema.sectionTitle` — formulärsektion | 0/246 | 0 % |
| `schema.fieldGuidance` — fältvägledning | 0/157 | 0 % |
| `applicationMethod` — så ansöker du | 0/85 | 0 % |
| `evidence.description` — underlag | 0/74 | 0 % |
| `schema.title` — formulärets titel | 0/71 | 0 % |
| `amountNote` — belopp | 0/7 | 0 % |
| **Totalt** | **266/1725** | **15 %** |

Bilden är inte att fas B är halvgjord — fas B levererade exakt det den
lovade. Bilden är att **allt som kurerats in efteråt är enspråkigt**:
F-SPECIFIKs ansökningsscheman (473 fält), underlagslistorna, ansökningssätten
och F-BELOPPs sju belopp tillkom efter fas B och ligger utanför minnet.

**Konsekvensen i produkten, konkret:** en somalisktalande användare får
intagsdialogen och matchningarnas sammanfattningar på somaliska — och sedan
ett ansökningsformulär på svenska. Upptäckten är översatt, förberedelsen är
det inte. Det är den enskilt största återstående luckan i språkarbetet.

## Fas D — förberedelselagret (EJ PÅBÖRJAD)

Omfattning i prioritetsordning, störst nytta först:

1. **Ansökningsschemanas fältetiketter och vägledning** (876 förekomster,
   462 unika källtexter) — det användaren faktiskt fyller i.
2. **`applicationMethod`** (63 unika) — meningen "så ansöker du".
3. **`evidence.description`** (54 unika) — underlagslistan före utklicket.
4. **`criteria.description`** (263 unika) — villkorstexten. Störst volym,
   minst brådska: intagsfrågan bär redan innebörden på valt språk.
5. **`amountNote`** (7) — beloppet självt är siffror; meningen runt det
   översätts, aldrig talen eller källan.

Ärlighetsgränserna gäller oförändrat: officiella namn står kvar på svenska,
det **färdiga dokumentet till myndigheten förblir svenskt** (§3), och
etiketten säger det. Fas D översätter alltså *vägledningen fram till*
ansökan — inte ansökan.

Arkitekturen räcker som den är: samma `kb_translations`-tabell, samma
källtextsnyckel, samma självreglerande fallback. Det som krävs är kurering,
inte kod — plus en utvidgning av `translateCriteria`-motsvarigheten till
schema- och underlagsleveransen i `apps/api/src/routes/`.

## Granskningsprotokollet

Per språk: en mänsklig granskare med målspråket som modersmål går igenom
språkfilen mot sv-källan (facköversättning av bidragstermerna, ton, RTL-
rendering), godkännandet loggas här med datum, och först då byts etiketten
för det språket. **so och ti först** — AI-kvaliteten är svagast där och
målgrupperna är centrala för produkten. Granskningsstatus:

| Språk | Granskad av | Datum |
|---|---|---|
| — ingen granskning genomförd ännu — | | |
