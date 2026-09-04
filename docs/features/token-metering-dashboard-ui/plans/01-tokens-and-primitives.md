# Plan — Track A / Wave 1: tokens & primitives

Design: `../DESIGN.md` (full authority — palette, type scale, elevation/shape rules). This plan resolves the one open question that blocks it (font hosting) and sequences *building* it, per `../GOAL.md`'s sprint process.

## Open question resolved: font hosting → self-host

The mockup loads Big Shoulders/Public Sans/Martian Mono from a Google Fonts CDN `<link>`. The `impeccable-finish-reviewer`'s review of the mockup accepted that only for a "review-only static mockup," naming it a future concern "if the pattern is copied into the shipping React app" — this port is that app, so the CDN link doesn't carry forward.

**Resolution: self-host.** Vendor `.woff2` files (each face's regular + any bold/mono weight `DESIGN.md` actually uses — no unused weights) into `token-metering/frontend/public/fonts/`, declare them via `@font-face` in `index.css` alongside the token swap, and reference them from Tailwind's `@theme` font-family mapping. Rationale: this is a local-only tool with a single stakeholder (`requirements.md` Stakeholders) — a CDN dependency buys nothing (no multi-tenant caching benefit) and costs an external network call on every cold load of an otherwise fully local app. Self-hosting also sidesteps `requirements.md`'s font-hosting Non-goal ("general font-hosting infrastructure") by staying file-local to this one app, not a shared service.

## Scope

- `token-metering/frontend/src/index.css` — replace the 12 old custom properties (`--paper`, `--paper-line`, `--ink`, `--ink-soft`, `--graphite`, `--block`, `--block-line`, `--window`, `--blue`, `--blue-soft`, `--flag`, `--flag-soft`) with `DESIGN.md`'s scale; add `@font-face` declarations; remove any Archivo/Space Mono references
- `token-metering/frontend/public/fonts/` — new, vendored `.woff2` files
- `token-metering/frontend/src/components/ui/button.tsx`, `badge.tsx`, `panel.tsx`, `tabs.tsx` — restyle to the new corner-radius range, hairline borders, Bezel-Not-Shadow elevation; no prop or behavior changes
- Tailwind v4 `@theme` mapping in `index.css` (or wherever the project's CSS-first config lives) — font-family and color-token mapping updated to match

## Steps

1. **Plan** — `cairn:scope` (if not already active) → `cairn:planner`, using this file as primary input. Present the resulting task-folder plan for approval before dispatching `builder`.
2. **Worktree**: create a branch inside `token-metering/` for Track A (this repo's own worktree doesn't branch a submodule — see `../GOAL.md`'s Worktree section).
3. **Implement** — `cairn:builder`:
   - Source or export the three faces' `.woff2` files (regular weights per `DESIGN.md`'s Typography section; Martian Mono needs `font-variant-numeric: tabular-nums` support, confirm the vendored file includes tabular figures rather than relying on a CSS-only fallback) into `public/fonts/`.
   - Write `@font-face` rules and wire them into Tailwind's font-family theme keys (label/body/readout, matching `DESIGN.md`'s Three-Face Rule naming).
   - Swap every custom property per `DESIGN.md`'s palette (bone/bone-dim/window/block, ink/ink-soft/ink-faint, signal/signal-soft/signal-line, `--ch1`–`--ch4`, both hairline opacities).
   - Restyle the four `ui/` primitives: corner-radius range, hairline borders, Bezel-Not-Shadow (flat tone-stepped elevation, no shadow beyond one hairline) — visual only, no prop/behavior change.
4. **Gate** — `npm run build` clean inside `frontend/`; `npx playwright test` green (this wave should change zero test *behavior*, only visuals not asserted on by name — a red assertion here means something got renamed/removed, not just restyled).
5. **Confirm tests** — no new automated coverage expected (`ui/` primitives have no dedicated test file today, per `../ROADMAP.md`'s Wave 1 Tests line); confirm existing Playwright suite still passes unchanged.
6. **Test manually** — `npm run dev`, visually check each primitive's known call sites (buttons, badges, panels, tabs across at least one populated-state screen) against `DESIGN.md`'s Components section; confirm no FOUT/FOIT flash from the font swap on a hard reload.
7. **Review** — `cairn:reviewer` against the diff, scoped to this wave.
8. **PR** — opened inside the `token-metering` submodule, diff scoped to this wave only.

## Done when

Wave 1's gate in `../GOAL-CONDITION.md`'s Per-wave gate section is satisfied and its PR has merged. Then flip Wave 1's checkbox there, log the merge date, and start the next unblocked sprint — both Track A's Wave 2 and Track B's Wave 3 become available.
