---
goal: Fix WCAG-failing tokens; redesign drilldown as a turn-grouped chat
  thread with inline tool actions; remove "view full detail" entirely.
paths:
  - token-metering/frontend/src/index.css
  - token-metering/frontend/src/components/SessionDrilldown.tsx
  - token-metering/server.py
  - docs/DESIGN.md
done_when: tokens clear 4.5:1 (script-verified); one prompt/turn + inline
  tool actions, no blank bubbles; view-full-detail gone, endpoint kept;
  pytest/build/playwright green; re-vendored.
out_of_scope:
  - Bench Scope layout rework; pricing/parser/db.py + SQLite schema; new
    deep-link mechanism
source: docs/tasks/2026-09-07-0701-dashboard-contrast-and-transcript/requirements.md
path: escalated
phase: planned
key_info: requirements.md settled; supersedes plan.md's server.py-unchanged
  Actionable 5.
flags:
  - Client-side dedup (prior plan) replaced by tool_calls field.
  - Tool-name-to-summary mapping is this plan's choice, unreviewed.
---
