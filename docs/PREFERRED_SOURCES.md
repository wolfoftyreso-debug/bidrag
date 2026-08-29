# Google Preferred Sources — beslutsunderlag och implementationsgrind

**Status 2026-08-29: EJ IMPLEMENTERAT. Blockerat uppströms, inte av kod.**

Detta dokument är resultatet av rekognoseringen enligt masterprompten
"Google Preferred Sources — full production implementation". Prompten säger
själv i §1 att **Googles officiella dokumentation har företräde framför
prompten** och i §3 att man **aldrig får fabricera behörighet**. Båda
reglerna pekar åt samma håll i vårt läge: integrationen ska inte byggas än.

Här står varför, exakt vad som måste verifieras, och var sömmen ligger så att
den kan aktiveras med minimal kodändring när blockerarna är lösta.

---

## 1. Varför ingen kod skrevs

### 1.1 Googles dokumentation gick inte att nå (§1)

Sessionens egress-proxy blockerar Googles domäner:

```
developers.google.com   → CONNECT tunnel failed, 403
support.google.com      → CONNECT tunnel failed, 403
```

Firecrawl-connectorn, som annars når externa sidor via sin egen tjänst, föll
bort vid en containeromstart samma dag.

Det gick alltså inte att verifiera något av det §1 kräver: aktuell
behörighet, stödda länder, stödda språk, stödda söksurfaces, publisher-script,
komponentsyntax, deeplink-format, callbacks, stylingregler, domänbeteende.

Att skriva integrationen ändå hade betytt att gissa Googles mekanism ur
minnet. Det är precis det prompten förbjuder — och samma kategori av fel som
red team-fyndet F1 i kunskapsbasen (hellre tomt än ett påhittat belopp).

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

### 1.3 Regionen är osäker och kunde inte kontrolleras

Preferred Sources lanserades begränsat till vissa marknader och språk. Om
Sverige och svenska inte stöds är hela funktionen irrelevant för produkten.
Detta är den **första** frågan att besvara när dokumentationen går att nå —
den avgör om resten av arbetet ska göras alls.

### 1.4 Tre arkitekturkrockar som måste beslutas, inte smygas förbi

**a) Ytan är avsiktligt scriptfri.** Hela den publika SEO-ytan (157 sidor,
`tools/genseo.mjs`) innehåller exakt **ett** `<script>`: JSON-LD-blocket. Noll
JavaScript. Det är en medveten egenskap som bär sidornas prestanda och
GATE 0-profil. Googles publisher-script vore det första skriptet någonsin på
den ytan.

**b) CSP är strikt.** `apps/api/src/server.ts` sätter
`scriptSrc: ["'self'"]`. Googles script kräver en utvidgning. Prompten §5:
utvidga snävt, aldrig `script-src *`. Vilken exakt origin som ska tillåtas
går inte att veta utan dokumentationen.

**c) Det finns ingen analytics.** Projektet har **inget** analysverktyg alls —
inte gtag, inte Plausible, inget. Prompten §11 kräver instrumentering och
säger samtidigt "installera inte en andra analysplattform bara för den här
funktionen". Det finns ingen första. Att välja och införa analytics är ett
eget arkitekturbeslut med GDPR-, consent- och CSP-konsekvenser — det ska inte
smygas in som en bieffekt av en Google-knapp.

---

## 2. Verifieringsordning när blockerarna är lösta

Kör i den här ordningen. Avbryt vid första nej.

1. **Stöds Sverige och svenska?** Läs Googles aktuella dokumentation för
   Preferred Sources. Om nej: avsluta, dokumentera datum, ompröva senare.
2. **Är domänen deployad och indexerbar?** `bidragskoll.se` ska peka på
   Vercel, `x-robots-tag: noindex` ska vara borta, och sidor ska finnas i
   Search Console.
3. **Vilken publisher-mekanism gäller?** Script, komponent, deeplink eller
   kombination. Notera exakt syntax och origin för CSP.
4. **Finns bekräftelse-callback?** Avgör om `preferred_source_confirmed` går
   att mäta. Utan callback gäller strikt: **klick ≠ bekräftat** (§11).
5. **Krävs separat publisher-behörighet?** Search Console-koppling eller
   Google Publisher Center.

Först när 1–3 är gröna får CTA:n exponeras publikt.

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
