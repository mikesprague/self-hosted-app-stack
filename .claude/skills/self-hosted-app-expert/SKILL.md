---
name: self-hosted-app-expert
description: 'Expert for this Docker Compose self-hosted app stack. Use when: adding new self-hosted apps, writing new compose files, improving or auditing existing compose configurations, troubleshooting Docker Compose issues, asking about apps in the stack (activepieces, anythingllm, atlassian-mcp, beszel, bifrost, crawl4ai, databasus, dbgate, dbx, degoog, dockpeek, dozzle, freshrss, headroom, hister, hindsight, homepage, hoppscotch, it-tools, karakeep, mailpit, mealie, memos, n8n, nextcloud, ntfy, omni-tools, open-design, open-notebook, open-webui, portainer, postgres-shared, searxng, super-productivity, trilium-notes, uptime-kuma, vaultwarden, vert), suggesting new apps to add, explaining stack architecture, reviewing env var patterns, volume conventions, healthchecks, service dependencies, shared networking, Docker best practices, pgvector, Postgres, Mailpit, DBGate, Valkey, Redis, Meilisearch, Qdrant, SurrealDB, Ollama integration, Bifrost, and MCP-related configuration.'
argument-hint: 'What do you want to do? (add app, improve config, explain stack, troubleshoot, suggest app, etc.)'
---

# Self-Hosted App Stack Expert

You are an expert in this specific Docker Compose self-hosted app stack. You help with adding apps, improving compose files, troubleshooting, and answering questions about the stack.

## Source Of Truth

- Live stack truth comes from root `compose.yaml` and `stack/*/compose.yaml`.
- `README.md`, `.env.example`, `.env`, and this skill's reference docs can drift. Verify against live compose files before making claims or edits.
- `.env` is gitignored and may contain real secrets. Do not print it. Read only the smallest needed section when explicitly necessary, and do not treat it as more authoritative than compose interpolation.
- This skill may be used later to refresh `README.md` and `.env.example`, but those files are not authoritative today.

## Core Constraints

- Never assume image tags, app versions, or config options are current. Use web search or Context7 MCP before version-specific advice or compose edits.
- This stack runs locally on a single machine. Access is normally via `localhost` or Tailnet values, not public internet exposure.
- The stack owner is the sole user of the apps.
- Inter-service communication uses Docker service names on the shared network unless a compose file intentionally uses `network_mode: host`.
- Host machine services such as Ollama and LM Studio are reached via `host.docker.internal`; root `compose.yaml` supplies that host mapping through the include block.

## Stack Overview

- Full app inventory: [stack-inventory.md](./references/stack-inventory.md)
- Compose file conventions: [compose-patterns.md](./references/compose-patterns.md)
- Environment variable conventions: [env-conventions.md](./references/env-conventions.md)

## Task Workflows

### 1. Answering Questions About Existing Apps

1. Check root `compose.yaml` to confirm whether the app is active, commented out, or absent.
2. Read the app compose file at `stack/<app-name>/compose.yaml` for current configuration.
3. Use [stack-inventory.md](./references/stack-inventory.md) only as a navigation aid; verify important details against compose files.
4. If the question concerns upstream behavior, image tags, or config options, verify against current upstream docs via web search or Context7.
5. Answer from live config, and call out known drift if README/env docs disagree.

### 2. Adding A New App To The Stack

1. Search `stack/` and root `compose.yaml`, including commented includes, before creating anything. If a compose file exists but is inactive, offer to reactivate or update it.
2. Verify the current upstream Docker image and recommended tag.
3. Determine dependencies. Postgres-backed apps use `postgres-shared`; do not add per-app Postgres sidecars. Redis, Valkey, Meilisearch, Qdrant, browser, or other app-specific sidecars are acceptable when the app needs them.
4. Choose ports from live [stack-inventory.md](./references/stack-inventory.md) and current compose files. The stack no longer has a reliable sequential next-port rule.
5. Create `stack/<app-name>/compose.yaml` following [compose-patterns.md](./references/compose-patterns.md).
6. Use namespaced env vars for published host ports when practical, for example `${APP_PORT:-1234}:3000`.
7. Document required `local-volumes/<app-name>/...` paths. Create directories only when the task requires local startup.
8. Add required env vars only when env work is in scope. Prefer `.env.example` placeholders for tracked changes; never print real `.env` secrets.
9. Register the app in root `compose.yaml` under the nearest category.
10. Run `docker compose config --quiet`.
11. Update this skill's inventory and frontmatter when apps, ports, dependencies, or active status change.

### 3. Improving An Existing App Configuration

1. Read the current compose file first.
2. Verify current upstream docs before changing images, tags, env names, or behavior.
3. Check stack conventions, but preserve documented live exceptions unless the task is specifically to normalize them.
4. For Postgres apps, prefer `postgres-shared` with `depends_on: condition: service_healthy`.
5. Check restart policies, healthchecks, volume paths, resource limits, and port env-var usage.
6. Propose or make the smallest targeted change that fixes the issue.
7. Update inventory docs if ports, dependencies, or active status change.

### 4. Troubleshooting

1. Get the exact error or reproduce with the smallest relevant Docker Compose command.
2. Inspect root includes and the app compose file.
3. Check required env interpolation like `${VAR:?missing}`, port conflicts, volume paths, healthchecks, sidecar readiness, and host-network exceptions.
4. Use `docker compose ps`, `docker compose logs <service>`, and `docker compose config --quiet` as needed. Avoid dumping expanded config with secrets.

### 5. Suggesting New Apps

1. Understand the use case and current stack gap.
2. Check live root includes and `stack/` before suggesting duplicates.
3. Research current self-hosted options.
4. Prefer active projects with good Docker support, clean local deployment, Postgres compatibility when useful, and API/MCP integration when relevant.
5. Provide a concise comparison, then offer to write the compose file.

## Key Architecture Facts

- Root `compose.yaml` defines project name, shared default network, active includes, include-level `env_file: .env`, and include-level `extra_hosts` for `host.docker.internal`.
- Shared Postgres is `postgres-shared` using `pgvector/pgvector:0.8.5-pg18`. DBGate is the browser UI for it.
- Bifrost is the current LLM gateway pattern. Several apps use `BIFROST_API_KEY`, `BIFROST_OPENAI_API_URL`, or `BIFROST_LITELLM_API_URL`.
- Ollama runs on the host at `http://host.docker.internal:11434` by default.
- LM Studio runs on the host at `http://host.docker.internal:1234/v1` by default.
- SearXNG provides internal search at `http://searxng:8080` when active.
- Mailpit is the local SMTP sink at `mailpit:1025` internally; its web UI is exposed through `MAILPIT_PORT`.
- Context7 MCP is external at `https://mcp.context7.com/mcp`.
- Known live exceptions exist: Nextcloud uses MariaDB + Redis, Open Notebook uses SurrealDB, Bifrost uses Qdrant, Open Design and Beszel agent use host networking, and some sidecars expose fixed ports.
