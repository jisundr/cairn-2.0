# Goal condition: token-metering follow-ups

**Entry point for this project** — read this file first when resuming or checking status; only open `GOAL.md` (process) or the design docs (`requirements.md`/`specs/*.md`/`ROADMAP.md`) when the task at hand actually needs that detail, not by default.

Definition of done — the conditions that must hold for these seven fixes to be considered complete.

## Current status

**On resume, before starting anything new: for any track below marked "PR open," check whether that PR has merged** (a sprint is published when its PR opens, but only closes on merge — see `GOAL.md`'s per-sprint steps). If merged, mark the issue done, update this section per `GOAL.md`'s resume instructions, then proceed; if not, work a different unblocked track or stop here.

Not started — `requirements.md`, `specs/*.md`, `ROADMAP.md`, this file, and `GOAL.md` exist; no sprint has begun.

- **Track A (critical path)**: not started. Next: Issue 6 (vendoring drift guard).
- **Track B**: not started. Next: Issue 7 (architecture doc staleness) — no dependency, can start any time.
- **Track C**: not started. Next: Issue 2 (UI overflow fixes) — no dependency, can start any time.

## Known issues (check before starting new work)

Bugs hit mid-sprint that weren't fixed on the spot — a resuming session should address or consciously re-defer these before starting a new sprint on the affected track. Empty means none open.

*(none — no sprint has run yet)*

## Done when (overall)

Pulled from `requirements.md`'s Success criteria:

- [ ] A worktree removed via cairn's normal teardown no longer appears anywhere in the dashboard (Projects panel, session filter pills) the next time the dashboard is loaded.
- [ ] (a) A session containing a subagent with a long name (e.g. `cairn:planner`) renders its agent row with the name and badge fully visible, not overlapping the token-bar column. (b) A rollup panel fed more rows than its cap shows the cap's worth of rows plus a "+N more" indicator, and no more.
- [ ] `session_trace()` and `call_detail()` return identical results to today's implementation while no longer scanning the full `calls` table to do it; `EXPLAIN QUERY PLAN` (or equivalent) shows the new index is used.
- [ ] Deleting `SessionDrilldown.tsx`'s local sort-and-renumber block does not change which call opens when a trace row's detail toggle is clicked, for any session with multiple agents and multiple calls per agent.
- [ ] A trace row's rendered time, a session's started/ended times, and the activity heatmap's bucketing all reflect the browser's local time zone when loaded from a non-UTC time zone; `format.ts`'s and `ActivityHeatmap.tsx`'s existing test suites still pass, asserting against explicit, non-flaky expected values.
- [ ] Intentionally editing one of the nine vendored files in only one of `tools/tokens/` or `token-metering/` causes a test or CI check to fail, naming the mismatched file.
- [ ] `03-architecture.md` no longer states that backend code targets the `token-metering` submodule; a reader following only `03-architecture.md` and `docs/tasks/vendor-token-metering-backend/` arrives at the same, correct understanding of where the code lives.

## Per-issue gate

Each issue's own condition — pulled from `ROADMAP.md`'s wave Gate lines. An issue isn't done until its gate passes, independent of the others.

- **Issue 6**: new drift-check script + CI job pass on the current (identical) trees.
- **Issue 7**: diff review confirming the four cited `03-architecture.md` spots now match `BUILD_BRIEF.md`/`ROADMAP.md`/`GOAL-CONDITION.md`'s (the shipped feature's) already-updated wording.
- **Issue 1**: `test_server.py`'s ghost-worktree fixture green in both `tools/tokens/` and `token-metering/`; Issue 6's drift check passes on the resulting tree.
- **Issue 3**: `test_db.py`'s index-presence assertion and `test_server.py`'s `EXPLAIN QUERY PLAN`/same-rows regression checks green in both copies; Issue 6's drift check passes.
- **Issue 4**: `test_server.py`'s multi-agent/multi-call fixture green; `token-metering/frontend/`'s `npm run build && npx playwright test` green; Issue 6's drift check passes.
- **Issue 2**: `token-metering/frontend/`'s `npm run build && npx playwright test` green, including new fixture cases for a long subagent name and an over-cap panel.
- **Issue 5**: `npm run build && npx playwright test` green, including the `timezoneId`-scoped fixed-timezone, DST-boundary, and local-calendar-day-crossing cases; Issue 6's drift check additionally applies only if the heatmap wire-shape decision touches `server.py`.

## Invariants (must stay true throughout, not just at the end)

- `tools/tokens/` stays the live source for its files; `token-metering/`'s copy stays a synced, frozen mirror — never the reverse.
- The server stays UTC end-to-end; localization happens only at the frontend's rendering boundary (`specs/05-utc-time-localization.md`'s Architecture).
- Capture stays advisory-only and pricing/queries stay read-time-only lookups — none of these seven fixes introduces a write-time migration.
- `tools/budget.py` covers only `tools/tokens/`'s copy — `token-metering/frontend/` still gates itself via the submodule's own `.harness/`.

## Explicitly out of scope (not a failure to satisfy these)

Pulled from `requirements.md`'s Non-goals:

- A general project/worktree-lifecycle tracking system beyond what issue 1's fix displays.
- Query pagination, rotation, or archival of `tokens.db`'s history beyond issue 3's bounding/indexing.
- Redesigning `HbarList`'s or `SessionDrilldown.tsx`'s visual language beyond the two overflow cases in issue 2.
- Any change to where pricing, rollups, or other read-time computation happens, beyond issue 4 removing the one duplicated sort.
- Any change to `tools/tokens/`'s zero-pip-dependency, stdlib-only constraint, or to the frontend's existing dependency set.
- De-duplicating `tools/tokens/` and `token-metering/`'s backend copy into one physical source — issue 6 only adds a drift guard on top of today's two-copies-by-design state.

## Backlog (deferred, not scheduled to an issue)

*(none yet — carry forward anything raised during a sprint that isn't in scope for that issue's spec, rather than expanding the spec after the fact)*
