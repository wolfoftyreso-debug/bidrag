# Vad återstår till beta? — full analys 2026-09-03

Analysen är gjord mot repots egna sanningskällor: `docs/LIMITATIONS.md`
(15 numrerade begränsningar), `docs/PERFECTION_BACKLOG.md` (2 CRITICAL,
6 HIGH, 20 MEDIUM öppna), `docs/GATE0_REPORT.md`, `docs/ACTIVATION.md`
(tekniska + icke-tekniska lanseringsvillkor), `docs/DEPLOY-AGENT.md` och de
tre senaste revisionerna (REVISION_2026-09-01, UX_MOBBIN_2026-09-02,
KURERING_2026-09-03). Inget nedan är ett antagande; varje punkt har en
källa i repot.

## Definition

**Beta** = *sluten beta*: ett begränsat antal inbjudna riktiga användare på
den riktiga domänen, med riktiga betalningar (Stripe) och riktiga kvitton,
under aktiv observation. Inte öppen lansering, inte SEO-trafik. Exitkriteriet
för betan står sist.

## Vad som är klart (bevisat, inte påstått)

| Område | Läge | Bevis |
|---|---|---|
| Domänmotor, API, webb, demo | Byggt, deterministiskt, testat | `npm run verify` 24/24; core 100 tester; api 228 tester; 6 webbläsargenomklickningar (`verify:ui`) |
| Produktionsartefakten | Genomkörd lokalt exakt som Vercel kör den | DEPLOY-AGENT §"Produktionsartefakten är genomtestad lokalt": deploy-smoke i båda lägena, cron 401/200, lagringsdrivaren bevisad |
| Databas | Bootstrap + migreringar + seed, rundtur från tom databas | `deploy/bootstrap.sql` 84/36/70/37/11510/15; backup/restore-övning i OPERATIONS §Rehearsal log |
| Betalningar | Stripe Checkout + webhook + entitlement + kvitton med moms + ångerrättssamtycke | LIMITATIONS §10, §12 A1; stripe.test.ts; uicheck13/14 |
| GDPR-självservice | Export + typad radering + retention | LIMITATIONS §7 |
| Säkerhet | Adversariell svit (TOCTOU, förfalskade callbacks, tenant-isolering), hemlighetsskanning, RLS som djupförsvar | adversarial.test.ts; verify steg "Inga hemligheter"; DEPLOY-AGENT §RLS-fällan |
| Kapacitet | 324 req/s, 0 fel i lasttest (utan per-IP-gräns) | REVISION_2026-09-01 |
| Kunskapsbas | 84 stöd, 70 scheman (467 fält), 57 underlagslistor, 11 språk 100 % täckta | KURERING_2026-09-03; `i18n:cov` |
| Publik yta | 169 statiska sidor, schema-graf, 12 situationsnoder, QA-crawl i verify | GATE0 (tekniskt block grönt), SCHEMA_ENGINE |
| UX | Alla flöden genomgångna mot Mobbin-mönster, fyra fynd lagade med vakter | UX_MOBBIN_2026-09-02 |

Det som återstår är alltså inte "bygga produkten". Det är **drift, juridik,
sanningsgranskning och mätning** — plus några produktbeslut.

## A. Hårda blockerare — betan kan inte starta utan dessa

Ordningen är beroendeordning. Punkt 1 blockerar 2–4 och 8–9.

| # | Vad | Vem | Uppskattning | Källa |
|---|---|---|---|---|
| A1 | **Deployn**: Neon Postgres via Vercel Storage, env-blocket (nio variabler, hemligheterna redan genererade), ladda bootstrap, RLS-kontrollen (`current_user` måste äga tabellerna, 84 rader synliga), sedan `tools/deploy-smoke.mjs` utifrån | Operatör (connectorn kan inte sätta env eller skapa databas) | 30–60 min | DEPLOY-AGENT steg 1–4; C5 |
| A2 | **Domänen**: `bidragskoll.se` pekar på parkering (194.9.94.85). Koppla till Vercel, sätt `PUBLIC_BASE_URL`/`CORS_ORIGIN` till domänen, verifiera HTTPS | Operatör | 30 min + DNS-propagering | PREFERRED_SOURCES §DNS; C5 |
| A3 | **Stripe live**: livenycklar + webhook-endpoint på domänen + ett riktigt köp för 19 kr med riktigt kvitto | Operatör sätter nycklar; jag kör testet via connectorn | 1 h | ACTIVATION §3; uppgift #101 |
| A4 | **Resend**: domänverifiering (SPF/DKIM) så att kvitton och återställningslänkar går ut; annars är e-post ärligt av (503) men betan tappar två flöden | Operatör (DNS) + jag (connectorn) | 1 h | ACTIVATION §4; LIMITATIONS §4 |
| A5 | **DPIA**: art. 9-hälsodata behandlas (frågan om funktionsnedsättning/sjukdom). Obligatorisk *före* behandling, alltså även för sluten beta. Underlaget finns i `docs/PRIVACY.md` | Operatör/DPO (dokumentet kan jag utkasta) | 1–2 dagar | ACTIVATION §icke-tekniska 1; LIMITATIONS §12 A2 |
| A6 | **Juristgranskning** av `/villkor`, samtyckestexten vid köp och kvittots ångerrättsrad | Jurist | 2–4 h jurist | ACTIVATION 2; LIMITATIONS §12 A1 |
| A7 | **Mänsklig granskning av kunskapsbasen**: alla 84 stöd är `ai_curated`. Dagens pass hittade ett stöd som varit avskaffat i fyra år och en text som blev fel för två dagar sedan. Minimum för beta: de ~25 stöd som syns oftast i analysen (universella + topp-20 i motorsimuleringen) plus de 20 stöd vars källa är en startsida (M25) | Kurator med admin-kuratorsflödet; jag förbereder listan och källorna | 2–3 dagar för minimum, 1–2 veckor för alla 84 | ACTIVATION 3; LIMITATIONS §12 A3; M25 |
| A8 | **Supportkanal**: brevlåda på domänen för reklamationer och återbetalningar; manuell återbetalningsrutin i Stripe + `refundStatus` på kvittot | Operatör | 1 h | ACTIVATION 4; LIMITATIONS §12 |
| A9 | **Larm och jour (minimum)**: readiness-proben under cron, e-postlarm vid 5xx-spik och vid `ok:false`, en person som svarar. Dashboards kan vänta | Jag (Vercel-connectorn + cron finns) + operatör (vem som larmas) | 2 h | LIMITATIONS §9; OPERATIONS §Monitoring |

## B. Bör vara på plats vid betastart — annars lär vi oss inget

| # | Vad | Varför för beta | Uppskattning | Källa |
|---|---|---|---|---|
| B1 | **Feedbackkomponent** "Verkar något fel? / Var detta begripligt?" på analys, stödsida och arbetsyta, med kategori och fri text, in i inkorgen/admin | Betans hela syfte är att hitta fel i kunskapsbasen och friktion i flödet; utan kanal blir det tyst | 1 dag | H1 |
| B2 | **Instrumentering**: händelser för intag påbörjat/klart, matchning, utklick "ansök själv", köp, förberedelse klar (QSDR/ARR-måtten) — serverside, utan tredjepartscookies. GSC-verifiering direkt efter deploy | Projektet saknar analytics helt; betan är oanvändbar som mätning utan detta | 1 dag | PREFERRED_SOURCES; LAUNCH_DEMAND_INTELLIGENCE; prio 3 |
| B3 | **Ansökningslänkar per stöd** (M17): 44 stöd skickar till en startsida (16 FK-stöd till `forsakringskassan.se/privatperson`). Överlämningen är produktens sista steg — en generisk länk är friktion exakt där värdet ska levereras | Samma kuratorspass som A7; källorna hämtades i dag för ~20 av dem | ingår i A7 | M17, KURERING_2026-09-03 |
| B4 | **Riktad tillgänglighetsgenomgång** av intaget, analysen och köpet med tangentbord och skärmläsare (inte hela WCAG 2.2) | Målgruppen har högre andel hjälpmedelsanvändare; punktfixar finns men helheten är oreviderad | 1 dag | M7; LIMITATIONS §12 |
| B5 | **Betan på svenska**: språkväljaren kvar, men inbjudan och stöd på svenska. Översättningarna är AI-gjorda och ogranskade (so/ti svagast); etiketten säger det ärligt | Sänker risk; översättningsgranskning är ett eget pass | beslut | LIMITATIONS §15 |
| B6 | **Rate limit per instans** (M13): i Vercels serverless delas inte räknaren. Acceptabelt för sluten beta, inte för öppen | dokumentera; delad store (Upstash/Postgres) före öppen beta | 0 nu, ½ dag senare | LIMITATIONS §13 |
| B7 | **Beta-läge i produkten**: inbjudningskod eller allow-lista på registrering, "beta"-märkning i sidfoten, kontakt-länk. Ingen sådan gate finns i dag | Annars är "sluten" beta öppen så fort domänen lever | ½ dag | (nytt) |

## C. Inte betablockerande — hör till öppen beta och lansering

- **SEO-innehållet** (GATE 0 CONTENT-RED: 0 av 332 sökområden GREEN, guider
  och kalkylatorer obyggda, de 25 klustren). Betan ska inte ha söktrafik.
- **Trust Center + rättelsepolicy** (H2), **entity footprint** (C4),
  **namngivna granskare** (H5), **publik sökning** (H6), Preferred Sources.
- **Swish** (avtal och certifikat från banken; Stripe är lanseringsrälsen).
- **Automatisk återbetalning**, digital post, malware-scanning, native
  inlämningsadaptrar (LIMITATIONS §1, §3, §5).
- **"Vet inte"-svar** (M23), **ångerfrist vid radering** (M24),
  **frågebördan** (M22, p50 20 frågor) — mät i betan innan beslut.
- **Fullständig WCAG 2.2 AA** och externa användartester bortom betan.

## Två produktbeslut som betan bör ta ställning till

1. **Kontovägg före första matchningen** (M19): i dag krävs konto för att
   se analysen. Det är en odokumenterad premiss. Betan kan mäta avhoppet vid
   registreringen; alternativet (anonymt intag, konto vid köp) är ett
   större bygge och bör inte göras blint.
2. **Vad "human_verified" ska betyda**: kuratorsflödet finns, men utan
   namngivna granskare (H5) blir stämpeln en intern markering. Betan behöver
   minst A7:s minimum; lanseringen behöver en policy.

## Rekommenderad ordning (kritisk väg)

```
Dag 1   A1 deploy → deploy-smoke → RLS-kontroll → A2 domän → A9 larm
Dag 1–2 A3 Stripe live-köp · A4 Resend · A8 supportbrevlåda · B7 betagate
Dag 2–3 B1 feedback · B2 instrumentering + GSC · B4 a11y-pass
Dag 2–5 A7 kuratorsminimum (25 + 20 stöd) inkl. B3 länkar   [parallellt]
Parallellt A5 DPIA-utkast → DPO · A6 jurist
Dag 5–6 Egen genomkörning på riktiga domänen (uicheck-sviten mot prod-URL,
        deploy-smoke, ett riktigt köp, ett riktigt kvittomejl,
        en riktig återställning) → bjud in första 10 användarna
```

**Kalendertid:** ungefär en arbetsvecka om operatörsstegen (A1, A2, A5, A6,
A8) inte väntar. Av det är ~2 dagar mitt byggarbete (B1, B2, B4, B7, larm,
DPIA-utkast) och 2–3 dagar kuratorsarbete. Det som inte kan forceras är
juristen och DPO:n.

## Exitkriterier för betan (när är den klar?)

- ≥ 30 fullständiga intag av inbjudna användare, ≥ 10 riktiga köp med
  kvitto, 0 betalningar utan kvitto, 0 kvitton utan betalning.
- Alla feedbackärenden i kategorin "fakta" åtgärdade eller avvisade med
  källa; de stöd betaanvändarna faktiskt nådde är `human_verified`.
- Inga 5xx i loggen som inte är förklarade; readiness `ok:true` hela
  perioden; p95 för matchning under 2 s i fält.
- Kontovägg-beslutet (M19) fattat på mätdata.
- DPIA undertecknad, villkoren juristgranskade, supportkanalen använd minst
  en gång med dokumenterad hantering.

Först därefter: öppen beta, SEO-innehållet och offsite (GATE 0 gäller
fortfarande — offsite är fryst tills gaten är grön).
