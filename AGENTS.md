# Agent Notes

## Repo Shape

- This is a Docker Compose workspace, not an application codebase; there are no package manifests or test/build scripts.
- Root `compose.yaml` is the active source of truth: it defines the project name, shared network, `.env` loading, and the `include:` list for active per-app compose files.
- Per-app files live at `stack/<app>/compose.yaml`; data/config bind mounts live under `local-volumes/<app>/` and `local-volumes/` is gitignored.
- `.env` is gitignored and may contain real secrets. Use `.env.example` for tracked env changes; do not print `.env` or compose-expanded secrets.

## Commands

- Validate compose syntax/interpolation without dumping secrets: `docker compose config --quiet`.
- Start core database/admin first: `docker compose up -d postgres-shared dbgate`.
- Start or inspect one service: `docker compose up -d <service>`, `docker compose logs -f <service>`, `docker compose ps`.
- Refresh running images/containers: `docker compose pull && docker compose up -d`.

## Compose Conventions

- Individual `stack/<app>/compose.yaml` files do not set top-level `name:`, `networks:`, or `env_file:`; root `compose.yaml` handles those.
- Use `restart: unless-stopped` for persistent services; one-shot migration jobs may omit it or use upstream defaults.
- Host ports must be namespaced env vars with defaults, e.g. `${APP_PORT:-8372}:3000`, not hard-coded literals.
- Bind mounts from app compose files should be relative paths like `../../local-volumes/<app>/data:/container/path`.
- Service/container names usually match the app; sidecars are prefixed (`<app>-redis`, `<app>-valkey`, `<app>-meilisearch`, `<app>-chrome`).

## Shared Services

- Postgres-backed apps use the single `postgres-shared` service. Do not add per-app Postgres sidecars.
- Role/database/pgvector provisioning is automated by the `postgres-shared-provision` one-shot service (`stack/postgres-shared/compose.yaml`) running `stack/postgres-shared/scripts/provision-apps.sh` on every `docker compose up`. It is idempotent and driven entirely by the manually maintained `POSTGRES_SHARED_PROVISION_APPS` list in `.env` -- it does not infer or discover app names.
- New Postgres apps need `APP_POSTGRES_DB`, `APP_POSTGRES_USER`, and `APP_POSTGRES_PASSWORD` in `.env.example`, their DB identifier added to `POSTGRES_SHARED_PROVISION_APPS`, and `postgres-shared-provision: condition: service_completed_successfully` added to the app's own `depends_on`. No manual `psql`/DBGate step is needed.
- DBGate is the browser UI for `postgres-shared` at the `dbgate` service / `DBGATE_PORT`.
- Mailpit is the local SMTP sink; internal SMTP host is `mailpit` with `MAILPIT_SMTP_PORT`.
- Host-machine model servers use `host.docker.internal` (`OLLAMA_BASE_URL`, `LM_STUDIO_OPENAI_API_URL`).
- Homepage, Dockpeek, Dozzle, Portainer, Uptime Kuma, and Beszel-related services may mount `/var/run/docker.sock`; treat those as privileged.

## When Adding Or Updating Apps

- Check root `compose.yaml` first: a `stack/<app>/compose.yaml` may exist but be inactive if its include line is commented out or absent.
- Verify current upstream image tags/docs before changing service images; do not rely on stale memory.
- Add new app compose files under `stack/<app>/compose.yaml`, register them in root `compose.yaml`, and add tracked env defaults/secrets placeholders to `.env.example`.
- Run `docker compose config --quiet` after compose/env edits.
- There is a repo-local stack skill at `.claude/skills/self-hosted-app-expert/` with detailed patterns, but its inventory can lag; trust live `compose.yaml`, `stack/*/compose.yaml`, and `.env.example` over prose.

## Formatting

- Follow `.editorConfig`: UTF-8, LF, final newline, trim trailing whitespace, 2-space indentation.
