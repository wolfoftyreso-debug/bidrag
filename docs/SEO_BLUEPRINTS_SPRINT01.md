# 10 Gold Standard Content Blueprints — Sprint 01

Status: 2026-08-22. **Blueprints, inte artiklar** — varje sida specificeras
här innan en rad text skrivs. Urval: de 10 mest värdefulla av sprintens 13
ETTA-MÖJLIG-kluster (`seo/serp-sprint01.json`), viktade mot konsumentkärnan
(atlasens ledare A/C först). **Utanför denna omgång:** kluster 21
(fonder/stipendier — kräver stiftelsedata som inte finns i seeden; byggs efter
F2-ingestion, aldrig ur påhittade fondlistor), kluster 22 (förening) och 10
(lönebidrag) — nästa omgång.

Gemensamt för alla tio (ur `docs/CONTENT_ENGINE.md`):
- **CAS ≥ 90** (Tier 1) genom hela 16-stegs kvalitetsloopen; namngiven
  granskare krävs (beslut §11.2 — blockerare tills bemannad).
- Obligatoriska moduler överallt: (1) direkt svar på första skärmen,
  (2) enkel svenska, (17) officiell källa per faktapåstående, (20) senast
  faktiskt kontrollerad (= seedens CURATED_AT-princip, aldrig kosmetiskt datum),
  (16) ändringshistorik (source-fetch-diffen), tydlig myndighetsöverlämning
  ("att ansöka själv är alltid gratis").
- **Verktygskomponenten är kärnan, inte dekoration** — SERP-beviset är att
  kalkylatorformatet slår myndigheter (foraldrakalkylatorn > FK). Verktygen är
  tunna UI-lager på core-motorn (kriterie-DSL + matchpoäng körs redan i
  webbläsaren i demon). Språkregel: "ansökningsberedskap/ser ut att kunna ha
  rätt till", aldrig "du får/chans att beviljas".
- Interna länkar hämtas ur `seo/kunskapsgraf.json` (relaterad-kanterna), aldrig
  handplockas ad hoc.

Format per blueprint: **Nod** (URL) · **Målqueries** (ur query-universum) ·
**Slår topp 3 genom** (SERP-belagt) · **Moduler** (nummer ur gold standard-20)
· **Verktyg** · **Källor**.

---

## B1 — Vilka bidrag kan du få? (samlingsvyn) — kluster 17
**Nod:** `/situationer/vilka-bidrag-kan-jag-fa/` · **Ledare:** alla · **Prio 1**
**Målqueries:** vilka bidrag kan jag få · vilka bidrag har jag rätt till · räkna ut vilka bidrag jag kan få
**Slår topp 3 genom:** dagens bästa svar är Frälsningsarméns statiska lista och två intent-fel i topp 4; ingen myndighet kan äga frågan. Vi svarar med det enda strukturellt överlägsna formatet: interaktiv situationsingång ("svara på några frågor → se vilka stöd som ser lovande ut") + answer-first-text per livssituation.
**Moduler:** 1, 2, 4 (interaktiv behörighetsingång), 7 (scenarier per livssituation), 12, 13, 16, 17, 18, 19, 20.
**Verktyg:** motorns fråge-/matchflöde i lättviktsversion (samma som demon) — gratis, utan konto; tydlig gräns mot den fullständiga utredningen (kluster 17-regeln: innehållsvyn låtsas aldrig vara utredningen).
**Källor:** samtliga berörda stödkällor ur seeden (redan källmärkta).

## B2 — Akut: kan inte betala hyran — kluster 16
**Nod:** `/situationer/kan-inte-betala-hyran/` · **Ledare:** A · **Prio 1**
**Målqueries:** kan inte betala hyran hjälp · akut hjälp med hyran · hjälp med hyresskuld
**Slår topp 3 genom:** toppen är tre Malmö-forumtrådar, kommunala bostadsbolags egna-hyresgäst-sidor och ett låneforum. Vi levererar det ingen har: rikstäckande handlingsplan med tidsordning — (1) kontakta hyresvärden, (2) socialtjänstens nödbistånd + 3-veckorsregeln vid uppsägning, (3) bostadsbidrag framåt, (4) fonder — plus "hitta din kommuns socialjour". Att ta positionen från snabblånespåret är konsumentskydd.
**Moduler:** 1, 2, 8 (steg-för-steg), 10 (tidslinje med frister), 11, 12, 16, 17, 19, 20.
**Verktyg:** kommunväljare → rätt socialtjänstingång; behörighetskoll bostadsbidrag.
**Källor:** Kronofogden (processen), Socialstyrelsen (bistånd), FK (bostadsbidrag), hyreslagen (12 kap. JB) — allt länkat.
**YMYL-not:** akut målgrupp — extra varsam ton, inga löften, socialjour synlig högst upp.

## B3 — Försörjningsstöd: krav, belopp och hur du söker — kluster 3
**Nod:** `/bidrag/kommun-forsorjningsstod/` (fördjupad kanonisk sida) + `/guider/forsorjningsstod-hur-mycket/`
**Målqueries:** försörjningsstöd krav · hur mycket är försörjningsstöd · riksnormen 2026 belopp · socialbidrag
**Slår topp 3 genom:** SERP:en är kommunlotteri + nämnd-PDF:er; Socialstyrelsen osynlig på beloppsfrågan. Vi ger nationell riksnormstabell per hushållstyp (officiell källa), kravlistan inkl. aktivitetskravet, och ärlig kommunbrasklapp ("skäliga kostnader bedöms av din kommun") + kommunväljare.
**Moduler:** 1, 2, 3, 5 (diskvalificerande: tillgångar först), 6 (riksnorm + boende), 7, 8, 9 (dokumentchecklista), 11, 12, 16, 17, 19, 20.
**Verktyg:** riksnormsberäkning för hushållet (ur officiella normtabellen; visar "ungefärlig norm — kommunen beslutar").
**Källor:** Socialstyrelsen (riksnormen), SoL 4 kap., regeringens normbeslut.

## B4 — Bostadsbidrag eller bostadstillägg? (avgöraren) — kluster 2
**Nod:** `/jamforelser/bostadsbidrag-eller-bostadstillagg/`
**Målqueries:** bostadsbidrag eller bostadstillägg · skillnad bostadsbidrag bostadstillägg · kan man få både
**Slår topp 3 genom:** ingen myndighet försöker jämföra (FK/PM beskriver varsitt stöd); toppen är juridik-Q&A och nischsajt. Vi svarar med avgörartabell + tre frågor ("ålder? ersättningstyp? barn?") → rätt spår + rätt myndighet, inkl. kombinationsregeln som ingen visar i titel/snippet.
**Moduler:** 1, 2, 4 (trefrågeavgörare), 5, 7, 12, 13 (tabellen), 16, 17, 19, 20.
**Verktyg:** avgörar-widget (tre val → spår + länk till rätt myndighetskalkyl).
**Källor:** FK + Pensionsmyndigheten, med respektive kalkyl länkad (deras kalkyler är bra — vi konkurrerar om vägvalet, inte beräkningen).

## B5 — Bidrag för dig som är ensamstående förälder — kluster 18
**Nod:** `/situationer/ensamstaende-foralder/`
**Målqueries:** bidrag ensamstående förälder · bidrag barnfamilj · ekonomiskt stöd barnfamilj
**Slår topp 3 genom:** undersökningens svagaste SERP (nyhetsartikel, lagtext 1992, lånesajt, donationssida i topp 4; FK helt frånvarande). Vi paketerar: underhållsstöd + bostadsbidrag + barnbidrag/flerbarnstillägg + kommunala stöd + fonder, med ansökningsordning och typscenarier — det Frälsningsarméns lista gör statiskt gör vi beräknat och situationsfiltrerat.
**Moduler:** 1, 2, 4, 6, 7 (tre typscenarier), 8, 12, 13, 14 (efter F2), 16, 17, 19, 20.
**Verktyg:** situationsingången (delmängd av B1 med förifylld situation).
**Källor:** FK, Socialstyrelsen, seedens barnstöd; personas PER-001/-002 styr språket (aldrig moraliserande).

## B6 — Underhållsstöd eller underhållsbidrag — vad gäller er? — kluster 8
**Nod:** `/jamforelser/underhallsstod-eller-underhallsbidrag/`
**Målqueries:** underhållsstöd eller underhållsbidrag · separerat vem betalar för barnen · underhållsstöd belopp
**Slår topp 3 genom:** FK frånvarande i topp 8 på sin egen produkt; ~7 utbytbara juristbyråers leadgen äger skillnadsfrågan. Vi ger neutral, beloppssatt jämförelse (underhållsstödets fasta nivåer per ålder med källa) + beslutsträd ("kan ni komma överens? betalar den andra föräldern?") + nästa steg per utfall — utan advokatförsäljning.
**Moduler:** 1, 2, 4 (beslutsträd), 6 (åldersnivåtabell), 7, 8, 11 (vanliga missförstånd: stöd ≠ bidrag), 12, 13, 16, 17, 19, 20.
**Verktyg:** beslutsträdet; nivåtabell per barnets ålder.
**Källor:** FK (underhållsstöd), FB 7 kap. (underhållsbidrag), Konsumentverkets beräkningsstöd om lämpligt.

## B7 — Studiemedel eller omställningsstudiestöd? — kluster 6
**Nod:** `/jamforelser/studiemedel-eller-omstallningsstudiestod/`
**Målqueries:** studiemedel eller omställningsstudiestöd · vilket studiestöd passar mig · plugga som vuxen med lön
**Slår topp 3 genom:** valfrågans SERP innehåller folkhögskolepersonalsidor, engelska sidor och en teknisk skräpfil; CSN jämför aldrig sina egna stöd. Vi gör sida-vid-sida (belopp/vecka, veckotak, ålderskrav, arbetsvillkor, återbetalning) + snabbtest av omställningsstudiestödets arbetsvillkor (96 mån/14 år, 16 tim/v) + notera de kollektivavtalade tilläggen som ingen samlar.
**Moduler:** 1, 2, 4 (villkorstest), 5, 6, 7, 12, 13, 16, 17, 19, 20.
**Verktyg:** arbetsvillkorstest + jämförelsetabell.
**Källor:** CSN (båda stöden), omställningsorganisationernas publicerade villkor (TSL/Omställningsfonden).

## B8 — Starta eget-bidraget: vem får det och hur mycket — kluster 13
**Nod:** `/bidrag/af-stod-start-naringsverksamhet/` (fördjupad) + `/guider/starta-eget-bidrag/`
**Målqueries:** starta eget bidrag · starta eget bidrag hur mycket · starta företag utan pengar stöd
**Slår topp 3 genom:** AF frånvarande i alla tre SERP:ar; toppinnehållet har motstridiga belopp utan situationslogik; arkiverade 2015/16-publikationer rankar. Vi förklarar den verkliga belopplogiken (aktivitetsstöd: a-kassenivå vs grundbelopp), villkoren, och den ärliga kartan över alternativa vägar (Almi-lån, regionala stöd) — utan låneförsäljning.
**Moduler:** 1, 2, 4, 5, 6 (belopplogiken), 7 (med/utan a-kassa), 8, 11, 12, 13, 16, 17, 19, 20.
**Verktyg:** behörighetskoll ur seedens kriterier (finns redan i motorn).
**Källor:** AF (stödet), FK (aktivitetsstödets utbetalning), förordning 2000:634.

## B9 — Anställa med stöd: väljaren — kluster 12 (+11)
**Nod:** `/jamforelser/anstallningsstod/`
**Målqueries:** bidrag för att anställa · jämför anställningsstöd · nystartsjobb regler/ersättning · vilket anställningsstöd passar
**Slår topp 3 genom:** ingen sida jämför på riktigt; AF sist/frånvarande; SERP:en visar sinsemellan motstridiga takbelopp = föråldrat innehåll. Vi bygger jämförelsetabellen (nystartsjobb/introduktionsjobb/lönebidrag/etableringsjobb + Skatteverkets växa-stöd — den korsmyndighetskombination ingen gör) + kandidatväljare.
**Moduler:** 1, 2, 4 (kandidatväljare), 5, 6, 7, 8, 12, 13 (tabellen), 16, 17, 19, 20.
**Verktyg:** väljaren ("beskriv kandidaten → möjliga stöd + var du ansöker"); ersättningsexempel med aktuella tak (källdaterade — SERP:ens motstridighet är vårt kvalitetsargument).
**Källor:** AF (per stödform), Skatteverket (växa-stöd), förordningar; ledare D.

## B10 — Glasögonbidrag för barn: alla 21 regioner — kluster 14
**Nod:** `/bidrag/region-glasogonbidrag-barn/` (fördjupad med regionstabell)
**Målqueries:** glasögonbidrag barn · glasögonbidrag [region] · glasögonbidrag belopp per region
**Slår topp 3 genom:** strukturell lucka — regionerna kan inte göra nationella jämförelsen, 1177 är regionssplittrat, vårdgivarsidor (fel målgrupp) rankar etta, optikerkedjor säljer i resten. Vi bygger 21-regionerstabellen (belopp, åldersgräns, ansökningsväg, direktavdrag hos optiker) — varje cell med käll-URL + kontrolldatum, i linje med authority-mapens kategoristrategi (parameter, inte 21 kopior).
**Moduler:** 1, 2, 6 (tabellen), 8 (per region), 11 ("landstingsbidrag" heter det inte längre), 12, 13, 16, 17, 19, 20.
**Verktyg:** regionväljare → din regions rad expanderad.
**Källor:** 21 regioners publicerade regler (var och en länkad) — **kravet: alla 21 källor läses innan publicering; tills dess publiceras tabellen med de regioner som är verifierade och "kontrolleras"-markering på övriga, aldrig gissade belopp.**

---

## Byggordning och gate

B1 → B2 → B3 → B4 → B5 (ledare A + hemmaplan först), därefter B6–B10.
Ingen sida publiceras utan: kvalitetsloopens steg 1–11, CAS ≥ 90, namngiven
granskare, källa + kontrolldatum på varje faktapåstående, och verktygs-
komponenten funktionstestad i webbläsarkontrollerna. Efter publicering:
indexeringskontroll + GSC-uppföljning per sida (steg 13–14) innan nästa byggs
i samma kluster.
