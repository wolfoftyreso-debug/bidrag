# Google Preferred Sources — beslutsunderlag och implementationsgrind

**Status 2026-08-30: EJ IMPLEMENTERAT — men inte längre blockerat av okunskap.**
Dokumentationen är nu läst och §1.1 är omskriven med källbelagda svar
(Firecrawl-connectorn når Googles domäner som sandlådans proxy blockerar).
Kvarvarande blockerare är **deployn**, inte kunskap.

Detta dokument är resultatet av rekognoseringen enligt masterprompten
"Google Preferred Sources — full production implementation". Prompten säger
själv i §1 att **Googles officiella dokumentation har företräde framför
prompten** och i §3 att man **aldrig får fabricera behörighet**. Båda
reglerna pekar åt samma håll i vårt läge: integrationen ska inte byggas än.

Här står varför, exakt vad som måste verifieras, och var sömmen ligger så att
den kan aktiveras med minimal kodändring när blockerarna är lösta.

---

## 1. Varför ingen kod skrevs

### 1.1 Dokumentationen — LÄST 2026-08-30 (var blockerad, är det inte längre)

Sandlådans egress-proxy blockerar fortfarande Googles domäner direkt
(`developers.google.com` → CONNECT tunnel failed, 403). Firecrawl-connectorn
hämtar däremot serverside och når dem. Följande är läst ur Googles egen
dokumentation, inte ur minnet.

| Fråga | Svar | Källa |
|---|---|---|
| Stöds svenska/Sverige? | **JA.** "Expanding preferred sources to all languages where Google Search is available" | developers.google.com/search/updates, post 23 april 2026 |
| Vilka söksurfaces? | Top Stories, och sedan 20 maj 2026 även **AI Mode och AI Overviews** | samma sida, post 20 maj 2026 |
| Krävs registrering hos Google? | Ingen registrering, ingen Search Console-inställning och inget Publisher Center-steg nämns i dokumentationen. Funktionen är **läsarstyrd**: användaren väljer sina källor | developers.google.com/search/docs/appearance/preferred-sources (uppdaterad 2026-08-20) |
| Vilken mekanism? | Tre alternativ: standard-JS-knapp, avancerad JS med egna designassets, eller **deeplink utan JavaScript** | samma sida |
| Deeplink-format | `https://www.google.com/preferences/source?q=<domän>` — fungerar som vanlig textlänk eller klickbar bild, och även i nyhetsbrev och sociala inlägg | samma sida |
| JS-format | `<script async src="https://news.google.com/swg/js/v1/publisher.js"></script>` + `<div google-add-preferred-source-btn data-theme="dark"></div>`; avancerat läge importerar `preferredSource` från `https://news.google.com/swg/js/v1/publisher.mjs` | samma sida |

**Det avgörande fyndet: deeplinken kräver ingen JavaScript.** Den löser
arkitekturkrockarna (a) och (b) i §1.4 — den scriptfria ytan förblir scriptfri
och CSP:n behöver inte utvidgas alls. Vi ska alltså **inte** ta in Googles
publisher-script.

**Kvarstående osäkerheter, ärligt märkta:**

- **Bekräftelse-callback (§11).** Det avancerade JS-läget exponerar ett
  programmatiskt API (`preferredSource.init` / `addPreferredSource`) och
  "standard script callback queues". Om något av det rapporterar *bekräftat
  val* framgår inte av det jag kunnat läsa. För deeplink-vägen finns ingen
  callback alls, så regeln **klick ≠ bekräftat** gäller oförändrat.
- **Är funktionen meningsfull för oss?** Dokumentationen heter "Guide to
  Preferred Sources in Google Search for **Web Publishers**", och ett svar i
  Googles hjälpforum (EJ officiell dokumentation — behandla som obekräftat)
  beskriver funktionen som "tied to Top Stories personalization". Bidragskoll
  är ingen nyhetsutgivare. Att svenska stöds betyder alltså **inte** att
  funktionen ger oss värde; utvidgningen till AI Mode och AI Overviews är det
  som skulle kunna göra den relevant, och den kopplingen är inte bevisad för
  en icke-nyhetssajt. Detta är nästa sak att avgöra — efter deployn.
- **Rapporterad bugg.** En tråd i Googles webmaster-forum (2026-08, obekräftad)
  beskriver att deeplinken `?q=` fallerar på en intern CSP-överträdelse hos
  Google. Testa deeplinken innan den exponeras publikt.

### 1.2 Domänen är inte behörig — den finns inte i Google (§3)

```
PREFERRED_SOURCE_STATUS = configuration-required (blockerad uppströms)
```

Mätt 2026-08-29:

| Kontroll | Utfall |
|---|---|
| DNS `bidragskoll.se` | 194.9.94.85 / .86 — parkering, **inte Vercel** |
| Produktionssvar | `x-robots-tag: noindex` på hela ytan |
| Indexerade sidor | 0 |
| Rankande sökord (Semrush, tidigare i programmet) | 0 |

Preferred Sources är en mekanism där en användare som **hittar dig i Google**
väljer att se mer från dig. Med noll indexerade sidor finns ingenting att
föredra, och en CTA skulle skicka användaren in i ett flöde för en källa
Google inte känner till. Prompten §3: *"A button that sends users into a dead
or unsupported Google flow is NOT an acceptable implementation."*

Blockeraren är **deployn** (uppgift #99): koppla bidragskoll.se till Vercel +
Neon och ta bort noindex. Ingen mängd kod här löser det.

### 1.3 ~~Regionen är osäker~~ — BESVARAD 2026-08-30: svenska stöds

Frågan som §2 kallade den första att besvara är besvarad: funktionen är
utrullad till **alla språk där Google Sök finns** (23 april 2026), alltså
även svenska. Regionen är inte längre en blockerare. Kvar är i stället
värdefrågan i §1.1: om funktionen betyder något för en icke-nyhetssajt.

### 1.4 Tre arkitekturkrockar som måste beslutas, inte smygas förbi

**a) Ytan är avsiktligt scriptfri — LÖST 2026-08-30.** Hela den publika
SEO-ytan (170 sidor, `tools/genseo.mjs`) innehåller exakt **ett** `<script>`:
JSON-LD-blocket. Noll JavaScript. Det är en medveten egenskap som bär sidornas
prestanda och GATE 0-profil. **Deeplink-varianten kräver ingen JavaScript**
(§1.1), så krocken uppstår aldrig: vi tar inte in Googles publisher-script.

**b) CSP är strikt — LÖST av samma skäl.** `apps/api/src/server.ts` sätter
`scriptSrc: ["'self'"]`. Med deeplinken behöver den inte röras alls. Skulle
JS-knappen någon gång väljas är originet `https://news.google.com` — men det
valet ska då fattas medvetet mot §1.4a, inte glida in.

**c) Det finns ingen analytics.** Projektet har **inget** analysverktyg alls —
inte gtag, inte Plausible, inget. Prompten §11 kräver instrumentering och
säger samtidigt "installera inte en andra analysplattform bara för den här
funktionen". Det finns ingen första. Att välja och införa analytics är ett
eget arkitekturbeslut med GDPR-, consent- och CSP-konsekvenser — det ska inte
smygas in som en bieffekt av en Google-knapp.

---

## 2. Verifieringsordning när blockerarna är lösta

Kör i den här ordningen. Avbryt vid första nej.

1. ~~**Stöds Sverige och svenska?**~~ **BESVARAD 2026-08-30: JA** — alla språk
   där Google Sök finns (§1.1).
2. **Är domänen deployad och indexerbar?** ❌ **NEJ, fortfarande.** Mätt
   2026-08-30: produktionsfunktionen svarar `FUNCTION_INVOCATION_FAILED`
   (`DATABASE_URL` saknas i Vercel) och hela ytan bär `x-robots-tag: noindex`
   eftersom värden är `*.vercel.app`. Detta är den enda kvarvarande hårda
   blockeraren. Uppgift #99.
3. ~~**Vilken publisher-mekanism gäller?**~~ **BESVARAD** — tre varianter,
   varav deeplinken är JS-fri och därför vår väg (§1.1).
4. **Finns bekräftelse-callback?** Delvis besvarad: JS-läget har ett
   programmatiskt API, deeplinken har ingen callback. Så länge vi kör deeplink
   gäller **klick ≠ bekräftat** (§11) — mät aldrig annat än utgående klick.
5. ~~**Krävs separat publisher-behörighet?**~~ **BESVARAD: nej** — ingen
   registrering nämns i dokumentationen (§1.1).

Kvar att avgöra **efter** deployn, i den ordningen: (i) testa att deeplinken
faktiskt fungerar för domänen (rapporterad CSP-bugg, §1.1), (ii) avgör om
funktionen ger en icke-nyhetssajt något värde alls — det är nu den öppna
frågan, inte tillgängligheten.

---

## 3. Sömmen — var koden ska in

Håll Google-specifik kod på **ett** ställe. Resten av produkten ska inte veta
att funktionen finns.

| Lager | Fil | Vad som ska in |
|---|---|---|
| Konfiguration | `apps/api/src/config.ts` | `preferredSourcesEnabled` (default **false**) + verifierad origin |
| CSP | `apps/api/src/server.ts` | snäv utvidgning av `scriptSrc` med Googles verifierade origin |
| Publik yta | `tools/genseo.mjs` | CTA i sidmallen — bakom flaggan, annars ingen markup alls |
| Appen | `apps/web/src/` | CTA-komponent enligt designsystemet Signal |
| Språk | `apps/web/src/i18n/locales/*.ts` | nycklar i alla 11 språk (i18ncheck fäller annars) |

**Flaggan default av** betyder att ytan är exakt som i dag tills någon
medvetet slår på den. Ingen halvfärdig markup, ingen död knapp.

---

## 4. Placering och copy — förberett, inte byggt

Utvärderat mot produktens faktiska ytor (§7). Rangordnat efter avsikt:

1. **Efter utredningens resultat** — användaren har just fått konkret värde
   (matchade stöd med villkor och källa). Högst avsikt. Får aldrig störa
   huvuduppgiften: ligger *efter* "Nästa — förbered ansökan".
2. **Entity-sidorna** (`/bidrag/<stöd>/`) — den som läst klart ett stöd är en
   återkommande läsare av just den sortens innehåll.
3. **Sidfoten** — kompakt, sekundär, aldrig dominerande.

**Inte** startsidan som modal. **Inte** mitt i intaget.

Copy, enligt §9 och `docs/LANGUAGE_GUIDE.md` — kort och saklig, inga
rankningspåståenden:

> **Se mer från Bidragskoll på Google**
> Lägg till oss som föredragen källa så hittar du våra uppdateringar lättare.

Förbjudet: "hjälp oss ranka", "Google rekommenderar oss", "bli följare",
"Google har verifierat oss". Preferred Sources är inte en rankningsröst.

**Får aldrig blandas ihop med** e-postbevakning eller SMS (§8). Tre skilda
relationer, tre skilda handlingar, presenterade var för sig.

---

## 5. Analytics-schema — definierat, inte implementerat

När analytics finns (eget beslut, se §1.4c) gäller:

| Event | När |
|---|---|
| `preferred_source_impression` | CTA:n är faktiskt synlig i viewporten |
| `preferred_source_click` | användaren aktiverar kontrollen |
| `preferred_source_return` | användaren kommer tillbaka från Googles flöde |
| `preferred_source_confirmed` | **endast** om Google exponerar en pålitlig bekräftelse |

Egenskaper: `placement`, `page_type`, `pathname`, `locale`, `device_type`,
`referrer_class`, `component_variant`. Inga personuppgifter.

Nyckeltal: CTR = klick / visningar. Bekräftelsegrad **beräknas inte** utan
verifierbar bekräftelse — ett klick är inte ett val.

---

## 6. GEO-/AI-sökberedskap — reviderat, i gott skick

Granskning av den genererade publika ytan (§15–§16), 157 sidor:

| Kontroll | Utfall |
|---|---|
| Organization / WebSite / WebApplication | 157/157 |
| WebPage med `dateModified`, `inLanguage`, `isPartOf` | 157/157 |
| BreadcrumbList | 157/157 |
| FAQPage där FAQ finns | 102 |
| Canonical, titlar, rubrikhierarki, sitemap, robots | vaktas av `tools/seocheck.mjs` i verify |
| Hreflang-kluster, 11 språk + x-default | vaktas, ömsesidigt |
| Dubblerad bas-URL i JSON-LD | permanent vakt sedan tidigare fynd |

**Medvetet inte tillagt:** `Article`/`NewsArticle`. Sidorna är
referens-/entitetssidor, inte artiklar — §16 säger att schema bara får
beskriva det som faktiskt syns. Att stämpla dem som artiklar vore samma sorts
osanning som en påhittad författare.

**Öppen fråga:** `datePublished` saknas (bara `dateModified` sätts, ur
`CURATED_AT`). Ett publiceringsdatum ska sättas när sidorna faktiskt
publicerats — alltså vid deploy. Att sätta det nu vore ett datum för något som
inte hänt.

---

## 7. Sammanfattning

Funktionen är inte byggd, och det är rätt beslut just nu. Den kräver tre
saker vi inte har: **verifierad dokumentation**, **en deployad och indexerad
domän**, och **ett analysbeslut**. Två av dem är operatörens, en är en
nätverksfråga.

När de är lösta är arbetet litet och avgränsat — sömmen ovan är avsiktligt
smal. Det som skulle ha varit dyrt är att bygga fel sak nu och riva upp den
sedan.
