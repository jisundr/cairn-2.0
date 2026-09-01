# Spec: correct `03-architecture.md`'s stale submodule-only framing

Implementation spec for `requirements.md` issue 7 / goal 7. A docs-only correction, no code change — kept to exactly the wording that's actually wrong, per the requirements doc's finding that this is a genuine oversight in `docs/tasks/vendor-token-metering-backend/plan.md`'s Actionable 3 file list, not a deliberate historical-record choice like `ROADMAP.md`'s milestone bodies.

## Architecture

`03-architecture.md` is the living design description of the feature (as opposed to `ROADMAP.md`'s milestone bodies, which `plan.md`'s own Scope section explicitly preserves "as historical record of the original submodule-based build"). There's no reason for a living design doc to keep describing a layout that no longer exists — so this fix mirrors, in `03-architecture.md`, exactly the correction `plan.md`'s Actionable 3 already made in `docs/BUILD_BRIEF.md` §B10, `ROADMAP.md`'s header, and `GOAL-CONDITION.md`'s Invariants: state that the backend (`db.py`, `parser.py`, `pricing.py`, `server.py`) lives at `tools/tokens/` in this repo, and only `frontend/` still lives in the `token-metering` submodule, maintainers-only.

Four spots in the file carry the stale framing (all checked against the file's current content at time of writing): the Architecture section's opening paragraph (line 7), the Components table (lines 29-37), Data flow step 3 (line 43), and the Testing section's gate description (line 58). This spec corrects all four in one pass rather than just the line the review flagged, since leaving the other three would just relocate the same staleness a few lines down — the review named line 7 as the clearest example, not the only instance.

## Components

### `docs/features/token-metering/03-architecture.md`

**Line 7**, current:

> `db.py`, `parser.py`, `pricing.py`, `server.py`, and `frontend/` all target the `token-metering` git submodule (`cairn-2.0-token-metering`), not this repo — this repo (cairn-2.0) keeps the design docs plus the two artifacts that reach across the submodule boundary to invoke that code: `hooks/stop-tokens.sh` and `commands/cairn-tokens.md`. `python tools/budget.py` gates only what ships from this repo; the submodule is gated by its own `.harness/workflow.md` (`pytest`, plus `npm run build` for the frontend). Full milestone-by-milestone breakdown in `ROADMAP.md`.

New, matching `ROADMAP.md`'s already-corrected header paragraph:

> `db.py`, `parser.py`, `pricing.py`, and `server.py` live at `tools/tokens/` in this repo, vendored from their original home in the `token-metering` git submodule (`cairn-2.0-token-metering`) — see `docs/tasks/vendor-token-metering-backend/` for why and when. Only `frontend/` (the dev-time React/Vite build) still lives in that submodule, reached by maintainers only; a consuming project's checkout never needs it initialized. `hooks/stop-tokens.sh` and `commands/cairn-tokens.md` invoke `tools/tokens/server.py`/`parser.py` directly, with no submodule boundary to cross. `python tools/budget.py` and `pytest tools/` gate `tools/tokens/` alongside every other artifact in this repo; `token-metering/`'s own `.harness/workflow.md` (`pytest`, `npm run build`) gates only `frontend/` now. Full milestone-by-milestone breakdown in `ROADMAP.md`, including the post-completion relocation.

**Components table** (lines 29-37) — every cell naming a backend file path is updated from `token-metering/` to `tools/tokens/`:
- Row 1 (`db.py`): first column `token-metering/db.py` → `tools/tokens/db.py`.
- Row 2 (`parser.py`): first column `token-metering/parser.py` → `tools/tokens/parser.py`; "Depends on" column `token-metering/db.py` → `tools/tokens/db.py`.
- Row 3 (`hooks/stop-tokens.sh`): "Depends on" column `token-metering/parser.py`, `jq` → `tools/tokens/parser.py`, `jq`.
- Row 4 (`prices.json` + `pricing.py`): first column `token-metering/prices.json` + `pricing.py` → `tools/tokens/prices.json` + `pricing.py`.
- Row 5 (`server.py`): first column `token-metering/server.py` → `tools/tokens/server.py`; "Depends on" column `token-metering/db.py`, `token-metering/pricing.py` → `tools/tokens/db.py`, `tools/tokens/pricing.py`.
- Row 6 (`frontend/`): first column stays `token-metering/frontend/` (genuinely still correct — that piece lives there). Its "What it does" cell — "Dev-time React/Vite source; compiled to `token-metering/static/`, which is what actually ships" — needs its own small correction: `tools/tokens/server.py` serves static assets from `tools/tokens/static/` (`Path(__file__).resolve().parent / "static"`, per that file's own code), not `token-metering/static/` — the latter still exists as the frontend's own build output (kept for that repo's e2e fixtures, `plan.md` Decision 2) but is no longer what a running dashboard actually serves post-vendoring. New wording: "Dev-time React/Vite source; compiled to `token-metering/static/`, vendored into `tools/tokens/static/` (one-time copy, `docs/tasks/vendor-token-metering-backend/`) — the latter is what `tools/tokens/server.py` actually serves." This also surfaces a gap worth one sentence in the corrected prose but not a fix in this spec (out of this issue's scope, and arguably its own follow-up): there's no documented process today for keeping `tools/tokens/static/` in sync with a *future* `frontend/` rebuild, unlike `tools/tokens/`'s four backend modules, which `specs/06-vendoring-drift-guard.md` covers. Naming the gap in the corrected doc text is in scope here (it's accurate, and cheap); building a guard for it is not.
- Row 7 (`commands/cairn-tokens.md`): "What it does" cell `Starts token-metering/server.py in the background...` → `Starts tools/tokens/server.py in the background...`; "Depends on" column `token-metering/server.py` → `tools/tokens/server.py`.

**Data flow step 3** (line 43), current: "...inserting each unique `requestId` into `calls`... via `token-metering/db.py`." → "...via `tools/tokens/db.py`."

**Testing section** (line 58), current: "...Gated by `pytest` inside `token-metering/`, per that repo's own `.harness/workflow.md` — not `python tools/budget.py`, which covers only this repo's own artifacts." → "...Gated by `python tools/budget.py`/`pytest tools/` for `tools/tokens/`'s four modules, and by `pytest` inside `token-metering/` (per that repo's own `.harness/workflow.md`) for `frontend/`'s tests only."

No change to the Capture side / Serving side bullet lists (lines 9-25) — they describe behavior and design rationale, not file locations, and were checked line-by-line against the current split with nothing else found stale there. No change to `01-intent.md`, `02-requirements.md`, or `04-user-flow.md` — none of the three references the submodule/vendoring split at all (confirmed by reading each during this review), so none needed correcting.

## Data flow

Not applicable — this is a documentation edit with no runtime behavior to trace.

## Error handling

Not applicable.

## Testing

Not applicable — no code changes. Verification is a re-read of `03-architecture.md` after the edit, confirming no remaining reference to `token-metering/db.py`, `token-metering/parser.py`, `token-metering/pricing.py`, or `token-metering/server.py` (a plain `grep` for those four strings against the edited file returning no matches is sufficient), and that the `frontend/`-related references are untouched.

Gate: `python tools/budget.py` clean (docs-only change; `docs/` isn't part of `budget.py`'s size-budgeted artifact walk, but the gate is still run per this repo's own per-file discipline). No `.claude-plugin/plugin.json` version bump (docs-only, no behavior change, matching every other docs-only entry in `CHANGELOG.md`'s 2026-09-01 section).
