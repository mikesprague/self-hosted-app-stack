#!/usr/bin/env bash
# Idempotently provisions a Postgres role, database, and pgvector extension
# for each app listed in POSTGRES_SHARED_PROVISION_APPS.
#
# Source of truth: the repo-root .env file (bind-mounted read-only into this
# container). POSTGRES_SHARED_PROVISION_APPS is a manually maintained,
# comma-separated list of app identifiers, e.g.:
#   POSTGRES_SHARED_PROVISION_APPS="anythingllm,bifrost,freshrss"
# Adding a future Postgres-backed app means adding its identifier to that
# list by hand -- nothing here infers or discovers app names automatically.
#
# Safe to rerun on every `docker compose up`: existing roles/databases are
# left alone (password is re-synced to POSTGRES_SHARED_APP_PASSWORD every
# run), and only genuine failures (bad connection, invalid identifier, etc.)
# cause a non-zero exit.

set -uo pipefail

ENV_FILE="${ENV_FILE:-/run/secrets/.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "provision-apps: cannot find env file at $ENV_FILE" >&2
  exit 1
fi

# The .env file is sourced as plain bash (KEY="value" assignments), not
# parsed by a separate dotenv tool. Keep it that way.
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

: "${POSTGRES_SHARED_SUPERUSER:?POSTGRES_SHARED_SUPERUSER is not set}"
: "${POSTGRES_SHARED_SUPERUSER_PASSWORD:?POSTGRES_SHARED_SUPERUSER_PASSWORD is not set}"
: "${POSTGRES_SHARED_DEFAULT_DB:?POSTGRES_SHARED_DEFAULT_DB is not set}"
: "${POSTGRES_SHARED_APP_PASSWORD:?POSTGRES_SHARED_APP_PASSWORD is not set}"
: "${POSTGRES_SHARED_PROVISION_APPS:?POSTGRES_SHARED_PROVISION_APPS is not set}"

export PGHOST="postgres-shared"
export PGPORT="5432"
export PGUSER="$POSTGRES_SHARED_SUPERUSER"
export PGPASSWORD="$POSTGRES_SHARED_SUPERUSER_PASSWORD"
export PGDATABASE="$POSTGRES_SHARED_DEFAULT_DB"

# Lowercase Postgres identifier, matching the DB/role names already used
# throughout .env (e.g. "openwebui", "anythingllm").
identifier_re='^[a-z_][a-z0-9_]{0,62}$'
failures=0

IFS=',' read -ra apps <<<"$POSTGRES_SHARED_PROVISION_APPS"

for raw in "${apps[@]}"; do
  app="$(echo "$raw" | xargs)"
  [ -z "$app" ] && continue

  if ! [[ "$app" =~ $identifier_re ]]; then
    echo "provision-apps: skipping invalid app identifier '$app' (must match $identifier_re)" >&2
    failures=$((failures + 1))
    continue
  fi

  echo "provision-apps: ensuring role for '$app'"

  # Note: this deliberately avoids a DO $$ ... $$ block -- psql's client-side
  # :'var' substitution is skipped inside dollar-quoted bodies (so it doesn't
  # clobber PL/pgSQL syntax like := or ::casts), so variables never reach the
  # server from inside one. SELECT ... \gexec keeps substitution at the
  # top-level statement scope where it actually applies.
  if ! psql -v ON_ERROR_STOP=1 -v app="$app" -v pass="$POSTGRES_SHARED_APP_PASSWORD" <<'SQL'; then
SELECT CASE
    WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'app')
      THEN format('ALTER ROLE %I WITH PASSWORD %L', :'app', :'pass')
    ELSE format('CREATE ROLE %I LOGIN PASSWORD %L', :'app', :'pass')
  END
\gexec
SQL
    echo "provision-apps: FAILED to create/sync role for '$app'" >&2
    failures=$((failures + 1))
    continue
  fi

  echo "provision-apps: ensuring database for '$app'"

  db_exists="$(psql -tAc "SELECT 1 FROM pg_database WHERE datname = '${app}'" | tr -d '[:space:]')"

  if [ "$db_exists" != "1" ]; then
    if ! psql -v ON_ERROR_STOP=1 -v app="$app" <<'SQL'; then
SELECT format('CREATE DATABASE %I OWNER %I', :'app', :'app') \gexec
SQL
      echo "provision-apps: FAILED to create database for '$app'" >&2
      failures=$((failures + 1))
      continue
    fi
  fi

  echo "provision-apps: ensuring pgvector extension for '$app'"

  if ! psql -v ON_ERROR_STOP=1 -d "$app" -c "CREATE EXTENSION IF NOT EXISTS vector;"; then
    echo "provision-apps: FAILED to enable pgvector extension for '$app'" >&2
    failures=$((failures + 1))
    continue
  fi

  echo "provision-apps: '$app' ready (role, database, pgvector extension)"
done

if [ "$failures" -gt 0 ]; then
  echo "provision-apps: completed with $failures failure(s)" >&2
  exit 1
fi

echo "provision-apps: all apps provisioned successfully"
exit 0
