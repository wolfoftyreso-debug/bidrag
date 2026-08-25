# OPEN RISKS — Master Control Prompt

Öppna risker och blockerare, kontinuerligt uppdaterade. Detaljerad numrerad
teknisk lista finns i `docs/LIMITATIONS.md`; detta dokument är styr-vyn för
masterprompt-uppdraget. Inget döljs.

Skala: BLOCKER (extern, hindrar produktion) · HIGH · MEDIUM · LOW.

---

## Externa blockerare (BLOCKER — kräver avtal/nyckel/manuellt steg)

| Id | Risk | Var det löses | Kan resten verifieras utan? |
|---|---|---|---|
| X1 | Swish Handel-avtal + klientcertifikat saknas | `.env` `SWISH_*` (base64) · `docs/ACTIVATION.md` | Ja — mock i preview, ärlig 503 i prod |
| X2 | Search Console ej ansluten | GSC-verifiering efter deploy | Nej — kräver deployad domän |
| X3 | Supabase-produktionsprojekt ej rest | `.env` Supabase-trio · `deploy/bootstrap.sql` | Delvis — lokal roundtrip i verify |
| X4 | Resend API-nyckel (e-post) | `.env` `RESEND_API_KEY` | Ja — ärlig 503 utan |
| X5 | ANTHROPIC_API_KEY (fritext/språkförslag) | `.env` `ANTHROPIC_API_KEY` | Ja — ärlig 503 + val-baserat fallback |

## Produktluckor (från FAS 0)

| Id | Risk | Prio | Fas |
|---|---|---|---|
| R1 | Fritext-discovery (narrativ → faktaextraktion m. bekräftelse) ej primär | P1 | FAS 1/3 |
| R2 | Explicit sökandekontext-ingång ("Vem söker du för?") saknas som steg 0 | P1 | FAS 1 |
| R3 | Enskild firma-dubbelkontext modellerad men viks in i projektgren i UI | P2 | FAS 1/6 |
| R4 | `/situationer/`-SEO-lagret ej byggt (ontologi klar) | P3 | FAS 8/9 |
| R5 | Namngivna docs saknas (DATA_MODEL, MATCHING_ENGINE, PAYMENTS_AND_ENTITLEMENTS) | LOW | löpande |

## Kända tekniska residualer (från LIMITATIONS.md)

| Id | Risk | Prio |
|---|---|---|
| T1 | Delad rate-limit-store saknas i serverless (per-instans-räknare) — LIMITATIONS §12 | MEDIUM |
| T2 | SSRF DNS-rebinding-residual — LIMITATIONS §13 (låg exponering, data_curator-gated) | LOW |
| T3 | Fyra måttliga dev-beroendesårbarheter i drizzle-kits kedja — LIMITATIONS §11 | LOW (medvetet accepterat) |
| T4 | Innehållet AI-kurerat i väntan på mänsklig granskning (`ai_curated`-stämpel) | MEDIUM (ärligt exponerat) |
| T5 | DPIA/juristgranskning återstår | MEDIUM (dokumenterat) |

## Konkurrens (icke-teknisk)

| Id | Risk | Prio |
|---|---|---|
| C1 | Grantigos contentmotor är situationsdriven och bred (SEO_COMPETITORS §D3c) | MEDIUM — mötas med situations-SEO efter GATE 0 |
| C2 | Offsite/social fryst tills GATE 0 grön — begränsar motdrag på kort sikt | accepterat (ZERO_COMPROMISE_GATE) |
