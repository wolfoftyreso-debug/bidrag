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
båda leden per stödsida: att provider-noden finns och heter det seeden säger,
att `description` ÄR seedens `summary`, att `sameAs` pekar på seedens `sourceUrl`,
att myndighetens namn faktiskt förekommer i sidans text — och att en
ansökningsperiod finns i markupen **om och endast om** seeden har kurerade datum.

## Vad som emitteras (uppmätt 2026-08-29, 157 sidor)

| @type | Antal | Var |
|---|---|---|
| `Organization` | 166 | utgivaren + Bidragskoll självt |
| `GovernmentOrganization` | 76 | myndighet/kommun/region/EU-organ som utgivare |
| `GovernmentService` | 76 | stödet, när utgivaren är offentlig |
| `Service` | 9 | stödet, när utgivaren är stiftelse eller förening |
| `WebSite` / `WebApplication` / `WebPage` / `BreadcrumbList` | 157 vardera | hela ytan |
| `FAQPage` | 102 | sidor med synliga frågor och svar |
| `ItemList` | 4 | hubbar och kataloger |
| `Dataset` | 1 | företagsbidragsindexet |

## Relationen som nu står i markupen

```
Bidragskoll (Organization)
   └── publisher av WebSite / WebApplication
          └── WebPage  ──about──►  Stödet (GovernmentService | Service)
                                      ├── provider ──► Utgivaren (GovernmentOrganization | Organization)
                                      │                   ├── url / sameAs = myndighetens webbplats
                                      │                   └── areaServed = land
                                      ├── areaServed = countries ur seeden
                                      ├── audience  = applicantTypes ur seeden
                                      ├── sameAs    = officiell källa (sourceUrl)
                                      ├── serviceUrl = ansökningssidan
                                      └── hoursAvailable = ENDAST kurerade datum (3 av 85)
                     └── relatedLink ──► relaterade stödsidor (samma lista som syns på sidan)
```

## Medvetna avgränsningar

- **Ingen `Article`/`NewsArticle`/`BlogPosting`.** Sidorna är referens- och
  entitetssidor, inte artiklar. Att stämpla dem som artiklar vore samma sorts
  osanning som en påhittad författare. Vakten fäller det aktivt.
- **Ansökningsperiod på 3 av 85 stöd.** Resten har `deadlineModel`
  (`rolling`, `recurring`, `one_time`, `upcoming_round`) men inga kurerade
  datum. Hellre tyst än ett uppdiktat ansökningsfönster.
- **`datePublished` saknas.** Sätts när sidorna faktiskt publicerats, alltså
  vid deploy — inte innan (docs/PREFERRED_SOURCES.md §6).
- **`FAQPage` behålls** trots att den, enligt uppgift, inte längre ger rich
  results hos Google. Markupen beskriver frågor och svar som faktiskt står i
  sidans synliga text; den är sann oavsett vilka rich results Google för
  tillfället renderar, och andra konsumenter läser den. Den byggdes aldrig för
  ett SERP-utseende. **Ej verifierad mot Googles dokumentation** — se nedan.

## Vad som INTE går att avgöra härifrån

Sandlådans egress-proxy blockerar `developers.google.com` och
`support.google.com` (samma blockerare som stoppade Preferred Sources, se
`docs/PREFERRED_SOURCES.md` §1.1). Allt som beror på **vad Google stödjer just
nu** — vilka rich results som finns kvar, vilka structured-data-funktioner som
pensionerats, hur AI-ytorna använder markup — går därför inte att verifiera i
den här miljön.

Arbetet ovan är medvetet valt för att **inte** bero på det: `provider`,
`areaServed`, `audience` och `sameAs` är sanna beskrivningar av verkligt
innehåll enligt schema.org oavsett vilka rich results Google renderar i dag.
Det som kräver verifiering mot levande dokumentation — att lägga till eller ta
bort typer för ett visst SERP-utseende — är inte gjort och ska inte gissas.
