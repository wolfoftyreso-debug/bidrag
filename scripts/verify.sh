#!/usr/bin/env bash
# Hälsokontroll i ett kommando: bygge, typer, tester, databas-bootstrap,
# produktionsbygge, deploy-konfiguration och hemlighetsskanning.
#
#   npm run verify            # allt (kräver PostgreSQL igång)
#   npm run verify -- --no-db # utan databassteg (t.ex. miljö utan Postgres)
#
# Databasanslutning: VERIFY_ADMIN_URL (default postgres://postgres@localhost:5432/postgres).
# Skriptet skapar/raderar ENDAST databaser med prefixet verify_ samt bidrag_test.
# Avslutar 0 endast om varje kört steg passerade. UI-/demo-kontrollerna (kräver
# Chromium) ingår inte här — se tools/README.md för dem.
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
ADMIN_URL="${VERIFY_ADMIN_URL:-postgres://postgres@localhost:5432/postgres}"
BASE_URL="${ADMIN_URL%/*}"
WITH_DB=1
[ "${1:-}" = "--no-db" ] && WITH_DB=0

PASS=0; FAIL=0; SKIP=0; FAILED_STEPS=""
step() { # step <namn> <kommando...>
  local name="$1"; shift
  printf '\n== %s\n' "$name"
  local log; log="$(mktemp)"
  if "$@" >"$log" 2>&1; then
    PASS=$((PASS+1)); echo "   PASS"
  else
    FAIL=$((FAIL+1)); FAILED_STEPS="$FAILED_STEPS  - $name\n"
    echo "   FAIL — sista 40 raderna:"; tail -40 "$log" | sed 's/^/   | /'
  fi
  rm -f "$log"
}
skip() { SKIP=$((SKIP+1)); printf '\n== %s\n   HOPPAD (%s)\n' "$1" "$2"; }

# ── 0. Grundkrav ─────────────────────────────────────────────────────────────
node_ok() {
  local major; major="$(node -p 'process.versions.node.split(".")[0]')" || return 1
  [ "$major" -ge 22 ] || { echo "Node $major < 22"; return 1; }
  [ -d node_modules ] || { echo "node_modules saknas — kör npm ci först"; return 1; }
}
step "Node >= 22 och beroenden installerade" node_ok

db_up=0
if [ "$WITH_DB" = 1 ]; then
  if psql "$ADMIN_URL" -Atc 'select 1' >/dev/null 2>&1; then
    db_up=1
    echo "   (databas nåbar: ${BASE_URL})"
  else
    step "PostgreSQL nåbar på $ADMIN_URL" false
    echo "   Tips (denna sandlåda): rm -f /home/user/pgdata/postmaster.pid && su postgres -c \"/usr/lib/postgresql/16/bin/pg_ctl -D /home/user/pgdata -o '-k /tmp -p 5432' -l /home/user/pgdata/log start\""
  fi
fi

# ── 1. Bygge, typer, lint ────────────────────────────────────────────────────
step "Bygg packages/core (krävs före typecheck)" npm run build -w packages/core
step "Typecheck (core + api + web)" npm run typecheck
step "Lint" npm run lint

# ── 2. Tester ────────────────────────────────────────────────────────────────
step "Core-tester (enhetstester, ingen databas)" npm test -w packages/core
step "Relevansrevisionen (personor mot alla stöd, F-RELEVANS)" node tools/audit-relevans.mjs
step "Produktdoktrinen (situations-först, ingen entry-gate, värde före betalning)" node tools/doctrine.mjs
step "Semantic guard (Open Discovery + kanonisk entitet, FAS SEO-2)" node tools/semanticguard.mjs
step "I18N: alla 11 språk kompletta och konsistenta (I18N_PROGRAM)" node --experimental-strip-types tools/i18ncheck.mjs
if [ "$db_up" = 1 ]; then
  psql "$ADMIN_URL" -Atc "select 1 from pg_database where datname='bidrag_test'" | grep -q 1 \
    || psql "$ADMIN_URL" -c 'CREATE DATABASE bidrag_test' >/dev/null
  api_tests() { TEST_DATABASE_URL="${BASE_URL}/bidrag_test" npm test -w apps/api; }
  step "API-tester (integration mot bidrag_test)" api_tests
else
  skip "API-tester" "ingen databas"
fi

# ── 3. Databasen från noll: bootstrap + migreringar ─────────────────────────
if [ "$db_up" = 1 ]; then
  BOOT_DB="verify_boot_$$"
  MIG_DB="verify_mig_$$"
  MIG_COUNT="$(ls apps/api/drizzle/*.sql | wc -l | tr -d ' ')"

  bootstrap_roundtrip() {
    psql "$ADMIN_URL" -c "DROP DATABASE IF EXISTS $BOOT_DB" >/dev/null &&
    psql "$ADMIN_URL" -c "CREATE DATABASE $BOOT_DB" >/dev/null &&
    psql "${BASE_URL}/${BOOT_DB}" -v ON_ERROR_STOP=1 -q -f deploy/bootstrap.sql &&
    got="$(psql "${BASE_URL}/${BOOT_DB}" -Atc \
      "select (select count(*) from public.funding_opportunities)||'/'||(select count(*) from public.funding_authorities)||'/'||(select count(*) from public.application_schemas)||'/'||(select count(*) from public.sources)||'/'||(select count(*) from drizzle.__drizzle_migrations)")" &&
    want="85/36/71/37/${MIG_COUNT}" &&
    { [ "$got" = "$want" ] || { echo "räkningar: fick $got, väntade $want"; false; }; } &&
    DATABASE_URL="${BASE_URL}/${BOOT_DB}" npm run db:migrate &&
    after="$(psql "${BASE_URL}/${BOOT_DB}" -Atc 'select count(*) from drizzle.__drizzle_migrations')" &&
    { [ "$after" = "$MIG_COUNT" ] || { echo "db:migrate var inte en no-op efter bootstrap ($after != $MIG_COUNT)"; false; }; }
  }
  step "deploy/bootstrap.sql mot tom databas (räkningar + migrate är no-op)" bootstrap_roundtrip
  psql "$ADMIN_URL" -c "DROP DATABASE IF EXISTS $BOOT_DB" >/dev/null 2>&1

  migrations_from_scratch() {
    psql "$ADMIN_URL" -c "DROP DATABASE IF EXISTS $MIG_DB" >/dev/null &&
    psql "$ADMIN_URL" -c "CREATE DATABASE $MIG_DB" >/dev/null &&
    DATABASE_URL="${BASE_URL}/${MIG_DB}" npm run db:migrate &&
    DATABASE_URL="${BASE_URL}/${MIG_DB}" npm run db:seed &&
    got="$(psql "${BASE_URL}/${MIG_DB}" -Atc 'select count(*) from public.funding_opportunities')" &&
    { [ "$got" = "85" ] || { echo "seed gav $got stöd, väntade 85"; false; }; }
  }
  step "Migreringar + seed från tom databas" migrations_from_scratch
  psql "$ADMIN_URL" -c "DROP DATABASE IF EXISTS $MIG_DB" >/dev/null 2>&1
else
  skip "Bootstrap- och migreringsverifiering" "ingen databas"
fi

# ── 4. Produktionsbygge ──────────────────────────────────────────────────────
step "Produktionsbygge (core + api + web)" npm run build

# ── 5. Deploy-konfiguration ──────────────────────────────────────────────────
deploy_config() {
  node -e 'JSON.parse(require("fs").readFileSync("vercel.json","utf8"))' || { echo "vercel.json är inte giltig JSON"; return 1; }
  [ -f api/index.ts ] || { echo "api/index.ts (serverless-ingången) saknas"; return 1; }
  [ -f Dockerfile ] || { echo "Dockerfile saknas"; return 1; }
  [ -f deploy/bootstrap.sql ] || { echo "deploy/bootstrap.sql saknas"; return 1; }
  # Cron-paths i vercel.json och CRON_TASKS i jobs/tasks.ts ska matcha 1:1.
  node -e '
    const fs = require("fs");
    const crons = (JSON.parse(fs.readFileSync("vercel.json","utf8")).crons ?? []).map(c => c.path.split("/").pop());
    const src = fs.readFileSync("apps/api/src/jobs/tasks.ts","utf8");
    const block = src.slice(src.indexOf("CRON_TASKS"));
    const tasks = [...block.slice(0, block.indexOf("};")).matchAll(/^\s+['\''"]?([a-z][a-z-]*)['\''"]?:/gm)].map(m => m[1]);
    const missingRoute = crons.filter(j => !tasks.includes(j));
    const missingCron = tasks.filter(j => !crons.includes(j));
    if (missingRoute.length) { console.error("cron i vercel.json utan jobb i CRON_TASKS: " + missingRoute.join(", ")); process.exit(1); }
    if (missingCron.length) { console.error("jobb i CRON_TASKS utan cron-post i vercel.json: " + missingCron.join(", ")); process.exit(1); }'
  # Dokumentdrift: deploy-körbokens migreringsantal måste stämma med verkligheten.
  local n; n="$(ls apps/api/drizzle/*.sql | wc -l | tr -d ' ')"
  grep -q "${n} migreringar" docs/DEPLOY-AGENT.md \
    || { echo "docs/DEPLOY-AGENT.md nämner inte aktuella migreringsantalet (${n}) — uppdatera körboken (och kör scripts/make-bootstrap.sh)"; return 1; }
}
step "Deploy-konfiguration (vercel.json, serverless-ingång, cron-routes)" deploy_config

# ── 5b. Systemhandboken ──────────────────────────────────────────────────────
# Reaktivitetsvakten: docs/MANUAL.md måste vara regenererad ur källorna, och
# varje API-operation/kommando måste ha en instruktion i tools/genmanual.mjs.
manual_check() { node --experimental-strip-types tools/genmanual.mjs --check; }
step "Systemhandboken är aktuell och komplett (docs/MANUAL.md)" manual_check

# ── 5c. Publika SEO-ytan ─────────────────────────────────────────────────────
# Keyword-databasen i synk med seeden, sidgenerering ur sanningsmodellen och
# full teknisk QA (titlar, canonical, länkgraf, sitemap, JSON-LD, orphans).
seo_check() {
  node --experimental-strip-types tools/seokeywords.mjs --check &&
  node --experimental-strip-types tools/genqueries.mjs --check &&
  node --experimental-strip-types tools/genkgraf.mjs --check &&
  node --experimental-strip-types tools/demandmodel.mjs --check &&
  node --experimental-strip-types tools/genseo.mjs &&
  node tools/seocheck.mjs &&
  node --experimental-strip-types tools/gatekeywords.mjs --check &&
  node --experimental-strip-types tools/gate0.mjs --allow-content-red
}
step "Publika SEO-ytan genereras och klarar QA-crawlen" seo_check
step "Maskinförståelse: de 10 kärnpåståendena finns i publik text (FAS SEO-2)" node tools/semantictest.mjs
step "Indexability-domar i synk (Query Pages, SEO-3)" node --experimental-strip-types tools/indexability.mjs --check
step "SEO data-QA: källa + deadline-accuracy (DoD-invarianter, SEO-120/121)" node --experimental-strip-types tools/seo-dataqa.mjs

# ── 6. Hemlighetsskanning (versionshanterade filer) ──────────────────────────
secrets_scan() {
  local hits
  hits="$(git grep -nIE \
    -e 'sk-ant-[A-Za-z0-9_-]{16,}' \
    -e 'sk_live_[A-Za-z0-9]{16,}' \
    -e 're_[A-Za-z0-9]{24,}' \
    -e 'AQ\.[A-Za-z0-9_-]{30,}' \
    -e '-----BEGIN( RSA| EC| OPENSSH)? PRIVATE KEY' \
    -e 'eyJ[A-Za-z0-9_-]{30,}\.eyJ' \
    -e 'AKIA[0-9A-Z]{16}' \
    -- ':(exclude)package-lock.json' 2>/dev/null || true)"
  [ -z "$hits" ] || { echo "Misstänkta hemligheter:"; echo "$hits"; return 1; }
  git ls-files | grep -E '(^|/)\.env($|\.local|\.production)|\.pem$|\.p12$|\.key$' \
    && { echo "Hemlighetsfil versionshanterad (ovan)"; return 1; } || true
}
step "Inga hemligheter i versionshanterade filer" secrets_scan

# ── Summering ────────────────────────────────────────────────────────────────
printf '\n────────────────────────────────\n'
printf 'PASS: %d   FAIL: %d   HOPPADE: %d\n' "$PASS" "$FAIL" "$SKIP"
if [ "$FAIL" -gt 0 ]; then printf 'Fallerade steg:\n%b' "$FAILED_STEPS"; exit 1; fi
echo "Allt grönt."
