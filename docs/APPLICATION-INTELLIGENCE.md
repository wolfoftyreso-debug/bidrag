# Bidrag.se — Application Intelligence Engine (styrande specifikation v1.0)

Detta dokument är den styrande specifikationen för hur Bidrag.se förbereder,
granskar och kvalitetssäkrar verkliga bidragsansökningar. Den är mottagen som
produktdirektiv 2026-08-16 och gäller i sin helhet. Ingen funktionalitet som
rör ansökningsberedning får byggas i strid med principerna här.

## Implementeringsläge

| Spec-del | Status | Var i koden |
| --- | --- | --- |
| §1 Grundprincip (hierarkin formella krav → … → språk) | **Bärande designprincip** | Hela domänmotorn; språkgenerering är sista steget och kan aldrig övertrumfa krav |
| §2 Input, UNKNOWN aldrig positivt antagande | **Implementerad** | Trevärdeskriterier pass/fail/unknown i `packages/core/src/criteria.ts`; unknown ⇒ fråga, aldrig antagande |
| §3 Källhierarki | Delvis | `sources` med kvalitet A–C + `sourceUrl` per stöd; formell konfliktflaggning återstår |
| §4 Grant Fingerprint | Delvis | `funding_opportunities` + versionerade `rule_versions` (kriterier, budgetregler, bevisning, källa, ändringsnot) täcker kärnfälten; fler fält läggs till i kurerad data vid behov |
| §5 Eligibility Gate (PASS/FAIL/UNKNOWN, stoppregel) | **Implementerad** | Matchmotorn `packages/core/src/matching.ts`; granskningen flaggar FAIL som `requiresFactualChange` — systemet skriver aldrig runt ett hårt krav |
| §6 Requirement Matrix | Delvis | `application_schemas` mappar formulärfält; full kriteriemappning återstår |
| §7–9 Evaluation matrix, poängsimulering, non-compensatory | Planerad | Interna kvalitetspoäng måste märkas INTERNAL_ESTIMATE; icke-kompensatoriska krav = hard/mandatory-kriterier i motorn |
| §10–11 Evidence engine E0–E4 + claim register | Planerad (grund finns) | `documents.kind` + `evidenceRequirements` + `case_documents` är E2-grunden; nivåklassning och claimregister återstår |
| §12 Consistency engine | Delvis | Budget↔finansiering balanskontroll i `validateBudget`; namn/nummer/datum-konsistens återstår |
| §13–16 Interventionslogik, mål/indikatorer, metod, organisation | Planerad | Kräver utökade mallfrågor; får aldrig genereras utan användarens sakuppgifter (§27) |
| §17 Budget engine | **Implementerad** | `packages/core/src/budget.ts`: öre-exakta heltal, stödandel, medfinansiering, kategoritak/-krav/-uteslutning, finansieringsbalans |
| §18 Double funding | Delvis | `excludesOtherPublicFunding` + stackningsregler i `packages/core/src/stacking.ts` |
| §19 Statsstöd | Planerad | Flaggas STATE_AID_UNKNOWN tills kurerade regler finns — aldrig gissning |
| §20–22 Horisontella principer, långsiktighet, konkurrens | Planerad | Byggs som mallfrågor + granskningspunkter, aldrig som kosmetiska standardsatser |
| §23–24 Handläggarperspektiv, kompletteringsrisk | **Implementerad (v1)** | Granskningens prioriterade luckor CRITICAL/HIGH/MEDIUM/LOW i `reviewCase` |
| §25–27 Language compiler, teckengränser, no-hallucination | **Implementerad (för dokumentmotorn)** | `packages/core/src/documents.ts`: obesvarade rader utelämnas — dokumentet ljuger aldrig; ingen LLM-textgenerering finns i v1 |
| §28 Negative-fact detection | Planerad | FACT→IMPACT→MITIGATION→EVIDENCE-struktur i mallar |
| §29 Decision traceability | **Implementerad (grund)** | Deterministisk motor: varje bedömning spårbar till kriterium + regelversion + källa; `answer_provenance` på ansökningssvar |
| §30 Final Application Gate | **Implementerad** | `reviewCase` i `apps/api/src/services/applications.ts` + tillståndsvakt för READY_TO_SUBMIT |
| §31 Final Review Mode | **Implementerad (v1)** | `GET /v1/applications/:id/review` + "Granskning inför inlämning" i ansökningsvyn |
| §32 Generation mode (BEFORE/REASON/AFTER) | Planerad | Gäller när textförbättring byggs; kräver spårbar motivering per ändring |
| §33 Output contract | Planerad | Granskningssvaret är första delmängden |
| §34 Absoluta regler | **Bärande designprincip** | Se nedan |
| §35 Interna mål | **Bärande designprincip** | Optimering mot verifierbarhet och handläggningsbarhet, aldrig mot språkyta |

**Viktigast av allt (§27, §34):** systemet hittar aldrig på fakta, uppgraderar
aldrig obevisade påståenden, och behandlar aldrig UNKNOWN som uppfyllt. En
brist som kräver ändrade faktiska omständigheter flaggas som sådan
(`requiresFactualChange`) i stället för att döljas med bättre text.

---

## Specifikationen (mottagen 2026-08-16, återgiven i sin helhet)

### Systemidentitet

Bidrag.se:s interna Application Intelligence Engine. Uppdraget är inte att
skriva "snygga" bidragsansökningar utan att maximera sannolikheten att en
verklig ansökan: uppfyller alla formella krav; är behörig enligt aktuell
stödordning; adresserar exakt de kriterier finansiären bedömer; innehåller
tillräcklig och trovärdig bevisning; är internkonsekvent mellan formulär,
budget, bilagor och projektplan; är genomförbar; är ekonomiskt och
administrativt trovärdig; är lätt för en handläggare att förstå och
verifiera; inte innehåller påståenden utan stöd; inte innehåller
motsägelser, överdrifter eller oavsiktliga risker; och är så stark som de
faktiska omständigheterna tillåter.

Systemet får aldrig förbättra en ansökan genom att hitta på fakta, aldrig
anta att ett påstående är sant för att det låter rimligt, aldrig
rekommendera att relevanta negativa omständigheter döljs, aldrig optimera
mot att kringgå myndighetens regler eller bedömningsprocess.

### 1. Grundprincip

Hierarki: FORMELLA KRAV → BEHÖRIGHET → OBLIGATORISKA KRITERIER →
UTLYSNINGENS SYFTE OCH PRIORITERINGAR → BEDÖMNINGSKRITERIER → BEVISNING →
GENOMFÖRBARHET → EKONOMI → RESULTAT OCH EFFEKTER → HÅLLBARHET →
KONKURRENSKRAFT → SPRÅKLIG KVALITET. En språkligt bra ansökan får aldrig
prioriteras över en korrekt och kriteriemässigt komplett ansökan.

### 2. Input

Utlysningstext, förordning/regelverk, anvisningar, formulär,
bedömnings-/urvalskriterier, budgetmall, bilagekrav, FAQ, tidigare
utlysningar, sökandens uppgifter/svar/dokument/ekonomiunderlag/projektplan/
budget/bevisning, tillåtna externa källor, tidigare beslut/avslag,
kompletteringskrav. Saknad viktig uppgift markeras UNKNOWN. UNKNOWN får
aldrig automatiskt omvandlas till ett positivt antagande.

### 3. Källhierarki

1 lag/förordning · 2 formell stödordning · 3 aktuell utlysning · 4
officiella anvisningar · 5 officiella bedömningskriterier · 6 budget-/
bilagemall · 7 officiella FAQ · 8 tidigare officiella dokument · 9 externa
sekundärkällor · 10 modellens allmänna antaganden. Lägre källa ersätter
aldrig högre. Kvarstående konflikt ⇒ FLAGGA CONFLICT, gissa inte.

### 4. Grant Fingerprint

Före all textgenerering omvandlas stödordningen till en strukturerad
fingerprint: finansiär, program, utlysning, diarienummer, rättslig grund,
stödform, målgrupp, geografi, organisations-/projektkrav, projektperiod,
tidigaste start/senaste slut, deadline, max/min stöd, stödnivå,
medfinansiering, partnerkrav, stödberättigande/icke stödberättigande
aktiviteter och kostnader, statsstöd/de minimis, annan offentlig
finansiering, obligatoriska bilagor/fält, teckenbegränsningar,
bedömnings-/urvalskriterier, poängmodell, minimipoäng, icke-kompensatoriska
kriterier, prioriteringsgrunder, hållbarhets-/jämställdhets-/
tillgänglighets-/icke-diskrimineringskrav, implementering,
resultatspridning, utvärdering, samverkan, kapacitet, uppföljning,
återrapportering, särskilda riskområden. Varje regel lagras med SOURCE,
SOURCE_LOCATION, RULE_TYPE, RULE_TEXT, MANDATORY, CONFIDENCE,
PROGRAM_VERSION.

### 5. Eligibility Gate

PASS (uppfyllt och styrkt), FAIL (förefaller inte uppfyllt), UNKNOWN
(underlag räcker inte). UNKNOWN är riskläge, inte FAIL. Varje FAIL:
exakt regel, källa, förklaring, om bristen kan korrigeras, om den kräver
faktisk förändring snarare än bättre text. Varje UNKNOWN: vilken uppgift
som krävs, varför, vilket underlag som styrker. STOPPREGEL: ett hårt
obligatoriskt behörighetskrav som är FAIL får aldrig "skrivas runt".

### 6. Requirement Matrix

Fullständig matris (ID, krav, obligatoriskt, hur bedöms, var besvaras,
bevis, status). Varje formulärfråga mappas till krav, kriterier, bevis,
budgetdelar, bilagor. Inget kriterium lämnas omatchat.

### 7. Evaluation Matrix

Per kriterium: CRITERION_ID/NAME, EXACT_REQUIREMENT, CURRENT/MAX_SCORE,
PASS_THRESHOLD, NON_COMPENSATORY, EVIDENCE_STRENGTH, MISSING_ELEMENTS,
CONTRADICTIONS, RISK, RECOMMENDED_ACTIONS. Konservativ bedömning; delvis
dokumenterat ⇒ inte fullt resultat; obedömbart ⇒ UNKNOWN.

### 8. Score Simulation

Officiell poängmodell används exakt. Utan officiell modell får ett internt
kvalitetspoängsystem skapas, tydligt märkt INTERNAL_ESTIMATE — aldrig en
prognos om myndighetens beslut, utan "styrkan i tillgängligt beslutsunderlag
relativt publicerade krav".

### 9. Non-Compensatory Rule

Kriterier där svaghet inte kan kompenseras (relevans, behörighet,
obligatoriska urvalskriterier, lagkrav, obligatoriska bilagor) ⇒ vid brist
CRITICAL_GAP; höga betyg i övrigt får aldrig dölja problemet.

### 10. Evidence Engine

Evidensnivåer: E0 obevisat · E1 sökandens påstående · E2 dokumenterat ·
E3 extern källa · E4 verifierat. Per viktigt påstående: CLAIM, SOURCE,
EVIDENCE_LEVEL, SOURCE_DATE, SOURCE_LOCATION, CRITERION_LINK,
CONSISTENCY_STATUS. E0 uppgraderas ALDRIG utan nytt underlag.

### 11. Claim Register

Centralt register över viktiga påståenden, kopplade till alla ställen där
de används (sammanfattning, problem, effektmål, budget, indikator, bilaga,
projektplan). Samma faktum uttryckt olika ⇒ FLAGGA CONTRADICTION.

### 12. Consistency Engine

Automatisk kontroll av namn, organisationsnummer, projektnamn, period,
start/slut, geografier, målgrupper, antal, budgetbelopp, stödbelopp,
medfinansiering, procentsatser, timkostnader, aktiviteter, mål,
indikatorer, effekter, ansvar, projektledare, partners, bilagor, siffror,
datum, terminologi. Motsägelser rapporteras före finalisering.

### 13. Problem → Mål → Aktivitet → Resultat → Effekt

Varje projekt ska kunna uttryckas som logisk kedja PROBLEM → ORSAK → BEHOV
→ MÅL → AKTIVITET → OUTPUT → RESULTAT → EFFEKT → LÅNGSIKTIG FÖRÄNDRING,
med kontroll att varje steg följer logiskt. Generiska samband ("bidrar
positivt till samhället") underkänns — kräv konkret mekanism.

### 14. Mål och indikatorer

Mål ska vara specifika, mätbara, realistiska, tidsbestämda, relevanta,
problemkopplade, uppföljningsbara. Indikatorer: BASELINE, TARGET,
TIMEFRAME, DATA_SOURCE, MEASUREMENT_METHOD, RESPONSIBLE_ACTOR. Saknad
baseline/metod/uppföljningsbarhet ⇒ FLAGGA.

### 15. Method Validation

Vid metodkrav: varför metoden, vilket problem, varför relevant för
målgruppen, vilket stöd (erfarenhet/forskning), genomförande, uppföljning,
riskhantering. Utan evidens: skriv aldrig ett positivt faktapåstående —
skriv "Underlag saknas för att styrka detta. Föreslagen komplettering: …".

### 16. Organisation och kapacitet

Mappa ROLE, PERSON/ORGANISATION, COMPETENCE, EXPERIENCE, RESPONSIBILITY,
TIME_COMMITMENT, EVIDENCE, PROJECT_NEED. Identifiera saknade funktioner,
kompetensluckor, oklara ansvar, personberoende, orealistisk bemanning,
omotiverade externa resurser.

### 17. Budget Engine

Budgeten är aldrig fristående. Per kostnad: COST_ID, ACTIVITY_LINK,
PERSON/RESOURCE, PERIOD, AMOUNT, FUNDING_SOURCE, ELIGIBILITY,
JUSTIFICATION, EVIDENCE, RISK. Kontrollera stödberättigande, rimlighet,
period, aktivitet, kostnadseffektivitet, medfinansiering, annan offentlig
finansiering, statsstöd, dubbelfinansiering, matematik, stödnivå,
konsekvens mot projektplan. Varna för kostnad utan aktivitet, aktivitet
utan resurser, mål utan finansierade aktiviteter.

### 18. Double Funding Check

Samma kostnad/aktivitet finansierad från annan myndighet, statsbidrag,
EU-fond, kommun, region eller annan offentlig källa ⇒ CLEAR /
POTENTIAL_OVERLAP / HIGH_RISK. Ändra aldrig fakta för att "få det att
passa".

### 19. State Aid Check

Vid statsstödsregler: stödmottagare, ekonomisk verksamhet, stödgrund,
stödintensitet, de minimis, tidigare stöd, kumulering, stödberättigande
kostnader, tak, sektorsbegränsningar. Saknas uppgifter ⇒ FLAGGA
STATE_AID_UNKNOWN.

### 20. Horizontal Principles

Jämställdhet, tillgänglighet, lika möjligheter, icke-diskriminering,
klimat/miljö, hållbarhet: aldrig kosmetisk standardsats — kontrollera
PROBLEM → MÅLGRUPP → AKTIVITET → METOD → RESULTAT → INDIKATOR för det
aktuella perspektivet. Identifiera målkonflikter.

### 21. Implementation / Long-term Value

Vem tar emot resultatet, vem äger det, hur används det efter projektet,
hur integreras arbetssätt, hur behålls kompetens, hur hanteras
finansiering efteråt, hur sprids resultat, hur består effekter.
"Resultaten kommer att leva vidare" räcker inte — kräv mekanism.

### 22. Competitive Positioning

WHY_THIS_PROJECT / WHY_NOW / WHY_THIS_APPLICANT / WHY_THIS_METHOD /
WHY_THIS_FUNDING / WHY_THIS_SCALE. Identifiera särskiljande drag och
generiska delar. Aldrig uppdiktad konkurrensfördel.

### 23. Handläggarperspektiv

Simulera professionell granskning per kriterium: vad vill finansiären
fastställa, har sökanden svarat, är svaret konkret, finns bevis, räcker
det, finns motsägelser, måste handläggaren fylla i luckor, vilken
kompletteringsfråga uppstår, vilket är det troligaste avslagsargumentet,
vad gör bedömningen enklare. Optimera för minimal egen tolkning hos
handläggaren.

### 24. Completion Risk

Klassificera varje lucka: CRITICAL (t.ex. obligatorisk bilaga saknas),
HIGH (centralt kriterium utan substantiell motivering), MEDIUM (svag
indikator), LOW (språk). Användaren prioriterar efter faktisk påverkan.

### 25. Language Compiler

Texten svarar direkt på frågan, följer frågans logik, använder
finansiärens begrepp, inga superlativ eller marknadsföringsspråk, ingen
funktionslös upprepning, konkreta samband, verifierbar, inom teckengräns,
inga tillagda fakta. Prioritet: KORREKTHET → KRAVUPPFYLLNAD → BEVIS →
RELEVANS → TYDLIGHET → KONCISION → POLISH.

### 26. Character-Limit Compiler

Generera ≤ gränsen, kontrollera faktiskt teckenantal. Trimma i ordning:
redundans, dekor, sekundära detaljer, överflödiga förklaringar. Ta aldrig
bort kriteriebevis, centrala fakta, siffror, orsakssamband, obligatoriska
komponenter.

### 27. No-Hallucination Rule

Saknas nödvändig information: skriv inte påståendet. Skapa MISSING_FACT,
MISSING_EVIDENCE, REQUIRED_USER_INPUT, POTENTIAL_SOURCE,
EXAMPLE_OF_ACCEPTABLE_PROOF. Hellre stoppa ett viktigt fält än skapa en
trovärdig men falsk uppgift.

### 28. Negative-Fact Detection

Ekonomisk svaghet, tidigare stöd, överlappande projekt, kapacitetsbrist,
förseningar, oklara partnerrelationer, otillräcklig medfinansiering,
riskabla kostnadsposter: döljs aldrig. Föreslå FACT → IMPACT → MITIGATION
→ EVIDENCE.

### 29. Decision Traceability

Varje genererat stycke spårbart: QUESTION → CRITERION → CLAIM → EVIDENCE
→ SOURCE. "Varför skrev systemet detta?" ska kunna besvaras utan
spekulation.

### 30. Final Application Gate

READY_FOR_SUBMISSION endast om: inga kritiska behörighetsfel; alla
obligatoriska fält fyllda; alla obligatoriska bilagor finns; inga kända
motsägelser; budgeten stämmer matematiskt; stödnivån korrekt; centrala
kriterier täckta; centrala påståenden bevisade; deadline och period
korrekta; signeringskrav uppfyllda; statsstöds-/medfinansieringsrisker
hanterade; textbegränsningar kontrollerade. Annars NOT_READY med
prioriterad åtgärdslista.

### 31. Final Review Mode

"Granska ansökan" gör aldrig automatisk omskrivning. Först: eligibility,
requirement coverage, criteria, evidence, budget, consistency, diligence,
competitive, language review. Sedan: OVERALL_STATUS, gap-listor per
prioritet, scorecards, risker, troliga kompletteringar, troliga svaga
beslutsargument, TOP_5_CHANGES.

### 32. Final Generation Mode

Varje förbättring motiveras internt: BEFORE, REASON, CRITERION, EVIDENCE,
AFTER. Alla ändringar motiverade av faktiskt kriterium/krav eller
dokumenterad förbättring i tydlighet/verifierbarhet.

### 33. Output Contract

Strukturerad intern output: grant_fingerprint, eligibility, requirements,
evaluation_matrix, claims, evidence, consistency, budget, state_aid,
double_funding, horizontal_principles, implementation,
competitive_position, diligence, completion_risk, generated_answers,
submission_gate, recommended_actions.

### 34. Absoluta regler

1 Skriv aldrig för att "låta bra" på bekostnad av precision. 2 Hitta
aldrig på fakta. 3 Anta aldrig att ett kriterium är uppfyllt för att en
närliggande formulering finns. 4 Separera alltid FACT / INFERENCE /
RECOMMENDATION / UNKNOWN. 5 Skilj alltid "detta står i reglerna" från
"detta är vår kvalitetsbedömning". 6 Vid avgörande krav: hellre FLAGGA än
gissa. 7 Optimera för verifierbarhet. 8 Optimera för finansiärens
faktiska bedömningsmodell. 9 Explicit bedömningsmatris väger tyngre än
generella principer. 10 Återanvänd inte generiska formuleringar mellan
utlysningar. 11 Varje utlysning är ett eget regelverk. 12 En bra ansökan
är en där sambandet behov–mål–aktivitet–budget–resultat–effekt–bevis är
tydligt.

### 35. Primärt internt mål

Maximera TRUE_REQUIREMENT_COVERAGE + EVIDENCE_STRENGTH +
INTERNAL_CONSISTENCY + IMPLEMENTATION_CREDIBILITY + FINANCIAL_CREDIBILITY
+ HANDLER_CLARITY + PROGRAM_RELEVANCE. Minimera FORMAL_FAILURE +
UNKNOWN_CRITICAL_FACTS + UNSUPPORTED_CLAIMS + CONTRADICTIONS +
BUDGET_RISK + DUPLICATE_FUNDING_RISK + COMPLETION_RISK + GENERIC_LANGUAGE
+ NON-RELEVANT_CONTENT. Slutmålet: en korrekt, verifierbar,
kriteriemässigt komplett, internkonsekvent och genomförbar ansökan som
ger finansiären ett så tydligt och lättverifierat beslutsunderlag som
möjligt.
