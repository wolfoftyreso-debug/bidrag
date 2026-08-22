# ZERO-COMPROMISE GATE (GATE 0) — Bidragskoll.se

**Order: STOPPA NY EXPANSION. Bevisa med data, crawls, skärmdumpar och
SERP-jämförelser att content, teknisk SEO, media, UX, trust och intern
länkning är färdiga — innan en enda krona eller timme läggs på extern
länkkraft.** Ingen aggressiv offsite förrän gaten är grön. Frågan gaten
ställer är inte "har vi gjort SEO?" utan: *om vi jämför Bidragskoll med
resultat 1–3 på våra viktigaste sökområden — finns det fortfarande någon
rationell anledning för Google eller användaren att föredra konkurrenten?*

Google själva: det finns ingen åtgärdslista som garanterar förstaplatsen;
fundamenten är people-first, unikt och användbart innehåll, crawlbarhet,
relevanta ord, länkar och teknisk kvalitet (Search Essentials/SEO starter
guide). Gaten operationaliserar det.

Senaste körning och dom: **docs/GATE0_REPORT.md**. Registret:
`seo/gate0-keywords.json`. Maskindelen: `tools/gate0.mjs` (+ `gate0-ux.mjs`,
`gatekeywords.mjs`) — inkopplad i verify.

## §1 Gatens sju block

| Block | Krav (grönt =) | Verktyg/bevis |
|---|---|---|
| **CONTENT** | 300+ rötter kartlagda mot faktisk SERP; query-universum verifierat; Tier 1 exceptionell; inga uppenbara content gaps | `seo/gate0-keywords.json` (status per rot), `seo/serp-gate0.json` (färska observationer), innehållsmatrisen i gate0-rapporten |
| **TECHNICAL** | 100 % crawl; nolltolerans: 404, redirect-kedjor, orphans, dubblett-titlar, dubblett-H1, fel canonical, index-konflikter, trasiga interna/externa länkar, parameterbloat, tomma sidor, JS-renderingsproblem, sitemapfel | `tools/seocheck.mjs` + `tools/gate0.mjs`; externa länkar HTTP-verifieras av `tools/deploy-smoke.mjs` (sandlådan saknar utgående nät) |
| **MEDIA** | 100 % bildinventering: crawlbar URL, relevant bild, rätt omgivande text, korrekt alt, dimensioner, srcset, komprimering, filnamn; OG-assets; ingen generisk skräpmedia. EXIF/IPTC är INTE rankingmekanismen — IPTC-metadata används där attribution/licens faktiskt är relevant | gate0-rapportens mediainventering; `docs/IMAGE_STANDARD.md` (alt=""-policyn för dekorativa illustrationer) |
| **UX** | mobil 320 px perfekt; desktop perfekt; a11y kontrollerad; inga återvändsgränder; ingen oklar CTA | `tools/gate0-ux.mjs` (alla sidor × 2 vyer + skärmdumpar), uicheck-sviten för appen |
| **TRUST** | primärkällor på varje sida; metodik publikt; redaktion/granskare namngivna; rättelsepolicy; "senast verifierad" | käll+datum finns per sida (kod); Trust Center-sidorna (H2) och namngiven granskare (H5) är ÖPPNA gate-blockerare |
| **INTERNAL AUTHORITY** | topic graph klar; internlänkning klar; ankar-audit klar; orphans = 0; Tier 1 ≤ 3 klick | gate0-rapportens länkgraf: in/ut-länkar, djup, PageRank-koncentration, ankarfördelning |
| **MEASUREMENT** | Search Console; analytics; rank tracking; conversion events; baseline sparad | efter deploy (docs/SEO_BASELINE.md + LAUNCH_DEMAND_INTELLIGENCE §5) — kan per definition inte bli grönt före deploy |

**Statusskala per sökområde** (block CONTENT, `seo/gate0-keywords.json`):
`GREEN` exceptionell destination · `YELLOW` bra men inte tillräckligt ·
`RED` rätt innehåll/verktyg saknas · `GREY` queryn bör ägas av myndigheten
(vår roll är komplementär). **GREEN kan aldrig sättas maskinellt** — den
kräver mänsklig sida-mot-sida-jämförelse med faktiska topp-3 (§51-benchmark)
plus kvalitetsloopens granskning. Verktygens maxbetyg är YELLOW.

## §2 Exit-kriteriet

Gaten är passerad när: **0 CRITICAL · 0 HIGH i teknik/media/UX/intern
länkning över hela publika ytan (recrawl-bevisat)**, alla Tier 1-kluster
GREEN, trust-blockets öppna punkter stängda, och mätblocket aktiverat efter
deploy. Fynd → åtgärd → **recrawl** — ett fynd är inte stängt förrän
omkontrollen visar det. Formatet är alltid: N fynd → N åtgärdade →
recrawl → 0 kvar.

## §3 Offsite-doktrinen (gäller EFTER gaten — och reglerna gäller för alltid)

Google pekar uttryckligen ut länkspam: köpta rankinglänkar, överdrivna
länkbyten, automatiserad länkbyggnad och **missbruk av utgångna domäner**
(spam policies). Därför:

1. **Outbound authority först.** Bidragskoll länkar generöst till
   primärkällor — Försäkringskassan, CSN, AF, kommuner, EU, varje
   finansiär. Vi håller aldrig PageRank "inne": *Bidragskoll förklarar.
   Här är originalkällan. Här ansöker du.* Det är en förtroendesignal och
   redan implementerat (80 unika myndighetslänkar på ytan; hälsan
   verifieras i deploy-smoke).
2. **Authority Desk.** Inbound förtjänas redaktionellt. Arbetsfrågan är
   alltid: *varför skulle någon vilja hänvisa till Bidragskoll idag?*
   Målgrupper: journalister, kommuner, regioner, universitet,
   företagsrådgivare, redovisningsbyråer, inkubatorer,
   föreningsorganisationer, arbetsgivarorganisationer, fack, studentkårer,
   bibliotek, rådgivningsverksamheter, branschorganisationer, sakkunniga,
   Wikipedia-källmaterial där vi producerat citerbar originaldata. **Varje
   länk måste ha en legitim redaktionell anledning att existera.** Aldrig
   "köp N backlinks".
3. **Länkmagneter före outreach.** Byggs ur data vi redan äger eller
   skaffar ärligt: *Sveriges Bidragskalender* (seedens verifierade
   fönster/deadlines — SERP-bevisat öppet fält: ingen tvärgående kalender
   existerar), *Sveriges Bidragskarta*, *Bidragsrapporten* (originalstatistik),
   *Beviljandebanken* (offentligt redovisade beviljade projekt —
   licensgenomgång först, datakontraktet finns), *Stöddjungelindex* och
   *Bidragsgapet* (begreppen ur PERFECTION-doktrinen §begreppsbildning —
   publiceras först med definition+datapunkt+metodik), *Myndighetsspråksindex*,
   *Deadline-API/kalenderfeed* (låt andra använda vår data — länken följer).
4. **Nyhetsprodukt: ja, som riktig redaktionell produkt** — bevakning av
   offentlig ekonomi/stöd/finansiering med eget existensberättigande. Inte
   "bidragsnyheter24" med AI-volym och länkar hem. När dess journalistik
   hänvisar till Bidragskolls data är länken konsekvensen av innehållet,
   inte anledningen till sajten.
5. **Web Lab: experimentdomäner för lärande, aldrig PBN.** Billiga domäner
   får användas för att testa arkitektur, titlar, format, kalkylatorer,
   schema, prestanda, indexeringsbeteende. De får ALDRIG bilda ett nätverk
   som korslänkar Bidragskoll för ranking, och utgångna domäner köps aldrig
   för deras länkprofil.
6. **Satellitprodukter (Deadlinekalendern, Föreningsguiden, Projektbanken,
   Stipendieguiden, EU-bevakningen) måste klara testet:** *om Bidragskoll
   inte existerade — vore sajten fortfarande värd att använda?* Nej → bygg
   inte.
7. Nästa masterprompt efter grön gate: **AUTHORITY & DISTRIBUTION** —
   kartlägg de 1 000 svenska domäner vi helst förtjänar en relevant
   hänvisning från: varför de skulle länka, vilket asset som krävs, vem som
   äger relationen.

## §4 Sanningsregler för gaten själv

- SERP-observationer bär alltid metodbrasklappen (WebSearch/USA-index;
  ordning kan avvika; PAA/snippets ej observerbara). Rot utan observation
  får tom ägare och `verifikation: NONE` — aldrig en gissad.
- Inga sökvolymer någonstans — DATA_UNAVAILABLE tills GSC finns.
- Fynd rapporteras med reproduktionssteg och allvarsgrad (red team-reglerna
  gäller); inga fabricerade fynd, inga tystade.
- Gaten är kod där den kan vara kod (verify/CI), dokument bara där mänsklig
  bedömning krävs.
