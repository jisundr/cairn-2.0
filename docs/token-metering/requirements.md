# Requirements: token metering & dashboard (Phase 2)

## Problem

Cairn has no way to measure its own token cost. `/cairn-tokens` is listed in the commands table (build brief §B9) but was intentionally left unbuilt — it depends entirely on metering data that doesn't exist yet. Without it, the default (≤ 40k) and escalated (≤ 150k) token budgets in `skills/start/SKILL.md` are stated assumptions, not measured facts, and there's no way to tell which agent, phase, or session is driving cost on a real task.

**Amends build brief §B10**, which now points here for the full requirements and to `docs/token-metering/architecture.md` for the design. The original brief called for "a self-contained HTML file — no server, no CDN"; this doc replaces that with a live local dashboard.

## Goals

- Capture every model API call cairn triggers, without double-counting or missing calls.
- Persist usage data so it can be queried by day, session, and agent.
- Distinguish usage-limit events (hitting a rate/quota ceiling) from normal usage — they must never be counted as ordinary calls.
- Price usage using current rates, without requiring a data migration when prices change.
- Serve a live local dashboard (`/cairn-tokens` starts it and opens the browser) with per-day, per-session, and per-agent rollups.
- Dashboard data refreshes automatically on an interval, plus a manual refresh control for an immediate check.
- **Per-session view is the primary surface**: each agent's rollup (`planner`/`builder`/`reviewer`/`scribe`) expands into its own call-by-call trace, in order, with tokens/cost/duration per call.
- Rollups are visualized with charts (per-day, per-agent totals).
- Show a visible warning in the dashboard whenever a usage-limit event was recorded in the period covered.

## Non-goals

- Real-time push updates mid-call — the dashboard reflects the last completed session activity, refreshed by polling, not a live stream of an in-progress session.
- Billing or invoicing integration — this is a local diagnostic, not a cost-recovery system.
- Metering anything outside cairn's own hook lifecycle (other plugins, non-cairn projects).
- A shared or remote datastore, or multi-machine access — data and server both stay local to the developer's own machine.
- A native desktop app — browser-based dashboard only.

## Stakeholders

- Developers running cairn on their own projects — the direct audience for the dashboard.
- Cairn's own maintainers — need real usage data to validate or retune the 40k/150k budget figures in `skills/start/SKILL.md`, and own the dashboard's build step.

## Constraints & assumptions

- Metering capture stays advisory-only (§B10: "Hooks nudge; they never gate") — it must never block or alter a session, regardless of how the data is later displayed.
- No new runtime dependency for consuming projects — a project running `/cairn-tokens` never installs or builds anything itself.
- Data and server stay local to the developer's machine — no remote or shared datastore (see Non-goals).
- The live server is local-only, started on demand by `/cairn-tokens`, not a background daemon — no new always-on process.

## Open questions

- Exact polling interval for dashboard refresh (e.g. 10s vs 30s) — a tuning detail, not an architectural one.

## Success criteria

- Running `/cairn-tokens` after a cairn session spanning multiple agent dispatches starts a local dashboard whose per-day/per-agent rollups sum to a plausible total against the transcript.
- Expanding an agent's rollup row in the per-session view reveals its call-by-call trace, in order, with per-call tokens/cost/duration.
- A deliberately triggered usage-limit event surfaces in the dashboard's warning banner rather than being folded into ordinary usage.
- Re-processing an already-recorded session's data does not double-count.
- No `npm`/`node` invocation is required on the machine running `/cairn-tokens`.
