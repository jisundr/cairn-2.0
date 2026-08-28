# Architecture: token metering & dashboard (Phase 2)

## Architecture

Two pieces: a `Stop` hook that captures usage into SQLite (mirrors `hooks/session-start.sh`'s advisory-only, silently-degrading style), and a dashboard (Python stdlib server + prebuilt static frontend) that reads it at query time.

**Capture side:**
- One call can span several transcript entries (e.g. a thinking block and a text block) sharing a `requestId` and an identical `usage` snapshot — per-line counting would double-count, so `requestId` is the dedup key.
- A dispatched subagent's calls do not appear inline in the parent transcript; they land in a sibling file, `<session_id>/subagents/agent-<agentId>.jsonl`. The subagent's own file carries an `agentId` but not its name (`planner`, etc.) — that only exists in the parent transcript's `Agent`/`Task` tool_use block's `input.subagent_type`. Attribution requires cross-referencing the parent's tool_use/tool_result pairs (the `agentId` appears embedded in the tool_result's text, `"agentId: <hex>"`, not as structured JSON) to build an `{agentId: subagent_type}` map, then tagging each call in the matching `subagents/agent-*.jsonl` file. Unmatched → `"unknown"`. Cairn's own 4 agents have no `Agent`/`Task` grant, so one level of `subagents/` is sufficient scope.
- Synthetic usage-limit entries are marked `isApiErrorMessage: true` with a zeroed-but-present `usage` object — routed to a separate table, never counted as a call.
- Full transcript rescan on every `Stop` event, made idempotent via `INSERT OR IGNORE` keyed on `request_id` — no offset tracking. Accepted as the starting approach; revisit only if measurably slow.
- Prices are looked up at read time from a checked-in `model → $/MTok` table, never baked in at write time — a price change is a data edit, not a migration. An unrecognized model reports `cost: unknown`; a rollup containing any unpriced model reports `null`, never a partial sum.
- **Tool/skill/MCP-server rollups and the activity heatmap** come from the same transcript walk, no separate capture step. A single assistant turn can fire several `tool_use` blocks sharing one `requestId`, so this can't be a column on `calls` — it's a separate `tool_uses` table, one row per `tool_use` block: `tool_use_id` (the block's own id, e.g. `toolu_...`) as primary key, so a re-scan is idempotent via `INSERT OR IGNORE` the same way `calls.request_id` is; `request_id` FK; `session_id`; `agent`; `tool_name` (raw, e.g. `Bash`, `Skill`, `mcp__claude-in-chrome__navigate`); `detail` (nullable — the invoked skill name for `Skill` calls, null otherwise); `timestamp`. Which skill and which MCP server are parsed from `tool_name`/`detail` at query time in `server.py`, mirroring pricing's read-time philosophy rather than normalizing at capture time. The heatmap needs no new capture at all — it's a day-of-week × hour-of-day bucketing of `calls.timestamp`, done at query time in `server.py`.

**Serving side (over the original brief's "self-contained HTML file"):**
- Server: Python stdlib `http.server` + `sqlite3` — no new pip dependency, matching `tools/budget.py`'s existing zero-pip footprint. Binds `localhost` only, runs in the foreground of the launching terminal, stops on Ctrl-C — no separate stop command, no background daemon.
- Frontend: React 19 + Vite + Recharts + Tailwind + shadcn/ui (components copied into the plugin's own source, not pulled in as a runtime kit) + `@tanstack/react-query` for polling refresh. Built once by cairn's maintainers; the compiled static output (plain JS/CSS/HTML) is checked into the plugin. Node/npm is a cairn-dev-time-only dependency — a consuming project running `/cairn-tokens` never installs or builds anything.
- Decided over CodeBurn and LangSmith as comparables: per-session drill-down (CodeBurn) and a run timeline (LangSmith) shaped the per-session/call-trace view; CodeBurn's own choice not to reach for a charting library for simple rollup bars is mirrored here (Recharts is available in the stack for the per-day trend graph, not required for the bars).
- **Cross-project rollup** (user/local-scope installs, which can fire hooks across every project on the machine): each project keeps its own `.cairn/tokens.db` exactly as at project scope — no schema change, no shared write target. A small `~/.claude/cairn/known-projects.json`, appended to by `hooks/stop-tokens.sh` with the project's path whenever it fires outside project scope, lets `server.py` discover and union the other `.cairn/tokens.db` files it knows about. Project-scoped installs (the common case) never touch or read this file — the dashboard only ever sees its own project's db.
- **Call-detail deep-linking**: a trace row's detail is a client-side route (`/call/<session>/<n>`) that renders as a drawer when navigated to in-app and as a standalone page on direct load or refresh, matching the GitLab issue-drawer pattern the mockup is modeled on. `server.py` serves a catch-all → `index.html` fallback for any non-API path so a direct load/refresh resolves client-side rather than 404ing on the stdlib server.
- **Per-day chart range windows** (Today/7D/30D/Month/6M/Life): bucket size is a query-time decision over `calls.timestamp` — no new capture, no schema impact. Exact day-counts per tab (the mockup's placeholder data doesn't fully agree with its own tab labels) are pinned down when `server.py`'s rollup queries are actually written, not before.

## Components

| Component | What it does | Depends on |
|---|---|---|
| `tools/tokens/db.py` | SQLite schema (`calls`, `usage_limit_events`, `tool_uses`) + connection/insert helpers | stdlib `sqlite3` |
| `tools/tokens/parser.py` | Walks a session's transcript + its `subagents/*.jsonl` files, attributes each call and each `tool_use` block to an agent, dedups calls on `requestId` and tool uses on `tool_use_id`, routes usage-limit entries separately | `tools/tokens/db.py` |
| `hooks/stop-tokens.sh` | `Stop` hook — mirrors `hooks/session-start.sh`'s style; shells out to a Python entry point that runs the parser against the just-ended session; appends to `~/.claude/cairn/known-projects.json` when firing outside project scope | `tools/tokens/parser.py`, `jq` |
| `tools/tokens/prices.json` + `pricing.py` | Checked-in `model → $/MTok` price table, applied at read time | none |
| `tools/tokens/server.py` | Local dashboard server — serves the prebuilt static frontend plus a JSON API (rollups by day/session/agent/tool/skill/MCP-server, heatmap, per-session call trace); unions other projects' dbs via `known-projects.json` when present; catch-all → `index.html` fallback for client-side routes | `tools/tokens/db.py`, `tools/tokens/pricing.py` |
| `tools/tokens/frontend/` | Dev-time React/Vite source; compiled to `tools/tokens/static/`, which is what actually ships | React 19, Vite, Recharts, Tailwind, shadcn/ui, `@tanstack/react-query` |
| `commands/cairn-tokens.md` | Starts `tools/tokens/server.py` in the background, opens the default browser to it | `tools/tokens/server.py` |

## Data flow

1. A cairn session runs, dispatching zero or more subagents (`planner`/`builder`/`reviewer`/`scribe`).
2. On `Stop`, `hooks/stop-tokens.sh` fires, extracts `transcript_path`/`session_id`/`cwd`, and (if the project has opted in) invokes `tools/tokens/parser.py` against the transcript.
3. The parser builds the `{agentId: subagent_type}` map from the main transcript, then walks the main transcript (tagged `agent="main"`) and every `subagents/agent-*.jsonl` file (tagged via the map, default `"unknown"`), inserting each unique `requestId` into `calls` (or `usage_limit_events` for synthetic error entries) via `tools/tokens/db.py`.
4. `/cairn-tokens` starts `tools/tokens/server.py`, which opens the default browser to the dashboard.
5. The frontend polls the server's JSON API; the server reads `.cairn/tokens.db`, applies `tools/tokens/prices.json` at query time, and returns priced rollups/traces.

## Error handling

- Any missing `jq`, missing transcript field, or missing opt-in marker in `hooks/stop-tokens.sh` → silent `exit 0`, mirroring `hooks/session-start.sh`. Capture is advisory-only; it never blocks or alters a session.
- A transcript entry whose `agentId` doesn't match any `Agent`/`Task` tool_use in the parent → tagged `"unknown"` rather than dropped or failing the parse.
- A model with no entry in `prices.json` → that call's cost reports `"unknown"`; any rollup group containing it reports `cost: null` rather than a silently partial sum.
- A second `Stop` event re-scanning an already-recorded session → `INSERT OR IGNORE` on `request_id` means no duplication, no error.

## Testing

- `tools/tokens/db.py`, `parser.py`, `pricing.py`, `server.py` each get unit tests under `tools/tokens/test_*.py`, mirroring `tools/test_budget.py`'s `tmp_path`-based style — including synthetic fixture transcripts for the two-file main+subagent case, a duplicate-`requestId` case, a duplicate-`tool_use_id` case, and unknown-model/partial-group-null cases for pricing.
- `hooks/stop-tokens.sh` gets a `--selftest` mode per the repo's existing shell-script convention.
- Manual end-to-end: run a real session that dispatches at least one subagent, let `Stop` fire, inspect `.cairn/tokens.db` via the `sqlite3` CLI to confirm `calls` rows exist with correct `agent` attribution, and confirm a second `Stop` doesn't duplicate them.
- Run `/cairn-tokens`, confirm the dashboard loads, an agent's rollup row expands into its call trace, and a synthetic `usage_limit_events` row surfaces the warning banner.
