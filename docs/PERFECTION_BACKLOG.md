# PERFECTION BACKLOG

Levande prioriterad lista ur Perfection Audit 01 (`PERFECTION_BASELINE.md`).
Regel: CRITICAL/HIGH implementeras före allt annat; ett åtgärdat fynd flyttas
till "Åtgärdat" med datum. Zero broken windows (§32): små trasigheter är
kvalitetsfel av samma sort som stora.

## CRITICAL (öppna)

| Id | Fynd | Ägare | Väg |
|---|---|---|---|
| C4 | Entity footprint obefintlig: inga officiella konton, brand-SERP ägs av namngrannen + bidragskalkyl-förväxlingen | **Användaren** | ENTITY_FOOTPRINT.md: öppna LinkedIn + en till kanal med verkligt innehåll (aldrig döda konton), registeruppgifter, sameAs i schemat när URL:erna finns |
| C5 | Ej deployad — index/GSC/CWV/entity omöjliga | **Användaren** | docs/DEPLOY-AGENT.md; därefter GSC + sitemap + brand-SERP-runda |

## HIGH (öppna)

| Id | Fynd | Väg |
|---|---|---|
| H1 | Användarfeedback saknas (§45: "Var detta begripligt?" / "Något som verkar fel?") | Diskret komponent på entity-/guide-sidor + API-yta + kategorisering (fakta/språk/navigering/saknas/tekniskt) → skapar arbetsuppgifter; byggs med F0 |
| H2 | Publikt Trust Center saknas (§43) + rättelsepolicy (§44) | TRUST_CENTER_SPEC.md är byggritningen; sidorna genereras i genseo (utanför /bidrag/, kräver seocheck-utökning) |
| H3 | Innehållsmodulgapet: 12/20 gold standard-moduler saknas; 8/13 ETTA-MÖJLIG-kluster utan sida | Redan planlagt: F0 (behörighetskontroll + ändringshistorik) → B1–B10 (docs/SEO_BLUEPRINTS_SPRINT01.md) |
| H4 | §33–35-kedjan inte sluten: source-diff → berörda publika sidor → review-task → publicerad ändringshistorik | source-fetch + snapshot/diff finns; bygg kopplingen källa→sidor via kunskapsgrafen + kuratorsuppgift + modul 16-rendering |
| H5 | Namngivna granskare saknas (modul 18) — Tier 1 ≥95 onåbart | **Produktägarbeslut** (CONTENT_ENGINE §11.2) |
| H6 | Publik intern sökning saknas (§41: "jag blev av med jobbet" får aldrig ge 0 träffar) | Byggs som del av B1-samlingsvyn: sökindex ur kunskapsgraf + terminologi + grammatikens vardagsspråk |

## MEDIUM (öppna)

- M1 Render-blockerande fonter (SEO_REVISION_01 R6) — mät LCP i fält efter deploy; självhosta vid behov.
- M2 Dynamiska per-sida-OG-bilder (§11) — designsystemstyrd generator; standardbilden duger tills sidmängden motiverar det.
- M3 Typad schemagenerator som egen modul (§17) — när situationssidor/fler sidtyper landar.
- M4 Fullt source object publikt (§34): effective date, sektion, versionshistorik.
- M5 Automatisk term-/stavningskonsekvens för publika ytan (§37) — terminologi.json är källan; bygg kontrollen i seocheck.
- M6 Automatisk visuell QA med skärmbilder i flera vyportar (§38) + cross-browser (§39) — uicheck-infran finns, utöka.
- M7 Full WCAG 2.2 AA-genomgång med hjälpmedel (§31; docs/LIMITATIONS.md).
- M8 Länkhälsomotor för externa myndighetslänkar (§33) — körs i deployad miljö/CI (sandlådans proxy blockerar myndighetsdomäner; falska negativa lokalt).
- M9 Skeleton-/empty-/error-states som systemkomponenter (§4) — designkällan först (design/), sedan ytorna.
- M10 Quality dashboard (§46) — QUALITY_DASHBOARD_SPEC.md; först meningsfull efter deploy när fältdata finns.
- ~~M11 Numeriskt åldersfaktum (red team RT03-F4)~~ → **STÄNGD 2026-08-26.** Födelseårsintaget härleder exakt ålder (`person.ageYears`) och per-gräns-fakta `age60Plus`/`age62Plus`/`age66Plus`/`age67Plus`; seedens studiestöds- och pensionskriterier pekar nu på rätt gräns var för sig (csn-sm/us/ss → 60, csn-oss → 62, pm-afs → 67). Regeltext och matchningslogik stämmer. Härledningen speglas i webb, demo, scenario-/sim-helpers.
- M12 Kombinationssituationer i sysselsättningsintaget (red team RT03-F4/relevans) — enkelval härleder ömsesidigt uteslutande `receivesPension`/`selfEmployed`/`registeredUnemployed`, så en pensionär som driver enskild firma ser antingen bostadstillägg ELLER företagsstöden, aldrig båda. Kräver flerval eller en kombinationsgren i intaget (webb + demo) + relevanslogik som hanterar överlappande roller.
- M13 Delad rate-limit-store (red team RT03-adversariell) — `@fastify/rate-limit` använder in-memory-store; i Vercels serverless-modell delas inte per-IP-räknarna mellan instanser (LIMITATIONS §13). Wire:a en delad store (Vercel KV / Upstash Redis) så gränserna håller vid horisontell skalning. Kräver infra/plan-beslut.
- M14 SSRF DNS-rebinding-residual (red team RT03-adversariell) — källhämtningen revaliderar varje redirect-hop, men `assertSafeUrl` och `fetch` gör separata DNS-uppslag (LIMITATIONS §14). Full stängning kräver att man kopplar upp mot en pinnad IP med explicit Host-header. Låg exponering (källregistrering kräver icke-självbetjänings-rollen data_curator).

## LOW (öppna)

- L1 Sitemap-index per innehållstyp (§14) — vid >1 sidtyp.
- L2 favicon-presentation verifieras på iOS/Android/SERP efter deploy (§12).
- L3 Deadline-textens berikning ur källmönster (SEO_REVISION_01 R9).
- L4 Begreppsbiblioteket i samhällsdebatten (bidragsgapet, stöddjungeln, sökfriktion, bidragsblindhet, stödkartan) — aktiveras med F3-rapporterna: varje begrepp får definition + egen datapunkt + metodik innan det används publikt.
- L5 Transparensparitet i intaget (DOCTRINE_AUDIT yta 7) — demon har "Varför ställs frågan?"-knapp vid varje fråga (`demo/main.tsx`), webbappens `Onboarding.tsx` saknar den. Den betalda produkten bör inte vara mindre transparent än demon; för över affordansen till webben. Stödjer produktdoktrinen §2.

## Åtgärdat

| Datum | Id | Åtgärd |
|---|---|---|
| 2026-08-28 | F-SPECIFIK | Förberedelsen körde fyra generiska mallar trots att kunskapsbasen har 71 kurerade ansökningsscheman (473 fält) med myndighetens egna rubriker, gränser och vägledning, plus 37 kurerade underlagslistor. Schemat exporteras nu till demon och driver förberedelsen: myndighetens sektioner och fält, `visibleWhen`-villkor, `validateAnswers` mot deras gränser, ansökningssätt och underlag per stöd. Stöd utan schema faller tillbaka på mallarna och SÄGER att de är generella; saknad underlagslista påstås aldrig vara "inga underlag". Fynd på vägen: demon frågade efter boendekostnaden och kastade bort siffran — den bärs nu som `person.housingCostMonthly` och förifyller myndighetens fält. Vakt: utökad demo/checks/forberedcheck.mjs |
| 2026-08-28 | F-FÖRBERED | Demons planvy slutade i en myndighetslänk — upptäckt utan förberedelse, alltså halva produkten. Nu kör demon cores riktiga dokumentmotor i webbläsaren: relevanta mallar per stödtyp, förifyllnad ur utredningen, validering som vägrar skriva ofullständigt, och det färdiga dokumentet som text med kopieraknapp (sandlådan tillåter ingen nedladdning). Ärligheten står kvar: 19 kr i produkten, gratis i demon, inget skickas, och att ansöka själv hos myndigheten är alltid gratis. Regressionsvakt: demo/checks/forberedcheck.mjs |
| 2026-08-28 | F-LÄNK | Demons utgående länkar var döda i artefaktvyn: sandlådan blockerar tyst öppning av externa adresser utan `allow-popups`, så "Till ansökan hos …" — själva överlämningen till myndigheten — gjorde ingenting. Alla utgående länkar går nu genom komponenten UtLank som säger varför klicket stoppades och visar adressen kopierbar. Samtidigt: långa källadresser saknade radbrytning i planvyn och sprängde kortet på 320px. Regressionsvakt: demo/checks/lankcheck.mjs (kör demon i samma sandlåda) |
| 2026-08-28 | F-ÅLDER | Demons sparade följdfrågesvar vann tyst över fakta härledda ur födelseåret: med 1987 angivet redovisades "Är du 40 år eller yngre?" som Nej och Startstöd till unga jordbrukare stängdes ute. Intagets härledda faktum vinner nu alltid, inaktuella svar städas ur lagringen, lagringsnyckeln höjd till v2 så gamla motsägelsefulla utkast aldrig läses in. Regressionsvakt: demo/checks/alderscheck.mjs |
| 2026-08-28 | — | SVG-vakten (tools/svgcheck.mjs) i verify + CI: märke och illustrationer måste vara välformad XML och favicon härledd ur logo-mark.svg |
| 2026-08-22 | C1 | Favicon-/brand asset-sviten: eget märke, svg/ico/apple-touch/192/512/manifest/theme-color i webbapp + alla publika sidor |
| 2026-08-22 | C2 | Social metadata komplett: varumärkes-OG 1200×630, twitter:card, og:locale, webbappens hela OG-block; seocheck-gate failar utan |
| 2026-08-22 | C3 | Äkta 404: genseo emitterar hjälpsam noindex-404.html (§40-språk), vercel-rewrite exkluderar statiska ytan, SPA fick riktig 404-vy i stället för tyst redirect |
| 2026-08-22 | — | LANGUAGE_GUIDE.md + seo/terminologi.json (20 termer) + samtliga tio doktrindokument |
