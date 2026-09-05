---
goal: Verify the token-metering dashboard port and re-vendor tools/tokens/static/, closing out token-metering-dashboard-ui.
paths:
  - token-metering/ (test_*.py, frontend/)
  - tools/tokens/static/
  - docs/features/token-metering-dashboard-ui/GOAL-CONDITION.md
done_when: pytest/build/playwright green in token-metering/; tools/tokens/static/ re-vendored; budget.py clean; GOAL-CONDITION.md checklist + Wave 5 checked off.
out_of_scope:
  - New component restyle
  - Pre-existing toFixed crash (logged)
  - mockups/dashboard.html changes
source: docs/features/token-metering-dashboard-ui/plans/05-verification-and-vendor-sync.md
path: escalated
phase: done-pending-merge
key_info: Actionables 1-7 done at e3cae6c. Gate green - pytest 62/62, build
  clean, playwright 26/26 (1 flaky rerun, no regression). Smoke test matched
  screenshots; actionable 5 + 9/10 submodule skipped. Re-vendored
  tools/tokens/static/. budget.py clean.
flags:
  - "GOAL-CONDITION.md closeout deferred to follow-up session."
---
