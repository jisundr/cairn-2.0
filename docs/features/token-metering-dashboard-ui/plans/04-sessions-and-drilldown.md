# Plan — Track B / Wave 4: sessions & drilldown

Design: `../DESIGN.md`'s Session List/Drilldown and Meter/Progress Bars component sections. The largest wave by file count. Depends on Wave 1 only; sequenced after Wave 3 within Track B purely because this is a solo effort running one worktree per track (`../GOAL.md`'s Worktree note) — no content dependency on Wave 3.

## Scope

- `token-metering/frontend/src/components/SessionsTable.tsx` — session-item rows, dashed-bottom-border list, flag-dot marker
- `token-metering/frontend/src/components/SessionDrilldown.tsx` — agent-select rows with channel-color swatches, mini-bars, chat-thread turns
- `token-metering/frontend/src/components/HbarList.tsx` — flat bordered tracks, ink-scale/channel-color fills
- `token-metering/frontend/src/components/ProjectsPanel.tsx`, `CallPage.tsx`, `TraceDrawer.tsx`, `TraceDetailContent.tsx` — remaining panels and the per-call drill-through, brought to the same vocabulary
- `token-metering/frontend/e2e/populated/dashboard.spec.ts:41,45` — update the `toHaveClass(/border-\(--blue\)/)` assertions on `sessions-range-30d`/`sessions-range-life` to whatever selector/token the ported range-tab component actually uses (Goal 6)

`SessionDrilldown.tsx`'s existing sort/ordering logic (`token-metering-followups` issue 4's `global_position` contract) is untouched by this port — restyle only.

## Steps

1. **Plan** — `cairn:scope` → `cairn:planner`, using this file as primary input. Present the plan for approval before dispatching `builder`.
2. **Worktree**: Track B's existing worktree/branch, continued from Wave 3 (or freshly created if Wave 3's was torn down after merge).
3. **Implement** — `cairn:builder`:
   - `SessionsTable.tsx`: session-item rows with dashed bottom borders, flag-dot marker per `DESIGN.md`.
   - `SessionDrilldown.tsx`: agent-select rows with channel-color swatches (`--ch1`–`--ch4`), mini-bars, chat-thread turn styling.
   - `HbarList.tsx`: flat bordered tracks, ink-scale/channel-color fills replacing the old palette.
   - `ProjectsPanel.tsx`, `CallPage.tsx`, `TraceDrawer.tsx`, `TraceDetailContent.tsx`: same vocabulary applied — no data-binding, routing, or interaction change.
   - Update `dashboard.spec.ts:41,45`'s two assertions to match whatever CSS custom property or class the restyled range-tab component now uses for its active state.
4. **Gate** — `npm run build && npx playwright test` inside `frontend/`.
5. **Confirm tests** — `dashboard.spec.ts`'s existing session-selection and drilldown coverage re-run against the new markup, including the two updated range-tab assertions.
6. **Test manually** — `cairn:run` against a real session, exercise an agent-select interaction in the drilldown (Playwright's fixtures don't fully cover interactive agent-selection against live data) — confirm channel-color swatches and mini-bars render correctly.
7. **Review** — `cairn:reviewer` against the diff, scoped to this wave.
8. **PR** — opened inside the `token-metering` submodule, diff scoped to this wave only.

## Done when

Wave 4's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip Wave 4's checkbox there, log the merge date — Track B is done. Wave 4 merging is also one of the two conditions gating Track A's Wave 5 (the other being Wave 2).
