# Roadmap: token metering & dashboard

Delivery plan for the remainder of build brief §B10's token-metering feature. Design detail lives in `03-architecture.md`; this doc sequences it into shippable, independently-gated milestones. Kept here (not under `docs/specs/`, which is gitignored) so it stays a committed, citable reference.

Implementation code (`db.py`, `parser.py`, `pricing.py`, `server.py`, `frontend/`) targets the `token-metering` git submodule (`cairn-2.0-token-metering`), not `tools/tokens/` in this repo. This repo keeps the design docs plus the two artifacts that stay cairn's own — `hooks/stop-tokens.sh` (M2) and `commands/cairn-tokens.md` (M6) — which reach across the submodule boundary to invoke the code. `tools/budget.py`'s gate covers only what ships from this repo; it doesn't run against the submodule.

## Status

- Done: dashboard mockup (`mockups/dashboard.html`, intentionally not formalized into a design system — one screen, not worth the overhead yet).
- **Not yet ported**: a `calls`/`usage_limit_events` schema + tests exist, but only in this repo's pre-split `tools/tokens/db.py`/`test_db.py` (committed at `9c0ff58`), plus an uncommitted `tool_uses` addition on top of that file. None of it has been ported into `token-metering/db.py`, which currently has no code at all — only `CLAUDE.md`/`README.md`/`.harness/`. Porting this (and deciding `tools/tokens/`'s fate in this repo) is Track A's M1 Step 0, not a completed prerequisite — see `GOAL-STATE.md`'s log.
- Unbuilt: everything below.

## Milestones

Each milestone is one artifact-set, one commit, gated by relevant `pytest`/`--selftest` (plus `python tools/budget.py` for the artifacts that ship from this repo — `hooks/`, `commands/`) before moving to the next (§A13).

### M1 — `token-metering/db.py` (schema addition) + `token-metering/parser.py`

`db.py` gains a `tool_uses` table before `parser.py` is written against it. Transcript walker: builds the `{agentId: subagent_type}` map from the main transcript's `Agent`/`Task` tool_use/tool_result pairs, then walks the main transcript (tagged `agent="main"`) and every `subagents/agent-*.jsonl` file (tagged via the map, default `"unknown"`), inserting each unique `requestId` into `calls` and each unique `tool_use_id` into `tool_uses`. Routes `isApiErrorMessage: true` entries to `usage_limit_events` instead of `calls`.

- Depends on: `db.py`'s existing schema + its `tool_uses` addition.
- Tests: synthetic fixture transcripts for main+subagent attribution, a duplicate-`requestId` case, a duplicate-`tool_use_id` case, an unmatched-`agentId` case (→ `"unknown"`), a synthetic-error case (→ routed, not counted).
- Gate: `pytest test_db.py test_parser.py` inside `token-metering/`, per that repo's own `.harness/workflow.md` — no `tools/budget.py`.

### M2 — `hooks/stop-tokens.sh`

`Stop` hook wiring. Mirrors `hooks/session-start.sh`'s style: `set -uo pipefail`, extracts `transcript_path`/`session_id`/`cwd` via `jq`, checks the opt-in marker, shells out to a Python entry point that runs `token-metering/parser.py` against the just-ended session. When the install scope is user/local rather than project, appends the project path to `~/.claude/cairn/known-projects.json` (creating it if absent). Silent `exit 0` on any missing `jq`, missing field, or missing opt-in — capture is advisory, never blocking.

- Depends on: M1.
- Tests: `--selftest` per repo convention; manual check that a second `Stop` on the same session doesn't duplicate rows (`INSERT OR IGNORE` on `request_id` already guarantees this at the `db.py` layer — this step confirms the hook actually re-invokes the parser rather than skipping).
- Gate: `budget.py` clean (hook body stays advisory-only, no gating logic).

### M3 — `token-metering/prices.json` + `pricing.py`

Checked-in `model → $/MTok` table, applied at read time only (never at write time). Unrecognized model → `cost: "unknown"` for that call; a rollup group containing any unpriced model → `cost: null`, never a silently-partial sum.

- Depends on: nothing (pure data + pure function over `db.py`'s rows).
- Tests: known-model pricing, unknown-model → `"unknown"`, mixed-group rollup → `null`.
- Gate: `pytest test_pricing.py` inside `token-metering/`.

### M4 — `token-metering/server.py`

Local dashboard server: Python stdlib `http.server` + `sqlite3`, binds `localhost` only, foreground, stops on Ctrl-C. JSON API: rollups by day/session/agent/tool/skill/MCP-server, the day-of-week × hour-of-day heatmap, per-session call trace, on-demand prompt/response lookup read from the transcript file (never duplicated into `tokens.db`). Also where these decisions land: per-day chart range/bucket sizes (Today/7D/30D/Month/6M/Life), unioning other projects' dbs via `~/.claude/cairn/known-projects.json` when present, and a defined "unavailable" response shape when a trace row's transcript file has been moved/deleted or `tokens.db` is empty/missing (cold start). Serves a catch-all → `index.html` fallback so the M5 frontend's client-side `/call/<session>/<n>` route resolves on direct load/refresh.

- Depends on: `db.py`, M3.
- Tests: rollup correctness against a seeded `tokens.db` (including `tool_uses` rollups and heatmap bucketing), trace ordering, unpriced-model `null` propagation, cross-project union against a seeded `known-projects.json`.
- Gate: `pytest test_server.py` inside `token-metering/`.

### M5 — `token-metering/frontend/`

Dev-time React 19 + Vite + Recharts + Tailwind + shadcn/ui + `@tanstack/react-query` (polling at a 15-second interval) source, matching the approved `mockups/dashboard.html` views/states (empty/cold-start, populated, per-session trace expansion, transcript-unavailable trace detail, usage-limit warning banner). Compiled once by maintainers to `token-metering/static/`, which is what actually ships — Node/npm never runs on a consuming project's machine.

- Depends on: M4 (API shape it polls against).
- Tests: Playwright e2e suite under `token-metering/frontend/e2e/`, run against the built `static/` bundle served by `server.py` — covers every `mockups/dashboard.html` state plus the `/call/<session>/<n>` deep-link route; manual only for the 15s-poll timing check.
- Gate: `npm run build` inside `token-metering/frontend/` regenerates `static/`, then `npx playwright test` against that build, per that repo's `.harness/workflow.md` — no `tools/budget.py`.

### M6 — `commands/cairn-tokens.md`

Starts `token-metering/server.py` in the background, opens the default browser to it.

- Depends on: M4, M5.
- Tests: manual end-to-end (`03-architecture.md`'s Testing section) — run a real session with ≥1 subagent dispatch, let `Stop` fire, run `/cairn-tokens`, confirm rollups, trace expansion, and warning banner.
- Gate: full §A13 gate + relevant §B12 acceptance criteria (26: token report opens correctly from `file://` — recheck against the live-server amendment).

## Design decisions behind the milestones

Full detail lives in `03-architecture.md`'s Capture side / Serving side and `02-requirements.md`'s Open Questions section (each marked **Resolved**). Summary:

| Decision | Resolution | Milestone impact |
|---|---|---|
| Tool/skill/MCP-server rollups + activity heatmap | New `tool_uses` table, one row per `tool_use` block, keyed on the block's own id. Skill/MCP-server names parsed at query time from `tool_name`/`detail`. Heatmap buckets `calls.timestamp` — no new capture. | Schema addition folded into **M1**, before `parser.py` is written against it. |
| Project-scope rollup (user/local-scope installs) | Per-project `.cairn/tokens.db` unchanged; a `~/.claude/cairn/known-projects.json` registry, appended to by the `Stop` hook, lets `server.py` discover and union other projects. No schema change, no impact on project-scoped installs (the common case). | Hook append logic in **M2**; union logic in **M4**. |
| Per-day chart range tabs (Today/7D/30D/Month/6M/Life) | Pure query-time bucketing of `calls.timestamp` — no schema impact. Exact day-counts per tab deferred to when the queries are actually written (the mockup's own labels disagree with its placeholder data: "7D" shows "Last 19 days"). | Decided during **M4**. |
| Call-detail deep-linking | Client-side `/call/<session>/<n>` route (drawer in-app, standalone page on direct load), `server.py` serves a catch-all → `index.html` fallback. | Server fallback in **M4**; route in **M5**. |
| Dashboard polling interval | 15 seconds — capture only ever happens on a `Stop` event, so polling faster surfaces no new data sooner in the common case; 15s still feels live when a second session's `Stop` fires while the dashboard is open, without hammering the sqlite read path. | Tuning detail folded into **M4**/**M5**. |
| Trace-row behavior when the transcript file has been moved/deleted | Tokens/cost/duration still render from `tokens.db` (captured at parse time, unaffected). The on-demand prompt/response lookup returns a defined "unavailable" response shape instead of an error; the frontend renders a graceful "transcript unavailable" state in the trace-row detail. | Server response shape in **M4**; frontend rendering in **M5**. |
| Cold-start behavior (`/cairn-tokens` run before any `Stop` event, empty/missing `tokens.db`) | Dashboard still starts and loads normally, showing an empty-state message in place of the rollup bars/session list rather than erroring. | Frontend empty state in **M5**; no schema or capture impact on **M4**. |

## Testing (cross-milestone)

- Unit tests per component under `token-metering/test_*.py`, `tmp_path`-based, mirroring `tools/test_budget.py`'s style (per `03-architecture.md`'s own Testing section).
- Playwright e2e suite under `token-metering/frontend/e2e/` for M5, run against the built `static/` bundle.
- `hooks/stop-tokens.sh --selftest`.
- Manual end-to-end pass after M6, per `03-architecture.md`: real session → `Stop` fires → `sqlite3` CLI inspection → `/cairn-tokens` → dashboard confirms rollups, trace expansion, warning banner, and idempotency on a second `Stop`.
