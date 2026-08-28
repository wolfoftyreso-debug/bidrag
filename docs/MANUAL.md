# Bidragskoll.se — systemhandbok

> **GENERERAD FIL — redigera aldrig för hand.** Handboken byggs ur systemets
> faktiska källor (routetabellen, cores exporter, kunskapsbasens seed,
> `.env.example`, `package.json`) av `tools/genmanual.mjs`. Regenerera med
> `npm run manual`. `npm run verify` fallerar om handboken inte är aktuell,
> och om någon API-operation eller något kommando saknar instruktion.

## 1. Vad systemet är

Bidragskoll.se utreder vilka stöd en person kan ha rätt till utifrån
livssituationen och förbereder hela ansökan. **Open Discovery:** upptäckten
och resultaten är gratis och inte låsta — det enda som kostar är att förbereda
en ansökan i systemet (19 kr per ansökan; alla dokument för den ansökan ingår).
Att ansöka själv direkt hos myndigheten är alltid gratis och sägs uttryckligen.
Två orubbliga principer: **en fråga per skärm**
och **bedömning, aldrig beslut**. Systemet påstår aldrig att något är
inlämnat utan verifierbart kvitto, och hittar aldrig på data.

## 2. Användarresan, moment för moment

1. **Konto** — registrera med e-post + lösenord (inga personnummer, någonsin).
   Skapa gärna engångs-återställningskoder under Konto & data direkt: de är
   reservvägen om e-postkanalen inte är aktiverad.
2. **Intaget** — en fråga per skärm om livssituationen. Varje fråga går att
   backa till och ändra. Känsliga frågan om funktionsnedsättning/långvarig
   sjukdom i familjen är frivillig på riktigt: "Vill inte svara" respekteras,
   faktumet lämnas osatt och frågan återkommer aldrig (art. 9-samtycke
   tidsstämplas när den besvaras).
3. **Analysen (gratis, Open Discovery)** — räknas mot alla stöd och visas
   direkt: varje stöd med namn, sannolikhet och förklaring. Ingen betalvägg,
   inga låsta matchningar — resultaten är fria att se.
4. **Förberedd ansökan (19 kr/ansökan)** — det enda köpet: köpet kräver
   ikryssat samtycke till omedelbar leverans (ångerrätten upphör —
   distansavtalslagen); utan kryss vägrar servern (400). Betala med Swish (QR
   på desktop, app-länk i mobil). Kvittot med löpnummer och 25 % moms hamnar
   under Mina köp direkt.
5. **Analysen** — varje stöd visas med sannolikhet, förklaring per kriterium,
   källa med färskhet och kureringsstämpel ("AI-sammanställd från officiell
   källa — ej granskad av människa" tills en kurator höjt den). Obesvarade
   följdfrågor sorteras efter hur många stöd de avgör; svar går att ändra i
   efterhand under Dina svar.
6. **Vägvalet per stöd** — antingen gratis "ansök själv"-länk till
   myndigheten, eller **Förbered ansökan i systemet (19 kr)**: ansökan
   förifylls ur intaget och alla dokument för den ansökan ingår.
7. **Ansökningsarbetsytan** — schema-drivna fält (autosparas), budget i ören
   med aktivitet↔kostnads-koppling, dokument ur valvet, deterministisk
   granskning som säger READY/NOT_READY med prioriterade luckor i stället
   för tomt beröm.
8. **Dokumentstudion** — mallarna i §5 renderas till PDF under Mina
   dokument; språkförslag (om aktiverat) passerar deterministiska vakter och
   sparas aldrig utan ditt godkännande.
9. **Inlämning** — utan myndighetsadapter förbereder systemet ett assisterat
   paket och du bekräftar själv den externa inlämningen med kvittouppgift;
   först då blir ärendet SUBMITTED. Ingen låtsasautomatik.
10. **Efteråt** — beslut registreras, återrapporteringskrav får deadlines,
    kalendern och notiserna håller ordning. Kvitton ligger kvar under Mina
    köp (PDF + ev. e-post). Konto & data ger GDPR-export och radering som
    självservice.

## 3. Kuratorns arbetsflöde (admin)

Kräver rollen administrator/data_curator. Källregistret hämtar officiella
källor på schema (6 h); ändringar blir snapshot-diffar i klarspråk i
granskningskön. Människan avgör: applicera som ny regelversion (append-only,
spårbar) eller avfärda med motivering. Kureringsstämpeln höjs endast via
verify-flödet efter kontroll mot levande källa — `ai_curated` →
`human_curated`/`human_verified`. Inaktuella matchningar listas och räknas
om. Inget regelinnehåll autopubliceras någonsin.

## 4. Funktionskatalog — hela API-ytan

Samtliga 90 operationer, grupperade. Webbappen använder exakt dessa ytor —
katalogen är därmed också webbens funktionskarta.

### Konto & inloggning

| Operation | Instruktion |
|---|---|
| `GET /v1/auth/me` | Vem är jag: användare + medlemskap. Webben anropar den vid varje sidladdning. |
| `GET /v1/auth/recovery-codes` | Status för koderna: hur många oanvända som finns kvar. |
| `POST /v1/auth/login` | Logga in; sätter access-cookien och returnerar användaren. |
| `POST /v1/auth/logout` | Logga ut och ogiltigförklara refresh-tokenen. |
| `POST /v1/auth/recover-with-code` | Återställ lösenordet med en oanvänd engångskod. |
| `POST /v1/auth/recovery-codes` | Generera engångs-återställningskoder (visas EN gång — spara dem). Kanal-lös reservväg när e-post saknas. |
| `POST /v1/auth/refresh` | Byt refresh-token mot ny access-token — webben gör detta automatiskt vid 401. |
| `POST /v1/auth/register` | Skapa konto: e-post + lösenord + visningsnamn → 201 med inloggad session (cookie). Rate-limitad (~10/min per IP). |
| `POST /v1/auth/request-password-reset` | Beställ återställningslänk via e-post. Utan e-postkanal: ärlig 503 — använd återställningskoderna i stället. |
| `POST /v1/auth/reset-password` | Sätt nytt lösenord med token ur återställningslänken. |

### Profiler

| Operation | Instruktion |
|---|---|
| `GET /v1/profiles` | Lista tenantens sökandeprofiler (person eller organisation). |
| `PATCH /v1/profiles/:id` | Uppdatera profilfakta — matchningarna räknas om deterministiskt. |
| `POST /v1/profiles` | Skapa profil med fakta från intaget (`facts` är kanoniska fältvägar, t.ex. person.professionalArtist). |
| `POST /v1/profiles/:id/external-identifiers` | Registrera extern identifierare (org.nr/OID) — fältkrypteras (AES-256-GCM) före lagring. Personnummer tas aldrig emot. |

### Projekt, matchning & köp

| Operation | Instruktion |
|---|---|
| `GET /v1/projects` | Lista projekt/utredningar. |
| `GET /v1/projects/:id` | Hämta projektet med status och fakta. |
| `GET /v1/projects/:id/document-credits` | Kvarvarande dokumentkrediter (härledda ur bekräftade betalningar — aldrig ur klienten). |
| `GET /v1/projects/:id/generated-documents` | Lista projektets genererade dokument. |
| `GET /v1/projects/:id/matches` | Hämta analysen — alltid fullständig och gratis (Open Discovery): varje stöd med förklaring per kriterium, källa och färskhet. Ingen betalvägg framför resultaten. |
| `GET /v1/projects/:id/receipt` | Kvitto för projektets köp (förberedd ansökan). |
| `PATCH /v1/projects/:id` | Uppdatera projektets fakta/intention; svar på öppna följdfrågor sparas hit. |
| `POST /v1/projects` | Skapa projekt: profil + intention (fritext) + fakta. Detta är intagets slutresultat. |
| `POST /v1/projects/:id/application-purchase` | Köp en ansökningsförberedelse (19 kr — alla dokument för den ansökan ingår). Kräver `immediateDeliveryConsent: true` (ångerrätten) — annars 400. Utan betalprovider: ärlig 503. |
| `POST /v1/projects/:id/document-pack` | Köp dokumentpaket i dokumentstudion (samtyckeskrav + 503-ärlighet som övriga köp). |
| `POST /v1/projects/:id/funding-stack` | Bygg finansieringsplan av valda stöd; kontrollerar kombinerbarhet och dubbelfinansiering. |
| `POST /v1/projects/:id/generated-documents` | Generera ett dokument ur en mall: svar valideras, förifylls ur projektet och renderas deterministiskt. |
| `POST /v1/projects/:id/matches` | Räkna om matchningarna mot alla 72 stöd (idempotent, deterministisk). |

### Stödkatalogen

| Operation | Instruktion |
|---|---|
| `GET /v1/funding-opportunities` | Sök/lista stödkatalogen (delad läsyta — inga persondata). |
| `GET /v1/funding-opportunities/:id` | Stödets detaljer: kriterier med proveniens, belopp, deadline, källa + färskhet, kureringsstämpel (t.ex. ai_curated). |

### Ansökningar

| Operation | Instruktion |
|---|---|
| `DELETE /v1/applications/:id/budget-lines/:lineId` | Ta bort budgetrad. |
| `GET /v1/applications` | Lista ansökningsärenden. |
| `GET /v1/applications/:id` | Hämta ärendet: schema-drivna fält, budget, dokument, tillstånd, historik. |
| `GET /v1/applications/:id/review` | Deterministisk granskning (Application Intelligence): READY/NOT_READY med prioriterade luckor, konsistens- och språkkontroller. |
| `GET /v1/applications/:id/validate` | Strukturvalidering: obligatoriska fält, bilagor, budgetregler. |
| `PATCH /v1/applications/:id` | Spara fältsvar (autosparas från arbetsytan). |
| `POST /v1/applications` | Skapa ansökan för projekt + stöd. Utan förbrukningsbar 19 kr-kredit: 402 med pris — webben visar köpflödet. |
| `POST /v1/applications/:id/budget-lines` | Lägg budgetrad (heltal i ören; aktivitet↔kostnads-länk). |
| `POST /v1/applications/:id/decision` | Registrera myndighetens beslut (bifall/avslag) med underlag. |
| `POST /v1/applications/:id/documents` | Koppla dokument ur valvet till ärendet. |
| `POST /v1/applications/:id/reporting-requirements` | Lägg återrapporteringskrav med deadline efter bifall. |
| `POST /v1/applications/:id/submissions/:submissionId/confirm-external` | Användaren bekräftar att den externa inlämningen är gjord, med kvittouppgift — först då blir ärendet SUBMITTED. |
| `POST /v1/applications/:id/submit` | Starta inlämning. Utan avtalad adapter: assisterat paket (validerad payload + hash + officiell URL) — aldrig låtsad automatik. |
| `POST /v1/applications/:id/suggest-field` | Språkförslag för ett fält (generation mode). Kräver ANTHROPIC_API_KEY; annars ärlig 503. Varje förslag passerar cores deterministiska vakter och sparas aldrig utan användarens godkännande. |
| `POST /v1/applications/:id/transition` | Flytta ärendet i tillståndsmaskinen — vaktade övergångar kan inte forceras (se tillståndstabellen nedan). |

### Dokument

| Operation | Instruktion |
|---|---|
| `DELETE /v1/documents/:id` | Radera dokument. |
| `GET /v1/documents` | Lista dokumentvalvet. |
| `GET /v1/documents/:id/download` | Ladda ner ur valvet. |
| `GET /v1/generated-documents/:id/download` | Ladda ner genererat dokument som PDF. |
| `POST /v1/documents` | Ladda upp (multipart, max 20 MB): magic-byte-kontroll, sha256, ev. ClamAV — utan skanner märks filen scan_unavailable. |

### Betalningar & kvitton

| Operation | Instruktion |
|---|---|
| `GET /v1/payments/:id/qr` | Swish-QR för desktopflödet (proxad, tokenskyddad). |
| `GET /v1/payments/:id/receipt` | Kvittot som strukturerad data. |
| `GET /v1/payments/:id/receipt.pdf` | Kvittot som PDF (löpnummer BS-ÅÅÅÅ-NNNNNN, 25 % moms, ångerrättsrad). |
| `GET /v1/payments/:id/status` | Betalningens tillstånd — webben pollar tills confirmed. Swish verifieras alltid server-till-server (mTLS), aldrig på callbackens ord. |
| `GET /v1/purchases` | Mina köp: alla köp med kvittonummer och belopp. |
| `POST /v1/payments/:id/mock-confirm` | Bekräfta SIMULERAD betalning — finns bara när mock är tillåten (aldrig i skarp produktion; 404 annars). |
| `POST /v1/payments/:id/receipt-email` | Mejla kvittot (kräver e-postkanal; kvittot finns alltid kvar i kontot). |
| `POST /v1/payments/:id/resend-receipt` | Skicka om kvittomejlet. |
| `POST /v1/webhooks/payments/:provider` | Betalleverantörens callback. Osignerad by design: används bara som väckning — bekräftelse sker via verifierad statushämtning. 503 utan konfigurerad provider. |

### Team & GDPR

| Operation | Instruktion |
|---|---|
| `DELETE /v1/tenant` | GDPR-radering (art. 17): kaskaderar genom alla tenantägda tabeller. Kräver typad bekräftelse; kvitton bevaras enligt bokföringslagen. |
| `DELETE /v1/tenant/invites/:id` | Återkalla inbjudan. |
| `GET /v1/invites/:token` | Visa inbjudan (delbar länk). |
| `GET /v1/tenant/export` | GDPR-export (art. 15/20): all tenantdata som strukturerad fil. Endast ägarrollen. |
| `GET /v1/tenant/invites` | Lista utestående inbjudningar. |
| `GET /v1/tenant/members` | Lista teamets medlemmar och roller. |
| `POST /v1/invites/:token/accept` | Acceptera inbjudan och gå med i tenanten. |
| `POST /v1/tenant/invites` | Bjud in via e-post (hashad token; ägarroll kan aldrig delas ut via inbjudan). |
| `POST /v1/tenants` | Skapa organisationstenant (för team). |

### Bidragsinkorgen

| Operation | Instruktion |
|---|---|
| `GET /v1/correspondence` | Bidragsinkorgen: myndighetsmeddelanden användaren registrerat (uppladdning/vidarebefordran/manuellt). Inga portalinloggningar lagras någonsin. |
| `PATCH /v1/correspondence/:id` | Ändra klassificering/ärendekoppling. |
| `POST /v1/correspondence` | Registrera post; klassificeras deterministiskt och matchas mot ärende med mänsklig override. |

### Notiser

| Operation | Instruktion |
|---|---|
| `GET /v1/notifications` | In-app-notiser (deadlines, kuratorspåminnelser m.m.). |
| `POST /v1/notifications/:id/read` | Markera notis som läst. |

### Kuratorskonsolen

| Operation | Instruktion |
|---|---|
| `GET /v1/admin/opportunities` | Stödlistan ur kuratorsperspektiv (kureringsstatus). |
| `GET /v1/admin/review-queue` | Granskningskön: upptäckta källändringar som väntar på människa. |
| `GET /v1/admin/sources` | Kuratorskonsolen: källregistret med färskhet. |
| `GET /v1/admin/sources/:id/snapshots` | Källans snapshothistorik. |
| `GET /v1/admin/stale-matches` | Matchningar som blivit inaktuella av regeländringar. |
| `POST /v1/admin/opportunities/:id/rule-versions` | Publicera ny regelversion (append-only, tidsdaterad, spårbar till källa). |
| `POST /v1/admin/opportunities/:id/verify` | Höj kureringsstämpeln (ai_curated → human_curated/human_verified) efter kontroll mot levande källa — enda vägen dit. |
| `POST /v1/admin/review-queue/:id/apply` | Applicera föreslagen regeländring som ny regelversion. |
| `POST /v1/admin/review-queue/:id/resolve` | Avfärda/lös köpost med motivering. |
| `POST /v1/admin/sources` | Registrera ny officiell källa. |
| `POST /v1/admin/sources/:id/fetch` | Hämta källan nu → snapshot + diff i klarspråk till granskningskön. |

### Interna jobb

| Operation | Instruktion |
|---|---|
| `GET /v1/internal/cron/:job` | Kör bakgrundsjobb (source-fetch, deadline-scan, stale-match-recalc, curator-reminders, retention). Vercel Cron anropar med Bearer CRON_SECRET; utan hemligheten är ytan 404. |
| `GET /v1/internal/readiness` | Aktiveringsberedskap: databas/Swish/Resend/Anthropic som ready/mock/not_configured + blockerare. Bearer CRON_SECRET; `?probe=true` gör ofarliga verifieringsanrop. |
| `POST /v1/internal/cron/:job` | Samma som GET — båda metoderna accepteras av Vercel Cron. |

### Systemytor

| Operation | Instruktion |
|---|---|
| `GET /healthz` | Processhälsa — 200 så länge processen lever. Används av lastbalanserare/Docker HEALTHCHECK. |
| `GET /metrics` | Prometheus-mått (bidrag_*-prefix). Exponeras inte i Vercel-driften — läs funktionsloggarna där. |
| `GET /readyz` | Riktig beredskap — kör `select 1` mot databasen, 503 om den inte svarar. Vänta på 200 efter deploy. |
| `GET /v1/openapi.json` | Maskinläsbart API-kontrakt (OpenAPI 3.1) för de schema-registrerade ytorna. |

## 5. Dokumentmallarna

| Mall | Mottagare | Sektioner | Frågor |
|---|---|---|---|
| **Ansökan om ekonomiskt stöd** (`ansokan-ekonomiskt-stod`) — Själva ansökningsdokumentet: vem du är, vad du söker och en kort motivering. | Myndigheten/organisationen som handlägger stödet | 4 | 11 |
| **Bilaga — beskrivning av ekonomisk situation** (`bilaga-ekonomisk-situation`) — En strukturerad bild av hushållets inkomster och utgifter — den bilaga handläggare oftast frågar efter. | Bilaga till ansökan | 5 | 11 |
| **Beskrivning av behov** (`behovsbeskrivning`) — Förklarar konkret vad behovet är, vem det gäller och vad det betyder i vardagen. | Bilaga till ansökan | 3 | 7 |
| **Förklaring av särskilda omständigheter** (`sarskilda-omstandigheter`) — När något i er situation behöver förklaras: sjukdom, separation, varierande inkomst, oförutsedda händelser. | Bilaga till ansökan | 5 | 6 |
| **Projektbeskrivning** (`projektbeskrivning`) — Den logiska kedjan finansiärer letar efter: problem, orsak, mål, aktiviteter, mätbara resultat och vad som består efteråt. | Bilaga till ansökan | 10 | 23 |

Förifyllnad (`prefillAnswers`), validering (`validateDocumentAnswers`) och
rendering (`renderDocument`) är deterministiska och ligger i `packages/core`.

## 6. Ansökans tillståndsmaskin

Tillstånd: `DISCOVERED` → `MATCHED` → `SELECTED` → `PREPARING` → `READY_FOR_REVIEW` → `READY_TO_SUBMIT` → `SUBMITTING` → `SUBMITTED` → `ACKNOWLEDGED` → `UNDER_REVIEW` → `ACTION_REQUIRED` → `DECISION_RECEIVED` → `AWARDED` → `REJECTED` → `WITHDRAWN` → `CLOSED`.

Vaktade övergångar (kan aldrig forceras via API:t):

| Övergång | Krav |
|---|---|
| `READY_TO_SUBMIT->SUBMITTED` | requires a submission receipt (user-confirmed external submission) |
| `SUBMITTING->SUBMITTED` | requires a verified submission confirmation from the adapter |
| `READY_FOR_REVIEW->READY_TO_SUBMIT` | requires all mandatory fields valid and mandatory attachments present |
| `DECISION_RECEIVED->AWARDED` | requires a recorded decision |
| `DECISION_RECEIVED->REJECTED` | requires a recorded decision |

## 7. Kunskapsbasen i siffror

72 stöd från 35 finansiärer, 71 ansökningsscheman, 36 källor (kurerade 2026-08-13).
Allt seedat innehåll stämplas `ai_curated` tills en människa granskat det.

| Finansiär | Stöd |
|---|---|
| Allmänna arvsfonden | 1 |
| Arbetsförmedlingen | 3 |
| Boverket | 1 |
| CSN — Centrala studiestödsnämnden | 6 |
| Din kommun | 4 |
| Din region | 2 |
| Energimyndigheten | 2 |
| Europeiska kommissionen (Erasmus+/EACEA) | 3 |
| Formas | 1 |
| Forte — Forskningsrådet för hälsa, arbetsliv och välfärd | 1 |
| Försäkringskassan | 8 |
| Jordbruksverket | 3 |
| Konstnärsnämnden | 3 |
| Kulturrådet | 6 |
| Länsstyrelsen i ditt län | 1 |
| Majblommans Riksförbund | 1 |
| Migrationsverket | 1 |
| MUCF — Myndigheten för ungdoms- och civilsamhällesfrågor | 3 |
| Naturvårdsverket | 3 |
| Nordisk kulturfond | 1 |
| Pensionsmyndigheten | 2 |
| Radiohjälpen | 1 |
| Riksantikvarieämbetet | 1 |
| Riksidrottsförbundet | 1 |
| Socialtjänsten i din kommun | 1 |
| Sparbanksstiftelsen i ditt område | 1 |
| Statens musikverk | 1 |
| Svenska ESF-rådet | 1 |
| Svenska Filminstitutet | 1 |
| Svenska institutet | 1 |
| Svenska Postkodstiftelsen | 1 |
| Tillväxtverket | 2 |
| UHR — Universitets- och högskolerådet | 1 |
| Vetenskapsrådet | 1 |
| Vinnova | 2 |

## 8. Miljövariabler

`.env.example` är sanningskällan — tabellen nedan genereras ur den.

### Databas (Neon / Vercel Postgres)

| Variabel | Beskrivning |
|---|---|
| `DATABASE_URL` | Runtime: poolad anslutning (Neon pooler, host ...-pooler.neon.tech, sslmode=require). |
| `DIRECT_DATABASE_URL` | Migreringar/seed: direktanslutning (icke-poolad host) — kör aldrig migreringar via poolern. |
| `PG_POOL_MAX` | Serverless: håll poolen liten per funktionsinstans. |

### Auth & kryptering

| Variabel | Beskrivning |
|---|---|
| `AUTH_SECRET` | Minst 32 tecken; rotera vid misstanke om läckage. |
| `FIELD_ENCRYPTION_KEY` | 32 byte hex (64 tecken) för fältkryptering av externa identifierare. |

### Applikation

| Variabel | Beskrivning |
|---|---|
| `PORT` | Lokal utveckling: sätt PORT=3100 — vite-proxyn (apps/web) och alla verifieringsverktyg i tools/ antar API:t på :3100 (kodens default är 3000). |
| `PUBLIC_BASE_URL` | — |
| `CORS_ORIGIN` | — |
| `LOG_LEVEL` | — |
| `RATE_LIMIT_MAX` | — |

### Lagring (dokumentvalvet)

| Variabel | Beskrivning |
|---|---|
| `STORAGE_DRIVER` | 'disk' lokalt/i container (kräver persistent volym); 'postgres' på Vercel+Neon (filerna bor i databasen — fullständigt privat, ingen publik URL, överlever serverless); 'supabase' finns kvar som alternativ (privat bucket, |
| `UPLOAD_DIR` | — |
| `SUPABASE_URL` | Endast om STORAGE_DRIVER=supabase: |
| `SUPABASE_SERVICE_ROLE_KEY` | — |
| `SUPABASE_STORAGE_BUCKET` | — |

### Bakgrundsjobb

| Variabel | Beskrivning |
|---|---|
| `CRON_SECRET` | Container: ENABLE_WORKER=true (pg-boss). Vercel: ENABLE_WORKER är irrelevant; Vercel Cron anropar /v1/internal/cron/:job med Bearer CRON_SECRET. |

### E-post (Resend är den påkopplade kanalen)

| Variabel | Beskrivning |
|---|---|
| `RESEND_API_KEY` | I produktion sätts RESEND_API_KEY + EMAIL_FROM (verifierad avsändardomän i Resend). Kanalen används för lösenordsåterställningslänkar och för att skicka kvitton ("Skicka kvittot via e-post" i Mina köp). Kvittot är fortfa |
| `SMTP_URL` | — |
| `EMAIL_FROM` | — |

### Betalningar

| Variabel | Beskrivning |
|---|---|
| `APPLICATION_PRICE_MINOR` | Momsen är fast 25 % (standardsats för elektroniskt levererade tjänster till konsument i Sverige) och är medvetet inte konfigurerbar — se apps/api/src/config.ts. Säljaruppgifterna nedan är Landvex AB:s riktiga uppgifter o |
| `SELLER_NAME` | — |
| `SELLER_ORG_NUMBER` | — |
| `SELLER_VAT_NUMBER` | — |
| `SELLER_ADDRESS` | — |
| `SWISH_MERCHANT_ALIAS` | Swish Handel (Commerce API). Aktiveras först med handelsavtal + mTLS- certifikat från banken; adaptern vägrar ärligt (503) tills dess. Certifikat och nyckel som BASE64-kodad PEM (serverless har inget filsystem): base64 - |
| `SWISH_KEY_PASSPHRASE` | — |
| `SWISH_API_BASE` | Test/preview: peka mot MSS-simulatorn https://mss.cpc.getswish.net |
| `SWISH_QR_BASE` | — |
| `STRIPE_SECRET_KEY` | Stripe Checkout (kort m.m.) — lanseringsrälsen medan Swish-avtalet dröjer. STRIPE_SECRET_KEY aktiverar providern; STRIPE_WEBHOOK_SECRET krävs för att bekräfta betalningar (den signerade webhooken är sanningskällan). Utan |
| `STRIPE_WEBHOOK_SECRET` | — |
| `STRIPE_API_BASE` | STRIPE_API_BASE pekas bara om i integrationstester (lokal emulator). |
| `PAYMENTS_MOCK_ENABLED` | Utveckling/test + Vercel PREVIEW (VERCEL_ENV=preview). Ignoreras alltid i skarp produktion — sätt den ENDAST i Preview-miljön på Vercel. |

### Språkförslag (generation mode)

| Variabel | Beskrivning |
|---|---|
| `ANTHROPIC_API_KEY` | Aktiveras av ANTHROPIC_API_KEY (modell claude-opus-5 via officiella SDK:n). Utan nyckel svarar förslagsytan ärligt 503. Varje förslag passerar de deterministiska vakterna i @bidrag/core och sparas aldrig automatiskt — sö |
| `GENERATION_MOCK_ENABLED` | Endast utveckling/test — ignoreras alltid i produktion. |

### Valfritt

| Variabel | Beskrivning |
|---|---|
| `CLAMAV_ADDRESS` | — |

### Sessioner & uppladdningar (valfria — rimliga standardvärden i koden)

| Variabel | Beskrivning |
|---|---|

## 9. Kommandon

| Kommando | Gör |
|---|---|
| `npm run build` | Bygger core → api → web (i den ordningen; api/web kräver cores dist). |
| `npm run test` | Alla tester: core (enhetstester) + api (integration mot TEST_DATABASE_URL). |
| `npm run typecheck` | tsc --noEmit i alla tre paketen — kräver att core är byggt. |
| `npm run lint` | Samma som typecheck (ingen separat linter är konfigurerad). |
| `npm run dev:api` | API:t i utvecklingsläge (läser .env i roten; sätt PORT=3100). |
| `npm run dev:web` | Vite-devservern på :5173, proxar /v1 till API_URL (default :3100). |
| `npm run db:migrate` | Applicerar migreringarna i apps/api/drizzle/ (idempotent). |
| `npm run db:seed` | Seedar kunskapsbasen (72 stöd; idempotent, append-only regelversioner). |
| `npm run demo:build` | Bygger den fristående demon → artifacts/demo/demo.html (ingen databas). |
| `npm run demo:check` | Demons 7 webbläsarkontroller (kräver Chromium + byggd demo). |
| `npm run verify:sim30` | 30 simulerade användare genom hela flödet — kräver körande API (:3100, mock på). |
| `npm run verify:ui` | 13 UI-genomklickningar — kräver körande API + dev:web + Chromium. |
| `npm run verify:schemas` | Ansökningsschemanas täckning mot stöden — kräver körande API. |
| `npm run verify:relevans` | Relevansrevisionen: 10 personor mot alla stöd — inga sektorsgrindade stöd utanför personens situation, inga överexkluderingar (F-RELEVANS). Ingen server krävs. |
| `npm run verify:smoke` | Prismodellens kedja (402 → 19 kr → ansökan) — kräver körande API. |
| `npm run verify` | HELA hälsokontrollen (scripts/verify.sh): bygge, typer, tester, databas från tom, produktionsbygge, deploy-konfig, hemligheter, handbokens aktualitet. |
| `npm run manual` | Regenererar denna handbok ur källorna (tools/genmanual.mjs). |
| `npm run seo:keywords` | Bygger master keyword-databasen seo/keywords.json ur seeden + seo/roots-manual.json (aldrig påhittade volymer — se docs/SEO_STRATEGY.md). |
| `npm run seo:build` | Genererar den publika, indexerbara ytan (/bidrag/… + sitemap + robots) ur kunskapsbasen — samma sanningsmodell som produkten. |
| `npm run seo:check` | SEO-QA-crawlen: titlar, canonical, JSON-LD, intern länkgraf, orphans och sitemap-täckning för den genererade ytan. |
| `npm run demand:model` | Lanseringsscenariomodellen (docs/LAUNCH_DEMAND_INTELLIGENCE.md): fördelar scenariotrafik (INPUT, aldrig prognos) över klustren, räknar tratt, myndighetsbelastning och teknisk last → artifacts/demand-model.json. |
| `npm run gate:0` | Zero-Compromise Gate, deterministiska blocken (docs/ZERO_COMPROMISE_GATE.md): teknisk totalcrawl, bildinventering, intern länkgraf/PageRank, innehållsmatris → artifacts/gate0-report.json. Failar på CRITICAL/HIGH. |
| `npm run gate:ux` | Gatens UX-block: alla publika sidor i 320 px + 1280 px — overflow, H1, tomma ankare, återvändsgränder + bevis-skärmdumpar. Kräver byggd yta + Chromium. |
| `npm run gate:keywords` | Gatens block A: statusregistret seo/gate0-keywords.json (GREEN/YELLOW/RED/GREY per keyword-rot mot SERP-observationerna). |
| `npm run gate:links` | Extern länkhälsa för myndighetslänkarna på publika ytan — körs från nätansluten maskin (t.ex. efter deploy); sandlådan saknar utgående nät. |

## 10. Drift, deploy och gränser

- Deploy: `docs/DEPLOY-AGENT.md` (agentdriven) / `docs/DEPLOY-NU.md` (manuell);
  helhet `docs/DEPLOYMENT.md`; drift `docs/OPERATIONS.md`.
- Fjärr-röktest av deployad miljö: `BASE_URL=https://… node tools/deploy-smoke.mjs`
  (+ `CRON_SECRET` för readiness). I preview körs hela köpkedjan med mock;
  i produktion utan Swish verifieras att köpen vägrar ärligt (503).
- Mock kan aldrig aktiveras i skarp produktion (`NODE_ENV=production` utan
  `VERCEL_ENV=preview`) — vakten ligger i `apps/api/src/config.ts` och
  regressionstestas i `apps/api/test/previewMockGate.test.ts`.
- Ärliga begränsningar: `docs/LIMITATIONS.md`. Säkerhet: `docs/SECURITY.md`.
  GDPR: `docs/PRIVACY.md`. Aktivering av Swish/Resend/Anthropic:
  `docs/ACTIVATION.md`.

## 11. Så hålls handboken aktuell (reaktiviteten)

Handboken är en byggprodukt, inte ett dokument som kan glömmas: den
genereras ur routetabellen, cores exporter, seeden, `.env.example` och
`package.json`. `npm run verify` regenererar den och fallerar om (a) den
committade filen skiljer sig från källorna, eller (b) en ny API-operation
eller ett nytt kommando saknar instruktion. En ny funktion kan alltså inte
nå `main` utan sin rad i handboken.
