# Goal condition: token-metering dashboard — production port

Entry point for this feature — start here, then `GOAL.md` for *how* a sprint runs, `requirements.md` for *what* and *why*, `ROADMAP.md` for the wave sequence, `DESIGN.md` for the system being ported.

## Current status

Not started. `requirements.md`, `ROADMAP.md`, and `GOAL.md` exist; none of the five `plans/0N-*.md` files are written yet, and no sprint has run.

Next up: Track A's Wave 1 (tokens & primitives) — the only wave with no dependency, and the one every other wave is blocked on. `plans/01-tokens-and-primitives.md` needs to exist (and resolve the font-hosting open question) before Wave 1's `cairn:scope` step can start.

## Known issues

None — no sprint has run yet.

## Done when

Pulled directly from `requirements.md`'s Success criteria:

- [ ] No file under `token-metering/frontend/src/` references `--paper`, `--blue`, `--flag`, `--graphite`, `Archivo`, or `Space Mono`.
- [ ] Every component under `token-metering/frontend/src/components/` visually matches its `DESIGN.md`-named counterpart when compared against the reviewed mockup evidence (`.impeccable/review/{desktop,mobile,sessions-interaction,empty-state}.png`).
- [ ] `pytest test_*.py`, `npm run build`, and `npx playwright test` are all green inside `token-metering/`, with no assertion left referencing the old token system.
- [ ] `tools/tokens/static/` in this repo matches a fresh `npm run build` of the ported `token-metering/frontend/`, confirmed by re-running the existing re-vendor step.
- [ ] Exercised live via `cairn:run` against a real session: a cold-start/empty project, a populated project, a session mid-usage-limit warning, and an agent-select interaction in the drilldown all render correctly in the new system.

## Per-wave gate

Mirrors `ROADMAP.md`'s wave Gate lines — the authoritative copy is there; this list is for at-a-glance status only.

- [ ] Wave 1 — tokens & primitives: `npm run build` clean; `npx playwright test` green.
- [ ] Wave 2 — chrome & readouts: `npm run build && npx playwright test`.
- [ ] Wave 3 — charts: `npm run build && npx playwright test`.
- [ ] Wave 4 — sessions & drilldown: `npm run build && npx playwright test`.
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

Empty — no sprint has surfaced deferred work yet.
