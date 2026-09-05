---
goal: Restyle SessionsTable/SessionDrilldown/HbarList/ProjectsPanel/CallPage/TraceDrawer/TraceDetailContent.tsx to DESIGN.md's Session List/Drilldown + Meter/Progress Bars vocabulary; update 2 stale-token spec assertions.
paths:
  - token-metering/frontend/src/components/SessionsTable.tsx
  - token-metering/frontend/src/components/SessionDrilldown.tsx
  - token-metering/frontend/src/components/HbarList.tsx
  - token-metering/frontend/src/components/ProjectsPanel.tsx
  - token-metering/frontend/src/components/CallPage.tsx
  - token-metering/frontend/src/components/TraceDrawer.tsx
  - token-metering/frontend/src/components/TraceDetailContent.tsx
  - token-metering/frontend/e2e/populated/dashboard.spec.ts
done_when: npm run build clean in frontend/; npx playwright test green incl. updated range-tab assertions at dashboard.spec.ts:41,45.
out_of_scope:
  - SessionDrilldown.tsx sort/ordering (global_position)
  - mockups/dashboard.html, backend (tools/tokens/)
  - state/routing/data-fetching, index.css
source: docs/features/token-metering-dashboard-ui/plans/04-sessions-and-drilldown.md
path: escalated
phase: merged
key_info: Plan at docs/tasks/dashboard-sessions-and-drilldown/plan.md, 13 actionables,
  all complete. Worktree track-b, branch wave-4-sessions-and-drilldown off
  origin/main. Gates green (build clean, playwright 26/26, pytest 62/62);
  cairn:reviewer PASSed on the first round. Manual check done against
  e2e-session-main (default selection, non-dominant agent-row expand, trace
  drawer for an available and an unavailable transcript) - e2e-session-other
  was avoided because selecting it hits the pre-existing toFixed crash logged
  in GOAL-CONDITION.md's Known issues (out of this wave's scope). PR #9
  (https://github.com/jisundr/cairn-2.0-token-metering/pull/9) merged
  2026-09-05 via merge commit e3cae6c, source branch deleted. Wave 4 closed.
flags:
  - "Stale tokens (--blue/-soft,--flag,--block-line,--paper,--graphite) absent from index.css; mapped per-site to current tokens, index.css untouched (out of scope)."
  - "--ch1-soft (chat-thread response bubble) also absent; --bone-dim substituted in TraceDetailContent."
  - "CallPage/TraceDrawer nav links mapped to --ink-soft not --signal (One Signal Rule bars signal on at-rest chrome)."
  - "Mockup's always-visible multi-turn chat-thread not ported (its :has()-CSS mechanism is a non-goal); bubble styling applied only to TraceDetailContent's per-call pair."
  - "TraceDrawer's diffuse box-shadow dropped per Bezel-Not-Shadow Rule; border+window substituted."
---
