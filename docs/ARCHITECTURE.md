# Architecture

## Shape

A **modular monolith** (deliberately — §56 of the build order). The primary
deployment is **Vercel + Supabase**: the built SPA served statically and the
entire API as one serverless function (`api/index.ts`), with Supabase providing
Postgres (via its pooler) and Storage. A container image (API, pg-boss worker
and SPA in one) is retained as an alternative self-hosting path. See
`docs/DEPLOYMENT.md`.
Logical boundaries are enforced in code layout and can be split into
services later without changing contracts:

```
packages/core          — pure domain logic (no I/O, fully unit-tested)
apps/api/src
  auth/                — passwords (scrypt), tokens (JWT+refresh), field crypto (AES-GCM)
  plugins/auth.ts      — tenant context + RBAC
  db/                  — Drizzle schema (37 tables), deterministic SQL migrations
  routes/              — versioned /v1 REST API (OpenAPI at /v1/openapi.json)
  services/            — matching, applications, submission gateway, ingestion,
                         uploads, notifications
  jobs/                — pg-boss queues: source-fetch, deadline-scan, stale-match-recalc,
                         curator-reminders, retention
  seed/                — wave-1 curated funding knowledge with provenance
```

## Data model invariants

- **Tenant-owned tables** carry `tenant_id`; every query filters on it; tested
  by `test/tenantIsolation.test.ts`.
- **Public funding knowledge** (authorities, programmes, opportunities, rules,
  sources) is shared across tenants and carries provenance instead:
  `source_url`, `source_quality` (A–D), `verification_status`,
  `last_verified_at`, `next_review_at`.
- **Temporal rules** (§23): `rule_versions` are effective-dated; opportunities
  point at `current_rule_version_id`; matches record which version they were
  computed against; submitted cases freeze an `opportunity_snapshot` and
  `submitted_snapshot` that are never altered afterwards.
- **Money** is integer minor units (öre) everywhere.
- **audit_events** is append-only; every consequential mutation writes one.

## Match engine (packages/core/src/matching.ts)

Five layers, deterministic and reproducible from stored facts + rule version +
reference date (§11–12):

1. Hard exclusions (wrong applicant type/geography, closed deadline) — score 0.
2. Mandatory criteria over *known* facts; three-valued logic (pass/fail/unknown);
   missing facts surface as intake questions, never silently as failures.
3. Weighted strategic fit.
4. Evidence readiness (mandatory evidence kinds vs the tenant's vault).
5. Execution readiness (days to deadline vs estimated effort).

Composite: eligibility gate 40 + fit 35 + evidence 15 + execution 10.
Semantic similarity can *discover*, but can never override a deterministic
exclusion — the engine only consumes structured criteria.

## Application lifecycle (§32)

Formal state machine in `packages/core/src/stateMachine.ts`, enforced
server-side. Guarded transitions:

- `READY_FOR_REVIEW → READY_TO_SUBMIT` requires full validation (fields,
  budget rules, mandatory attachments).
- `→ SUBMITTED` is unreachable through the generic transition endpoint; only
  the submission flow can get there, and only with evidence: an adapter
  confirmation (native/structured) or a user-recorded receipt (assisted).
- Failed adapter submissions fall back to `READY_TO_SUBMIT` visibly.

## Submission levels (§16)

The adapter registry (`services/submission.ts`) is the integration boundary.
No native/structured adapter is registered today because no wave-1 authority
exposes a supported public submission API (see LIMITATIONS.md) — every
opportunity therefore runs the **assisted** flow: validated package + official
URL + user-confirmed receipt. Adding an authorised adapter changes nothing in
the application flow.

## Ingestion (§20–22)

`services/ingestion.ts` fetches registered sources with strict SSRF controls
(protocol allowlist, DNS resolution against private/reserved ranges, size and
time limits), stores immutable hashed snapshots, hash-diffs against the
previous snapshot and queues changes for human review. Publishing a new rule
version marks affected matches stale; a worker recomputes them and notifies
affected tenants. Raw source evidence is never discarded.

## Background jobs (§59)

pg-boss (Postgres-backed, no extra infrastructure): all jobs idempotent, retry
with backoff, failed jobs retained. Queues: `source-fetch` (6-hourly),
`deadline-scan` (daily), `stale-match-recalc` (15-min), `curator-reminders`
and `retention`. On Vercel the same job bodies run via Vercel Cron calling
`/v1/internal/cron/:job` (all five schedules are in `vercel.json`) instead of
the pg-boss worker.

**Redis is deliberately not used.** It exists in some base environments but
nothing in this system depends on it — Postgres is the single stateful
dependency, and an architectural test (`test/invariants.test.ts`) fails the
build if a Redis reference is introduced. Fewer moving parts.

## Domain invariants enforced by tests

Two guarantees are treated as architecture, not convention, and are enforced
by dedicated tests:

1. **Tenant isolation** — every tenant-owned query filters on `tenant_id`
   (`test/tenantIsolation.test.ts`).
2. **Case state is owned by the domain service** — only
   `services/applications.ts` may write `application_cases.state`; routes,
   jobs and future integrations go through `transitionCase()` with its guards
   (`test/invariants.test.ts`). UI, API handlers and adapters never decide
   status on their own.

## Observability (§44)

- Structured JSON logs (pino) with request IDs, redacted auth headers.
- `/healthz` (liveness) and `/readyz` (DB-checked readiness) probes.
- `/metrics` — Prometheus text format: HTTP counters/durations, process and
  pg-pool gauges, and domain health gauges (published opportunities, overdue
  reviews, stale matches, review-queue depth, failing sources). Recommended
  alert rules in OPERATIONS.md.
- Operational views in the admin console: source health, review queue with
  affected opportunities, verification urgency list with one-click re-verify.

## Scaling path

- Postgres is the single stateful dependency (plus Supabase Storage for
  documents in production — `STORAGE_DRIVER=supabase` — or a disk/volume in
  the container path; the driver boundary in `services/storage.ts` is the
  adapter boundary).
- Matching is per-project and embarrassingly parallel.
- The knowledge graph is read-heavy and cacheable; tenant data is not shared.
