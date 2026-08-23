# Limitations register

Guard-mode rule (§71): never conceal a limitation. This is the honest,
current list — each entry states the blocker, what was done instead, and the
next integration boundary. The product UI reflects every one of these
truthfully (no fake coverage, §54).

## 1. No native/structured submission adapters yet

**Blocker**: none of the wave-1 authorities (Kulturrådet, Tillväxtverkets
"Min ansökan", Energimyndighetens "Mina sidor", Jordbruksverkets SAM,
MUCF, Vinnovas intressentportal) exposes a supported public API for
third-party application submission; the EU Funding & Tenders / Erasmus+
systems require organisation-level EU Login sessions. Automating their web
UIs without agreement would violate §16's "only when technically and
contractually permitted".

**Fallback implemented**: first-class assisted submission — full validated
package, deterministic payload hash, the official URL, and a user-confirmed
receipt before any case reads "Inlämnad". The UI says exactly this.

**Next boundary**: `services/submission.ts` `registerAdapter()` — a signed
agreement + API access with any authority plugs in without changing the
application flow.

## 2. Source parsing is structured extraction + human curation, not rule auto-publishing

**Blocker**: wave-1 sources publish HTML/PDF without machine-readable rule
data; unattended *publishing* of extracted eligibility rules is not safe
(§24) and remains deliberately out of scope.

**Implemented**: the ingestion pipeline fetches with SSRF guards, snapshots
with hashes, and now runs a deterministic Swedish extraction layer
(`services/parsers/`, version `generic-sv@1`): dates (written and ISO forms,
with deadline-context detection), amounts (incl. millions), links, and
deadline phrases — each extraction carrying its exact text evidence.
Snapshot-to-snapshot diffs produce plain-Swedish summaries ("Nya länkar:
'Residensbidrag för dansare' · Datum som försvunnit: 2026-09-24") and
material flags against the published opportunities linked to the source —
a vanished date that is a published deadline is a warning in the review
queue. Everything still goes through human review before any rule changes;
nothing auto-publishes. Fixture-tested end to end without network.

**Next boundary**: source-specific parsers (registered on
`sources.parserVersion`) that map listing items to opportunity slugs and
propose draft rule-version diffs for one-click curator approval; PDF text
extraction for document-based sources.

## 3. Digital post / mailbox integrations not connected

**Blocker**: Digg's digital-post infrastructure serves public actors and
accredited mailbox operators; Bidragskoll.se holds neither role today.

**Fallback implemented**: the unified inbox accepts uploads, forwarded text
and manual entries, classifies message types deterministically (Swedish
decision vocabulary) and auto-matches to cases via submission references —
with human override. The architecture normalises everything to
`correspondence_events`, so a mailbox connector is additive.

## 4. Email — Resend is the coupled channel (product decision 2026-08-17)

Per product decision: Resend is the production email channel
(`RESEND_API_KEY` + `EMAIL_FROM` with a verified sender domain; `SMTP_URL`
remains as an alternative for self-hosted operation). The channel is used
for password-reset links and for sending receipts ("Skicka kvittot via
e-post" in Mina köp). The system still degrades honestly without a key:
receipts remain first-class in the authenticated account
(`GET /v1/purchases`, `GET /v1/payments/:id/receipt`, downloadable as PDF
via `GET /v1/payments/:id/receipt.pdf`), notifications live in the in-app
inbox, team invites produce shareable links, and every unsent email is
recorded as `skipped` — no flow silently pretends to have sent anything.

**Password recovery — email link is the primary path.** The link flow
(`POST /v1/auth/request-password-reset` → one-time token, 60 min TTL,
hashed at rest, atomic single-use claim, all sessions revoked, constant
response with no account enumeration) requires the email channel and fails
closed (503) without one. One-time recovery codes remain as the
channel-less fallback: eight codes generated under Konto & data (shown
exactly once, stored only as SHA-256 hashes, ~73 bits of entropy each),
redeemed via `POST /v1/auth/recover-with-code` with the same guarantees.
A user who forgets their password, has no saved codes *and* no reachable
email still needs support — that residual case is inherent to not holding
any other out-of-band identity (no phone, no BankID).

External blocker for production: the operator's Resend account with a
verified sender domain.

## 5. Malware scanning optional

ClamAV scanning activates when `CLAMAV_ADDRESS` is set (INSTREAM protocol
implemented). Without it, uploads are marked `scan_unavailable` — visible in
the vault, and magic-byte/content-type checks still apply. In the container
path, deploy the ClamAV daemon alongside the API; the Vercel path has no
ClamAV equivalent — uploads there are honestly marked `scan_unavailable`
(open item).

## 6. Object storage: Supabase Storage in the primary path

Resolved for the Vercel + Supabase path: documents live in a private
Supabase Storage bucket (`STORAGE_DRIVER=supabase`, `services/storage.ts` is
the driver boundary). In the container path documents live on a volume
(`UPLOAD_DIR`); move to S3-compatible storage if that path ever needs
multi-node.

## 7. GDPR self-service — closed (operator's DPIA remains)

Export and erasure are full self-service: the "Konto & data" page offers the
JSON download and the typed-confirmation erasure flow, backed by the tested
endpoints (file deletion + database cascade + tenant-less audit proof). A
daily retention job purges expired/revoked refresh tokens, old read
notifications and excess source snapshots (conservative policy in
`services/retention.ts`; applicant content is never auto-purged). Remaining
before public launch: the operator's DPIA (organisational step, see
PRIVACY.md).

## 8. Coverage is wave-1 (expanded)

72 curated opportunities across 35 financiers — state agencies, foundations,
the sports federation, EU programmes, and personal entitlements
(Försäkringskassan, CSN, Pensionsmyndigheten, municipal social services) —
exercise the data patterns: recurring and rolling deadlines, upcoming rounds,
OID/Quality Label requirements, applicant-type gates, co-financing shares,
prefinancing requirements, and household/income-based benefit conditions.
Personal benefits carry instrument types `social_benefit`/
`educational_support` and are always presented separately from grants, in
rights-assessment language ("ser ut att kunna ha rätt till"), never as
decisions. This
proves the engine — it is not national coverage. Scaling to hundreds of
opportunities is data work on the existing model plus curator throughput
(the curator console now shows affected opportunities per source change and
offers one-click re-verification). No schema changes required.

## 9. Observability — partially closed

Structured logs, probes, admin health views and a Prometheus `/metrics`
endpoint (HTTP, process, pool and domain gauges) now exist, with recommended
alert rules in OPERATIONS.md. Remaining: dashboards and alert wiring in the
cluster's monitoring stack, plus a rehearsed on-call path.

## 10. Payments — generic layer built, Swish awaits merchant agreement

The commercial model is a one-time 39 kr unlock of the personal analysis
(`ANALYSIS_PRICE_MINOR`, default 3900 öre) plus 19 kr per application
prepared in the system (`APPLICATION_PRICE_MINOR`, default 1900 öre — all
documents for that application included) — never a subscription, and never
"buying a grant". The generic layer (payment → confirmation → unlock) is
implemented and tested end to end: a `payments` table with per-project state,
a provider registry, teaser gating of match results (counts and categories
visible, names/sources/questions withheld until a confirmed payment), 402 on
the funding stack, idempotent re-purchase protection, and an unauthenticated
webhook surface for server-to-server callbacks.

The purchase pipeline is provider-independent: the confirmed payment is the
authoritative event, and the chain is always *payment confirmed → transaction
recorded → receipt issued → unlock* (never "user clicked pay → unlock").
Receipts are real verification records issued in the same database
transaction as the confirmation (duplicate callbacks can never produce two):
sequential receipt numbers from a dedicated sequence (`BS-YYYY-NNNNNN`),
gross/net/VAT amounts frozen in öre, VAT rate, payment method, product,
purchase ID, refund status and seller details. Receipts are first-class in
the authenticated account ("Mina köp"): listed, viewable and permanently
accessible without any email involved — email delivery is an optional
best-effort extra (see §4). Receipts survive GDPR tenant erasure
(bookkeeping obligation, GDPR art. 17(3)(b)) with the email address scrubbed.

**Swish Handel is implemented** (Commerce API over mTLS, certificates as
base64 PEM in `SWISH_CERT_BASE64`/`SWISH_KEY_BASE64` — no filesystem
dependency): idempotent payment-request creation (PUT with an instruction id
derived from our payment id), QR served through the API, `swish://` deep
link, and a security model where the unsigned Swish callback is never
trusted — every confirmation is preceded by a server-to-server status fetch
over mTLS with amount/currency checks. Status polling verifies-on-read, so a
lost callback can never strand a paid customer. The whole chain is
integration-tested against a real local mTLS server (client-certificate
required), including a forged-callback attack test.

What is honestly missing: the merchant agreement and bank-issued
certificates, and a run of `scripts/swish-readiness.mjs` against MSS
(`SWISH_API_BASE=https://mss.cpc.getswish.net`) and then against production
with one real 39 kr payment. VAT is fixed at the Swedish standard rate of
25 % — both products (analysis unlock, document preparation) are
electronically supplied services to consumers in Sweden, which carry the
standard rate; the rate is deliberately not configurable so a bad
environment variable can never produce incorrect receipts. Seller identity
on receipts defaults to the real operating company — Landvex AB, org.nr
559141-7042, Antennvägen 2, 135 48 Tyresö, VAT no SE559141704201 — and can
be overridden via `SELLER_NAME`/`SELLER_ORG_NUMBER`/`SELLER_VAT_NUMBER`/
`SELLER_ADDRESS` if the company details ever change. The mock provider
used by tests and the demo is disabled in production by construction
(`PAYMENTS_MOCK_ENABLED` is ignored when `NODE_ENV=production`), with one
deliberate, verified exception: Vercel **preview** deployments
(`VERCEL_ENV=preview`) may enable it explicitly, so the full purchase flow
can be debugged in a deployed environment before the Swish agreement
exists. The production environment stays structurally locked, and the mock
is never selected when Swish is configured.

## 11. Dependency audit — clean in production, one upstream dev advisory left

`npm audit --omit=dev` reports **0 vulnerabilities**: nothing that ships to
production is affected, and that is the number that matters for the service.

The critical and high advisories that used to appear are closed. They came
from `vitest@2.1.9` and the `vite@5.4.21` it pulled in; the test framework
was upgraded to `vitest@4` (verified 2026-08-18), which resolves onto the
same `vite@6.4.3` the web app already builds with. Both suites — 90 core
unit tests and 198 API integration tests against real Postgres — pass
unchanged on the new major, because they use only `describe`/`it`/`expect`/
`beforeAll`/`afterAll` and no mocking API.

What remains is 4 moderate advisories with a single upstream root cause:
`drizzle-kit@0.31.10` (the latest release) still depends on the deprecated
`@esbuild-kit/esm-loader`, which pins `esbuild@0.18.20`. The advisory
(GHSA-67mh-4wv8-2f99) concerns esbuild's **development server** allowing
cross-origin requests; drizzle-kit uses esbuild only to transpile
`drizzle.config.ts` and never starts that server, and drizzle-kit itself is
a developer command (`npm run db:generate`) that is absent from every build
output and runtime image.

Two fixes were tried and deliberately rejected. `npm audit fix --force`
proposes `drizzle-kit@0.18.1` — a *downgrade* across many majors, which
would break migration generation. An npm `overrides` entry forcing
`esbuild@^0.25` does not reach the nested dependency, and forcing it would
run drizzle-kit's transpiler against an API seven minors newer than the one
it pins — risking the tool that produces our migrations, to silence an
advisory about a server we never start. The honest state is: wait for
drizzle-kit to drop `@esbuild-kit`, and re-check on each release.

## 12. Consumer law & content review (counter-audit 2026-08-18)

The adversarial counter-audit ("Motförhöret", docs/reports/motforhoret.html)
found three A-class gaps. What is now implemented in code, and what remains:

**A1 Withdrawal right (distansavtalslagen)** — implemented: every purchase
(analysis 39 kr, application 19 kr) requires an explicit
checkbox consenting to immediate delivery and acknowledging that the 14-day
withdrawal right thereby lapses. The server rejects purchases without it
(400 `consent_required`); the consent timestamp is stored on the payment,
frozen onto the receipt, and printed on the receipt document. A public
terms page (`/villkor`) carries the pre-purchase information and the refund/
complaint policy. **Remaining**: legal review of the texts by a lawyer, and
an automated refund flow (refunds are handled manually by the operator today;
`refundStatus` on receipts is the bookkeeping anchor).

**A2 Art. 9 health data** — implemented: explicit-consent framing on the
health question, a decline path that never re-asks and never counts as "no",
consent timestamp stored. See PRIVACY.md. **Remaining**: the operator's DPIA,
now understood as mandatory (Art. 9 at scale), is a launch condition.

**A3 Knowledge-base truth** — implemented: the seed stamps every opportunity
`ai_curated` ("AI-sammanställd från officiell källa — ej granskad av
människa") — the previous blanket `human_curated` stamp was untrue and has
been removed. The curator flow in admin is the only path to `human_curated`/
`human_verified`. The demo says the same thing. **Remaining**: a human must
actually review all 72 opportunities against live sources before launch;
until then every rule value (amounts, thresholds, dates) is AI-knowledge,
not verified fact.

Also from the counter-audit, still open: full WCAG review (targeted fixes
shipped: focus management in the one-question intake, progressbar semantics,
aria-live on payment status — the rest of the app is unreviewed); external
user testing beyond one session; commercial validation with real customers.

## 12. Rate limiting is per-instance in the serverless model (red team RT03)

The API's rate limits (10/min register/login, 5/min password-reset, 300/min
global — `apps/api/src/server.ts`, `routes/auth.ts`) use `@fastify/rate-limit`
with its **default in-memory store**. In the primary Vercel deploy the API
runs as a serverless function: each container has isolated memory and the
platform scales out horizontally under load, so per-IP counters are not shared
between instances — the effective limit becomes roughly
`instances × configured_limit`, and cold starts reset the counters. This
materially weakens brute-force/credential-stuffing protection on `/v1/auth/*`
and registration spam in that model. It does NOT weaken the one-time codes
themselves (~73 bits of entropy, not brute-forceable) or any money/tenant
invariant. The honest fix is a shared store (Vercel KV / Upstash Redis) wired
into `@fastify/rate-limit` — tracked as backlog M13. Until then the limits are
best-effort per instance, and this is the accurate statement (SECURITY.md
corrected accordingly).

## 13. SSRF residual: DNS rebinding on source fetch (red team RT03)

Source fetching (`apps/api/src/services/ingestion.ts`) validates the URL and
now re-validates every redirect hop against private-address blocklists
(`assertSafeUrl`), closing the redirect-follow SSRF. A narrow residual remains:
`assertSafeUrl` resolves DNS and `fetch` resolves again separately, so an
attacker-controlled DNS that returns a public IP at validation and a private
IP at fetch time (rebinding) could still be reached. Fully closing it requires
connecting to a pinned resolved IP with an explicit Host header. The realistic
exposure is low: registering a source URL requires the `data_curator` role,
which is not self-service (RT03-S1), so only a compromised legitimate source
could trigger it. Tracked as backlog M14.
