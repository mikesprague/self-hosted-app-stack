# Self-Hosted App Stack

An opinionated Docker Compose workspace for running a local, single-user collection of AI tools, databases, personal cloud services, knowledge tools, automation, monitoring, and utilities.

The root [`compose.yaml`](compose.yaml) is the source of truth for which apps are active. Each app owns a compose file under [`stack/`](stack/), while persistent data and local configuration live under the gitignored `local-volumes/` directory.

## How It Fits Together

```text
compose.yaml                    Active app includes, shared network, env loading
stack/<app>/compose.yaml        One compose file per app
local-volumes/<app>/            Persistent data and local configuration (gitignored)
.env                            Local ports, credentials, and secrets (gitignored)
```

- All included services share the Compose default network unless an app intentionally uses host networking.
- Postgres-backed apps generally use the shared `postgres-shared` service and separate per-app roles and databases.
- App-specific dependencies such as Redis, Valkey, Qdrant, Meilisearch, Chrome, SurrealDB, and MariaDB remain sidecars.
- Bifrost provides the shared OpenAI-compatible LLM gateway used by several AI-enabled apps.
- Ollama and LM Studio run on the host and are reached from containers through `host.docker.internal`.
- Mailpit provides the local SMTP sink, while DBGate provides browser-based access to shared Postgres.

## Quick Start

### Prerequisites

- Docker Desktop, OrbStack, or another runtime with strong Docker Compose compatibility
- Enough disk and memory for the apps you enable
- Ollama or LM Studio only if you want host-based local models

This stack assumes Docker-oriented features such as `host-gateway` and Docker socket mounts. Docker Desktop and OrbStack are the expected paths.

> [!IMPORTANT]
> `.env.example` and existing local `.env` files are scheduled for a separate cleanup and may contain stale entries. Use `.env.example` only as a starting point, verify required variables against the active files under `stack/`, and never commit `.env`.

From the repository root:

```sh
cp .env.example .env

# Edit .env, then validate interpolation without printing expanded secrets.
docker compose config --quiet

# Start shared database infrastructure first.
docker compose up -d postgres-shared dbgate
```

Before starting a Postgres-backed app for the first time, create its role and database as described in [Shared Postgres](#shared-postgres). Then start selected services:

```sh
docker compose up -d homepage open-webui
```

Or start every service currently included by root compose:

```sh
docker compose pull
docker compose up -d
```

## Active Apps

Only uncommented entries in [`compose.yaml`](compose.yaml) are active. Links below open the app's compose definition, where its current image, ports, dependencies, volumes, and environment variables are defined.

### Data And Personal Cloud

| App | Purpose and dependencies |
| --- | --- |
| [Databasus](stack/databasus/compose.yaml) | Scheduled database backups; connects to shared Postgres and Mailpit |
| [DBGate](stack/dbgate/compose.yaml) | Browser database manager preconfigured for shared Postgres |
| [DBX](stack/dbx/compose.yaml) | Lightweight multi-database client |
| [Postgres Shared](stack/postgres-shared/compose.yaml) | Shared PostgreSQL 18 instance with pgvector |
| [Nextcloud](stack/nextcloud/compose.yaml) | Personal cloud and file sync; uses dedicated MariaDB and Redis sidecars |

### AI And LLM

| App | Purpose and dependencies |
| --- | --- |
| [Atlassian MCP](stack/atlassian-mcp/compose.yaml) | MCP server for Atlassian services |
| [AnythingLLM](stack/anythingllm/compose.yaml) | LLM workspace using Bifrost, SearXNG, and shared pgvector |
| [Bifrost](stack/bifrost/compose.yaml) | Shared LLM gateway with a Qdrant sidecar |
| [Crawl4AI](stack/crawl4ai/compose.yaml) | Web crawling and extraction API using Bifrost |
| [Headroom](stack/headroom/compose.yaml) | Compresses agent context and tool output before forwarding it to an LLM |
| [Hindsight](stack/hindsight/compose.yaml) | Agent memory service using Headroom and embedded Postgres |
| [Open Design](stack/open-design/compose.yaml) | Local-first design workspace for coding agents; uses host networking |
| [Open Notebook](stack/open-notebook/compose.yaml) | AI research notebook using SurrealDB and Bifrost |
| [Obscura MCP](stack/obscura-mcp/compose.yaml) | MCP server for Obscura (headless browser for AI agents and web scraping) |
| [Open WebUI](stack/open-webui/compose.yaml) | Main chat UI using shared pgvector, Bifrost, Ollama, SearXNG, and MCP integrations |
| [Phoenix](stack/phoenix/compose.yaml) | LLM tracing and observability using shared Postgres, Ollama, and an MCP server |

Additional notes about how I utilize some of these services with [OpenCode](https://github.com/anomalyco/opencode) available here: <https://gist.github.com/mikesprague/08b52562e70e1bbcc1ce22c01c9c7a2f>

### Search

| App | Purpose and dependencies |
| --- | --- |
| [DeGoog](stack/degoog/compose.yaml) | Private search aggregator with a Valkey sidecar |
| [Hister](stack/hister/compose.yaml) | Self-hosted full-text search for visited web content |
| [SearXNG](stack/searxng/compose.yaml) | Private metasearch engine with a Valkey sidecar |
| [Vane](stack/vane/compose.yaml) | Privacy-focused AI answering engine using SearXNG |

### PKM And Productivity

| App | Purpose and dependencies |
| --- | --- |
| [Karakeep](stack/karakeep/compose.yaml) | Bookmark and read-later manager using Chrome, Meilisearch, and Bifrost |
| [Mealie](stack/mealie/compose.yaml) | Recipe manager with Postgres, Mailpit, and Bifrost integrations |
| [Memos](stack/memos/compose.yaml) | Lightweight notes and journaling on shared Postgres |
| [Trilium Notes](stack/trilium-notes/compose.yaml) | Hierarchical personal knowledge base |
| [FreshRSS](stack/freshrss/compose.yaml) | RSS and Atom feed reader using shared Postgres |
| [Super Productivity](stack/super-productivity/compose.yaml) | Tasks, time tracking, and focus tools with Nextcloud WebDAV sync |
| [Vaultwarden](stack/vaultwarden/compose.yaml) | Lightweight Bitwarden-compatible password server |

### Automation And Development

| App | Purpose and dependencies |
| --- | --- |
| [n8n](stack/n8n/compose.yaml) | Workflow automation using shared Postgres, Bifrost, and a Qdrant sidecar |
| [Hoppscotch](stack/hoppscotch/compose.yaml) | API development suite using shared Postgres and Mailpit |

### Monitoring And Operations

| App | Purpose and dependencies |
| --- | --- |
| [Dockpeek](stack/dockpeek/compose.yaml) | Lightweight Docker dashboard |
| [Dozzle](stack/dozzle/compose.yaml) | Live Docker log viewer |
| [Portainer](stack/portainer/compose.yaml) | Docker management UI |
| [Uptime Kuma](stack/uptime-kuma/compose.yaml) | Service uptime and availability monitoring |
| [Mailpit](stack/mailpit/compose.yaml) | Local SMTP sink and inbox viewer |
| [Homepage](stack/homepage/compose.yaml) | Stack dashboard and start page |

### Utilities

| App | Purpose and dependencies |
| --- | --- |
| [IT-Tools](stack/it-tools/compose.yaml) | Browser-based developer and system utilities |
| [OmniTools](stack/omni-tools/compose.yaml) | Browser-based file, text, and media utilities |
| [ntfy](stack/ntfy/compose.yaml) | Push notification service |
| [Vert](stack/vert/compose.yaml) | Browser-based file conversion |

Additional compose files may exist under `stack/` without being active. Commented and absent root includes are intentionally excluded from this list.

## Key Endpoints

These are the compose defaults for the services you are most likely to open first. Values in `.env` may override them.

| Service | Default endpoint |
| --- | --- |
| Homepage | <http://localhost:8349> |
| DBGate | <http://localhost:8370> |
| Open WebUI | <http://localhost:3000> |
| Phoenix | <http://localhost:6006> |
| Mailpit UI | <http://localhost:8371> |
| Mailpit SMTP | `smtp://localhost:1025` |
| Dozzle | <http://localhost:8357> |
| Portainer | <http://localhost:8358> |
| Uptime Kuma | <http://localhost:8356> |

Check the relevant app compose file for every other default port. Homepage configuration belongs under `local-volumes/homepage/config/` and is intentionally not tracked.

## Common Operations

```sh
# Inspect status and logs.
docker compose ps
docker compose logs -f <service>

# Start, stop, or restart one service and its dependencies.
docker compose up -d <service>
docker compose stop <service>
docker compose restart <service>

# Refresh images and running containers.
docker compose pull
docker compose up -d

# Stop the stack without deleting persistent bind-mounted data.
docker compose down
```

Validate compose syntax and environment interpolation after any compose or env edit:

```sh
docker compose config --quiet
```

Avoid sharing the expanded output of `docker compose config`; it may contain secrets.

## Shared Postgres

The stack uses one `postgres-shared` service instead of a Postgres sidecar for each app. Every application gets its own role and database.

Role, database, and pgvector extension creation is automated by the `postgres-shared-provision` service defined alongside `postgres-shared` in [`stack/postgres-shared/compose.yaml`](stack/postgres-shared/compose.yaml). It runs [`stack/postgres-shared/scripts/provision-apps.sh`](stack/postgres-shared/scripts/provision-apps.sh) as a one-shot job on every `docker compose up`, reading the manually maintained `POSTGRES_SHARED_PROVISION_APPS` list in `.env` and, for each app identifier in that list:

- Creates its role if missing, and re-syncs the password from `POSTGRES_SHARED_APP_PASSWORD` on every run.
- Creates its database if missing, owned by the same-named role.
- Runs `CREATE EXTENSION IF NOT EXISTS vector;` on it unconditionally (harmless no-op for apps that don't use pgvector).

It's idempotent and safe to rerun; only genuine failures (bad credentials, unreachable database, invalid identifier) cause a non-zero exit, which blocks any app that `depends_on: postgres-shared-provision: condition: service_completed_successfully`.

To add a future Postgres-backed app:

1. Add its DB identifier to the comma-separated `POSTGRES_SHARED_PROVISION_APPS` list in `.env`.
2. Add `postgres-shared-provision: condition: service_completed_successfully` to the app's own `depends_on` block.
3. `docker compose up -d postgres-shared postgres-shared-provision <app>` — no manual `psql`/DBGate step required.

Active compose files that connect to or depend on shared Postgres include AnythingLLM, Bifrost, Databasus, DBGate, FreshRSS, Hoppscotch, Memos, n8n, Open WebUI, and Phoenix. Mealie also uses Postgres through its configured server variables. Nextcloud is the main exception and uses its own MariaDB sidecar.

## Integrations

- **Bifrost:** shared OpenAI-compatible gateway for AnythingLLM, Crawl4AI, Headroom, Hindsight, Karakeep, Mealie, Open Notebook, Open WebUI, and other AI-enabled services.
- **Ollama and LM Studio:** host-machine model servers reached through `host.docker.internal`.
- **SearXNG:** search backend for Open WebUI and AnythingLLM.
- **MCP:** Bifrost and AI tools can connect to Atlassian MCP, Context7, Mermaid, Obscura, and other configured MCP servers.
- **Mailpit:** captures local application email from Databasus, Hoppscotch, Mealie, and other SMTP-enabled apps.
- **Nextcloud WebDAV:** synchronization backend for Super Productivity.
- **DBGate:** browser UI for provisioning and inspecting shared Postgres.

## Data And Security

- `local-volumes/` contains databases, uploads, indexes, and app state. It is gitignored and survives container recreation.
- `.env` contains credentials, API keys, and app secrets. It is gitignored and must not be committed or pasted into issue reports.
- Homepage, Dockpeek, Dozzle, Portainer, and Uptime Kuma mount the Docker socket. Treat those containers as privileged.
- Open Design uses host networking. Review that compose file before changing network behavior.
- The stack is designed for local or Tailnet use, not direct public internet exposure.

## Maintainer Notes

Everything above covers day-to-day use. The notes below are for changing the stack itself.

## Adding Or Updating An App

1. Check `stack/` and root `compose.yaml` for an existing or inactive definition.
2. Verify the current upstream image and configuration documentation.
3. Add or update `stack/<app>/compose.yaml` using namespaced environment variables and bind mounts under `../../local-volumes/<app>/`.
4. Use `postgres-shared` for new Postgres-backed apps unless upstream cannot support it.
5. Register new apps in root `compose.yaml`.
6. Add tracked placeholders to `.env.example` when environment cleanup is in scope.
7. Run `docker compose config --quiet`.
8. Update this README when the active inventory or operator workflow changes.

## License

See [LICENSE](LICENSE).
