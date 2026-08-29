# Goal state: token metering & dashboard

Detail file, not the entry point — for current status, start at `GOAL-CONDITION.md`'s Current status section instead of here. This file holds the full log and the per-milestone sub-task checklist, consulted only when a task needs that history or detail. Development process lives in `GOAL.md`, per-sprint execution steps in `plans/` ([index](plans/README.md)), design/sequencing in `01-intent.md`/`03-architecture.md`/`ROADMAP.md`.

## Milestones

- [ ] **M0** — pre-M1 baseline. Mockup done (`mockups/dashboard.html`). Schema/tests **not done in the submodule**: `calls`/`usage_limit_events` + tests exist only in this repo's legacy `tools/tokens/db.py`/`test_db.py` (committed), plus an **uncommitted** `tool_uses` diff on top of `tools/tokens/db.py` that duplicates part of M1. `token-metering/db.py` itself has no code yet. Resolve before Track A's M1 implement step (its plan's Step 0): port (base + the uncommitted diff, or discard and redo) into `token-metering/db.py`, then decide `tools/tokens/`'s fate in this repo.
- [ ] **M1** — `token-metering/db.py` (`tool_uses` table) + `parser.py`
  - [ ] resolve M0's carryover (port or discard `tools/tokens/`'s contents into the submodule)
  - [ ] `tool_uses` table + main/subagent attribution walker
  - [ ] route `isApiErrorMessage` entries to `usage_limit_events`
  - [ ] tests: main+subagent attribution, dup `requestId`, dup `tool_use_id`, unmatched `agentId` → `"unknown"`, synthetic error routing
- [ ] **M2** — `hooks/stop-tokens.sh`
  - [ ] `Stop` hook: opt-in check, shell out to parser, silent `exit 0` on missing `jq`/field/opt-in
  - [ ] append to `~/.claude/cairn/known-projects.json` on user/local scope installs
  - [ ] `--selftest`; manual check second `Stop` doesn't duplicate rows
- [ ] **M3** — `token-metering/prices.json` + `pricing.py`
  - [ ] checked-in `model → $/MTok` table, applied at read time
  - [ ] unknown model → `"unknown"`; mixed-model rollup → `null`
  - [ ] `test_pricing.py`
- [ ] **M4** — `token-metering/server.py`
  - [ ] stdlib `http.server` + `sqlite3`, localhost-only, foreground
  - [ ] JSON API: rollups (day/session/agent/tool/skill/MCP-server), heatmap, per-session trace, on-demand prompt/response lookup
  - [ ] cross-project union via `known-projects.json`; cold-start + transcript-unavailable response shapes
  - [ ] catch-all → `index.html` fallback
  - [ ] `test_server.py`
- [ ] **M5** — `token-metering/frontend/`
  - [ ] React 19 + Vite + Recharts + Tailwind + shadcn/ui + react-query (15s poll), matching `mockups/dashboard.html`
  - [ ] compiled to `token-metering/static/` via `npm run build`
  - [ ] manual: loads from `static/`, matches mockup states (empty, populated, trace expansion, transcript-unavailable, usage-limit banner)
- [ ] **M6** — `commands/cairn-tokens.md`
  - [ ] starts `server.py` in background, opens browser
  - [ ] manual end-to-end: real session w/ ≥1 subagent → `Stop` → `/cairn-tokens` → rollups, trace, banner, idempotency

## Log

- 2026-08-29 — GOAL-STATE.md created; M0 confirmed done per `ROADMAP.md` status section, M1 not started.
- 2026-08-29 — Doc-sync review: M0 was marked done in error. `token-metering/db.py` has no code; the schema/tests it was credited for live only in this repo's legacy `tools/tokens/`, which also has an uncommitted, untested `tool_uses` diff. Corrected here and in `ROADMAP.md`'s Status section. Decision: leave `tools/tokens/` untouched for now, resolve it as Sprint 1's first step. Also found `docs/BUILD_BRIEF.md` §B10/§B11 hadn't been amended for the `token-metering` submodule split — fixed alongside this.
- 2026-08-29 — M5 scope change: added a Playwright e2e suite (`token-metering/frontend/e2e/`, `playwright.config.ts`) as automated coverage for `mockups/dashboard.html`'s states plus the `/call/<session>/<n>` deep-link route, replacing "manual only" as M5's primary verification. Manual testing narrows to just the 15s-poll timing check. Updated `plans/m5-frontend.md`, `ROADMAP.md`'s M5 Tests/Gate lines and cross-milestone Testing section, and `GOAL-CONDITION.md`'s M5 gate. Not yet reflected in the `token-metering` submodule's own `.harness/workflow.md` (still says frontend testing is manual-only) — that update is deferred to M5's implementation step.
- 2026-08-29 — Sprint process change: switched from one strict serial queue (Sprint 1=M1 … Sprint 6=M6) to three parallel tracks, based on `ROADMAP.md`'s own "Depends on" lines showing M3 depends on nothing and M2 depends only on M1. Track A (critical path) is M1→M4→M5→M6; Track B is M3, parallel with M1; Track C is M2, parallel with B/M4/M5, gated only by M1 merged and required before M6. Updated `GOAL.md`'s Sprint sequence and Worktree sections and `plans/README.md`'s index table to match. "Current sprint" above rewritten to track-based framing.
- 2026-08-29 — Entry-point consolidation: `GOAL-CONDITION.md` is now the single entry point for resuming/checking this feature — its new "Current status" section absorbed this file's former "Current sprint" section (moved, not duplicated) so a session doesn't need to open this file for routine status. This file (`GOAL-STATE.md`) is now log + detailed milestone checklist only, read on demand. `GOAL.md`'s and `plans/README.md`'s pointers updated to match.
- 2026-08-29 — Sprint-closing trigger changed: a sprint's session-level work now ends once its PR is **published** (opened) at `GOAL.md` step 5, not once it's merged — review/merge happens asynchronously, outside that session. A sprint is only marked done (checkbox flipped, downstream tracks unblocked) once a *later* session, resuming from `GOAL-CONDITION.md`, confirms that PR actually merged. Until then the milestone sits in a "PR open" state. Updated `GOAL.md`'s per-sprint steps and `GOAL-CONDITION.md`'s Current status accordingly. No milestone has reached this state yet (nothing started).
- 2026-08-29 — Added the mid-sprint bug-logging mechanism: a one-line entry in `GOAL-CONDITION.md`'s new "Known issues" section (checked first on resume) plus the full repro/detail as a dated log entry here. `GOAL.md`'s per-sprint step 5 amended with the rule and its "don't open a PR against an unresolved Known-issues entry" constraint.
- 2026-08-29 — Drift review: the six `plans/mN-*.md` files still had pre-track "Sprint N" titles and "Done when" footers left over from the parallel-track restructuring, with M1's and M2's footers logically wrong (implying a linear M1→M2→M3… chain instead of the actual Track A/B/C sequencing). Retitled all six to `Track X / MN` and rewrote each footer to name the correct next sprint (or "track done" for M2/M3) and require the PR having *merged*, not just opened, consistent with the publish-vs-closed distinction above. Also fixed two stale "Sprint 1" references in living text: `GOAL-STATE.md`'s M0 line and `ROADMAP.md`'s Status section, both now pointing to "Track A's M1 Step 0." Cross-checked and confirmed still accurate: `GOAL-CONDITION.md`'s Per-milestone gate wording matches `ROADMAP.md`'s Gate lines exactly; `plans/README.md`'s Track column matches the corrected plan titles; current git state (`token-metering/db.py` still empty, `tools/tokens/db.py` still carries its uncommitted 22-line `tool_uses` diff) still matches Current status's "nothing started" claim. No other drift found.
