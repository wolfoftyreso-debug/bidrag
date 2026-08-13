# Security

## Authentication & sessions

- Passwords hashed with scrypt (N=16384, r=8, p=1), constant-time comparison,
  identical error shapes for unknown user vs wrong password.
- Access tokens: HS256 JWT, 15 min TTL, httpOnly SameSite=Lax cookies
  (Secure in production).
- Refresh tokens: 256-bit random, stored as SHA-256 hashes, rotated on every
  use, revocable, 30-day TTL, path-scoped cookie.
- Rate limits: 10/min on register/login, 300/min globally.

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

- All secrets from environment / Kubernetes Secrets; production fails fast if
  missing; nothing in code or logs (auth headers redacted from request logs).
- External identifiers (OID, org.nr) encrypted at rest with AES-256-GCM
  (`FIELD_ENCRYPTION_KEY`), stored separately from profiles.
- **Never stored**: BankID credentials, external portal passwords, session
  cookies for authority systems. Authority authentication always happens in
  the authority's own flow (§17, §47).

## Headers & transport

Helmet CSP (self-only scripts, no framing), CORS restricted to the configured
origin with credentials, TLS terminated at ingress, cookies Secure in
production.

## Error handling

5xx responses never leak internals — users get a request ID; details go to
structured logs.

## Known gaps

See `LIMITATIONS.md` (ClamAV optional, no CSRF token on top of SameSite=Lax,
no Prometheus endpoint yet).
