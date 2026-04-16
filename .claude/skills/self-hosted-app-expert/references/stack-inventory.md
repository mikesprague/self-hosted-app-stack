# Stack App Inventory

Complete inventory of all apps in the self-hosted stack. Apps marked **[inactive]** are defined but commented out in the root `compose.yaml` include block — their compose files exist in `stack/` and can be re-activated.

## AI / LLM

| App | Container | Port | Postgres | Status | Notes |
|-----|-----------|------|----------|--------|-------|
| open-webui | `open-webui` | 3000 | shared | **active** | Main AI chat UI; integrates Ollama, Azure Foundry, SearXNG, multiple MCP servers |
| open-notebook | `open-notebook` | — | No (SurrealDB) | **active** | AI-powered notebook with SurrealDB |
| litellm | `litellm` | 4000 | shared | [inactive] | LLM proxy/gateway; aggregates multiple providers |

## Search

| App | Container | Port | Deps | Status | Notes |
|-----|-----------|------|------|--------|-------|
| searxng | `searxng` | 8348 | Valkey | **active** | Privacy-preserving meta search engine; used by open-webui |

## Personal Knowledge Management (PKM)

| App | Container | Port | Postgres | Status | Notes |
|-----|-----------|------|----------|--------|-------|
| affine | `affine` | 8369 | shared | **active** | All-in-one workspace (docs, whiteboard, tasks) |
| flatnotes | `flatnotes` | — | No | **active** | Simple flat-file markdown notes |
| karakeep | `karakeep-web` | 7788 | No | **active** | Bookmark/read-later manager; uses Meilisearch + headless Chrome + AI inference |
| memos | `memos` | 5230 | shared | **active** | Lightweight micro-journaling / notes |
| blinko | `blinko` | — | shared | [inactive] | Note-taking with AI |
| docmost | `docmost` | — | shared | [inactive] | Collaborative wiki/docs (Notion alternative) |
| jotty | `jotty` | — | No | [inactive] | Minimal notes app |
| logseq | `logseq` | — | No | [inactive] | Graph-based outliner / PKM |
| silverbullet | `silverbullet` | — | No | [inactive] | Markdown-based personal wiki with plugins |
| trilium-notes | `trilium` | — | No | [inactive] | Hierarchical notes with scripting |

## RSS / Feed Reading

| App | Container | Port | Postgres | Status | Notes |
|-----|-----------|------|----------|--------|-------|
| freshrss | `freshrss` | 8353 | shared | **active** | Self-hosted RSS aggregator |

## Task Management / Productivity

| App | Container | Port | Deps | Status | Notes |
|-----|-----------|------|------|--------|-------|
| super-productivity | `super-productivity` | — | No (WebDAV) | **active** | Task/time tracking; uses local WebDAV for sync |

## Automation / Workflow

| App | Container | Port | Postgres | Status | Notes |
|-----|-----------|------|----------|--------|-------|
| n8n | `n8n` | 5678 | shared | [inactive] | Visual workflow automation; also has Qdrant vector DB |
| flowise | `flowise` | — | shared | [inactive] | LLM workflow builder (LangChain UI) |

## API Development / Testing

| App | Container | Port | Postgres | Status | Notes |
|-----|-----------|------|----------|--------|-------|
| hoppscotch | `hoppscotch` | 8363 (UI), 3100 (admin), 3170 (API) | shared | **active** | Full-featured REST/GraphQL/WS client with team features |
| yaade | `yaade` | 8364 | No | **active** | Simple collaborative API client |
| restfox | `restfox` | 8365 | No | **active** | Lightweight offline-first REST client |

## Infrastructure / Shared Services

| App | Container | Port | Notes |
|-----|-----------|------|-------|
| postgres-shared | `postgres-shared` | — | **The single Postgres instance for all apps** (`pgvector/pgvector:pg17`). Each app has its own database and credentials within this instance. Includes `pgadmin` UI (port 5050) and a `postgres-maintenance` one-shot provisioning service. |
| mailcatcher | `mailcatcher` | 1025 (SMTP), 8366 (UI) | Dev SMTP catcher; captures all outbound email |
| atlassian-mcp | `atlassian-mcp` | 9000 | MCP server for Jira + Confluence integration |

## Monitoring / Management

| App | Container | Port | Status | Notes |
|-----|-----------|------|--------|-------|
| dozzle | `dozzle` | — | [inactive] | Real-time Docker log viewer |
| portainer | `portainer` | 8358 (HTTP), 9443 (HTTPS) | [inactive] | Docker management UI |
| uptime-kuma | `uptime-kuma` | — | [inactive] | Service uptime monitoring |

## Dashboard

| App | Container | Port | Notes |
|-----|-----------|------|-------|
| homepage | `homepage` | 8349 | Configurable start page / dashboard; reads Docker socket |

## File Tools

| App | Container | Port | Status | Notes |
|-----|-----------|------|--------|-------|
| vert | `vert` | 8368 | **active** | File format converter (runs offline — external requests disabled) |

## Ports Quick Reference

> **Port assignment rule**: Host-side ports must always be a namespaced env var (e.g., `${APP_PORT:-8370}`) — never hard-coded. Assign the next sequential number above the current highest to avoid conflicts.
> **Next available port: 8370**

| Port | App |
|------|-----|
| 1025 | mailcatcher SMTP |
| 3000 | open-webui |
| 3100 | hoppscotch admin |
| 3170 | hoppscotch API backend |
| 4000 | litellm [inactive] |
| 5050 | pgadmin |
| 5230 | memos |
| 5678 | n8n [inactive] |
| 7788 | karakeep |
| 8348 | searxng |
| 8349 | homepage |
| 8353 | freshrss |
| 8358 | portainer [inactive] |
| 8363 | hoppscotch web UI |
| 8364 | yaade |
| 8365 | restfox |
| 8366 | mailcatcher web UI |
| 8368 | vert |
| 8369 | affine |
| 9000 | atlassian-mcp |
| 9443 | portainer HTTPS [inactive] |

## External Integrations (Shared)

| Service | How to reach | Env Var |
|---------|-------------|---------|
| Ollama (host) | `http://host.docker.internal:11434` | `OLLAMA_BASE_URL` |
| LM Studio (host) | `http://host.docker.internal:1234/v1` | `LM_STUDIO_OPENAI_API_URL` |
| Azure Foundry OpenAI | `AZURE_FOUNDRY_OPENAI_BASE_URL` | `AZURE_OPENAI_API_KEY` |
| SearXNG (internal) | `http://searxng:8080` | — |
| Atlassian MCP (internal) | `http://atlassian-mcp:9000/mcp` | — |
| Context7 MCP (external) | `https://mcp.context7.com/mcp` | `CONTEXT7_API_KEY` |
| Mermaid MCP (external) | `https://mcp.mermaid.ai/mcp` | — |
