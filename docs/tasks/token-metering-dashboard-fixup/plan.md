# Plan — token-metering dashboard fixup (correction wave)

Design: `docs/features/token-metering-dashboard-ui/DESIGN.md`'s Layout section (bezel), Dial
Tabs component (app-level variant), and Session List/Drilldown component (Agent-select rows,
Chat thread) — DESIGN.md lines ~133-137, ~155-156, ~161-166. Concrete reference: the frozen
`docs/features/token-metering-dashboard-ui/mockups/dashboard.html` (never edited) — `.chrome`/
`.dots`/`.url` at 1040-1044 (the bezel being removed, real in the mockup but not to be ported),
`.app-tabs` CSS at 170-196 and markup at 1056-1059, `.agent-select-list`/`.chat-thread` CSS at
701-834 and rendered markup at 1442-1504.

Root cause (already diagnosed, not re-derived): Wave 2's plan
(`docs/features/token-metering-dashboard-ui/plans/02-chrome-and-readouts.md`) ported the bezel
literally though it isn't required by any `done_when` item and doesn't exist for a good reason.
Wave 4's plan (`plans/04-sessions-and-drilldown.md`, its own "Risks" section, still on disk)
explicitly narrowed the agent-select+chat-thread component down to `TraceDetailContent.tsx`'s
existing one-call view and flagged the app-level tabs were never built — both correctly scoped
the *CSS-only, no-JS* mechanism out, but over-applied that exclusion to the *feature* too. This
plan restores the two dropped features as React-state equivalents and removes the bezel.

Worktree/branch: `token-metering/.claude/worktrees/dashboard-fixup`, fresh branch
`dashboard-fixup` off updated `origin/main` (no prior track-a/track-b worktree survives — both
were torn down 2026-09-05 per `GOAL-CONDITION.md`'s Current status).

## Scope (paths)

- `token-metering/frontend/src/components/Header.tsx`
- `token-metering/frontend/src/Dashboard.tsx`
- `token-metering/frontend/src/components/SessionDrilldown.tsx`
- `token-metering/frontend/src/api/hooks.ts` (new hook only; `client.ts`/`types.ts` already
  expose what's needed — see Actionable 4)
- `token-metering/frontend/src/index.css` (one additive token — see Actionable 5)
- `token-metering/frontend/e2e/populated/dashboard.spec.ts`
- `docs/features/token-metering-dashboard-ui/DESIGN.md`
- `docs/features/token-metering-dashboard-ui/GOAL-CONDITION.md`
- `tools/tokens/static/` (re-vendor only, no hand-edit)

Out of scope (scope record, confirmed against current code): `mockups/dashboard.html` (its
`.chrome` bezel and `.app-tabs`/`.agent-select`/`.chat-thread` CSS `:target`/`:has()`/`:checked`
mechanism stay frozen); `App.tsx`/`routing.ts` (the `/call/<session>/<n>` deep-link route and
`TraceDrawer`/`CallPage` stay reachable, unchanged); `SessionDrilldown.tsx`'s sort/ordering
(`global_position` contract); `server.py`/`db.py`/`pricing.py`/`parser.py` — confirmed
unnecessary (Actionable 4).

## Actionables

1. **`Header.tsx` — remove the bezel**: delete the fake browser-chrome block (the traffic-dot
   spans + `window.location.host` mono readout, currently justified by a code comment citing
   DESIGN.md's Layout section) entirely. Keep the header row below it (brand mark, status
   cluster) as-is except for Actionable 2's new tab control.

2. **`Header.tsx` — app-level Dial Tabs**: add the Dashboard/Sessions tab control to the header
   row, positioned between the brand block and the status cluster (mockup's `.app-head` order:
   `.brand`, `.app-tabs`, `.status-cluster`). New props `activeTab: "dashboard" | "sessions"`,
   `onTabChange: (tab: "dashboard" | "sessions") => void`. Styling per DESIGN.md's Dial Tabs
   app-level variant: bordered `--window` segmented group, unselected segments `--ink-soft`
   label text, selected segment `--signal-soft` fill + `inset 0 -3px 0 var(--signal)` bottom
   box-shadow — distinct from `components/ui/tabs.tsx`'s solid-`--signal`-fill treatment (that
   primitive stays reserved for the existing chart-range Today/Daily/Monthly tabs; do not
   reuse it here or restyle it).

3. **`Dashboard.tsx` — own the tab state and split content**: add
   `useState<"dashboard" | "sessions">("dashboard")`, pass `activeTab`/`onTabChange` to
   `Header`. Split the current single sequential render into two conditional blocks matching
   the mockup's `tab-panel-dashboard`/`tab-panel-sessions` split:
   - Dashboard tab: `WarningBanner`, the meter row, `TokensPerDayPanel`, and the rollup-panels
     grid (Agents & skills, Activity, Tokens/model, Tool calls, MCP calls, `ProjectsPanel`).
   - Sessions tab: `SessionsTable` + `SessionDrilldown`.
   Cold-start (`isColdStart`) behavior is unchanged: `EmptyState` still renders in place of
   either tab's content, regardless of `activeTab` — the mockup's `.app-head` (and so its tab
   bar) sits outside the populated/empty view toggle, matching Header always rendering today.

4. **`SessionDrilldown.tsx` — checkbox agent-select rows**: replace `AgentRow`'s
   click-to-expand accordion with a row driven by a boolean "checked" state per agent (e.g.
   `useState<Set<string>>` of checked agent names). Each row keeps its existing swatch/dot
   (reuse the existing `CHANNEL_COLORS` index-cycling), but the swatch fills solid with the
   channel color only when checked (outlined/unfilled otherwise, per DESIGN.md's "fills solid
   when checked"); keep the existing mini horizontal bar (relative token share vs `maxTokens`)
   and the calls/tokens/cost stats columns.

5. **`SessionDrilldown.tsx` — always-visible chat-thread**: replace the per-agent `<table>` of
   trace rows (and the "⋯" `TraceDrawer`-opening button) with one merged, `global_position`-
   ordered list of every agent's calls, rendered as chat turns: a meta line (agent, position,
   time, model, in/out tokens, cost, duration) plus a prompt bubble (left-aligned, `--window`)
   and a response bubble (right-aligned, `--ch1-soft` — Actionable 6), each turn left-border-
   railed per DESIGN.md. Keep a small per-turn "view full detail" affordance calling
   `onOpenCall(sessionId, call.global_position)` so `TraceDrawer`/`CallPage`/`routing.ts` stay
   reachable and untouched (out of scope). Dimming: when the checked set (Actionable 4) is
   non-empty, turns whose agent isn't checked drop to reduced opacity (not removed); when
   nothing is checked, all turns render at full opacity — mirrors the mockup's default-all-
   visible / `:has()`-checked-dims-others behavior, in React state instead of CSS.

6. **`index.css` — add the missing `--ch1-soft` token**: `index.css` currently defines
   `--ch1`/`--ch2`/`--ch3`/`--ch4` but not `--ch1-soft`, which DESIGN.md's Chat Thread spec
   names for the response bubble fill and which the frozen mockup's own `:root` already
   defines as `#dfe1e8` (`mockups/dashboard.html` line ~26) — add `--ch1-soft: #dfe1e8;`
   alongside the existing `--ch1` declaration, plus the matching `--color-ch1-soft: var(--ch1-
   soft);` line in the `@theme` block next to `--color-ch1`. Additive only — no other rule in
   this file changes.

7. **`api/hooks.ts` — batched per-call detail for the chat-thread**: `CallDetail` (in
   `api/types.ts`) already carries `prompt`/`response` per call, fetched today one at a time
   via `useCallDetail`/`api.callDetail` against the existing `/api/call/<session_id>/<n>` route
   (confirmed in `server.py` — no backend change needed to expose this data). Add one new hook
   that fetches every visible call's detail for the session's chat-thread — e.g. wrapping
   `@tanstack/react-query`'s `useQueries` over the session trace's `global_position` list, one
   query per call, reusing `api.callDetail` as the query fn. `api/client.ts` and `api/types.ts`
   need no change.

8. **`DESIGN.md` — correct the Layout section**: remove the "framed by a fake browser-chrome
   strip ... a screen-within-a-bezel device" clause (~line 135), keeping "renders inside a
   single bordered 'instrument window'" as the remaining framing. Also drop "the browser-chrome
   bar" from the Bone Dim neutral-color usage list (~line 104, under Neutral/Bone Dim) since
   that surface no longer exists anywhere in the port.

9. **`GOAL-CONDITION.md` — correct "Explicitly out of scope"**: reword the CSS-only-mechanism
   bullet so it's unambiguous that only the literal `:target`/`:has()`/`:checked` no-JS trick
   is excluded — the React-state equivalents of the DESIGN.md-named components themselves
   (app-level Dashboard/Sessions tabs; agent-select rows; chat-thread) are in scope and this
   wave delivers them. Add a short "Current status" entry recording this fixup wave (goal,
   PR/commit, gate results) once merged, matching the existing per-wave narrative convention
   already used for Waves 1-5.

10. **`e2e/populated/dashboard.spec.ts` — update assertions**: the accordion/table testids
    this spec currently targets (`agent-row-toggle-*`, `agent-trace-*`, `trace-row-*`,
    `trace-toggle-*`) no longer exist after Actionables 4-5; rewrite against the new
    checkbox/chat-thread markup, preserving each assertion's original intent (agent stats
    visible by default, dominant agent called out, a call's detail still reachable,
    `global_position` ordering unaffected). Add coverage for the tab switch (Actionables 2-3)
    and checkbox dimming across at least two agents (Actionable 5). Re-check no assertion
    depended on the removed bezel markup (Actionable 1).

11. **Gate**: `npm run build && npx playwright test` inside `token-metering/frontend/`.
    `pytest test_*.py` inside `token-metering/` only if any backend file ends up touched
    (Actionable 7's analysis says it shouldn't be) — if it is, `tools/tokens/check_vendoring_
    sync.py` must also pass, since backend files are vendored byte-for-byte into `tools/tokens/`.

12. **Re-vendor**: rebuild `token-metering/frontend/` (`npm run build`) and re-vendor
    `tools/tokens/static/` from the fresh build, mirroring Wave 5's re-vendor step. Then run
    `python tools/budget.py` in the outer repo and confirm it's clean.

13. **Manual check** (`cairn:run`): against a real captured session, confirm no bezel renders
    above the app, the Dashboard/Sessions tab switch works and preserves each tab's content
    (including cold-start still showing `EmptyState` under either tab), and the drilldown's
    checkbox agent-select dims/undims chat-thread turns correctly with real (non-fixture)
    prompt/response text.

14. **Review** — `cairn:reviewer` agent (never the `review-pr` skill, per this project's own
    established preference) against the diff, scoped to this fixup wave.

15. **PR** — opened inside the `token-metering` submodule from the `dashboard-fixup` worktree/
    branch, diff scoped to this correction wave only.

## Done when

Pulled from the scope record: `Header.tsx` has no browser-chrome bezel and DESIGN.md's Layout
section no longer calls for one; `Dashboard.tsx` has real React-state Dashboard/Sessions tab
navigation matching DESIGN.md's Dial Tabs app-level variant; `SessionDrilldown.tsx` implements
checkbox-driven agent-select rows plus an always-visible chat-thread with in-place dimming,
matching DESIGN.md lines ~157-166; `GOAL-CONDITION.md`'s "Explicitly out of scope" section is
corrected per Actionable 9; `npm run build && npx playwright test` pass in
`token-metering/frontend/` (`pytest test_*.py` too if backend touched); `tools/tokens/static/`
is re-vendored and `python tools/budget.py` is clean in the outer repo.

## Risks

- **Per-call fetch volume for the chat-thread** (Actionable 7): showing every call inline
  requires one `/api/call/<session>/<n>` fetch per call (each walks the transcript file via
  `server.py`'s `lookup_transcript_content`). E2e fixtures only seed single-digit call counts,
  so this isn't exercised at scale by the gate; a real session with many calls would first
  show this as a slow drilldown load in Actionable 13's manual check, not the automated gate.
- **`--ch1-soft` addition touches `index.css`**, outside the scope record's listed `paths`.
  Narrowly scoped (one token + its `@theme` mapping, value from the mockup's frozen `:root`)
  and required by the done-when item for the chat-thread response bubble — see `STATE.md`.
