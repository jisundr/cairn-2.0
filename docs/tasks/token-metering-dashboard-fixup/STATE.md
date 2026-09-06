---
goal: Fix dashboard vs DESIGN.md - drop bezel, real Dashboard/Sessions tabs, SessionDrilldown agent-select + chat-thread.
paths:
  - token-metering/frontend/src/{Dashboard.tsx,index.css,components/{Header.tsx,SessionDrilldown.tsx},api/hooks.ts}
  - token-metering/frontend/e2e/populated/dashboard.spec.ts
  - docs/features/token-metering-dashboard-ui/
  - tools/tokens/
done_when: build+playwright green; tools/tokens/ re-vendored; budget.py clean; pytest green.
out_of_scope: mockup frozen; CSS :target/:has()/:checked trick.
source: token-metering-dashboard-ui/{DESIGN.md,GOAL-CONDITION.md,mockups}
path: escalated
phase: gated
key_info: >
  Actionables 1-11 done+gated. Added session label (ai-title @ Stop-hook,
  short-id fallback) + fixed encode_project_path dot-vs-dash bug (blocked
  transcript lookup). Backend 78/78. tools/tokens/ re-vendored. budget.py
  now ignores node_modules, clean here. Remaining: reviewer, PR.
flags:
  - "chat-thread fetch volume at scale unverified by e2e."
---
