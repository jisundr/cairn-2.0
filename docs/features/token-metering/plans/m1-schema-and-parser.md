# Plan — Track A / M1: `db.py` (`tool_uses`) + `parser.py`

Design is fully pinned in [`../specs/2026-08-29-m1-db-parser.md`](../specs/2026-08-29-m1-db-parser.md) (schema, function signatures, data flow, error handling, test list) — this plan sequences *building* it, per `../GOAL.md`'s sprint process. Don't re-derive shape here; the spec is the authority.

## Scope

- `token-metering/db.py` — add `TOOL_USES_SCHEMA` + `insert_tool_use`
- `token-metering/parser.py` — new: `build_agent_map`, `parse_transcript`, `parse_session`
- `token-metering/test_db.py` — extend
- `token-metering/test_parser.py` — new

Repo: mostly inside the `token-metering` submodule, plus one cleanup commit in cairn-2.0 itself (see Step 0).

## Step 0 — resolve the `tools/tokens/` carryover (blocking, do first)

`token-metering/db.py` has no code yet. The `calls`/`usage_limit_events` schema + tests this milestone builds on top of currently exist only in this repo's pre-split `tools/tokens/db.py`/`test_db.py` (committed at `9c0ff58`), and `tools/tokens/db.py` additionally carries an **uncommitted** diff that already adds this milestone's `TOOL_USES_SCHEMA`/`insert_tool_use` — untested, in the wrong repo. Per `GOAL-STATE.md`'s log, this was left unresolved on purpose until this sprint starts. Before Step 2:

- Port the `calls`/`usage_limit_events` schema (and decide whether to carry over the uncommitted `tool_uses` diff or discard and let Step 2 build it fresh) into `token-metering/db.py` + `test_db.py`.
- Remove `tools/tokens/` from this repo (own commit, `tools/budget.py` clean) once the port is verified.

## Steps

1. **Worktree**: create a branch inside `token-metering/` for this sprint (outer-repo worktree alone doesn't branch the submodule — see `../GOAL.md`'s Worktree section). Step 0's cleanup commit lands directly on cairn-2.0's own branch/worktree, not the submodule.
2. **Implement** — `cairn:builder`, working from the spec's Components and Data flow sections. While implementing, confirm the exact `message.usage` field names (cache-read vs. the two cache-write buckets) against one real captured transcript, per the spec's note — a mismatch there is a one-line mapping fix, not a redesign.
3. **Gate** — `pytest test_db.py test_parser.py` inside `token-metering/`.
4. **Manual test** — no hook exists yet to trigger this end-to-end, so sanity-check directly: run `parse_session` in a Python REPL against one real `~/.claude/.../transcript.jsonl` (main + a `subagents/` file if one exists) into a scratch sqlite file, then inspect row counts via the `sqlite3` CLI — plausible `calls`/`tool_uses` counts, correct `agent` attribution, no `usage_limit_events` misclassified as calls.
5. **Confirm tests** — the spec's Testing section lists the required cases (agent-map resolution, unresolved dispatch, two-file attribution, `"unknown"` tagging, duplicate `requestId`, duplicate `tool_use_id`, usage-limit routing, malformed-JSON-line tolerance, re-run idempotency). All present and green.
6. **PR** — `cairn:review-pr` against the `token-metering` submodule's own repo, diff scoped to `db.py`/`parser.py`/their tests.

## Done when

M1's gate in `../GOAL-CONDITION.md`'s Per-milestone gate section is satisfied and its PR (opened against the `token-metering` submodule) has merged. Then flip M1's checkbox in `../GOAL-STATE.md`, log the merge date, and move to Track A's next sprint — M4, once Track B's M3 has also merged (per `../GOAL.md`'s Sprint sequence table). M1 merging also unblocks Track C's M2.
