#!/usr/bin/env bash
# Restore rehearsal: restores a dump into a scratch database and verifies it —
# an untested backup is not a backup. Never touches the source database.
# Usage: SCRATCH_DATABASE_URL=postgres://.../bidrag_restore_test ./scripts/restore-verify.sh <dump-file>
set -euo pipefail

DUMP="${1:?usage: restore-verify.sh <dump-file>}"
: "${SCRATCH_DATABASE_URL:?SCRATCH_DATABASE_URL must be set (a scratch DB that may be wiped)}"

echo "== restoring $DUMP into scratch database =="
psql "$SCRATCH_DATABASE_URL" -q -c "DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public; DROP SCHEMA IF EXISTS drizzle CASCADE; DROP SCHEMA IF EXISTS pgboss CASCADE;"
pg_restore --dbname="$SCRATCH_DATABASE_URL" --no-owner "$DUMP"

echo "== verifying restored content =="
CHECKS="tenants users funding_opportunities rule_versions application_cases audit_events"
for table in $CHECKS; do
  COUNT=$(psql "$SCRATCH_DATABASE_URL" -tA -c "SELECT count(*) FROM $table")
  echo "  $table: $COUNT rows"
done

MIGRATIONS=$(psql "$SCRATCH_DATABASE_URL" -tA -c "SELECT count(*) FROM drizzle.__drizzle_migrations" 2>/dev/null || echo 0)
echo "  applied migrations: $MIGRATIONS"

PUBLISHED=$(psql "$SCRATCH_DATABASE_URL" -tA -c "SELECT count(*) FROM funding_opportunities WHERE status='published'")
if [ "$PUBLISHED" -lt 1 ]; then
  echo "FAIL: restored database has no published opportunities"; exit 1
fi

echo "RESTORE VERIFIED: $PUBLISHED published opportunities, core tables present."
echo "Full drill: boot the API against SCRATCH_DATABASE_URL and hit /readyz + login."
