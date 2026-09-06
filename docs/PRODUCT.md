# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

A solo developer running cairn locally on their own machine, checking in on their Claude Code agent token usage and cost periodically (not a continuously-watched surface). They already know the terminology (agents, subagents, sessions, tokens, calls) from using cairn day to day.

## Product Purpose

Give a cairn user transparent, accurate local accounting of what their Claude Code sessions actually cost — in tokens and dollars — broken down by agent, model, skill, tool, and MCP call, with the ability to drill into any session's real transcript to verify the numbers.

## Positioning

Unlike hosted usage/analytics dashboards, this reads session transcripts already on disk and computes cost locally via a pricing table — nothing leaves the machine, and every rollup traces back to a real, inspectable transcript rather than an opaque aggregate.

## Operating Context

- Runs as a local server (`127.0.0.1:<port>`) started alongside a cairn install; viewed in a browser, not embedded in the CLI.
- Two install shapes change what's shown: **project-scope** (one repo, no cross-project chrome) and **user/local-scope** (all projects on the machine, adds a Projects panel and project filter pills).
- Two tabs: **Dashboard** (rollups — tokens/day, agents & skills, activity heatmap, tokens/model, tool calls, MCP calls, projects) and **Sessions** (session list + drilldown into one session's per-agent totals and full transcript).
- Auto-refreshes on an interval; the developer may also refresh on demand.
- A usage-limit warning banner surfaces when the account has hit a rate/usage limit recently, linking straight to the offending session.

## Capabilities and Constraints

- Local-only tool. No accounts, no multi-user access, no cloud sync — never implies telemetry leaving the machine.
- Transcript content is read on demand from the session file and never duplicated into the metering database; a call whose transcript has since moved or been deleted shows an explicit "unavailable" state rather than failing silently.
- Cost/token numbers are already computed and authoritative by the time they reach this UI — the UI's job is legible presentation and drill-down, not calculation.
- Real implementation lives in `token-metering/frontend/src` (Vite + React + Tailwind + Recharts); `docs/features/token-metering-dashboard-ui/mockups/dashboard.html` is a static proposal surface used to design and review changes before they're built. **This design-system pass is scoped to that mockup only** — the React app is a separate follow-up, not part of this pass.

## Evidence on Hand

- Existing component structure: `token-metering/frontend/src/Dashboard.tsx` and its children (`Header`, `SessionsTable`, `SessionDrilldown`, `ActivityHeatmap`, `TokensPerDayPanel`, `HbarList`, `ProjectsPanel`, `WarningBanner`, `TraceDrawer`, `EmptyState`).
- The current mockup/app visual treatment (muted paper/graphite palette, blue accent, Archivo body + Space Mono labels) — confirmed by the user as **not binding**; treated as evidence/anti-reference for this redesign, not visual authority to preserve.
- No existing brand name, logo, or marketing assets beyond the plain "Token Metering" label — nothing to preserve there.

## Product Principles

1. Local-first, zero cloud dependency — the design should never read like a hosted SaaS product asking for trust it hasn't earned.
2. Dense numbers read fast and precisely — cost, tokens, durations, and per-agent splits are the actual content; the system exists to make that scannable, not to decorate it.
3. Full-fidelity trust — drilldown always shows the real transcript and real per-call numbers; nothing is obscured behind an aggregate the developer can't verify.
4. Built for one operator, not a team — no collaboration chrome, sharing affordances, or multi-user cues.
5. A distinct, considered visual identity — not the generic default look of an AI-scaffolded dashboard.
