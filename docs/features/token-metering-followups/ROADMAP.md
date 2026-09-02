# Roadmap: token-metering follow-ups

Delivery plan for `requirements.md`'s seven issues, sequenced into four waves. Design detail lives in each `specs/*.md`; this doc only sequences them and calls out the dependencies between them that the specs themselves flag but don't resolve into an order.

## Why this order

Three of the seven fixes (issues 1, 3, 4) touch files that `specs/06-vendoring-drift-guard.md` treats as required to stay byte-identical between `tools/tokens/` (this repo, live source) and `token-metering/` (submodule, frozen backend copy) — `db.py`, `server.py`, and their tests. Specs 01, 03, and 04 all say explicitly that their fix "applies to `token-metering/`'s copy once `specs/06-vendoring-drift-guard.md`'s sync process carries it across." That only works cleanly if the sync process (and the CI check that enforces it) exists *before* those three fixes land — otherwise each one has to be manually ported to the frozen copy with nothing checking the port was done correctly, which is the exact failure mode issue 6 exists to catch. So the drift guard goes first, not last.

The remaining two issues (2, 5) touch only `token-metering/frontend/`, which isn't vendored — no interaction with the drift guard, no reason to wait.

## Status

All four waves done. Wave 1 (commits `f87eaa8`, `6e31ae1`): issue 6's vendoring drift guard (`tools/tokens/check_vendoring_sync.py` + the `vendoring-drift` CI job) and issue 7's `03-architecture.md` correction. Wave 2 (commits `aec41ce`, `b69c24a`): issue 1's ghost-project cleanup in `discover_projects()` and issue 3's session-scoped indexes + bounded query path. Wave 3 (commit `94ccbae`): issue 4's `global_position` call-ordering contract, with `SessionDrilldown.tsx`'s duplicated client-side sort deleted in the same change. Wave 4 (commits `4771739`, `16b2f87` + submodule `7319ff1`): issue 2's agent-row badge wrap and `HbarList` row cap, and issue 5's UTC-to-local time rendering plus the `/api/heatmap` wire-shape redesign (raw per-call rows, client-side local bucketing) to handle DST transitions correctly. All seven issues in `requirements.md` are closed.

## Waves

Each wave is one or more independently gated commits, per this repo's own one-artifact-per-commit discipline (`CLAUDE.md`) — a wave groups commits that ship together for a coherent reason, it isn't itself one commit.

### Wave 1 — Guardrails, no behavior change

- **Issue 6** (`specs/06-vendoring-drift-guard.md`): verification script diffing the fixed file list between `tools/tokens/` and `token-metering/`, plus a new, separate CI job that checks out the submodule to run it (the existing `budget` job deliberately never does).
- **Issue 7** (`specs/07-architecture-doc-staleness.md`): correct `03-architecture.md`'s four stale submodule-only spots to match `BUILD_BRIEF.md`/`ROADMAP.md`/`GOAL-CONDITION.md`'s already-updated wording.

Neither touches runtime code. Issue 7 has zero dependency on anything else in this roadmap and could ship before, after, or independently of issue 6 — grouped here because both are low-risk, no-behavior-change housekeeping worth clearing before the waves that touch shared files.

- Depends on: nothing.
- Tests: per spec — issue 6's script + new CI job exercised against the current (identical) trees; issue 7 has no test, just a diff review against the four cited spots.
- Gate: `python tools/budget.py` clean; `python -m pytest tools/` green; new CI job passes on a clean (pre-drift) tree.

### Wave 2 — Backend correctness & scale

- **Issue 1** (`specs/01-ghost-project-cleanup.md`): `discover_projects()` skips a `known-projects.json` entry whose path no longer resolves on disk.
- **Issue 3** (`specs/03-query-bounding-and-indexes.md`): indexes on `calls.session_id`, the `substr(timestamp,1,19)` expression, `tool_uses.session_id`, `usage_limit_events.session_id`; `session_trace()`/`call_detail()` bound their query to the session's own known time window instead of scanning every row.

Both are backend-only fixes to `tools/tokens/{db.py,server.py}`, ported to `token-metering/`'s copy per wave 1's sync process, with no frontend coordination required.

- Depends on: Wave 1 (the drift guard must exist to catch a copy that's ported incorrectly, and to keep both copies identical going forward).
- Tests: `test_db.py`/`test_server.py` extensions per each spec — a ghost-worktree fixture for issue 1, an `EXPLAIN QUERY PLAN` index-usage assertion plus a same-rows regression check for issue 3.
- Gate: `python tools/budget.py` clean; `python -m pytest tools/` green; `pytest test_db.py test_server.py` inside `token-metering/`; wave 1's drift check passes on the resulting tree.

### Wave 3 — Cross-boundary contract change

- **Issue 4** (`specs/04-call-ordering-contract.md`): `build_session_trace()` adds a `global_position` field per call; `SessionDrilldown.tsx`'s duplicated client-side sort-and-renumber block is deleted in the same change, since a partial rollout (server field added, client still computing its own) would leave two ordering sources live at once with no way to tell which one a given deploy is using.

Kept separate from Wave 2 despite also touching `server.py`, because this one changes an API response shape (an actual contract, not an internal query optimization) and requires a matching frontend commit — a different kind of risk than Wave 2's fixes, and `03-architecture.md`'s own Data flow section is the place a contract change like this would need to be reflected, which Wave 1's issue 7 will have already touched.

- Depends on: Wave 1 (drift guard, same reasoning as Wave 2 — `server.py` is a shared file). Not dependent on Wave 2, but shipping after it avoids two near-simultaneous changes to `server.py`'s `session_trace`/`call_detail` neighborhood.
- Tests: per spec — a multi-agent, multi-call-per-agent session fixture confirming the deep-link opens the same call before and after the client-side sort is deleted.
- Gate: `python tools/budget.py` clean; `python -m pytest tools/` green; `token-metering/frontend/`'s `npm run build && npx playwright test`; wave 1's drift check.

### Wave 4 — Frontend polish

- **Issue 2** (`specs/02-ui-overflow-fixes.md`): wrap the subagent-name badge onto a second line in `SessionDrilldown.tsx`'s agent-row grid instead of overflowing; add a row cap + "+N more" indicator to `HbarList.tsx`.
- **Issue 5** (`specs/05-utc-time-localization.md`): `format.ts`'s two time-rendering functions switch to `Date`'s local getters. The activity heatmap's re-bucketing has one implementation-time decision left open by the spec — whether `/api/heatmap` is replaced by a per-call feed the client buckets itself, or some other wire-shape change — which, if it lands on touching `tools/tokens/server.py`, pulls this issue under Wave 1/2's drift-guard dependency for that piece only; `format.ts`'s half of the fix has no such dependency.

Both issues live entirely in `token-metering/frontend/`, which isn't vendored — no interaction with the drift guard (format.ts's half of issue 5, and all of issue 2), so this wave has no hard ordering dependency on Waves 1-3 and could run in parallel. Sequenced last here only because it's the lowest-risk, most isolated wave, not because anything blocks it — a team wanting the visible UI fixes sooner should feel free to pull it forward.

Note: issue 2(a) and issue 4 both edit `SessionDrilldown.tsx`, in unrelated regions (badge wrapping vs. the sort-and-renumber block being deleted) — no expected conflict, but land whichever ships second on top of the other's diff rather than in parallel branches, to avoid a manual merge.

- Depends on: nothing hard; the heatmap half of issue 5 conditionally depends on Wave 1 only if its implementation touches `server.py`.
- Tests: per spec — issue 2 has no existing Playwright coverage named, so this wave adds fixture cases for a long subagent name and an over-cap panel; issue 5 adds `timezoneId`-scoped Playwright cases (fixed-timezone assertion, a DST-boundary case, a local-calendar-day-crossing case for the heatmap).
- Gate: `token-metering/frontend/`'s `npm run build && npx playwright test`. No `tools/budget.py` involvement unless issue 5's heatmap decision touches `server.py`, in which case Wave 1/2's backend gate also applies to that piece.

## Cross-wave notes

| Concern | Resolution | Wave impact |
|---|---|---|
| Shared-file drift during rollout | Wave 1's guard must exist before Waves 2-3 touch `db.py`/`server.py`, so every subsequent commit is checked against `token-metering/`'s copy as it lands, not after the fact. | Fixes the sequencing risk named in specs 01/03/04. |
| Issue 5's heatmap wire shape | Left as an implementation-time decision by `specs/05-utc-time-localization.md`; whichever way it's resolved determines whether Wave 4 has any backend surface at all. | Decide at the start of Wave 4, before writing the `ActivityHeatmap.tsx` change. |
| `SessionDrilldown.tsx` touched twice | Issues 2(a) and 4 edit the same file in different regions, in different waves. | Land sequentially (Wave 3 then Wave 4, per this roadmap's order), rebasing rather than parallel-branching. |
| `03-architecture.md` as the record of this work | Wave 1's issue 7 fixes the doc's *existing* staleness; it does not attempt to document Waves 2-4's new behavior (query bounding, `global_position`, localized rendering) — that's a documentation gap this roadmap doesn't resolve, since `requirements.md`'s Non-goals scope this effort to fixing what's wrong today, not maintaining `03-architecture.md` going forward as new work lands. | Worth a follow-up doc pass after Wave 3 if `03-architecture.md` is meant to stay current; out of scope here. |

## Testing (cross-wave)

- `python tools/budget.py` and `python -m pytest tools/` after every wave that touches `tools/tokens/` (Waves 1-3).
- `pytest` inside `token-metering/` (per its own `.harness/workflow.md`) after every wave that touches the submodule's backend copy (Waves 1-3) or its `frontend/` (Wave 3's client half, Wave 4).
- `npm run build && npx playwright test` inside `token-metering/frontend/` after every wave with a frontend change (Waves 3-4).
- The new drift-check CI job (Wave 1) runs on every subsequent wave that touches a vendored file (Waves 2-3), by construction — it's the mechanism, not a one-time gate.
