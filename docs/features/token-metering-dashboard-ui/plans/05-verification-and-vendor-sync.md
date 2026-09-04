# Plan — Track A / Wave 5: verification & vendor sync

Closing wave — no component code changes here; it confirms the port is complete and syncs the vendored copy. Depends on Waves 2, 3, and 4 all merged.

## Scope

- No `token-metering/frontend/src/` changes expected — this wave is verification, not implementation. If the manual smoke test (step 6) surfaces a regression, fix it here as a small follow-up commit rather than reopening an earlier wave.
- `tools/tokens/static/` in this repo — re-vendored from `token-metering/frontend/`'s rebuilt `static/`, per the existing convention (most recently commit `54b2c31`)

Two PRs come out of this wave: one inside the `token-metering` submodule (any smoke-test fixes), one in this repo (the re-vendor commit) — never combined.

## Steps

1. **Plan** — `cairn:scope` → `cairn:planner`, using this file as primary input. Present the plan for approval before dispatching `builder` (even though this wave is mostly verification, the re-vendor commit and any smoke-test fix still go through the same process).
2. **Worktree**: Track A's existing worktree/branch, continued from Wave 2 (or freshly created if Wave 2's was torn down after merge). The re-vendor commit lands in this outer repo directly, not the submodule worktree.
3. **Run the full gate**:
   - `pytest test_*.py` inside `token-metering/` — confirms the untouched backend stays green.
   - `npm run build && npx playwright test` inside `frontend/` — full suite, both fixture states (populated, cold-start), confirming nothing in Waves 2-4 regressed another wave's surface.
4. **Confirm tests** — no new cases expected unless the manual smoke test (step 5) surfaces something Waves 2-4's automated coverage missed; if it does, add the missing case as part of this wave's fix rather than deferring.
5. **Test manually** — `cairn:run` against a real session, covering `requirements.md`'s Success criterion 5 in full: a cold-start/empty project, a populated project, a session mid-usage-limit warning, and an agent-select interaction in the drilldown. This is the mockup review's own evidence set (`.impeccable/review/{desktop,mobile,sessions-interaction,empty-state}.png`), now exercised live instead of statically — compare each state against its corresponding screenshot.
6. **Re-vendor**: rebuild `frontend/`'s `static/` via `npm run build`, then copy it into this repo's `tools/tokens/static/`, mirroring commit `54b2c31`'s convention exactly (same source/destination, same commit shape).
7. **Gate the re-vendor commit** — `python tools/budget.py` clean, in this repo.
8. **Review** — `cairn:reviewer` against both diffs (any submodule-side smoke-test fix; the re-vendor commit), each scoped to its own repo.
9. **PR** — two, opened separately: the submodule-side fix (if any) inside `token-metering`; the re-vendor commit in this repo. If step 5 found nothing to fix, only the re-vendor PR is needed.

## Done when

Wave 5's gate in `../GOAL-CONDITION.md` is satisfied and both PRs (or the one re-vendor PR, if no fix was needed) have merged. Flip Wave 5's checkbox there, and check off every item in `../GOAL-CONDITION.md`'s Done when section — this closes the port.
