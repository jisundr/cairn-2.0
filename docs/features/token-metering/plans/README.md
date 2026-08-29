# Build plans

One plan per milestone, each walking the sprint process from `../GOAL.md` (implement → gate → manual test → confirm tests → PR) with the concrete steps for that milestone. Design authority stays `../03-architecture.md` and `../ROADMAP.md`; a plan adds *how to execute the sprint*, not new design decisions. Sprints run as three parallel tracks (A/B/C), not one strict queue — see `../GOAL.md`'s Sprint sequence table for the "starts after" gating between them.

| Track | Milestone | Plan | Design ref |
|---|---|---|---|
| A | `db.py` (`tool_uses`) + `parser.py` | [m1-schema-and-parser.md](m1-schema-and-parser.md) | `../specs/2026-08-29-m1-db-parser.md` |
| C | `hooks/stop-tokens.sh` | [m2-stop-hook.md](m2-stop-hook.md) | `../03-architecture.md` §Capture side |
| B | `prices.json` + `pricing.py` | [m3-pricing.md](m3-pricing.md) | `../03-architecture.md` §Capture side |
| A | `server.py` | [m4-server.md](m4-server.md) | `../03-architecture.md` §Serving side |
| A | `frontend/` | [m5-frontend.md](m5-frontend.md) | `../mockups/dashboard.html` |
| A | `commands/cairn-tokens.md` | [m6-cairn-tokens-command.md](m6-cairn-tokens-command.md) | `../04-user-flow.md` |

Entry point / current status: `../GOAL-CONDITION.md`. Full log/history: `../GOAL-STATE.md` (on demand only).
