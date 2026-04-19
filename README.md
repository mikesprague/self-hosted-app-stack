# Self-Hosted App Stack

Docker Compose workspace for running a personal collection of self-hosted apps across AI and research, cloud storage, knowledge management, feeds, productivity, automation, password management, monitoring, API development, and utilities on a shared Docker network with persistent local storage.

The stack is split into per-app compose files under `stack/` and assembled by the root `compose.yaml` using Compose `include`. Persistent data lives under `local-volumes/`.

Several note-taking and knowledge-management apps are included on purpose. They each have different strengths around capture, organization, collaboration, publishing, or personal knowledge management, and this stack is being used to evaluate them side by side before settling on a smaller long-term set.

## Included Services

| Service | Purpose |
| --- | --- |
| **Infrastructure / Data** | |
| PostgreSQL Shared | Shared `pgvector` Postgres instance used by Postgres-backed apps in the stack |
| [DBGate](https://dbgate.org/) | Browser-based database manager preconfigured for the shared Postgres instance |
| **Personal Cloud** | |
| [Nextcloud](https://nextcloud.com/) | File sync, sharing, and personal cloud storage |
| **AI / Research** | |
| [Open WebUI](https://openwebui.com/) | Unified chat interface for local and cloud LLMs |
| [SearXNG](https://searxng.org/) | Private internet metasearch engine that aggregates results from several search services |
| [Open Notebook](https://www.open-notebook.ai/) | Private, multi-model, local alternative to NotebookLM |
| [LiteLLM](https://www.litellm.ai/) | OpenAI-compatible LLM gateway and model routing layer |
| **Knowledge Management** | |
| [Affine](https://affine.pro/) | Workspace with fully merged docs, whiteboards, and databases |
| [Blinko](https://blinko.space/) | AI-powered card notes for quick capture and organization |
| [Docmost](https://docmost.com/) | Collaborative wiki with real-time editing, team spaces, and AI |
| [Flatnotes](https://github.com/Dullage/flatnotes) | Distraction-free markdown notes stored as plain searchable files |
| [Jotty](https://github.com/fccview/jotty) | Personal checklists and rich text notes with file-based storage |
| [Karakeep](https://karakeep.app/) | Save bookmarks, notes, and images with AI auto-tagging |
| [Logseq](https://logseq.com/) | Local-first outliner and knowledge graph workspace |
| [Memos](https://www.usememos.com/) | Quick-capture markdown notes on a private personal timeline |
| [Silverbullet](https://silverbullet.md/) | Programmable markdown knowledge base with live queries and scripting |
| [Trilium Notes](https://triliumnext.github.io/Notes/) | Hierarchical note-taking for building rich personal knowledge bases |
| **Recipes** | |
| [Mealie](https://mealie.io/) | Recipe manager with meal planning and shopping support |
| **Feeds** | |
| [FreshRSS](https://freshrss.org/) | Fast, customizable RSS and Atom feed aggregator |
| **Productivity** | |
| [Super Productivity](https://super-productivity.com/) | Privacy-focused deep work system with tasks, time tracking, and focus tools |
| **Automation / Workflows** | |
| [Flowise](https://flowiseai.com/) | Drag-and-drop platform for building AI agents and chatbots |
| [n8n](https://n8n.io/) | Workflow automation connecting APIs, apps, and services |
| **Password Management** | |
| [Vaultwarden](https://vaultwarden.net/) | Lightweight Bitwarden-compatible server for encrypted credentials |
| **Monitoring & Management** | |
| [Dockpeek](https://dockpeek.com/) | Lightweight Docker container dashboard |
| [Dozzle](https://dozzle.dev/) | Real-time web-based viewer for Docker container logs |
| [Uptime Kuma](https://github.com/louislam/uptime-kuma) | Customizable uptime monitor for sites and network services |
| [Portainer](https://www.portainer.io/) | Visual Docker management dashboard for containers and stacks |
| **Mail / Delivery** | |
| [Mailpit](https://mailpit.axllent.org/) | Local SMTP sink and inbox viewer for testing outbound mail |
| **API Development** | |
| [Hoppscotch](https://hoppscotch.io/) | API development suite with app, admin, and backend services |
| [Restfox](https://restfox.dev/) | Simple local API client for testing HTTP requests |
| [Yaade](https://www.yaade.io/) | Self-hosted Postman alternative for API collections |
| **Utilities** | |
| [Vert](https://github.com/vert-sh/vert) | Self-hosted file conversion web app |
| **Dashboard** | |
| [Homepage](https://gethomepage.dev/) | Highly customizable app dashboard with service and widget integrations |

## Local URLs

| Service | Local URL |
| --- | --- |
| PostgreSQL Shared | `postgresql://localhost:5432` |
| DBGate | <http://localhost:8370> |
| Open WebUI | <http://localhost:3000> |
| SearXNG | <http://localhost:8348> |
| Homepage | <http://localhost:8349> |
| Silverbullet | <http://localhost:8350> |
| Trilium Notes | <http://localhost:8351> |
| Flatnotes | <http://localhost:8352> |
| FreshRSS | <http://localhost:8353> |
| Super Productivity | <http://localhost:8354> |
| Flowise | <http://localhost:8355> |
| Uptime Kuma | <http://localhost:8356> |
| Dozzle | <http://localhost:8357> |
| Portainer | <http://localhost:8358> |
| Vaultwarden | <http://localhost:8359> |
| Logseq | <http://localhost:8360> |
| Nextcloud | <http://localhost:8361> |
| Hoppscotch App | <http://localhost:8363> |
| Hoppscotch Admin | <http://localhost:3100> |
| Hoppscotch API | <http://localhost:3170> |
| Yaade | <http://localhost:8364> |
| Restfox | <http://localhost:8365> |
| Mealie | <http://localhost:8367> |
| Dockpeek | <http://localhost:8368> |
| Vert | <http://localhost:8369> |
| Mailpit UI | <http://localhost:8025> |
| Mailpit SMTP | `smtp://localhost:1025` |
| LiteLLM | <http://localhost:4000> |
| Affine | <http://localhost:3010> |
| Blinko | <http://localhost:1111> |
| Docmost | <http://localhost:7889> |
| Jotty | <http://localhost:1122> |
| Karakeep | <http://localhost:7788> |
| Memos | <http://localhost:5230> |
| Open Notebook | <http://localhost:8502> |
| Open Notebook API | <http://localhost:5055> |

## Quick Start

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Podman / OrbStack) with modern Compose support and enough disk space for databases, indexes, uploads, and app state under `local-volumes/`. [Ollama](https://ollama.com/) is needed only for local AI features.

1. Clone the repository.
2. Copy the example environment file.
3. Fill in the required secrets, credentials, ports, Tailnet values, and provider settings. For any field marked `openssl rand -hex 32`, run that command in your terminal to generate a secure value.
4. Start the shared Postgres instance and DBGate first.
5. For each Postgres-backed app you plan to enable, create its role and database in the shared Postgres instance.
6. Pull and start the full stack.

```sh
git clone https://github.com/mikesprague/self-hosted-app-stack.git
cd self-hosted-app-stack
cp .env.example .env
docker compose up -d postgres-shared dbgate
docker compose pull
docker compose up -d
```

Use DBGate at <http://localhost:8370> or `psql` against `postgres-shared` to provision a new Postgres-backed app before starting it:

```sql
CREATE ROLE appName WITH LOGIN PASSWORD 'replace-with-your-password';
CREATE DATABASE appName OWNER appName;
```

That applies to any app configured with `*_POSTGRES_DB`, `*_POSTGRES_USER`, and `*_POSTGRES_PASSWORD` values in `.env`, such as Open WebUI, Affine, Docmost, Blinko, Memos, FreshRSS, Flowise, n8n, LiteLLM, Hoppscotch, and Mealie.

To stop everything:

```sh
docker compose down
```

**Optional providers:** [Context7](https://context7.com/) for the preconfigured MCP integration in Open WebUI, [Jina AI](https://jina.ai/) for Jina-backed features, [LM Studio](https://lmstudio.ai/) as an alternative local model runner, and Azure Foundry / Azure OpenAI if you prefer cloud-hosted models over local ones.

## Configuration

The root compose file loads environment variables from `.env` and includes the per-service definitions from `stack/`. Start with `.env.example` and review these groups before bringing the stack up:

| Variable group | Affects | Required |
| --- | --- | --- |
| `POSTGRES_SHARED_*` | Shared Postgres and DBGate bootstrap | Yes |
| `SEARXNG_*` | SearXNG | Yes |
| `OPEN_WEBUI_*` | Open WebUI | Yes |
| `OPEN_NOTEBOOK_*` | Open Notebook | Yes |
| `KARAKEEP_*` | Karakeep | Yes |
| `AFFINE_*`, `DOCMOST_*`, `BLINKO_*`, `MEMOS_*`, `FRESHRSS_*`, `FLOWISE_*`, `N8N_*`, `LITELLM_*`, `HOPPSCOTCH_*`, `MEALIE_*` | Postgres-backed apps | If enabling that app |
| `NEXTCLOUD_*` | Nextcloud and its MariaDB-backed setup | If enabling Nextcloud |
| `FLATNOTES_*`, `SILVERBULLET_*`, `SP_WEBDAV_*`, `VAULTWARDEN_*`, `YAADE_*`, `DOCKPEEK_*` | App-specific auth and secrets | If enabling that app |
| `MAILPIT_*` | Mailpit UI and SMTP defaults | If enabling Mailpit-backed email flows |
| `DBGATE_*` | DBGate label and published port | Optional |
| `HOMEPAGE_*`, `PORTAINER_*`, `DOZZLE_*`, `UPTIME_KUMA_*`, `JOTTY_*`, `LOGSEQ_*`, `TRILIUM_*`, `RESTFOX_*`, `VERT_*` | Primarily published ports and app-specific options | Optional unless changing defaults |
| `TAILNET_*` | Blinko, n8n, and Hoppscotch absolute URLs | Yes if using those apps |
| `TZ` | All services | Yes |
| `AZURE_*`, `OLLAMA_*` | AI-enabled apps | Only if using that provider |
| `CONTEXT7_API_KEY`, `JINA_API_KEY`, `UNSPLASH_*` | Open WebUI, Open Notebook, and related integrations | Optional |

### Shared Postgres Workflow

The stack now uses a single shared Postgres instance instead of one sidecar Postgres container per app. When you add a new Postgres-backed app, the expected workflow is:

1. Add the app's compose file and `*_POSTGRES_*` variables.
2. Start or confirm `postgres-shared` is healthy.
3. Create the role and database in `postgres-shared`.
4. Start the app.

The shared Postgres service is exposed on `localhost:5432`, and DBGate is included as the default browser UI for administering it.

### Homepage Configuration

The Homepage config lives under [local-volumes/homepage/config](/Users/msprague/Code/self-hosted-app-stack.git/local-volumes/homepage/config). The included [settings.yaml](/Users/msprague/Code/self-hosted-app-stack.git/local-volumes/homepage/config/settings.yaml) and [custom.css](/Users/msprague/Code/self-hosted-app-stack.git/local-volumes/homepage/config/custom.css) are meant to be tweaked as desired for your preferred look and behavior.

To use the bundled examples for service and widget definitions, copy [services.example.yaml](/Users/msprague/Code/self-hosted-app-stack.git/local-volumes/homepage/config/services.example.yaml) and [widgets.example.yaml](/Users/msprague/Code/self-hosted-app-stack.git/local-volumes/homepage/config/widgets.example.yaml), remove the `.example` suffix, and edit them as needed.

## Integrations

Some parts of the stack are wired together out of the box:

- **Open WebUI → SearXNG**: web-enabled LLM workflows use the local SearXNG instance by default.
- **Open WebUI → Ollama**: preconfigured via `OLLAMA_BASE_URL` and `OLLAMA_API_KEY`.
- **Open WebUI → Context7 MCP**: pulls current library and framework docs when `CONTEXT7_API_KEY` is set.
- **DBGate → PostgreSQL Shared**: DBGate comes up with a preconfigured connection to `postgres-shared`.
- **Mailpit → Hoppscotch / Mealie**: outbound app mail is routed to the local Mailpit SMTP service.

Two services require manual setup after startup:

- **Open Notebook**: provider and application-level configuration must be completed manually.
- **Vaultwarden**: requires a valid HTTPS `VAULTWARDEN_DOMAIN` and a generated Argon2 admin token before first use.

## Service Layout

Each app has its own compose file at `stack/<service>/compose.yaml` and a matching data folder at `local-volumes/<service>/` for databases, uploads, indexes, and app state. The root `compose.yaml` assembles them all via Compose `include`.

## Operating The Stack

```sh
docker compose ps
docker compose logs -f
docker compose logs -f open-webui
docker compose restart
docker compose pull && docker compose up -d
```

You can also operate services individually by name. For example, `docker compose up -d docmost` starts only Docmost and its dependencies, while `docker compose stop docmost` stops that service without tearing down the rest of the stack.

```sh
docker compose up -d docmost
docker compose stop docmost
docker compose restart docmost
docker compose logs -f docmost
docker compose rm -f docmost   # remove a stopped container without losing data
```

## Notes

- All services share the `self-hosted-app-stack-network` Docker network. Data under `local-volumes/` survives container removal.
- Shared Postgres replaces the old per-app Postgres sidecars. DBGate is the default database UI, and Mailpit is the default SMTP sink.
- Homepage, Dockpeek, Dozzle, Portainer, and Uptime Kuma mount the Docker socket for container-aware features. Treat that as privileged access.
- Affine has extra startup orchestration for migrations and may take longer to become ready on first boot.
- Hoppscotch exposes separate app, admin, and API ports. Mailpit exposes both a web UI and an SMTP listener.
- Keep provider URLs, keys, and model names aligned across AI-enabled services when changing providers.

## Recommended First Checks

After startup:

1. `docker compose ps` — all containers healthy or running.
2. Homepage at <http://localhost:8349> loads and links to enabled services.
3. DBGate at <http://localhost:8370> can connect to `postgres-shared`.
4. Vaultwarden at <http://localhost:8359> has a valid HTTPS domain and admin token configured before use.
5. Any service with a database — check logs for migration errors on first boot.
