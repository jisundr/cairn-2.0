# Goal condition: token-metering dashboard — production port

Entry point for this feature — start here, then `GOAL.md` for *how* a sprint runs, `requirements.md` for *what* and *why*, `ROADMAP.md` for the wave sequence, `DESIGN.md` for the system being ported.

## Current status

Track A's Wave 1 (tokens & primitives) is **merged** — PR #6 (https://github.com/jisundr/cairn-2.0-token-metering/pull/6, branch `wave-1-tokens-and-primitives`) merged 2026-09-04 via merge commit `4eeb88d`. Closed.

Track A's Wave 2 (chrome & readouts) is **merged** — PR #7 (https://github.com/jisundr/cairn-2.0-token-metering/pull/7, branch `wave-2-chrome-and-readouts`) merged 2026-09-04 via merge commit `b84ad1d`, source branch deleted. Went through 3 `cairn:reviewer` rounds (findings: missing `.window` frame, `formatCost` null-coercion, missing brand-mark crosshair, chrome-bar flush-edge bleed — all fixed and re-verified); third pass PASSed, gates green (pytest 62, build clean, playwright 26/26). Closed. Detail in `docs/tasks/dashboard-chrome-and-readouts/STATE.md`.

Track A's next sprint is Wave 5 (verification & vendor sync), which needs **both** Wave 2 (merged) **and** Wave 4 (Track B, merged) — now cleared to start. Track A's worktree (`token-metering/.claude/worktrees/track-a`) and Track B's worktree (`token-metering/.claude/worktrees/track-b`) are both stale now that their branches are merged/deleted; both still need removing from a session at the outer repo root (attempted 2026-09-05, blocked by the auto-mode safety classifier as an unconfirmed destructive action — needs explicit user confirmation).

Track B (Wave 3 — charts) is **merged** — PR #8 (https://github.com/jisundr/cairn-2.0-token-metering/pull/8, branch `wave-3-charts`) merged 2026-09-04 via merge commit `4df7bed2`, source branch deleted. Built in `token-metering/.claude/worktrees/track-b`. `cairn:reviewer` PASSed with gates green (build clean, playwright 25/25, pytest 62/62); the manual `cairn:run` check (Actionable 8 — live 15s poll cycle against a seeded populated project) confirmed no flicker/break in the graticule/trace device. The branch predated Wave 2's merge, so landing it required merging `origin/main` in first and regenerating the conflicted `static/` dir from the merged tree (commits `a2cf3af`/`f475242`), re-verified gates green (playwright 26/26, pytest 62/62) before merging. Detail in `docs/tasks/dashboard-charts/STATE.md`. Closed.

Track B's Wave 4 (sessions & drilldown) is **merged** — PR #9 (https://github.com/jisundr/cairn-2.0-token-metering/pull/9, branch `wave-4-sessions-and-drilldown`) merged 2026-09-05 via merge commit `e3cae6c`, source branch deleted. Built in `token-metering/.claude/worktrees/track-b`. `cairn:reviewer` PASSed on the first round, gates green (build clean, playwright 26/26, pytest 62/62); the manual check (Actionable 11 — default-session drilldown, selected-row marker/wash, non-dominant agent-row expand, trace drawer for both an available- and an unavailable-transcript call) confirmed no visual or console/page errors. Surfaced the pre-existing `toFixed` crash logged under Known issues while doing that check; worked around it in the manual check by using `e2e-session-main` instead of the affected `e2e-session-other`, since the crash's cause is out of this wave's scope. Detail in `docs/tasks/dashboard-sessions-and-drilldown/STATE.md`. Closed.

## Known issues

- Track B, hit during Wave 4's manual check (pre-existing, not a Wave 4 regression — `server.py`, `frontend/src/lib/format.ts`, and `frontend/src/api/*` are byte-identical to `origin/main`): selecting a session whose trace has an unpriced call crashes `SessionDrilldown` with `TypeError: e.toFixed is not a function`. `server.py`'s `pricing.call_cost(row)` can return the literal string `"unknown"` for a per-call `cost`, but `format.ts`'s `formatCost`/`formatDuration` only guard `=== null` (matching their `number | null` TS signature, which doesn't account for the `"unknown"` string the backend actually emits) before calling `.toFixed()`. Repro: seed the `populated` e2e fixture, select `e2e-session-other` (its one call has `"cost": "unknown"`). Both `pricing.py`/`server.py` (backend) and `format.ts`/`api/*` (data-fetching) are out of scope for this visual-restyle port per this doc's Invariants — needs its own fix (either `pricing.call_cost` never returning a non-numeric sentinel, or `format.ts` guarding non-numeric values) outside this port.

## Done when

Pulled directly from `requirements.md`'s Success criteria:

- [ ] No file under `token-metering/frontend/src/` references `--paper`, `--blue`, `--flag`, `--graphite`, `Archivo`, or `Space Mono`.
- [ ] Every component under `token-metering/frontend/src/components/` visually matches its `DESIGN.md`-named counterpart when compared against the reviewed mockup evidence (`.impeccable/review/{desktop,mobile,sessions-interaction,empty-state}.png`).
- [ ] `pytest test_*.py`, `npm run build`, and `npx playwright test` are all green inside `token-metering/`, with no assertion left referencing the old token system.
- [ ] `tools/tokens/static/` in this repo matches a fresh `npm run build` of the ported `token-metering/frontend/`, confirmed by re-running the existing re-vendor step.
- [ ] Exercised live via `cairn:run` against a real session: a cold-start/empty project, a populated project, a session mid-usage-limit warning, and an agent-select interaction in the drilldown all render correctly in the new system.

## Per-wave gate

Mirrors `ROADMAP.md`'s wave Gate lines — the authoritative copy is there; this list is for at-a-glance status only.

- [x] Wave 1 — tokens & primitives: `npm run build` clean; `npx playwright test` green. Merged (PR #6, commit `4eeb88d`).
- [x] Wave 2 — chrome & readouts: `npm run build && npx playwright test`. Merged (PR #7, commit `b84ad1d`).
- [x] Wave 3 — charts: `npm run build && npx playwright test`. Merged (PR #8, commit `4df7bed2`).
- [x] Wave 4 — sessions & drilldown: `npm run build && npx playwright test`. Merged (PR #9, commit `e3cae6c`).
- [ ] Wave 5 — verification & vendor sync: `pytest test_*.py`; `npm run build && npx playwright test`; this repo's `python tools/budget.py` clean on the re-vendored commit.

## Invariants

Hold across every wave, not just the one currently in flight:

- `mockups/dashboard.html` stays frozen — no fix discovered mid-port gets "fixed in the mockup" instead of ported forward into the real components.
- The backend (`tools/tokens/`, `token-metering`'s backend copy) is untouched — this is a visual/component port only.
- `static/` stays a generated, committed artifact — rebuilt via `npm run build`, never hand-edited, and only re-vendored into this repo's `tools/tokens/static/` at Wave 5.
- `DESIGN.md` is not amended by this port unless a wave's plan concludes a genuine gap needs a new named rule — the default is extending conservatively in its existing vocabulary, not inventing a new one.
- State management, routing (`routing.ts`), and data-fetching (`api/hooks.ts`, `api/client.ts`) are untouched — only presentation-layer files change.

## Explicitly out of scope

Pulled from `requirements.md`'s Non-goals:

- Changing `mockups/dashboard.html` itself.
- Any new feature, data field, or API surface.
- Replacing `recharts` with a fully bespoke charting engine (default assumption is customizing `recharts`; only reconsidered if Wave 3's plan concludes that's the only way to hit the graticule/trace device).
- Rewriting state management, routing, or data-fetching.
- General font-hosting infrastructure beyond serving Big Shoulders/Public Sans/Martian Mono to this one app.
- Reproducing the mockup's CSS-only (`:target`/`:has()`/`:checked`, no-JS) interaction mechanism — the live app's real React interactivity is preserved as-is.

## Backlog

- Vendored Big Shoulders/Martian Mono `.woff2` files (Wave 1) carry garbled internal name-table strings, a leftover of static instancing — cosmetic only (no `fvar` remains, `OS/2.usWeightClass` and glyph ink-area both correctly track declared weight, and `@font-face` binds on the CSS-declared family name, not the font's internal name table), confirmed by Wave 1's review. Worth a cheap re-instancing pass with a proper name-table rename at some point, not urgent.
- Wave 1's `@theme` block registered the readout-face font under `--font-mono` rather than the Three-Face-Rule-matching `--font-readout` the plan asked for. No ripple today (`font-mono` had zero pre-existing usages app-wide), but worth renaming to `--font-readout` for naming consistency if a later wave touches `index.css`'s `@theme` block anyway.
