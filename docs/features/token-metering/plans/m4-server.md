# Plan — Track A / M4: `server.py`

Design: `../03-architecture.md` §Serving side — the largest single milestone. Depends on M1 (`db.py`) and M3 (`pricing.py`).

## Scope

- `token-metering/server.py` — new
- `token-metering/test_server.py` — new

## Steps

1. **Worktree**: branch inside `token-metering/`.
2. **Implement** — `cairn:builder`, covering every sub-decision `03-architecture.md` pins down for this milestone:
   - Python stdlib `http.server` + `sqlite3`, binds `localhost` only, foreground, stops on Ctrl-C.
   - JSON API: rollups by day/session/agent/tool/skill/MCP-server; day-of-week × hour-of-day heatmap (bucketing `calls.timestamp`); per-session call trace; on-demand prompt/response lookup read from the transcript file at request time (never duplicated into `tokens.db`).
   - Per-day chart range bucketing (Today/7D/30D/Month/6M/Life) — exact day-counts decided now, per `02-requirements.md`'s Open Questions.
   - Cross-project union via `~/.claude/cairn/known-projects.json` when present; project-scoped installs never read it.
   - Cold start: empty/missing `.cairn/tokens.db` → rollup/session-list endpoints return empty results, not errors.
   - Transcript-unavailable: moved/deleted transcript file → defined "unavailable" response shape from the prompt/response lookup, not an error; tokens/cost/duration unaffected.
   - Catch-all → `index.html` fallback so `/call/<session>/<n>` resolves on direct load (M5 depends on this).
3. **Gate** — `pytest test_server.py` inside `token-metering/`.
4. **Manual test**:
   - Seed a `.cairn/tokens.db` from a real captured session (M1/M2 output) plus a deliberately-priced-and-unpriced mix of models.
   - `cairn:run` to start `server.py`; hit each JSON endpoint directly (`curl`) — confirm rollup totals are plausible against the transcript, heatmap buckets look right, trace ordering is correct, an unpriced model's rollup group returns `null` not a partial sum.
   - Seed `known-projects.json` with a second project's db path — confirm the union appears.
   - Point at an empty/missing `tokens.db` — confirm empty results, not a 500.
   - Move/delete a transcript file backing a captured call — confirm the on-demand lookup returns the "unavailable" shape, not an error.
   - Hit a non-API path (e.g. `/call/<session>/1`) directly — confirm the `index.html` fallback, not a 404.
5. **Confirm tests** — rollup correctness (incl. `tool_uses` + heatmap), trace ordering, unpriced-model `null` propagation, cross-project union (per `../ROADMAP.md`'s M4 test list).
6. **PR** — `cairn:review-pr`, diff scoped to `server.py`/tests.

## Done when

M4's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip M4 in `../GOAL-STATE.md`, log it, and move to Track A's next sprint — M5.
