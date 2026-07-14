<!-- markdownlint-disable MD060 -->

# Compose File Conventions & Patterns

These are conventions for new work. Existing compose files have intentional exceptions; verify live files before normalizing anything.

## File Location & Structure

```text
stack/
└── <app-name>/
    └── compose.yaml
```

- Individual app compose files live at `stack/<app-name>/compose.yaml`.
- Root `compose.yaml` defines the project name, shared network, include list, include-level `.env` loading, and include-level `extra_hosts`.
- Do not add top-level `networks:` or `env_file:` in individual app compose files.
- Do not add top-level `name:` in new app files. Existing exception: `stack/open-design/compose.yaml`.

## Source Of Truth

- Root `compose.yaml` decides active vs inactive.
- `stack/*/compose.yaml` decides current app config.
- README, `.env.example`, `.env`, and these reference docs can be stale. Use them only after checking compose files.
- Do not print `.env`; it may contain real secrets and is also known to have stale values.

## Volume Paths

Use bind mounts relative to the app compose file:

```yaml
volumes:
  - ../../local-volumes/<app-name>/<subdir>:/container/path
```

Common paths:

| Purpose | Path |
|---------|------|
| App data | `local-volumes/<app>/data` |
| App config | `local-volumes/<app>/config` |
| Redis/Valkey data | `local-volumes/<app>/redis` or `local-volumes/<app>/valkey` |
| Search/vector data | `local-volumes/<app>/meilisearch`, `local-volumes/<app>/cache/qdrant` |
| Storage/uploads | `local-volumes/<app>/storage` |

Shared Postgres data lives under `local-volumes/postgres-shared/postgresql`.

## Service Naming

- Service and primary `container_name` usually match the stack directory or app name.
- Sidecars should be prefixed with the app name, such as `<app>-redis`, `<app>-valkey`, `<app>-meilisearch`, `<app>-chrome`, or `<app>-qdrant`.
- Known upstream-specific names exist, such as `karakeep-web`, `blinko-web`, `hbbr`, and `hbbs`.
- Do not add `<app>-postgres` sidecars. New Postgres apps use `postgres-shared` unless upstream truly cannot.

## Restart Policy

Persistent services should use:

```yaml
restart: unless-stopped
```

One-shot migration jobs may omit it or use the upstream recommendation.

## Shared Postgres Pattern

All Postgres-backed apps should use the shared `postgres-shared` service.

```yaml
depends_on:
  postgres-shared:
    condition: service_healthy
environment:
  DATABASE_URL: "postgresql://${APP_POSTGRES_USER}:${APP_POSTGRES_PASSWORD}@postgres-shared:5432/${APP_POSTGRES_DB}"
```

Before first start, create the role/database in `postgres-shared`:

```sql
CREATE ROLE appname WITH LOGIN PASSWORD 'replace-with-your-password';
CREATE DATABASE appname OWNER appname;
```

Only add `CREATE EXTENSION IF NOT EXISTS vector;` when the app needs pgvector.

Known exceptions:

- Nextcloud uses app-specific MariaDB + Redis sidecars.
- Open Notebook uses SurrealDB.
- Bifrost uses Qdrant.

## Environment Variables

- Root `compose.yaml` loads `.env` through the include block.
- Required secrets should use `${VAR:?missing}` when practical.
- Optional values should use `${VAR:-default}`.
- Published host ports should use namespaced env vars in new work.
- Choose ports from live inventory and compose files. There is no reliable sequential next-port rule anymore.

Example:

```yaml
ports:
  - "${APP_PORT:-1234}:3000"
```

## Healthchecks

Use healthchecks when the image exposes a stable readiness signal.

Postgres:

```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "${POSTGRES_SHARED_SUPERUSER}", "-d", "${POSTGRES_SHARED_DEFAULT_DB}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Redis:

```yaml
healthcheck:
  test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Valkey:

```yaml
healthcheck:
  test: ["CMD", "valkey-cli", "ping"]
  interval: 10s
  timeout: 3s
  retries: 5
  start_period: 5s
```

HTTP app:

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## Resource Limits

Many current services use memory limits:

```yaml
deploy:
  resources:
    limits:
      memory: 1024M
```

For new work, add a simple memory limit when the app is known to be heavy. Skip speculative CPU/pids tuning unless upstream or local behavior requires it.

## Host Services And Host Networking

Root compose provides:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

Use host-service URLs such as:

```yaml
environment:
  OLLAMA_BASE_URL: "${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"
```

Known host-network exceptions:

- `open-design` uses `network_mode: host` and `ports: []`.
- `beszel-agent` uses `network_mode: host`.

Do not add host networking to new apps unless bridge networking cannot satisfy the app.

## Sidecars

Current sidecar patterns:

| App | Sidecars |
|-----|----------|
| activepieces | Redis |
| bifrost | Qdrant |
| degoog | Valkey |
| karakeep | Chrome, Meilisearch |
| nextcloud | MariaDB, Redis |
| open-notebook | SurrealDB |
| paperless-ngx inactive | Redis, Gotenberg, Tika, paperless-gpt |
| searxng | Valkey |

Some existing sidecars publish fixed host ports, such as Karakeep Chrome `9222`, Karakeep Meilisearch `7700`, and Open Notebook SurrealDB `8000`. Prefer env-var host ports for new public mappings unless an upstream tool expects a fixed local port.

## Multi-Port Apps

Use one env var per published host port:

```yaml
ports:
  - "${APP_PORT:-1234}:3000"
  - "${APP_ADMIN_PORT:-1235}:3100"
  - "${APP_API_PORT:-1236}:3170"
```

Current examples include Hoppscotch, Hindsight, Mailpit, Portainer, Bifrost/Qdrant, and Open Notebook.

## Docker Socket Access

Treat Docker socket mounts as privileged local-management access.

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

Current users include Homepage, Dockpeek, Dozzle, Portainer, Uptime Kuma, and Beszel agent.

## Registering In Root Compose

After creating `stack/<app-name>/compose.yaml`, add it to root `compose.yaml` under the nearest category.

Do not update README or `.env.example` unless that is explicitly in scope.

## Image Tag Guidance

| Pattern | When to use |
|---------|-------------|
| `:stable` or `:release` | Preferred when upstream publishes and recommends it |
| `:<version>` | Good default for stable local services |
| `:latest` | Acceptable only when upstream recommends it or no stable tag exists |
| `:main` / prerelease | Use only when the stack intentionally tracks that upstream channel |

Always verify tags against current upstream docs before editing compose files.

## Minimal New App Pattern

```yaml
services:
  myapp:
    image: registry/myapp:stable
    container_name: myapp
    restart: unless-stopped
    ports:
      - "${MYAPP_PORT:-1234}:8080"
    environment:
      SECRET_KEY: "${MYAPP_SECRET_KEY:?missing}"
    volumes:
      - ../../local-volumes/myapp/data:/app/data
    deploy:
      resources:
        limits:
          memory: 512M
```
