# Plan — Track B / Wave 3: charts

Design: `../DESIGN.md`'s Graticule Bar Charts component section. The riskiest wave — resolves both open architecture questions before implementation starts. Depends on Wave 1 only, not Wave 2.

## Open question resolved: chart technique → customize `recharts`, don't go bespoke

`requirements.md`'s Non-goals already names "replacing `recharts` with a fully bespoke charting engine" as the default-avoid, reconsidered only if customization can't hit the mockup's look. It can: the mockup's graticule background is a repeating grid — `recharts`' `CartesianGrid` (custom `stroke`/`strokeDasharray` to match the hairline grid) reproduces it directly. The mockup's calibrated trace/tick overlay — a polyline with tick marks at each data point — maps to a custom `Dot` renderer on `recharts`' `Line` component (tick glyph in place of the default dot) plus a custom `Line` stroke matching `DESIGN.md`'s trace styling.

**Resolution: customize.** `CartesianGrid` for the graticule, custom `Dot`/`Line` renderers for the trace/tick device, inside the existing `ResponsiveContainer`. This keeps `recharts`' built-in tooltip, resize, and live-data (15s poll) behavior intact, which Goal 4 requires and a bespoke rebuild would have to reimplement from scratch for no visual gain.

## Open question resolved: `ActivityHeatmap.tsx` color → ink-scale gradient, not a special case

`DESIGN.md`'s Ink-Scale Data Rule reserves the single amber `--signal` accent for triggered/selected/warning states and puts multi-series data on the ink channel scale (`--ch1`–`--ch4`). A heatmap's intensity gradient isn't multi-series data in that literal sense, but it's also not a triggered/selected/warning state — nothing about "this cell has more activity than that cell" is a warning.

**Resolution: ink-scale gradient.** Intensity steps map onto the ink scale (`ink` → `ink-soft` → `ink-faint` → `bone-dim`, low-to-high or high-to-low matching the mockup's existing direction), consistent with the rule's spirit — reserve amber for triggered/selected/warning, never for volume alone — without inventing a new named rule or amending `DESIGN.md`.

## Scope

- `token-metering/frontend/src/components/TokensPerDayPanel.tsx` — graticule `CartesianGrid` + custom `Dot`/`Line` renderers
- `token-metering/frontend/src/components/ActivityHeatmap.tsx` — ink-scale intensity recolor

## Steps

1. **Plan** — `cairn:scope` → `cairn:planner`, using this file (including both resolutions above) as primary input. Present the plan for approval before dispatching `builder`.
2. **Worktree**: new branch inside `token-metering/` for Track B (parallel with Track A's Wave 2 worktree).
3. **Implement** — `cairn:builder`:
   - `TokensPerDayPanel.tsx`: custom `CartesianGrid` props for the graticule; custom `Dot` component rendering the tick glyph at each point; `Line` stroke/width matching `DESIGN.md`'s trace styling. Preserve existing tooltip, `ResponsiveContainer` resize, and the 15s live-data poll untouched.
   - `ActivityHeatmap.tsx`: swap whatever color function currently maps intensity → fill onto the ink scale's 4 (or however many `DESIGN.md`'s scale defines) steps.
4. **Gate** — `npm run build && npx playwright test` inside `frontend/`.
5. **Confirm tests** — existing chart coverage (render, tooltip/hover, live-data update on the 15s poll) re-run against the new rendering; extend with a case asserting the graticule/trace device is actually present (not just that the chart renders) if no such assertion exists today.
6. **Test manually** — `cairn:run` against a real session, watch `TokensPerDayPanel.tsx` across at least one 15s poll cycle to confirm the custom `Dot`/`Line` renderers don't break on a live data update (Playwright's fixtures are static, not a true live-poll test).
7. **Review** — `cairn:reviewer` against the diff, scoped to this wave.
8. **PR** — opened inside the `token-metering` submodule, diff scoped to this wave only.

## Done when

Wave 3's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip Wave 3's checkbox there, log the merge date, and start Track B's Wave 4.
