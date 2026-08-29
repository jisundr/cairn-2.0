# Plan — Track C / M2: `hooks/stop-tokens.sh`

Design: `../03-architecture.md` §Capture side and §Error handling. Style model: `hooks/session-start.sh` (this repo) — same `set -uo pipefail`, `jq`-based field extraction, silent-degrade posture.

## Scope

- `hooks/stop-tokens.sh` — new, this repo (cairn-2.0)
- `hooks/hooks.json` — register the `Stop` event
- No submodule changes — this milestone only calls into `token-metering/parser.py` (M1), doesn't modify it

## Steps

1. **Worktree**: outer-repo worktree only — nothing in `token-metering/` changes this sprint.
2. **Implement** — `cairn:builder`:
   - Extract `transcript_path`/`session_id`/`cwd` via `jq`, mirroring `session-start.sh`'s pattern.
   - Check the opt-in marker (`<!-- cairn:start -->` in the project's `CLAUDE.md`, same check `session-start.sh` already does).
   - Shell out to a Python entry point invoking `token-metering/parser.py`'s `parse_session` (M1's signature) against the just-ended session.
   - When install scope is user/local rather than project: append the project path to `~/.claude/cairn/known-projects.json`, creating it if absent.
   - Silent `exit 0` on any missing `jq`, missing field, or missing opt-in — never block or alter the session.
3. **Gate**:
   - `hooks/stop-tokens.sh --selftest`
   - `python tools/budget.py` clean
4. **Manual test**:
   - Run a real cairn session that dispatches at least one subagent.
   - Let `Stop` fire; inspect `.cairn/tokens.db` via the `sqlite3` CLI — confirm `calls` rows exist with correct `agent` attribution.
   - Trigger a second `Stop` on the same session (or re-run the hook manually against the same transcript) — confirm no duplicate rows (the parser's `INSERT OR IGNORE` should hold; this step confirms the hook actually re-invokes the parser rather than skipping on a second fire).
   - At user/local scope: confirm `known-projects.json` gets the project path appended, and isn't touched at project scope.
5. **Confirm tests** — `--selftest` covers the hook's own field-extraction/silent-degrade paths.
6. **PR** — `cairn:review-pr`, diff scoped to `hooks/stop-tokens.sh` + `hooks/hooks.json`.

## Done when

M2's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip M2 in `../GOAL-STATE.md`, log it — Track C is done. M2 merging is also one of the two conditions gating Track A's M6 sprint (the other being M5).
