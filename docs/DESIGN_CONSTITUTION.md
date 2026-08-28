# DESIGN CONSTITUTION — Bidragskoll.se

Överordnad designlag. Designsystemets tekniska källa är `design/`
(bidragskoll.css + designsystem.html + illustrationer + README — paketerat ur
Claude Design); detta dokument är principerna som styr hur källan får ändras
och användas. Vid konflikt vinner konstitutionen.

Gällande riktning: **"Signal"** (2026-08-28), som ersatte **"Bläck"**
(2026-08-22). Bytet var identitet, inte omdesign: ytor, text, semantiska
färger, radier, skuggnivåer, typografi och alla mönster är oförändrade — det
som ändrades är primärfamiljen (klarare signalblå), den nya tonen
`--primary-light` och märket. Ändringstabellen står i `design/README.md`.

## 1. Känslan: varmt institutionellt ("den varma myndighetskramen")

Myndighetens ordning, saklighet, förutsägbarhet, dokumentation och respekt —
kombinerat med en mycket bra konsumentprodukts enkelhet, snabbhet, mänskliga
språk, pedagogik och feedback. Inte kall myndighet, inte glad fintech, inte
startup-lila, inte "AI". Användaren ska undermedvetet känna: *här kommer jag
inte göra bort mig; här kommer jag förstå; här har någon tänkt igenom det.*

UI:t signalerar alltid tre saker: **Vi vet var du är. Vi har förstått vad du
gjorde. Här är nästa steg.**

## 2. Perfektion är frånvaro av friktion — inte överdesign

En trasig canonical, en otydlig knapp, ett motsägelsefullt belopp och en
konstig formulering är samma typ av kvalitetsfel i olika lager. Zero broken
windows (§32): inga små trasigheter accepteras, för en liten trasighet
signalerar att kanske inte heller informationen stämmer.

## 3. Systemets byggstenar (status)

Definierat och i drift (design/bidragskoll.css): tokens (varma neutraler,
signalblå primärfamilj `--primary` / `-dark` / `-deep` / `-light` / `-soft` /
`-ring`, semantiska färger, guldaccent), typografi (Public Sans UI + Source
Serif 4 för rubriker/poäng/varumärke), radier, elevation (tre skuggnivåer +
CTA-skuggan), knappar (primär/sekundär/subtil med medveten lyft-hierarki),
svarsval (.choice + .ikon + framhävd nyckelfråga med illustrationsscen),
fält, badges, alerts, matchrad + förklaring, tabeller, kv-listor, progress,
frågelistans tre lägen (F-STABIL), inforutan (F-INFO), betalyta, blurmask,
den inbundna låsta rapporten (F-EXKLUSIV), illustrationsbibliotek 22 figurer
med regler (max 3 färger, kontur i deep, varm markrad, aldrig ren dekor, en
figur per skärm, alltid tom alt).

**Märket** är en systemkomponent, inte en bild: en rundad ruta i `--primary`
med en taklinje i `--primary-light` och en bock i `--surface` under — "hem" och
"bedömt" i en form, två streckvikter, runda ändar, inga gradienter. Rutan hör
till märket och får inte plockas bort. Under ~24px (favicon, 32px-ikonen)
faller taklinjen bort och bocken bär ensam med tyngre streck; den regeln
härleds, den ritas inte.
`apps/web/public/logo-mark.svg` är **enda källan**; favicon, app-ikoner och
OG-bilden härleds ur den av `node tools/genbrand.mjs`. Ingen får rita ett eget
märke eller handredigera de härledda filerna — ändra SVG:n, kör skriptet. `tools/svgcheck.mjs`
i verify och CI vaktar båda leden: varje märke och illustration måste vara
välformad XML, och favicon.svg måste bära märkets bock och ingen geometri som
inte står i källan. Vakten finns för
att Signal-märket en gång gick ut med `--` i en XML-kommentar och därmed
renderades som trasig bild — utan att något bygge klagade.

**Saknas som systemkomponenter (M9 i backloggen):** skeleton states, empty
states (`.tomt-lage` finns som CSS men används inte systematiskt), error
states utöver `.alert.error`, accordion, breadcrumbs i appen. Ingen
utvecklare får uppfinna dem lokalt — de läggs i design/ först.

## 4. UX-konstitutionen (varje vy måste klara alla tio)

1 Var är jag? · 2 Vad handlar sidan om? · 3 Vad kan jag göra? · 4 Vad händer
när jag trycker? · 5 Feedback efter varje betydelsefull handling ·
6 Tydligt nästa steg · 7 Säker väg tillbaka · 8 Källor synliga ·
9 Osäkerhet tydligt kommunicerad · 10 Fungerar med mobil och hjälpmedel.
**Nej på någon kritisk punkt = sidan är inte färdig.**

## 5. Mikrointeraktioner — de fasta fraserna

Sparat: **"Sparat — går att ändra."** (finns: svar-kvittot) ·
Villkor uppfyllt: **"Det här grundvillkoret verkar stämma."** ·
Kan inte avgöras: **"Vi behöver en uppgift till för att kunna bedöma detta."** ·
Överlämning: **"Du går nu till [myndighetens] officiella ansökan."** ·
404: **"Vi hittar inte sidan — men vi kan fortfarande hjälpa dig."** (byggd).
Nya mikrocopy-fraser skrivs enligt LANGUAGE_GUIDE.md och läggs till här.

## 6. Inga återvändsgränder (§42)

Ingen sida får sluta med "läs mer hos myndigheten". Myndighetslänken är
överlämningen — sidan erbjuder därutöver alltid nästa relevanta steg:
relaterade stöd, annan kontroll, spara, sök vidare.

## 7. Orubbligt (ärvt från produktprinciperna)

En fråga per skärm · bedömning aldrig beslut · F-STABIL · F-INFO · ärlighet
före glans (mockar/503 syns, blur är mask) · gratisvägen sägs alltid intill
köpknappar · exklusivitet genom materialkänsla, aldrig brådska: inga timers,
ingen konstgjord knapphet, inga förkryssade rutor, inga dark patterns.

## 8. Ändringsprocess

Designändring: design/-källan först (via Claude Design eller direkt) → förs
till apps/web/src/styles.css + demo/demo.css + tools/genseo.mjs (+ `node
tools/genbrand.mjs` om märket rörts) → verify + demokontroller + uicheck
gröna → skärmbildsbevis i PR/commit. En riktningsändring uppdaterar också
`design/README.md`s ändringstabell och §3 här — annars är den inte färdig. Prestanda är
del av design: en ändring som försämrar CWV-målen (SEO_RELEASE_GATE) är inte
färdig.
