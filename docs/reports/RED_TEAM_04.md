# RED TEAM-PASS 04 — bedrägeri & hackerattacker (2026-08-23)

Direktiv: "alla typer av försök till bedrägeri, alla typer av hackerattack …
måste testas hela tiden." Detta pass gör två saker: (1) ett djupt live-/
statiskt angreppspass mot pengaflödena och injektions-/auth-ytorna, och (2)
gjuter attackerna i en **stående adversariell svit** (`apps/api/test/
adversarial.test.ts`) som körs vid VARJE commit (npm test → verify → CI) —
en regression som öppnar en väg fäller bygget.

Två fokuserade angripare + en samtidighets-reproduktion i testharnessen.
**8 fynd: 1 HIGH, 3 MEDIUM, 4 LOW/INFO. Alla åtgärdade eller ärligt
dokumenterade + backloggade.**

## Bedrägeri (pengaflödet)

| Id | Grad | Fynd | Åtgärd |
|---|---|---|---|
| A1 | **HIGH** | **TOCTOU-race i kreditförbrukningen.** Krediten härleddes `remaining = sum(betalda credits) − count(ansökningar)` med kontroll och skapande i två separata statements utan atomicitet. 12 parallella `POST /v1/applications` läste alla `remaining=1` → **7 ansökningar på ETT 19-kr-köp**. Kärnan i "19 kr per ansökan" kringgicks proportionellt mot parallellism. | **FIXAD**: kontroll-och-förbrukning serialiseras nu per (tenant, projekt) med ett **icke-blockerande** `pg_try_advisory_xact_lock` + bounded retry i en transaktion (släpper pool-connectionen mellan försök — ingen pool-svält). Bevisat: 12 parallella → exakt 1 skapad, 11 × 402. Permanent samtidighetstest i sviten. |
| A2 | MEDIUM | Samma race i dokumentgenereringen (`generated-documents`) — kontroll-sedan-insert utan atomicitet. | **FIXAD**: identiskt icke-blockerande lås + re-kontroll + insert i samma transaktion. |

**Pengaflödet i övrigt: verifierat härdat** (kodläst, dokumenterat i sviten):
belopp och momssats server-side ur config (aldrig ur request-body;
`additionalProperties:false`), bekräftelsekedjan idempotent (`state='pending'`-
villkor + unikt kvitto per `paymentId`), mock strukturellt avstängd i skarp
produktion, Swish-callback verifieras server-till-server över mTLS med
beloppskontroll före upplåsning, kvitton tenant-scopade och oförfalskbara,
ingen delete-and-recreate-väg, consent-grinden litar inte blint på klienten.

## Hackerattacker (injection, auth, transport)

| Id | Grad | Fynd | Åtgärd |
|---|---|---|---|
| B1 | MEDIUM | **SSRF via redirect-följning + DNS-rebinding.** `assertSafeUrl` validerade bara initial-URL:en; `fetch(redirect:'follow')` följde 3xx till godtycklig adress utan omvalidering → en källa kunde 302:a till 169.254.169.254/127.0.0.1 och läcka interna adresser. | **FIXAD**: redirects följs manuellt och **varje hop revalideras** mot privata-adress-blocklistan (bounded till 5 hop). DNS-rebinding-residualen dokumenterad (LIMITATIONS §14, backlog M14) — låg exponering (källregistrering kräver icke-självbetjänings-rollen data_curator). |
| B2 | MEDIUM | **Rate-limiting per instans.** In-memory-store → i Vercels serverless-modell delas inte per-IP-räknarna mellan instanser; effektiv gräns skalar med instansantal. SECURITY.md påstod skydd utan förbehåll. | **DOKUMENTERAD ÄRLIGT** (LIMITATIONS §13, SECURITY.md rättad) + **backlog M13** (delad store: Vercel KV/Upstash). Påverkar inte engångskoderna (~73 bitar) eller någon pengainvariant. |
| B3 | LOW | JSON-LD-injektion i statisk SEO-generering: `JSON.stringify` escapar inte `</script>`, så en stödtitel med den strängen kunde bryta ut ur script-taggen (lagrad XSS på de 77 sidorna). | **FIXAD**: `<`/`>` escapas till `<`/`>` i JSON-LD-emissionen. (Data är kuratorstyrt, ej slutanvändare — defense-in-depth.) |
| B4 | LOW | Kapplöpning vid inbjudningsaccept → dubbel medlemskapsrad (rollen tas från inbjudan, så ingen privilegie-eskalering — bara en dublett). | **FIXAD**: accepteringen är nu atomisk — villkorad `UPDATE acceptedAt WHERE acceptedAt IS NULL RETURNING`; bara vinnaren skapar medlemskapet, förloraren får 410. |
| B5 | INFO | JWT-verifiering saknade explicit `algorithms`-allowlist (ej exploaterbart med symmetrisk nyckel, men defense-in-depth). | **FIXAD**: `jwtVerify(..., { algorithms: ['HS256'] })`. |

**Verifierat härdat** (statiskt, mot alla prövade angrepp): tenant-isolation/
IDOR genomgående (X-Tenant-Id kan bara välja egna medlemskap; 404 läcker inte
existens), mass-assignment omöjlig (alla body-scheman stängda; tenantId/role/
id sätts server-side), privilegie-eskalering till global kurator stängd
(RT03-S1), ingen SQL-injektion (Drizzle-parametrar genomgående), ingen path
traversal (opaka lagringsvägar), scrypt+timingSafeEqual, atomiska engångs-
token, CSRF-origin-guard + Helmet-CSP, felhanteraren läcker inga internal.

## Den stående sviten (permanensen)

`apps/api/test/adversarial.test.ts` — 13 tester som kodifierar varje angrepp
som en invariant: pris/beloppsintegritet, consent-grind server-side, gratisväg-
bypass (402/404), replay/dubbelbekräftelse, **samtidighets-racet (A1)**, cross-
tenant på betalningar, mass-assignment, rolleskalering, mock-gate. Körs i
`npm test` → `npm run verify` → CI. En regression som återöppnar någon väg
fäller bygget. Kompletterar `tenantIsolation.test.ts` och `hardening.test.ts`
(CSRF, rate limit, felläckage) samt `previewMockGate.test.ts`.

## Recrawl (tester)

- `apps/api`: **211 tester** gröna (198 → +13 adversariella), full svit 43s
  (ingen pool-svält efter det icke-blockerande låset).
- `packages/core`: 100 gröna. `npm run verify`: grönt.

Nästa pass börjar med att verifiera A1/A2/B1–B5 som faktiskt åtgärdade, och
kör den stående sviten som baslinje.
