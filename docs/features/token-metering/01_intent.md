# Intent: token metering & dashboard

## Why this exists

Cairn has no way to measure its own token cost. `/cairn-tokens` has sat in the commands table (build brief §B9) intentionally unbuilt, because it depends entirely on metering data that doesn't exist yet. Without it, the default (≤ 40k) and escalated (≤ 150k) token budgets in `skills/start/SKILL.md` are stated assumptions, not measured facts — there's no way to tell which agent, phase, or session is actually driving cost on a real task.

## What "done" looks like

A developer runs `/cairn-tokens` after a session and gets a live local dashboard that:

- Sums to a plausible total against the transcript, broken down by day, session, and agent.
- Lets them drill from a day into a session into a single agent's call-by-call trace — tokens, cost, duration, and on-demand access to that call's actual prompt/response.
- Surfaces usage-limit events as a visible warning, never folded into ordinary usage counts.
- Needs no `npm`/`node` on the machine that runs it, and never touches a session's behavior — capture is advisory-only.

## What it deliberately isn't

- Not a live stream — reflects the last completed session, refreshed by polling.
- Not billing or cost-recovery — a local diagnostic only.
- Not shared or remote — data and server stay on the developer's own machine, even when rolling up across projects at user/local install scope.

## Where the detail lives

This doc is the "why, in one page" — it doesn't get amended as design decisions land. Everything downstream of it does:

- `02_requirements.md` — goals, non-goals, stakeholders, constraints, open questions, success criteria.
- `03_architecture.md` — the capture/serving design and its tradeoffs.
- `04_user-flow.md` — the end-to-end developer flows.
