# Plan — Track A / M6: `commands/cairn-tokens.md`

Design: `../04-user-flow.md` Flow 2 (opening the dashboard) and Flow 6 (stopping it). Depends on M4 (`server.py`) and M5 (`static/`) both being real. This is the last sprint — its manual test is the feature's full end-to-end acceptance pass.

## Scope

- `commands/cairn-tokens.md` — new, this repo (cairn-2.0)
- No submodule changes

## Steps

1. **Worktree**: outer-repo worktree only.
2. **Plan** — `cairn:scope` (source: this file; path: escalated per `../GOAL.md`'s Plan step), then `cairn:planner` → `docs/tasks/m6-cairn-tokens-command/STATE.md` + plan, using this file as its primary input. Present for approval before dispatching `builder`.
3. **Implement** — `cairn:builder`, escalated path, following `commands/cairn-doctor.md`'s frontmatter/body style:
   - Starts `token-metering/server.py` in the background.
   - Opens the default browser to it.
   - Reports the URL and that Ctrl-C in the terminal that ran it stops the server (per Flow 6 — no separate stop command).
4. **Gate** — full §A13 gate + relevant §B12 acceptance criteria (specifically #26: token report opens correctly from `file://` — recheck against the live-server amendment, since the original brief assumed a static HTML file and this ships a live server instead).
5. **Manual test** — the feature's full end-to-end acceptance, per `../03-architecture.md`'s Testing section and `../GOAL-CONDITION.md`'s overall Done-when list:
   - Run a real cairn session that dispatches at least one subagent.
   - Let `Stop` fire.
   - Run `/cairn-tokens`.
   - Confirm: dashboard opens, per-day/per-agent rollups sum to a plausible total against the transcript, an agent's rollup row expands into its call trace, a deliberately-triggered usage-limit event surfaces the warning banner (not folded into ordinary usage), and re-running against the same session doesn't double-count.
6. **Confirm tests** — manual only, per `../ROADMAP.md`'s M6 test note; no new automated coverage beyond what M1–M5 already carry.
7. **Review** — `cairn:reviewer` agent against the diff (`commands/cairn-tokens.md`), before any PR exists. Fail → back to step 3 with findings.
8. **PR** — the main thread opens it, diff scoped to `commands/cairn-tokens.md`.

## Done when

M6's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged, and every item in `../GOAL-CONDITION.md`'s overall "Done when" section is true. Flip M6 in `../GOAL-STATE.md`, log it — the feature is complete.
