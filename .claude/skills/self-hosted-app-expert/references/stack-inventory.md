<!-- markdownlint-disable MD060 -->

# Stack App Inventory

Generated from live `compose.yaml` and `stack/*/compose.yaml` conventions. Verify details against compose files before editing. README, `.env.example`, and `.env` are not authoritative.

## Active Apps

### Postgres / Data

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| databasus | `databasus` | `${DATABASUS_PORT:-4005}` | Postgres browser/client; depends on `postgres-shared` |
| dbgate | `dbgate` | `${DBGATE_PORT:-8370}` | Browser UI for `postgres-shared` |
| dbx | `dbx` | `${DBX_PORT:-4224}` | Database tool |
| postgres-shared | `postgres-shared` | `${POSTGRES_SHARED_PORT:-5432}` | Shared `pgvector/pgvector:0.8.5-pg18` Postgres instance |

### Personal Cloud

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| nextcloud | `nextcloud` | `${NEXTCLOUD_PORT:-8361}` | Uses app-specific MariaDB and Redis sidecars, not shared Postgres |

### AI / LLM

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| atlassian-mcp | `atlassian-mcp` | `${ATLASSIAN_MCP_PORT:-9000}` | Atlassian MCP server |
| anythingllm | `anythingllm` | `${ANYTHINGLLM_PORT:-3001}` | Uses shared Postgres/pgvector and Bifrost endpoints |
| bifrost | `bifrost` | `${BIFROST_APP_PORT:-8080}` | Current LLM gateway; uses Qdrant sidecar |
| bifrost-qdrant | `bifrost-qdrant` | `${BIFROST_QDRANT_REST_PORT:-6333}`, `${BIFROST_QDRANT_GRPC_PORT:-6334}` | Qdrant sidecar for Bifrost |
| crawl4ai | `crawl4ai` | `${CRAWL4AI_PORT:-11235}` | Uses Bifrost-compatible OpenAI endpoint |
| headroom | `headroom` | `${HEADROOM_PORT:-8787}` | AI/code tool; depends on Bifrost in compose |
| hindsight | `hindsight` | `${HINDSIGHT_API_PORT:-8888}`, `${HINDSIGHT_UI_PORT:-9999}` | Uses shared Postgres |
| open-design | `open-design` | host network, app port 7456 | Intentional exception: top-level `name:`, `network_mode: host`, `ports: []` |
| open-notebook | `open-notebook` | `${OPEN_NOTEBOOK_PORT:-8502}`, `5055`, SurrealDB `8000` | Uses SurrealDB sidecar and Bifrost |
| open-webui | `open-webui` | `${OPEN_WEBUI_PORT:-3000}` | Main chat UI; uses shared Postgres/pgvector, Ollama, SearXNG, MCPs |

### Search Engine

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| degoog | `degoog` | `${DEGOOG_PORT:-4444}` | Uses Valkey sidecar |
| hister | `hister` | `${HISTER_PORT:-4433}` | Search/history tool |
| searxng | `searxng` | `${SEARXNG_PORT}` | Uses Valkey sidecar; no default in compose |

### Password Manager

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| vaultwarden | `vaultwarden` | `${VAULTWARDEN_PORT:-8359}` | Local Bitwarden-compatible server |

### PKM / Personal Data

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| karakeep | `karakeep-web` | `${KARAKEEP_PORT:-7788}` | Uses Chrome sidecar on `9222` and Meilisearch sidecar on `7700` |
| mealie | `mealie` | `${MEALIE_PORT:-8367}` | Recipe manager |
| memos | `memos` | `${MEMOS_PORT:-5230}` | Uses shared Postgres |
| trilium-notes | `trilium` | `${TRILIUM_PORT:-8351}` | Hierarchical notes |

### RSS / Feed Reading

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| freshrss | `freshrss` | `${FRESHRSS_PUBLISHED_PORT:-8353}` | Uses shared Postgres |

### Task Management / Productivity

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| super-productivity | `super-productivity` | `${SUPER_PRODUCTIVITY_PORT:-8354}` | Uses Nextcloud WebDAV sync |

### Workflows / Automation

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| activepieces | `activepieces` | `${ACTIVEPIECES_PORT:-8080}` | Uses shared Postgres and Redis sidecar |
| n8n | `n8n` | `${N8N_PORT:-5678}` | Uses shared Postgres |

### Monitoring / Management

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| beszel | `beszel` | `${BESZEL_PORT:-8090}` | Beszel hub; agent uses host network and Docker socket |
| dockpeek | `dockpeek` | `${DOCKPEEK_PORT:-8368}` | Mounts Docker socket |
| dozzle | `dozzle` | `${DOZZLE_PORT:-8357}` | Mounts Docker socket |
| portainer | `portainer` | `${PORTAINER_PORT:-8358}`, `${PORTAINER_HTTPS_PORT:-9443}` | Mounts Docker socket |
| uptime-kuma | `uptime-kuma` | `${UPTIME_KUMA_PORT:-8356}` | Mounts Docker socket |

### Mail / Delivery

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| mailpit | `mailpit` | `${MAILPIT_PORT:-8371}`, SMTP `${MAILPIT_SMTP_PORT:-1025}` | Local SMTP sink |

### API Development / Testing

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| hoppscotch | `hoppscotch` | `${HOPPSCOTCH_PORT:-8363}`, `${HOPPSCOTCH_ADMIN_PORT:-3100}`, `${HOPPSCOTCH_API_PORT:-3170}` | Multi-service API development suite |

### File Conversion

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| vert | `vert` | `${VERT_PORT:-8369}` | File conversion web app |

### Misc Tools / Utilities

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| it-tools | `it-tools` | `${IT_TOOLS_PORT:-8080}` | Utility toolbox; default may conflict if not overridden |
| omni-tools | `omni-tools` | `${OMNI_TOOLS_PORT:-8080}` | Utility toolbox; default may conflict if not overridden |

### Push Notifications

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| ntfy | `ntfy` | `${NTFY_PORT:-80}` | Push notification service |

### Dashboard

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| homepage | `homepage` | `${HOMEPAGE_PORT:-8349}` | Dashboard/start page; mounts Docker socket |

## Inactive Compose Files

### Commented Out In Root `compose.yaml`

| App | Main container(s) | Host port(s) | Notes |
|-----|-------------------|--------------|-------|
| 9router | `9router` | `${NINEROUTER_PORT:-20128}` | Compose file exists but include is commented out |
| caveman | `caveman`, `cavehead` | `${CAVEMAN_PORT:-8788}`, `${CAVEHEAD_PORT:-8789}` | Compose file exists but include is commented out |
| paperless-ngx | `paperless-ngx`, sidecars | `${PAPERLESS_PORT:-8000}`, plus sidecar ports | Uses shared Postgres, Redis, Gotenberg, Tika, paperless-gpt |
| silverbullet | `silverbullet` | `${SILVERBULLET_PORT:-8350}` | Compose file exists but include is commented out |

### Present Under `stack/` But Not Referenced By Root Compose

| App | Main container | Host port(s) | Notes |
|-----|----------------|--------------|-------|
| anchor | `anchor` | `${ANCHOR_PORT:-3000}` | Uses shared Postgres |
| blinko | `blinko-web` | `${BLINKO_PORT:-1111}` | Uses shared Postgres |
| caddy | `caddy` | See compose file | Reverse proxy compose exists but is not included |
| flatnotes | `flatnotes` | `${FLATNOTES_PORT:-8352}` | Flat-file notes compose exists but is not included |
| jotty | `jotty` | `${JOTTY_PORT:-1122}` | Notes/checklist compose exists but is not included |
| rustdesk | `hbbr`, `hbbs` | See compose file | RustDesk relay/server compose exists but is not included |

## Port Quick Reference

Host port values below are compose defaults or required env vars. Check root `.env` only when env work is in scope, and never print secrets.

| Host port / env | App |
|-----------------|-----|
| `${NTFY_PORT:-80}` | ntfy |
| `${MAILPIT_SMTP_PORT:-1025}` | mailpit SMTP |
| `${ANYTHINGLLM_PORT:-3001}` | anythingllm |
| `${HOPPSCOTCH_ADMIN_PORT:-3100}` | hoppscotch admin |
| `${HOPPSCOTCH_API_PORT:-3170}` | hoppscotch API |
| `${DBX_PORT:-4224}` | dbx |
| `${HISTER_PORT:-4433}` | hister |
| `${DEGOOG_PORT:-4444}` | degoog |
| `${MEMOS_PORT:-5230}` | memos |
| `${N8N_PORT:-5678}` | n8n |
| `${BIFROST_QDRANT_REST_PORT:-6333}` | bifrost-qdrant REST |
| `${BIFROST_QDRANT_GRPC_PORT:-6334}` | bifrost-qdrant gRPC |
| `7456` | open-design host-network app port |
| `7700` | karakeep-meilisearch sidecar |
| `${KARAKEEP_PORT:-7788}` | karakeep |
| `${ACTIVEPIECES_PORT:-8080}` | activepieces |
| `${BIFROST_APP_PORT:-8080}` | bifrost |
| `${IT_TOOLS_PORT:-8080}` | it-tools |
| `${OMNI_TOOLS_PORT:-8080}` | omni-tools |
| `${BESZEL_PORT:-8090}` | beszel |
| `${HOMEPAGE_PORT:-8349}` | homepage |
| `${TRILIUM_PORT:-8351}` | trilium-notes |
| `${FRESHRSS_PUBLISHED_PORT:-8353}` | freshrss |
| `${SUPER_PRODUCTIVITY_PORT:-8354}` | super-productivity |
| `${UPTIME_KUMA_PORT:-8356}` | uptime-kuma |
| `${DOZZLE_PORT:-8357}` | dozzle |
| `${PORTAINER_PORT:-8358}` | portainer HTTP |
| `${VAULTWARDEN_PORT:-8359}` | vaultwarden |
| `${NEXTCLOUD_PORT:-8361}` | nextcloud |
| `${HOPPSCOTCH_PORT:-8363}` | hoppscotch app |
| `${MEALIE_PORT:-8367}` | mealie |
| `${DOCKPEEK_PORT:-8368}` | dockpeek |
| `${VERT_PORT:-8369}` | vert |
| `${DBGATE_PORT:-8370}` | dbgate |
| `${MAILPIT_PORT:-8371}` | mailpit UI |
| `${HEADROOM_PORT:-8787}` | headroom |
| `9222` | karakeep-chrome sidecar |
| `${PORTAINER_HTTPS_PORT:-9443}` | portainer HTTPS |
| `${HINDSIGHT_API_PORT:-8888}` | hindsight API |
| `${HINDSIGHT_UI_PORT:-9999}` | hindsight UI |
| `${CRAWL4AI_PORT:-11235}` | crawl4ai |
| `${ATLASSIAN_MCP_PORT:-9000}` | atlassian-mcp |
| `${OPEN_WEBUI_PORT:-3000}` | open-webui |
| `${OPEN_NOTEBOOK_PORT:-8502}` | open-notebook UI |
| `5055` | open-notebook API |
| `8000` | open-notebook SurrealDB sidecar |
| `${POSTGRES_SHARED_PORT:-5432}` | postgres-shared |
| `${SEARXNG_PORT}` | searxng |

## External Integrations

| Service | How to reach | Common env vars |
|---------|--------------|-----------------|
| Bifrost OpenAI-compatible API | internal service / configured URL | `BIFROST_API_KEY`, `BIFROST_OPENAI_API_URL`, `BIFROST_LITELLM_API_URL` |
| Ollama on host | `http://host.docker.internal:11434` | `OLLAMA_BASE_URL`, `OLLAMA_API_KEY` |
| LM Studio on host | `http://host.docker.internal:1234/v1` | `LM_STUDIO_OPENAI_API_URL` |
| SearXNG internal | `http://searxng:8080` | `SEARXNG_BASE_URL`, `SEARXNG_PORT` |
| Context7 MCP external | `https://mcp.context7.com/mcp` | `CONTEXT7_API_KEY` |
| Mermaid MCP external | `https://mcp.mermaid.ai/mcp` | none required in compose |
| Mailpit SMTP internal | `mailpit:1025` | `MAILPIT_SMTP_HOST`, `MAILPIT_SMTP_PORT` |
