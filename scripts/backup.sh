#!/usr/bin/env bash
# Bidragskoll.se backup: database dump (custom format) + uploads archive.
# Usage: DATABASE_URL=... UPLOAD_DIR=... ./scripts/backup.sh [output-dir]
set -euo pipefail

OUT_DIR="${1:-./backups}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUT_DIR"

: "${DATABASE_URL:?DATABASE_URL must be set}"
UPLOAD_DIR="${UPLOAD_DIR:-./uploads}"

DB_FILE="$OUT_DIR/bidrag-db-$STAMP.dump"
UP_FILE="$OUT_DIR/bidrag-uploads-$STAMP.tar.gz"

pg_dump "$DATABASE_URL" --format=custom --no-owner --file="$DB_FILE"

# Checksum exactly the files that were actually produced. The uploads archive
# is optional: object storage (Supabase) and fresh deployments have no local
# upload directory, and a database backup that succeeded must never be
# reported as failed because an optional archive was absent.
FILES=("$DB_FILE")
if [ -d "$UPLOAD_DIR" ]; then
  tar czf "$UP_FILE" -C "$UPLOAD_DIR" .
  FILES+=("$UP_FILE")
else
  echo "note: upload dir $UPLOAD_DIR does not exist; skipping uploads archive"
fi

sha256sum "${FILES[@]}" | tee "$OUT_DIR/bidrag-$STAMP.sha256"
echo "backup complete: $DB_FILE"
