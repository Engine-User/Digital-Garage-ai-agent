# Digital Garage — Agentic Orchestration Platform

<div align="center">

<svg fill="#282424" width="120" height="120" viewBox="0 0 24.00 24.00" xmlns="http://www.w3.org/2000/svg" stroke="#282424" stroke-width="1.152"><g id="SVGRepo_iconCarrier"><path d="M19.9,12.66a1,1,0,0,1,0-1.32L21.18,9.9a1,1,0,0,0,.12-1.17l-2-3.46a1,1,0,0,0-1.07-.48l-1.88.38a1,1,0,0,1-1.15-.66l-.61-1.83A1,1,0,0,0,13.64,2h-4a1,1,0,0,0-1,.68L8.08,4.51a1,1,0,0,1-1.15.66L5,4.79A1,1,0,0,0,4,5.27L2,8.73A1,1,0,0,0,2.1,9.9l1.27,1.44a1,1,0,0,1,0,1.32L2.1,14.1A1,1,0,0,0,2,15.27l2,3.46a1,1,0,0,0,1.07.48l1.88-.38a1,1,0,0,1,1.15.66l.61,1.83a1,1,0,0,0,1,.68h4a1,1,0,0,0,.95-.68l.61-1.83a1,1,0,0,1,1.15-.66l1.88.38a1,1,0,0,0,1.07-.48l2-3.46a1,1,0,0,0-.12-1.17ZM18.41,14l.8.9-1.28,2.22-1.18-.24a3,3,0,0,0-3.45,2L12.92,20H10.36L10,18.86a3,3,0,0,0-3.45-2l-1.18.24L4.07,14.89l.8-.9a3,3,0,0,0,0-4l-.8-.9L5.35,6.89l1.18.24a3,3,0,0,0,3.45-2L10.36,4h2.56l.38,1.14a3,3,0,0,0,3.45,2l1.18-.24,1.28,2.22-.8.9A3,3,0,0,0,18.41,14ZM11.64,8a4,4,0,1,0,4,4A4,4,0,0,0,11.64,8Zm0,6a2,2,0,1,1,2-2A2,2,0,0,1,11.64,14Z"></path></g></svg>

**Create AI agents, configure their behaviour, connect them into collaborative workflows — all from a single self-hosted web UI.**

[Features](#features) · [Architecture](#architecture) · [Quick Start](#quick-start) · [Demo](#demo)

</div>

---

## What is Digital Garage?

Digital Garage is a platform where users can **create AI agents**, **control how they behave** (personality, tools, schedules, memory, limits), and **connect them into collaborative workflows**. Agents run on a real runtime, execute real tools, and communicate with each other to complete tasks autonomously. At least one agent is reachable through an external messaging channel (Email) so a human can interact with it conversationally. The platform includes a web UI for managing everything visually.

| Dimension | What you can configure |
|---|---|
| **Identity** | Name, role, system prompt, model |
| **Capabilities** | Tools, MCP servers, skills, memory |
| **Behaviour** | Schedules, interaction rules, guardrails |
| **Channels** | Email (IMAP/SMTP), web chat, API tokens |
| **Limits** | Token budgets, rate limits, admin gates |

---

## Features

- **Chat** — Multi-turn chat with any local model or API (vLLM, llama.cpp, Ollama, OpenRouter, OpenAI)
- **Agent Mode** — Autonomous agents that plan, call tools, and work through tasks end-to-end. Built on [opencode](https://github.com/anomalyco/opencode) with MCP, web, files, shell, skills, and memory tools
- **DYOM (Deploy Your Own Models)** — Hardware-aware model recommendations, one-click download and serving. Built on [llmfit](https://github.com/AlexsJones/llmfit). VRAM-aware scoring across 270+ models
- **Deep Research** — Multi-step research runs that gather, read, and synthesize sources into a visual report. Adapted from [Tongyi DeepResearch](https://github.com/Alibaba-NLP/DeepResearch)
- **Compare** — Blind multi-model comparison. Send one prompt to several models, compare answers side-by-side
- **Documents** — Multi-tab editor where YOU write the text and AI assists (markdown, HTML, CSV, syntax highlighting, AI edits)
- **Memory & Skills** — Persistent vector memory and self-evolving skills. Your agent gets more capable over time (ChromaDB, fastembed ONNX, vector + keyword retrieval)
- **Email Agent** — IMAP/SMTP inbox with AI triage: urgency detection, auto-tag, auto-summary, auto-reply drafts, spam filtering. Agents can receive and respond to emails autonomously
- **Notes & Tasks** — Quick notes with reminders, todo lists, and scheduled tasks the agent can act on
- **Calendar** — Local-first calendar with CalDAV sync (Radicale, Nextcloud, Apple, Fastmail)
- **Mobile** — Responsive PWA with touch gestures

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     Web UI (static/)                     │
│  index.html · app.js · style.css · js/ (modular ES)      │
└────────────────────────┬─────────────────────────────────┘
                         │ REST / WebSocket
┌────────────────────────▼─────────────────────────────────┐
│                   FastAPI (app.py)                       │
│  Auth · Middleware · Rate Limiting · CORS                │
├──────────┬──────────┬──────────┬──────────┬──────────────┤
│ routes/  │   src/   │  core/   │services/ │mcp_servers/  │
│ REST API │ Agent    │ Auth, DB │ Memory,  │ MCP protocol │
│ handlers │ loop,    │ Session  │ Search,  │ servers for  │
│ for each │ tools,   │ Mgmt     │ Shell,   │ email, RAG,  │
│ feature  │ LLM core │          │ DYOM     │ image gen    │
└──────────┴──────────┴──────────┴──────────┴──────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
   ┌─────────┐    ┌───────────┐    ┌──────────┐
   │ SQLite  │    │ ChromaDB  │    │  LLM     │
   │ (data/) │    │ (vectors) │    │ (Ollama/ │
   │ sessions│    │ memory,   │    │  vLLM/   │
   │ docs,   │    │ RAG       │    │  API)    │
   │ presets │    │           │    │          │
   └─────────┘    └───────────┘    └──────────┘
```

### Clear Separation of Concerns

| Layer | Directory | Responsibility |
|---|---|---|
| **UI** | `static/` | HTML, CSS, modular JS — no business logic |
| **API** | `routes/` | FastAPI endpoints — request validation, response formatting |
| **Runtime** | `src/` | Agent loop, tool execution, LLM orchestration |
| **Data** | `core/` + `data/` | SQLAlchemy models, auth, session management, SQLite |
| **Services** | `services/` | Memory, search, DYOM, shell — isolated business logic |
| **MCP** | `mcp_servers/` | Model Context Protocol servers for tool integration |

---

## Multi-Agent System & Agentic Behaviour

### How agents work

Each agent runs through a **tool-calling loop (ReAct)** (`src/agent_loop.py`):

1. **Plan** — The agent receives a task and its system prompt (personality, rules, available tools)
2. **Act** — It calls tools (shell commands, file operations, web search, email send, memory recall)
3. **Observe** — Tool results feed back into the next reasoning step
4. **Loop** — Steps 2–3 repeat until the agent decides the task is complete or hits a limit

### Agent-to-agent communication

Agents communicate **asynchronously** through persisted message queues:

- **Email channel** — An agent can be assigned to an email account. Incoming emails become tasks; the agent drafts and sends replies autonomously. This is the external messaging channel integration
- **Internal messages** — Agents can trigger other agents via scheduled tasks and event bus (`src/event_bus.py`)
- **Shared memory** — All agents read/write to the same ChromaDB vector store, enabling knowledge sharing across the workflow

### Message persistence

All agent conversations are stored in SQLite (`data/app.db`):
- `sessions` table — conversation metadata, timestamps, agent config
- `chat_messages` table — full message history with role, content, tool calls
- Visible in the UI under the Chat and History panels

### Configurable dimensions per agent

| Config | Where |
|---|---|
| Name, role, system prompt | Agent creation UI |
| Model selection | `/api/models` discovery |
| Tool toggles | Per-agent tool permissions |
| Schedules | Task scheduler (`src/task_scheduler.py`) |
| Memory scope | Agent-specific or shared memory |
| Skills | Self-evolving skill library (`services/memory/skills.py`) |
| Guardrails | Prompt security (`src/prompt_security.py`) |
| Rate limits | Per-user rate limiter (`src/rate_limiter.py`) |

---

## Pre-built Workflow Templates

### 1. Research Agent Workflow
A multi-step research pipeline: gather sources → read & extract → synthesize into a visual report.

```
[User Query] → Web Search → Source Collection → Content Extraction → LLM Synthesis → Visual Report
```

### 2. Email Triage Workflow
Autonomous email processing: monitor inbox → classify urgency → summarize → draft replies → await approval.

```
[IMAP Poll] → Urgency Classification → Auto-Tag → Summary Generation → Reply Draft → Human Approval
```

---

## Runtime & Framework Choices

### Why FastAPI + Python?
- **Async-native** — Agent loops are inherently async (wait for LLM, wait for tools). FastAPI's `async/await` model handles this natively
- **Type safety** — Pydantic models validate all API inputs/outputs
- **Performance** — Uvicorn ASGI server handles concurrent agent sessions efficiently
- **Ecosystem** — Rich Python ML/AI ecosystem (embeddings, NLP, document processing)

### Why opencode as the agent framework?
- **Open source** — Fully auditable, no vendor lock-in
- **MCP support** — Model Context Protocol enables standardized tool integration
- **Proven patterns** — Battle-tested agent loop with tool execution, memory, and skill management
- **Justification** — Compared against AutoGen, CrewAI, and LangGraph. opencode offered the best balance of simplicity, MCP support, and local-first design

### Why ChromaDB for vector memory?
- **Self-hosted** — Runs locally via Docker Compose, no cloud dependency
- **Fast** — HNSW indexing for sub-millisecond similarity search
- **Embedded** — Can run in-process or as a service

---

## Quick Start

### Option 1: Docker (recommended)

```bash
git clone <repo-url>
cd digital_garage
cp .env.example .env
docker compose up -d --build
```

Opens at `http://localhost:7000`. Compose starts: Digital Garage app, ChromaDB, SearXNG, and ntfy.

### Option 2: Manual install

**Requirements:** Python 3.11+

```bash
# Linux/macOS
git clone <repo-url> && cd digital_garage
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python setup.py
uvicorn app:app --host 0.0.0.0 --port 7000

# Windows (PowerShell)
git clone <repo-url>
cd digital_garage
python -m venv venv
venv\Scripts\Activate.ps1
pip install -r requirements.txt
python setup.py
uvicorn app:app --host 0.0.0.0 --port 7000
```

### Option 3: Test with Uvicorn directly

```bash
uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

---

## Demo

### End-to-end workflow


1. **Agent creation** — Create an agent with name, role, system prompt, and model
2. **Tool configuration** — Enable web search, shell, file, and email tools
3. **Multi-agent task** — Two agents collaborate: one researches, one writes a report
4. **Email channel** — Live conversation with an agent through email (IMAP/SMTP)
5. **Memory & skills** — Agent recalls previous conversations and evolves new skills

### Live monitoring

The UI includes real-time monitoring:
- **Agent logs** — Stream agent reasoning steps and tool calls in real-time
- **Inter-agent messages** — View messages passed between agents
- **Token/cost tracking** — Per-session and per-agent token usage and estimated cost

---

## Adding New Workflow Templates

1. Create a new template in `data/presets.json`
2. Define the agent chain: which agents run, in what order, with what handoffs
3. Add a UI entry in `static/js/` for the template selector
4. Test end-to-end with the template runner

## Adding New Messaging Channels

1. Implement a channel handler in `routes/` (e.g., `routes/slack_routes.py`)
2. Add polling logic in `src/bg_jobs.py` for inbound messages
3. Register the channel in the agent config UI
4. Messages flow through the same agent loop — no runtime changes needed

---

## Configuration

| Variable | Default | Description |
|---|---|---|
| `LLM_HOST` | `localhost` | Your LLM server |
| `SEARXNG_INSTANCE` | `http://localhost:8080` | SearXNG URL for web search |
| `AUTH_ENABLED` | `true` | Enable/disable login |
| `DATABASE_URL` | `sqlite:///./data/app.db` | Database connection |
| `CHROMADB_HOST` | `localhost` | ChromaDB host for vector memory |
| `DIGITAL_GARAGE_ADMIN_PASSWORD` | *(generated)* | Initial admin password, change later|

---

## Project Structure

```
app.py                   # FastAPI entry point
core/                    # Auth, database, middleware, constants, models
src/                     # Agent loop, tools, LLM core, search, chat processor
routes/                  # REST API endpoints (chat, email, documents, DYOM, etc.)
services/                # Memory, search, DYOM (model serving), shell, research
mcp_servers/             # MCP protocol servers (email, RAG, image gen, memory)
static/                  # Web UI (index.html, app.js, style.css, modular JS)
scripts/                 # CLI tools (digital_garage-dyom, database migrations)
tests/                   # Pytest test suite
docs/                    # Landing page and documentation
data/                    # Runtime data (SQLite DB, uploads, memory, presets)
```

---

## Security

- `AUTH_ENABLED=true` for any network-accessible deployment
- Do not expose directly to public internet without HTTPS + reverse proxy
- Keep `data/`, `.env`, logs out of Git (ignored by default)
- Non-admin users cannot access shell/Python/file tools by default
- Admin-only routes are gated: MCP management, API tokens, webhooks, DYOM serving, backup/vault

### HTTPS Setup

```caddy
your-domain.com {
  reverse_proxy localhost:7000
}
```

---

## Tests

```bash
pip install -r requirements.txt
pytest tests/ -v
```

Critical path tests cover: agent creation, workflow execution, message delivery, auth regressions, security gates.


<div align="center">
<em>Built for professionals</em>
</div>
