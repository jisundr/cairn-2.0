# Plan — Track A / M6: `commands/cairn-tokens.md`

Design: `../../features/token-metering/04-user-flow.md` Flow 2 (opening the dashboard) and Flow 6 (stopping it); `../../features/token-metering/03-architecture.md`'s Components table and "Serving side" section. `token-metering/server.py`'s actual startup contract (read from the checked-out submodule at the main repo root, since this worktree doesn't have it checked out yet — see Actionable 1): `run(project_root, host="127.0.0.1", port=4317)` binds localhost, blocks in `serve_forever()`, prints `token-metering dashboard: http://{host}:{port}`, exits on `KeyboardInterrupt`; `main()` takes `argv[0]` as `project_root` (defaults to `Path.cwd()` if omitted) and `argv[1]` as an optional port override. Source plan: `docs/features/token-metering/plans/m6-cairn-tokens-command.md`.

## Scope

- `commands/cairn-tokens.md` — new, this repo (cairn-2.0)
- `.claude-plugin/plugin.json` — version bump (same commit, per this repo's one-artifact-plus-its-registry-and-changelog-line convention)
- `CHANGELOG.md` — one new entry
- No `token-metering` submodule changes (out of scope — `server.py`/`frontend` already built by M4/M5)
- No `docs/REGISTRY.md` change — checked: that file registers only agent tool grants, has no commands section, so a new command adds no line there

## Actionables

1. **Submodule prerequisite.** `token-metering/` is not checked out in this worktree (track-a-m6) as of planning time — only in the main repo's working copy. Run `git submodule update --init token-metering` (or equivalent) before writing the command, so `server.py` can actually be invoked for the manual test and its startup contract can be double-checked against the live file rather than this plan's summary.

2. **Write `commands/cairn-tokens.md`**, following `commands/cairn-doctor.md`'s frontmatter/body style (one-line `description:` frontmatter, numbered body steps, no mandate language — no `MUST`/`ALWAYS`/`NEVER`/`MANDATORY`/`NON-NEGOTIABLE`):
   - Starts `token-metering/server.py <project-root>` in the background via `Bash` with `run_in_background`, passing the actual project root explicitly (don't rely on `server.py`'s cwd-default) — mirrors the backgrounding pattern already established in `skills/run/SKILL.md` (wait for the server's own "token-metering dashboard: http://..." readiness line, not a fixed sleep).
   - Opens the default browser to the reported `http://127.0.0.1:<port>` URL (port 4317 unless a port is passed) via a platform-appropriate opener.
   - Reports the URL and how to stop the server. Since this command runs the server as a backgrounded Bash task inside the session rather than literally in a terminal's foreground, report the actual stop action for that background task (not a literal "press Ctrl-C", which doesn't apply to how this command starts it) — satisfies Flow 6's contract (one action stops the server, no separate stop command) using the mechanism this codebase's Bash tool actually offers.
   - Cold start (`.cairn/tokens.db` empty/missing): starts and opens normally per Flow 2's "Resolved" note — no special-casing needed in the command itself, since `server.py`/frontend already handle the empty state.
   - No submodule code changes.

3. **Gate** — full §A13 (`python tools/budget.py`; `python -m pytest tools/`; every `tools/**/*.sh --selftest`; `python tools/budget.py --report`, tail `docs/BUDGET.md`) plus the relevant §B12 acceptance criteria against the new file: #3/#4/#5/#6 (size/budget totals still hold), #17 (no mandate language), #18 (no `TODO`/`TBD`/`FIXME`/placeholder), #23 (no write path outside the §B2b allowlist — this command only starts a process and opens a browser, writes nothing to the consuming project). #26 ("the token report opens correctly from `file://`") predates the live-server amendment noted in `../../features/token-metering/ROADMAP.md`'s own M6 gate line and `03-architecture.md`'s "Serving side" section — re-verify it as "the dashboard opens correctly at its reported `http://` URL" instead, and say so explicitly in the gate output rather than silently skipping the numbered criterion. Any failure is fixed in `commands/cairn-tokens.md` before proceeding.

4. **Manual end-to-end test** (per `03-architecture.md`'s Testing section and `../../features/token-metering/GOAL-CONDITION.md`'s overall Done-when list — this is the feature's full acceptance pass, not just M6's):
   - Run a real cairn session that dispatches at least one subagent.
   - Let `Stop` fire (exercises Track C's already-merged M2 hook).
   - Run `/cairn-tokens`.
   - Confirm: the dashboard opens in the browser; per-day/per-agent rollups sum to a plausible total against the transcript; an agent's rollup row expands into its call-by-call trace; a deliberately-triggered usage-limit event (a synthetic `isApiErrorMessage: true` entry) surfaces the warning banner distinctly, not folded into ordinary usage; re-running `/cairn-tokens` against the same already-captured session doesn't double-count (idempotent via `calls.request_id`'s `INSERT OR IGNORE`, already guaranteed at the `db.py` layer — this step confirms the end-to-end path doesn't reintroduce duplication).

5. **Confirm tests** — manual only, per `../../features/token-metering/ROADMAP.md`'s M6 test note. No new automated coverage: M6 adds no testable logic beyond what `tools/budget.py` already gates for artifacts shipping from this repo.

6. **Review** — dispatch the `cairn:reviewer` agent (never `cairn:review-pr`, which reviews an already-open PR — not this project's flow, per `../../features/token-metering/GOAL.md`'s step 6) against the diff (`commands/cairn-tokens.md`, `.claude-plugin/plugin.json`, `CHANGELOG.md`), before any PR exists. Fail → back to Actionable 2 with findings.

7. **Repo bookkeeping**, same commit as the command file (one-artifact-per-commit convention): bump `.claude-plugin/plugin.json`'s `version` (minor bump — a new command is a new capability, matching the pattern of past minor bumps like M2's `0.13.0`), and add one `CHANGELOG.md` entry describing the command and the version change.

8. **PR** — the main thread opens it, diff scoped to `commands/cairn-tokens.md` + `.claude-plugin/plugin.json` + `CHANGELOG.md`. Never opened by `reviewer` or `builder`.

## Done when

M6's gate (full §A13 + relevant §B12, including the reinterpreted #26) passes, and the manual end-to-end pass in Actionable 4 succeeds. Per `../../features/token-metering/GOAL.md`, the session's own stopping point is the PR opening (Actionable 8) — merge, flipping M6's checkbox in `GOAL-STATE.md`, and closing out the feature (it's the last milestone) happen in a later session once that PR is confirmed merged.

Risks: the `token-metering` submodule is not checked out in this worktree as of planning time — Actionable 1 must succeed before Actionable 2 can verify `server.py`'s CLI/output contract against the live file (not just this plan's summary) or Actionable 4 can run at all.
