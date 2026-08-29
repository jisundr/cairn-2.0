# Goal: token metering & dashboard — how we build it

This doc is about *process*, not the feature itself or its progress. Start at `GOAL-CONDITION.md` (the entry point — current status + done-conditions, what `/goal` attaches to); this file is read only when you need the *how*, not the *what*. What we're building lives in `01-intent.md`/`03-architecture.md`; full log/history in `GOAL-STATE.md`.

## Approach: one mini goal sprint per milestone, run as parallel tracks

`ROADMAP.md` sequences the feature into six independently-gated milestones (M1–M6), each with its own "Depends on" line. Read literally, only M1 → M4 → M5 → M6 is a true chain — M2 depends only on M1, and M3 depends on nothing (it's a pure function over `db.py`'s row shape, which the M1 spec already freezes). Running every milestone as one strictly serial queue leaves that slack unused, so sprints run as three tracks instead:

- **Track A (critical path)**: M1 → M4 → M5 → M6.
- **Track B**: M3, in parallel with M1 — needs only the frozen row-shape spec, not merged M1 code. Must merge before Track A starts M4.
- **Track C**: M2, in parallel with Track B/M4/M5 — needs M1 merged, nothing depends on it downstream. Must merge before Track A's M6 sprint (its manual end-to-end test needs the `Stop` hook actually firing).

A given sprint (one milestone) still runs exactly as described below — this only changes when a sprint is allowed to *start* relative to the others, not what happens inside it.

Each sprint:

1. **Implement** the milestone's artifact(s) — `cairn:builder` (writes code and its tests together, no separate test pass).
2. **Run the build/gate workflow** for what that milestone touches — `token-metering/`'s own `pytest`/`--selftest` per its `.harness/workflow.md`, plus `python tools/budget.py` for anything shipping from this repo (hooks, commands). Gate specifics per milestone are in `ROADMAP.md`'s Gate lines and mirrored in `GOAL-CONDITION.md`.
3. **Test manually** — `cairn:run` to launch whatever the milestone makes runnable (the hook, the server, the dashboard, `/cairn-tokens` itself once M6 lands), exercising the milestone's own manual-test note in `ROADMAP.md`.
4. **Confirm tests exist** for the milestone's automated coverage (already produced in step 1 — this is the checkpoint, not a separate writing pass).
5. **Open a PR for review** — `cairn:review-pr` / the `reviewer` agent, against the milestone's diff only. This is where the session's work on this sprint ends — review and merge happen asynchronously, outside this run.

A sprint is **published** once its PR is opened at step 5 — that's the session's own stopping point, and enough to mark that milestone's checkbox in `GOAL-STATE.md` as PR-open (not yet done) and note it in `GOAL-CONDITION.md`'s Current status. It is **closed** only once that PR is actually merged.

The next session that resumes (starting at `GOAL-CONDITION.md`) checks, for any track showing a PR-open sprint: has it merged?

- **Merged** — flip that milestone's checkbox to done in `GOAL-STATE.md`, log it, update `GOAL-CONDITION.md`'s Current status to reflect whatever's now unblocked, and start the next sprint on that track (or a newly-unblocked track).
- **Not yet merged** — don't start a new sprint on that track. Work a different unblocked track if one exists, or end the session with nothing new to start; re-check on the next invocation.

**Bug hit mid-sprint (steps 1–4) that isn't fixed on the spot** — before ending the session: add a one-line entry to `GOAL-CONDITION.md`'s "Known issues" section (track/milestone, one-line symptom, pointer to the detail below), and write the full detail (repro, what's affected, any fix attempted) as a dated `GOAL-STATE.md` log entry. The next session reads Known issues first and addresses (or consciously re-defers) it before starting new work on that track — don't open a PR for a sprint with an unresolved Known-issues entry against it.

## Sprint sequence

| Track | Milestone | Starts after | Plan |
|---|---|---|---|
| A (critical path) | M1 — `db.py` (`tool_uses`) + `parser.py` | — | [plans/m1-schema-and-parser.md](plans/m1-schema-and-parser.md) |
| B (parallel) | M3 — `prices.json` + `pricing.py` | — (parallel with A/M1) | [plans/m3-pricing.md](plans/m3-pricing.md) |
| C (parallel) | M2 — `hooks/stop-tokens.sh` | A's M1 merged | [plans/m2-stop-hook.md](plans/m2-stop-hook.md) |
| A (critical path) | M4 — `server.py` | A's M1 merged **and** B's M3 merged | [plans/m4-server.md](plans/m4-server.md) |
| A (critical path) | M5 — `frontend/` | A's M4 merged | [plans/m5-frontend.md](plans/m5-frontend.md) |
| A (critical path) | M6 — `commands/cairn-tokens.md` | A's M5 merged **and** C's M2 merged | [plans/m6-cairn-tokens-command.md](plans/m6-cairn-tokens-command.md) |

1:1 with `ROADMAP.md`'s milestones — no bundling. "Starts after" is `ROADMAP.md`'s own "Depends on" lines per milestone; if those ever change, update this table to match rather than re-deriving the tracks from scratch.

## Worktree per track

Each **track** runs in its own git worktree (not each sprint) — up to three can be active at once (A, B, C), each created when that track's next sprint is cleared to start and removed once that sprint's PR merges:

- Track C's sprints (M2, M6) touch only this repo — a worktree here only.
- Track A's and B's sprints touching `token-metering/` (M1, M3, M4, M5) need a branch inside the submodule too — a worktree of the outer repo doesn't branch a submodule for you; each worktree initializes its own submodule checkout independently, so parallel submodule branches (e.g. Track A's M1 branch and Track B's M3 branch) don't collide. Set up the submodule branch before implementing.
- Within a single track, sprints stay sequential — don't start a track's next sprint until that track's current sprint's PR is merged.
- Across tracks, only start a sprint once its "Starts after" condition in the table above is actually merged — the table is the gate, not calendar time.

## Notes

- `token-metering/` gates itself (its own `.harness/`); this repo's `tools/budget.py` only applies to the sprints whose artifacts live here (M2, M6).
- If a sprint's implementation reveals the milestone needs splitting or reordering, amend `ROADMAP.md` first (including its "Depends on" line), then reflect the change in the sprint table above and in `GOAL-STATE.md` — don't let the three drift.
