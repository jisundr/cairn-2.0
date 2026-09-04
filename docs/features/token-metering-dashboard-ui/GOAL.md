# Goal: token-metering dashboard production port — how we build it

This doc is about *process*, not the port itself or its progress. Start at `GOAL-CONDITION.md` (the entry point — current status + done-conditions, what `/goal` attaches to); this file is read only when you need the *how*, not the *what*. What we're porting lives in `requirements.md`/`DESIGN.md`; sequencing lives in `ROADMAP.md`.

## Approach: one sprint per wave, run as two parallel tracks

`ROADMAP.md` sequences the port into five waves. Read literally, only Wave 1 → Wave 5 is a hard chain through the whole roadmap — Waves 2, 3, and 4 all depend only on Wave 1, and Waves 3 and 4 don't depend on each other or on Wave 2 at all. Running every wave as one strictly serial queue leaves that slack unused, so sprints run as two tracks instead:

- **Track A**: Wave 1 → Wave 2 → Wave 5 — chrome-and-readouts, the smaller of the two component groups, kept on the critical-path track since Wave 5 needs every other wave merged anyway and there's no benefit to racing it ahead independently.
- **Track B (parallel with A's Wave 2)**: Wave 3 → Wave 4, sequenced only because this is a solo effort and running two worktrees for two component groups with zero interdependency is more overhead than it's worth — a developer who wants true parallelism can split B into its own two tracks (3 and 4) instead. Must merge before Track A starts Wave 5.

A given sprint (one wave) still runs exactly as described below — this only changes when a sprint is allowed to *start* relative to the others, not what happens inside it.

Each sprint:

1. **Plan** — resolve scope with `cairn:scope` if not already active for this wave (`goal`/`paths`/`done_when` from `ROADMAP.md`'s wave entry; `source` set to the wave's `plans/0N-*.md`; `path: escalated` — every wave in this project runs the escalated path regardless of whether it individually trips `cairn:start`'s own escalation trigger, since the whole port is governed by this shared roadmap/gate structure and lands inside the `token-metering` submodule). Then dispatch `cairn:planner` to turn that scope into `docs/tasks/<slug>/STATE.md` + a plan referencing paths and contracts, using the wave's `plans/0N-*.md` as its primary input rather than re-deriving from nothing. **Present the plan for approval** before dispatching `builder` — `planner` never proceeds past this on its own.
2. **Implement** the wave's port — `cairn:builder`, escalated path (reads the task folder's plan; writes code and its tests together, no separate test pass), working inside the `token-metering` submodule.
3. **Run the gate** for what that wave touches — `npm run build && npx playwright test` inside `frontend/`, plus `pytest test_*.py` as a cheap regression check that the untouched backend stays green. Wave 5 additionally runs this repo's `python tools/budget.py` on its re-vendor commit. Gate specifics per wave are in `ROADMAP.md`'s wave Gate lines and mirrored in `GOAL-CONDITION.md`.
4. **Confirm tests exist** for the wave's automated coverage (already produced in step 2 — this is the checkpoint, not a separate writing pass).
5. **Test manually** for any wave touching a state Playwright's two fixtures don't fully cover (Wave 2's warning banner against a real usage-limit event, Wave 3's live 15s-poll update, Wave 5's full smoke test) — `cairn:run` against a real session.
6. **Review** — dispatch the `cairn:reviewer` agent (never the `cairn:review-pr` skill, which reviews an already-open PR — this project's own convention is review before a PR exists) against the diff, scoped to the wave only. Fail → the main thread dispatches `builder` again with the findings, back to step 2. Pass → proceed to step 7; `reviewer` never opens a PR itself.
7. **Open the PR** — the main thread opens it, diff scoped to the wave only, inside the `token-metering` submodule (Wave 5's re-vendor half opens a second, separate PR in this repo — never combined with the submodule-side diff). This is where the session's work on this sprint ends — merge happens asynchronously, outside this run.

A sprint is **published** once its PR(s) are opened at step 7 — that's the session's own stopping point, enough to mark that wave's line in `GOAL-CONDITION.md`'s Current status as PR-open (not yet done). It is **closed** only once every PR it opened has actually merged.

The next session that resumes (starting at `GOAL-CONDITION.md`) checks, for any track showing a PR-open sprint: has it merged?

- **Merged** — mark that wave done in `GOAL-CONDITION.md`, log it, update Current status to reflect whatever's now unblocked, and start the next sprint on that track (or a newly-unblocked track).
- **Not yet merged** — don't start a new sprint on that track. Work a different unblocked track if one exists, or end the session with nothing new to start; re-check on the next invocation.

**Bug hit mid-sprint (steps 2-5) that isn't fixed on the spot** — before ending the session: add a one-line entry to `GOAL-CONDITION.md`'s "Known issues" section (track/wave, one-line symptom, repro/detail inline or in that section's own sub-bullet). The next session reads Known issues first and addresses (or consciously re-defers) it before starting new work on that track — don't open a PR for a sprint with an unresolved Known-issues entry against it.

## Sprint sequence

| Track | Wave | Starts after | Plan |
|---|---|---|---|
| A (critical path) | Wave 1 — tokens & primitives | — | [plans/01-tokens-and-primitives.md](plans/01-tokens-and-primitives.md) |
| A (critical path) | Wave 2 — chrome & readouts | A's Wave 1 merged | [plans/02-chrome-and-readouts.md](plans/02-chrome-and-readouts.md) |
| B (parallel with A's Wave 2) | Wave 3 — charts | A's Wave 1 merged | [plans/03-charts.md](plans/03-charts.md) |
| B | Wave 4 — sessions & drilldown | B's Wave 3 merged (sequenced within Track B only — see Worktree note below; no dependency on Wave 3's content) | [plans/04-sessions-and-drilldown.md](plans/04-sessions-and-drilldown.md) |
| A (critical path) | Wave 5 — verification & vendor sync | A's Wave 2 merged **and** B's Wave 4 merged | [plans/05-verification-and-vendor-sync.md](plans/05-verification-and-vendor-sync.md) |

1:1 with `ROADMAP.md`'s five waves — no bundling. "Starts after" reflects `ROADMAP.md`'s own dependency notes; if those ever change, update this table to match rather than re-deriving the tracks from scratch.

## Worktree per track

Each **track** runs in its own git worktree (not each sprint) — up to two can be active at once (A, B), each created when that track's next sprint is cleared to start and removed once that sprint's PR(s) merge:

- Both tracks touch only `token-metering/frontend/` — every sprint needs a branch inside the `token-metering` submodule; a worktree of this outer repo doesn't branch a submodule for you, so each worktree initializes its own submodule checkout independently, letting Track A's and B's submodule branches coexist without colliding.
- Within a single track, sprints stay sequential — don't start a track's next sprint until that track's current sprint's PR(s) are merged.
- Across tracks, only start a sprint once its "Starts after" condition in the table above is actually merged — the table is the gate, not calendar time.
- `docs/tasks/<slug>/` (the Plan step's task folder) is written in the outer repo's worktree for that track, even though the code itself lands in the submodule.

## Notes

- `token-metering/` gates itself (its own `.harness/workflow.md`); this repo's `tools/budget.py` only applies to Wave 5's re-vendor commit.
- If a sprint's implementation reveals a wave needs splitting or reordering, amend `ROADMAP.md` first (including its dependency notes), then reflect the change in the sprint table above — don't let the two drift.
- No `GOAL-STATE.md` yet — with zero sprints run, a separate log/detail file would be empty scaffolding. This project's log lives directly in `GOAL-CONDITION.md`'s Current status until enough sprints have run to justify splitting detail out, the same call `token-metering-followups` made at its own start.
