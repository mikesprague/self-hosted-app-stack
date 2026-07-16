<!-- markdownlint-disable MD060 -->

# Environment Variable Conventions

Root `compose.yaml` loads `.env` for interpolation across included app compose files. `.env` may contain secrets and stale values; do not print it, and do not treat it as more authoritative than compose files.

## File Structure

The local `.env` has historically used section delimiters like this:

```bash
### APP NAME ###
APP_VAR_ONE="value"
APP_VAR_TWO="value"
### END APP NAME ###
```

- Section headers use all-caps display names.
- Variable names use upper snake case.
- String values are usually quoted.
- Numeric and boolean values may be unquoted when existing nearby usage does that.
- Keep app-specific values under an app-specific prefix.

## Variable Naming

Use the app namespace in screaming snake case:

```text
APP_NAME_VAR_DESCRIPTION
```

Common patterns:

| Purpose | Variable pattern | Example |
|---------|------------------|---------|
| Published port | `APP_PORT` | `OPEN_WEBUI_PORT` |
| Secondary/admin/API port | `APP_ADMIN_PORT`, `APP_API_PORT` | `HOPPSCOTCH_ADMIN_PORT` |
| Secret/signing key | `APP_SECRET_KEY` | `OPEN_WEBUI_SECRET_KEY` |
| Postgres database | `APP_POSTGRES_DB` or upstream-specific equivalent | `MEMOS_POSTGRES_DB` |
| Postgres username | `APP_POSTGRES_USER` or upstream-specific equivalent | `MEMOS_POSTGRES_USER` |
| Postgres password | `APP_POSTGRES_PASSWORD` or upstream-specific equivalent | `MEMOS_POSTGRES_PASSWORD` |
| Admin email | `APP_ADMIN_EMAIL` | `FRESHRSS_ADMIN_EMAIL` |
| Admin password | `APP_ADMIN_PASSWORD` | `FRESHRSS_ADMIN_PASSWORD` |
| Encryption key | `APP_ENCRYPTION_KEY` | `ACTIVEPIECES_ENCRYPTION_KEY` |
| Meilisearch master key | `APP_MEILI_MASTER_KEY` | `KARAKEEP_MEILI_MASTER_KEY` |

Postgres vars define credentials for a database in shared `postgres-shared`; the compose hostname is normally `postgres-shared` or `${POSTGRES_SHARED_HOST}`.

## Shared Variables

Common shared or cross-app variables in live compose include:

| Variable | Purpose |
|----------|---------|
| `TZ` | Timezone |
| `TAILNET_IP_ADDRESS` | Local/Tailnet URL construction |
| `TAILNET_DOMAIN` | Apps that need an absolute Tailnet domain |
| `POSTGRES_SHARED_HOST` | Shared Postgres hostname |
| `POSTGRES_SHARED_PORT` | Shared Postgres port |
| `POSTGRES_SHARED_SUPERUSER` | Shared Postgres bootstrap/admin user |
| `POSTGRES_SHARED_SUPERUSER_PASSWORD` | Shared Postgres bootstrap/admin password |
| `POSTGRES_SHARED_DEFAULT_DB` | Shared Postgres bootstrap database |
| `MAILPIT_SMTP_HOST` | Internal SMTP host, usually `mailpit` |
| `MAILPIT_SMTP_PORT` | Internal SMTP port, usually `1025` |
| `OLLAMA_BASE_URL` | Ollama API URL |
| `OLLAMA_API_KEY` | Ollama API key if enabled |
| `LM_STUDIO_OPENAI_API_URL` | LM Studio OpenAI-compatible URL |
| `BIFROST_API_KEY` | Shared Bifrost API key |
| `BIFROST_OPENAI_API_URL` | Bifrost OpenAI-compatible URL |
| `BIFROST_LITELLM_API_URL` | Bifrost LiteLLM-compatible URL for apps expecting that shape |
| `AZURE_FOUNDRY_BASE_URL` | Azure Foundry base URL |
| `AZURE_FOUNDRY_OPENAI_BASE_URL` | Azure OpenAI-compatible URL |
| `AZURE_FOUNDRY_API_KEY` | Azure Foundry API key |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI-compatible key |
| `SEARXNG_BASE_URL` | SearXNG URL for apps that call search |
| `CONTEXT7_API_KEY` | Context7 MCP API key |
| `JINA_API_KEY` | Jina AI API key |

## Adding Variables For A New App

Only update env files when env work is in scope. Prefer tracked placeholders in `.env.example`; put real secrets only in local `.env`.

Example placeholder block:

```bash
### NEW APP ###
NEWAPP_PORT=<available-port>
NEWAPP_SECRET_KEY="<generated-secret>"

# PostgreSQL credentials on shared postgres-shared instance
NEWAPP_POSTGRES_DB="newapp"
NEWAPP_POSTGRES_USER="newapp"
NEWAPP_POSTGRES_PASSWORD="<strong-password>"
### END NEW APP ###
```

Reference these vars from compose with `${NEWAPP_PORT}`, `${NEWAPP_SECRET_KEY}`, etc.

For Postgres apps, a typical connection string is:

```text
postgresql://${NEWAPP_POSTGRES_USER}:${NEWAPP_POSTGRES_PASSWORD}@postgres-shared:5432/${NEWAPP_POSTGRES_DB}
```

Create the role and database in `postgres-shared` before first app start:

```sql
CREATE ROLE newapp WITH LOGIN PASSWORD 'replace-with-your-password';
CREATE DATABASE newapp OWNER newapp;
```

Add `CREATE EXTENSION IF NOT EXISTS vector;` only when the app needs pgvector.

## Secret Generation

Generate secrets locally:

```bash
# 32-byte hex secret
openssl rand -hex 32

# 32-byte base64 secret
openssl rand -base64 32
```

## Compose Interpolation Syntax

| Syntax | Meaning |
|--------|---------|
| `${VAR}` | Required by convention, but may resolve empty if unset depending on Compose behavior |
| `${VAR:-default}` | Optional with default fallback |
| `${VAR:?missing}` | Required and fails fast if unset |

Use `${VAR:?missing}` for required secrets and auth credentials when practical. Use `${VAR:-default}` for optional toggles and local development defaults.
