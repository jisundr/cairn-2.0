# Plan — warning icon, focus-ring, activity cadence, session-list dot, drilldown redesign

Five fixes from `requirements.md` (settled, no open questions). Items 1-4 are small isolated
edits; item 5 (5a-5d) restructures the session drilldown across `SessionDrilldown.tsx`,
`Dashboard.tsx`, and `package.json`.

Build in worktree/branch `dashboard-warning-selection-heatmap` per `workflow.md`'s Branching
SOP, not on `main` directly.

## Scope (paths, from requirements.md/STATE.md)

- `token-metering/frontend/src/components/WarningBanner.tsx`
- `token-metering/frontend/src/components/TokensPerDayPanel.tsx`
- `token-metering/frontend/src/components/SessionsTable.tsx`
- `token-metering/frontend/src/components/ActivityHeatmap.tsx`
- `token-metering/frontend/src/components/SessionDrilldown.tsx`
- `token-metering/frontend/src/Dashboard.tsx`
- `token-metering/frontend/src/index.css`
- `token-metering/frontend/package.json`
- `token-metering/frontend/e2e/populated/dashboard.spec.ts` (assertions touched by 3, 6-7)

Out of scope: `server.py`/`db.py`/`parser.py`; a routing library (5d extends the app's
pushState/popstate tab pattern instead); `tools/tokens/static/` (re-vendor is a separate step).

## Actionables

1. **`WarningBanner.tsx`**: remove the circular `<span className="... rounded-full border
   border-(--warn) ...">` wrapper (lines 22-24) around `AlertTriangle`; render `<AlertTriangle
   size={18} strokeWidth={2.5} className="flex-none text-(--warn)" />` directly. Count `Badge`
   and the "View session →" button are untouched.

2. **`index.css`**: after the existing `:focus-visible` block (lines 115-125), add:
   ```
   .recharts-wrapper:focus, .recharts-wrapper:focus-visible,
   .recharts-surface:focus, .recharts-surface:focus-visible { outline: none; }
   ```
   `TokensPerDayPanel.tsx` is the only recharts consumer (confirmed by grep), so this is
   effectively scoped without a component-local style. `DayBarShape`'s `onClick`/`data-testid`
   unchanged — only the outline is suppressed. If manual check (Actionable 10) shows the ring
   persists, fall back to `tabIndex={-1}` on the two `<BarChart>` instances (lines 165, 174).

3. **`ActivityHeatmap.tsx`**: reshape into a per-calendar-day, GitHub-style grid.
   - Bucket by local `YYYY-MM-DD` (not `dow-hour`), summing `calls`/`tokens` per day as today.
   - Build all 7 calendar dates in the unchanged 7-day window (6 days before today → today,
     local midnight) explicitly, so data-free days still render as level-0 cells.
   - Grid: 7 rows, Sun (top, index 0) → Sat (bottom) — replaces the Monday-first
     `DOW_LABELS`/`localDow` pairing — × one column per Sun-Sat week the range touches (1 or
     2). Column index: weeks since the range's first Sunday-aligned week start.
   - Keep `LEVEL_CLASSES`/`levelFor` unchanged, now keyed by per-day token total.
   - Tooltip: day total (`{calls} calls · {tokens} tokens`) headed by the date via the
     existing `formatDayLabel` (`lib/format.ts`), not `{label} {hour}:00`.
   - Test ids: `heatmap-cell-{dow}-{hour}` → `heatmap-cell-{date}`;
     `heatmap-tooltip-{dow}-{hour}` → `heatmap-tooltip-{date}`. No e2e test targets either
     pattern today (confirmed by grep) — not a test-breaking rename.
   - Drop the top hour-axis label row (`00/04/08…` ticks) — no place in a day-per-cell grid.
   - `Dashboard.tsx` line 182-184: "When calls happen, by hour of day — last 7 days." →
     "Calls per day — last 7 days."

4. **`SessionsTable.tsx`**: remove line 97 (`{selected && <span ... rounded-[1px]
   bg-(--accent)" />}`) entirely. The round `bg-(--warn)` usage-limit dot (line 98) and the
   row's `bg-(--accent-soft)` background (line 92) are unchanged — row highlight is now the
   sole active indicator.

5. **`package.json`**: add `@tanstack/react-virtual` to `dependencies` (no windowing library
   exists today, confirmed by reading `package.json`) — feeds Actionable 6.

6. **`SessionDrilldown.tsx`** (5a/5b/5c):
   - New `AgentShareBar`, rendered once between the header and the agent list, replacing each
     `AgentSelectRow`'s embedded mini-bar: one flex row of segments in `agentsWithColor`'s
     order, each width = `agent.tokens / totalTokens * 100`% (session-total share, not
     `maxTokens` — fixes today's share-of-top-agent behavior), `backgroundColor: channelColor`
     (existing `CHANNEL_COLORS` cycling). Each segment is a `group relative` hover target
     (`ActivityHeatmap.tsx`'s cell convention) showing name/tokens/percent; test ids
     `agent-share-segment-{name}` /
     `agent-share-tooltip-{name}`. Segments are hover-only, not click targets.
   - `AgentSelectRow` becomes a legend row, not a checkbox row: drop the `<label
     htmlFor>`/`<input type="checkbox" data-testid={agent-select-${name}}>` pairing and the
     per-row `agent-mini-bar-{name}` div (lines 249-291). Replace with `<button type="button"
     aria-pressed={checked} data-testid={agent-select-${name}} onClick={onToggle}>` wrapping a
     solid (always-filled) `channelColor` swatch keyed to the matching `AgentShareBar`
     segment, name + subagent badge, and the calls/tokens/cost trio — same grid-row minus the
     mini-bar and 18px checkbox-dot columns (e.g. `grid-cols-[14px_1fr_70px_80px_70px]`).
     Checked-state visual reuses the existing `bg-(--surface-muted)` treatment, keyed off
     `aria-pressed` instead of `:checked`. Outer `data-testid={agent-row-${name}}` unchanged.
     Add `data-testid={agent-row-meta-${name}}` around the calls/tokens/cost trio (feeds
     Actionable 8). 5b's "legend keyed to the bar's segments" option, not click-on-segment.
   - Virtualize `chat-thread`'s turn list: replace the plain `turns.map(...)` (lines 211-218)
     with `@tanstack/react-virtual`'s `useVirtualizer` (`count: turns.length`, dynamic
     per-item size via `measureElement` — turns vary from one bubble to several tool-action
     lines). `chat-thread` (lines 204-219) needs a bounded, scrollable height for windowing to
     matter — `overflow-y-auto` plus a height filling the viewport (natural once Actionable 7
     makes the drilldown a full-viewport page). Keep every `chat-turn-{sessionId}-
     {globalPosition}` test id on rendered turns (see Risks).

7. **`Dashboard.tsx`** (5d): session drilldown as a full-viewport page, addressed by URL.
   - Extend the existing `pathForTab`/`tabFromPath` pushState/popstate pattern (lines 31-37)
     rather than adding a library: add `/sessions/<sessionId>` (URL-encoded). Replace
     `tabFromPath` with `parseView(pathname)` returning `{kind: "tab", tab}` or `{kind:
     "session", sessionId}`; replace `pathForTab` with `pathForView` covering all three paths.
   - State: keep `activeTab`, add `viewSessionId: string | null`. Both initialize from
     `parseView(window.location.pathname)` on mount (line 44) and re-sync in `popstate`
     (lines 60-66).
   - `navigateToSession(sessionId)`: sets `selectedSessionId`/`viewSessionId` to `sessionId`,
     `activeTab` to `"sessions"`, pushes `/sessions/${encodeURIComponent(sessionId)}`.
     `navigateBackToSessions()`: clears `viewSessionId`, calls existing `navigateToTab
     ("sessions")`.
   - `SessionsTable`'s `onSelect` (line 239, currently `setSelectedSessionId`) becomes
     `navigateToSession` — a row click opens the full-page drilldown, same one-click behavior
     as today, now landing on a dedicated page (see Risks).
   - `handleViewSession` (lines 114-117) becomes a direct `navigateToSession(sessionId)` call
     — lands on the real `/sessions/<sessionId>` URL instead of today's tab-jump + scroll.
     Update the stale comment above it.
   - Render: `viewSessionId && selectedSession` → render the session page (a "← Back to
     sessions" control calling `navigateBackToSessions()` above `<SessionDrilldown
     session={selectedSession} project={projectParam} />`) instead of the two tab-panel blocks
     (lines 127-249). `Header` keeps rendering above it unchanged (see Risks). The
     `activeTab === "sessions"` panel (lines 233-249) drops its
     `{selectedSession && <SessionDrilldown .../>}` line (247) — Sessions tab becomes
     list-only; drilldown only ever renders on the dedicated session page.

8. **`e2e/populated/dashboard.spec.ts`**: update for the new structure.
   - "switches between the Dashboard and Sessions tab panels" (40-58): drop the
     `session-drilldown` assertion at line 53.
   - "shows the usage-limit warning banner…" (113-123): after clicking
     `usage-limit-view-session`, assert `session-drilldown` visible directly / URL is
     `/sessions/<id>`, not `tab-panel-sessions`.
   - Every test reached via `openSessionsTab(page)` that asserts on
     `session-drilldown`/`agent-row-*`/`chat-turn-*`/`agent-select-*` (66-85, 225-326) needs an
     added row-click step first (row click now navigates away from the list).
   - "checking an agent dims other agents' chat-thread turns" (274-302): replace
     `.toBeChecked()`/`.not.toBeChecked()` on `agent-select-main` with
     `.toHaveAttribute("aria-pressed", "true"/"false")`.
   - "wraps a long subagent name's badge…" (304-326): replace the removed
     `agent-mini-bar-cairn:planner` bounding-box target with Actionable 6's new
     `agent-row-meta-cairn:planner` test id.
   - Add a `heatmap-cell-<date>` assertion (Actionable 3) to "renders rollup panels with
     seeded data", replacing the bare `activity-heatmap` check with one confirming the
     per-day shape (e.g. 7 or 14 cells, not 168).

9. **Gate**: `pytest test_*.py` in `token-metering/`; `npm run build` inside `frontend/`
   (regenerates `token-metering/static/` — commit it, distinct from the untouched
   `tools/tokens/static/` vendor target); `npx playwright test` inside `frontend/`.

10. **Manual check** (`cairn:run`), a real multi-turn session: 7D day bar click leaves no
    focus rectangle and the day-detail panel still updates; warning icon has no ring; Activity
    panel reads as day cells; selecting a session lands on a distinct, full-page drilldown
    reachable by URL, with share-bar hover tooltips, legend-row click-to-dim, and smooth
    transcript scrolling for a long session; browser back returns to the list with selection
    intact.

11. **Review** — `cairn:reviewer` agent (established preference over `review-pr`), scoped to
    this diff.

12. **PR** — from the worktree's branch into `main`, scoped to this fix only; delete the
    branch/worktree after merge (Branching SOP above).

## Done when

All 5 requirements.md items (1-5, 5a-5d) verified per Actionable 10; `WarningBanner.tsx` has
no circular badge; no native focus rectangle on a 7D bar click; `ActivityHeatmap.tsx` is a
per-calendar-day, week-column grid, not 7×24; `SessionsTable.tsx` has no square accent-dot;
drilldown shows one 100%-stacked, session-total share bar with per-segment hover tooltips
driving the sole agent-select control (no checkbox rows); chat-thread is windowed via
`@tanstack/react-virtual`; drilldown is a full-viewport page at `/sessions/<id>`, including
from `WarningBanner`; `pytest`/`npm run build`/`npx playwright test` green;
`tools/tokens/static/` untouched.

## Risks

- **"Full-viewport" (5d) is this plan's own reading**: `Header`/tab bar stays above the
  session page, not replacing all chrome — conservative/reversible, not the only reading.
  Revisit if reviewer or Actionable 10 disagrees.
- **Row-click-navigates (5d)**: a row click both selects and navigates (today's one-click
  flow). A select-only + separate "view" control is an easy later change if too eager.
- **Deep-linking outside the sessions-range fetch (5d)**: `/sessions/<id>` older than
  `sessionsRange`'s window won't be in `sessionRows`; the existing auto-select effect
  (lines 85-89) falls back to the most recent session — pre-existing, not a new regression.
- **Virtualization vs. the small seeded fixture (5c)**: only 5 turns seeded for
  `e2e-session-main`, likely all within the virtualizer's window — confirm against the real
  suite, don't assume.
- **Focus-outline selector (Actionable 2)** targets both `.recharts-wrapper` and
  `.recharts-surface` without confirming which one recharts 3.x actually focuses;
  `tabIndex={-1}` is the named fallback.
