# Requirements: token metering & dashboard (Phase 2)

## Problem

Cairn has no way to measure its own token cost. `/cairn-tokens` is listed in the commands table (build brief §B9) but was intentionally left unbuilt — it depends entirely on metering data that doesn't exist yet. Without it, the default (≤ 40k) and escalated (≤ 150k) token budgets in `skills/start/SKILL.md` are stated assumptions, not measured facts, and there's no way to tell which agent, phase, or session is driving cost on a real task.

**Amends build brief §B10**, which now points here for the full spec. The original brief called for "a self-contained HTML file — no server, no CDN"; this doc replaces that with a live local dashboard server, decided across design discussion referencing [CodeBurn](https://github.com/getagentseal/codeburn) and LangSmith as comparables (see Constraints & assumptions for how the no-new-runtime-dependency intent is preserved anyway).

## Goals

- Capture every model API call cairn triggers, deduplicated on `requestId` — one call can span several transcript entries (e.g. a thinking block and a text block) sharing a `requestId` and an identical `usage` snapshot, so per-line counting would double-count.
- Persist usage to SQLite in `.cairn/`, queryable by day, session, and agent.
- Populate a `calls` table via a full transcript rescan on every `Stop` event; make it idempotent with `INSERT OR IGNORE` keyed on `request_id` (no offset tracking).
- Route synthetic usage-limit entries (`isApiErrorMessage: true`, a zeroed-but-present `usage` object) into a separate `usage_limit_events` table instead of the `calls` table.
- Price usage at read time via a `model → $/MTok` table, never at write time, so a price change is a script edit, not a migration. An unrecognized model reports `cost: unknown`; a group containing any unpriced model reports `null`, never a partial sum.
- Serve a live local dashboard (`/cairn-tokens` starts the server and opens the dashboard in the default browser) with per-day, per-session, and per-agent rollups.
- Refresh dashboard data via `@tanstack/react-query` polling on a short interval, plus a manual refresh control for an immediate check.
- **Per-session view is the primary surface**: each agent's rollup row (`planner`/`builder`/`reviewer`/`scribe`) expands into its own call-by-call trace — a waterfall of that agent's calls in sequence, each showing tokens/cost/duration. Modeled on CodeBurn's per-session drill-down and LangSmith's run timeline.
- Rollup bar charts (per-day, per-agent totals) rendered as plain chart components, matching CodeBurn's own choice not to reach for a dedicated charting library for simple bars — Recharts is available in the stack for anything past that (e.g. the per-day usage graph), but isn't required for the rollup bars themselves.
- Show a visible warning in the dashboard whenever a usage-limit event was recorded in the period covered.

## Non-goals

- Real-time push updates mid-call — the dashboard reflects the last completed `Stop` event, refreshed by polling (interval TBD, see Open questions), not a live stream of an in-progress session.
- Billing or invoicing integration — this is a local diagnostic, not a cost-recovery system.
- Metering anything outside cairn's own hook lifecycle (other plugins, non-cairn projects).
- A shared or remote datastore, or multi-machine access — data and server both stay local to the developer's own machine.
- A native desktop app (e.g. Electron) — browser-based dashboard only, matching CodeBurn's web dashboard rather than its Electron variant.

## Stakeholders

- Developers running cairn on their own projects — the direct audience for the dashboard.
- Cairn's own maintainers — need real usage data to validate or retune the 40k/150k budget figures in `skills/start/SKILL.md`, and own the frontend build step (see Constraints).

## Constraints & assumptions

- Metering capture (the `Stop` hook writing to SQLite) is unchanged and stays advisory-only (§B10: "Hooks nudge; they never gate") — it must never block or alter a session, regardless of how the data is later displayed.
- **No new runtime dependency for consuming projects.** The dashboard server is a Python stdlib `http.server` (reading SQLite via `sqlite3`, both already stdlib) — no new pip dependency, matching cairn's existing zero-pip-dependency footprint (`tools/budget.py` is pure stdlib). Node/npm is a **cairn-dev-time-only** dependency: the frontend (React 19 + Vite + Recharts + Tailwind + shadcn/ui + `@tanstack/react-query`) is built once by cairn's maintainers and its compiled static output (plain JS/CSS/HTML) is checked into the plugin. A consuming project runs `/cairn-tokens` and gets a server + prebuilt assets; it never runs `npm install` or a build step itself.
- shadcn/ui components are copied into the plugin's own source (its usual distribution model) rather than pulled in as an opaque UI-kit runtime — only the components actually used ship in the build.
- The SQLite file lives in `.cairn/`, assumed already writable and gitignored, alongside the existing `sessions.log`.
- Assumes the transcript's `requestId`, `usage`, and `isApiErrorMessage` fields are stable enough to key off of — no fallback is specified for a format change.
- Full-transcript rescan on every `Stop` is the accepted starting approach; the build brief flags it as revisit-only-if-measurably-slow, not something to optimize up front.
- The live server is local-only (binds to localhost), started on demand by `/cairn-tokens`, not a background daemon — no new always-on process per §B10's "hooks nudge, they never gate" spirit extended to the dashboard. It runs in the foreground of the launching terminal and stops when that session ends or is interrupted (Ctrl-C) — no separate stop command.
- The `model → $/MTok` price table lives in a checked-in data file (e.g. `tools/tokens/prices.json`), not hardcoded in the server — a price change is a data edit, not a code change.

## Open questions

- Exact schema (columns, types) for `calls`, `usage_limit_events`, and whatever supports the per-session/per-agent rollups — deferred to the implementation spec, not a decision this doc needs to make.
- Exact polling interval for `@tanstack/react-query` (e.g. 10s vs 30s) — a tuning detail, not an architectural one.

## Success criteria

- `tools/tokens/` (backend) and the frontend build both pass the same phase gate as every other artifact: `python tools/budget.py`, `pytest`, and `--selftest` on any new shell script.
- Running `/cairn-tokens` after a cairn session spanning multiple agent dispatches starts a local dashboard whose per-day/per-agent rollups sum to a plausible total against the transcript.
- Expanding an agent's rollup row in the per-session view reveals its call-by-call trace, in order, with per-call tokens/cost/duration.
- A deliberately triggered usage-limit event lands in `usage_limit_events`, not `calls`, and the dashboard's warning banner appears.
- Re-running the `Stop` hook against an already-recorded `requestId` does not double-count.
- No `npm`/`node` invocation is required on the machine running `/cairn-tokens` — only during cairn's own frontend build.
