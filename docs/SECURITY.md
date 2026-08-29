# Security

## Authentication & sessions

- Passwords hashed with scrypt (N=16384, r=8, p=1), constant-time comparison,
  identical error shapes for unknown user vs wrong password.
- Access tokens: HS256 JWT, 15 min TTL, httpOnly SameSite=Lax cookies
  (Secure in production).
- Refresh tokens: 256-bit random, stored as SHA-256 hashes, rotated on every
  use, revocable, 30-day TTL, path-scoped cookie.
- Rate limits: 10/min on register/login, 300/min globally — **per instance
  (in-memory store)**; in the Vercel serverless model these are not shared
  across instances, so the effective limit scales with instance count. Honest
  caveat + shared-store fix tracked in LIMITATIONS §13 / backlog M13.
- Source fetching re-validates every redirect hop against private-address
  blocklists (no redirect-follow SSRF); DNS-rebinding residual in LIMITATIONS §14.

## Tenant isolation (§27)

Every tenant-owned table has `tenant_id`; every query filters on it; the
request context is derived from a **verified membership** — the `X-Tenant-Id`
header can only select among the caller's own memberships. Cross-tenant access
returns 404 (existence is not leaked). Covered by dedicated integration tests
(IDOR on projects, profiles, cases, documents, matches; list scoping; header
spoofing).

## RBAC

Roles: owner, applicant, contributor, reviewer, finance, administrator,
data_curator, integration_operator. Writes require writer roles; the curation
API requires administrator/data_curator. Every write is attributed in the
audit trail.

## Uploads are hostile input (§28)

- Content-type + extension allowlist (PDF, PNG, JPG, DOCX, XLSX, TXT).
- Magic-byte verification (polyglot defence), 20 MB cap, one file per request.
- Opaque tenant-scoped storage names outside the web root;
  `X-Content-Type-Options: nosniff` + attachment disposition on download.
- ClamAV INSTREAM scanning when `CLAMAV_ADDRESS` is deployed; otherwise files
  are explicitly marked `scan_unavailable` — never silently assumed clean.
  Blocked files cannot be attached to applications.

## SSRF (§28)

Source ingestion only fetches http(s), rejects credentials-in-URL, resolves
DNS and blocks loopback/RFC1918/link-local/CGNAT/multicast targets (v4 and
v6), enforces 10 MB / 30 s limits, and identifies itself with a UA string.

## Secrets & crypto

- All secrets from environment variables (Vercel Environment Variables;
  Kubernetes Secrets in the container path); production fails fast if
  missing; nothing in code or logs (auth headers redacted from request logs).
- External identifiers (OID, org.nr) encrypted at rest with AES-256-GCM
  (`FIELD_ENCRYPTION_KEY`), stored separately from profiles.
- **Never stored**: BankID credentials, external portal passwords, session
  cookies for authority systems. Authority authentication always happens in
  the authority's own flow (§17, §47).

## Headers & transport

Helmet CSP (self-only scripts, no framing), CORS restricted to the configured
origin with credentials, TLS terminated by the platform on Vercel (at ingress
in the container path), cookies Secure in production.

## Row Level Security (Supabase)

Migration 0005 enables RLS with no policies (deny-all) on every `public`
table and revokes grants from the `anon`/`authenticated` roles, so Supabase's
PostgREST can never read anything — all access goes through the API.

## Error handling

5xx responses never leak internals — users get a request ID; details go to
structured logs.

## Known gaps

See `LIMITATIONS.md` (ClamAV optional, no CSRF token on top of SameSite=Lax).
A Prometheus `/metrics` endpoint exists in the API, but dashboards/alerting
remain to be set up (LIMITATIONS §9) and it is not exposed in the Vercel
deployment.
