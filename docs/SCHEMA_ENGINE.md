# Schema Engine — entitetsgrafen i den publika ytan

Structured data i Bidragskoll är **inte ett SEO-lager ovanpå sidorna**. Det
genereras av `tools/genseo.mjs` ur samma kunskapsbas som driver produkten, så
att ett ändrat stöd, en ändrad myndighet eller ett ändrat villkor slår igenom i
markupen vid nästa bygge. Inga handskrivna JSON-filer.

## Den bärande regeln

**Schema får bara påstå det som (a) står i seeden och (b) syns på sidan.**

Saknas uppgiften utelämnas egenskapen — den gissas aldrig. Det är samma regel
som gäller belopp (`amountNote` utan källa fäller bygget) och samma regel som
Google själv sätter för structured data: markup som beskriver osynligt eller
påhittat innehåll är ett policybrott, inte en finess.

Vakten `tools/schemacheck-seo.mjs` (i verify och `npm run seo:check`) kontrollerar
båda leden på 84 stödsidor, 36 aktörssidor och 12 situationssidor. Per stödsida: att provider-noden finns och heter det seeden säger,
att `description` ÄR seedens `summary`, att `sameAs` pekar på seedens `sourceUrl`,
att myndighetens namn faktiskt förekommer i sidans text — och att en
ansökningsperiod finns i markupen **om och endast om** seeden har kurerade datum.

Per aktörssida: att aktörsnoden finns med rätt `@id` (så `provider` inte pekar i
tomma luften) och rätt typ ur `authority.kind` — en stiftelse får inte stämplas
som myndighet.

Per situationssida: att `ItemList` är **exakt motorns utdata** (vakten kör om
resolveringen mot seeden och jämför både innehåll och ordning), att
`audienceType` är sidans egen H1 och ingen påhittad målgruppsetikett, att
noindex sätts exakt när stödtröskeln inte nås, och att varje fråga sidan
ställer står ordagrant både i seeden och i sidans synliga text.

Och för varje `ItemList`, oavsett sida: att `numberOfItems`
stämmer och att **varje post faktiskt länkas i sidans HTML**.

## Vad som emitteras (uppmätt 2026-08-30, 169 sidor)

| @type | Antal | Var |
|---|---|---|
| `Organization` | 188 | Bidragskoll + stiftelser/föreningar som utgivare |
| `GovernmentOrganization` | 103 | myndighet/kommun/region/EU-organ som utgivare |
| `GovernmentService` | 76 | stödet, när utgivaren är offentlig |
| `Service` | 9 | stödet, när utgivaren är stiftelse eller förening |
| `WebSite` / `WebApplication` / `BreadcrumbList` | 169 vardera | hela ytan |
| `WebPage` | 169 | varav 19 multi-typade `['WebPage','CollectionPage']` |
| `FAQPage` | 102 | sidor med synliga frågor och svar |
| `ItemList` | 59 | varje synlig lista av stöd, aktörer eller situationer |
| `Dataset` | 1 | företagsbidragsindexet |

Multi-typningen är avsiktlig: `CollectionPage` är en subtyp av `WebPage`, och
genom att bära båda förblir vaktens `WebPage`-krav bokstavligt sant samtidigt
som sidans roll framgår. `tools/seocheck.mjs` plattar ut typlistan.

## Relationen som nu står i markupen

```
Bidragskoll (Organization)
   └── publisher av WebSite / WebApplication
          │
          ├── /bidrag/ + hubbar  (WebPage+CollectionPage)
          │      └── ItemList ──► stödsidorna som listas synligt
          │
          ├── /situationer/<situation>/  (WebPage+CollectionPage)
          │      ├── audience  = PeopleAudience | Audience, audienceType = sidans H1
          │      └── ItemList ──► stöden MOTORN för framåt, i motorns ordning
          │
          ├── /bidrag/<stöd>/  (WebPage)
          │      └── about ──► Stödet (GovernmentService | Service)
          │                      ├── provider ────────┐
          │                      ├── areaServed = countries ur seeden
          │                      ├── audience   = applicantTypes ur seeden
          │                      ├── sameAs     = officiell källa (sourceUrl)
          │                      ├── serviceUrl = ansökningssidan
          │                      └── hoursAvailable = ENDAST kurerade datum (3 av 84)
          │                                           │
          └── /finansiarer/<aktör>/  (WebPage)        │
                 ├── about ──► Aktören ◄──────────────┘  SAMMA @id
                 │              (GovernmentOrganization | Organization)
                 │               ├── url / sameAs = officiell webbplats
                 │               └── areaServed   = land
                 └── ItemList ──► aktörens stöd, som listas synligt
```

Det är delningen av `@id` (`#aktor-<key>`) som gör det till en graf i stället
för 84 lösta påståenden: `provider` på en stödsida och entiteten på
finansiärssidan är **samma nod**, och den noden har en egen sida på sajten.

## Medvetna avgränsningar

- **Ingen `Question`/`Answer` på situationssidornas frågelista.** Frågorna
  ("Har du barn som bor hos dig?") är ett behörighetsfilter, inte ett
  fråga-svar-innehåll: sidan ställer dem och besvarar dem inte. `FAQPage` där
  vore markup som beskriver något annat än det som står.
- **Inga Wikidata-`sameAs`.** Att peka ut en myndighet med ett QID vore
  värdefullt för entitetsupplösning, men `wikidata.org` är blockerad av
  sandlådans egress-proxy och ett QID ur minnet är påhittad identitetsdata:
  fel QID påstår att Försäkringskassan är någon annan. `sameAs` pekar därför
  på aktörens **egen officiella webbplats**, som är verifierbar ur seeden.
  Wikidata kan läggas till när uppslagen går att verifiera.
- **Ingen `Article`/`NewsArticle`/`BlogPosting`.** Sidorna är referens- och
  entitetssidor, inte artiklar. Att stämpla dem som artiklar vore samma sorts
  osanning som en påhittad författare. Vakten fäller det aktivt.
- **Ansökningsperiod på 3 av 84 stöd.** Resten har `deadlineModel`
  (`rolling`, `recurring`, `one_time`, `upcoming_round`) men inga kurerade
  datum. Hellre tyst än ett uppdiktat ansökningsfönster.
- **`datePublished` saknas.** Sätts när sidorna faktiskt publicerats, alltså
  vid deploy — inte innan (docs/PREFERRED_SOURCES.md §6).
- **`FAQPage` behålls** trots att rich-resultatet är borta sedan 7 maj 2026
  (verifierat, se nedan). Markupen beskriver frågor och svar som faktiskt står
  i sidans synliga text; den är sann oavsett vilka rich results Google för
  tillfället renderar, och andra konsumenter läser den. Den byggdes aldrig för
  ett SERP-utseende.

## Verifierat mot Googles dokumentation (2026-08-30)

Sandlådans egress-proxy blockerar `developers.google.com` direkt, men
Firecrawl-connectorn hämtar serverside och når den. Tre saker som tidigare
stod som "ej verifierat" är nu lästa ur källan:

| Påstående | Utfall | Källa |
|---|---|---|
| Schema måste motsvara det som syns på sidan | **BEKRÄFTAT** — "Make sure structured data matches the visible content" är en egen rubrik i Googles vägledning för AI-ytorna, och upprepas i *AI features and your website*: "Making sure your structured data matches the visible text on the page" | developers.google.com/search/blog/2025/05/succeeding-in-ai-search; .../docs/appearance/ai-features |
| FAQ rich results är borttagna | **BEKRÄFTAT** — deprecationsnotis maj 2026, funktionen slutade visas **7 maj 2026**, och dokumentationssidan togs bort i juni 2026 | developers.google.com/search/updates |
| Oanvänd markup skadar inte | **BEKRÄFTAT** — "Structured data that's not being used does not cause problems for Search, but also has no visible effects in Google Search" | developers.google.com/search/blog/2023/08/howto-faq-changes |

Den bärande regeln högst upp i det här dokumentet är alltså inte vår egen
uppfinning utan sammanfaller ordagrant med Googles egen formulering. Det är
det starkaste stödet regeln kan få.

**Konsekvens för `FAQPage`:** avgränsningen nedan står kvar, men nu på
verifierad grund i stället för "enligt uppgift". Markupen ger inga rich
results längre och kommer inte att göra det. Den behålls därför bara på den
grund som faktiskt bär: den beskriver sant det som står i sidans synliga text,
och andra konsumenter än Googles rich results läser den. Skulle den
motiveringen falla ska markupen tas bort — inte behållas av vana.

**Ny officiell källa att följa:** Google publicerade i maj 2026 en samlad
vägledning, *optimizing your website for generative AI features on Google
Search* (`developers.google.com/search/docs/fundamentals/ai-optimization-guide`).
Den är inte genomgången rad för rad här; det är nästa steg i GEO-spåret.

## Vad som fortfarande inte går att avgöra härifrån

Vad markupen faktiskt gör i en riktig SERP går inte att mäta härifrån:
Rich Results Test och Search Console kräver en **indexerad, levande URL**, och
domänen är varken deployad eller indexerbar (`docs/PREFERRED_SOURCES.md` §2,
punkt 2). Det gäller alltså inte längre dokumentationen — den är läst — utan
utfallet.

Arbetet ovan är medvetet valt för att **inte** bero på det: `provider`,
`areaServed`, `audience` och `sameAs` är sanna beskrivningar av verkligt
innehåll enligt schema.org oavsett vilka rich results Google renderar i dag.
Det som kräver verifiering mot levande dokumentation — att lägga till eller ta
bort typer för ett visst SERP-utseende — är inte gjort och ska inte gissas.
