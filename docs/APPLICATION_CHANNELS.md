# Ansökningskanal-revision — ingångar per stöd & hur ansökan mottas

> **Byggprodukt — redigera aldrig för hand.** Genereras ur sanningsmodellen
> (`apps/api/src/seed/data.ts`) av `tools/appchannels.mjs`. Kanaltaggarna
> extraheras ur den kurerade `applicationMethod`-texten + `authenticationMethod`;
> inga kanaler hittas på. Regenerera efter kanaländringar i seeden:
> `node --experimental-strip-types tools/appchannels.mjs`.

Kurerat läge: **2026-08-13T00:00:00Z**. Stöd i kunskapsbasen: **72**.

## Varför den här revisionen finns

Produktägaren: *"Vi kontrollerar exakt vilka ingångar alla ansökningar har
som alternativ, hur de kan mottas."* Idag lämnas ingen ansökan direkt från
systemet — Bidragskoll **förbereder** ansökan och lämnar över till den
officiella ingången (Open Discovery: "ansök själv"-länken är alltid gratis).
Därför måste varje stöd ha en känd, korrekt ingång och en ärlig beskrivning
av hur ansökan tas emot. Denna fil är facit och gap-listan för det.

## Sammanfattning

**Datatäckning (alla stöd):**

| Fält | Täckning |
|---|---|
| Officiell ansöknings-URL (`applicationUrl`) | 72/72 |
| Preciserad kanaltext (ej generisk standard) | 54/72 |
| Angiven mottagning/autentisering (`authenticationMethod`) | 72/72 |

**Ingångar (kanaltaggar) — antal stöd per kanal (ett stöd kan ha flera):**

| Ingång | Antal stöd |
|---|---|
| E-tjänst/onlinetjänst | 27 |
| Ospecificerad (kräver kurering) | 18 |
| Via mellanhand | 10 |
| Mina sidor (myndighet) | 10 |
| Myndighetsspecifik väg | 9 |
| Kontakt/inskrivning först | 5 |
| Pappersblankett | 2 |
| Bokat besök | 1 |

**Mottagning (hur ansökan tas emot / autentisering) — antal stöd:**

| Mottagning | Antal stöd |
|---|---|
| Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | 34 |
| e-legitimation (BankID e.dyl.) | 24 |
| Kulturrådskonto | 6 |
| EU Login + OID/PIC | 5 |
| MUCF-konto | 2 |
| Vinnova-konto (Intressentportalen) | 1 |

## Gap — stöd med ospecificerad kanal (generisk standardtext)

**18 stöd** bär fortfarande den generiska texten
"Ansökan görs i finansiärens officiella ansökningstjänst." — den officiella URL:en finns, men den exakta ingången och
mottagningsvägen är ännu inte kurerad i klartext. Prioriterad kureringskö:

| Stöd | Myndighet | Mottagning | URL |
|---|---|---|---|
| Allmänna arvsfonden — Projektstöd (`arvsfonden-projektstod`) | Allmänna arvsfonden | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.arvsfonden.se/soka-pengar |
| Boverket — Investeringsbidrag till allmänna samlingslokaler (`boverket-allmanna-samlingslokaler`) | Boverket | e-legitimation (BankID e.dyl.) | https://www.boverket.se/sv/bidrag--garantier/ |
| Formas — Årliga öppna utlysningen (`formas-oppna-utlysningen`) | Formas | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.formas.se/soka-finansiering.html |
| Konstnärsnämnden — Arbetsstipendium (`konstnarsnamnden-arbetsstipendium`) | Konstnärsnämnden | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.konstnarsnamnden.se/stipendier-och-bidrag/ |
| Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor (`konstnarsnamnden-internationellt-kulturutbyte`) | Konstnärsnämnden | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.konstnarsnamnden.se/stipendier-och-bidrag/ |
| Konstnärsnämnden — Kulturbryggan (`konstnarsnamnden-kulturbryggan`) | Konstnärsnämnden | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.konstnarsnamnden.se/stipendier-och-bidrag/ |
| Kulturrådet — Inköpsstöd till folk- och skolbibliotek (`kulturradet-inkopsstod-bibliotek`) | Kulturrådet | Kulturrådskonto | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning) (`kulturradet-litteraturstod`) | Kulturrådet | Kulturrådskonto | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Skapande skola (`kulturradet-skapande-skola`) | Kulturrådet | Kulturrådskonto | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper (`kulturradet-verksamhetsbidrag-scenkonst`) | Kulturrådet | Kulturrådskonto | https://kulturradet.se/sok-bidrag/ |
| MUCF — Organisationsbidrag till barn- och ungdomsorganisationer (`mucf-organisationsbidrag`) | MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor | MUCF-konto | https://www.mucf.se/bidrag |
| Nordisk kulturfond — Projektstöd (`nordisk-kulturfond-projektstod`) | Nordisk kulturfond | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.nordiskkulturfond.org/ |
| Riksantikvarieämbetet — Bidrag till kulturarvsarbete (`raa-kulturarvsbidrag`) | Riksantikvarieämbetet | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.raa.se/ |
| Statens musikverk — Projektbidrag till musiklivet (`musikverket-projektbidrag`) | Statens musikverk | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://musikverket.se/ |
| Svenska Filminstitutet — Stöd till kort- och dokumentärfilm (`filminstitutet-kortfilmsstod`) | Svenska Filminstitutet | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.filminstitutet.se/sv/sok-stod/ |
| Svenska institutet — Creative Force (`si-creative-force`) | Svenska institutet | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://si.se/ |
| Svenska Postkodstiftelsen — Projektstöd (`postkodstiftelsen-projektstod`) | Svenska Postkodstiftelsen | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://postkodstiftelsen.se/ |
| Vetenskapsrådet — Projektbidrag (fri forskning) (`vr-projektbidrag`) | Vetenskapsrådet | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | https://www.vr.se/ |

## Fullständig kanalmatris (per myndighet, per stöd)


### Allmänna arvsfonden (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Allmänna arvsfonden — Projektstöd (`arvsfonden-projektstod`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.arvsfonden.se/soka-pengar |

### Arbetsförmedlingen (3)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Arbetsförmedlingen — Etableringsersättning för nyanlända (`af-etableringsersattning`) | Kontakt först (inskrivning/handläggare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Skriv in dig hos Arbetsförmedlingen; ersättningen ansöks sedan hos Försäkringskassan. | https://arbetsformedlingen.se/ |
| EURES — Targeted Mobility Scheme (jobb i annat EU-land) (`af-eures-targeted-mobility`) | Via mellanhand (optiker/handläggare/kansli/förvaltare) · Kontakt först (inskrivning/handläggare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Kontakta en EURES-rådgivare via Arbetsförmedlingen — ansökan görs innan flytten/resan. | https://arbetsformedlingen.se/ |
| Arbetsförmedlingen — Stöd till start av näringsverksamhet (`af-stod-start-naringsverksamhet`) | Via mellanhand (optiker/handläggare/kansli/förvaltare) · Kontakt först (inskrivning/handläggare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs via Arbetsförmedlingen — kontakta din handläggare. | https://arbetsformedlingen.se/ |

### Boverket (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Boverket — Investeringsbidrag till allmänna samlingslokaler (`boverket-allmanna-samlingslokaler`) | Ospecificerad (generisk standardtext) — kräver kurering | e-legitimation (BankID e.dyl.) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.boverket.se/sv/bidrag--garantier/ |

### CSN — Centrala studiestödsnämnden (6)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| CSN — Hemutrustningslån för nyanlända (`csn-hemutrustningslan`) | Myndighetsspecifik väg (se metodtext) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs hos CSN; kommunmottagandet styr vilka som kan söka. | https://www.csn.se/ |
| CSN — Inackorderingstillägg för gymnasieelever som bor på studieorten (`csn-inackorderingstillagg`) | Myndighetsspecifik väg (se metodtext) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan hos CSN (fristående skola/folkhögskola) eller hos hemkommunen (kommunal skola), inför varje läsår. | https://www.csn.se/ |
| CSN — Omställningsstudiestöd (`csn-omstallningsstudiestod`) | Via mellanhand (optiker/handläggare/kansli/förvaltare) | e-legitimation (BankID e.dyl.) | Ansökan görs hos CSN; omställningsorganisationen kan komplettera med kollektivavtalat stöd. | https://www.csn.se/ |
| CSN — Studiemedel (bidrag och studielån) (`csn-studiemedel`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs i Mina sidor hos CSN (kräver e-legitimation). | https://www.csn.se/ |
| CSN — Studiestartsstöd för arbetslösa med kort utbildning (`csn-studiestartsstod`) | Kontakt först (inskrivning/handläggare) | e-legitimation (BankID e.dyl.) | Kontakta hemkommunen (målgruppsbedömning) och ansök därefter hos CSN. | https://www.csn.se/ |
| CSN — Studiemedel för utlandsstudier (`csn-utlandsstudier`) | Myndighetsspecifik väg (se metodtext) | e-legitimation (BankID e.dyl.) | Ansökan görs hos CSN med e-legitimation. | https://www.csn.se/ |

### Din kommun (4)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Din kommun — Bostadsanpassningsbidrag (`kommun-bostadsanpassningsbidrag`) | Myndighetens e-tjänst/onlinetjänst · Pappersblankett | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs hos din kommun, ofta via e-tjänst eller blankett, med intyg. | https://www.boverket.se/sv/bidrag--garantier/ |
| Din kommun — Stöd för elevresor på gymnasiet (`kommun-elevresor-gymnasiet`) | Myndighetsspecifik väg (se metodtext) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan hos elevens hemkommun, vanligen inför varje läsår. | https://www.riksdagen.se/sv/dokument-och-lagar/ |
| Din kommun — Föreningsbidrag (aktivitets-, lokal- och startbidrag) (`kommun-foreningsbidrag`) | Myndighetsspecifik väg (se metodtext) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan hos kommunens kultur- och fritidsförvaltning — rutiner och tider varierar per kommun. | https://www.skr.se/ |
| Din kommun — Skolskjuts i grundskolan (`kommun-skolskjuts`) | Myndighetens e-tjänst/onlinetjänst · Pappersblankett | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan hos barnets hemkommun (e-tjänst eller blankett). | https://www.skolverket.se/ |

### Din region (2)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Din region — Glasögonbidrag för barn och unga (8–19 år) (`region-glasogonbidrag-barn`) | Myndighetens e-tjänst/onlinetjänst · Via mellanhand (optiker/handläggare/kansli/förvaltare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Vanligen via optikern eller regionens e-tjänst — se din regions rutin på 1177.se. | https://www.1177.se/ |
| Din region — Regionala kulturstöd och projektbidrag (`region-kulturstod`) | Myndighetens e-tjänst/onlinetjänst | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan hos regionens kulturförvaltning — utlysningar publiceras på regionens webbplats. | https://www.skr.se/ |

### Energimyndigheten (2)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Energimyndigheten — Stöd för energi- och klimatprojekt (löpande utlysningar) (`energimyndigheten-energieffektivisering`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs via Energimyndighetens Mina sidor. | https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/ |
| Energimyndigheten — Industriklivet (`energimyndigheten-industriklivet`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs via Energimyndighetens Mina sidor. | https://www.energimyndigheten.se/stod-och-utlysningar/sok-hantera-och-redovisa-stod/ |

### Europeiska kommissionen (Erasmus+/EACEA) (3)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Erasmus+ — Småskaliga partnerskap (KA2) (`erasmus-ka2-smaskaliga-partnerskap`) | Myndighetens e-tjänst/onlinetjänst | EU Login + OID/PIC | Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID). | https://erasmus-plus.ec.europa.eu/ |
| Erasmus+ — Ungdomsutbyten (Youth Exchanges) (`erasmus-plus-ungdomsutbyten`) | Myndighetens e-tjänst/onlinetjänst | EU Login + OID/PIC | Ansökan lämnas i EU:s ansökningssystem för Erasmus+ (kräver EU Login och OID). | https://erasmus-plus.ec.europa.eu/opportunities/individuals/youth-exchanges-and-activities |
| Kreativa Europa — Europeiska samarbetsprojekt (kultur) (`kreativa-europa-samarbetsprojekt`) | Myndighetens e-tjänst/onlinetjänst | EU Login + OID/PIC | Ansökan görs i EU:s Funding & Tenders-portal (kräver EU Login och PIC/OID). | https://ec.europa.eu/info/funding-tenders/opportunities/portal/screen/home |

### Formas (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Formas — Årliga öppna utlysningen (`formas-oppna-utlysningen`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.formas.se/soka-finansiering.html |

### Forte — Forskningsrådet för hälsa, arbetsliv och välfärd (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Forte — Projektbidrag för forskning om hälsa, arbetsliv och välfärd (`forte-projektbidrag`) | Myndighetens e-tjänst/onlinetjänst · Via mellanhand (optiker/handläggare/kansli/förvaltare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan i Fortes ansökningssystem Prisma, via medelsförvaltaren. | https://forte.se/ |

### Försäkringskassan (8)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Försäkringskassan — Aktivitetsersättning vid nedsatt arbetsförmåga (`fk-aktivitetsersattning`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan tillsammans med läkarutlåtande. | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Bilstöd vid funktionsnedsättning (`fk-bilstod`) | Myndighetsspecifik väg (se metodtext) | e-legitimation (BankID e.dyl.) | Ansökan görs hos Försäkringskassan; läkarutlåtande om funktionsnedsättningen och körkortsuppgifter behövs. | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Bostadsbidrag till barnfamiljer (`fk-bostadsbidrag-barnfamiljer`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation). | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Bostadsbidrag för unga (18–28 år) (`fk-bostadsbidrag-unga`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation). | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Merkostnadsersättning vid funktionsnedsättning (`fk-merkostnadsersattning`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); merkostnaderna specificeras. | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Närståendepenning (`fk-narstaendepenning`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan; läkarutlåtande och den sjukes samtycke bifogas. | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Omvårdnadsbidrag för barn med funktionsnedsättning (`fk-omvardnadsbidrag`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan (kräver e-legitimation); läkarutlåtande bifogas. | https://www.forsakringskassan.se/privatperson |
| Försäkringskassan — Underhållsstöd (`fk-underhallsstod`) | Mina sidor hos myndigheten | e-legitimation (BankID e.dyl.) | Ansökan görs på Mina sidor hos Försäkringskassan. | https://www.forsakringskassan.se/privatperson |

### Jordbruksverket (3)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Jordbruksverket — Investeringsstöd för jordbruk (`jordbruksverket-investeringsstod`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation). | https://jordbruksverket.se/stod |
| Jordbruksverket — Startstöd till unga jordbrukare (`jordbruksverket-startstod-unga`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs i Jordbruksverkets e-tjänst (kräver e-legitimation; fullmakt kan användas). | https://jordbruksverket.se/stod |
| Leader — Projektstöd för lokalt ledd utveckling på landsbygden (`leader-lokalt-ledd-utveckling`) | Myndighetens e-tjänst/onlinetjänst · Via mellanhand (optiker/handläggare/kansli/förvaltare) · Kontakt först (inskrivning/handläggare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Kontakta ditt leaderområdes kansli; ansökan lämnas i Jordbruksverkets e-tjänst. | https://jordbruksverket.se/ |

### Konstnärsnämnden (3)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Konstnärsnämnden — Arbetsstipendium (`konstnarsnamnden-arbetsstipendium`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.konstnarsnamnden.se/stipendier-och-bidrag/ |
| Konstnärsnämnden — Bidrag till internationellt kulturutbyte och resor (`konstnarsnamnden-internationellt-kulturutbyte`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.konstnarsnamnden.se/stipendier-och-bidrag/ |
| Konstnärsnämnden — Kulturbryggan (`konstnarsnamnden-kulturbryggan`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.konstnarsnamnden.se/stipendier-och-bidrag/ |

### Kulturrådet (6)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Kulturrådet — Inköpsstöd till folk- och skolbibliotek (`kulturradet-inkopsstod-bibliotek`) | Ospecificerad (generisk standardtext) — kräver kurering | Kulturrådskonto | Ansökan görs i finansiärens officiella ansökningstjänst. | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Resebidrag för internationellt kulturutbyte (`kulturradet-internationellt-resebidrag-musik`) | Myndighetens e-tjänst/onlinetjänst | Kulturrådskonto | Ansökan görs i Kulturrådets onlinetjänst. | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Litteraturstöd (efterhandsstöd till utgivning) (`kulturradet-litteraturstod`) | Ospecificerad (generisk standardtext) — kräver kurering | Kulturrådskonto | Ansökan görs i finansiärens officiella ansökningstjänst. | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Projektbidrag musik (fria musiklivet) (`kulturradet-projektbidrag-musik`) | Myndighetens e-tjänst/onlinetjänst | Kulturrådskonto | Ansökan görs i Kulturrådets onlinetjänst när omgången är öppen. | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Skapande skola (`kulturradet-skapande-skola`) | Ospecificerad (generisk standardtext) — kräver kurering | Kulturrådskonto | Ansökan görs i finansiärens officiella ansökningstjänst. | https://kulturradet.se/sok-bidrag/ |
| Kulturrådet — Verksamhetsbidrag till fria scenkonstgrupper (`kulturradet-verksamhetsbidrag-scenkonst`) | Ospecificerad (generisk standardtext) — kräver kurering | Kulturrådskonto | Ansökan görs i finansiärens officiella ansökningstjänst. | https://kulturradet.se/sok-bidrag/ |

### Länsstyrelsen i ditt län (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Länsstyrelsen — Bygdemedel (`lansstyrelsen-bygdemedel`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs hos länsstyrelsen i ditt län, ofta via e-tjänst. | https://www.lansstyrelsen.se/ |

### Majblommans Riksförbund (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Majblomman — Bidrag till barn i familjer där pengarna inte räcker (`majblomman-bidrag-barn`) | Via mellanhand (optiker/handläggare/kansli/förvaltare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan till din lokala majblommeförening via majblomman.se. | https://majblomman.se/ |

### Migrationsverket (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Migrationsverket — Stöd vid frivillig återvandring (`migrationsverket-atervandringsbidrag`) | Myndighetsspecifik väg (se metodtext) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs hos Migrationsverket före utresan. | https://www.migrationsverket.se/ |

### MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor (3)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| MUCF — Organisationsbidrag till barn- och ungdomsorganisationer (`mucf-organisationsbidrag`) | Ospecificerad (generisk standardtext) — kräver kurering | MUCF-konto | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.mucf.se/bidrag |
| MUCF — Projektbidrag för barn- och ungdomsorganisationer (`mucf-projektbidrag-ungdomsorganisationer`) | Myndighetens e-tjänst/onlinetjänst | MUCF-konto | Ansökan görs i MUCF:s ansökningssystem när en utlysning är öppen. | https://www.mucf.se/bidrag |
| MUCF — Europeiska solidaritetskåren: volontärprojekt (`mucf-solidaritetskaren-volontarprojekt`) | Myndighetens e-tjänst/onlinetjänst | EU Login + OID/PIC | Ansökan görs i EU:s ansökningssystem (kräver EU Login, OID och Quality Label). | https://www.mucf.se/bidrag |

### Naturvårdsverket (3)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Naturvårdsverket — Klimatklivet (`naturvardsverket-klimatklivet`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs i Naturvårdsverkets e-tjänst när en omgång är öppen (kräver e-legitimation). | https://www.naturvardsverket.se/bidrag/ |
| Naturvårdsverket — Bidrag för miljö- och klimatåtgärder (organisationer) (`naturvardsverket-ladda-bilen-organisationer`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs i Naturvårdsverkets e-tjänster. | https://www.naturvardsverket.se/bidrag/ |
| Naturvårdsverket — Lokala naturvårdssatsningen (LONA) (`naturvardsverket-lona`) | Via mellanhand (optiker/handläggare/kansli/förvaltare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Kommunen ansöker via länsstyrelsen; föreningar initierar via sin kommun. | https://www.naturvardsverket.se/bidrag/ |

### Nordisk kulturfond (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Nordisk kulturfond — Projektstöd (`nordisk-kulturfond-projektstod`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.nordiskkulturfond.org/ |

### Pensionsmyndigheten (2)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Pensionsmyndigheten — Äldreförsörjningsstöd (`pm-aldreforsorjningsstod`) | Myndighetsspecifik väg (se metodtext) | e-legitimation (BankID e.dyl.) | Ansökan görs hos Pensionsmyndigheten (kräver e-legitimation). | https://www.pensionsmyndigheten.se/ |
| Pensionsmyndigheten — Bostadstillägg för pensionärer (`pm-bostadstillagg`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs på Pensionsmyndighetens webbplats (kräver e-legitimation). | https://www.pensionsmyndigheten.se/ |

### Radiohjälpen (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Radiohjälpen — Projektbidrag ur insamlingskampanjerna (`radiohjalpen-projektbidrag`) | Myndighetsspecifik väg (se metodtext) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan enligt respektive utlysning på radiohjalpen.se. | https://www.radiohjalpen.se/ |

### Riksantikvarieämbetet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Riksantikvarieämbetet — Bidrag till kulturarvsarbete (`raa-kulturarvsbidrag`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.raa.se/ |

### Riksidrottsförbundet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Riksidrottsförbundet — Statligt lokalt aktivitetsstöd (LOK-stöd) (`rf-lok-stod`) | Myndighetens e-tjänst/onlinetjänst | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan/redovisning görs i IdrottOnline. Ansökningsperioderna stänger 25 februari och 25 augusti. | https://www.rf.se/bidrag-och-stod |

### Socialtjänsten i din kommun (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Socialtjänsten — Försörjningsstöd (ekonomiskt bistånd) (`kommun-forsorjningsstod`) | Myndighetens e-tjänst/onlinetjänst · Bokat besök · Via mellanhand (optiker/handläggare/kansli/förvaltare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs hos socialtjänsten i din kommun — ofta via kommunens e-tjänst eller ett bokat besök. | https://www.socialstyrelsen.se/ |

### Sparbanksstiftelsen i ditt område (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Sparbanksstiftelsen i ditt område — Bidrag till lokala projekt (`sparbanksstiftelsen-projektstod`) | Via mellanhand (optiker/handläggare/kansli/förvaltare) | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan hos den sparbanksstiftelse vars område ni verkar i — rutiner varierar per stiftelse. | https://www.sparbankerna.se/ |

### Statens musikverk (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Statens musikverk — Projektbidrag till musiklivet (`musikverket-projektbidrag`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://musikverket.se/ |

### Svenska ESF-rådet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Svenska ESF-rådet — ESF+ projektstöd för kompetensutveckling och omställning (`esf-kompetensutveckling`) | Myndighetens e-tjänst/onlinetjänst | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i ESF-rådets Projektrummet när en utlysning är öppen. | https://www.esf.se/utlysningar/ |

### Svenska Filminstitutet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Svenska Filminstitutet — Stöd till kort- och dokumentärfilm (`filminstitutet-kortfilmsstod`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.filminstitutet.se/sv/sok-stod/ |

### Svenska institutet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Svenska institutet — Creative Force (`si-creative-force`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://si.se/ |

### Svenska Postkodstiftelsen (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Svenska Postkodstiftelsen — Projektstöd (`postkodstiftelsen-projektstod`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://postkodstiftelsen.se/ |

### Tillväxtverket (2)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Tillväxtverket — Affärsutvecklingscheckar (internationalisering/digitalisering) (`tillvaxtverket-affarsutvecklingscheckar`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs via Min ansökan (Tillväxtverket) när regionens omgång är öppen. | https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html |
| Tillväxtverket — Regionalt investeringsstöd (`tillvaxtverket-regionalt-investeringsstod`) | Myndighetens e-tjänst/onlinetjänst | e-legitimation (BankID e.dyl.) | Ansökan görs via Min ansökan (Tillväxtverket) innan investeringen påbörjas. | https://tillvaxtverket.se/tillvaxtverket/sokfinansiering.html |

### UHR — Universitets- och högskolerådet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Erasmus+ — Mobilitet för skola och vuxenutbildning (KA1) (`erasmus-mobilitet-skola-vuxen`) | Myndighetens e-tjänst/onlinetjänst | EU Login + OID/PIC | Ansökan görs i EU:s ansökningssystem (kräver EU Login och OID). | https://www.uhr.se/internationella-mojligheter/ |

### Vetenskapsrådet (1)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Vetenskapsrådet — Projektbidrag (fri forskning) (`vr-projektbidrag`) | Ospecificerad (generisk standardtext) — kräver kurering | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i finansiärens officiella ansökningstjänst. | https://www.vr.se/ |

### Vinnova (2)

| Stöd | Ingångar (alternativ) | Mottagning | Metod (kurerad) | URL |
|---|---|---|---|---|
| Vinnova — Innovativa startups (`vinnova-innovativa-startups`) | Myndighetens e-tjänst/onlinetjänst | Vinnova-konto (Intressentportalen) | Ansökan görs i Vinnovas e-tjänst (Intressentportalen). | https://www.vinnova.se/soka-finansiering/ |
| Vinnova — Planeringsbidrag för EU-ansökningar (`vinnova-planeringsbidrag-eu`) | Myndighetens e-tjänst/onlinetjänst | Ingen inloggning krävs (öppen tjänst/blankett/mellanhand) | Ansökan görs i Vinnovas e-tjänst när en omgång är öppen. | https://www.vinnova.se/soka-finansiering/ |

---

*Regenererad av `tools/appchannels.mjs` ur seeden. Antalet stöd, kanaler och
mottagningsvägar följer kunskapsbasen automatiskt — filen kan aldrig divergera.*
