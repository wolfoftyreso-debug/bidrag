# SEO_INFORMATION_ARCHITECTURE — URL-struktur, taxonomi och indexeringspolicy

Datum: 2026-08-21. Implementerad grund: tools/genseo.mjs (genereras vid varje
bygge ur apps/api/src/seed/data.ts; QA-vaktad av tools/seocheck.mjs i verify).

## URL-struktur (hub-and-spoke)

```
/                          appen (SPA) — utredningen; INTE en innehållssida
/bidrag/                   huvudhubb: hela katalogen, grupperad          [LIVE i bygget]
/bidrag/privatpersoner/    målgruppshubb                                  [LIVE]
/bidrag/foretag/           målgruppshubb                                  [LIVE]
/bidrag/foreningar/        målgruppshubb                                  [LIVE]
/bidrag/offentlig-sektor/  målgruppshubb                                  [LIVE]
/bidrag/<slug>/            entity-sida per stöd (72 st, seedens slug)     [LIVE]
/guider/<amne>/            question-/guide-sidor (Tier 1: 12 st)          [PLANERAD — redaktionellt]
/situationer/<situation>/  problem-first-hubbar (taxonomi 2)              [PLANERAD]
/villkor                   köpvillkor (finns i appen)                     [LIVE via SPA]
```

Regler: gemener, svenska utan diakritiska tecken i sluggar, alltid trailing
slash, aldrig årtal i URL:en, aldrig query-parametrar på indexerbara sidor.
Entity-sluggar = seedens sluggar (stabila ID:n; ändras aldrig utan 301).

## Taxonomi 1 — målgrupp (implementerad som hubbar)

privatpersoner (familj, barn, boende, studier, arbete, arbetslöshet, sjukdom,
funktionsnedsättning, pension, etablering, utvandring, ekonomisk utsatthet) ·
foretag (starta, anställa, investera, kompetens, innovation, energi/klimat,
jordbruk, regional utveckling, export/EU) · foreningar (idrott, kultur, barn
och unga, lokaler, civilsamhälle, landsbygd) · offentlig-sektor (skola,
kommun/region, forskning, kultur).

## Taxonomi 2 — situation/problem (planerad; öppnar long-tail-ytan)

"jag har låg inkomst" · "jag har blivit arbetslös" · "jag ska börja studera"
· "jag har fått barn" · "jag ska starta företag" · "jag vill anställa" ·
"jag ska energieffektivisera" · "min förening behöver pengar" · "jag har en
funktionsnedsättning" · "jag ska flytta utomlands". SERP-belagt (Del 1,
problem-first-tabellen): denna yta är i praktiken oägd av myndigheterna.

## Entity-first (implementerat)

Kanonisk entitetspost = seedens opportunity-record (namn, typ, målgrupp,
finansiär, belopp, villkor som kriterier, evidenskrav, deadlinemodell,
ansökningsväg, källa, kureringsstatus, kontrolldatum). SEO-sidorna genereras
ur samma post som produktens matchmotor använder — fakta dupliceras aldrig
för hand. Relaterade stöd härleds (samma finansiär → samma instrumenttyp).

## Sidmall — entity (implementerad; endast sektioner med data renderas)

Eyebrow (finansiär · instrumenttyp) → H1 → kort definition → snabbfakta-
tabell (vem/belopp/deadline/ansökningsväg/arbetsinsats) → "Vad är X?" →
"Vem kan få stödet?" (villkoren ur kriterierna, med myndighetsförbehåll) →
"Det här stärker ansökan" → "Underlag som brukar behövas" → Två vägar vidare
(ansök själv gratis hos källan | Bidragskolls utredning med ärlig prisrad) →
ärlighetsruta (ai_curated) → relaterade stöd → källa + senast kontrollerad.

## Structured data (implementerad, validerad i QA)

Organization + WebSite + BreadcrumbList + WebPage (dateModified =
kureringsdatum, about → officiell källa via sameAs). MEDVETET UTELÄMNAT:
FAQPage (sektionerna är inte FAQ), rating/review (fabriceras aldrig),
GovernmentService (vi är inte myndigheten). DefinedTerm/Dataset övervägs för
guide-/datalagret senare.

## Indexeringspolicy

INDEX: /bidrag/-trädet (hubbar + 72 entity-sidor), framtida /guider/ och
/situationer/ som klarar kvalitetsgrinden. NOINDEX/ALDRIG: appens inloggade
vyer (robots.txt Disallow: /projekt /ansokningar /konto /dokument /admin
/inkorg — användarspecifikt innehåll), sökresultat, parametervyer. SPA-skalet
på / behåller sin statiska title/description tills en riktig publik startsida
byggs (RECOMMENDED, eget beslut — ersätter appskalets rot-URL för utloggade).

## Sitemap & robots (implementerade)

sitemap.xml genereras med exakt de byggda sidorna (QA-vaktad 1:1), lastmod =
kureringsdatum. robots.txt: Allow / + Disallow app-vyerna + Sitemap-pekare.
Canonical: absolut URL med trailing slash på varje sida (QA-vaktad).
Vid framtida URL-ändringar: 301 i vercel.json redirects — bryt aldrig en
publicerad URL utan vidarebefordran.
