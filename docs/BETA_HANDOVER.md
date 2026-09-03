# Beta-överlämning — det som bara operatören kan göra (2026-09-03)

Allt som gick att bygga utan konton, DNS och nycklar är byggt och verifierat
(se `docs/reports/BETA_READINESS_2026-09-03.md` för hela bilden). Det här
dokumentet är den exakta listan över återstående handgrepp, i den ordning de
måste göras, med värdena färdiga att klistra in. Varje steg har ett
kontrollkommando så att det går att bevisa att det lyckades.

## 0. Två saker att bestämma innan något annat

| Fråga | Varför den måste avgöras nu |
|---|---|
| **Vilket bolag säljer?** Kvitton och köpvillkor säger Landvex AB (559141-7042). Stripe-kontot i sessionen heter "Sommarliden Holding" (live). Betalningsmottagare och säljare på kvittot måste vara samma juridiska person. | Bokföring och konsumentköplag. Antingen ett Stripe-konto för Landvex AB, eller ändra `SELLER_*`-variablerna till Sommarliden Holding (då även villkoren och kvittotexterna). |
| **Vilken e-postdomän?** Resend-kontot har nått planens domängräns (12 domäner, 6 med status "failed"). `bidragskoll.se` gick inte att lägga till. | Utan verifierad domän går inga kvittomejl eller återställningslänkar (ärligt 503, men två flöden i betan saknas). Ta bort en fallerad domän (t.ex. `vyra.gg`, `corpfitt.com`, `apifly.com`, `hypebit.com`) eller uppgradera planen, sedan `create-domain bidragskoll.se` i eu-west-1 och lägg DNS-posterna. |

## 1. Deploy (30–60 min) — `docs/DEPLOY-AGENT.md` steg 1–4

1. Vercel → projekt `bidragskoll` → Storage → skapa Neon Postgres (EU-region).
2. Kopiera `DATABASE_URL` (pooled) och `DIRECT_DATABASE_URL`.
3. Ladda `deploy/bootstrap.sql` mot DIRECT-adressen (psql) — **som samma roll
   som körtiden använder** (RLS-fällan, DEPLOY-AGENT §"RLS-fällan").
4. Env-blocket (Production + Preview), hemligheterna är redan genererade i
   chatten 2026-09-01:

```
DATABASE_URL=<pooled>
DIRECT_DATABASE_URL=<direct>
PG_POOL_MAX=2
AUTH_SECRET=<ur chatten>
FIELD_ENCRYPTION_KEY=<ur chatten>
CRON_SECRET=<ur chatten>
STORAGE_DRIVER=postgres
PUBLIC_BASE_URL=https://bidragskoll.se
CORS_ORIGIN=https://bidragskoll.se
BETA_MODE=true
BETA_INVITE_CODES=<3–5 koder, kommaseparerade, t.ex. genererade med openssl rand -hex 6>
ALERT_EMAIL=<din adress>
# Preview only:
PAYMENTS_MOCK_ENABLED=true
```

5. Redeploy. Kontroll:

```sh
BASE_URL=https://bidragskoll.vercel.app CRON_SECRET=… node tools/deploy-smoke.mjs
curl -s -H "Authorization: Bearer $CRON_SECRET" "$BASE_URL/v1/internal/readiness?probe=true" | jq '{ok, blockers}'
curl -s "$BASE_URL/v1/auth/register-policy"      # {"inviteRequired":true,"beta":true}
curl -s -H "Authorization: Bearer $CRON_SECRET" "$BASE_URL/v1/internal/cron/watchdog" | jq   # {"ok":true,"alarms":[]}
```

## 2. Domänen (30 min + DNS)

`bidragskoll.se` pekar i dag på parkering (194.9.94.85/.86). Vercel → Domains →
lägg till `bidragskoll.se` + `www`, följ DNS-anvisningen (A/CNAME). När den
är grön: sätt `PUBLIC_BASE_URL`/`CORS_ORIGIN` till `https://bidragskoll.se`
(redan i blocket ovan) och redeploya. Kontroll: `curl -I https://bidragskoll.se/readyz`.

## 3. Stripe live (1 h)

Efter beslut i §0:

1. Stripe Dashboard (live) → Developers → API keys → `STRIPE_SECRET_KEY`.
2. Webhooks → Add endpoint `https://bidragskoll.se/v1/payments/stripe/webhook`,
   händelse `checkout.session.completed` → `STRIPE_WEBHOOK_SECRET`.
3. Lägg båda i Vercel env (Production), redeploy.
4. Gör ett riktigt köp för 19 kr med eget konto. Kontroll: kvittot syns under
   Konto & data → Mina köp, `receipts`-raden finns, vakthunden larmar inte.
   Återbetala testköpet i Stripe och sätt `refundStatus` på kvittot.

## 4. Resend (1 h)

Efter beslut i §0: `create-domain bidragskoll.se` (region eu-west-1) →
lägg SPF/DKIM/Return-Path-posterna i DNS → `verify-domain` → `RESEND_API_KEY`
i Vercel env, `EMAIL_FROM=no-reply@bidragskoll.se`. Kontroll: readiness-proben
visar e-post `ready`; begär en lösenordsåterställning och ta emot mejlet.

## 5. Supportkanal (1 h)

Brevlåda `support@bidragskoll.se` (Resend receiving eller vanlig e-post).
Skriv in adressen på `/villkor` (§Återbetalning och reklamation) — texten
säger i dag "kontakta oss" utan adress. Återbetalningar: manuellt i Stripe +
`refundStatus` på kvittot (LIMITATIONS §12).

## 6. DPIA och jurist (parallellt, 2–5 dagar)

- `docs/DPIA.md` är ett utkast med alla **[ANSVARIG]**-fält markerade. Fyll
  i, värdera riskerna i §7, underteckna §9. Behandlingen av hälsouppgifter får
  inte börja innan dess — betainbjudningarna väntar på detta.
- Jurist: `/villkor` (`apps/web/src/pages/Terms.tsx`), samtyckestexten
  (`apps/web/src/components/PurchaseConsent.tsx`), kvittots ångerrättsrad
  (`apps/api/src/services/receipts.ts`).

## 7. Kuratorsminimum (2–3 dagar) — `docs/reports/KURATORSMINIMUM_2026-09-03.md`

Listan över de 25 mest synliga stöden och de 20 med startsida som källa,
med den specifika källsidan för var och en där den hittades i dag. Görs i
admin-kuratorsflödet (`/admin`), som lyfter stödet till `human_verified`.

## 8. Bjud in (dag 5–6)

När §1–§6 är gröna: skapa inbjudningskoderna, skicka till de första tio,
följ `GET /v1/internal/metrics/product?days=7` och feedbacklådan i `/admin`
dagligen. Exitkriterierna står i BETA_READINESS §Exitkriterier.
