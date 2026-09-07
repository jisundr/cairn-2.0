# Requirements — dashboard warning/selection/heatmap fixes

## Problem

Follow-up feedback on the token-metering dashboard after the contrast/transcript
task landed. Five items from a live review of the running dashboard
(http://127.0.0.1:4317). Source: user feedback in session, no prior doc.

## Goals

1. **Warning icon** — `WarningBanner.tsx` wraps the `AlertTriangle` icon in a
   circular badge (`<span className="... rounded-full border border-(--warn) ...">`).
   User wants the circle gone — render the triangle icon directly, no ring.

2. **Selection blue rectangle** — confirmed via user's screenshot
   (`~/Desktop/Screenshot 2026-09-07 at 4.31.09 PM.png`): it's the "Tokens /
   day" panel (`TokensPerDayPanel.tsx`), 7D range. Clicking a day bar
   (`DayBarShape`'s `onClick` at
   `token-metering/frontend/src/components/TokensPerDayPanel.tsx:87`) selects
   the day and also gives the recharts SVG native keyboard focus; the browser
   then draws its default blue focus ring around the whole chart (spans full
   width/height of the plot area, as seen in the screenshot). No app code
   draws this rectangle on purpose — no focus-ring reset exists for
   `.recharts-wrapper`/`.recharts-surface` in `index.css` today. Fix: suppress
   the native focus outline on the recharts SVG/wrapper (e.g.
   `.recharts-surface:focus, .recharts-wrapper:focus-visible { outline: none; }`
   in `index.css`, or `tabIndex={-1}` on the chart) without breaking the
   click-to-select behavior itself.

3. **Activity panel cadence** — `ActivityHeatmap.tsx` currently renders a
   7 (day-of-week) × 24 (hour-of-day) grid. User wants "per day, just like
   GitHub" — i.e. GitHub's contribution-graph shape: one cell per calendar
   day, arranged in week columns over a date range, not a dow×hour grid.
   This is a shape change, not a tweak: new bucketing (by calendar date
   instead of `dow-hour`), new grid layout (weeks as columns, 7 rows), and
   probably a different tooltip (day total, not hour total).

4. **Session-list indicators** — `SessionsTable.tsx` renders two small dots
   inline with the session label (`token-metering/frontend/src/components/SessionsTable.tsx:96-97`):
   - a 1.5px **square** `bg-(--accent)` dot for the *selected* row
   - a 1.75px **round** `bg-(--warn)` dot for `usage_limit_hit`
   Resolved: drop the square accent dot entirely. The selected row is already
   marked by its `bg-(--accent-soft)` background
   (`token-metering/frontend/src/components/SessionsTable.tsx:88`), so the
   row highlight alone is the active indicator going forward. The round
   usage-limit dot is unchanged and stays.

5. **Session drilldown redesign** — resolved into four sub-parts, all in
   scope now:
   - **5a. Stacked share bar.** Replace the N per-agent mini-bars in
     `AgentSelectRow` (`agent-mini-bar-*`, each currently
     tokens-vs-max-agent) with one 100%-stacked bar showing every agent's
     share of the *session's total* tokens, one segment per agent in its
     existing `CHANNEL_COLORS` color. Segment-level hover tooltip (agent
     name, tokens, %) since thin segments won't read from color alone with
     4+ agents.
   - **5b. Legend doubles as agent-select.** The stacked bar's segments (or
     an adjacent legend keyed to them) become the interactive control that
     drives the existing dim/highlight-other-agents behavior in the chat
     thread (today's `checkedAgents` state, `SessionDrilldown.tsx`) — replaces
     the separate checkbox rows rather than sitting alongside them.
   - **5c. Virtualize the transcript.** `ChatTurn`-rendered turns in the
     `chat-thread` list get windowed rendering so a long transcript (user has
     one today) doesn't render every turn's DOM at once. No windowing lib is
     in `frontend/package.json` yet — add one (e.g. `@tanstack/react-virtual`)
     rather than hand-rolling it.
   - **5d. Move to a full-page view.** The session drilldown moves out of the
     inline panel below the sessions table into a full-viewport "page" state
     in `Dashboard.tsx` (list view ⇄ session view), addressable via the
     native History API (`pushState`/`popstate`) rather than an inline panel,
     a drawer, or a modal — no router dependency added. `WarningBanner`'s
     "View session →" button should land on this view via a real URL instead
     of scrolling to an inline panel.

## Non-goals

- No backend/`server.py`/`db.py`/`parser.py` changes.
- No routing library (e.g. react-router) — 5d uses the native History API.

## Success criteria

- Items 1-5 (including 5a-5d) are concrete enough to plan and build now; no
  open questions remain.
