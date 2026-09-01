# Plan — Vendor token-metering's backend into cairn-2.0

Motivation: `/plugin install` may not recurse git submodules (a plain `git clone` leaves `token-metering/` empty — anthropics/claude-code#17293; no install-hook mechanism exists — #11240), so a fresh consumer gets a broken `/cairn-tokens`. Fix: vendor the backend as regular tracked files here; keep only `frontend/` (dev-time React/Vite build, never a consuming-project runtime dep) in the `token-metering` submodule.

## Decisions

1. **Target path: `tools/tokens/`.** This repo's own `.harness/architecture.md` Layering line already states the convention: "Subsystem files group under their own `tools/<name>/` dir." It's also the pre-amendment original design — `docs/BUILD_BRIEF.md` §B10 literally says code "targets a separate `token-metering` git submodule, not `tools/tokens/`," and `CHANGELOG.md`'s 2026-08-28 entries show `tools/tokens/db.py` briefly lived here before the submodule detour (a stale, untracked `tools/tokens/__pycache__/` from that era is still on disk — delete it before vendoring, harmless but avoids stale-bytecode confusion). This path needs zero code changes to `tools/budget.py` (already walks/records anything under `tools/`) and is auto-discovered by CI's existing `python -m pytest tools/` step — that pytest run *is* the concrete gate satisfying `done_when`'s "budget.py gates the vendored files," without inventing a size-cap rule with no precedent for application code. No `tools/tokens/README.md`/`CLAUDE.md`/`.harness/` — this repo's root files already govern it, same as `tools/budget.py` has none of its own.
   Import safety: every vendored file does `sys.path.insert(0, str(Path(__file__).resolve().parent))` then flat sibling imports (`import db`, `import pricing`), and `server.py`'s static dir defaults to `Path(__file__).resolve().parent / "static"` — the tree moves as a unit with **no import edits**.

2. **Leave backend files in `cairn-2.0-token-metering` frozen, don't delete.** `token-metering/frontend/playwright.config.ts` (`TOKEN_METERING_ROOT = path.resolve(FRONTEND_ROOT, "..")`) shells out to `${TOKEN_METERING_ROOT}/server.py` for its own e2e fixtures (ROADMAP's M5 gate) — deleting the backend there breaks that repo's own frontend gate. Recommend (not a builder actionable — separate repo/access, outside this task's `paths`): add one line to `token-metering/README.md` there noting that copy is retained only to serve the frontend's e2e fixtures, superseded by `cairn-2.0`'s `tools/tokens/`. Leave for the user to action.

3. **`.gitmodules` stays** — `token-metering` remains, scoped to `frontend/` dev-time use only. Document that an installed-plugin checkout with the submodule absent/uninitialized is now fully supported (nothing at runtime reads there). Note: `.github/workflows/ci.yml`'s `actions/checkout@v4` doesn't set `submodules: true` today, so CI already runs every gate against exactly that condition — no CI change needed, and it's the closest thing to a standing regression check for this invariant.

## Scope

- New, tracked: `tools/tokens/{db.py,parser.py,pricing.py,prices.json,server.py,static/index.html,static/assets/*,test_db.py,test_parser.py,test_pricing.py,test_server.py}`
- Edited: `commands/cairn-tokens.md`, `hooks/stop-tokens.sh`, `docs/BUILD_BRIEF.md`, `docs/features/token-metering/ROADMAP.md`, `docs/features/token-metering/GOAL-CONDITION.md`, `.claude-plugin/plugin.json`, `CHANGELOG.md`, `docs/BUDGET.md` (regenerated)
- Untouched: `.gitmodules`, `token-metering/frontend/**`, `docs/REGISTRY.md` (no new agent); `ROADMAP.md`/`GOAL.md`/`GOAL-STATE.md` milestone-body text stays as historical record of the original submodule-based build
- Out of scope (scope record): `token-metering/frontend/` source/build tooling; Claude Code's own plugin-install submodule behavior

## Actionables

1. **Vendor the backend into `tools/tokens/`.** Copy byte-for-byte from the checked-out `token-metering/` submodule: `db.py`, `parser.py`, `pricing.py`, `prices.json`, `server.py`, `static/index.html`, `static/assets/index-B9Ghos6U.css`, `static/assets/index-CkyuEyo5.js`, `test_db.py`, `test_parser.py`, `test_pricing.py`, `test_server.py` — no content edits (Decision 1). Skip `README.md`/`CLAUDE.md`/`.harness/` — those are the submodule's own separate-repo governance; copying them would scatter a second `.harness/` this repo's architecture already avoids. Delete stale untracked `tools/tokens/__pycache__/` first.
   Same commit: regenerate `docs/BUDGET.md` (`python tools/budget.py --report`). One `CHANGELOG.md` entry; **no** `plugin.json` bump — nothing points at these files yet, so behavior is unchanged (mirrors the original 2026-08-28 "Inert until a hook writes to it — no version bump" entry).
   Gate: `python tools/budget.py` clean; `python -m pytest tools/` green — first time the vendored suite runs in this repo's own CI path.

2. **Repoint the two runtime references; cut the release.**
   - `commands/cairn-tokens.md` step 1: `${CLAUDE_PLUGIN_ROOT}/token-metering/server.py` → `${CLAUDE_PLUGIN_ROOT}/tools/tokens/server.py`.
   - `hooks/stop-tokens.sh`: the parser-invocation arg `"$pr/token-metering"` → `"$pr/tools/tokens"`; the `--selftest` block's `stub()` fabricated path `$1/token-metering/parser.py` → `$1/tools/tokens/parser.py`.
   - After this, `/cairn-tokens` has zero submodule dependency — `done_when`'s "no submodule-init step" holds.
   - Same commit: bump `.claude-plugin/plugin.json` `0.14.0` → `0.14.1` (**patch**, not minor — fixes a broken-install path dependency, no user-facing interface change; flagged in `STATE.md` as an unattended judgment call). One `CHANGELOG.md` entry under the existing `## 2026-09-01` header.
   - Gate: `hooks/stop-tokens.sh --selftest` passes; `python tools/budget.py` clean.

3. **Update docs** (docs-only, no version bump):
   - `docs/BUILD_BRIEF.md` §B10: rewrite the "**Amended:** implementation code (...) targets a separate `token-metering` git submodule, not `tools/tokens/`" paragraph to state: backend now lives at `tools/tokens/` in this repo; only `frontend/` + its Node/npm build stay in the `token-metering` submodule, maintainers-only; `tools/budget.py`'s walk + `pytest tools/` now cover `tools/tokens/`; an installed checkout with the submodule absent/uninitialized is fully supported. Also fix §B11's build-order line 2, which asserts the same stale claim.
   - `docs/features/token-metering/ROADMAP.md`: rewrite the header paragraph (the one starting "Implementation code (...) targets the `token-metering` git submodule... it doesn't run against the submodule") to match current reality. Leave M1–M6 milestone bodies as historical record; add one Status-section line noting the post-completion relocation to `tools/tokens/`, pointing at `docs/tasks/vendor-token-metering-backend/`.
   - `docs/features/token-metering/GOAL-CONDITION.md`: update the Invariants bullet "`tools/budget.py` covers only artifacts shipping from this repo... the submodule gates itself" to note it now also covers `tools/tokens/`.
   - Gate: `python tools/budget.py` clean.

4. **Full phase-gate**: `python tools/budget.py`; `python -m pytest tools/`; every `tools/**/*.sh --selftest`; `python tools/budget.py --report && tail -5 docs/BUDGET.md`. Fix any finding before proceeding.

5. **Review** — dispatch `cairn:reviewer` (not `review-pr`) against the full diff from Actionables 1–3. Fail → back to the relevant actionable.

6. **Manual check** — run `/cairn-tokens` against a checkout/worktree with the `token-metering` submodule left uninitialized, mirroring a fresh plugin install; confirm it starts and serves the dashboard purely from `tools/tokens/server.py`.

7. **PR** — the main thread opens it, scoped to Actionables 1–3's files. Never opened by `reviewer` or `builder`.

Optional, out of band (not required for `done_when`, separate repo): the Decision 2 README note in `cairn-2.0-token-metering`, once push access there is confirmed.

## Done when

`tools/tokens/{server.py,db.py,parser.py,pricing.py,prices.json,static/,test_*.py}` are regular tracked files in `cairn-2.0`, not submodule content; `/cairn-tokens` works with the submodule absent/uninitialized (Actionable 6); `docs/BUILD_BRIEF.md` + `ROADMAP.md` reflect the split (Actionable 3); `tools/budget.py`'s walk + `pytest tools/` cover the vendored files (Actionable 1). Actionable 7 (PR) is the session's stopping point.

Risks: the `plugin.json` patch-vs-minor bump size (Actionable 2) is a judgment call without a mechanical rule beyond "matching past bumps" — flagged in `STATE.md`'s `flags`, not guessed silently; reviewable/override-able before merge.
