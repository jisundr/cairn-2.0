# Goal: token-metering follow-ups — how we build it

This doc is about *process*, not the fixes themselves or their progress. Start at `GOAL-CONDITION.md` (the entry point — current status + done-conditions, what `/goal` attaches to); this file is read only when you need the *how*, not the *what*. What we're fixing lives in `requirements.md`/`specs/*.md`; sequencing lives in `ROADMAP.md`.

## Approach: one sprint per issue, run as three parallel tracks

`ROADMAP.md` sequences the seven issues into four waves, each with a Depends-on line. Read literally, only the vendored-file chain (issues 6 → 1 → 3 → 4) is a true dependency chain — issue 7 depends on nothing, and Wave 4's issues 2 and 5 depend on nothing except issue 5's heatmap half, conditionally. Running every issue as one strictly serial queue leaves that slack unused, so sprints run as three tracks instead:

- **Track A (critical path)**: Issue 6 → Issue 1 → Issue 3 → Issue 4 — the vendored-file chain. Kept serial within the track, rather than splitting issues 1 and 3 into parallel sub-tracks, because both land in `server.py`'s neighborhood in quick succession and `ROADMAP.md` already prefers avoiding near-simultaneous edits to the same file over exploiting every last bit of parallelism.
- **Track B (independent, parallel with A)**: Issue 7 — the architecture-doc fix. No dependency on anything; can land before, during, or after Track A.
- **Track C (frontend, parallel with A/B)**: Issue 2 → Issue 5 — both live only in `token-metering/frontend/`, unvendored, so neither needs Track A's drift guard merged first... except issue 5's heatmap half, conditionally, if its implementation-time wire-shape decision (`specs/05-utc-time-localization.md`'s open question) ends up touching `server.py`. If it does, that one piece waits on Track A's Issue 6 merging; `format.ts`'s half of issue 5, and all of issue 2, don't.

A given sprint (one issue) still runs exactly as described below — this only changes when a sprint is allowed to *start* relative to the others, not what happens inside it.

Each sprint:

1. **Plan** — resolve scope with `cairn:scope` if not already active for this issue (goal/paths/done_when from `ROADMAP.md`'s wave entry; `source` set to the issue's `specs/0N-*.md`; `path: escalated` — every issue in this project runs the escalated path regardless of whether it individually trips `cairn:start`'s own escalation trigger, since several cross a repo boundary (this repo ↔ the `token-metering` submodule) and all seven are governed by this shared roadmap/gate structure). Then dispatch `cairn:planner` to turn that scope into `docs/tasks/<slug>/STATE.md` + a plan referencing paths and contracts, using the issue's `specs/0N-*.md` as its primary input rather than re-deriving from nothing. **Present the plan for approval** before dispatching `builder` — `planner` never proceeds past this on its own.
2. **Implement** the issue's fix — `cairn:builder`, escalated path (reads the task folder's plan; writes code and its tests together, no separate test pass). For an issue touching a vendored file (Track A), the same fix is ported to `token-metering/`'s copy in the same sprint, verified against `specs/06-vendoring-drift-guard.md`'s check script once Track A's Issue 6 has merged.
3. **Run the gate** for what that issue touches — `python tools/budget.py` and `python -m pytest tools/` for anything in `tools/tokens/`; `pytest` inside `token-metering/` for its ported copy; `npm run build && npx playwright test` inside `token-metering/frontend/` for frontend changes. Gate specifics per issue are in `ROADMAP.md`'s wave Gate lines and mirrored in `GOAL-CONDITION.md`.
4. **Confirm tests exist** for the issue's automated coverage (already produced in step 2 — this is the checkpoint, not a separate writing pass).
5. **Review** — dispatch the `cairn:reviewer` agent (never the `cairn:review-pr` skill, which reviews an already-open PR — this project's own convention is review before a PR exists) against the diff, scoped to the issue only. Fail → the main thread dispatches `builder` again with the findings, back to step 2. Pass → proceed to step 6; `reviewer` never opens a PR itself.
6. **Open the PR** — the main thread opens it, diff scoped to the issue only. For an issue spanning both this repo and the submodule (Track A's issues touching `server.py`/`db.py`, and any frontend half of an issue), open one PR per repo rather than one combined diff. This is where the session's work on this sprint ends — merge happens asynchronously, outside this run.

A sprint is **published** once its PR(s) are opened at step 6 — that's the session's own stopping point, enough to mark that issue's line in `GOAL-CONDITION.md`'s Current status as PR-open (not yet done). It is **closed** only once every PR it opened has actually merged.

The next session that resumes (starting at `GOAL-CONDITION.md`) checks, for any track showing a PR-open sprint: has it merged?

- **Merged** — mark that issue done in `GOAL-CONDITION.md`, log it, update Current status to reflect whatever's now unblocked, and start the next sprint on that track (or a newly-unblocked track).
- **Not yet merged** — don't start a new sprint on that track. Work a different unblocked track if one exists, or end the session with nothing new to start; re-check on the next invocation.

**Bug hit mid-sprint (steps 2-4) that isn't fixed on the spot** — before ending the session: add a one-line entry to `GOAL-CONDITION.md`'s "Known issues" section (track/issue, one-line symptom, repro/detail inline or in that section's own sub-bullet). The next session reads Known issues first and addresses (or consciously re-defers) it before starting new work on that track — don't open a PR for a sprint with an unresolved Known-issues entry against it.

## Sprint sequence

| Track | Issue | Starts after | Spec |
|---|---|---|---|
| A (critical path) | Issue 6 — vendoring drift guard | — | [specs/06-vendoring-drift-guard.md](specs/06-vendoring-drift-guard.md) |
| B (parallel) | Issue 7 — architecture doc staleness | — (parallel with A) | [specs/07-architecture-doc-staleness.md](specs/07-architecture-doc-staleness.md) |
| C (parallel) | Issue 2 — UI overflow fixes | — (parallel with A/B) | [specs/02-ui-overflow-fixes.md](specs/02-ui-overflow-fixes.md) |
| A (critical path) | Issue 1 — ghost-project cleanup | A's Issue 6 merged | [specs/01-ghost-project-cleanup.md](specs/01-ghost-project-cleanup.md) |
| C (parallel) | Issue 5 — UTC time localization | C's Issue 2 merged (no file overlap with issue 2 — `format.ts`/`ActivityHeatmap.tsx` vs. `SessionDrilldown.tsx`/`HbarList.tsx` — sequenced only because Track C's worktree runs one sprint at a time, per Worktree per track below; the heatmap half additionally needs A's Issue 6 merged **if** it touches `server.py`) | [specs/05-utc-time-localization.md](specs/05-utc-time-localization.md) |
| A (critical path) | Issue 3 — query bounding and indexes | A's Issue 1 merged | [specs/03-query-bounding-and-indexes.md](specs/03-query-bounding-and-indexes.md) |
| A (critical path) | Issue 4 — call ordering contract | A's Issue 3 merged | [specs/04-call-ordering-contract.md](specs/04-call-ordering-contract.md) |

1:1 with `ROADMAP.md`'s seven issues, unbundled into one sprint each — no issue spans two sprints even though `ROADMAP.md` groups some of them into the same wave. "Starts after" reflects `ROADMAP.md`'s own Depends-on lines; if those ever change, update this table to match rather than re-deriving the tracks from scratch.

## Worktree per track

Each **track** runs in its own git worktree (not each sprint) — up to three can be active at once (A, B, C), each created when that track's next sprint is cleared to start and removed once that sprint's PR(s) merge:

- Track B's sprint (Issue 7) touches only this repo — a worktree here only.
- Track A's sprints touching vendored files (Issues 6, 1, 3, 4) need a branch inside the `token-metering` submodule too, once each fix is ported per Issue 6's sync process — a worktree of the outer repo doesn't branch a submodule for you; each worktree initializes its own submodule checkout independently, so parallel submodule branches don't collide.
- Track C's sprints (Issues 2, 5) touch only `token-metering/frontend/` — a submodule branch, no outer-repo change (Issue 5's contingent `server.py` piece, if chosen, would need the outer repo too, at which point it also needs Track A's worktree conventions).
- Within a single track, sprints stay sequential — don't start a track's next sprint until that track's current sprint's PR(s) are merged.
- Across tracks, only start a sprint once its "Starts after" condition in the table above is actually merged — the table is the gate, not calendar time.
- `docs/tasks/<slug>/` (the Plan step's task folder) is written in the outer repo's worktree for that track, regardless of which repo the issue's code touches.

## Notes

- Track A's Issue 4 and Track C's Issue 2 both edit `token-metering/frontend/src/components/SessionDrilldown.tsx`, in unrelated regions (`ROADMAP.md`'s Cross-wave notes) — land whichever merges second on top of the other's diff, don't parallel-branch the same file from a stale base.
- If a sprint's implementation reveals an issue needs splitting or reordering, amend `ROADMAP.md` first (including its Depends-on line), then reflect the change in the sprint table above — don't let the two drift.
- No `GOAL-STATE.md` yet — with zero sprints run, a separate log/detail file would be empty scaffolding. This project's log lives directly in `GOAL-CONDITION.md`'s Current status until enough sprints have run to justify splitting detail out the way `token-metering`'s own feature did.
