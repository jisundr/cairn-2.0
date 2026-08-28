# Requirements: token metering & dashboard (Phase 2)

## Problem

Cairn has no way to measure its own token cost. `/cairn-tokens` is listed in the commands table (build brief §B9) but was intentionally left unbuilt — it depends entirely on metering data that doesn't exist yet. Without it, the default (≤ 40k) and escalated (≤ 150k) token budgets in `skills/start/SKILL.md` are stated assumptions, not measured facts, and there's no way to tell which agent, phase, or session is driving cost on a real task.

**Amends build brief §B10**, which now points here for the full requirements and to `docs/token-metering/architecture.md` for the design. The original brief called for "a self-contained HTML file — no server, no CDN"; this doc replaces that with a live local dashboard.

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
- Whether a call's detail should be independently addressable (e.g. `/call/<session>/<n>`), opening as a drawer when navigated to in-app but as a full standalone page on direct load/refresh — GitLab's issue-drawer pattern. Mocked visually in `mockups/dashboard.html`, but the routing/deep-linking this implies isn't described in `architecture.md` yet.
- The per-day chart's range tabs (Today/7D/30D/Month/6M/Life, modeled on CodeBurn's Trend view) each imply a different underlying window and bucket size — Today = 24 hourly buckets, 7D = 19 days, 30D/Month = 30 days, 6M/Life = 90 days — mocked in `mockups/dashboard.html`, but neither the hourly-granularity capture this implies for "Today" nor the query/rollup shape for the other windows is described in `architecture.md` yet.
- The model/tool/skill/MCP-server and activity-heatmap rollups (mocked in `mockups/dashboard.html`) need columns or a companion table beyond the `calls` schema sketched for Phase 2 code — `architecture.md` doesn't yet say whether a tool_use's name (and, for MCP calls, the `mcp__<server>__<tool>` prefix) is stored per-row on `calls` or in a separate table keyed the same way.
- How a user- or local-scope install's project rollup actually finds another project's data isn't decided: `architecture.md` currently has `tools/tokens/server.py` reading a single `.cairn/tokens.db` inside the running project. Two shapes fit the constraints above without either being picked yet: (a) capture always writes to one scope-appropriate location — project-scoped installs keep today's per-project `.cairn/tokens.db`, user/local-scoped installs write to a single machine-wide db with a `project` column derived from the hook's `cwd` — or (b) capture stays per-project always, and a small registry file (e.g. `~/.claude/cairn/known-projects.json`, appended to by the `Stop` hook) lets the server discover and union the other `.cairn/tokens.db` files it knows about. The mockup's Projects panel and project filter only demonstrate the resulting UI, not which of these it's built on.

## Success criteria

- Running `/cairn-tokens` after a cairn session spanning multiple agent dispatches starts a local dashboard whose per-day/per-agent rollups sum to a plausible total against the transcript.
- Expanding an agent's rollup row in the per-session view reveals its call-by-call trace, in order, with per-call tokens/cost/duration.
- A deliberately triggered usage-limit event surfaces in the dashboard's warning banner rather than being folded into ordinary usage.
- Re-processing an already-recorded session's data does not double-count.
- No `npm`/`node` invocation is required on the machine running `/cairn-tokens`.
