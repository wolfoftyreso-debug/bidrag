# Aktiveringsrunbook — från byggt till påslaget

Systemet är byggt så att varje extern tjänst aktiveras med **enbart
konfiguration** — ingen kodändring, ingen deploy av ny funktionalitet.
Tills en tjänst är aktiverad vägrar motsvarande yta ärligt (503/avstängd),
den låtsas aldrig. Detta dokument är checklistan för att slå på allt.

**Verifiering efter varje steg:** anropa beredskapsendpointen.

```sh
# Konfigurationsstatus (inga externa anrop)
curl -s https://<api-host>/v1/internal/readiness \
  -H "Authorization: Bearer $CRON_SECRET" | jq

# Med levande prober mot Resend och Anthropic (ofarliga läsanrop)
curl -s "https://<api-host>/v1/internal/readiness?probe=true" \
  -H "Authorization: Bearer $CRON_SECRET" | jq
```

Svaret listar `checks` per integration och `blockers` — målet är `ok: true`
med tom blockerarlista. Endpointen kräver `CRON_SECRET` (utan den är hela
ytan 404).

---

## 0. Grundkrav (gäller alla miljöer)

| Variabel | Krav |
|---|---|
| `DATABASE_URL` | Postgres-anslutning (Supabase i produktion, se §1) |
| `AUTH_SECRET` | ≥ 32 slumpade tecken, unik per miljö |
| `FIELD_ENCRYPTION_KEY` | 64 hex-tecken (32 byte), unik per miljö — roteras aldrig utan migreringsplan |
| `CRON_SECRET` | Slumpad hemlighet; krävs för cron-jobben och readiness-endpointen |
| `PUBLIC_BASE_URL` | Publika webbadressen (används i återställningslänkar m.m.) |

Generera hemligheter: `openssl rand -hex 32`.

## 1. Supabase (databas)

1. Skapa projekt på supabase.com (region EU).
2. Hämta anslutningssträngen (Session pooler för serverless) → `DATABASE_URL`.
3. Kör migrationerna och seeda kunskapsbasen:
   ```sh
   cd apps/api
   DATABASE_URL=... npx drizzle-kit migrate
   DATABASE_URL=... node --experimental-strip-types src/seed/run.ts
   ```
   Seeden är idempotent och versionerar regeländringar append-only — säker
   att köra om.
4. Verifiera: readiness → `checks.database.status: "ready"`.

Detaljer: `docs/DEPLOYMENT.md`.

## 2. Vercel (drift)

1. Importera repot i Vercel; sätt alla miljövariabler från §0 + §3–5.
2. Cron-jobb: konfigurera enligt `vercel.json` — Vercel skickar
   `Authorization: Bearer $CRON_SECRET` automatiskt när variabeln finns.
   Jobben (`source-fetch`, `deadline-scan`, `stale-match-recalc`,
   `curator-reminders`, `retention`) är idempotenta.
3. Verifiera: `curl -s https://<host>/healthz` → `{"ok":true}`, därefter
   readiness enligt ovan.

## 3. Swish Handel (betalningar, 39 kr på riktigt)

Extern förutsättning: **handelsavtal med banken + Swish-certifikat**
(utfärdas via Swish Certificate Management). Detta är det enda steget som
kräver en process utanför konfiguration.

1. Teckna Swish Handel-avtal hos bolagets bank (Landvex AB).
2. Skapa klientcertifikat i Swish Certificate Management; exportera
   certifikat + privat nyckel som PEM.
3. Sätt miljövariabler (PEM base64-kodas eftersom serverless saknar
   filsystem):
   ```sh
   SWISH_MERCHANT_ALIAS=123XXXXXXX
   SWISH_CERT_BASE64=$(base64 -w0 swish-cert.pem)
   SWISH_KEY_BASE64=$(base64 -w0 swish-key.pem)
   SWISH_KEY_PASSPHRASE=...   # om nyckeln är lösenordsskyddad
   ```
   Lämna `SWISH_API_BASE`/`SWISH_QR_BASE` osatta i produktion
   (standard är Swish riktiga endpoints); peka mot MSS-simulatorn
   (`https://mss.cpc.getswish.net`) i preview för slutrepetition.
4. Kontrollera att `PAYMENTS_MOCK_ENABLED` **inte** är satt i produktion —
   mocken vägrar ändå starta där, men variabeln ska bort.
5. Verifiera: readiness → `checks.payments_swish.status: "ready"`, gör
   därefter en riktig 39 kr-betalning end-to-end och kontrollera kvittot
   under Mina köp (momsspecifikation, kvittonummer).

## 4. Resend (e-post: återställningslänkar + kvittoutskick)

1. Skapa konto på resend.com; lägg till avsändardomänen och sätt
   DNS-posterna (SPF/DKIM) tills domänen är **Verified**.
2. Skapa API-nyckel → miljövariabler:
   ```sh
   RESEND_API_KEY=re_...
   EMAIL_FROM=no-reply@<verifierad-domän>
   ```
3. Verifiera: readiness med `?probe=true` →
   `checks.email_resend.status: "ready"` (proben gör `GET /domains` mot
   Resend med nyckeln). Testa därefter "Skicka kvittot via e-post" i Mina
   köp och en lösenordsåterställning.

Utan kanal: kvitton finns ändå i kontot (läs + PDF), länk-återställningen
är fail-closed (503) och återställningskoderna är reservvägen. Se
`docs/LIMITATIONS.md` §4.

## 5. Anthropic (språkförslag — generation mode)

1. Skapa API-nyckel på platform.claude.com → `ANTHROPIC_API_KEY=sk-ant-...`.
2. Modellen är `claude-opus-5` via officiella `@anthropic-ai/sdk` med
   strukturerad utdata (JSON-schema) och refusal-hantering. Prisbild:
   5 USD/M inmatningstokens, 25 USD/M utmatningstokens; ett förslag är
   typiskt några hundra tokens.
3. Kontrollera att `GENERATION_MOCK_ENABLED` inte är satt i produktion.
4. Verifiera: readiness med `?probe=true` →
   `checks.generation_anthropic.status: "ready"` (proben hämtar
   modellmetadata, kostar inget). Testa därefter "Föreslå språklig
   förbättring" på ett ansökningsfält och kontrollera att
   BEFORE/REASON/AFTER hamnar i revisionsloggen.

Garantierna ligger i arkitekturen, inte i modellen: varje förslag passerar
de deterministiska vakterna (uppfunna siffror, meta-spår, språkrisk,
längdsvall), ett avvisat förslag når aldrig användaren, och systemet
skriver aldrig i sökandens svar — sökanden godkänner själv.

## 6. Slutkontroll

```sh
curl -s "https://<host>/v1/internal/readiness?probe=true" \
  -H "Authorization: Bearer $CRON_SECRET" | jq '{ok, blockers}'
```

Förväntat i fullt aktiverad produktion:

```json
{ "ok": true, "blockers": [] }
```

Därefter: en riktig betalning, ett riktigt kvittomejl, en riktig
lösenordsåterställning och ett riktigt språkförslag — fyra manuella
stickprov som tillsammans täcker alla externa integrationer.

## Icke-tekniska lanseringsvillkor (motförhöret 2026-08-18)

Dessa syns inte i readiness-proben men är lika hårda:

1. **DPIA** — obligatorisk (art. 9-hälsodata behandlas). Underlag: PRIVACY.md.
2. **Juristgranskning** av köpvillkoren (`/villkor`), samtyckestexterna och
   kvittots ångerrättsrad.
3. **Mänsklig granskning av kunskapsbasen** — alla 72 stöd mot levande källor;
   kuratorsflödet i admin flyttar dem från `ai_curated` till `human_verified`.
4. **Supportkanal** för reklamationer/återbetalningar (t.ex. brevlåda på
   den verifierade domänen) — återbetalningar hanteras manuellt.
