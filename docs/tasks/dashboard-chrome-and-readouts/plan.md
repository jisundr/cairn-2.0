# Plan — Track A / Wave 2: chrome & readouts

Design: `../../features/token-metering-dashboard-ui/DESIGN.md` — Meter Boxes, Empty State, Warning
Banner sections; Header chrome follows the same corner/border/elevation vocabulary Wave 1 already
applied to the `ui/` primitives (`button.tsx`, `badge.tsx`, `panel.tsx`, `tabs.tsx`, all live in this
worktree). Concrete reference: the frozen `mockups/dashboard.html` (never edited). Source plan:
`docs/features/token-metering-dashboard-ui/plans/02-chrome-and-readouts.md`. Depends on Wave 1
(merged, PR #6, commit `4eeb88d`).

Continues on Track A's existing worktree/branch: `token-metering/.claude/worktrees/track-a`,
branch `wave-2-chrome-and-readouts`, already synced past Wave 1's merge.

## Scope

- `token-metering/frontend/src/components/Header.tsx`
- `token-metering/frontend/src/Dashboard.tsx` — **path correction**: the source plan and
  `ROADMAP.md` say `src/components/Dashboard.tsx`; the file is actually at `src/Dashboard.tsx`
  (top level, not under `components/`). Only its top-of-page meter-row is in scope — the panels/
  table it composes stay untouched (Waves 3-4).
- `token-metering/frontend/src/components/WarningBanner.tsx`
- `token-metering/frontend/src/components/EmptyState.tsx`

Out of scope (scope record): `Dashboard.tsx`'s composed panels (charts, sessions), any prop or
behavior change beyond the meter-row addition below, `mockups/dashboard.html` itself, backend
(`tools/tokens/`, `token-metering`'s backend copy).

## Actionables

1. **`Header.tsx`** — instrument-window chrome + brand mark, per `DESIGN.md`'s `.chrome`/`.brand`/
   `.status-cluster` markup (`mockups/dashboard.html:90-230`):
   - Add a tone-stepped chrome bar above the existing brand/status row: `--bone-dim` background,
     `--paper-line` bottom border, three small `--ink-faint` traffic dots, and a mono URL-style
     readout field (`border-(--paper-line)`, `bg-(--window)`, `font-mono` text) — a static/
     decorative device per `DESIGN.md`'s Layout section, not a live control; source its text from
     `window.location.host` (no new prop) rather than a hardcoded placeholder.
   - Recolor the existing `h-7 w-7 border-2 border-(--ink)` brand-mark square and its "Token
     Metering" / "cairn · local dashboard" text to the mockup's `.mark`/`.brand-text` treatment
     (label face for the caption, body face at 700 weight for "Token Metering").
   - The `↻ auto-refresh 15s` pill and `refresh now` `Button` move to the `.pill`/`.status-cluster`
     treatment: `border-(--paper-line)`, `bg-(--window)`, drop `rounded-full` for `rounded-[3px]`
     (matches Wave 1's Shapes Don't-rule already applied to `button.tsx`). Add the pulsing `--signal`
     status lamp `DESIGN.md` names as part of `.status-cluster` — small circular dot, `box-shadow`
     ring in `--signal-soft`, CSS `@keyframes` pulse; presentational only, no new state.
   - **Install-scope toggle**: the mockup's `.state-toggle.scope-toggle` sits *outside* `.window`,
     alongside its `Populated/Empty` state toggle — both are review-harness controls for previewing
     two static caption variants (`mockups/dashboard.html:1033-1038`), not a feature of the shipped
     app. Confirmed: no such toggle, and no `multiProject`-driven caption, exists in current
     `Header.tsx`/`HeaderProps`. Restyle the one caption string that exists today as-is; do not add a
     `multiProject` prop or wire a live scope switch — that would be a behavior change this wave's
     `done_when` doesn't ask for.
   - `updated-label` text and refresh behavior: unchanged.

2. **`Dashboard.tsx`** — top-of-page meter-row only:
   - The mockup's `meter-row` (`mockups/dashboard.html:1079-1092`: Tokens today / Cost today /
     Tokens 7D meter boxes) has no counterpart anywhere in the current file — there is nothing to
     "restyle," it needs to be added net-new. Render it directly below `WarningBanner`, above the
     existing panels grid, inside the same `isColdStart` branch (meter-row is part of the populated
     view only, matching the mockup's `view-populated` wrapper).
   - Data: two additional `useTimeseries` calls — `{ range: "today", project: projectParam }` and
     `{ range: "7d", project: projectParam }` — the same hook `TokensPerDayPanel.tsx` already calls
     with different range params (`api/hooks.ts`'s existing `useTimeseries`). No new endpoint, no new
     hook. Reuse `formatTokens`/`formatCost` from `lib/format.ts` (already used elsewhere) for the
     three displayed values (today's `total_tokens`, today's `total_cost`, 7d's `total_tokens`).
   - Markup/style: three boxes per `DESIGN.md`'s Meter Box spec — bordered `--window` box, 2px
     `--paper-line-soft` top hairline, `rounded.md` (4px), `12px 16px` padding — each with a
     label-face caption (Big Shoulders, 11px, uppercase, `--ink-soft`) above a readout-face value
     (`font-mono`, 27px, 600 weight, `tabular-nums`, `--ink`); the Three-Face Rule split the source
     plan's step 3 names.
   - No other part of `Dashboard.tsx` changes: rollup panels, `SessionsTable`, `SessionDrilldown`,
     routing/state stay exactly as they are.

3. **`WarningBanner.tsx`** — currently references now-removed Wave-1 tokens (`--flag`, `--flag-soft`),
   left broken (undefined CSS custom properties) since Wave 1 landed:
   - Border: `border-dashed border-[1.5px] border-(--signal-line)` (was `--flag`).
   - Fill: `bg-(--signal-soft)` (was `--flag-soft`).
   - Flag-icon circle and "view session →" link: same `--flag` → `--signal-line` swap.
   - `<code>` span: move to `font-mono` (readout face) per the source plan's "mono `<code>`
     treatment," keeping its existing `bg-(--block)` chip background.
   - `Badge` (already restyled circular/mono in Wave 1) and the `events.length`/`onViewSession`
     logic/props: unchanged.

4. **`EmptyState.tsx`** — currently references now-removed tokens (`--block-line`, `--paper`,
   `--graphite`; `--paper-line` was already the current name, no change needed there):
   - Card: `border-dashed border-[1.5px] border-(--paper-line) bg-(--window)` (was
     `--block-line`/`--paper`).
   - Circular glyph mark: `border-dashed border-(--paper-line)` (was `--graphite`); the single
     Martian Mono glyph (`∅`) moves to `font-mono` (was implicitly label face via the parent's class)
     per `DESIGN.md`'s Empty State spec.
   - Numbered steps (`EmptyStep`): circular step-index badge `border-(--paper-line)` (was
     `--block-line`); the index number moves to readout face (`font-mono`), not label face — the
     step body text itself stays body face, unchanged.
   - `<code>` span (`.cairn/tokens.db`): `font-mono`, keep `bg-(--block)` chip.
   - No prop/structure change: `EmptyState` still takes no props; `EmptyStep` keeps its `n`/`text`
     props.

5. **Gate**: `npm run build && npx playwright test` inside `token-metering/frontend/`;
   `pytest test_*.py` inside `token-metering/` as the cheap backend regression check (per
   `ROADMAP.md`'s cross-wave testing note — backend untouched, should stay green trivially).

6. **Confirm/extend Playwright coverage**:
   - `frontend/e2e/cold-start/empty-state.spec.ts` and `frontend/e2e/populated/dashboard.spec.ts`'s
     existing warning-banner test (`shows the usage-limit warning banner...`) should re-run against
     the new markup unmodified — neither asserts on class names/tokens, only `data-testid` and text
     content.
   - No existing assertion exercises the meter-row (it didn't exist before this wave). Add one case
     to `frontend/e2e/populated/dashboard.spec.ts` asserting the three meter boxes render with the
     seeded fixture's values, using new `data-testid`s (e.g. `meter-tokens-today`,
     `meter-cost-today`, `meter-tokens-7d`) — per the source plan's "extend only if a `DESIGN.md`
     device isn't yet exercised by an assertion."

7. **Manual check** (`cairn:run`): load the populated fixture and, separately, a real project
   mid-usage-limit warning — confirm `WarningBanner.tsx` renders correctly against real event data
   (Playwright's seeded fixture shape may not fully cover a live trigger, per the source plan's step
   6). Visually compare the chrome bar, brand mark, and meter-row against `DESIGN.md`/the mockup;
   confirm no FOUT/FOIT flash on a hard reload (Wave 1's font-loading note).

8. **Review** — `cairn:reviewer` agent (never `review-pr`) against the diff from Actionables 1-4,
   scoped to this wave.

9. **PR** — opened by the main thread inside the `token-metering` submodule, scoped to Actionables
   1-4's diff only.

## Done when

`npm run build` is clean inside `token-metering/frontend/`; `npx playwright test` is green
(existing cold-start/populated e2e coverage passes against the new markup, extended per Actionable
6); no file among the four target files references `--flag`, `--flag-soft`, `--block-line`,
`--paper`, `--graphite`, or any other pre-Wave-1 token.

## Risks

- Meter-row is net-new markup plus two net-new `useTimeseries` polling calls, not a pure restyle —
  the source plan's "no data-binding change" phrasing is read here as "no new endpoint, no change to
  any *existing* binding," not literally zero new query calls (there was nothing to bind to before).
  Re-check this reading against the source plan's author intent if `reviewer` flags it.
- The mockup's `.window`/`.chrome` outer instrument-window border wraps the *entire* app (chrome bar
  through the sessions table), but only `Header.tsx` and `Dashboard.tsx` are in this wave's scope.
  Split adopted: the chrome bar renders inside `Header.tsx`; the hairline `--window` border/radius
  applies to `Dashboard.tsx`'s existing outer `mx-auto max-w-[1180px]` wrapper div (both already
  in scope, both already siblings in the same render tree) so the visual enclosure still reads
  correctly. Re-check this split against the rendered result once built.
- "Install-scope toggle" is read as mockup review-harness only (no live equivalent in
  `Header.tsx`/`HeaderProps` today, confirmed by reading the current component). Re-open if a later
  wave's data model needs a real project-scope indicator in the header.
