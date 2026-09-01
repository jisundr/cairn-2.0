# Spec: frontend overflow fixes (`SessionDrilldown.tsx` agent-row, `HbarList.tsx` row cap)

Implementation spec for `requirements.md` issue 2 / goal 2. Two independent fixes in the same component family; grouped in one spec because both are small, confirmed-live visual bugs with no design-decision overlap between them.

## Architecture

**(a) Agent-row name column** — widen the fixed name column and let its content wrap onto a second line instead of truncating. Truncation (ellipsis) was considered and rejected: `cairn:planner`/`cairn:builder` names are the load-bearing identifier in that row (there's no tooltip or expansion elsewhere that would recover a truncated name), so hiding characters trades one visual bug for a usability regression. Widening `110px` outright was also considered, but the grid's other five columns are already tuned to the mockup's fixed-width numeric columns (`90px_90px_70px`) plus the `1fr` token bar — shrinking `1fr` to make room for a wider name column narrows the bar chart for every row, including the common short `main` case, for a problem that only `cairn:`-prefixed subagent names have. Wrapping the badge onto its own line inside the existing 110px column fixes the overflow without touching the other five columns' widths or the bar chart's proportions.

**(b) `HbarList` row cap** — a `maxRows` prop, default matching the panels' current implicit expectation (see Components), that slices the rows array and renders a "+N more" trailing row when the input exceeds it. This is additive to the existing `HbarListProps` shape (no existing caller's rendering changes unless it happens to pass more rows than the cap), so every one of `HbarList`'s five current call sites (agent/skill/model/tool/MCP-server rollups in `Dashboard.tsx`) gets the fix for free once the component enforces its own cap, matching the issue's ask for something "consistent with the component's existing visual style" applied to the shared component rather than to one call site.

## Components

### `token-metering/frontend/src/components/SessionDrilldown.tsx`'s `AgentRow` (around line 89-96)

Current:

```tsx
<span className="font-semibold">
  {name}
  {isSubagent && (
    <span className="font-label ml-1.5 rounded border border-(--block-line) px-1 py-0.5 text-[9.5px] lowercase text-(--ink-soft)">
      subagent
    </span>
  )}
</span>
```

New — drop the `whitespace-nowrap` assumption implicit in a single-line `<span>` and let the badge wrap:

```tsx
<span className="flex flex-wrap items-center gap-x-1.5 gap-y-0.5 font-semibold leading-tight">
  <span className="truncate">{name}</span>
  {isSubagent && (
    <span className="font-label shrink-0 rounded border border-(--block-line) px-1 py-0.5 text-[9.5px] lowercase text-(--ink-soft)">
      subagent
    </span>
  )}
</span>
```

`flex flex-wrap` lets the badge drop to its own line inside the column's 110px width once `name` plus badge no longer fit on one line; `truncate` on the inner name span is a backstop for a name long enough that even alone it wouldn't fit (not expected in practice — cairn's own agent names top out around `cairn:reviewer`, 14 characters — but keeps a pathological custom-agent name from re-introducing the same overflow). `main`'s row (`isSubagent` false, no badge) renders identically to today since the flex wrapper has only one child and no wrapping is triggered.

No change to the grid's `grid-cols-[18px_110px_1fr_90px_90px_70px]` template (line 82) — the fix stays inside the 110px column.

### `token-metering/frontend/src/components/HbarList.tsx`

Current signature and body render every row unconditionally (lines 1-38). New:

```tsx
export interface HbarRow {
  label: string;
  value: number;
  display: string;
}

interface HbarListProps {
  rows: HbarRow[];
  emptyText?: string;
  maxRows?: number;
  "data-testid"?: string;
}

const DEFAULT_MAX_ROWS = 8;

export function HbarList({
  rows,
  emptyText = "No data yet.",
  maxRows = DEFAULT_MAX_ROWS,
  "data-testid": testId,
}: HbarListProps) {
  if (rows.length === 0) {
    return <p className="text-[11.5px] text-(--ink-soft)">{emptyText}</p>;
  }
  const visible = rows.slice(0, maxRows);
  const hiddenCount = rows.length - visible.length;
  const max = Math.max(...visible.map((r) => r.value), 1);

  return (
    <div className="flex flex-col gap-2.5" data-testid={testId}>
      {visible.map((row) => (
        <div key={row.label} className="grid grid-cols-[minmax(76px,auto)_1fr_54px] items-center gap-2.5">
          <span className="font-label text-[11.5px] text-(--ink)">{row.label}</span>
          <div className="h-3 overflow-hidden rounded-[3px] border border-(--paper-line) bg-(--paper)">
            <div
              className="h-full border-r border-(--block-line) bg-(--block)"
              style={{ width: `${(row.value / max) * 100}%` }}
            />
          </div>
          <span className="font-label text-right text-[10.5px] text-(--ink-soft)">{row.display}</span>
        </div>
      ))}
      {hiddenCount > 0 && (
        <p className="font-label text-[10.5px] text-(--ink-soft)" data-testid={testId ? `${testId}-more` : undefined}>
          +{hiddenCount} more
        </p>
      )}
    </div>
  );
}
```

`max` (the bar-width denominator) is computed from `visible` rows only, not the full `rows` array — keeps the rendered bars' relative proportions meaningful for what's actually shown, rather than being silently compressed by an unshown outlier's value. `DEFAULT_MAX_ROWS = 8` is a starting figure sized to the panels' fixed heights in the mockup (`docs/features/token-metering/mockups/dashboard.html`); confirm against the mockup's actual panel heights during implementation and adjust the constant if 8 over- or under-fills a panel — this is a tuning value, not a design decision, so a builder can adjust it without a new spec.

No prop changes needed at any of `Dashboard.tsx`'s five `HbarList` call sites (lines 97, 106, 121, 133, 141) — they inherit `DEFAULT_MAX_ROWS` unless a specific panel is found during implementation to need a different cap, in which case that call site passes `maxRows` explicitly.

## Data flow

No data-flow change in either fix — both are pure rendering adjustments over props/data the components already receive. `HbarList`'s row cap slices client-side data already fetched by `Dashboard.tsx`'s existing rollup hooks; no new API call, no change to `/api/rollup/*`'s response shape.

## Error handling

- (a) A subagent name plus badge that still doesn't fit even after wrapping (name alone wider than 110px) → `truncate` on the name span ellipsizes it; not expected to occur with cairn's current agent-naming convention, but doesn't overflow the column if it did.
- (b) `rows.length <= maxRows` → no "+N more" indicator rendered, identical output to today's unbounded render. `maxRows` explicitly passed as `0` or negative → treated as "show nothing but the indicator"; not a case any current call site produces, not specially guarded beyond `slice`'s own defined behavior for those inputs.

## Testing

`token-metering/frontend`'s existing Playwright e2e suite (`e2e/populated/dashboard.spec.ts`) plus any component-level test framework already in the project (confirm during implementation whether one exists beyond Playwright — none was found under `frontend/src/` at time of writing, so this may be the first):

- Agent-row: a fixture session with an agent named `cairn:planner` (or a comparably long subagent name) renders its row with the badge visible and no visual overflow into the token-bar column — Playwright screenshot or bounding-box assertion (`getBoundingClientRect()` of the name cell vs. the adjacent bar-cell) rather than a pixel-diff snapshot, to avoid a snapshot test that's brittle to unrelated style changes.
- Agent-row: a `main` row (no badge) renders unchanged from today — same bounding-box assertion, or a snapshot comparison against the current build's output for this one case if a visual-regression harness already exists.
- `HbarList`: a rollup panel fed more rows than `maxRows` shows exactly `maxRows` rows plus a "+N more" line with the correct count.
- `HbarList`: a rollup panel fed fewer rows than `maxRows` shows all of them, no "+N more" line — matches `e2e/populated/dashboard.spec.ts`'s existing assertion that `tool-rollup` contains `"Bash"` (line 18), extended to also check the absence of the "more" indicator against today's fixture, which seeds only 4 distinct tool uses (`e2e/fixtures/seed.py:90-117`), well under `DEFAULT_MAX_ROWS`.
- `e2e/fixtures/seed.py`'s tool-use fixture is extended with enough additional distinct `tool_name`/`tool_use_id` entries (more than `DEFAULT_MAX_ROWS`) to reproduce the over-cap case the review found live with 20 rows, and `dashboard.spec.ts` gets a new assertion against that extended fixture: the `tool-rollup` panel shows exactly `maxRows` rows plus a "+N more" indicator with the correct count.

Gate: `npm run build` regenerates `token-metering/static/`; `npx playwright test` green against that build, per `token-metering/.harness/workflow.md`.
