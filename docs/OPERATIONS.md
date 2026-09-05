# Operations runbook

Practical procedures for running Bidragskoll.se. Every procedure here must be
*rehearsed* in the real cluster before public launch — an untested backup is
not a backup.

## Topology

Primary path: **Vercel** (static SPA + the API as one serverless function) +
**Supabase** (PostgreSQL via the pooler, Storage for uploads), with jobs run
by Vercel Cron. Alternative self-hosting path: one container image (API +
pg-boss worker + SPA), N replicas behind the ingress, with an uploads volume.
Stateful dependencies either way: **PostgreSQL** (all data + job queue) and
the document store. Redis is deliberately not used — verified by an
architectural test (`test/invariants.test.ts`).

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

Point-in-time recovery: Supabase PITR in the primary path; when self-hosting,
enable WAL archiving on the Postgres instance (e.g. RDS automated backups on
AWS). The pg-boss schema (`pgboss`) is included in the
dump; jobs are idempotent so replaying after restore is safe.

## Deployment & rollback

- Images are immutable, tagged by commit SHA; never `:latest`.
- Migrations run at startup in the container path only; on Vercel they are a
  deploy step (`npm run db:migrate` against the direct connection) and never
  run at cold start. They are **additive by policy**: no destructive
  column drops in the same release that stops writing them. This makes
  rollback safe: on Vercel, "Promote previous deployment"; in the container
  path, `kubectl rollout undo deployment/bidrag-api`.
- A migration that must be destructive ships in two releases: N stops using
  the column, N+1 drops it.
- After deploy: watch `/readyz`, `bidrag_http_requests_total{status="5xx"}`
  and the smoke path (login → list opportunities).

## Monitoring & alerting

`GET /metrics` (Prometheus text format, cluster-internal). Note: `/metrics`
is not exposed in the Vercel deployment — there, use Vercel function logs and
the structured pino logs. Alert on:

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
  row counts verified (historical snapshot from the 2026-08-13 drill: 36
  published opportunities, all core tables, 2 applied migrations — current
  state is 72 supports and 12 migrations); API booted against the restored DB — `/readyz` 200 and a full
  registration succeeded. The drill also runs in CI on every push.
- **Load test** (`scripts/loadtest.mjs`): two modes — capacity (N workers
  flat out) and `--model` (the demand model's peak hours as fixed-rate
  scenarios with the funnel mix, results in `artifacts/loadtest.json`).
  2026-09-05 run (`docs/reports/LOADTEST_2026-09-05.md`, 4 vCPU sandbox, one
  process): all three modelled peak hours and a ×5 spike (64 req/s) with 0
  non-2xx and p95 ≤ 56 ms; capacity 202 req/s with match recompute p95 335 ms.
  `/v1/events` has its own per-IP limit, now `max(60, RATE_LIMIT_MAX/5)` so
  a single-IP load test measures capacity, not the guard.
  Historical: 2026-08 capacity run 599 req/s on the read-heavy mix; match
  recompute p95 164 ms after batching the upsert (was 504 ms with per-row writes).
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

- [x] Restore rehearsal against a scratch DB *(dev 2026-08-13 + automated in CI — repeat against the production backup target; Vercel/Supabase: restore via Supabase PITR/backup into a scratch project)*
- [ ] Rollback rehearsal (deploy N, roll back to N-1 under traffic) *(Vercel: "Promote previous deployment")*
- [x] Load test *(dev reference numbers above — repeat at expected peak ×3 through the real ingress; Vercel: through the production domain)*
- [x] Failure injection: DB outage *(dev — repeat with pod kill and full uploads volume; Vercel/Supabase: pause the Supabase project and verify `/readyz` + client error behaviour)*
- [ ] Alert rules firing verified end-to-end (to the on-call channel) *(Vercel: log/alert integration on function logs — `/metrics` is not exposed there)*
- [ ] ClamAV deployed and `scan_unavailable` rate ≈ 0 *(no Vercel equivalent — uploads are honestly marked `scan_unavailable` in that path)*
- [ ] Secrets rotated once via the real secret-manager path *(Vercel: rotate via Environment Variables + redeploy; Supabase: rotate service keys)*
