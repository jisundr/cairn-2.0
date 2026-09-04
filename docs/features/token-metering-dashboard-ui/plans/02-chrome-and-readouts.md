# Plan — Track A / Wave 2: chrome & readouts

Design: `../DESIGN.md` — Meter Boxes, Empty State, Warning Banner sections; Header chrome follows the same corner/border/elevation vocabulary Wave 1 already applied to the `ui/` primitives. Depends on Wave 1 (tokens + primitives must exist first).

## Scope

- `token-metering/frontend/src/components/Header.tsx` — instrument-window chrome, brand mark, install-scope toggle
- `token-metering/frontend/src/components/Dashboard.tsx` — top-of-page meter-box totals (tokens/cost readouts) only; the panels it composes (charts, sessions) are out of scope here, ported in Waves 3-4
- `token-metering/frontend/src/components/WarningBanner.tsx` — dashed signal-line border, signal-soft fill, mono `<code>` treatment
- `token-metering/frontend/src/components/EmptyState.tsx` — dashed-border card, circular mono-glyph mark, numbered steps

## Steps

1. **Plan** — `cairn:scope` → `cairn:planner`, using this file as primary input. Present the plan for approval before dispatching `builder`.
2. **Worktree**: Track A's existing worktree/branch, continued from Wave 1 (or freshly created if Wave 1's was torn down after merge).
3. **Implement** — `cairn:builder`:
   - `Header.tsx`: apply the instrument-window frame (hairline border, tone-stepped chrome bar) and brand mark per `DESIGN.md`; install-scope toggle keeps its existing behavior, restyled only.
   - `Dashboard.tsx`: meter boxes get the readout face (Martian Mono, tabular-nums) for numeric totals and the label face for their captions, per the Three-Face Rule — no data-binding change.
   - `WarningBanner.tsx`: dashed `signal-line` border, `signal-soft` fill, `<code>` spans in the readout face.
   - `EmptyState.tsx`: dashed-border card, circular mono-glyph mark, numbered-step list per `DESIGN.md`'s Empty State component spec.
4. **Gate** — `npm run build && npx playwright test` inside `frontend/`.
5. **Confirm tests** — existing Playwright coverage for empty/cold-start (`e2e/cold-start/`) and warning-banner states (`e2e/populated/`) re-run against the new markup; extend only if a `DESIGN.md` device (e.g. the dashed-border empty-state mark) isn't yet exercised by an assertion.
6. **Test manually** — `cairn:run` against a real session mid-usage-limit warning (Playwright's fixtures don't fully cover a live warning trigger) — confirm `WarningBanner.tsx` renders correctly against real event data, not just the seeded fixture shape.
7. **Review** — `cairn:reviewer` against the diff, scoped to this wave.
8. **PR** — opened inside the `token-metering` submodule, diff scoped to this wave only.

## Done when

Wave 2's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip Wave 2's checkbox there, log the merge date. Track A now waits on Track B's Wave 4 merging before Wave 5 can start.
