# Plan — Track B / Wave 4: sessions & drilldown restyle

Design: `docs/DESIGN.md`'s Session List/Drilldown and
Meter/Progress Bars component sections (also One Signal Rule, Ink-Scale Data Rule, Three-Face
Rule, Bezel-Not-Shadow Rule, Shapes' dashed-border/no-pill-radius rules — all under Colors/
Typography/Elevation/Shapes). Concrete reference: the frozen
`docs/features/token-metering-dashboard-ui/mockups/dashboard.html` (never edited) — `.hbar-*`
CSS at 542-608, `.pill-row`/`.flag-dot` at 610-639, `.session-item`/`.drilldown-head` at
658-699, `.agent-select`/`.mini-bar`/`.agent-name` at 701-766, `.chat-thread`/`.chat-turn`/
`.chat-bubble` at 768-834, `.pill`/`.badge` at 218-239, rendered drilldown markup at 1436-1467
(agent rows) and 1469-1504 (chat-thread turns). Source plan (architecture questions already
resolved, carried forward): `docs/features/token-metering-dashboard-ui/plans/04-sessions-and-
drilldown.md`. Goal 6 / requirements.md lines 15-21 give the two stale-token spec assertions.

Worktree/branch per the scope record: `token-metering/.claude/worktrees/track-b`, fresh branch
`wave-4-sessions-and-drilldown` off updated `origin/main`.

## Scope (paths)

- `token-metering/frontend/src/components/SessionsTable.tsx`
- `token-metering/frontend/src/components/SessionDrilldown.tsx`
- `token-metering/frontend/src/components/HbarList.tsx`
- `token-metering/frontend/src/components/ProjectsPanel.tsx`
- `token-metering/frontend/src/components/CallPage.tsx`
- `token-metering/frontend/src/components/TraceDrawer.tsx`
- `token-metering/frontend/src/components/TraceDetailContent.tsx`
- `token-metering/frontend/e2e/populated/dashboard.spec.ts` (lines 41-46 only)

Out of scope (scope record): `SessionDrilldown.tsx`'s sort/ordering logic (`global_position`
contract); `mockups/dashboard.html`; backend (`tools/tokens/`); any data-binding, routing
(`routing.ts`), or data-fetching (`api/hooks.ts`) change; `index.css` (not in paths — stale/
missing tokens are resolved to tokens that already exist there, per Risks below).

## Stale-token resolution (applies everywhere below)

None of `--blue`, `--blue-soft`, `--flag`, `--block-line`, `--paper`, `--graphite` exist in
`index.css` (confirmed by reading it) — same situation Wave 3 hit with `--block-line`.
Per-site mapping used throughout (index.css out of scope, not edited):
- `--blue` (active/link accent) → `--signal` **only** where the element is a genuinely
  triggered/selected/active state (dial-tab/pill active fill, selected agent-row, drilldown
  arrow). For plain at-rest navigation links (CallPage's "back", TraceDrawer's "view full
  page") → `--ink-soft` instead — the One Signal Rule states signal is "never used for
  default/at-rest chrome" (see Risks).
- `--blue-soft` → `--signal-soft` (selected-row wash).
- `--flag` → `--signal` (DESIGN.md: ".flag-dot (solid amber circle)").
- `--block-line` → `--paper-line` (hairline borders) or, where DESIGN.md names a per-agent
  channel fill (drilldown mini-bar, agent dot), → `--ch1`/`--ch2`/`--ch3`/`--ch4` cycled by
  agent index mod 4 (see Actionable 2).
- `--paper` → `--bone-dim` (DESIGN.md's Bone Dim entry names "hbar track" directly; mockup's
  `.hbar-track`/`.mini-bar` both use `--bone-dim`).
- `--graphite` → `--ink-soft` (label text) or `--ink-faint` (dashed disclosure-button border,
  matching the empty/placeholder-mark convention) — see per-file notes.

## Actionables

1. **`SessionsTable.tsx`**:
   - `FilterPill` (mockup `.pill-row .pill-item`, lines 612-631): rest state
     `rounded-full` → `rounded-[3px]` (Shapes: no pill radius outside true circles) with
     `border-(--paper-line) bg-(--window)`; active state → `border-(--signal) bg-(--signal)
     font-bold text-(--window)` (solid fill, matching `pill-active`/Dial-Tab convention —
     drop the old border+soft-wash pattern).
   - Session row selected wash: `bg-(--blue-soft)` → `bg-(--signal-soft)`. Add the
     DESIGN.md-named "small signal-colored square marker" prepended when
     `selectedSessionId === s.session_id`: a `h-1.5 w-1.5 rounded-[1px] bg-(--signal)` span
     before the flag-dot/session_id content in the Session `<Td>` (mockup's
     `.session-item.selected .session-item-top::before`, 667-674).
   - Flag dot: `bg-(--flag)` → `bg-(--signal)`.
   - `thead` sticky `bg-white` → `bg-(--window)`.
   - Table container `rounded-md` → `rounded-[4px]` (mockup `.sessions-scroll`, 4px exactly).
   - `Th`: `border-(--block-line)` → `border-(--paper-line)`.
   - `Td`: add an optional `mono?: boolean` prop, `font-mono` when set; pass `mono` for
     Started, Agents, Tokens, Est. cost columns (readout-face "session metadata" per
     DESIGN.md's Typography hierarchy) — leave Session (id + flag/marker) and Project as
     body-face (names/identifiers, not measured values).
   - Keep the existing `<table>`/`<tr>`/`<td>` structure — do not rebuild as the mockup's
     `<li class="session-item">` card list; the mockup's card layout and the live table's
     multi-column layout are a pre-existing, deliberate divergence outside this restyle.

2. **`SessionDrilldown.tsx`**:
   - Container: `rounded-lg border border-(--block-line) bg-white` → `rounded-[4px] border
     border-(--paper-line) bg-(--window)` (mockup `.drilldown`, exact match).
   - Head: `rounded-t-md border-(--block-line) bg-(--block)` → `rounded-t-[3px]
     border-(--paper-line) bg-(--bone-dim)` (mockup `.drilldown-head`).
   - "Session {id}" title: drop `font-label` (DESIGN.md's Body hierarchy names "drilldown
     session title" as a Body-face example directly) — plain body-face bold text.
   - Runtime/dominant-agent subtitle: `font-label` → `font-mono` (mockup `.session-meta` is
     mono; matches Readout hierarchy's "session metadata").
   - `AgentRow`: pass `index` from the `trace.agents.map((agent, index) => ...)` call. Add a
     circular per-agent dot (mockup's rendered `.agent-dot`, always solid — not the abstract
     `::before`-fills-when-checked description, which belongs to the mockup's unported
     checkbox-selection mechanism) — `h-2 w-2 rounded-full` before the agent name, colored
     via `[--ch1,--ch2,--ch3,--ch4][index % 4]` (inline `style`, matching HbarList's existing
     inline-style-for-computed-value pattern).
   - Open-state wash: `bg-(--blue-soft)` → `bg-(--signal-soft)`; arrow color
     `text-(--blue)` → `text-(--signal)`.
   - Mini-bar track: `bg-(--paper)` → `bg-(--bone-dim)`. Mini-bar fill: `bg-(--block-line)`
     → the same per-agent channel color as the dot (DESIGN.md's Meter/Progress Bars: "the
     per-agent channel color in drilldown mini-bars").
   - Subagent badge: `rounded` → `rounded-[3px]`; `border-(--block-line)` →
     `border-(--paper-line)`; `text-(--ink-soft)` → `text-(--ink-faint)` (mockup `.tag`).
   - `TraceTh`: `border-(--block-line)` → `border-(--paper-line)`.
   - "⋯" call-detail toggle: `border-(--graphite)` → `border-(--ink-faint)` (dashed
     circular disclosure mark, matching the empty/placeholder-mark convention).
   - No change to the open/close accordion mechanism itself, `defaultOpen` logic, or
     `onOpenCall` wiring — restyle only.

3. **`HbarList.tsx`** (DESIGN.md's Meter/Progress Bars: "Flat bordered tracks (`--bone-dim`
   background, `--paper-line` border) filled with a solid ink-scale color (`--ink-soft`
   default...)."):
   - Track: `h-3 rounded-[3px] bg-(--paper)` → `h-2.5 rounded-[2px] bg-(--bone-dim)` (mockup
     `.hbar-track`: 10px height, 2px radius, exact match).
   - Fill: drop `border-r border-(--block-line)`; `bg-(--block)` → `bg-(--ink-soft)` (flat
     fill only, no gradient/divider, per the Meter/Progress Bars spec's own wording).
   - Count/value span (`row.display`): `font-label` → `font-mono` (mockup `.hbar-row .count`
     is mono; a readout value, Three-Face-Rule fix).
   - `HbarGroupLabel`: `text-(--graphite)` → `text-(--ink-soft)` (mockup `.hbar-group-label`).

4. **`ProjectsPanel.tsx`**: composes the already-ported `Panel`/`PanelTitle` and the restyled
   `HbarList` with no local stale-token usage of its own (`text-(--ink-soft)` is already
   current) — verify it renders correctly post-restyle; no independent token edits expected.

5. **`CallPage.tsx`**:
   - Back link: `border-(--blue) text-(--blue)` → `border-(--ink-soft) text-(--ink-soft)`
     (at-rest nav chrome, not a triggered state — see Risks).
   - Header divider: `border-(--block-line)` → `border-(--paper-line)`.
   - `Pill`: `rounded-full` → `rounded-[3px]`; `border-(--block-line) bg-(--block)` →
     `border-(--paper-line) bg-(--window)` (mockup's generic `.pill`, line 218). Split each
     pill's content into label-face prefix ("in"/"out", where present) and a `font-mono`
     span for the numeral, instead of one `font-label` string mixing both (Three-Face Rule).

6. **`TraceDrawer.tsx`**:
   - Header bar: `border-(--block-line) bg-(--block)` → `border-(--paper-line)
     bg-(--bone-dim)` (same recessed-header treatment as `SessionDrilldown`'s head).
   - "Call #{n}" title: drop `font-label` (Body-face, matching `SessionDrilldown`'s title
     fix).
   - "view full page" link: `border-(--blue) text-(--blue)` → `border-(--ink-soft)
     text-(--ink-soft)` (same at-rest-chrome reasoning as CallPage's back link).
   - `aside`: `bg-white` → `bg-(--window)`; drop `shadow-[-14px_0_34px_rgba(...)]` (Don't:
     "add drop shadows, blurred glows, or card-elevation effects") and add `border-l
     border-(--paper-line)` in its place, per the Bezel-Not-Shadow Rule.
   - No change to open/close, backdrop-click, or `onViewFullPage` wiring.

7. **`TraceDetailContent.tsx`** (DESIGN.md's Chat Thread sub-component, applied to this
   file's existing single-call prompt/response pair — not rebuilt as the mockup's always-
   visible multi-turn `.chat-thread` panel driven by `:has()`/checkbox CSS, which is the
   no-JS interaction mechanism requirements.md's non-goals explicitly excludes; see Risks):
   - `TraceDetailGroup`: role label gets `font-label` (currently missing — Three-Face-Rule
     miss) and `text-(--ink-faint)` (mockup `.chat-msg-role`); the text itself wrapped in a
     `.chat-bubble`-equivalent box — `rounded-[4px] border border-(--paper-line) bg-(--window)
     p-[10px_12px]` for the prompt group, same box with `bg-(--bone-dim) border-(--bone-dim)`
     for the response group (mockup's response bubble uses `--ch1-soft`, which does not exist
     in `index.css` — `--bone-dim` substituted; see Risks). Prompt bubble left-aligned
     (`mr-auto max-w-[80%]`), response bubble right-aligned (`ml-auto max-w-[80%]`, role
     label `text-right`), matching mockup's `.chat-msg-prompt`/`.chat-msg-response`.
   - Wrap both groups together in one `border-l border-(--paper-line) pl-3` rail (mockup's
     `.chat-turn` left-border-railed turn), keeping the existing bottom `trace-detail-note`
     paragraph inside that rail, unchanged.
   - Unavailable-transcript message: wrap in `border border-dashed border-(--paper-line)
     rounded-[4px] px-3 py-2.5` (mockup's `.trace-detail-unavailable` — currently unstyled
     plain text; dashed-border box matches the empty/placeholder convention).
   - Keep all existing `data-testid`s (`transcript-available`, `transcript-unavailable`,
     `trace-detail-prompt`, `trace-detail-response`) on the same text-bearing elements the
     spec already queries — restyle the wrapper markup around them, not the testids.

8. **`dashboard.spec.ts:41-46`**: update both `toHaveClass(/border-\(--blue\)/)` assertions
   (on `sessions-range-30d` and `sessions-range-life`) to `toHaveClass(/bg-\(--signal\)/)`,
   matching Actionable 1's `FilterPill` active state (`bg-(--signal)`, solid fill — the
   load-bearing visual difference from the at-rest pill, same as the old assertion checked
   `border-(--blue)` against the at-rest `border-(--paper-line)`).

9. **Gate**: `npm run build && npx playwright test` inside `frontend/` (per
   `.harness/workflow.md`'s Gates — `pytest test_*.py` also gates but this wave touches no
   Python).

10. **Confirm tests**: full existing `dashboard.spec.ts` suite (session-selection,
    drilldown-expand, trace-drawer/call-page open/close, agent-row-badge-wrap) re-runs
    green against the new markup — none of it targets removed classes/tokens except the two
    updated in Actionable 8.

11. **Manual check** (`cairn:run`): load a populated project, click a session row to change
    selection (confirm the new square marker + signal-soft wash), expand a non-dominant
    agent row (confirm the per-agent dot/mini-bar channel color), open the trace drawer for
    an available-transcript call (confirm the prompt/response bubble alignment/colors), and
    for an unavailable one (confirm the dashed box) — Playwright's two fixture states don't
    cover the full agent-select interaction visually.

12. **Review** — `cairn:reviewer` agent (never `review-pr`) against the diff, scoped to this
    wave.

13. **PR** — opened inside the `token-metering` submodule, diff scoped to this wave only.

## Done when

`npm run build` is clean inside `token-metering/frontend/`; `npx playwright test` is green,
including the two updated range-tab assertions at `dashboard.spec.ts:41,45` (now checking
`bg-(--signal)` rather than `border-(--blue)`); none of the 7 restyled files reference
`--blue`, `--blue-soft`, `--flag`, `--block-line`, `--paper`, or `--graphite`.

## Risks

- **Chat-thread scope**: DESIGN.md's Chat Thread sub-component describes the mockup's
  always-visible, multi-turn, checkbox-`:has()`-highlighted `.chat-thread` panel (every
  agent's every call shown inline, dimming non-selected agents) — a different information
  architecture from the live app's per-call drill-through (`TraceDrawer`/`CallPage`,
  opened from a trace row's "⋯" toggle). Reproducing the mockup's full-thread panel verbatim
  would add a new always-on UI surface and conflicts with "no interaction change" and
  requirements.md's explicit non-goal against porting the mockup's no-JS `:has()` mechanism.
  This plan applies only the bubble *visual* vocabulary (role label, bordered box, left/
  right alignment, left-rail) to `TraceDetailContent.tsx`'s existing one-call-at-a-time
  structure. If `reviewer` reads DESIGN.md's intent as requiring the full inline thread,
  re-check against `04-sessions-and-drilldown.md`'s and `03-charts.md`'s established pattern
  of scoping component descriptions to wherever the equivalent live-app structure exists
  (Wave 3 did the same for the graticule/trace device) before expanding this actionable.
- **`--ch1-soft` gap**: named directly in DESIGN.md's Chat Thread text for the response
  bubble but absent from `index.css` (out of this wave's paths) — `--bone-dim` substituted;
  if a future wave ports `index.css`'s remaining tokens, this bubble's fill should switch to
  the real `--ch1-soft` then.
