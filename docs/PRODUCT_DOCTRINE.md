# PRODUCT DOCTRINE — Bidragskoll.se

> Styrdokument, inte vision. Principerna nedan är låsta och försvaras av kod:
> `tools/doctrine.mjs` körs i `npm run verify`. **Reviderad 2026-08-26** med
> den viktigaste produktkorrigeringen hittills: **Open Discovery** — betalning
> flyttas från att *se resultat* till att *använda arbetsverktyg*.

Status: LÅST (v2, 2026-08-26). Nulägesdom: `docs/DOCTRINE_AUDIT.md`.
Migreringsstatus: se §12 (den byggda 39 kr-teaser-modellen ersätts fasvis).

---

## 1. Positioneringen (en mening)

**Bidragskoll är en upptäcktsmotor, inte en sökmotor eller informationsportal.**
Användaren ska inte lära sig bidragssystemet. Användaren vill veta: *Finns det
pengar eller stöd jag kan få?* — och därefter: *Vad behöver jag göra för att få
dem?*

Affärsmodellen i en mening:

> **Gratis att upptäcka. Betalt att genomföra, bevaka och administrera.**

Publik kärnformulering:

> Se vilka bidrag du kan få. Ansök själv — eller låt Bidragskoll göra ansökan klar.

Den bärande mentala modellen är **en personlig bidragsinkorg**: användaren
identifierar sig, och möjligheterna kommer till användaren (öppna nu · behöver
kontrolleras · öppnar senare · bevakas · påbörjad ansökan · redo att skicka).
Användaren ska aldrig behöva navigera i ett bidragsuniversum.

## 2. Den bärande invarianten (kod)

**Användaren ska aldrig behöva känna till stödet — namn, kategori, myndighet
eller stödform — för att få värde.** Testbart; vaktas av `tools/doctrine.mjs`.

## 3. De sju bindande produktprinciperna

1. **Open Discovery** — alla användare ska kunna se möjliga bidrag och en
   grundläggande matchningsförklaring **utan betalning**. Ingen betalvägg
   framför resultatet.
2. **Progressive Eligibility** — behörighetsfrågor ställs huvudsakligen **efter**
   att en specifik möjlighet valts, per bidrag — inte som ett stort generellt
   formulär före första resultatet.
3. **Official Exit** — varje relevant bidrag ska kostnadsfritt kunna länka
   användaren till den officiella ansökningskanalen.
4. **Paid Execution Layer** — betalning utlöses av **användning av
   arbetsverktyg** (bevakning, förberedelse, administration), aldrig av att
   offentlig information eller grundläggande matchningsresultat visas.
5. **Radical Simplicity** — standardflödet får inte kräva att användaren lär sig
   bidragstermer eller läser långa texter.
6. **Progressive Disclosure** — detaljer visas när användaren öppnar en möjlighet
   eller behöver fatta ett beslut, inte allt på en gång.
7. **One Primary Action** — varje skärm har en tydlig primär handling; sekundära
   val konkurrerar inte visuellt med huvuduppgiften.

## 4. Gratis kontra betalt (den nya gränsen)

| Gratis (Open Discovery) | Betalt (Paid Execution Layer) |
|---|---|
| Skapa grundprofil | Fullständig bidragsbevakning (flera aktiva) |
| Se relevanta stöd | SMS-/e-postaviseringar, förändringsbevakning |
| Se **varför** de kan vara relevanta | Ansökningsarbetsyta + dokumenthantering |
| Svara på grundläggande kvalificeringsfrågor | Återanvända verksamhetsuppgifter automatiskt |
| Se sannolik status + deadline | Formulering av ansökningssvar, projektplan, budget |
| Se officiella källor | Medfinansieringskontroll, dokumentchecklistor |
| Gå till myndigheten och **ansöka själv** | Versionshistorik, uppgifter, påminnelser, samarbete |
| Spara ett begränsat antal möjligheter | Flera parallella ansökningar, slutkontroll, uppföljning |

Det betalda värdet är inte att hålla information gisslan — **det är att göra
arbetet**. Användaren jämför inte "ska jag betala för en lista?" utan "ska jag
göra hela ansökningsarbetet själv eller använda verktyget?".

## 5. Grundflödet

1. **Vem gäller kontrollen?** Privatperson · Företag · Enskild firma · Förening.
   Ingen intro, ingen artikel ovanför knappen.
2. **Identifiera** person/verksamhet (organisationsnummer för företag/förening;
   privatpersons-identitet — se §11, öppet beslut). Enskild firma = dubbelkontext
   (privat + näring).
3. **En eller ett fåtal inledande frågor** (frivillig fritext: "Berätta kort vad
   som händer just nu"). Ska förbättra första urvalet — aldrig en projektansökan
   i miniatyr.
4. **Visa möjligheter tidigt**: "Vi har hittat N möjligheter" uppdelat i starkt
   relevanta / behöver uppgifter / öppnar senare / bör kontrolleras.
5. **Kvalificering per bidrag** (Progressive Eligibility): först när användaren
   väljer ett bidrag ställs just dess villkorsfrågor.

## 6. Resultatkort (stängt läge)

Endast: namn · en mening · status · ungefärligt värde (om korrekt) · deadline/
nästa öppning · antal återstående frågor · **en** primär knapp. Progressive
Disclosure vid öppning: varför det matchar · vad som saknas · centrala villkor ·
officiell källa · nästa steg.

## 7. Tre handlingar per kontrollerat bidrag

- **Ansök själv** (gratis) — officiell sida, deadline, dokumentlista, villkor.
- **Förbered i Bidragskoll** (betalt) — startar arbetsflödet.
- **Bevaka** — stängt stöd, okänd nästa period, ej redo, väntade
  villkorsändringar, deadlinepåminnelser. Skapar produktloopen.

## 8. Konverteringslogiken

Inte "betala för att låsa upp resultat", utan: starta gratis kontroll → upptäck
möjlighet → kontrollera grundvillkor → uppleva att systemet förstår situationen
→ välj att hantera ansökan i Bidragskoll → betala för verktygslagret. Användaren
får **bevis på värdet innan betalning**. Bevakning fångar den som inte har något
öppet relevant just nu ("din profil kan användas för framtida möjligheter").

## 9. Search Surface vs Product Surface

Två skilda lager (detaljer: `docs/SEO_SEARCH_SURFACE.md`):

- **Search Surface** — den stora publika, indexerbara kunskapsytan; får vara
  enorm, men konkret (viktigast först, långa förklaringar bakom "Visa
  fullständig information"). Leder mot "Kontrollera om detta gäller dig".
- **Product Surface** — den personliga Bidragskoll; **minimal**. En fråga i
  taget, resultatkort, handlingar. Inga artiklar, inga säljavsnitt, inga
  textmassor. SEO-innehåll får aldrig sippra in i produkten.

## 10. Hårda kontrollkriterier (implementationen underkänns om)

- betalning möter användaren **innan** relevanta bidrag visas;
- användaren måste ange ett känt bidragsnamn;
- ett långt generellt formulär krävs före första resultatet;
- dokument krävs innan ett konkret bidrag valts;
- startsidan domineras av långa textavsnitt;
- resultatkort saknar tydlig nästa handling;
- officiell ansökningslänk göms för gratisanvändare;
- myndighetsspråk krävs för att komma vidare;
- samma uppgift efterfrågas flera gånger;
- användaren måste läsa en guide för att förstå produkten.

## 11. Identifiering av privatperson — BESLUTAT: bara födelseår

**Produktägarens beslut 2026-08-26:** *"Ingen bankid behövs. ingen ansökan sker
från systemet idag. Så vi nöjer sig med födelseår så det enda som fylls i av den
sökande är födelseår och signatur om det behövs."*

Personnummer + BankID **förkastades**. Grundregeln "Personnummer efterfrågas
aldrig någonstans" (CLAUDE.md regel #1) står **oförändrad**. Det enda personliga
fält den sökande fyller i är **födelseår** (+ signatur på färdiga dokument om det
behövs). Motivering: idag lämnas ingen ansökan direkt från systemet, så ingen
identitetskoppling behövs — bara den ålder som avgör åldersgränser.

Från födelseåret härleds **exakt ålder** (det år personen fyller X) mot varje
åldersgräns som ett stöd faktiskt har — inga grova åldersband som proxy:
`person.ageYears`, `ageUnder29`, `age40OrYounger`, `age60Plus`, `age62Plus`,
`age66Plus`, `age67Plus`. Detta stänger samtidigt buggen M11 (åldersgränserna
60/62/67 kontrollerades tidigare mot en 66-proxy). Företag/förening:
organisationsnummer är oproblematiskt (offentlig uppgift) och adopteras.

## 12. Migreringsstatus (39 kr-modellen → Open Discovery) — GENOMFÖRD

**Klart 2026-08-26 (commit 8b907d7).** Den byggda 39 kr-analysupplåsningen +
teasern är borttagna i kod:

- API: `matches` (GET+POST) returnerar alltid fulla resultat gratis;
  `analysis-unlock`/`unlock-status`/`isProjectUnlocked` pensionerade; funding-
  stack inte längre 402-gatead. 19 kr/ansökan + kvitto/swish oförändrat.
- Webb + demo: teaser/paywall borttagna; resultaten visas direkt.
- `tools/doctrine.mjs` check C **flippad**: fäller nu bygget om paywall-före-
  resultat återinförs (i api eller webb).
- Bevis: verify 15/15 · verify:ui KLAR · demo:check 7/7 · api 207/207.

Kvar (senare faser): bevakningslagret (spara möjligheter, e-post/SMS-
aviseringar) som betalda paket; produkter/priser/entitlements ska bli
konfigurerbara (idag `config.applicationPriceMinor`).

## 13. Förhållande till övriga doktriner

Perfektionsdoktrinen (friktion) · Application Constitution (lager 3-kvalitet) ·
Språkguiden (vardagssvenska) · SEO Release Gate + `docs/SEO_SEARCH_SURFACE.md`
(§9). Situationsontologin: `docs/SEO_SITUATION_ONTOLOGY.md`.
