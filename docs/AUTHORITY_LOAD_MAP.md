# AUTHORITY LOAD MAP — myndighetsbelastningskartan

Spår 3 i docs/LAUNCH_DEMAND_INTELLIGENCE.md. Frågan: **vilka myndigheter och
program är känsliga för plötslig trafik från Bidragskoll — och hur skickar vi
förberedda sökande i stället för panikvågor?**

Datastatus: strukturen (deadlinemodeller, autentisering, ansökningsvägar) är
**VERIFIED ur seeden** (`apps/api/src/seed/data.ts`). Känslighetsklassningen
är **INFERRED** ur strukturen — den är resonemang, inte uppmätta
handläggningsdata. Faktiska handläggningstider per myndighet:
**DATA_UNAVAILABLE** i kunskapsbasen i dag (se §4). Klickvolymer per scenario:
`artifacts/demand-model.json` (SCENARIO-OUTPUT, aldrig prognos).

## §1 Grundfakta ur seeden (VERIFIED)

- **Alla 84 stöd har digital ansökningsväg** (`applicationUrl` finns på
  samtliga) — ingen myndighet i kunskapsbasen är blankett-enbart, men flera
  kommunala vägar är "e-tjänst *eller* blankett" och socialtjänstens
  försörjningsstöd kan kräva bokat besök (enligt respektive `applicationMethod`).
- Autentisering: 24 stöd kräver e-legitimation, 6 saknar inloggningskrav,
  övriga använder finansiärskonton (Kulturrådet 6, EU Login 5, MUCF 2,
  Vinnova 1) — resten ospecificerat i källan.
- 9 stöd har `submissionLevel: assisted` (systemet kan förbereda hela
  underlaget); alla övriga är förberedelse + egen inlämning.
- Deadlinemodeller totalt: löpande (rolling) dominerar hos
  välfärdsmyndigheterna; fasta omgångar (recurring/upcoming_round) dominerar
  hos projekt- och kulturfinansiärerna.

## §2 Kartan per myndighet (VERIFIED struktur + INFERRED känslighet)

Spikkänslighet = hur illa en plötslig trafikvåg från oss skulle passa
myndighetens mottagning, härledd ur deadlinemodell + mottagningsväg:

| Myndighet | Stöd | Deadlinemodell | Spikkänslighet (INFERRED) | Resonemang |
|---|---|---|---|---|
| Försäkringskassan | 8 | 8 rolling | **Låg teknisk / hög human** | Nationell e-tjänst byggd för volym; men handläggningen är flaskhalsen — media rapporterar redan långa väntetider (§4). Fler *ofullständiga* ansökningar förvärrar; pre-checken är vårt bidrag. |
| Kulturrådet | 6 | 5 recurring, 1 omgång | **Hög** | All efterfrågan pressas mot deadlinefönster (spikmultiplikator 2,5–3,5× i modellen); onlinetjänsten har historiskt känsliga sista-dagen-toppar. Styr användare tidigt i fönstret. |
| CSN | 6 | 3 rolling, 3 recurring | **Medel** | Terminsstartstoppar är kända och CSN är dimensionerat för dem; vår volym adderar på befintlig topp. |
| Kommunerna (generisk) | 4 | 3 rolling, 1 recurring | **Hög** | 290 olika mottagningar, ojämn digitalisering ("e-tjänst eller blankett"); även liten nationell volym blir kännbar lokalt. |
| Socialtjänsten | 1 | rolling | **Högst** | Försörjningsstöd är handläggar- och besöksdrivet med socialt utsatta sökande; fel-riktad trafik gör direkt skada. Pre-checken (grundvillkor + underlag) är obligatorisk vy före utklick i 25-klusterfasen. |
| Arbetsförmedlingen | 3 | 3 rolling | **Medel** | Handläggarkontakt krävs ofta ("kontakta din handläggare") — digital väg men human mottagning. |
| Jordbruksverket | 3 | 3 rolling | Låg | E-tjänst, löpande, smal målgrupp. |
| Pensionsmyndigheten | 2 | 2 rolling | Låg | E-tjänst byggd för volym; äldre målgrupp kan behöva fullmaktsvägar. |
| MUCF, Vinnova, Konstnärsnämnden, EU/EACEA, Naturvårdsverket m.fl. | 2–3 var | omgångsdrivna | **Hög vid öppna utlysningar** | Efterfrågan finns bara när fönstret är öppet; vår kalenderdata (opensAt/closesAt) ska sprida ansökningar tidigt i fönstret. |
| Övriga (Arvsfonden, Boverket, RF, stiftelser …) | 1 var | blandat | Låg | Små volymer i alla scenarier (se modellens routing). |

Modellens routade toppbelastning (körning krävs, exempel ur scenariot
1 000 000 sessioner/mån): Försäkringskassan ~6 900 klick ut/mån,
Socialtjänsten ~3 400, Arbetsförmedlingen ~2 900 — fördelade på toppdygn med
deadlineviktning i `artifacts/demand-model.json`.

## §3 Designkonsekvenser (det vi bygger för att inte skapa kaos)

1. **Pre-check före utklick** (LAUNCH_DEMAND_INTELLIGENCE §3): grundvillkor
   kontrollerade + underlagslista visad → färre ofullständiga ansökningar når
   handläggarna. ARR är måttet.
2. **Deadline-spridning**: för omgångsdrivna stöd visas "omgången öppnar/
   stänger" ur seedens kalenderfält och användaren uppmanas ansöka tidigt i
   fönstret — aldrig sista-dagen-uppmaningar (och aldrig countdown-UI:
   exklusivitet genom materialkänsla, inte brådska).
3. **Socialtjänst-varsamhet**: försörjningsstödsflödet länkar alltid till
   kommunens egen väg med förväntanshantering (besök kan krävas) — ingen
   "snabb ansökan"-retorik mot försörjningsstöd.
4. **Källbevakningen som drift-sensor**: 6-timmarsdiffen på källsidor fångar
   även myndigheters egna ändringar under hög belastning (stängda e-tjänster,
   ändrade fönster) — kontrollrummet larmar (LAUNCH_CONTROL_ROOM).

## §4 Handläggningstider — ärlig lucka

Kunskapsbasen saknar fält för handläggningstid; att skylta väntetider utan
källa vore påhittad data. Verifierad extern signal i SERP-materialet:
Sveriges Radio rapporterar att ensamstående föräldrar får vänta länge på
pengar från Försäkringskassan
(sverigesradio.se/artikel/ensamstaende-foraldrar-far-vanta-lange-pa-pengar-fran-forsakringskassan,
observerad som position 1 på en barnfamiljsquery i Sprint 01 — väntetider är
alltså redan en nyhetsfråga med sökefterfrågan).

Åtgärdsväg (25-klusterfasen): lägg `processingTimeNote` som kurerat fält
**endast** där myndigheten själv publicerar handläggningstid (källa + datum,
samma kureringsregler som allt annat), börja med Försäkringskassan och CSN.
Tills dess visar produkten ingen väntetid alls — hellre tomt än gissat.
