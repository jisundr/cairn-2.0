# Plan — Track A / M5: `frontend/`

Design: `../03-architecture.md` §Serving side (stack) + `../mockups/dashboard.html` (approved visual reference — not formalized into a design system, one screen). Depends on M4's API shape.

## Scope

- `token-metering/frontend/` — new dev-time React source
- `token-metering/static/` — compiled output, committed (never hand-edited)
- `token-metering/frontend/e2e/` — new Playwright suite, browser-level, run against the built `static/` output served by M4's `server.py` (not against dev-server HMR)
- `token-metering/frontend/playwright.config.ts` — new, `webServer` config starts `server.py` against a seeded fixture `tokens.db` for the test run and tears it down after
- This amends the submodule's own `.harness/workflow.md`, which currently says frontend testing is manual-only — update its Gates/Testing sections alongside this milestone's implementation so the harness reflects reality (own commit or folded into this milestone's, submodule's call)

## Steps

1. **Worktree**: branch inside `token-metering/`.
2. **Plan** — `cairn:scope` (source: this file; path: escalated per `../GOAL.md`'s Plan step), then `cairn:planner` → `docs/tasks/m5-frontend/STATE.md` + plan, using this file as its primary input. Present for approval before dispatching `builder`.
3. **Implement** — `cairn:builder`, escalated path:
   - React 19 + Vite + Recharts + Tailwind + shadcn/ui (components copied in, not pulled as a runtime kit) + `@tanstack/react-query` polling at 15s.
   - Match every view/state in `mockups/dashboard.html`: empty/cold-start, populated, per-session trace expansion, transcript-unavailable trace detail, usage-limit warning banner.
   - `/call/<session>/<n>` client-side route — drawer in-app, standalone page on direct load (relies on M4's `index.html` catch-all).
   - Add `@playwright/test` as a frontend devDependency; `playwright.config.ts` seeds a fixture `tokens.db`, starts `server.py` against it via `webServer`, and points tests at the built `static/` bundle.
   - Write specs under `frontend/e2e/` covering the same states as the manual pass: empty/cold-start, populated rollups, per-session trace expansion, transcript-unavailable trace detail, usage-limit warning banner, and the `/call/<session>/<n>` deep-link route resolving on direct load (not just in-app navigation).
4. **Gate** — `npm run build` inside `token-metering/frontend/` (regenerates `token-metering/static/`), then `npx playwright install --with-deps` (first run only) and `npx playwright test` against that build — both must pass. Commit the rebuilt `static/` as its own artifact per the submodule's one-artifact-per-commit convention.
5. **Manual test** — narrowed to what the e2e specs don't cover:
   - Confirm the 15s poll picks up a newly-completed session without a manual refresh (timing-based; awkward to assert reliably in an automated spec), and that manual refresh also works.
   - One more screen-by-screen visual pass against `mockups/dashboard.html` via `cairn:run` + browser, catching anything the e2e assertions don't check (spacing, color, copy).
6. **Confirm tests** — the `frontend/e2e/` specs above, all green under `npx playwright test`.
7. **Review** — `cairn:reviewer` agent against the diff (`frontend/` incl. `e2e/` + regenerated `static/` + the `.harness/workflow.md` update), before any PR exists. Fail → back to step 3 with findings.
8. **PR** — the main thread opens it, same diff scope as step 7.

## Done when

M5's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip M5 in `../GOAL-STATE.md`, log it, and move to Track A's next sprint — M6, once Track C's M2 has also merged.
