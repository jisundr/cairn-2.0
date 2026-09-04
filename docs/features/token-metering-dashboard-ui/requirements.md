# Requirements: token-metering dashboard — production port

Carries the approved "Bench Scope" design system (`DESIGN.md`, built and shipped as a static, JS-free mockup at `mockups/dashboard.html`) into the real, running dashboard at `token-metering/frontend/`. The mockup itself is a frozen design proposal — nothing here changes it. This doc and its `plans/*.md` are documentation-only; no fix or port lands here.

All file:line references below were checked against `token-metering/frontend/` at its current `HEAD` (2026-09-04, commit `430c6d7`'s submodule pointer); a future reader implementing off this doc should re-check them, since the code may have moved since.

## Problem

The live dashboard the mockup was designed to replace still runs the old visual system in production. `token-metering/frontend/src/index.css:1-16` defines a muted paper/graphite/blue palette (`--paper`, `--blue`, `--flag`, `--graphite`) with body text in Archivo and a mono face (`.font-label`) in Space Mono — exactly the "confirmed anti-reference" `DESIGN.md`'s Overview names as evidence for the redesign, not visual authority to keep. `DESIGN.md` also names PRODUCT.md's own principle directly: this is the "generic AI-scaffolded dashboard" look the whole project exists to move away from.

The approved system currently exists only as one static HTML file with hardcoded sample data and CSS-only (`:target`/`:has()`/`:checked`) interactivity. None of it has touched the real component tree (`token-metering/frontend/src/components/`, 13 components + 4 shared `ui/` primitives, ~1,360 lines), and the live app's actual dynamic behavior — `@tanstack/react-query` polling, `recharts`-driven charts, routing between the dashboard and per-call pages, sortable/filterable session state — has never been exercised against the new system at all.

## Goals

1. `token-metering/frontend/src/index.css`'s custom properties (and any Tailwind v4 theme mapping) match `DESIGN.md`'s palette (bone/window/block/ink/signal scale, `--ch1`–`--ch4`) — no reference to `--paper`/`--blue`/`--flag`/`--graphite` remains anywhere in `src/`.
2. Every rendered string in the app resolves to exactly one of `DESIGN.md`'s three faces (label/body/readout) per the Three-Face Rule, using the resolved font-hosting strategy (Open question below).
3. The shared `ui/` primitives (`button.tsx`, `badge.tsx`, `panel.tsx`, `tabs.tsx`) and every component composing them reflect `DESIGN.md`'s shape and elevation rules (Bezel-Not-Shadow, the 1–6px corner range, hairline borders) with no change to their existing props/behavior.
4. `TokensPerDayPanel.tsx`'s `recharts`-based chart renders the graticule background and the calibrated trace/tick device from the mockup (or a `recharts`-native equivalent, per the Open question below) without losing `recharts`' built-in tooltip, resize, and live-data behavior.
5. `SessionsTable.tsx`, `SessionDrilldown.tsx`, `HbarList.tsx`, `ProjectsPanel.tsx`, `WarningBanner.tsx`, `EmptyState.tsx`, `Header.tsx`, `CallPage.tsx`, `TraceDrawer.tsx`, and `TraceDetailContent.tsx` all reflect the new component vocabulary (meter boxes, dial tabs, session-item markers, the dashed-border warning/empty convention) while their existing data-binding, routing, and interaction logic is untouched.
6. `frontend/e2e/populated/dashboard.spec.ts`'s assertions tied to the old token system (`border-(--blue)` at lines 41 and 45) are updated to the new system rather than left broken; `npm run build && npx playwright test` stays green through every wave that touches the frontend.
7. Once the port is complete and `token-metering/frontend/`'s `npm run build` is re-run, `tools/tokens/static/` in this repo is re-vendored from the rebuilt output, per the existing "re-vendor `tools/tokens/static/` from `token-metering/static/`" convention (most recently commit `54b2c31`).

## Non-goals

- Changing `mockups/dashboard.html` itself — it stays the frozen design reference this port works from; no fix discovered mid-port gets "fixed in the mockup" instead of ported forward.
- Any new feature, data field, or API surface — this is a visual/component port, not a functionality change. The backend (`tools/tokens/`, `token-metering/`'s backend copy) is untouched.
- Replacing `recharts` with a fully bespoke charting engine — the default assumption is customizing `recharts` (custom `Dot`/`Line`/`CartesianGrid` renderers) to approximate the mockup's look, not dropping the library. Only reconsidered if the Open question below concludes that's the only way to hit the graticule/trace device.
- Rewriting the app's state management, routing (`routing.ts`), or data-fetching (`api/hooks.ts`, `api/client.ts`) — untouched by this port.
- General font-hosting infrastructure beyond serving Big Shoulders/Public Sans/Martian Mono to this one app.
- Reproducing the mockup's CSS-only (`:target`/`:has()`/`:checked`, no-JS) interaction mechanism — that architecture exists because the mockup has no JS runtime; the live app already has real React-driven interactivity that the port preserves as-is.

## Stakeholders

Single stakeholder: the solo developer who authored, reviewed, and runs this dashboard locally (the same "primary user" scope locked for the mockup itself). No team, no external users to coordinate with.

## Constraints & assumptions

- Frontend stack is fixed: React 19 + Vite 8 + Tailwind v4 (`@import "tailwindcss"`, CSS-first config) + shadcn-derived `ui/` primitives (`class-variance-authority` + `tailwind-merge`) + `recharts` + `lucide-react` + `@tanstack/react-query` (`token-metering/frontend/package.json`) — the port works within this stack; no new charting or component library.
- Gated by `token-metering/.harness/workflow.md`: `pytest test_*.py` clean (backend untouched, must stay green throughout); `npm run build` inside `frontend/` regenerates `static/` (commit the rebuild, never hand-edit `static/`); `npx playwright test` clean before any commit.
- `frontend/e2e/` runs against two seeded server states — "populated" and "cold-start" (`playwright.config.ts`) — both states, not just one, must render correctly in the new system.
- `static/` is a generated, committed artifact; `tools/tokens/static/` in this repo is a re-vendored mirror of it. A wave that changes `frontend/`'s built output without a matching re-vendor commit here leaves the two out of sync — the same drift risk `token-metering-followups/specs/06-vendoring-drift-guard.md` exists to catch for the backend, just without an automated guard on the frontend side.
- `DESIGN.md` (this feature's own, already-shipped) is the source of truth for tokens, components, and named rules. Where it's silent on a live-app-only concern it doesn't need to cover in a static mockup (loading states, error states, the 15s auto-refresh's "updated Ns ago" ticking caption, pagination beyond `HbarList`'s cap), extend it conservatively in the same vocabulary rather than inventing a new one — DESIGN.md itself is not amended by this port unless a wave's plan concludes a genuine gap needs a new named rule.
- One artifact per commit (this repo's own discipline, `CLAUDE.md`) — each wave below ships as one or more independently gated commits, never a sweep across the whole component tree.

## Open questions

- **Chart technique.** Does `TokensPerDayPanel.tsx` get a graticule `CartesianGrid` plus custom `Dot`/`Line` renderers to approximate the mockup's hand-rolled SVG polyline+tick overlay, or does the chart go fully bespoke (matching the mockup's literal implementation, dropping `recharts`) — at the cost of `recharts`' built-in responsive container and tooltip machinery? Left to `plans/03-charts.md` to resolve before Wave 3 starts.
- **Font hosting.** The mockup loads Big Shoulders/Public Sans/Martian Mono from a Google Fonts CDN link — the `impeccable-finish-reviewer`'s review of the mockup called this acceptable only for a "review-only static mockup," naming it as a future concern "if the pattern is copied into the shipping React app." This port *is* that shipping app. Resolve self-hosted (`.woff2` files vendored into `frontend/public/` or similar) vs. CDN before Wave 1 lands — every later wave's typography depends on the answer. Left to `plans/01-tokens-and-primitives.md`.
- **`ActivityHeatmap.tsx`'s color.** `DESIGN.md`'s Ink-Scale Data Rule says multi-series data renders on the ink channel scale, never amber — but a heatmap's whole point is a single-series intensity gradient, which isn't quite "multi-series data" or a "triggered/selected/warning" state either. Whether intensity gets its own ink-scale gradient (consistent with the Ink-Scale Data Rule's spirit) or the heatmap is treated as a special case isn't decided by `DESIGN.md` and needs a call in `plans/03-charts.md` before Wave 3's heatmap piece.

## Success criteria

1. No file under `token-metering/frontend/src/` references `--paper`, `--blue`, `--flag`, `--graphite`, `Archivo`, or `Space Mono`.
2. Every component under `token-metering/frontend/src/components/` visually matches its `DESIGN.md`-named counterpart when compared against the reviewed mockup evidence (`docs/features/token-metering-dashboard-ui/.impeccable/review/{desktop,mobile,sessions-interaction,empty-state}.png`).
3. `pytest test_*.py`, `npm run build`, and `npx playwright test` are all green inside `token-metering/`, with no assertion left referencing the old token system.
4. `tools/tokens/static/` in this repo matches a fresh `npm run build` of the ported `token-metering/frontend/`, confirmed by re-running the existing re-vendor step.
5. Exercised live via `cairn:run` against a real session (not just the two Playwright fixture states): a cold-start/empty project, a populated project, a session mid-usage-limit warning, and an agent-select interaction in the drilldown all render correctly in the new system.
