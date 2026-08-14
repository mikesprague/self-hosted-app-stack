# Local OpenCode Setup and Request Flow

This page documents my local/private OpenCode setup, including the LLM request path, memory integration, web crawling, and web search capabilities.

## Architecture

```mermaid
flowchart LR
  OC["OpenCode"]

  subgraph LOCAL["Local machine · Docker / Docker Compose network"]
    HR["Headroom<br/>Compression Proxy"]
    BF["Bifrost Gateway"]

    subgraph MODELS["Bifrost model backends"]
      AZ["Azure AI Foundry<br/>OpenAI / Anthropic models"]
      LL["llama-server<br/>Local models"]
    end

    HS["Hindsight<br/>Memory and recall"]
    OP["OpenCode Hindsight Plugin"]

    C4["Crawl4AI<br/>MCP server / tools"]
    SX["SearXNG<br/>MCP server / tools"]
  end

  subgraph EXTERNAL["External services"]
    AZURE["Azure AI Foundry APIs"]
    SEARCH["Search engines / APIs"]
    TARGETS["Requested web pages"]
  end

  OC -->|"LLM API requests<br/>localhost URL"| HR
  HR -->|"Compressed requests"| BF

  BF -->|"OpenAI / Anthropic<br/>model requests"| AZ
  BF -->|"Local model requests"| LL
  AZ -->|"External model calls"| AZURE

  OC -->|"Memory and recall<br/>via plugin"| OP
  OP <-->|"Store / retrieve memories"| HS

  OC -->|"MCP calls"| C4
  OC -->|"MCP calls"| SX

  C4 -->|"Requested crawls"| TARGETS
  SX -->|"Web search requests"| SEARCH

  classDef client fill:#dbeafe,stroke:#2563eb,color:#111827
  classDef local fill:#dcfce7,stroke:#16a34a,color:#111827
  classDef backend fill:#fef3c7,stroke:#d97706,color:#111827
  classDef external fill:#fee2e2,stroke:#dc2626,color:#111827

  class OC client
  class HR,BF,HS,OP,C4,SX local
  class AZ,LL backend
  class AZURE,SEARCH,TARGETS external

  style LOCAL fill:#f0fdf4,stroke:#16a34a,stroke-width:2px
  style MODELS fill:#fffbeb,stroke:#d97706,stroke-width:1px
  style EXTERNAL fill:#fef2f2,stroke:#dc2626,stroke-width:2px
```

## Request and Integration Flows

### LLM requests

1. OpenCode sends its LLM API requests to the local Headroom compression proxy.
   - rtk used locally to compress OpenCode tool usage tokens
1. Headroom compresses and forwards the requests to the local Bifrost gateway.
1. Bifrost routes requests to one of two model backends:
   - OpenAI, Anthropic, xAI (Grok), Moonshot (Kimi), and DeepSeek models served via Azure AI Foundry.
   - Local models served by `llama-server` on the same host machine as Bifrost.
1. Only the Azure-backed model path leaves the local machine.

### Memory and recall

OpenCode uses the [Hindsight Plugin](https://hindsight.vectorize.io/sdks/integrations/opencode) to communicate with the local Hindsight service. The plugin handles memory storage and recall for OpenCode sessions.

### Web crawling

Crawl4AI is available to OpenCode through an MCP server and its associated tools. Requested crawls access external web pages.

### Web search

SearXNG is available to OpenCode through an MCP server and its associated tools. Search requests are routed through external search engines/APIs.

## Local and External Boundaries

rtk runs locally on the host machine along with OpenCode. Once installed and initialized for OpenCode, it automatically wraps compatible tools calls inside your OpenCode session prior to any request leaving OpenCode.

- [rtk](https://github.com/rtk-ai/rtk) CLI Proxy that reduces agentic tool-based LLM tokens (by 60-90%)

The following services run locally in Docker Compose containers and communicate directly as needed over the local Docker network:

- [Headroom](https://github.com/headroomlabs-ai/headroom) Open-source agnet token compression proxy
- [Bifrost](https://github.com/maximhq/bifrost) High performance open-source AI gateway
- [Hindsight](https://github.com/vectorize-io/hindsight) Open-source agent memory that learns over time
- [Crawl4AI](https://github.com/unclecode/crawl4ai) Open-source LLM friendly web crawler & scraper
- [SearXNG](https://github.com/searxng/searxng) Privacy-focused open-source metasearch engine

[Llama App](https://llama.app/) ([repo](https://github.com/ggml-org/Llama-macOS)) is installed on the local machine and is not containerized. It is configured to listen on a local port and is only accessible from localhost. Ollama or any other local model runner that provides an OpenAI-compatible API can be used here (or omitted altogether).

OpenCode is configured to use localhost URLs, so the overall setup remains local and private except for the following outbound connections:

- Bifrost to Azure AI Foundry models
- SearXNG to search engines/APIs
- Crawl4AI to requested web pages

---

### hindsight config - lives on host machine at: ~/.hindsight/opencode.json

```json
{
  "hindsightApiUrl": "<http://localhost:8888>",
  "autoRecall": true,
  "autoRetain": true,
  "recallBudget": "high",
  "recallMaxTokens": "2048",
  "recallTagsMatch": "any",
  "retainEveryNTurns": 3,
  "retainMode": "full-session",
  "dynamicBankId": true,
  "debug": true
}
```

### opencode global config - usually found at: ~/.config/opencode/opencode.jsonc

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["./global-instructions.md"],
  "plugin": [
    // "@dietrichgebert/ponytail",
    "@vectorize-io/opencode-hindsight",
    // "oh-my-openagent",
  ],
  "permission": {
    "webfetch": "allow",
    "websearch": "allow",
  },
  "lsp": false,
  "formatter": false,
  "snapshot": false,
  "compaction": {
    "auto": true,
    "prune": true,
    "reserved": 15000,
  },
  "share": "disabled",
  "autoupdate": true,
  "experimental": {
    "disable_paste_summary": true,
    "continue_loop_on_deny": true,
  },
  "default_agent": "plan",
  "agent": {
    "plan": {
      // "model": "github-copilot/gpt-5.6-luna",
      // "model": "github-copilot/gpt-5.6-terra",
      "model": "github-copilot/claude-sonnet-5",
      // "model": "github-copilot/claude-opus-4.8",

      // "model": "bifrost-other/azure/grok-4.3",
      // "model": "bifrost-other/azure/DeepSeek-V4-Pro",

      // "model": "bifrost-openai/azure/gpt-5.6-luna",

      // "model": "llama/ggml-org/Qwen3.6-35B-A3B-GGUF:Q4_K_M",
      // "model": "llama/ggml-org/gemma-4-12B-it-GGUF:Q4_0",

      "temperature": 0.2, // focused but slightly flexible for routing decisions
    },
    "build": {
      "model": "github-copilot/claude-sonnet-5",
      // "model": "github-copilot/gpt-5.6-terra",

      // "model": "bifrost-other/azure/DeepSeek-V4-Pro",,
      // "model": "bifrost-other/azure/Kimi-K2.7-Code",

      // "model": "bifrost-anthropic/azure/claude-sonnet-5",
      // "model": "bifrost-openai/azure/gpt-5.6-terra",

      // "model": "llama/ggml-org/Qwen3.6-27B-GGUF:Q4_K_M",
      // "model": "llama/ggml-org/Qwen3.6-35B-A3B-GGUF:Q4_K_M",
    },
    "general": {
      // "model": "github-copilot/gpt-5.6-luna",
      "model": "github-copilot/claude-sonnet-5",

      // "model": "bifrost-other/azure/DeepSeek-V4-Pro",
      // "model": "bifrost-other/azure/grok-4.3",

      // "model": "bifrost-openai/azure/gpt-5.6-luna",
      // "model": "bifrost-anthropic/azure/claude-sonnet-5",

      // "model": "llama/ggml-org/Qwen3.6-27B-GGUF:Q4_K_M",
      // "model": "llama/ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M",
    },
    "explore": {
      // "model": "github-copilot/gpt-5.6-luna",
      "model": "github-copilot/claude-sonnet-5",

      // "model": "bifrost-other/azure/grok-4.3",
      // "model": "bifrost-other/azure/DeepSeek-V4-Pro",

      // "model": "bifrost-openai/azure/gpt-5.6-luna",
      // "model": "bifrost-anthropic/azure/claude-sonnet-5",

      // "model": "llama/ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M",
      // "model": "llama/ggml-org/gemma-4-12B-it-GGUF:Q4_0",
    },
    "title": {
      // "model": "github-copilot/claude-haiku-4.5",
      "model": "github-copilot/gpt-5.4-nano",

      // "model": "bifrost-other/azure/DeepSeek-V4-Flash",

      // "model": "bifrost-openai/azure/gpt-5.4-nano",
      // "model": "bifrost-anthropic/azure/claude-haiku-4.5",

      // "model": "llama/ggml-org/gemma-4-E2B-it-GGUF:Q8_0",

      "temperature": 0.1, // ultra-deterministic, repeatable
    },
    "summary": {
      "model": "github-copilot/claude-haiku-4.5",
      // "model": "github-copilot/gpt-5.4-mini",

      // "model": "bifrost-other/azure/DeepSeek-V4-Pro",

      // "model": "bifrost-openai/azure/gpt-5.4-mini",
      // "model": "bifrost-anthropic/azure/claude-haiku-4.5",

      // "model": "llama/ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M",

      "temperature": 0.1, // ultra-deterministic, repeatable
    },
    "compaction": {
      // "model": "github-copilot/claude-haiku-4.5",
      "model": "github-copilot/gpt-5.4-mini",

      // "model": "bifrost-other/azure/DeepSeek-V4-Flash",

      // "model": "bifrost-anthropic/azure/claude-haiku-4.5",
      // "model": "bifrost-openai/azure/gpt-5.4-mini",

      // "model": "llama/ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M",

      "temperature": 0.1, // ultra-deterministic, repeatable
    },
  },

  "model": "github-copilot/claude-sonnet-5",
  "small_model": "github-copilot/claude-haiku-4.5",

  // "model": "github-copilot/gpt-5.6-terra",
  // "small_model": "github-copilot/gpt-5.4-mini",

  // "model": "github-copilot/gpt-5.6-luna",
  // "small_model": "github-copilot/gpt-5.4-nano",

  // "model": "bifrost-other/azure/DeepSeek-V4-Pro",
  // "small_model": "bifrost-other/azure/DeepSeek-V4-Flash",

  // "model": "bifrost-other/azure/Kimi-K2.7-Code",
  // "small_model": "bifrost-other/azure/DeepSeek-V4-Flash",

  // "model": "bifrost-other/azure/grok-4.3",
  // "small_model": "bifrost-other/azure/DeepSeek-V4-Flash",

  // "model": "bifrost-openai/azure/gpt-5.6-terra",
  // "small_model": "bifrost-openai/azure/gpt-5.4-mini",

  // "model": "bifrost-openai/azure/gpt-5.6-luna",
  // "small_model": "bifrost-openai/azure/gpt-5.4-nano",

  // "model": "bifrost-anthropic/azure/claude-sonnet-5",
  // "small_model": "bifrost-anthropic/azure/claude-haiku-4.5",

  // "model": "llama/ggml-org/Qwen3.6-27B-GGUF:Q4_K_M",
  // "small_model": "llama/ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M",

  "enabled_providers": [
    "github-copilot", // gpt-5.4-mini, gpt-5.4-nano, gpt-5.6-terra, gpt-5.6-luna, claude-haiku-4.5, claude-sonnet-5
    "bifrost-anthropic", // claude-haiku-4.5, claude-sonnet-5, claude-opus-4-8
    "bifrost-openai", // gpt-5.4-mini, gpt-5.4-nano, gpt-5.6-terra, gpt-5.6-luna
    "bifrost-other", // grok-4.3, DeepSeek-V4-Pro, DeepSeek-V4-Flash, Kimi-K2.7-Code
    "llama", // Qwen3.5-0.8B, Qwen3.6-27B, Qwen3.6-35B, Gemma-4-12B, Gemma-4-26B, Gemma-4-E2B, Gemma-4-E4B
  ],
  "provider": {
    "bifrost-openai": {
      "npm": "@ai-sdk/openai",
      "name": "Bifrost Openai",
      "models": {
        "azure/gpt-5.6-luna": {
          "id": "gpt-5.6-luna",
          "name": "GPT 5.6 Luna",
          "provider": {
            "npm": "@ai-sdk/openai"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 1,
            "output": 6,
            "cache_read": 0.1
          }
        },
        "azure/gpt-5.6-terra": {
          "id": "gpt-5.6-terra",
          "name": "GPT 5.6 Terra",
          "provider": {
            "npm": "@ai-sdk/openai"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 2.5,
            "output": 15,
            "cache_read": 0.25
          }
        },
        "azure/gpt-5.6-sol": {
          "id": "gpt-5.6-sol",
          "name": "GPT 5.6 Sol",
          "provider": {
            "npm": "@ai-sdk/openai"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 5,
            "output": 30,
            "cache_read": 0.5
          }
        },
        "azure/gpt-5.4-mini": {
          "id": "gpt-5.4-mini",
          "name": "GPT 5.4 Mini",
          "provider": {
            "npm": "@ai-sdk/openai-compatible"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 400000,
            "output": 128000
          },
          "cost": {
            "input": 0.75,
            "output": 4.5,
            "cache_read": 0.1
          }
        },
        "azure/gpt-5.4-nano": {
          "id": "gpt-5.4-nano",
          "name": "GPT 5.4 Nano",
          "provider": {
            "npm": "@ai-sdk/openai-compatible"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 256000,
            "output": 128000
          },
          "cost": {
            "input": 0.2,
            "output": 1.25,
            "cache_read": 0.02
          }
        }
      },
      "options": {
        "baseURL": "http://localhost:8787/v1"
      }
    },
    "bifrost-other": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Bifrost Other",
      "models": {
        "azure/Kimi-K2.7-Code": {
          "id": "Kimi-K2.7-Code",
          "name": "Kimi K2.7 Code",
          "provider": {
            "npm": "@ai-sdk/openai-compatible"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text", "image"]
          },
          "interleaved": {
            "field": "reasoning_content"
          },
          "limit": {
            "context": 262144,
            "output": 131072
          },
          "cost": {
            "input": 0.95,
            "output": 4,
            "cache_read": 0.16
          }
        },
        "azure/grok-4.3": {
          "id": "grok-4.3",
          "name": "Grok 4.3",
          "provider": {
            "npm": "@ai-sdk/openai-compatible"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image"]
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 1.25,
            "output": 2.5
          }
        },
        "azure/DeepSeek-V4-Flash": {
          "id": "DeepSeek-V4-Flash",
          "name": "DeepSeek V4 Flash",
          "provider": {
            "npm": "@ai-sdk/openai-compatible"
          },
          "tool_call": true,
          "attachment": false,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text"]
          },
          "interleaved": {
            "field": "reasoning_content"
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 0.19,
            "output": 0.51
          }
        },
        "azure/DeepSeek-V4-Pro": {
          "id": "DeepSeek-V4-Pro",
          "name": "DeepSeek V4 Pro",
          "provider": {
            "npm": "@ai-sdk/openai-compatible"
          },
          "tool_call": true,
          "attachment": false,
          "reasoning": true,
          "temperature": false,
          "modalities": {
            "input": ["text"]
          },
          "interleaved": {
            "field": "reasoning_content"
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 1.74,
            "output": 3.48
          }
        }
      },
      "options": {
        "baseURL": "http://localhost:8787/v1"
      }
    },
    "bifrost-anthropic": {
      "npm": "@ai-sdk/anthropic",
      "name": "Bifrost Anthropic",
      "models": {
        "azure/claude-haiku-4-5": {
          "id": "claude-haiku-4-5",
          "name": "Claude Haiku 4.5",
          "provider": {
            "npm": "@ai-sdk/anthropic"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 200000,
            "output": 64000
          },
          "cost": {
            "input": 1,
            "output": 5,
            "cache_read": 0.1,
            "cache_write": 1.25
          },
          "options": {
            "thinking": {
              "type": "adaptive",
              "display": "summarized"
              // "budgetTokens": 8000,
            }
          }
        },
        "azure/claude-opus-4-8": {
          "id": "claude-opus-4-8",
          "name": "Claude Opus 4.8",
          "provider": {
            "npm": "@ai-sdk/anthropic"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 5,
            "output": 25,
            "cache_read": 0.1,
            "cache_write": 1.25
          },
          "options": {
            "thinking": {
              "type": "adaptive",
              "display": "summarized"
            }
          }
        },
        "azure/claude-sonnet-5": {
          "id": "claude-sonnet-5",
          "name": "Claude Sonnet 5",
          "provider": {
            "npm": "@ai-sdk/anthropic"
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "pdf"]
          },
          "limit": {
            "context": 512000,
            "output": 128000
          },
          "cost": {
            "input": 2,
            "output": 10,
            "cache_read": 0.1,
            "cache_write": 1.25
          },
          "options": {
            "thinking": {
              "type": "adaptive",
              "display": "summarized"
            }
          }
        }
      },
      "options": {
        "baseURL": "http://localhost:8787/v1"
      }
    },
    "llama": {
      "id": "llama",
      "npm": "@ai-sdk/openai-compatible",
      "name": "Llama Server",
      "models": {
        "ggml-org/Qwen3.5-0.8B-GGUF:Q8_0": {
          "name": "Qwen 3.5 0.8B",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image"],
          },
        },
        "ggml-org/Qwen3.6-27B-GGUF:Q4_K_M": {
          "name": "Qwen 3.6 27B",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "video"],
          },
        },
        "ggml-org/Qwen3.6-35B-A3B-GGUF:Q4_K_M": {
          "name": "Qwen 3.6 35B",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "video"],
          },
        },
        "ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_K_M": {
          "name": "Gemma 4 26B-A4B IT QAT",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "audio", "video"],
          },
        },
        "ggml-org/gemma-4-12B-it-GGUF:Q4_0": {
          "name": "Gemma 4 12B IT QAT",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "audio", "video"],
          },
        },
        "ggml-org/gemma-4-E4B-it-GGUF:Q4_K_M": {
          "name": "Gemma 4 E4B IT QAT",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "audio", "video"],
          },
        },
        "ggml-org/gemma-4-E2B-it-GGUF:Q8_0": {
          "name": "Gemma 4 E2B IT QAT",
          "limit": {
            "context": 128000,
            "output": 32000,
          },
          "tool_call": true,
          "attachment": true,
          "reasoning": true,
          "temperature": true,
          "modalities": {
            "input": ["text", "image", "audio", "video"],
          },
        },
      },
      "options": {
        "baseURL": "http://localhost:2276/v1",
        "timeout": 900000,
      },
    },
  },
  "mcp": {
    "searxng": {
      "type": "local",
      "command": ["npx", "-y", "mcp-searxng"],
      "enabled": true,
      "environment": {
        "SEARXNG_URL": "http://localhost:8348"
      }
    },
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp@latest"],
      "enabled": false
    },
    "context7": {
      "type": "remote",
      "enabled": true,
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "Authorization": "Bearer context7-api-key"
      }
    },
    "crawl4ai": {
      "type": "remote",
      "enabled": true,
      "url": "http://localhost:11235/mcp/sse",
      "headers": {
        "Authorization": "Bearer local-crawl4ai-api-token"
      }
    }
  }
}
```
