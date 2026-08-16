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
accredited mailbox operators; Bidrag.se holds neither role today.

**Fallback implemented**: the unified inbox accepts uploads, forwarded text
and manual entries, classifies message types deterministically (Swedish
decision vocabulary) and auto-matches to cases via submission references —
with human override. The architecture normalises everything to
`correspondence_events`, so a mailbox connector is additive.

## 4. Email delivery — closed

Nodemailer SMTP adapter (`services/email.ts`) activates on `SMTP_URL`;
notifications email the relevant user (or the tenant's owners/applicants).
Every outcome — sent, skipped (no SMTP configured), failed — is recorded in
the audit trail; delivery is best-effort on top of the always-reliable
in-app notification and never breaks the caller. Covered by tests with an
injected transport. Remaining: point `SMTP_URL` at the real relay in the
cluster and verify one end-to-end delivery.

## 5. Malware scanning optional

ClamAV scanning activates when `CLAMAV_ADDRESS` is set (INSTREAM protocol
implemented). Without it, uploads are marked `scan_unavailable` — visible in
the vault, and magic-byte/content-type checks still apply. Deploy the ClamAV
daemon in the cluster for production.

## 6. Object storage is a volume, not S3

Documents live on a PVC (`UPLOAD_DIR`). Fine for a single cluster; for AWS
production move to S3 — call sites are isolated in `routes/documents.ts` /
`services/uploads.ts`.

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

51 curated opportunities across 29 financiers — state agencies, foundations,
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
(`ANALYSIS_PRICE_MINOR`, default 3900 öre) — never a subscription, and never
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
purchase ID, refund status and seller details. The receipt email address is
collected just before payment with a stated purpose, can be added afterwards,
and the receipt can be re-sent — self-service instead of support. Transactional
email goes through Resend (`RESEND_API_KEY`), falls back to SMTP, and is
otherwise honestly recorded as skipped. Receipts survive GDPR tenant erasure
(bookkeeping obligation, GDPR art. 17(3)(b)) with the email address scrubbed.

What is honestly missing: a real payment provider, and confirmed VAT
treatment. The Swish adapter refuses with 503 until `SWISH_MERCHANT_ALIAS`
and `SWISH_CERT_PATH` (merchant agreement + mTLS certificates from the bank)
are configured — it never pretends to charge. The VAT rate is configurable
(`VAT_RATE_BPS`, default 25.00 %) and seller identity comes from
`SELLER_NAME`/`SELLER_ORG_NUMBER`/`SELLER_VAT_NUMBER`, but the actual VAT
classification of the service must be confirmed with the company's
accountant before production — 39 kr × many transactions quickly becomes a
large ledger, so this must be right from day one. The mock provider used by
tests and the demo is disabled in production by construction
(`PAYMENTS_MOCK_ENABLED` is ignored when `NODE_ENV=production`). Adding a
provider touches only `services/paymentProviders.ts`; the engine, receipt
and unlock flow are unchanged.
