# Plan — Track B / Wave 3: charts

Design: `../../features/token-metering-dashboard-ui/DESIGN.md`'s Graticule Bar Charts component
section (Components; also the Ink-Scale Data Rule under Colors, and the Readout-face rule under
Typography). Concrete reference: the frozen `mockups/dashboard.html` (never edited) — graticule/
trace CSS at lines 350-415, the today/daily chart markup (incl. a full worked SVG trace overlay)
at lines 1105-1136, day-detail styling at lines 482-540, chart-headline styling at lines 457-480,
heatmap styling at lines 567-592. Source plan (architecture questions already resolved, carried
forward, not re-litigated): `../../features/token-metering-dashboard-ui/plans/03-charts.md`.

Worktree/branch already created per the scope record: `token-metering/.claude/worktrees/track-b`,
branch `wave-3-charts`.

## Scope

- `token-metering/frontend/src/components/TokensPerDayPanel.tsx`
- `token-metering/frontend/src/components/ActivityHeatmap.tsx`

Out of scope (scope record): a bespoke SVG charting engine in place of `recharts`; `Dashboard.tsx`
chrome/readouts (Wave 2, merged) and sessions/drilldown (`SessionsTable.tsx`, `SessionDrilldown.tsx`,
etc. — Wave 4, still on pre-Wave-1 tokens, untouched here); `mockups/dashboard.html`; backend
(`tools/tokens/`, `token-metering`'s backend copy). No prop, hook, or data-shape change to either
file — both stay on their current `points`/`calls` inputs and existing hooks (`useTimeseries`,
`useDayDetail`).

## Note on chart technique (applying 03-charts.md's resolution, not re-opening it)

03-charts.md resolves recharts-customization (`CartesianGrid` for the graticule, custom `Dot`/
`Line` for the trace/tick device) as the technique, "keeping recharts' built-in tooltip, resize,
and live-data poll behavior intact." Reading the current file: only the `sparkline` shape (30d/
month/6m/life) actually uses `recharts` today (`AreaChart`/`Area`/`ResponsiveContainer`). The
`hourly` and `daily-click` shapes are hand-rolled `div`/`button` markup with no `recharts` — there
is no existing tooltip/resize/poll behavior there to "keep intact." Actionables 2 and 3 below apply
the resolution accordingly: recharts customization where recharts already renders (sparkline);
the mockup's own CSS-background-graticule + absolute-SVG-overlay technique (which predates and
doesn't require recharts) for the hand-rolled bar shapes. See Risks.

## Actionables

1. **`TokensPerDayPanel.tsx` — token cleanup**, everywhere in the file:
   - `--blue` → `--signal`, `--blue-soft` → `--signal-soft` (selection state; The One Signal Rule).
   - `--block-line` → `--paper-line`. `--block-line` is used in the mockup but was not ported into
     `index.css` in Wave 1 (only `--paper-line`/`--paper-line-soft` exist there) — `index.css` isn't
     in this wave's paths, so don't add it back; use the token that already exists.
   - `--paper` (day-detail panel background) → `--bone-dim`, per `DESIGN.md`'s Bone Dim entry,
     which names "day-detail box" as one of its examples directly.
   - `--block` stays (still a current token — default bar fill).

2. **`TokensPerDayPanel.tsx` — hourly/daily-click bar shapes** (the `shape === "hourly"` /
   `"daily-click"` branch, currently a flex row of `button`/`div`):
   - Container: add the graticule `background-image` (two `linear-gradient`s — horizontal rows,
     vertical columns sized to `points.length`) matching `mockups/dashboard.html:356-359`'s
     `.bar-chart` rule, using `--paper-line-soft`; `position: relative` for the overlay below.
   - Add an absolutely-positioned `<svg>` trace overlay (`viewBox="0 0 100 100"
     preserveAspectRatio="none"`) computed from the same `points`/`maxTokens` data already used for
     bar heights: one `polyline` (`stroke: var(--ink-soft)`, width 1.25, non-scaling) through each
     bar's top-center point, plus one short perpendicular tick `line` per column
     (`stroke: var(--ink-faint)`) straddling the polyline's own y at that x — follow
     `mockups/dashboard.html:1134`'s worked example for the exact coordinate scheme (percentages,
     tick length) rather than re-deriving it.
   - Default bar: `bg-(--block) border border-(--paper-line) border-t-2 border-t-(--ink-faint)`.
   - Selected bar (`daily-click`, `selectedDate === p.bucket`): `border-(--signal) bg-(--signal-soft)
     border-t-(--signal)`, plus a small circular `--signal` marker above the bar (new small element,
     matching `mockups/dashboard.html:395-400`'s `::after` dot — a visual addition the restyle calls
     for, not a behavior/data change).
   - Day label (`<span>` under each bar): switch from label face (`font-label`) to readout face
     (`font-mono`), color `--ink-faint` at rest / bold `--ink` when selected — the mockup's `.day`
     rule (`mockups/dashboard.html:403-407`) is mono, not label face.

3. **`TokensPerDayPanel.tsx` — sparkline shape** (`AreaChart`/`Area`, `RANGE_OPTIONS` 30d/month/6m/
   life): replace the smooth-curve `Area` fill with the graticule + calibrated-trace device —
   `CartesianGrid` (`stroke="var(--paper-line-soft)"`) for the background, plus bars (`Bar`,
   `fill="var(--block)"`) with a `Line`/custom `Dot` trace drawn over them (`stroke="var(--ink-soft)"`
   for the line, a small tick-mark shape in the custom `Dot` instead of the default circle,
   `stroke="var(--ink-faint)"`) — recharts' `ComposedChart` (or equivalent composition) inside the
   same `ResponsiveContainer`/height/`isAnimationActive={false}` this shape already has. Same
   `dataKey="tokens"`, same `points` data — no new query, no new prop.

4. **`TokensPerDayPanel.tsx` — day-detail panel**:
   - Panel: `bg-(--bone-dim) border-(--paper-line)` (from Actionable 1).
   - Headline total value: add `font-mono` (readout face) — `mockups/dashboard.html:521`'s
     `.day-detail-total` is mono; current code (`text-[22px] font-bold tabular-nums`, no
     `font-mono`) is a Three-Face-Rule miss.
   - Per-model dot (`<span className="h-2 w-2 rounded-full bg-(--block-line)" />`): DESIGN.md's
     Ink-Scale Data Rule names "model breakdown dots" directly as `--ch1`-`--ch4` data — cycle
     `--ch1`/`--ch2`/`--ch3`/`--ch4` by the model row's index (mod 4), matching
     `mockups/dashboard.html:1190-1191`'s `style="background:var(--ch1)"` / `var(--ch2)` per row,
     instead of one flat color for every row.

5. **`ActivityHeatmap.tsx` — ink-scale recolor**, per 03-charts.md's resolution (already decided,
   not re-opened here):
   - Replace `LEVEL_CLASSES`' hardcoded hex (`#d7e0ea`, `#a9c0d6`, `#6f93b5`) and `--blue` with the
     four named ink-scale tokens: `--bone-dim` (no data) → `--ink-faint` → `--ink-soft` → `--ink`
     (low-to-high, matching the mockup's own `hm-0`→`hm-4` light-to-dark direction). Note: this is
     the resolution's own literal token list (`ink`/`ink-soft`/`ink-faint`/`bone-dim`), not the
     mockup's actual hex values for its middle steps, and not `--ch1`-`--ch4` (reserved by the
     Ink-Scale Data Rule for genuine multi-series data, not intensity) — 03-charts.md's stated
     reasoning for both.
   - Four tokens means four buckets, not five: adjust `levelFor()` from its current 0/25/50/75%
     quartile split (5 levels: 0-4) to a 3-way split (levels 0-3) so every level has a distinct
     token — 03-charts.md's "or however many DESIGN.md's scale defines" already anticipates this.
     No change to what's bucketed (still `tokens`/`max` ratio) or to the hover `title` text/content.
   - `border border-(--paper-line) bg-(--paper)` (level 0) → `border border-(--paper-line)
     bg-(--bone-dim)` (drop `--paper`).
   - No new legend, swatch, or markup beyond the existing cell grid — the mockup's `.heatmap-legend`
     has no counterpart in the current component and adding one would be new UI, not a restyle.

6. **Gate**: `npm run build && npx playwright test` inside `token-metering/frontend/`.

7. **Confirm/extend Playwright coverage** (`frontend/e2e/populated/dashboard.spec.ts`,
   `frontend/e2e/populated/timezone.spec.ts`):
   - Existing assertions on `data-testid`s (`chart-hourly`, `chart-daily-click`, `chart-sparkline`,
     `range-total-tokens`, `day-bar-<bucket>`, `day-detail-panel`, `day-detail-empty`,
     `day-detail-model-row`, `heatmap-cell-<dow>-<hour>` + its `title` attribute) re-run against the
     new markup unmodified — none assert on class names/tokens for these two files.
   - No existing assertion checks that the graticule/trace device itself is present. Add one case
     (e.g. asserting the `trace-overlay` SVG or its `polyline` renders inside `chart-daily-click`)
     per the scope record's `done_when`.

8. **Manual check** (`cairn:run`): load a populated project, watch `TokensPerDayPanel.tsx` across at
   least one 15s poll cycle (today/7d ranges) to confirm the custom trace/`Dot` renderer and the
   hand-rolled SVG overlay don't break or flicker on a live data refresh — Playwright's fixtures are
   static, not a true live-poll test (03-charts.md's step 6). Compare both components visually
   against `DESIGN.md`/the mockup.

9. **Review** — `cairn:reviewer` agent (never `review-pr`) against the diff from Actionables 1-5,
   scoped to this wave.

10. **PR** — opened by the main thread inside the `token-metering` submodule, scoped to Actionables
    1-5's diff only.

## Done when

`npm run build` is clean inside `token-metering/frontend/`; `npx playwright test` is green (existing
chart coverage re-run against new markup, extended per Actionable 7); neither file references
`--blue`, `--blue-soft`, `--block-line`, or `--paper`.

## Risks

- The chart-technique resolution (03-charts.md) is read as scoped to wherever `recharts` already
  renders (the sparkline shape) rather than requiring the hand-rolled hourly/daily-click bars to be
  migrated onto `recharts` too — migrating them would be a much larger structural change and risks
  the "no behavior change" constraint (click handling, `disabled`, existing `data-testid`s). If
  `reviewer` reads 03-charts.md's intent as covering all three shapes, re-check against the source
  plan's author intent before extending Actionable 2 into a `recharts`-based rebuild.
- Actionable 3's `Area` → `ComposedChart` (`Bar` + `Line` + `CartesianGrid`) swap is a bigger visual
  change to the sparkline than a pure recolor; verify against `DESIGN.md`'s three-density-variant
  description (hourly/spark vs. daily vs. monthly) once built, since the mockup itself never renders
  a "spark" instance to compare against pixel-for-pixel.
