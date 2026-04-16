# Compose File Conventions & Patterns

These are the established patterns used throughout this stack. All new compose files and modifications to existing ones must follow these conventions.

## File Location & Structure

```
stack/
└── <app-name>/
    └── compose.yaml
```

- Individual compose files live at `stack/<app-name>/compose.yaml`.
- **No top-level `name:` field** in individual compose files (only the root `compose.yaml` has the project name).
- **No top-level `networks:` block** in individual compose files — the shared `default` network is inherited from the root project automatically.
- **No top-level `volumes:` block** — use only bind mounts to `../../local-volumes/`.

## Volume Paths

All data volumes use bind mounts with paths **relative to the app's compose file location**:

```yaml
volumes:
  - ../../local-volumes/<app-name>/<subdir>:/container/path
```

Examples:

```yaml
- ../../local-volumes/memos/data:/var/opt/memos
- ../../local-volumes/memos/postgresql/data:/var/lib/postgresql/data
- ../../local-volumes/searxng/valkey:/data/
- ../../local-volumes/homepage/config:/app/config
```

Standard subdirectory conventions:

| Purpose | Path |
|---------|------|
| App data | `local-volumes/<app>/data` |
| App config | `local-volumes/<app>/config` |
| Meilisearch data | `local-volumes/<app>/meilisearch` |
| Redis/Valkey data | `local-volumes/<app>/valkey` |
| Storage/uploads | `local-volumes/<app>/storage` |

> **Note:** Per-app `postgresql/data` bind mount subdirectories are **not used**. All Postgres data lives in `local-volumes/postgres-shared/postgresql/data`.

## Service Naming

- Service name and `container_name` should always **match** (e.g., service `memos`, container_name `memos`).
- For per-app sidecar services (Valkey, Meilisearch, headless browser), prefix with the app name:
  - Valkey/Redis: `<app-name>-valkey`
  - Meilisearch: `<app-name>-meilisearch`
  - Headless Chrome: `<app-name>-chrome`
- **There is no `<app-name>-postgres` service.** All Postgres is handled by the shared `postgres-shared` service.

## Restart Policy

All persistent services must have:

```yaml
restart: unless-stopped
```

Exception: one-shot/maintenance services use `restart: "no"`.

## Postgres Pattern

All apps share a single `postgres-shared` Postgres instance (`pgvector/pgvector:pg17`). There are **no per-app Postgres sidecar containers**.

Each app has its own database and credentials provisioned within `postgres-shared`. These must be created before starting the app (via pgadmin or the maintenance script in `stack/postgres-shared/`).

To connect an app to Postgres:

```yaml
services:
  <app>:
    image: ...
    depends_on:
      postgres-shared:
        condition: service_healthy   # Wait for the shared instance to be ready
    environment:
      DATABASE_URL: "postgresql://${APP_POSTGRES_USER}:${APP_POSTGRES_PASSWORD}@postgres-shared:5432/${APP_POSTGRES_DB}"
```

The hostname is always `postgres-shared` (the container name / service name of the shared instance).

### Provisioning a New Database

Before a new app can start, its database and user must exist in `postgres-shared`. Use pgadmin (port 5050) or run SQL against the shared instance:

```sql
CREATE USER appuser WITH PASSWORD 'apppassword';
CREATE DATABASE appdb OWNER appuser;
\c appdb
CREATE EXTENSION IF NOT EXISTS vector;
```

Alternatively, add the app's credentials to the `POSTGRES_APP_DEFINITIONS` env var format used by the maintenance service (check `stack/postgres-shared/compose.yaml` and `local-volumes/postgres-shared/scripts/` for the current provisioning approach).

## Environment Variables

- All env vars use `${VAR_NAME}` interpolation from the root `.env` file.
- Required vars (must be set, fail hard if missing): `${VAR:?missing}`
- Optional vars with default: `${VAR:-default_value}`
- The host-side port **must always** be a namespaced env var — never a hard-coded number in the compose file.
- The env var must always include a sensible sequential default (see Ports Quick Reference in `stack-inventory.md` for next available).
- Pick port numbers sequentially from the current highest app port to avoid conflicts.

```yaml
ports:
  - "${APP_PORT:-8370}:3000"           # host port via namespaced env var with sequential default
  - "${APP_ADMIN_PORT:-8371}:3100"     # additional ports for multi-port apps, also namespaced
```

## Healthchecks

Include healthchecks on supporting services (Postgres, Valkey) **and** on the main app service where the app provides a health endpoint.

Postgres:

```yaml
healthcheck:
  test: ["CMD", "pg_isready", "-U", "${APP_POSTGRES_USER}", "-d", "${APP_POSTGRES_DB}"]
  interval: 10s
  timeout: 5s
  retries: 5
```

Valkey/Redis:

```yaml
healthcheck:
  test: ["CMD", "valkey-cli", "ping"]
  interval: 10s
  timeout: 3s
  retries: 5
  start_period: 5s
```

HTTP app (wget approach):

```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "--quiet", "http://localhost:<port>/healthz"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 15s
```

HTTP app (curl approach):

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:<port>/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## Accessing Host Services (Ollama, LM Studio)

When a service needs to reach Ollama or LM Studio on the host:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
environment:
  OLLAMA_BASE_URL: "${OLLAMA_BASE_URL:-http://host.docker.internal:11434}"
```

## Valkey Pattern (Redis Alternative)

Used by SearXNG. Prefer Valkey over Redis for new additions:

```yaml
<app>-valkey:
  image: valkey/valkey:9-alpine
  container_name: <app>-valkey
  command: valkey-server --save 30 1 --loglevel warning
  restart: unless-stopped
  volumes:
    - ../../local-volumes/<app>/valkey:/data/
  healthcheck:
    test: ["CMD", "valkey-cli", "ping"]
    interval: 10s
    timeout: 3s
    retries: 5
    start_period: 5s
```

## Meilisearch Pattern

Used by Karakeep:

```yaml
<app>-meilisearch:
  image: getmeili/meilisearch:latest
  container_name: <app>-meilisearch
  restart: unless-stopped
  environment:
    MEILI_NO_ANALYTICS: "true"
    MEILI_MASTER_KEY: ${APP_MEILI_MASTER_KEY:?missing}
  volumes:
    - ../../local-volumes/<app>/meilisearch:/meili_data
```

## Multi-Port App (Hoppscotch Pattern)

For apps with separate frontend / API / admin ports:

```yaml
ports:
  - "${APP_PORT}:3000"              # Web UI
  - "${APP_ADMIN_PORT}:3100"        # Admin panel
  - "${APP_API_PORT}:3170"          # Backend API
```

## Docker Socket Access

For management/dashboard apps that need Docker metadata (homepage, dozzle, portainer):

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

## Read-Only Mounts

For config files that should not be modified by the container:

```yaml
volumes:
  - ../../local-volumes/<app>/scripts:/scripts:ro
```

## Registering in Root compose.yaml

After creating `stack/<app-name>/compose.yaml`, add to the `include:` block in the root `compose.yaml` under the appropriate category comment:

```yaml
include:
  - path:
      # Category Name
      - ./stack/<app-name>/compose.yaml
```

The `env_file` entry in the include block is already set at the root level — do **not** add `env_file` in individual compose files.

## Image Tag Best Practices

| Pattern | When to use |
|---------|------------|
| `:stable` or `:release` | Preferred when the project explicitly publishes a stable channel |
| `:latest` | Only if the project uses it as their recommended production tag |
| `:<version>` | When pinning to a specific version for stability |
| `:main` | Only for apps like open-webui that recommend tracking the main branch |

Always verify the current recommended tag via the project's Docker Hub page or documentation — never assume `:latest` is always available or recommended.

## Security Notes (Local-Only Stack)

- Passwords in `.env` are acceptable for a local-only stack, but use unique strong passwords.
- Never expose ports on non-localhost interfaces unless intentional (the default Docker bind `0.0.0.0:port` is fine since this is local-only).
- Use `POSTGRES_INITDB_ARGS: '--data-checksums'` for data integrity.
- Secret keys should be randomly generated hex/base64 strings, not dictionary words.

## Annotated Complete Example

A complete, correct compose file for a typical app using the shared Postgres instance:

```yaml
services:
  myapp:
    image: registry/myapp:stable
    container_name: myapp
    restart: unless-stopped
    depends_on:
      postgres-shared:
        condition: service_healthy
    ports:
      - "${MYAPP_PORT:-8370}:8080"
      test: ["CMD-SHELL", "wget --spider --quiet http://localhost:8080/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    volumes:
      - ../../local-volumes/myapp/data:/app/data
```

For apps that also need a Valkey sidecar:

```yaml
services:
  myapp-valkey:
    image: valkey/valkey:9-alpine
    container_name: myapp-valkey
    command: valkey-server --save 30 1 --loglevel warning
    restart: unless-stopped
    volumes:
      - ../../local-volumes/myapp/valkey:/data/
    healthcheck:
      test: ["CMD", "valkey-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 5s

  myapp:
    image: registry/myapp:stable
    container_name: myapp
    restart: unless-stopped
    depends_on:
      postgres-shared:
        condition: service_healthy
      myapp-valkey:
        condition: service_healthy
    ports:
      - "${MYAPP_PORT:-8370}:8080"
    environment:
      DATABASE_URL: "postgresql://${MYAPP_POSTGRES_USER}:${MYAPP_POSTGRES_PASSWORD}@postgres-shared:5432/${MYAPP_POSTGRES_DB}"
      REDIS_URL: "redis://myapp-valkey:6379"
      SECRET_KEY: "${MYAPP_SECRET_KEY}"
    volumes:
      - ../../local-volumes/myapp/data:/app/data
```
