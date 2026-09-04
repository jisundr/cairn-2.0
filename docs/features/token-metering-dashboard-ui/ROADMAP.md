# Roadmap: token-metering dashboard — production port

Delivery plan for `requirements.md`'s port, sequenced into five waves. Design detail lives in each `plans/*.md`; this doc only sequences them and calls out the dependencies between them.

## Why this order

Every component in `token-metering/frontend/src/components/` composes the shared `ui/` primitives (`button.tsx`, `badge.tsx`, `panel.tsx`, `tabs.tsx`) and reads `index.css`'s custom properties directly or through Tailwind's arbitrary-value syntax (e.g. `border-(--blue)`, per the e2e assertion this port has to update). Porting any one component before the tokens and primitives exist underneath it means either building on the old palette and re-touching the file a second time, or hand-rolling one-off overrides that the rest of the system doesn't share — so the token/primitive layer goes first, alone, before any component-level wave starts.

Once that foundation lands, the remaining surface splits cleanly along file boundaries into three groups that don't overlap: chrome-and-readouts (`Header.tsx`, `Dashboard.tsx`'s meter boxes, `WarningBanner.tsx`, `EmptyState.tsx`), charts (`TokensPerDayPanel.tsx`, `ActivityHeatmap.tsx`), and sessions (`SessionsTable.tsx`, `SessionDrilldown.tsx`, `HbarList.tsx`, `ProjectsPanel.tsx`, `CallPage.tsx`, `TraceDrawer.tsx`, `TraceDetailContent.tsx`). Charts and sessions have no dependency on each other or on chrome-and-readouts beyond the shared foundation — sequenced here as Waves 3 and 4 for a single-track read, but either order works, and a developer running two worktrees could do them in parallel.

Verification and the `tools/tokens/static/` re-vendor sync go last, once the whole surface is stable — running the full `npx playwright test` suite and the vendor sync mid-port, before every component has moved, would just mean re-running both after every subsequent wave for no benefit.

## Status

Not started. `requirements.md` and this file exist; `plans/*.md` not yet written.

## Waves

Each wave is one or more independently gated commits, per this repo's own one-artifact-per-commit discipline (`CLAUDE.md`) — a wave groups commits that ship together for a coherent reason, it isn't itself one commit.

### Wave 1 — Tokens & primitives

- Replace `index.css:1-16`'s custom properties (`--paper`, `--paper-line`, `--ink`, `--ink-soft`, `--graphite`, `--block`, `--block-line`, `--window`, `--blue`, `--blue-soft`, `--flag`, `--flag-soft`) with `DESIGN.md`'s scale (bone/bone-dim/window/block, ink/ink-soft/ink-faint, signal/signal-soft/signal-line, `--ch1`–`--ch4`, the two paper-line hairline opacities).
- Resolve the font-hosting open question (`requirements.md`) and wire Big Shoulders/Public Sans/Martian Mono in as the body/label/readout faces, replacing Archivo and Space Mono.
- Restyle the four shared `ui/` primitives (`button.tsx`, `badge.tsx`, `panel.tsx`, `tabs.tsx`) to the new corner-radius range, hairline borders, and Bezel-Not-Shadow elevation rule, with no prop or behavior changes.

Foundation wave — no visible component redesign yet beyond what the primitives + token swap already ripple into, but every later wave depends on this landing first.

- Depends on: nothing.
- Plan: [plans/01-tokens-and-primitives.md](plans/01-tokens-and-primitives.md)
- Tests: `ui/` primitives have no dedicated test file today — a visual check (Storybook-less, so a manual `npm run dev` pass against each primitive's known call sites) stands in; full regression comes from Waves 2-4's component-level Playwright coverage still passing against the new tokens.
- Gate: `npm run build` clean; `npx playwright test` green (this wave should change zero test *behavior*, only visuals not asserted on by name).

### Wave 2 — Chrome & readouts

- `Header.tsx`: instrument-window chrome, brand mark, install-scope toggle.
- `Dashboard.tsx`: top-of-page meter-box totals (tokens/cost readouts).
- `WarningBanner.tsx`: dashed signal-line border, signal-soft fill, mono `<code>` treatment.
- `EmptyState.tsx`: dashed-border card, circular mono-glyph mark, numbered steps.

The dashboard's outer frame and its two state-dependent banners (warning, empty) — the surfaces a developer sees before any data-heavy panel renders.

- Depends on: Wave 1.
- Plan: [plans/02-chrome-and-readouts.md](plans/02-chrome-and-readouts.md)
- Tests: existing Playwright coverage for empty/cold-start and warning-banner states (per `frontend/e2e/{cold-start,populated}/`) re-run against the new markup; extend only if a `DESIGN.md` device (e.g. the dashed-border empty-state mark) isn't yet exercised by an assertion.
- Gate: `npm run build && npx playwright test`.

### Wave 3 — Charts

- `TokensPerDayPanel.tsx`: graticule background + calibrated trace/tick device, per the chart-technique open question's resolution in `plans/03-charts.md`.
- `ActivityHeatmap.tsx`: recolor per the heatmap-color open question's resolution in the same plan.

The riskiest wave — the only one with an unresolved architecture question (recharts customization vs. bespoke SVG) going in, per `requirements.md`'s Open questions.

- Depends on: Wave 1. Not on Wave 2.
- Plan: [plans/03-charts.md](plans/03-charts.md)
- Tests: `TokensPerDayPanel.tsx` and `ActivityHeatmap.tsx`'s existing Playwright coverage (chart renders, tooltip/hover behavior, live-data update on the 15s poll) re-run against the new rendering; extend with a case asserting the graticule/trace device is actually present (not just that the chart renders) if no such assertion exists today.
- Gate: `npm run build && npx playwright test`.

### Wave 4 — Sessions & drilldown

- `SessionsTable.tsx`: session-item rows, dashed-bottom-border list, flag-dot marker.
- `SessionDrilldown.tsx`: agent-select rows with channel-color swatches, mini-bars, chat-thread turns.
- `HbarList.tsx`: flat bordered tracks, ink-scale/channel-color fills.
- `ProjectsPanel.tsx`, `CallPage.tsx`, `TraceDrawer.tsx`, `TraceDetailContent.tsx`: remaining panels and the per-call drill-through, brought to the same vocabulary.

The largest wave by file count — everything downstream of selecting a session.

- Depends on: Wave 1. Not on Wave 2 or 3; `SessionDrilldown.tsx`'s existing sort/ordering logic (`token-metering-followups` issue 4's `global_position` contract) is untouched by this port and stays as-is.
- Plan: [plans/04-sessions-and-drilldown.md](plans/04-sessions-and-drilldown.md)
- Tests: `frontend/e2e/populated/dashboard.spec.ts`'s existing session-selection and drilldown coverage re-run against the new markup; the `border-(--blue)` assertions at lines 41 and 45 are updated to whatever selector/token the ported range-tab component actually uses (per `requirements.md` Goal 6) in this wave, not deferred to Wave 5.
- Gate: `npm run build && npx playwright test`.

### Wave 5 — Verification & vendor sync

- Full `npx playwright test` pass across both fixture states (populated, cold-start), confirming nothing in Waves 2-4 regressed another wave's surface.
- Manual `cairn:run` smoke test against a real session, covering `requirements.md`'s Success criteria 5 (cold-start, populated, a usage-limit warning, an agent-select interaction) — the mockup review's own evidence set, now exercised live instead of statically.
- Re-vendor `tools/tokens/static/` in this repo from `token-metering/frontend/`'s rebuilt `static/`, per the existing convention (most recently commit `54b2c31`) — a separate commit in this repo, not bundled into the submodule-side work.

Closing wave — nothing here changes component code; it confirms the port is complete and syncs the vendored copy.

- Depends on: Waves 2, 3, and 4 all merged.
- Plan: [plans/05-verification-and-vendor-sync.md](plans/05-verification-and-vendor-sync.md)
- Tests: the full existing suite, no new cases expected unless the manual smoke test surfaces something Waves 2-4's automated coverage missed.
- Gate: `pytest test_*.py` (confirming the untouched backend is still green); `npm run build && npx playwright test`; this repo's `python tools/budget.py` clean on the re-vendored `tools/tokens/static/` commit.

## Cross-wave notes

| Concern | Resolution | Wave impact |
|---|---|---|
| Font-hosting decision | Resolved once, in Wave 1's plan, before any component work starts — every later wave assumes the answer, doesn't re-litigate it. | Blocks Wave 1 from closing until decided. |
| Chart-technique decision | Resolved in Wave 3's plan, not before — Waves 1, 2, and 4 don't depend on the answer. | Scoped entirely to Wave 3. |
| `e2e` assertions tied to old tokens | `border-(--blue)` (lines 41, 45) lives in the session range-tab coverage — updated in Wave 4, where that component is actually ported, not patched separately. | If Wave 4 is deferred past Wave 3 or 2, those two assertions stay red until it lands — acceptable since `requirements.md`'s Goal 6 only requires the suite green "through every wave that touches the frontend," and Wave 4 is the one that touches it. |
| `static/` drift during rollout | Left un-synced (both `token-metering/static/` and this repo's `tools/tokens/static/` mirror) until Wave 5 — no automated drift guard exists on the frontend side (unlike the backend's `check_vendoring_sync.py`), so an interrupted port between waves should not be mistaken for a synced one. | Wave 5 is the only point re-vendoring happens; don't sync early. |

## Testing (cross-wave)

- `npm run build && npx playwright test` inside `token-metering/frontend/` after every wave (Waves 1-5).
- `pytest test_*.py` inside `token-metering/` after any wave, as a regression check that the untouched backend stays green (cheap enough to run every wave despite no backend file changing).
- `python tools/budget.py` in this repo only for Wave 5's re-vendor commit — no other wave touches a file this repo's own gate covers.
