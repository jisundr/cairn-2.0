# Plan — Track A / Wave 5: verification & vendor sync

Closing wave — no component restyle. Confirms Waves 1-4's port is complete against real usage
and syncs `tools/tokens/static/`'s vendored copy to the finished build. Source plan (steps
already resolved, carried forward, not re-litigated):
`docs/features/token-metering-dashboard-ui/plans/05-verification-and-vendor-sync.md`.
Screenshots for the manual check actually live at
`docs/features/token-metering-dashboard-ui/.impeccable/review/{desktop,mobile,
sessions-interaction,empty-state}.png` (confirmed via `Glob` — corrects the scope record's
`token-metering/.impeccable/review/...` shorthand, which doesn't exist).

Worktree/branch: Track A's and B's worktrees
(`token-metering/.claude/worktrees/{track-a,track-b}`) were both torn down after Waves 2/3/4
merged (per `GOAL-CONDITION.md`'s Current status). Running the gate and rebuilding `static/`
needs no branch — both run against `token-metering`'s checkout at the merged `origin/main` tip.
A worktree/branch is only created (Actionable 5) if the manual smoke test (Actionable 4)
surfaces a regression needing a fix. The re-vendor commit (Actionable 6) lands directly in this
outer repo's own working tree, never in a submodule worktree.

## Scope (paths)

- `token-metering/` — `test_*.py` and `frontend/` (run only, no edits expected, unless
  Actionable 5 fires)
- `tools/tokens/static/` in this repo — re-vendored file-for-file from `token-metering/static/`
  (the build's `outDir`, per `frontend/vite.config.ts`): `index.html`, `assets/*.css`,
  `assets/*.js`, `fonts/*.woff2` — whatever the rebuild actually produces
- `docs/features/token-metering-dashboard-ui/GOAL-CONDITION.md` — Wave 5's checkbox in the
  Per-wave gate table, all 5 items in Done when, a closing Current-status paragraph
- `CHANGELOG.md` — one entry for the re-vendor commit

Out of scope (scope record): any new component restyle; fixing the pre-existing `toFixed`
crash (`SessionDrilldown`, logged in `GOAL-CONDITION.md`'s Known issues, out of this port per
its Invariants); `mockups/dashboard.html`.

## Actionables

1. **Confirm the merged state**: `token-metering/` checked out at `origin/main`'s tip, with
   Waves 2 (chrome & readouts), 3 (charts), and 4 (sessions & drilldown) all present — per
   `GOAL-CONDITION.md`'s Current status (merge commits `b84ad1d`, `4df7bed2`, `e3cae6c`).

2. **Run the full gate** inside `token-metering/`:
   - `pytest test_*.py` — confirms the untouched backend stays green.
   - `npm run build && npx playwright test` inside `frontend/`, full suite, both fixture
     states (`populated`, `cold-start`) — confirms nothing in Waves 2-4 regressed another
     wave's surface.

3. **Confirm tests** — no new automated cases expected from this actionable; only Actionable 4
   (the manual check) can surface a gap Waves 2-4's coverage missed.

4. **Manual smoke test** (`cairn:run`), covering `requirements.md`'s Success criterion 5 in
   full — the mockup review's own evidence set, now exercised live instead of statically:
   - Cold-start/empty project — compare against `empty-state.png`.
   - Populated project — compare against `desktop.png` (and `mobile.png` for the responsive
     layout).
   - A session mid-usage-limit warning — compare against the warning-banner treatment shown
     in the review evidence.
   - An agent-select interaction in the drilldown — compare against `sessions-interaction.png`.

5. **Branch and fix, only if Actionable 4 finds a regression**: create
   `token-metering/.claude/worktrees/track-a`, fresh branch
   `wave-5-verification-and-vendor-sync` off updated `origin/main`; fix the regression there,
   add the Playwright case Actionable 4 exposed a gap in, re-run Actionable 2's gate until
   green. If Actionable 4 finds nothing, skip this actionable and Actionable 9's submodule PR
   entirely.

6. **Re-vendor `tools/tokens/static/`**: rebuild `frontend/`'s `static/` via `npm run build`
   (from Actionable 5's fix branch if one exists, otherwise from the merged `origin/main` tip —
   the final, fully-integrated state either way), then copy it into this repo's
   `tools/tokens/static/`, mirroring commit `54b2c31`'s convention: same source
   (`token-metering/static/`) → destination (`tools/tokens/static/`) mapping, byte-for-byte
   copy, no content edits. One commit; one `CHANGELOG.md` entry; no `plugin.json` version bump
   (asset sync, not a plugin capability change — matching the 2026-09-02 re-vendor precedent's
   own reasoning).

7. **Gate the re-vendor commit** — `python tools/budget.py` clean, in this repo.

8. **Close out `GOAL-CONDITION.md`**, once this wave's PR(s) (Actionable 10) have actually
   merged — this project's own `GOAL.md` treats "PR opened" and "wave closed" as separate
   session boundaries (merge is async), so don't flip these at PR-open time:
   - Flip Wave 5's checkbox in the Per-wave gate table.
   - Check off all 5 items in the Done when section.
   - Add a Current-status paragraph closing the wave (mirroring Waves 1-4's own entries),
     noting the port itself is now complete.

9. **Review** — `cairn:reviewer` against each diff separately: any submodule-side fix from
   Actionable 5 (if one exists), scoped to `token-metering`; the re-vendor + `CHANGELOG.md`
   commits, scoped to this outer repo.

10. **PR** — two, opened separately, never combined: the submodule-side fix (only if
    Actionable 5 produced one) inside `token-metering`; the re-vendor commit in this repo. If
    Actionable 4 found nothing to fix, only the outer-repo PR is needed.

## Done when

`pytest test_*.py` and `npm run build && npx playwright test` green inside `token-metering/`
(both fixture states); `tools/tokens/static/` re-vendored from a fresh build; `python
tools/budget.py` clean in this repo; `GOAL-CONDITION.md`'s Done-when checklist and Wave 5 gate
checked off (Actionable 8, once merge is confirmed).

## Risks

- Actionable 8 can only truthfully run once both PRs (or the one, if no fix was needed) have
  merged. If this task's session ends at PR-open (Actionable 10) with no merge yet, Actionable
  8 doesn't run in this session — leave `STATE.md`'s `key_info` noting the PR(s) as open,
  matching Wave 4's own precedent (commit `788a999`), and close out `GOAL-CONDITION.md` in a
  follow-up session once merge is confirmed.
