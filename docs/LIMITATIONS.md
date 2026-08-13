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

## 2. Live source parsing is snapshot+diff, not structured extraction

**Blocker**: wave-1 sources publish HTML/PDF without machine-readable rule
data; reliable unattended extraction of eligibility rules is not safe to
publish without human review (§24).

**Fallback implemented**: the ingestion pipeline fetches, hashes, snapshots
and hash-diffs every registered source on a schedule with SSRF guards; any
change lands in the human review queue; rules are published as curated,
versioned `rule_versions` with provenance and `last_verified_at`. The seeded
wave-1 opportunities are `human_curated` from the official URLs on
2026-08-13, and the UI displays that status and date rather than claiming
live verification. Deadlines that could not be verified are modelled as
`rolling`/`upcoming_round` with no invented dates.

**Next boundary**: per-source parsers registered on `sources.parserVersion`,
emitting extracted rules into the same review queue.

## 3. Digital post / mailbox integrations not connected

**Blocker**: Digg's digital-post infrastructure serves public actors and
accredited mailbox operators; Bidrag.se holds neither role today.

**Fallback implemented**: the unified inbox accepts uploads, forwarded text
and manual entries, classifies message types deterministically (Swedish
decision vocabulary) and auto-matches to cases via submission references —
with human override. The architecture normalises everything to
`correspondence_events`, so a mailbox connector is additive.

## 4. Email delivery not wired

`SMTP_URL` is configured but no SMTP adapter ships; notifications are
reliably delivered in-app and the skipped email is recorded in the audit
trail. Wire nodemailer or a provider in `services/notifications.ts`.

## 5. Malware scanning optional

ClamAV scanning activates when `CLAMAV_ADDRESS` is set (INSTREAM protocol
implemented). Without it, uploads are marked `scan_unavailable` — visible in
the vault, and magic-byte/content-type checks still apply. Deploy the ClamAV
daemon in the cluster for production.

## 6. Object storage is a volume, not S3

Documents live on a PVC (`UPLOAD_DIR`). Fine for a single cluster; for AWS
production move to S3 — call sites are isolated in `routes/documents.ts` /
`services/uploads.ts`.

## 7. GDPR self-service — largely closed

`GET /v1/tenant/export` (full JSON bundle, owner role) and `DELETE
/v1/tenant` (typed confirmation, file deletion + database cascade, tenant-less
audit proof) now exist and are integration-tested. Remaining: a retention
scheduler for time-based purging, UI surface for the endpoints, and the
operator's DPIA before public launch (see PRIVACY.md, OPERATIONS.md).

## 8. Coverage is wave-1 (expanded)

28 curated opportunities across 16 financiers (state agencies, foundations,
sports federation, EU programmes) exercise the data patterns: recurring and
rolling deadlines, upcoming rounds, OID/Quality Label requirements,
applicant-type gates, co-financing shares, prefinancing requirements. This
proves the engine — it is not national coverage. Scaling to hundreds of
opportunities is data work on the existing model plus curator throughput
(the curator console now shows affected opportunities per source change and
offers one-click re-verification). No schema changes required.

## 9. Observability — partially closed

Structured logs, probes, admin health views and a Prometheus `/metrics`
endpoint (HTTP, process, pool and domain gauges) now exist, with recommended
alert rules in OPERATIONS.md. Remaining: dashboards and alert wiring in the
cluster's monitoring stack, plus a rehearsed on-call path.

## 10. Payments/billing not built

Deliberate (§68): tenant/subscription boundaries exist in the model; billing
should not be built before core value is proven.
