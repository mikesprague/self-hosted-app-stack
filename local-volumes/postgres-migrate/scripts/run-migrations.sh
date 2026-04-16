#!/bin/sh
# ../../local-volumes/postgres-migrate/migrate.sh
set -euo pipefail

echo "🚚 Starting Postgres migration job..."

POSTGRES_SHARED_HOST="${POSTGRES_SHARED_HOST:-postgres-shared}"
POSTGRES_SHARED_PORT="${POSTGRES_SHARED_PORT:-5432}"
POSTGRES_SHARED_SUPERUSER="${POSTGRES_SHARED_SUPERUSER}"
POSTGRES_SHARED_SUPERUSER_PASSWORD="${POSTGRES_SHARED_SUPERUSER_PASSWORD}"
PG_MIGRATIONS="${PG_MIGRATIONS}"

if [ -z "$PG_MIGRATIONS" ]; then
  echo "❌ No migrations defined in PG_MIGRATIONS env var."
  exit 1
fi

# Wait for shared Postgres
echo "⏳ Waiting for postgres-shared..."
until PGPASSWORD="$POSTGRES_SHARED_SUPERUSER_PASSWORD" psql -h "$POSTGRES_SHARED_HOST" -p "$POSTGRES_SHARED_PORT" -U "$POSTGRES_SHARED_SUPERUSER" -d postgres -c "SELECT 1;" >/dev/null 2>&1; do
  echo "⏳ postgres-shared not ready, retrying in 2s..."
  sleep 2
done

echo "✅ postgres-shared ready."

# Migration loop: format is old_container:old_db:new_db
IFS=';'
for migration in $PG_MIGRATIONS; do
  IFS=':' read -r old_container old_db new_db <<< "$migration"
  [ -z "$old_container" ] || [ -z "$old_db" ] || [ -z "$new_db" ] && continue

  echo "🔄 Migrating $old_db from $old_container → $new_db in postgres-shared..."

  # Create target database if missing
  PGPASSWORD="$POSTGRES_SHARED_SUPERUSER_PASSWORD" psql -h "$POSTGRES_SHARED_HOST" -p "$POSTGRES_SHARED_PORT" -U "$POSTGRES_SHARED_SUPERUSER" -d postgres -c "
    SELECT 'CREATE DATABASE $new_db OWNER postgres_shared_app'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$new_db')
  " | PGPASSWORD="$POSTGRES_SHARED_SUPERUSER_PASSWORD" psql -h "$POSTGRES_SHARED_HOST" -p "$POSTGRES_SHARED_PORT" -U "$POSTGRES_SHARED_SUPERUSER" -d postgres

  # Dump from old container and restore to new
  docker exec "$old_container" pg_dump -U postgres -d "$old_db" --no-owner --no-acl | \
    PGPASSWORD="$POSTGRES_SHARED_SUPERUSER_PASSWORD" psql -h "$POSTGRES_SHARED_HOST" -p "$POSTGRES_SHARED_PORT" -U "$POSTGRES_SHARED_SUPERUSER" -d "$new_db"

  echo "✅ Completed migration: $old_db → $new_db"
done

echo "🎉 All migrations complete."
