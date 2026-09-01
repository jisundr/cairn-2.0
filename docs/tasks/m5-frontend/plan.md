# Plan — m5-frontend

Design: `docs/features/token-metering/03-architecture.md` §Serving side (stack, decided-on choices) + `docs/features/token-metering/mockups/dashboard.html` (approved visual/structural reference — every toggleable state in it is in scope). API already shipped by M4 in `token-metering/server.py` — read, not designed, here. Source plan: `docs/features/token-metering/plans/m5-frontend.md`.

## Scope

- `token-metering/frontend/` — new Vite + React 19 source (Tailwind, shadcn/ui components copied in under `frontend/src/components/ui/`, `@tanstack/react-query`, Recharts)
- `token-metering/static/` — `npm run build`'s output (`vite.config.ts`'s `build.outDir` pointed at `../static`), committed, never hand-edited
- `token-metering/frontend/e2e/` — new Playwright specs run against the built `static/` bundle served by `server.py`
- `token-metering/frontend/playwright.config.ts` — new
- `token-metering/.harness/workflow.md` — amend Gates/Testing to describe the new `npx playwright test` gate, replacing today's "no automated tests — manual check" line for frontend

Out of scope: `server.py`/API changes (M4, merged, do not touch), `commands/cairn-tokens.md` (M6), the 15s-poll timing behavior (manual-only, see Actionable 6).

## Actionables

1. **Scaffold `token-metering/frontend/`** — Vite + React 19 project; Tailwind configured; shadcn/ui components copied into the tree (not installed as a runtime package, per `03-architecture.md`); `package.json` `build` script that leaves compiled output in `token-metering/static/`.

2. **API client layer** over `server.py`'s routes (see `TokenMeteringApp.handle_api` for the full list: `/api/projects`, `/api/rollup/timeseries`, `/api/rollup/day-detail`, `/api/rollup/session`, `/api/rollup/agent`, `/api/rollup/model`, `/api/rollup/tool`, `/api/rollup/skill`, `/api/rollup/mcp-server`, `/api/heatmap`, `/api/usage-limit-events`, `/api/session/<id>/trace`, `/api/call/<session>/<n>`). Every response is enveloped as `{data, meta: {generated_at}}`. `@tanstack/react-query` polls each at 15s.

3. **Dashboard views matching every toggleable state in `mockups/dashboard.html`**:
   - App header, status cluster (refresh pill / "updated Xm ago" / manual refresh)
   - Warning banner — rendered only when `/api/usage-limit-events` is non-empty
   - Tokens/day panel: range tabs (today/7d/30d/month/6m/life) each swapping chart shape per the mockup (today = hourly bars, 7d = daily bars with per-day click-through, 30d/month/6m/life = sparkline, no click-through). The per-day breakdown-on-click (`day-detail`, calling `/api/rollup/day-detail?date=...`) applies only to the 7d tab — the other tabs have no day-radio/detail affordance in the mockup; don't add one.
   - Agents & skills, tokens/model, tool calls, MCP calls hbar-list panels; activity heatmap (7×24 grid) from `/api/heatmap`
   - Projects panel + project-filter pills — shown only when `/api/projects` returns more than one project (the user/local-scope multi-project case); a project-scope install (the common case, one project) never shows these
   - Sessions table: most-recent session auto-selected, click-to-select, project column added only in the multi-project case, flag-dot on a session with a usage-limit hit
   - Session drilldown: per-agent expand/collapse rows, each with its call trace table (`/api/session/<id>/trace`)
   - Trace-row detail (drawer in-app): renders `prompt`/`response` when `/api/call/<session>/<n>`'s `available` is `true`; a "transcript unavailable" message when `available` is `false` — this state isn't drawn in the mockup itself (see `03-architecture.md`'s "Trace-row transcript unavailable"), so build it directly from that contract
   - Cold-start empty state when the rollup/session endpoints return empty results

4. **`/call/<session>/<n>` client-side route**: drawer overlay when reached via in-app navigation, standalone page (`.call-page` layout in the mockup) when it's the entry route on direct load/refresh. Relies on `server.py`'s existing catch-all → `index.html` fallback — no server change needed.

5. **`token-metering/frontend/e2e/` Playwright suite + `playwright.config.ts`**:
   - Add `@playwright/test` as a frontend devDependency
   - `playwright.config.ts` defines two `webServer` entries (or two Playwright `projects`, each with its own `webServer`/`baseURL`) rather than one: a **populated** instance and a **cold-start** instance. A single `.cairn/tokens.db` can't represent both without specs mutating shared state between each other.
   - **Populated instance**: seed a fixture project's `.cairn/tokens.db` before `server.py` starts, via `db.py`'s `connect`/`insert_call`/`insert_tool_use`/`insert_usage_limit_event` helpers (mirrors `test_server.py`'s `make_project` fixture pattern) from a small Python seed script under `frontend/e2e/fixtures/`. Seed timestamps relative to the run's current time (`datetime.now(timezone.utc)` minus offsets), not hardcoded past dates like the mockup's — the today/7d/30d/etc. range windows are wall-clock-relative in `server.py`, so fixed dates would go stale. Include: calls spanning several agents/models/tools/skills/MCP servers, a day with zero calls (to exercise the 7d "No calls recorded" day-detail state), a `usage_limit_events` row, and at least two distinct call rows for the transcript-detail drawer.
   - **Cold-start instance**: `server.py` pointed at a project root with no `.cairn/tokens.db` at all.
   - Transcript-detail "available" vs "unavailable": `server.py` resolves its transcript directory from `Path.home() / ".claude" / "projects"` at import time (`DEFAULT_CLAUDE_PROJECTS_DIR`) — not a CLI-configurable path, and not to be changed (`server.py` is out of scope). Set the populated instance's `webServer.env.HOME` to a scratch directory instead, and write one fixture transcript `.jsonl` under `<scratch>/.claude/projects/<encoded-project-root>/<session_id>.jsonl` (path shape per `server.py`'s `encode_project_path`/`transcript_path_for`) containing a real prompt/response for one call's `request_id`, so that call resolves "available" and every other fixture call — with no matching transcript entry — naturally resolves "unavailable".
   - Specs covering: empty/cold-start view, populated rollups (chart tabs incl. 7d day-detail), agent-row trace expansion, trace-drawer "available" content, trace-drawer "transcript unavailable", usage-limit warning banner, and `/call/<session>/<n>` resolving as the standalone page on a direct `page.goto()` (not only via in-app click-through).

6. **Gate**: `npm run build` inside `token-metering/frontend/` (regenerates `token-metering/static/`), then `npx playwright install --with-deps` (first run) and `npx playwright test` against that build — both green. Commit the rebuilt `static/` as its own artifact (one-artifact-per-commit convention).

7. **Manual-only check** (not automatable, narrowed scope): confirm the 15s poll picks up a newly-completed session without manual refresh, via `cairn:run` against a live session. Not part of the e2e suite or its gate.

8. **`token-metering/.harness/workflow.md` update**:
   - Gates: add a bullet — `npx playwright test` (against the built `static/`) clean before any commit, alongside the existing `pytest`/`npm run build` bullets
   - Testing: replace "Frontend: no automated tests — manual check against the parent repo's approved mockup states" with a line naming the fixture-seeding approach from Actionable 5 (two `webServer` instances, `db.py`-seeded fixture db, HOME-scoped transcript fixture) and noting the 15s-poll timing check stays manual

9. **Review**: `cairn:reviewer` agent against the diff (`frontend/` incl. `e2e/` + regenerated `static/` + the `.harness/workflow.md` change), before any PR exists — never `cairn:review-pr` (`GOAL.md`'s step 6: that skill reviews an already-open PR, which isn't this project's flow). Fail → back to Actionable 1-8 with findings.

10. **PR**: the main thread opens it, same diff scope as Actionable 9.

## Done when

`npm run build` (inside `token-metering/frontend/`) regenerates `token-metering/static/`, and `npx playwright test` is green covering every state enumerated in Actionable 3 plus the `/call/<session>/<n>` deep-link route resolving on direct load.

Risks: `server.py` resolves its transcript directory from `Path.home()` at *import time*; Actionable 5's HOME-env-override approach for the "available" transcript state depends on that holding true per-subprocess (untested assumption — verify early, before building out both drawer-content variants).
