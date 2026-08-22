# RED TEAM-PASS 03 — hela systemet (2026-08-22)

Uppdrag (RED_TEAM_CHECKLIST §50): bevisa att Bidragskoll är dåligt, försvara
ingenting. Fyra parallella granskare (säkerhet/integritet, sanning/fakta,
förtroende/mörka mönster, relevans/bedömning) + deterministiska sonder. Varje
fynd verifierat mot koden/primärkälla — inga fabricerade. Detta pass hittade
**18 fynd**: 1 HIGH säkerhet, 3 HIGH sanning, 9 MEDIUM, 5 LOW.
**15 åtgärdade + recrawl (tester), 2 backloggade, 1 accepterad design.**

Format: fynd → åtgärd. Reproduktionssteg i respektive granskares logg.

## Säkerhet & integritet

| Id | Grad | Fynd | Åtgärd |
|---|---|---|---|
| S1 | **HIGH** | Självbetjänings-eskalering till global kurator: vem som helst kan skapa en org-tenant och bjuda in sig själv som `administrator`/`data_curator` (båda i `INVITABLE_ROLES`) och nå `/v1/admin/*` som muterar den DELADE kunskapsgrafen (rule versions, `human_verified`-stämplar, källregister) för alla tenanter | **FIXAD**: `CURATOR_ROLES` = endast `data_curator` (ej `administrator`); `data_curator` borttagen ur `INVITABLE_ROLES` — kuratorsrollen tilldelas bara utanför självbetjäning. Tenant-admin (team) och global kurator (kunskapsgraf) är nu isärkopplade. |
| S2 | MEDIUM | Kontoradering (`DELETE /v1/tenant`) lämnade kvar `users`-raden (e-post, lösenordshash) + autentiseringstoken — Art. 17 ofullständig mot löftet "radera all data permanent" | **FIXAD**: när användaren saknar kvarvarande medlemskap raderas users-raden; FK-cascade städar refresh-/återställnings-/recovery-tokens. `auditEvents.actorUserId` saknar FK → raderingsbeviset överlever. |
| S3 | MEDIUM | Andra, odokumenterad Art. 9-hälsofråga (`p-capacity`, nedsatt arbetsförmåga) utan samtyckesram eller avböjandeväg — i strid med PRIVACY.md ("exactly one Art. 9 question") | **FIXAD**: samtyckesnotis + "Vill inte svara" på p-capacity (webb + demo), samtyckestidsstämpel + avböjandemarkör i faktalagret; PRIVACY.md uppdaterad till två samtyckesramade hälsofrågor. |
| S4 | LOW | Fritextfältet `p-extra` uppmanade "t.ex. … sjukdom i familjen" — solliciterade hälsodata i oskyddat fält | **FIXAD**: vägledningen ber uttryckligen att INTE skriva hälsouppgifter där. |

**Rent (verifierat):** tenant-isolation/IDOR över alla datarutter (404 läcker
inte existens), scrypt+timingSafeEqual, JWT/refresh-rotation, engångstoken,
AES-256-GCM på externa identifierare, personnummer efterfrågas ingenstans,
header-redigering i loggar, inga hårdkodade hemligheter, mock strukturellt
omöjlig i skarp produktion, betalkedjan idempotent + callback-verifierad.

## Sanning & fakta

| Id | Grad | Fynd | Åtgärd |
|---|---|---|---|
| F1 | **HIGH** | Medgivet gissat belopp publicerat som fakta (Kulturrådet resebidrag, seed-kommentar "verifieras mot källan") | **FIXAD**: `maxAmountMinor: null` → renderar "Varierar, se källan". |
| F2 | **HIGH** | Förbjudet löftesord "garanterar" live (Äldreförsörjningsstöds summary) — bryter LANGUAGE_GUIDE §3 | **FIXAD**: omformulerad till "behovsprövat stöd … för att nå en skälig levnadsnivå". |
| F3 | **HIGH** | Pensionsålder "66 år" — verifierat faktafel: riktåldern är **67 år från 2026** och äldreförsörjningsstödets nedre gräns är knuten till riktåldern (WebSearch: regeringen/Pensionsmyndigheten) | **FIXAD**: beskrivning + kriterium → "riktåldern för pension (67 år från 2026)". |
| F5 | MEDIUM | `closesAt` på `recurring`-stöd renderades som en enda hård slutdeadline (LOK-stöd visade ett datum 3 dagar bort som "aktuell deadline"); den återkommande naturen doldes | **FIXAD**: `deadlineText()` ramar in recurring som "Återkommande — nästa omgång stänger …". |
| F6 | MEDIUM | MUCF projektbidrag: fast tak 400 000 kr motsäger sidans egen text "villkor varierar per utlysning" | **FIXAD**: `maxAmountMinor: null`. |
| F7 | LOW/MED | Glasögonbidrag "minst 800 kr" citerat till lag (2016:35) som inte fastställer beloppet | **FIXAD**: beloppet borttaget som hård siffra; texten säger att lagen inte sätter belopp, nivån är regional. |
| F8 | LOW | Titeln lovade "belopp" på 21 sidor utan beloppstak | **FIXAD**: titeln säger "villkor och ansökan" när belopp saknas. |
| F4 | MEDIUM | `person.age66Plus` är en grov proxy som används för fyra olika åldersgränser (60/62/66/67); en 63-åring passerar studiestödens hårdvillkor trots att texten säger 60/62 | **BACKLOG** (kräver numeriskt åldersfaktum — se PERFECTION_BACKLOG). Bedömning ("ser ut att kunna"), inte beslut, mildrar. |

**Rent:** inget "vårdbidrag" (utgånget namn), beslutsdisclaimern renderas,
kureringsstämpeln synlig på alla 72 stöd, de minimis 300 000 € korrekt,
null-belopp renderas ärligt.

## Förtroende & mörka mönster

| Id | Grad | Fynd | Åtgärd |
|---|---|---|---|
| T1 | MEDIUM | Ångerrättssamtycket skickades hårdkodat `immediateDeliveryConsent: true` i alla tre köpflöden — kryssrutan gatade bara knappens `disabled`; det lagrade samtycket speglade inte användarens val | **FIXAD**: skickar kryssrutans verkliga värde (`consent`). |
| T2 | LOW | Demons teaser-mask härleddes ur den riktiga titeln (form-fingeravtryck: ordantal/längder/versaler) — kommentaren "namnet läcker aldrig" överdrev | **FIXAD**: fasta platshållare (samma princip som produktens Matches.tsx). |
| T3 | LOW | Samtyckesrutan renderades EFTER prisknappen i DocumentStudio (läsordning pris→samtycke) | **FIXAD**: samtycket flyttat före knappen. |

**Blur-läckan (den mest sannolika CRITICAL) finns INTE i produktionen:**
servern skickar aldrig stödnamn/belopp före betalning (`buildTeaser` returnerar
bara `{likelihood, category}`), klienten blurrar en fast platshållare, och
finansieringsplanen är 402-gatead. **Rent** även: inga countdowns/timers, inga
förkryssade rutor, priser i klartext, gratisvägen (ansök själv) uttrycklig vid
varje betalpunkt, ångerrättsinformation före köp.

## Relevans & bedömning

| Id | Grad | Fynd | Åtgärd |
|---|---|---|---|
| Rel-F1 | MEDIUM | `fk-narstaendepenning` (vård av döende anhörig) grindades på funktionsnedsättning-i-familjen — dolde stödet från exakt dem som behöver det (den som svarar "nej, ingen funktionsnedsättning" men vårdar en döende förälder) | **FIXAD**: grov hälsogrind borttagen; grindas nu bara på sitt faktiska villkor (`caringForSeriouslyIllRelative`), som ytas som följdfråga. |
| Rel-F2 | MEDIUM | Tre barnstöd (`kommun-skolskjuts`, `kommun-elevresor-gymnasiet`, `csn-inackorderingstillagg`) saknade `hasChildrenAtHome`-grinden syskonstöden har → läckte till barnlösa som "behöver utredas" | **FIXAD**: `hasChildrenAtHome is_true`-grind tillagd i alla tre. |
| Rel-F3 | MEDIUM | Egenföretagare utan satt sektor läckte jordbruksstöd (F-RELEVANS återfödd på motornivå — UI hindrar men API:t inte) | **FIXAD**: jordbruksstöden flyttade från basmängden till `BUSINESS_SECTOR_SLUGS.agriculture`; nås bara av en deklarerad jordbrukare. Enhetstest + vaktpersona. |
| Rel-F4 | MEDIUM | Enkelval av sysselsättning döljer stöd för kombinationssituationer (pensionär som driver enskild firma ser antingen bostadstillägg ELLER företagsstöden, aldrig båda) | **BACKLOG** (intakemodell — kräver flerval eller kombinationsgren). |
| Rel-F5 | LOW/MED | ~18 personspårsstöd grindar på fakta intaget aldrig frågar → permanent "behöver utredas" tills följdfrågor besvaras | **ACCEPTERAD DESIGN** (stegvist intag: `missingFacts` ytas som ja/nej-följdfrågor; dokumenterad, ej dold bugg). |

Auditens tidigare "0 läckor" var sant men snävt (såg bara sektorsgrindade
läckor). Tre nya vaktpersonor tillagda (barnlös, osatt sektor via enhetstest,
vård av anhörig) så att F1–F3 inte kan återkomma.

## Efter åtgärd — recrawl (tester)

- `packages/core`: **100 tester** gröna (nytt RT03-F3-regressionstest).
- `apps/api`: **198 tester** gröna (två tester som kodifierade F3/Rel-F1-buggarna
  omriktade till korrekt beteende).
- Relevansrevisionen: **0 läckor, 0 fallerade positiva** (14 personor, +3 nya).
- `npm run verify`: grönt (se commit).

Föregående pass verifierade som åtgärdade: masterrevisionens + motförhörets
fynd, GATE 0:s teknik/UX. Nästa månads pass börjar med att verifiera dessa 15.
