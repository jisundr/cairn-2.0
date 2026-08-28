# Requirements: token metering & dashboard (Phase 2)

## Problem

Cairn has no way to measure its own token cost. `/cairn-tokens` is listed in the commands table (build brief §B9) but was intentionally left unbuilt — it depends entirely on metering data that doesn't exist yet. Without it, the default (≤ 40k) and escalated (≤ 150k) token budgets in `skills/start/SKILL.md` are stated assumptions, not measured facts, and there's no way to tell which agent, phase, or session is driving cost on a real task.

**Amends build brief §B10**, which now points here for the full requirements and to `docs/features/token-metering/03-architecture.md` for the design. The original brief called for "a self-contained HTML file — no server, no CDN"; this doc replaces that with a live local dashboard.

## Goals

- Capture every model API call cairn triggers, without double-counting or missing calls.
- Persist usage data so it can be queried by day, session, agent, and model.
- Roll up non-token activity from the same transcript walk: which tools were called, which skills were invoked, and which MCP servers were used — plus a day-of-week × hour-of-day view of when calls happen. No separate capture step; these all come from tool_use blocks already present in the transcript.
- Distinguish usage-limit events (hitting a rate/quota ceiling) from normal usage — they must never be counted as ordinary calls.
- Price usage using current rates, without requiring a data migration when prices change.
- Serve a live local dashboard (`/cairn-tokens` starts it and opens the browser) with per-day, per-session, and per-agent rollups.
- Dashboard data refreshes automatically on an interval, plus a manual refresh control for an immediate check.
- **Per-session view is the primary surface**: each agent's rollup (`planner`/`builder`/`reviewer`/`scribe`) expands into its own call-by-call trace, in order, with tokens/cost/duration per call.
- A trace row can reveal that call's actual prompt and response — read on demand from the session's transcript file rather than duplicated into `tokens.db` at capture time.
- Rollups are visualized with charts (per-day, per-agent totals).
- The per-day chart supports drilling into a single day's per-model breakdown (tokens and cost per model), modeled on CodeBurn's chart pattern.
- Show a visible warning in the dashboard whenever a usage-limit event was recorded in the period covered.
- When cairn is installed at user or local scope (Claude Code's plugin scope levels, not just project scope) rather than in a single project, roll up captured usage per project and let the dashboard be filtered down to one.

## Non-goals

- Real-time push updates mid-call — the dashboard reflects the last completed session activity, refreshed by polling, not a live stream of an in-progress session.
- Billing or invoicing integration — this is a local diagnostic, not a cost-recovery system.
- Metering any session cairn's own hooks didn't capture — a different plugin's session, or a project that hasn't opted into cairn. This bounds *when/where* capture happens, not *what* gets counted within a captured session: a session's transcript can contain any tool, any skill, and any subagent (cairn's four or otherwise — `Explore`, `general-purpose`, a project's own custom agent), and all of it is in scope for the rollups once that session is captured.
- A shared or remote datastore, or multi-machine access — data and server both stay local to the developer's own machine.
- A native desktop app — browser-based dashboard only.
- Storing prompt/response text in `tokens.db` — content is read from the session's transcript file on demand, never duplicated into the metering store.

## Stakeholders

- Developers running cairn on their own projects — the direct audience for the dashboard.
- Cairn's own maintainers — need real usage data to validate or retune the 40k/150k budget figures in `skills/start/SKILL.md`, and own the dashboard's build step.

## Constraints & assumptions

- Metering capture stays advisory-only (§B10: "Hooks nudge; they never gate") — it must never block or alter a session, regardless of how the data is later displayed.
- No new runtime dependency for consuming projects — a project running `/cairn-tokens` never installs or builds anything itself.
- Data and server stay local to the developer's machine — no remote or shared datastore (see Non-goals).
- The live server is local-only, started on demand by `/cairn-tokens`, not a background daemon — no new always-on process.
- Cairn's plugin install scope decides how many projects one capture stream can span: at project scope (the common case) a project only ever sees its own usage, so per-project rollup/filtering is moot; at user or local scope, hooks can fire across every project on the machine cairn is active in. Rolling up across those projects still satisfies the "local to the developer's own machine" constraint above — it's aggregation across that one machine's own project directories, not a shared or remote store.

## Open questions

- Exact polling interval for dashboard refresh (e.g. 10s vs 30s) — a tuning detail, not an architectural one.
- What a trace row shows if its transcript file has since been moved or deleted — tokens/cost/duration still come from `tokens.db`, but the on-demand prompt/response lookup would have nothing to read.
- **Resolved** — call-detail deep-linking: `03-architecture.md`'s Serving side now specifies a client-side `/call/<session>/<n>` route (drawer in-app, standalone page on direct load) with `server.py` serving a catch-all → `index.html` fallback.
- **Resolved** — per-day chart range windows: no capture-side change needed, it's a query-time bucketing of `calls.timestamp`. Exact day-counts per tab are pinned down when `server.py`'s rollup queries are written (M4 in `docs/specs/2026-08-28-token-metering-milestones.md`), not before — the mockup's own tab labels and placeholder data don't fully agree (its "7D" tab shows "Last 19 days").
- **Resolved** — model/tool/skill/MCP-server and activity-heatmap rollups: a new `tool_uses` table (one row per `tool_use` block, keyed on the block's own id for the same `INSERT OR IGNORE` idempotency as `calls.request_id`), captured in the same `parser.py` pass. Skill name and MCP server are parsed from `tool_name`/`detail` at query time, same read-time philosophy as pricing. The heatmap needs no new capture — it buckets `calls.timestamp`. Full shape in `03-architecture.md`'s Capture side.
- **Resolved** — cross-project rollup for user/local-scope installs: shape (b), per-project `.cairn/tokens.db` unchanged, plus a `~/.claude/cairn/known-projects.json` registry appended to by the `Stop` hook, that `server.py` unions when present. Chosen over a shared machine-wide db specifically because it needs no schema change and no change to project-scoped installs (the common case). Full shape in `03-architecture.md`'s Serving side.

## Success criteria

- Running `/cairn-tokens` after a cairn session spanning multiple agent dispatches starts a local dashboard whose per-day/per-agent rollups sum to a plausible total against the transcript.
- Expanding an agent's rollup row in the per-session view reveals its call-by-call trace, in order, with per-call tokens/cost/duration.
- A deliberately triggered usage-limit event surfaces in the dashboard's warning banner rather than being folded into ordinary usage.
- Re-processing an already-recorded session's data does not double-count.
- No `npm`/`node` invocation is required on the machine running `/cairn-tokens`.
