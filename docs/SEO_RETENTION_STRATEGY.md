# SEO_RETENTION_STRATEGY — retention, kanaler och integritetsräcken

Datum: 2026-08-21 (masterprompt 2 §21–23, §32.7). Princip: **retention, inte
förföljelse**. Bidragskoll följer aldrig ekonomiskt utsatta användare runt
internet med annonser som avslöjar eller antyder deras situation.

## Regulatorisk grund (styr allt nedan)

- Google klassificerar ekonomisk utsatthet, välfärdstjänster och
  arbetslöshetsresurser som känsliga intressekategorier → personanpassad
  annonsering på sådana signaler är policybegränsad (uppdaterade
  förtydliganden juni 2026 enligt uppdragsgivaren — PLATTFORMSPOLICY_REVIEW
  krävs innan varje AMBER-metod aktiveras; policytexterna ska läsas i
  original vid det tillfället, inte antas).
- Svensk rätt: icke-nödvändiga kakor kräver aktivt, återkallbart samtycke.
  EDPB varnar för ogenomskinlig social målgruppsstyrning.
- Produktens egna regler (redan implementerade): art. 9-hälsofrågan har
  uttryckligt samtycke + "Vill inte svara"; personnummer efterfrågas aldrig.

## Den optimala loopen (§21) — mappning mot befintlig produkt

| Steg | Läge |
|---|---|
| 1–2 Problem → preliminärt svar | Publika ytan (77 sidor) + kommande guider — IMPLEMENTED (grund) |
| 3–5 Frågor → matchningar med för/emot/kontrollera | Utredningen (en fråga i taget, förklaringar per kriterium) — IMPLEMENTED |
| 6 Jämföra stöd | Analysvyn + planerade jämförelsesidor — DELVIS |
| 7–8 Officiell källa → överlämning | Källa+ansök-själv-länk på varje stöd — IMPLEMENTED |
| 9 Frivilligt spara (stöd, deadline, status) | Konto + Dina svar + kalender — IMPLEMENTED; anonymt läge före konto: RECOMMENDED |
| 10 Påminnelser endast efter uttryckligt val | Deadlinebevakning per e-post: RECOMMENDED (Resend-aktivering krävs) |
| 11 Återkomst | Deadlinehubb + "vad har ändrats" — PLANERAD |

Kontokrav får inte läggas för tidigt: publika ytan och demon kräver inget
konto; utredningen kräver konto först vid sparande — utred anonymt läge med
lokal lagring som mellansteg (RECOMMENDED, produktbeslut).

## Kanalmatris v0.1 (§22, §32.7)

| Kanal/metod | Klass | Villkor |
|---|---|---|
| SEO/organisk återkomst | GREEN | grunden — redan byggd |
| Kontextuell annonsering (sidans ämne, ej individen) | GREEN | ingen användardata |
| Bred varumärkesannonsering | GREEN | inga målgruppssignaler om utsatthet |
| Sökannonser på generiska bidragstermer | GREEN* | *PLATTFORMSPOLICY_REVIEW per kategori (välfärdstermer kan vara begränsade) |
| Frivilligt nyhetsbrev / deadlinebevakning | GREEN | dubbelt opt-in, lätt avregistrering, aldrig förkryssat |
| Sparade stöd + magic link-återkomst | GREEN | kontobaserat, användarens val |
| Onsite-rekommendationer ur aktuell session | GREEN | sessionsbaserat, ingen historikprofil |
| Anonym local storage (utkast, läge) | GREEN | redan mönster i produkten (intagsutkast) |
| Partnersamarbeten (rådgivare, kommuner, skolor, fack, civilsamhälle) | GREEN | distribution via förtroendeaktörer |
| B2B-innehåll på branschytor (LinkedIn organiskt) | GREEN | företagsspåret |
| Generell remarketing till samtyckande besökare | AMBER | LEGAL_REVIEW + samtycke + exkludera ALLA känsliga sidkategorier |
| B2B-retargeting företagsstöd | AMBER | PLATTFORMSPOLICY_REVIEW; endast företagssidor |
| Lookalike på icke-känslig B2B-data | AMBER | LEGAL_REVIEW + dataminimering |
| Server-side tracking / längre historik / cross-device | AMBER | LEGAL_REVIEW; dokumenterat ändamål |
| Remarketing baserad på besök på bistånds-/ersättningssidor | RED | aldrig |
| Målgrupper på arbetslöshet, skulder, sjukdom, funktionsnedsättning, bostadsnöd | RED | aldrig |
| Uppladdning av eligibility-svar/inkomst/hälsa/familj till annonsplattformar | RED | aldrig |
| Lookalike byggd på ekonomiskt utsatta privatpersoner | RED | aldrig |
| Annonser som antyder att vi vet vad personen sökt | RED | aldrig |
| Skam-/skrämselbudskap, dark patterns, förkryssade val | RED | aldrig |

## Separationen privat/B2B (§23)

**Privatpersonsspåret:** anonym användning så långt som möjligt, minimal
datainsamling (redan produktprincip), uttryckligt valda påminnelser,
kontextuell kommunikation, GDPR-självservice (export/radering finns).
**Företags-/organisationsspåret:** utlysningsbevakning, branschuppdateringar,
projektpåminnelser — klassisk B2B-lifecycle ÄR rimlig här (PER-011/PER-012 är
retention-ledarna), fortfarande med samtycke, ändamålsbegränsning och
dataminimering. Datamodellerna hålls åtskilda: organisationsegenskaper får
sparas rikare än personegenskaper.

## Consent-krav (sammanfattning)

Nödvändiga kakor: inga samtyckeskrav (sessionshantering). Allt annat
(analytics, marknadsföring): aktivt samtycke, återkallbart, aldrig
förkryssat, med likvärdigt lätt nej. Innan någon AMBER-metod aktiveras:
skriftlig plattformspolicy- och rättslig genomgång dokumenterad i denna fil.
