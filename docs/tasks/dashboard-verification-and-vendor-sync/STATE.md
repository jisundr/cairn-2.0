---
goal: Verify the token-metering dashboard port is complete (full gate + manual smoke test) and re-vendor tools/tokens/static/, closing out the token-metering-dashboard-ui feature.
paths:
  - token-metering/ (test_*.py, frontend/)
  - tools/tokens/static/
  - docs/features/token-metering-dashboard-ui/GOAL-CONDITION.md
done_when: pytest test_*.py and npm run build && npx playwright test green inside token-metering/ (both fixture states); tools/tokens/static/ re-vendored from a fresh build; python tools/budget.py clean in this repo; GOAL-CONDITION.md's Done-when checklist and Wave 5 gate checked off.
out_of_scope:
  - Any new component restyle (Waves 1-4 closed)
  - Fixing the pre-existing toFixed crash (logged Known issue, out of port per Invariants)
  - mockups/dashboard.html changes
source: docs/features/token-metering-dashboard-ui/plans/05-verification-and-vendor-sync.md
path: escalated
phase: done-pending-merge
key_info: Actionables 1-7 done. token-metering/ confirmed at origin/main tip
  e3cae6c (Waves 2-4 present). Gate green: pytest 62/62, build clean, playwright
  26/26 (one run flaked 2 tests on the stdlib server's BrokenPipeError under
  full-parallel load - isolated pass + clean rerun ruled out a regression).
  Manual smoke test (actionable 4) found nothing vs. all 4 review screenshots,
  so actionable 5 + submodule half of 9/10 are skipped. Re-vendored
  tools/tokens/static/ from a fresh build at e3cae6c (adds fonts/, new since
  the 2026-09-02 sync). budget.py clean re: this diff.
flags:
  - "Screenshot path corrected: docs/features/token-metering-dashboard-ui/.impeccable/review/, not token-metering/.impeccable/review/ (doesn't exist, confirmed via Glob)."
  - "GOAL-CONDITION.md's Wave 5 checkbox + Done-when checklist closure deferred until PR(s) merge, per GOAL.md's publish-vs-close model - not flipped at PR-open time."
  - "No cairn:reviewer/PR dispatch tool in this role - outer-repo commit made directly (workflow.md: direct commits to main, no PR); reviewer dispatch is the main thread's next step."
---
