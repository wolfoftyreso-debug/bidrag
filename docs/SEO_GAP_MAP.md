# Myndigheternas gap map — Bidragskolls attackyta

Status: Sprint 01, 2026-08-22. **Allt nedan är SERP-belagt** — varje påstående
kommer ur `seo/serp-sprint01.json` (73 verkliga sökningar; kluster-# i
parentes). Metodbrasklappar i `docs/SEO_SPRINT01.md`. Grundhållning från
målgruppsatlasen: myndigheterna är inte inkompetenta — deras svaghet är
**öarna** (var och en svarar bara för sitt stöd) och **sidtypsförvirringen**
(handläggar-/vårdgivar-/nyhetssidor rankar i stället för konsumentsidorna).
Detta dokument analyserar hårt men rättvist.

Kolumnerna: **Bäst på** = respektera, länka dit, konkurrera inte.
**Försöker inte** = Bidragskolls attackyta. **Känt namn?** = kräver sidan att
användaren redan kan stödets namn. **Kalkyl i SERP?** = syntes eget
beräkningsverktyg i sökresultaten.

| Myndighetsyta | Bäst på (SERP-belagt) | Försöker inte (= attackytan) | Känt namn? | Kalkyl i SERP? | Splittring |
|---|---|---|---|---|---|
| **Försäkringskassan** | Egen kalkyl + ansökan + regelfakta per målgrupp; äger "bostadsbidrag hur mycket" (1) | Behovsspråk ("hjälp med hyran med barn" — FK rankar inte alls, 1); jämförelsen med bostadstillägg (2); underhålls-skillnadsfrågan där FK saknas i topp 8 på egen produkt (8); arbetstagarperspektiv; "vad gör jag om jag inte kvalar" | Ja | Ja (bostadsbidrag, bostadstillägg FK-spåret) | Innehållet delat på ≥4 grenar (barnfamilj/unga/arbetssökande/statistik) — användaren måste kunna sin kategori; vårdriktade sidor rankar fel (9) |
| **CSN** | FAQ-svar med exakt frågematch på egna termer (4, 5); nära total dominans på "omställningsstudiestöd villkor" | Jämförelse mellan sina EGNA stöd (6); kombinationer över myndighetsgräns (studiemedel+bostadsbidrag — CSN 4:a, FK frånvarande, 4); behovsspråket "plugga som vuxen med lön" (0 CSN-träffar, 5); årsspecifika beloppssidor (SEO-sajter vinner "csn 2026", 4) | Ja | Nej | Villkor utspridda på många undersidor; totalbilden kräver CSN + omställningsorganisation + fack (5) |
| **Pensionsmyndigheten** | HELA låg pension-klustret: problemformulering, term, belopp, kalkyl synlig i SERP (20, 7) — starkaste myndigheten i undersökningen | Vardagsspråket "hjälp med hyran pensionär" (0 myndigheter — bemannings- och lånesajter kapar, 7); stöd utanför pensionssystemet; anhörigvinkeln; FK/PM-förvirringen om vems bostadstillägg | Nej (20) | Ja | Låg — men tvåspårsförvirringen med FK:s bostadstillägg är obesvarad (7) |
| **Arbetsförmedlingen** | Arbetsgivarriktad produktinfo när termen är känd (10, 11) | Nästan allt annat: frånvarande på "starta eget bidrag" (13, alla tre SERP:ar), sist/frånvarande på väljaren "bidrag för att anställa" (12), osynlig på "blivit arbetslös vad göra" (19), arbetstagarperspektivet på lönebidrag (forumtrådar etta, 10); rankar via nyhetssidor i st.f. produktsidor (11) | Ja | Nej | Störst gap mellan ansvar och SERP-närvaro av alla myndigheter |
| **Socialstyrelsen + 290 kommuner** (försörjningsstöd) | Riksnormens officiella regler (kunskapsstöd) (3) | Privatpersonsvar ("hur mycket får JAG" — Socialstyrelsen osynlig, 3); akutfrågor (0 myndigheter, 16); kommunoberoende kravlista; beloppsberäkning | Ja | Nej | Extrem: slumpvisa kommunsidor + nämnd-PDF:er fyller SERP:en; hyresskuld = fyra olika kommuners lokalsidor (16) |
| **Boverket + kommunerna** (bostadsanpassning) | Regelverket via BAB-handboken (15) | Sökandevägledning (handläggarhandboken + lättläst-sidan rankar i stället för sökandesidan); intygsförberedelse; hitta rätt kommuns e-tjänst; gränsdragning mot hjälpmedel/bostadsbidrag (förvirringen synlig i SERP:en) | Ja | Nej | Boverket splittrar sig på tre sidtyper; 290 kommunala ansökningsvägar = kommunlotteri i SERP |
| **Regionerna + 1177** (glasögonbidrag) | Korrekt regionsinfo när regionen redan är vald (14) | Nationell jämförelse (kan per definition inte göras av en region); föräldervänd väg (vårdgivarsidor rankar etta); beloppen sinsemellan motstridiga i snippets | Ja | Nej | Extrem: 21 regioner + regionssplittrat 1177 + optikerkedjor med säljintresse |
| **Riksidrottsförbundet** (LOK-stöd) | Regelverk + statistik för stödet det äger (22) | Frågeformulerade svar ("hur mycket" — kommersiell blogg vinner, RF:s huvudsida plats 8); räknare; allt utanför idrotten | Ja | Nej | Specialförbund duplicerar varandra; föråldrad PDF från 2020 rankar tvåa |
| **Naturvårdsverket/Energimyndigheten** (energistöd) | Regelverk, omgångar, e-tjänster för Klimatklivet/Ladda bilen (24) | Vägvisning mellan angränsande stöd (grönt avdrag vs Ladda bilen vs Trafikverket — laddboxsäljare fyller tomrummet, utländsk säljare etta på "bidrag laddstation"); beloppskalkyl | Ja | Nej | Trevägsförvirringen (SkV/NV/Trafikverket) förklaras av ingen |
| **Jordbruksverket** | Villkor/belopp/perioder för startstödet (25) | Livshändelsen "ta över gården" (forskning + media toppar); disambiguering av egna snarlika stödnamn; kannibaliserar sig själv via nya.-subdomänen; finska myndigheter tar svenska SERP-platser | Ja | Nej | Måttlig på termen, hög på livshändelsen |
| **ESF/Tillväxtverket/Vinnova** (EU-företagsstöd) | Total dominans på egna varumärkestermer (esf.se 8/8 på "esf utlysning", 23) | Programöverskridande vägledning ("kan mitt företag få EU-bidrag" — media/konsulter/enprogramsidor splittrar); arkiverade publikationer från 2015/16 rankar etta på "starta företag utan pengar" (13) | Ja | Nej | Generiska frågor helt oägda; konsulter säljer i luckan |
| **Länsstyrelserna** (stiftelseregistret) | — registret syntes **inte alls** i fondsökningarna (21) | Allt: situationsmatchning mot fonder ägs av http-småsajter, smslånesajter och en betaldatabas | — | Nej | Störst omatchning mellan datainnehav (stiftelseregistret) och SERP-närvaro |

## Tvärmönstren (attackytans logik)

1. **Öarna**: ingen myndighet svarar på frågor som spänner över flera
   myndigheter — kluster 17 ("vilka bidrag kan jag få") är strukturellt oägbart
   för dem. Varje jämförelse-, kombinations- och samlingsintent är öppen.
2. **Fel sidtyp rankar**: handläggarhandböcker (Boverket), vårdgivarsidor
   (regionerna), kunskapsstöd för professionen (Socialstyrelsen), nyhetssidor
   (AF), arkiverade publikationer (Tillväxtverket) tar konsumentsökningarnas
   platser. Bidragskoll vinner genom att alltid vara konsumentsidan.
3. **Behovsspråket är myndighetsfritt**: "hjälp med hyran", "pengarna räcker
   inte", "plugga som vuxen med lön", "blivit arbetslös vad göra" — noll
   myndigheter i topp. Där står i stället lånesajter, forum och checklistor.
4. **Verktygsformatet vinner**: privata kalkylatorer slår myndigheter med egna
   kalkylverktyg (1, 8, 4). Bidragskolls motor-i-webbläsaren är det starkaste
   vapnet — varje blueprint ska bära en interaktiv komponent.
5. **Rollen mot myndigheterna är komplementär**: på ANGRIP-RUNT-kluster länkar
   vi alltid tydligt till myndighetens kalkyl/ansökan (gratisvägen) — vi tar
   före/mellan/efter-frågorna, inte deras transaktioner. Det är både strategi
   och produktprincip.

*Uppdateras: efter google.se-omvalidering (post-deploy) och därefter per
kvartal mot GSC-data.*
