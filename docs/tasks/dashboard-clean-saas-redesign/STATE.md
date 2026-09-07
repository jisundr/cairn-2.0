---
goal: Replace the dashboard's "Bench Scope" system with clean minimal
  SaaS; fix tab routing, chart tooltips, drilldown progress bar.
paths:
  - token-metering/frontend/src
  - docs/DESIGN.md
done_when: New system applied; tabs/tooltips/drilldown fixed;
  pytest/build/playwright green; re-vendored into tools/tokens/static/.
out_of_scope:
  - capture pipeline (db.py/parser.py/pricing.py)
  - mockups/dashboard.html (frozen reference)
source: docs/tasks/dashboard-clean-saas-redesign/requirements.md
path: escalated
phase: build-reviewed
key_info: Impeccable build + finish-review fixes done, pytest/build/
  playwright green. Next: documenter rewrites DESIGN.md.
flags: []
---
