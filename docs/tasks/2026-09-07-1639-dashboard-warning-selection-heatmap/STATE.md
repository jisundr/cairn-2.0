---
goal: Fix warning icon, focus-ring artifact, activity cadence, session-list
  indicator; redesign session drilldown (share bar, virtualized, full-page).
paths:
  - token-metering/frontend/src/components/
  - token-metering/frontend/src/Dashboard.tsx
  - token-metering/frontend/src/index.css
  - token-metering/frontend/package.json
done_when: requirements.md items 1-5 (5a-5d) verified in browser; no open
  questions remain.
out_of_scope:
  - server.py/db.py/parser.py
  - routing library (5d uses native History API)
  - tools/tokens/static/ (re-vendor is separate)
source: requirements.md
path: escalated
phase: merged
key_info: PR cairn-2.0-token-metering#13 squash-merged (5e6f0e4), branch
  deleted, worktree removed. cairn-2.0's submodule pointer not yet bumped -
  out of scope here (re-vendor is separate, see out_of_scope).
flags:
  - "5d keeps Header/tab-bar chrome, not fully chrome-less - see plan.md Risks."
  - "Row click still selects+navigates in one click - see plan.md Risks."
---
