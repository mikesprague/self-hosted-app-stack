# Environment Variable Conventions

All environment variables are defined in a single `.env` file at the workspace root. This file is loaded by the root `compose.yaml` `include:` block and made available to all app compose files via interpolation.

## File Structure

The `.env` file is organized into sections — one per app — using a consistent delimiter pattern:

```bash
### APP NAME ###
APP_VAR_ONE="value"
APP_VAR_TWO="value"
### END APP NAME ###
```

- Section headers use ALL CAPS app name matching the app's display name.
- All variable names are UPPERCASE with underscores.
- All values are quoted with double quotes (even numbers).
- Comments within a section use `#` prefix.
- Related vars within a section are grouped with an optional comment header (e.g., `# PostgreSQL`).

## Variable Naming Convention

All variables are prefixed with the app's namespace in SCREAMING_SNAKE_CASE:

```
APP_NAME_VAR_DESCRIPTION
```

### Standard Variable Patterns

| Purpose | Variable Name Pattern | Example |
|---------|----------------------|---------|
| Published port | `APP_PORT` | `OPEN_WEBUI_PORT=3000` |
| Admin/secondary port | `APP_ADMIN_PORT` | `HOPPSCOTCH_ADMIN_PORT=3100` |
| Secret/signing key | `APP_SECRET_KEY` | `OPEN_WEBUI_SECRET_KEY="..."` |
| Postgres DB name (on shared instance) | `APP_POSTGRES_DB` | `MEMOS_POSTGRES_DB="memos"` |
| Postgres username (on shared instance) | `APP_POSTGRES_USER` | `MEMOS_POSTGRES_USER="memos"` |
| Postgres password (on shared instance) | `APP_POSTGRES_PASSWORD` | `MEMOS_POSTGRES_PASSWORD="..."` |
| Postgres connection URL | `APP_DATABASE_URL` | `HOPPSCOTCH_DATABASE_URL="postgres://...@postgres-shared:5432/..."` |
| Admin email | `APP_ADMIN_EMAIL` | `OPEN_WEBUI_ADMIN_EMAIL="..."` |
| Admin password | `APP_ADMIN_PASSWORD` | `OPEN_WEBUI_ADMIN_PASSWORD="..."` |
| Admin username | `APP_ADMIN_USERNAME` | `YAADE_ADMIN_USERNAME="admin"` |
| Encryption key | `APP_ENCRYPTION_KEY` | `OPEN_NOTEBOOK_ENCRYPTION_KEY="..."` |
| Meilisearch master key | `APP_MEILI_MASTER_KEY` | `KARAKEEP_MEILI_MASTER_KEY="..."` |
| NextAuth secret | `APP_NEXTAUTH_SECRET` | `KARAKEEP_NEXTAUTH_SECRET="..."` |

> **Postgres vars define per-app credentials on the shared `postgres-shared` instance.** The connection hostname is always `postgres-shared`, never an app-specific container. These credentials must be provisioned in the shared instance before the app starts.

## Shared / Cross-App Variables

These variables are used by multiple apps and live in a `### SHARED ###` section:

| Variable | Purpose |
|----------|---------|
| `TZ` | Timezone (e.g., `America/New_York`) |
| `OLLAMA_BASE_URL` | Ollama API URL (`http://host.docker.internal:11434`) |
| `OLLAMA_API_KEY` | Ollama API key (if auth enabled) |
| `LM_STUDIO_OPENAI_API_URL` | LM Studio OpenAI-compat URL |
| `AZURE_OPENAI_API_KEY` | Azure Foundry API key |
| `AZURE_FOUNDRY_BASE_URL` | Azure Foundry base URL |
| `AZURE_FOUNDRY_OPENAI_BASE_URL` | Azure Foundry OpenAI-compat URL |
| `AZURE_OPENAI_API_VERSION` | Azure API version |
| `CONTEXT7_API_KEY` | Context7 MCP API key |
| `TDX_MCP_SERVER_URL` | TDX MCP Function App URL |
| `JINA_API_KEY` | Jina AI API key |
| `UNSPLASH_ACCESS_KEY` | Unsplash API key |

## Adding Variables for a New App

1. Open `.env`.
2. Add a new section at the end (before the `### SHARED ###` section):

```bash
### NEW APP ###
NEWAPP_PORT=8XXX
NEWAPP_SECRET_KEY="<generated-random-hex>"

# PostgreSQL (credentials on the shared postgres-shared instance)
NEWAPP_POSTGRES_DB="newapp"
NEWAPP_POSTGRES_USER="newapp"
NEWAPP_POSTGRES_PASSWORD="<strong-password>"
### END NEW APP ###
```

1. Reference these vars in the compose file using `${NEWAPP_PORT}`, `${NEWAPP_SECRET_KEY}`, etc.
2. The connection string in the compose file uses `postgres-shared` as the hostname:
   `DATABASE_URL: "postgresql://${NEWAPP_POSTGRES_USER}:${NEWAPP_POSTGRES_PASSWORD}@postgres-shared:5432/${NEWAPP_POSTGRES_DB}"`
3. Before starting the app, provision the database in `postgres-shared` via pgadmin or the maintenance script.

## Secret Generation

Generate secrets using:

```bash
# 32-byte hex secret (for signing keys, encryption keys)
openssl rand -hex 32

# 24-byte base64 secret
openssl rand -base64 32
```

## Variable Syntax in Compose Files

| Syntax | Meaning |
|--------|---------|
| `${VAR}` | Required, no default — will be empty string if unset |
| `${VAR:-default}` | Optional with default fallback |
| `${VAR:?missing}` | Required — Docker Compose will **fail with error** if unset |

Use `${VAR:?missing}` for secrets and required auth credentials to catch misconfiguration early.
Use `${VAR:-default}` for ports and optional feature flags.

## Example: Complete App .env Section

```bash
### FRESHRSS ###
FRESHRSS_ADMIN_EMAIL="user@example.com"
FRESHRSS_ADMIN_PASSWORD="<password>"
FRESHRSS_ADMIN_API_PASSWORD="<password>"
FRESHRSS_PUBLISHED_PORT=8353

# PostgreSQL (credentials on shared postgres-shared instance)
FRESHRSS_POSTGRES_DB="freshrss"
FRESHRSS_POSTGRES_USER="freshrss"
FRESHRSS_POSTGRES_PASSWORD="<password>"
### END FRESHRSS ###
```

FRESHRSS_POSTGRES_PASSWORD="<password>"

### END FRESHRSS ###

```
