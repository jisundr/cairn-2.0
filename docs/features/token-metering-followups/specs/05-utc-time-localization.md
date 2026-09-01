# Spec: localize displayed times, keep the heatmap and tests non-flaky

Implementation spec for `requirements.md` issue 5 / goal 5. Converts every user-facing time rendering from raw UTC to the browser's local time zone, and re-buckets the activity heatmap by local day-of-week/hour — without breaking `format.ts`'s own test-simplicity rationale for rendering UTC in the first place.

## Architecture

The server stays UTC end to end — `tools/tokens/server.py`'s `_iso()` (line 141-142), `rollup_heatmap()` (lines 309-324), and every timestamp column in `db.py` remain UTC, unchanged. Localization happens only at the frontend's rendering boundary, in two places:

- **`format.ts`'s two string-slicing functions** (`formatTimeOfDay`, `formatStarted`) switch from slicing the raw ISO string to constructing a `Date` from it and reading its local-time fields (`getHours()`/`getMinutes()`/etc., which JS's `Date` always returns in the runtime's local time zone) — no new dependency, no timezone library, since the browser's own `Date` object already knows the viewer's offset.
- **The activity heatmap** moves its day-of-week/hour bucketing from the server's UTC-based `rollup_heatmap()` to the client, in `ActivityHeatmap.tsx`. `rollup_heatmap()` today buckets `calls.timestamp` server-side into a fixed 168-cell UTC grid before the response ever reaches the browser (`server.py:309-324`) — that bucketing can't be "re-localized" after the fact without knowing each individual call's original timestamp, which the current `/api/heatmap` response shape doesn't carry (`HeatmapCell` is `{day_of_week, hour, calls, tokens}`, already aggregated). Two options were weighed:
  1. Keep `/api/heatmap` as is, and have the server accept a UTC-offset query parameter so `rollup_heatmap()` buckets in the requested zone.
  2. Change `/api/heatmap` to return per-call rows (or a per-call heatmap-input) instead of pre-aggregated cells, and bucket client-side using each row's local `Date`.

  Option 1 is rejected: it requires the server to know the browser's UTC offset (a query parameter sent on every poll), adds a parameter to an endpoint whose whole design point is "no request-specific state" (`03-architecture.md`'s read-time-only philosophy), and doesn't handle a viewer whose offset changes mid-session (DST, or a laptop that travels) without a fresh request. Option 2 keeps the server dumb and stateless (still just applies pricing/rollups at read time) and pushes zone-awareness to where zone-awareness naturally lives — the browser. Chosen: **option 2**.

  Concretely, `/api/heatmap` is replaced by a lighter-weight per-call timestamp feed the client buckets itself. Rather than inventing a new endpoint, `heatmap()`/`rollup_heatmap()` are dropped from `server.py`'s API surface and `ActivityHeatmap.tsx` instead derives its grid from the same range-scoped `calls` data the rest of the dashboard already fetches for that range (e.g. whatever endpoint already returns per-call rows for the active range — `session_trace`/`call_detail` return per-call rows, but scoped to one session, not the "last 7 days" window `03-architecture.md` says the heatmap panel covers today; confirm during implementation whether a new `/api/rollup/calls?range=...`-style raw-rows endpoint is the right vehicle, or whether it's cheaper to keep `/api/heatmap` but add per-cell UTC-hour granularity fine enough for the client to re-bucket losslessly — this file names the tradeoff and the chosen direction but the exact wire shape needs one more decision at implementation time, since it changes the `/api/heatmap` contract in a way this spec's author couldn't fully pin down without also redesigning that endpoint's response, which is beyond this issue's proportional scope).

## Components

### `token-metering/frontend/src/lib/format.ts`

```ts
export function formatTimeOfDay(iso: string): string {
  const d = new Date(iso);
  const hh = String(d.getHours()).padStart(2, "0");
  const mm = String(d.getMinutes()).padStart(2, "0");
  const ss = String(d.getSeconds()).padStart(2, "0");
  return `${hh}:${mm}:${ss}`;
}

export function formatStarted(iso: string): string {
  const d = new Date(iso);
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  const hh = String(d.getHours()).padStart(2, "0");
  const mm = String(d.getMinutes()).padStart(2, "0");
  return `${month}/${day} ${hh}:${mm}`;
}
```

Both now use `Date`'s local-time getters instead of `String.slice()` on the raw UTC ISO string. `formatDayLabel()` (date-only, no time-of-day component) and `formatRelativeToNow()` (already constructs a `Date` and diffs by elapsed milliseconds, which is timezone-agnostic by construction) are unchanged — neither has the UTC-vs-local problem described in the issue.

### `token-metering/frontend/src/components/ActivityHeatmap.tsx`

Once the wire shape from Architecture's option 2 is settled, `ActivityHeatmap`'s `levelFor`/grid-building logic (lines 13-20, 25-26) is unchanged — it still buckets into a 7×24 grid and colors by relative token volume. What changes is *where the day-of-week/hour key comes from*: today it reads `cell.day_of_week`/`cell.hour` directly off server-provided `HeatmapCell` rows; after this change, it computes `new Date(row.timestamp).getDay()`/`.getHours()` itself from raw per-call rows, then aggregates into the same 168-cell shape client-side (the aggregation logic — sum `tokens`, count `calls`, per cell — moves from `rollup_heatmap()` in Python to an equivalent reduce in this component, but the shape it produces and consumes downstream (`LEVEL_CLASSES`, `levelFor`) is unchanged).

### `tools/tokens/server.py`

`rollup_heatmap()` (lines 309-324) and the `/api/heatmap` route (`handle_api`, line 785-786) are removed once the frontend no longer calls them — or kept and left unused if the wire-shape decision above lands on "add a new endpoint alongside" rather than "replace." This spec doesn't remove them preemptively; that's the implementation-time decision flagged in Architecture.

## Data flow

1. The dashboard's existing range-scoped call fetch (whatever range the Activity panel is scoped to — `03-architecture.md` says "last 7 days," matching `Dashboard.tsx:115`'s copy) supplies per-call rows with their original UTC `timestamp` to `ActivityHeatmap`, instead of the fully-aggregated `/api/heatmap` payload.
2. `ActivityHeatmap` constructs a `Date` per row, reads its local `getDay()`/`getHours()`, and aggregates into the same 168-cell grid shape it renders today.
3. `formatTimeOfDay()`/`formatStarted()` are called exactly as today from `SessionDrilldown.tsx`/wherever else they're used, but now return local-time strings.

## Error handling

- A malformed or unparseable `iso` string reaching `formatTimeOfDay`/`formatStarted` → `new Date(iso)` produces an `Invalid Date`; `getHours()` etc. on it return `NaN`, rendering `"NaN:NaN:NaN"` — not worse than today's behavior (slicing a malformed string already produces garbage), and not a case this codebase's own timestamps are expected to produce (`server.py`'s `_iso()` always emits a well-formed ISO string).
- A per-call timestamp landing in a different local calendar day than its UTC date (e.g. 11pm UTC is already the next local day west of UTC, or vice versa east of UTC) → this is precisely the behavior change being fixed, not an error case — the heatmap cell it lands in shifts by design.

## Testing

`token-metering/frontend/package.json` has no unit-test runner today (`@playwright/test` is the only test dependency) — introducing one (Vitest, Jest) for this fix alone would add a new dev dependency for a single file's worth of pure functions, disproportionate to this issue. Both `format.ts` and `ActivityHeatmap.tsx`'s new behavior are instead covered through Playwright, using its built-in `timezoneId` context option (no new dependency — already part of `@playwright/test`) to fix the browser's timezone per test, which is the more faithful test anyway since the bug is about what a real browser in a real timezone renders:

- A new (or extended) `playwright.config.ts` project, or a per-test `test.use({ timezoneId: "America/New_York" })` override, fixes the browser's timezone for the relevant spec file.
- `e2e/populated/dashboard.spec.ts` (or a new spec alongside it) asserts a trace row's rendered time and a session's started/ended times, for a fixture call at a known UTC timestamp, against the manually-computed expected local-time string in the fixed test timezone — replacing an implicit reliance on UTC-equals-displayed with an explicit local-time assertion.
- One test case uses a seeded UTC timestamp that falls on either side of a spring-forward/fall-back transition in the fixed test timezone, confirming the browser's own `Date` handles the DST boundary correctly (this is exercising the browser's `Date` implementation, not hand-rolled logic, so the test is mainly a regression guard against a future refactor reintroducing manual offset math).
- A fixed-timezone test seeds a call at a UTC hour that crosses a local calendar-day boundary (the case named in Error handling) and asserts the activity heatmap cell it lands in matches the *local* day/hour, not the UTC one — the concrete regression check for the bug this spec fixes, and for `requirements.md`'s success criterion 5.

Gate: `npm run build && npx playwright test` green, per `token-metering/.harness/workflow.md`.
