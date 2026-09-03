# Konsekvensbedömning avseende dataskydd (DPIA) — Bidragskoll.se

**Status: UTKAST 2026-09-03 — inte undertecknat.** Utkastet är skrivet ur
systemets faktiska källor (`docs/PRIVACY.md`, `apps/api/src/db/schema.ts`,
`docs/LIMITATIONS.md`, `docs/OPERATIONS.md`) så att den personuppgifts-
ansvarige och ett eventuellt dataskyddsombud kan fylla i bedömningarna i
§7–§9 och underteckna. Punkter markerade **[ANSVARIG]** kräver ett mänskligt
beslut och kan inte härledas ur koden. DPIA:n är ett lanseringsvillkor
(`docs/ACTIVATION.md` §Icke-tekniska villkor 1) — även för sluten beta,
eftersom behandlingen av hälsouppgifter börjar i och med första användaren.

Rättslig grund för att en DPIA krävs: art. 35.3 b (behandling i stor skala
av särskilda kategorier) i kombination med IMY:s förteckning över
behandlingar som kräver DPIA (behandling av känsliga uppgifter om personer i
beroendeställning/ekonomisk utsatthet, nya tekniska lösningar). Vi bedömer
att kriteriet är uppfyllt och gör DPIA:n oavsett skala.

## 1. Behandlingens art, omfattning, sammanhang och ändamål

| | |
|---|---|
| Personuppgiftsansvarig | Landvex AB, org.nr 559141-7042, Antennvägen 2, 135 48 Tyresö **[ANSVARIG: bekräfta]** |
| Dataskyddsombud | **[ANSVARIG: namn eller "ej utsett" med motivering]** |
| Tjänst | Bidragskoll.se — konsumenttjänst som utifrån användarens beskrivna livssituation bedömer vilka offentliga stöd hen kan ha rätt till och förbereder ansökningar |
| Registrerade | Privatpersoner i Sverige (ofta i ekonomiskt utsatt situation), företrädare för föreningar och företag |
| Ändamål | (1) Ta fram en bedömning av möjliga stöd, (2) förbereda ansökningsdokument, (3) fullgöra köp (19 kr per förberedd ansökan) med kvitto, (4) drift, säkerhet och bokföring |
| Omfattning | Sluten beta: < 100 användare. Öppen drift: **[ANSVARIG: förväntad volym]** |
| Ny teknik | AI-sammanställd kunskapsbas (`ai_curated`) och regelmotor; **inga automatiserade beslut med rättslig verkan** (se §5) |

## 2. Personuppgifter som behandlas

Ur `docs/PRIVACY.md` §Data inventory och databasschemat:

| Kategori | Uppgifter | Tabell | Rättslig grund | Lagring |
|---|---|---|---|---|
| Konto | e-post, visningsnamn, lösenordshash | `users` | avtal (art. 6.1 b) | tills radering |
| Sökandeprofil | sökandetyp, kommun, hushållstyp, barn (ja/nej), födelseår, sysselsättning, ungefärlig inkomst, boendekostnad m.m. | `applicant_profiles`, `projects` | avtal | tills radering |
| **Hälsa (art. 9)** | om användaren eller nära anhörig har funktionsnedsättning/långvarig sjukdom; om egen arbetsförmåga är nedsatt ≥ 1 år | faktan `person.disabilityOrLongTermIllnessInFamily`, `person.reducedWorkCapacityLongTerm` + samtyckestidsstämpel `person.sensitiveDataConsentAt` | **uttryckligt samtycke (art. 9.2 a)** | tills radering eller återkallat samtycke |
| Ansökningsinnehåll | svar i formulär, budget, uppladdade dokument (CV, intyg, kvitton) | `application_cases`, `documents`, `storage_objects` | avtal | tills radering |
| Externa identifierare | OID/organisationsnummer när en inlämningskanal kräver det | `external_identifiers` (AES-256-GCM) | avtal / rättslig förpliktelse | tills radering |
| Betalning | belopp, leverantörsreferens, samtyckestidpunkt (ångerrätt) | `payments` | avtal | tills radering |
| Kvitto | kvittonummer, belopp, moms, e-post (maskeras vid radering) | `receipts` | rättslig förpliktelse (bokföringslagen 7 år) | 7 år, överlever radering |
| Revisionsspår | aktör, händelse, före/efter | `audit_events` | berättigat intresse (säkerhet) | enligt retention |
| Feedback (beta) | kategori, fritext, sida, språk, user-agent | `feedback` | berättigat intresse (förbättra tjänsten) | identitet nollas vid radering |
| Produkthändelser (beta) | händelsenamn + aggregerade egenskaper (antal, slug) | `product_events` | berättigat intresse | identitet nollas vid radering |

**Personnummer efterfrågas aldrig** (produktprincip; verifierat i intag och
schema). Inga uppgifter om etnicitet, religion, sexuell läggning eller
politisk åsikt efterfrågas. Frågan om uppehållstillstånd
(`person.newlyArrivedWithResidencePermit`) är inte en art. 9-uppgift men är
känslig i sammanhanget och behandlas med samma minimering.

## 3. Nödvändighet och proportionalitet

- **Dataminimering:** matchningen körs på åldersband och booleska
  livssituationsfakta, inte identitet. Exakt ålder härleds ur födelseår och
  lagras som härledd faktum. Inkomst efterfrågas som intervall.
- **Ändamålsbegränsning:** sökandefakta används bara för bedömning och
  förberedelse; den publika kunskapsgrafen innehåller inga personuppgifter.
- **Hälsofrågan är nödvändig** för att kunna peka på stöd som förutsätter
  funktionsnedsättning (omvårdnadsbidrag, merkostnadsersättning, bilstöd,
  sjukersättning m.fl.). Alternativet — att inte fråga — skulle göra att de
  som behöver stöden mest aldrig får dem föreslagna. Frågan ställs en gång,
  har ett riktigt "Vill inte svara" som aldrig tolkas som nej, och stöden
  visas då ärligt som "behöver utredas".
- **Lagringsminimering:** retention-jobbet rensar utgångna tokens, lästa
  notiser och överflödiga källsnapshots; sökandeinnehåll rensas aldrig
  automatiskt (det är användarens arbetsmaterial) men raderas i sin helhet på
  begäran.
- **Tredjelandsöverföring:** databas (Neon, EU-region **[ANSVARIG: bekräfta
  region]**), drift (Vercel — funktioner i EU-region **[ANSVARIG: bekräfta]**),
  betalning (Stripe — personuppgiftsbiträde, EU/US med standardavtalsklausuler),
  e-post (Resend, region eu-west-1), språkförslag (Anthropic — endast om
  aktiverat; skickar ansökningstext, aldrig hälsofakta som sådana
  **[ANSVARIG: bekräfta om funktionen aktiveras i beta]**). Biträdesavtal
  krävs med var och en **[ANSVARIG]**.

## 4. De registrerades rättigheter — hur de uppfylls

| Rättighet | Implementation | Bevis |
|---|---|---|
| Information (art. 13) | Samtyckesramen vid hälsofrågan, köpvillkoren, "Konto & data" | `Onboarding.tsx`, `/villkor` |
| Tillgång och dataportabilitet (art. 15, 20) | "Ladda ner min data (JSON)" | `GET /v1/tenant/export` |
| Radering (art. 17) | "Radera kontot och all data" med skriv-RADERA-bekräftelse; kaskad genom alla tenantägda tabeller; kvitton kvar med maskerad e-post (art. 17.3 b) | `DELETE /v1/tenant`, gdpr.test.ts |
| Rättelse (art. 16) | Alla svar kan ändras i "Dina svar"; profil redigerbar | Matches.tsx |
| Återkalla samtycke (art. 7.3) | Radera hälsosvaret via "Dina svar" eller radera kontot | — |
| Invändning mot profilering (art. 21–22) | Inga beslut med rättslig verkan fattas; bedömningen är förklarad och ändringsbar | PRIVACY.md §Art. 22 |

## 5. Automatiserat beslutsfattande (art. 22)

Systemet producerar **bedömningar**, aldrig beslut. Varje matchning visar
regelversion, källa, kontrolldatum och varför den föll ut som den gjorde, och
formuleras "ser ut att kunna ha rätt till". Beslutet fattas alltid av
myndigheten. Ingen prissättning, ingen åtkomstbegränsning och ingen annan
rättsverkan beror på bedömningen. Art. 22 är därmed inte tillämplig.

## 6. Säkerhetsåtgärder (art. 32)

- Transport: TLS överallt; cookies `Secure`/`HttpOnly`; CORS låst till
  `CORS_ORIGIN`.
- Åtkomst: JWT-sessioner, roller per tenant, all databasåtkomst genom API:t;
  RLS deny-all som djupförsvar; ingen direkt databasyta.
- Kryptering: externa identifierare AES-256-GCM med nyckel i miljön;
  lösenord hashade; hemligheter aldrig i repot (skanning i verify).
- Isolering: tenant-isolering testad, inklusive adversariella tester
  (TOCTOU, förfalskade betalcallbacks).
- Loggar: strukturerade, med request-id; inga personuppgifter i loggmeddelanden
  utöver id:n.
- Backup: dagliga Neon-backuper **[ANSVARIG: bekräfta retention]**;
  restore övad (OPERATIONS §Rehearsal log).
- Incidenthantering: OPERATIONS §Incident basics; anmälan till IMY inom
  72 h **[ANSVARIG: utse ansvarig person]**.
- Kända begränsningar som påverkar riskbilden: rate limit per instans i
  serverless (LIMITATIONS §13), ingen malware-scanning av uppladdningar
  utan ClamAV (LIMITATIONS §5), AI-översättningar ogranskade (LIMITATIONS §15).

## 7. Riskbedömning **[ANSVARIG: värdera sannolikhet/allvar]**

| # | Risk | Sannolikhet | Allvar | Åtgärd | Restrisk |
|---|---|---|---|---|---|
| R1 | Obehörig åtkomst till hälsouppgifter (intrång, läckt nyckel) | | | Åtgärderna i §6; nyckelrotation vid misstanke; minimering (booleskt faktum, ingen diagnos) | |
| R2 | Felaktig bedömning leder till att användaren missar stöd eller söker fel stöd | | | Bedömning aldrig beslut; källa + datum på varje rad; mänsklig granskning av kunskapsbasen (ACTIVATION 3); feedbackkanal för faktafel | |
| R3 | Inaktuell kunskapsbas (ex. avskaffat stöd fanns kvar i 4 år, KURERING_2026-09-03) | | | Källbevakning per stöd (M25), kuratorskö, vakthund | |
| R4 | Användare i utsatt situation lämnar mer än nödvändigt i fritext | | | Fritextfält bara där de behövs; tydlig vägledning; radering på begäran | |
| R5 | Tredjelandsöverföring via biträden (Stripe, Anthropic) | | | Biträdesavtal + SCC; Anthropic avstängt i beta om inte bekräftat | |
| R6 | Förlust av data (drift) | | | Backup + övad restore; bootstrap-dump | |
| R7 | Missbruk av feedback-/eventytor för spam eller avlyssning | | | Inloggning krävs; rate limit; allow-listade händelser; inga känsliga egenskaper i events | |

## 8. Samråd

- Registrerade: **[ANSVARIG: har användartester/intervjuer gjorts? LIMITATIONS §12 säger "en session"]**
- Dataskyddsombud: **[ANSVARIG]**
- Förhandssamråd med IMY (art. 36) krävs om restrisken efter §7 bedöms hög
  **[ANSVARIG]**.

## 9. Slutsats och underskrift

**[ANSVARIG]** Behandlingen får / får inte påbörjas. Villkor:

Underskrift, ort och datum: ______________________

Omprövning: vid varje ändring av intagets frågor om hälsa, ny biträdesrelation,
eller senast 12 månader efter undertecknandet.
