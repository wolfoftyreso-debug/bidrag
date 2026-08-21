#!/usr/bin/env bash
# Regenererar deploy/bootstrap.sql — hela databasen (schema + RLS +
# kunskapsbas + migrationsspårning) som en körbar SQL-fil utan psql-
# metakommandon. Kör den här efter varje ändring av migreringar eller seed.
#
#   bash scripts/make-bootstrap.sh
#
# Anslutning: VERIFY_ADMIN_URL (default postgres://postgres@localhost:5432/postgres).
# Skapar och raderar endast temporära databaser med prefixet bootstrap_.
# Verifierar sin egen produkt genom rundtur mot en andra tom databas innan
# den skriver resultatet.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ADMIN_URL="${VERIFY_ADMIN_URL:-postgres://postgres@localhost:5432/postgres}"
BASE_URL="${ADMIN_URL%/*}"
SRC_DB="bootstrap_src_$$"
CHK_DB="bootstrap_chk_$$"
OUT="deploy/bootstrap.sql"
TMP="$(mktemp)"
MIG_COUNT="$(ls apps/api/drizzle/*.sql | wc -l | tr -d ' ')"

cleanup() {
  psql "$ADMIN_URL" -c "DROP DATABASE IF EXISTS $SRC_DB" >/dev/null 2>&1 || true
  psql "$ADMIN_URL" -c "DROP DATABASE IF EXISTS $CHK_DB" >/dev/null 2>&1 || true
  rm -f "$TMP"
}
trap cleanup EXIT

echo "1/4 Migrerar + seedar en ren databas ($SRC_DB)…"
psql "$ADMIN_URL" -c "CREATE DATABASE $SRC_DB" >/dev/null
DATABASE_URL="${BASE_URL}/${SRC_DB}" npm run db:migrate >/dev/null
DATABASE_URL="${BASE_URL}/${SRC_DB}" npm run db:seed >/dev/null

echo "2/4 Dumpar (INSERT-format, utan psql-metakommandon)…"
pg_dump "${BASE_URL}/${SRC_DB}" --no-owner --no-privileges --inserts --rows-per-insert=50 \
  | sed '/^\\restrict/d; /^\\unrestrict/d' > "$TMP"
if grep -q '^\\' "$TMP"; then
  echo "FEL: dumpen innehåller psql-metakommandon som inte filtrerats bort:" >&2
  grep -n '^\\' "$TMP" | head >&2
  exit 1
fi

echo "3/4 Rundtur mot tom databas ($CHK_DB)…"
psql "$ADMIN_URL" -c "CREATE DATABASE $CHK_DB" >/dev/null
psql "${BASE_URL}/${CHK_DB}" -v ON_ERROR_STOP=1 -q -f "$TMP"
got="$(psql "${BASE_URL}/${CHK_DB}" -Atc \
  "select (select count(*) from public.funding_opportunities)||'/'||(select count(*) from public.funding_authorities)||'/'||(select count(*) from public.application_schemas)||'/'||(select count(*) from public.sources)||'/'||(select count(*) from drizzle.__drizzle_migrations)")"
src="$(psql "${BASE_URL}/${SRC_DB}" -Atc \
  "select (select count(*) from public.funding_opportunities)||'/'||(select count(*) from public.funding_authorities)||'/'||(select count(*) from public.application_schemas)||'/'||(select count(*) from public.sources)||'/'||(select count(*) from drizzle.__drizzle_migrations)")"
[ "$got" = "$src" ] || { echo "FEL: rundturen gav $got, källan har $src" >&2; exit 1; }
DATABASE_URL="${BASE_URL}/${CHK_DB}" npm run db:migrate >/dev/null
after="$(psql "${BASE_URL}/${CHK_DB}" -Atc 'select count(*) from drizzle.__drizzle_migrations')"
[ "$after" = "$MIG_COUNT" ] || { echo "FEL: db:migrate var inte en no-op efter bootstrap ($after != $MIG_COUNT)" >&2; exit 1; }

mv "$TMP" "$OUT"
TMP="$(mktemp)" # så att trap inte raderar resultatet
echo "4/4 Klart: $OUT ($(wc -c < "$OUT") byte, räkningar $got, $MIG_COUNT migreringar)."
echo "Uppdatera räkningarna i docs/DEPLOY-AGENT.md om de ändrats, och committa filen."
