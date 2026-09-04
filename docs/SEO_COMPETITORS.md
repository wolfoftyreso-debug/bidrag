# SEO_COMPETITORS — brand-SERP, konkurrenter och entitetsläget

Datum: 2026-08-21 · Metod: 18+ verkliga sökningar (WebSearch) + sidinspektioner
(WebFetch/GitHub). ALL data är SERP-DERIVED. Brasklapp: WebSearch går via ett
USA-index — resultaten kan avvika från google.se. Sökvolymer: DATA_UNAVAILABLE
(inga anges någonstans). Direkta besök på bidragskollen.app, bidragsportalen.se
och mindfulinnovations.se blockerades av nätverksproxyn — bedömningarna bygger
på SERP-snippets, GitHub och appkataloger, märkt per rad. Strukturerad data hos
konkurrenter kunde inte verifieras: DATA_UNAVAILABLE.

## A. Brand-SERP-läget och namnrisken

| Sökterm | Dominerande resultat | Tolkning |
|---|---|---|
| "Bidragskoll" | Ingen exakt entitet. SERP fylls av Bidragskollen (app) + "bidragskalkyl"-innehåll (Björn Lundén, Hogia) | Namnet är i praktiken ledigt — Google har ingen entitet för "Bidragskoll" idag |
| "Bidragskoll.se" | Samma + bidragsportalen.se | Ingen indexerad sajt på domänen ännu |
| "Bidragskollen" | appadvice (App Store), GitHub RobIsr, mindfulinnovations.se, nyheter24 (journalistiskt uttryck om FK-kontroller), bidragskollen.app | TVÅ aktörer delar namnet: gammal app + ny företagsbidragssajt |
| "bidragsportalen" | app/www.bidragsportalen.se + kommunala e-tjänster (Mönsterås, Karlskrona, Falun, Lidingö) + SPSM | Generiskt använt namn, splittrad rymd |
| "alla bidrag Sverige" | Frälsningsarmén, Europaportalen, Ekonomifakta, Informationsverige, arbetsloshetskassa.nu | Ingen stark kommersiell ägare av bred konsumentterm — LUCKA |
| "bidragsguiden" | SPSM, samfalligheterna.se, bidragsguiden.nu, Issuu-PDF:er | Utspätt namn, ingen äger det |

### Namnriskerna

1. **Bidragskollen (appen, Mindful Innovations HB):** iOS/Android-aggregator,
   senast uppdaterad 2020-04-08 (appadvice), GitHub-repo med generisk
   starter-README, 0 stjärnor. mindfulinnovations.se svarar inte på DNS.
   Ser övergiven ut — låg aktiv risk, men ockuperar SERP-utrymme.
2. **bidragskollen.app (den reella konflikten):** aktiv, SEO-driven,
   FÖRETAGSBIDRAG — programmatiska regionguider ("Bidrag för företag i
   Blekinge 2026"), engelska sidor under /en/, AI-ansökningshjälp omnämnd.
   Vem som står bakom: DATA_UNAVAILABLE (anonym i SERP — en förtroendelucka
   att exploatera). Rankar redan på "Bidragskollen"-varianter men i
   företagssegmentet, inte privatpersoner.
3. **Bidragsportalen (bidragsportalen.se):** B2B/B2G-databas "12 000+ bidrag,
   300+ bidragsgivare, sedan 2018", licensmodell mot kommuner, AI-tillägget
   GrantPilot. Inte konsumentinriktad — begränsad direkt konkurrens, stark
   på "bidrag + databas"-termer.

## B. Konkurrentkarta (domäner observerade i sökningarna)

| Domän | Typ | Syns på | Svaghet |
|---|---|---|---|
| bidragskollen.app | Ny SEO-sajt, företagsbidrag | "Bidragskollen", företagstermer | Nylanserad, anonym avsändare, endast företag |
| grantigo.com | B2B-plattform: ansökningseditor + AI ("Selma"), R&D/innovation/EU | org-typ-segment, forsknings-/EU-finansiärer | Endast organisationer (kräver org-nr); ingen privatpersonsväg; projekt/formulär före värde — se §D |
| bidragsportalen.se | B2B-SaaS-databas | "bidragsportalen" | Inlåst bakom konto/licens; ej privatpersoner |
| driva-eget.se | Företagarmagasin | "bidrag starta företag", "eu bidrag företag" | Årsuppdaterade listor, inga verktyg; URL "bidrag-att-soka-2024" med 2026-rubrik (recycling) |
| tillvaxtstod.se | Konsult (resultatarvode) | "företagsstöd", jämförelser | Affärsmodell = konsult, ej självbetjäning |
| stipendielistan.se | Stipendiedatabas (~9 800 ur stiftelseregistren, dagligt uppdaterad) | "stipendier lista" | Endast stipendier; ingen ansökningsförberedelse |
| globalgrant.com | Betaldatabas via bibliotek (20k+5k fonder) | "stipendier söka databas" | Betalvägg/bibliotekskort, gammalmodig |
| foraldrakalkylatorn.se | Kalkylatorsajt | "bostadsbidrag barnfamilj" | Endast föräldrasegmentet — men bevisar att VERKTYGSSIDOR RANKAR |
| homespotter.se | Bostadssajt m. kalkylator | "räkna ut bostadsbidrag" | Bidrag är sidospår |
| arbetsloshetskassa.nu | Innehållssajt | "Bidragsguiden"-artikelserie | Affiliate-typ, inga verktyg |
| zmarta.se/advisa.se/nordea/saldo | Lånesajter/banker | "bidrag ensamstående", "pengar till studier" | Styr mot LÅN — etisk lucka för oss att fylla |
| fralsningsarmen.se | Ideell | "vilka bidrag kan du få" (barnfamiljer) | Bästa samlade konsumentlistan ägs av en ideell — inte staten, inte en produkt |
| ekbladet/vardnadsvalet/lag24 m.fl. | Nischsajter | "bidrag ensamstående mamma" | Tunna listor |

**Mönster:** ingen privat aktör i sökningarna erbjuder tvärgående matchning +
ansökningsförberedelse för PRIVATPERSONER. De kommersiella specialisterna
sitter på företagssidan eller i stipendienischen. Konsumentluckan är öppen.

## B2. Uppmätt styrka (Semrush se, 2026-09-03 — verkliga tal, inte estimat)

Full genomgång: `docs/reports/SEMRUSH_2026-09-03.md` (rådata i
`seo/volumes-semrush-se.json` → `konkurrenter`). Sorterat på organisk trafik.

| Domän | Organiska sökord | Organisk trafik/mån | Ascore / backlinks / ref-domäner | Belägg |
|---|---|---|---|---|
| driva-eget.se | 16 174 | ~31 500 | — | företagarmagasin; "starta eget bidrag" #8, "bidrag" #25, "lönebidrag" #10 |
| funktionshindersguiden.se | 5 930 | ~10 100 | — | lss #4, aktivitetsersättning #5, sjukersättning #8, merkostnadsersättning #3, lönebidrag #4 — enda privata aktör topp-10 på stora stödtermer; målgruppsröst + klusterbredd |
| ekosnurra.com | 765 | ~3 800 | — | privatekonomi-kalkylatorer |
| foraldrakalkylatorn.se | 1 147 | ~2 660 | 11 / 50 / 47 | NOLL före feb 2026 → 2 660 besök/mån i aug; barnbidrag 2024 #2, flerbarnstillägg #5 — verktygssidor rankar utan länkmuskler |
| stipendielistan.se | 1 102 | ~1 260 | — | ~0 hela 2025 → 1 094 besök i aug 2026; stipendium #6, söka fonder privatperson #8 — listsidor ur register rankar |
| arbetsloshetskassa.nu | 2 091 | ~1 020 | — | artikelserie |
| svenskbidragsformedling.se | 311 | ~700 | 22 / 228 / 106 | ~all trafik från EN sida (/soka-bidrag-till-forening/) som är #1 på föreningsvarianterna; högst ascore bland de privata |
| foraldrakalkylen.se | 1 194 | ~650 | — | kalkylator-kopia |
| bidragsportalen.se | 968 | ~570 | — | B2B/B2G bakom licens |
| bidraget.se | 962 | ~330 | — | bred men svag: csn #22, bostadsbidrag #41, bidrag #46 |
| allabidrag.se | 18 | ~22 | — | minimal yta |
| grantigo.com | 45 | ~21 | 10 / 1 108 / 57 | 1 108 backlinks från 57 domäner, ingen organisk synlighet — länkar köper inte rankning här |
| hittabidrag.se | 11 | ~10 | — | #9 på "bidrag" trots 11 sökord |
| bidragskollen.app | 129 | ~5 | 7 / 102 / 66 | namngrannen är trafikmässigt försumbar |
| bidragskoll.se | 0 | 0 | — | nolläge: domänen inte indexerad (parkerad DNS, noindex — se docs/SEO_WAR_ROOM.md §2) |

Slutsatsen skärps av mätningen: Google belönar redan små privata aggregatorer
i bidrags-SERP:arna, och två sajter (foraldrakalkylatorn, stipendielistan)
gick från noll till tusentals besök på sex månader utan länkprofil. De
sökordskluster där en privat sida rankar topp-10 är **PRIVATE-DOMAIN-PROVEN**
och prioriteras (lista i `docs/SEO_WAR_ROOM.md` §4 + rapportens §3).
Den enda privata aktören med topp-10 på stora stödtermer är
funktionshindersguiden.se — inom funktionsnedsättningsklustret; på ekonomisk
utsatthet (försörjningsstöd 18 100, bostadsbidrag 22 200) finns ingen.

## C. Implikationer — att äga namnet (entity-SEO)

1. Google associerar "Bidragskoll" med ingenting eget idag — bygg entiteten
   från dag ett: Organization/WebSite-schema med sameAs, Om oss med orgnr
   (Landvex AB), konsekvent namnskrivning "Bidragskoll" + "Bidragskoll.se"
   i title/OG, publika profiler.
2. Differentiera mot bidragskollen.app: konsekvent tagline mot PRIVATPERSONER
   ("dina bidrag", inte företagens) + synlig avsändare/metod/källpolicy —
   exakt det den anonyma konkurrenten saknar (YMYL-fördel).
3. Bevaka journalistisk användning av "bidragskollen" (nyheter24-mönstret)
   som periodvis förorenar brand-SERP:en.

Fullständig källista: se researchkörningen 2026-08-21 (18 sökningar,
URL:er dokumenterade i agentens rapport, arkiverad i sessionshistoriken).

---

## D. Grantigo — djupanalys (fyndmatris under uppbyggnad)

Tillagt 2026-08-25. **Bevisläge:** 5 skärmdumpar mottagna 2026-08-25 (23:49–
00:09) — grantigo.com (startsida, onboarding, ansökningseditor),
portal.grantigo.com (organisationsformulär) och Grantigos publika
Facebook-sida. Fynden nedan är `CONFIRMED` från dessa; det jag inte sett
(prislista, resultatvyn efter "Hitta finansiering", ev. dold privatpersonsväg)
är fortsatt `DATA_UNAVAILABLE`. Vi fabricerar aldrig hur en konkurrents flöde
ser ut (repo-regel #1).

### D1. Strategisk dom (prövad mot bevis) — BEKRÄFTAD med nyans

Hypotesen höll, men skärmdumparna skärper den på två punkter:

- **Bekräftat:** Grantigo är **B2B/B2G, projekt- och ansökningsdrivet** och
  börjar i praktiken vid **lager 2–3** (`docs/PRODUCT_DOCTRINE.md` §3).
  Kärnprodukten är en ansökningseditor (Sammanfattning/Mål/Genomförandeplan/
  Budget) med AI-experten "Selma", och matchningen sker mot forsknings-/
  innovations-/EU-finansiärer (Vinnova, Horizon Europe, Formas, ERC, EIC,
  Energimyndigheten, Tillväxtverket, Arvsfonden). Portalen kräver
  **organisationsnummer + ett obligatoriskt adressformulär** tidigt — värde
  ligger bakom registrering. Positioneringen är uttrycklig: "FÖR FÖRETAGARE
  (SME) & STORA FÖRETAG".
- **Korrigering av vår hypotes:** Grantigo är **inte** bidragsnamn-drivet vid
  ingång — deras onboarding ("Vem söker finansiering?") är **segment-/
  organisationstypsdriven** (Företag, Startups, Forskare, Föreningar, Lantbruk,
  Kommun, Lärosäten, "Något annat/osäker"). De ber dig alltså välja *vem du är*
  på grov org-nivå, inte namnge ett bidrag. Det är mer upptäckts-orienterat än
  vi antog — men (a) uteslutande för organisationer och (b) bara på segment-
  nivå; de gissar aldrig på din faktiska situation.
- **Den stora, bekräftade flanken:** Grantigo har **ingen privatperson-/
  hushållsväg alls.** Varje ingång är en organisationstyp; portalen kräver
  org-nr. Hela Bidragskolls personspår (bostadsbidrag, sjukskriven,
  ensamstående, pensionär, barnfamilj) är ett segment Grantigo strukturellt
  inte kan betjäna. Öppen flank, inte hypotes.
- **Delad insikt — kräver skärpt differentiering:** Grantigos hero använder
  *exakt* vår "informationsproblem, många vet inte vilka bidrag som finns"-
  insikt. Vår differentiering kan därför aldrig vara insikten ensam — den måste
  ligga i **vem vi tjänar (alla, även privatpersoner)** och **hur lite man
  behöver veta och göra innan värde**. Vi kopierar aldrig deras komplexitet
  (org-formulär, projekt-skrivande som ingång); vi gör skillnaden tydligare.

### D2. Bedömningsperspektiv (fem linser per skärmdump)

Varje skärmdump behandlas som bevismaterial och bedöms i fem perspektiv:

| Perspektiv | Vad vi bedömer |
|---|---|
| **Friktion** | Hur mycket måste användaren förstå och göra före första värdet? |
| **Förkunskapskrav** | Förutsätter flödet att användaren känner till stöd, projektform eller terminologi? |
| **Produktlogik** | Är produkten en upptäcktsmotor, sökmotor eller ansökningsassistent? |
| **Konverteringsrisk** | Var riskerar användaren att avbryta, bli osäker eller känna att arbetet är för stort? |
| **Möjlighet för Bidragskoll** | Vilket konkret krav ska byggas in i vår produkt, kommunikation och SEO? |

### D3. Fyndmatris (fylls per skärmdump)

Kontrollpost-format: **Observation → konsekvens → Bidragskolls motposition →
systemkrav → SEO-konsekvens → testkriterium.**

| # | Sida/steg | Observation | Konsekvens | Bidragskolls motposition | Systemkrav | SEO-konsekvens | Testkriterium | Belägg |
|---|---|---|---|---|---|---|---|---|
| 1 | Startsida/hero (grantigo.com) | "Du kvalificerar oftare än du tror" · "FÖR FÖRETAGARE (SME) & STORA FÖRETAG". Samma "informationsproblem"-insikt som vår. CTA: "Boka strategisk genomgång" + "Se priser". | Löftet gäller bara redan investerande företag; privatpersoner/hushåll adresseras inte. Konsult/pris-CTA = högre tröskel och pris. | Bidragskoll tjänar alla — privatperson, hushåll, förening, företag — självbetjäning 39/19 kr, ingen bokning. | Håll privatperson/situations-spåret som förstahandsyta; ingen sälj-gate före värde. | Hela privatperson/hushålls-universumet är okontesterat — prioritera ontologins 2a-noder. | Privatperson (ej företag) får ≥3 kandidater — vilket Grantigo strukturellt inte kan. | grantigo.com 00:07 · CONFIRMED |
| 2 | Onboarding "Vem söker finansiering?" | Första steget = val av **organisationstyp** (Företag, Startups, Forskare, Föreningar, Lantbruk, Kommun, Lärosäten, "Något annat/osäker") → "så visar vi rätt bidrag, rätt exempel och en demo". Ingen privatpersonsväg. "24 000+ möjligheter". "Jag tittar bara runt". | Grantigo ÄR upptäckts-orienterat men bara på grov segment-nivå (vem = org-typ) och enbart B2B/B2G. De gissar aldrig på din situation; en privatperson har ingen väg in. | Bidragskoll frågar efter **situation**, inte segment ("Vad behöver du hjälp med?" → "Jag har svårt att få ekonomin att gå ihop"), och har ett privatpersonsspår. | Behåll situations-först (finare än org-typ) + privatpersonsspår; `tools/doctrine.mjs` steg A vaktar. | Konkurrera på situation/behov-sökningar (finare än org-typ), där Grantigo bara har segmentsidor. | Sökare utan org-nr/segmentsäkerhet får ändå kandidater. | grantigo.com 23:58 · CONFIRMED (korrigerar tidigare "bidragsnamn-driven"-hypotes) |
| 3 | Portal, Organisation-formulär (portal.grantigo.com) | Kräver **organisationsnummer** ("så hämtar vi uppgifterna automatiskt") + obligatoriska Namn/Adress/Postnummer/Ort tidigt (progress ~15 %). | Du måste ha en organisation och fylla ett registreringsformulär **innan värde** — lager 2–3-tröskel; hushåll utestängda (inget org-nr). | Bidragskoll kräver aldrig org-nr/personnummer, aldrig ett formulär före värde; teasern visar kandidater först. | Värde-före-underlag (doktrin §4) — bevakas av `tools/doctrine.mjs` steg C. | Vinkla innehåll mot "se direkt / utan konto / utan att fylla i". | Kandidatlista utan att ange org-nr eller fylla adressformulär. | portal.grantigo.com 00:09 · CONFIRMED |
| 4 | Ansökningseditor + "matchar mot" | Kärnprodukt = ansökningseditor (Ansökningar/Projekt/Organisation/Feedback/Plan; Sammanfattning/Mål/Genomförandeplan/Budget) + AI-expert "Selma — hela vägen". Matchar mot Vinnova, Horizon Europe, Formas, Tillväxtverket, Energimyndigheten, ERC, EIC, Arvsfonden. | Projekt-/ansökningsdrivet (lager 3), tyngdpunkt R&D/innovation/EU för företag/forskare. Förutsätter att du redan har ett projekt att skriva. | Bidragskoll börjar vid lager 1 (upptäckt ur situation) och täcker konsument-/SME-/föreningsstöd som Grantigos finansiärlista inte rör. | Behåll upptäckt→kvalificering→förberedelse; förberedelse (19 kr) efter upptäckt, aldrig som ingång. | Äg lager-1-sökningar. Överlappszon = R&D/innovation-företagsstöd (konkurrera inte huvudlöst — dessutom kurerings-blockerat, se ontologin ¹). | Användare utan färdigt projekt får ändå relevanta kandidater. | grantigo.com 00:02 · CONFIRMED |
| 5 | Publik Facebook-sida | Content-marketing: "63 miljoner till svenska projekt" (MUCF 5 867 535 € till 72 projekt: ungdomsutbyten, idrottsprojekt, solidaritetsinsatser) + case "stötta Precision Pulmo". "Grantigo Spotlight". Låg interaktion (2 gilla). | Bygger auktoritet via beviljade-projekt-berättelser och rör in i förening/ungdom (MUCF) trots B2B-positionering. Tidigt skede. | Vårt F2/F3-lager (erfarenhetslagret, beviljade projekt, länkbara tillgångar) är samma spel men bredare (även privatpersoner) och källmärkt. | Aktivera F2 beviljade-projekt-datakontraktet (`seo/beviljade-projekt.schema.json`) efter licensgenomgång. | Beviljade-projekt-berättelser + Authority Desk — men offsite FRYST tills GATE 0 är grön. | (F3) minst en länkbar tillgång med källmärkt data publicerad. | FB Grantigo 23:49 · CONFIRMED (publikt) |

### D3b. Bekräftade strategiska fynd (destillat)

1. **Grantigo har ingen privatperson-/hushållsväg** — bekräftat (org-typ-
   onboarding + org-nr-krav i portalen). Vår bredaste, mest okontesterade flank.
2. **Grantigo kräver organisation + projekt före värde** — bekräftat. Vår
   teaser-före-allt (kandidater före betalning/formulär) är den skarpaste
   differentiatorn.
3. **Grantigos PRODUKTINGÅNG är segment-drivet (org-typ), inte situations-
   drivet** — bekräftat. Vårt finare situationslager
   (`docs/SEO_SITUATION_ONTOLOGY.md`) är ytan produkten inte täcker. (Korrigerar
   vår tidigare "bidragsnamn-driven"-hypotes.) **Viktig nyans (batch 2):** deras
   *marknadsföring* är däremot brett situations-/behovsdriven — se §D3c. Skilj
   på produktingången (org-gatad) och contentmotorn (situationsdriven).
4. **Grantigo delar vår "informationsproblem"-insikt** — differentieringen måste
   ligga i *vem* och *hur lite man behöver veta/göra*, aldrig i insikten ensam.
5. **Grantigo = R&D/innovation/EU + konsult/sälj + AI-skrivhjälp (Selma).**
   Bidragskoll = bred självbetjäning, bedömning-ej-beslut. Överlapp endast i
   R&D/innovations-företagsstöd (där vi ändå är kurerings-blockerade — bygg inte
   huvudlöst in i deras starkaste zon).

### D3c. Content marketing (Facebook) — verifierat batch 2 (2026-08-25)

Fem ytterligare skärmdumpar (Grantigos publika FB, inlägg 3 juli–16 aug 2026)
visar **contentmotorn** — som ger en annan bild än den org-nr-gatade produkten:

| Datum | Vinkel | Mekanik | Vår lärdom |
|---|---|---|---|
| 3 juli | Lantbruk (SAM/EU-landsbygd) | "Du missar stöd du redan kvalificerar för … ett informationsproblem, inte ett kunskapsproblem." 3 ofta missade stöd (miljöersättning, kompensationsstöd, investeringsstöd) + engagemangsfråga "Vilket kollar du först?". #jordbruksstöd #EUstöd | Situations-/behovsdriven copy i plain language, med **exakt vår doktrins insikt** — men i verksamhetsram. Engagemangsfråga som interaktionsdrivare. |
| 10 juli | Process/värdeprop | "Förbered idag. Säkra finansiering i höst." 5 steg: Hitta rätt bidrag · Tolka & förstå · Matcha rätt möjlighet · Skriva ansökan · Bevaka & påminna. "Vi gör det svåra enkelt. Allt-i-ett. Hela vägen." | Bekräftar fullservice lager 2–4 inkl. deadline-bevakning (vi har kalender). Positionering: byrå/allt-i-ett, inte självbetjäning. |
| 8 aug | Founder-led ("Max tipsar") | "Tänk inte att ert projekt är för litet": aktivitet i bygden, barn/unga, "gör orten bättre". "20 000–50 000 kr räcker långt." CTA "Beskriv vad ni vill göra i Grantigo och se vilka möjligheter ni matchas med." | Founder-röst + **upptäckt-framing i marknadsföringen** ("beskriv → matchas") — men produkten kräver ändå org-nr. Belopps-transparens. |
| ~10 aug | Kultur/event-jacking (medeltidsveckan) | Kategorikort Scenkonst/Hantverk/Musik/Kulturarv med VEM KAN SÖKA · EXEMPEL · BELOPP (upp till 1,5 Mkr) · ANSÖKNINGSDATUM. | Programmatisk-liknande, detaljrik kategori-education med **belopp + deadlines**, kopplad till evenemang. Stark SEO/social-hybrid. |
| 16 aug | Policy-news-jacking | "FRITIDSKORTET BREDDAS — vad kan det betyda för er förening?" upp till 2 500 kr/barn, 31 mars 2027. | Nyhetsanknuten content på färska policyförändringar, riktad till föreningar. |

**Fynd (batch 2):**

1. **Contentmotorn är situations-/behovsdriven och bred** (lantbruk, småprojekt,
   kultur, förening, barn/unga) — i skarp kontrast till den org-nr-gatade
   produkten. Grantigo exekverar redan "situation → möjlighet"-content-spelet vi
   planerat, men **enbart i projekt-/organisationsramen** ("ert projekt", "er
   förening") — aldrig privatpersonen/hushållet.
2. **Löftes-/leverans-gap att utnyttja:** marknadsföringens löfte ("beskriv vad
   ni vill göra, se vad ni matchas med") krockar med produktens org-nr +
   adressformulär före värde. **Bidragskoll kan faktiskt leverera det
   låg-friktionslöftet** — teaser före allt, inget org-nr.
3. **Personspåret förblir okontesterat** även i contenten — allt är
   verksamhets-/projektramat.
4. **Taktiker att notera (inte kopiera blint):** engagemangsfrågor, founder-röst
   (Max/Marcus), event-/policy-news-jacking, kategorikort med belopp + deadlines.
   Förenliga med vår doktrin **endast källmärkta** — och offsite/social är
   **FRYST tills GATE 0 är grön** (`docs/ZERO_COMPROMISE_GATE.md`). Detta matas
   in i F2/F3-planen, inte i omedelbar handling.

### D4. Vad som INTE ska kopieras

När matrisen fyllts, skilj mekaniskt på fyra kategorier — undvik att härma
komplexitet:

1. Sådant Grantigo gör bra och vi saknar → bygg.
2. Sådant som ser avancerat ut men skapar friktion → undvik medvetet.
3. Sådant som är irrelevant för Bidragskolls modell → ignorera.
4. Möjligheter där vår produktlogik är objektivt starkare → förstärk och
   kommunicera.

### D5. Utdata när matrisen är klar

- Nya/ändrade rader i `docs/SEO_SITUATION_ONTOLOGY.md` (SEO-konsekvenserna).
- Nya poster i `docs/PERFECTION_BACKLOG.md` (systemkraven).
- Ev. skärpning av `docs/PRODUCT_DOCTRINE.md` om ett fynd rör positioneringen.
- Testkriterierna → personor i `tools/simulate30.mjs` / kontroller i
  `tools/doctrine.mjs`.
