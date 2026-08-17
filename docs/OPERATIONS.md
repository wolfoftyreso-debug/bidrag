# Operations runbook

Practical procedures for running Bidragskoll.se. Every procedure here must be
*rehearsed* in the real cluster before public launch — an untested backup is
not a backup.

## Topology

One container image (API + pg-boss worker + SPA), N replicas behind the
ingress. Stateful dependencies: **PostgreSQL** (all data + job queue) and the
**uploads volume** (or S3 once migrated). Redis is deliberately not used —
verified by an architectural test (`test/invariants.test.ts`).

## Backup & restore

Two things constitute the system state: the database and the uploads volume.

```bash
# Backup (run from a cron/Job; retain 30 daily + 12 monthly)
pg_dump "$DATABASE_URL" --format=custom --file=bidrag-$(date +%F).dump
tar czf uploads-$(date +%F).tar.gz -C "$UPLOAD_DIR" .

# Restore rehearsal (against a scratch database — do this quarterly)
createdb bidrag_restore_test
pg_restore --dbname=postgres://.../bidrag_restore_test --no-owner bidrag-YYYY-MM-DD.dump
# Verify: row counts on tenants, funding_opportunities, application_cases,
# audit_events; then boot the API against it and hit /readyz + login.
```

Point-in-time recovery: enable WAL archiving on the Postgres instance (RDS
automated backups on AWS). The pg-boss schema (`pgboss`) is included in the
dump; jobs are idempotent so replaying after restore is safe.

## Deployment & rollback

- Images are immutable, tagged by commit SHA; never `:latest`.
- Migrations run at startup and are **additive by policy**: no destructive
  column drops in the same release that stops writing them. This makes
  rollback = `kubectl rollout undo deployment/bidrag-api` safe.
- A migration that must be destructive ships in two releases: N stops using
  the column, N+1 drops it.
- After deploy: watch `/readyz`, `bidrag_http_requests_total{status="5xx"}`
  and the smoke path (login → list opportunities).

## Monitoring & alerting

`GET /metrics` (Prometheus text format, cluster-internal). Alert on:

| Signal | Condition | Meaning |
|---|---|---|
| `bidrag_sources_failing` | > 0 for 12h | A source connector is broken — recommendations may go stale |
| `bidrag_opportunities_review_overdue` | > 5 | Curation backlog — freshness promise at risk |
| `bidrag_matches_stale` | > 0 for 1h | Stale-match worker not keeping up |
| `bidrag_review_queue_pending` | growing for 24h | Human review starved |
| `bidrag_pg_pool_waiting` | > 0 sustained | DB pool exhaustion |
| 5xx rate | > 1 % of requests | Application errors |

## Incident basics

- Every 5xx response carries a `requestId`; logs are JSON with the same id.
- The audit trail (`audit_events`) is append-only — use it to reconstruct
  what happened to a case; never edit it.
- A broken source must never silently serve stale rules: check
  `/v1/admin/sources` health and the review queue first when users report
  wrong eligibility.

## GDPR operations

- Export: user self-service via `GET /v1/tenant/export` (owner role).
- Erasure: `DELETE /v1/tenant` with typed confirmation — removes files, then
  cascades the database; the erasure event itself is retained tenant-less in
  the audit log as proof.
- On a manual Art. 17 request (e.g. via email), perform the same erasure and
  record the request reference in the audit note.

## Rehearsal log

Executed in the development environment on 2026-08-13 (rerun in the real
cluster before launch — the checklist below tracks that):

- **Backup + restore drill** (`scripts/backup.sh` → `scripts/restore-verify.sh`):
  dump + uploads archive with sha256 manifest; restored into a scratch DB;
  row counts verified (36 published opportunities, all core tables, 2 applied
  migrations); API booted against the restored DB — `/readyz` 200 and a full
  registration succeeded. The drill also runs in CI on every push.
- **Load test** (`scripts/loadtest.mjs`, 25 concurrent, 20 s, 4 vCPU dev box):
  599 req/s sustained, 0 non-2xx. Read paths p95 ≈ 45 ms; match recompute
  p95 164 ms after batching the upsert (was 504 ms with per-row writes).
  First run honestly measured only the rate limiter (49 000 × 429) — the
  script now counts any non-2xx as failure and prints the status
  distribution; use `RATE_LIMIT_MAX` to load-test past the default limit.
- **Failure injection** (kill Postgres under live traffic): the process
  initially **crashed** — unhandled `error` event from idle pool clients —
  and the default error path leaked `ECONNREFUSED` to clients because the
  Fastify error handler was registered after the route contexts. Both fixed
  (pool error handler; error handler registered before routes; regression
  tests added). Verified after fix: `/readyz` 503 during outage, generic
  error + requestId to clients, process survives, full read/write recovery
  after DB restart.
- **Dependency audit**: production dependencies at 0 known vulnerabilities
  (`@fastify/static` and `drizzle-orm` patched). Remaining advisories are in
  dev-only toolchain (esbuild dev server via vite/drizzle-kit) — not present
  in the production image.

## Pre-launch drill checklist (real cluster)

- [x] Restore rehearsal against a scratch DB *(dev 2026-08-13 + automated in CI — repeat against the production backup target)*
- [ ] Rollback rehearsal (deploy N, roll back to N-1 under traffic)
- [x] Load test *(dev reference numbers above — repeat at expected peak ×3 through the real ingress)*
- [x] Failure injection: DB outage *(dev — repeat with pod kill and full uploads volume)*
- [ ] Alert rules firing verified end-to-end (to the on-call channel)
- [ ] ClamAV deployed and `scan_unavailable` rate ≈ 0
- [ ] Secrets rotated once via the real secret-manager path
