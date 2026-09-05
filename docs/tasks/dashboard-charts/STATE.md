---
goal: Restyle TokensPerDayPanel.tsx (graticule CartesianGrid + custom trace/tick Dot/Line renderers, customizing recharts rather than replacing it) and ActivityHeatmap.tsx (ink-scale intensity recolor per the Ink-Scale Data Rule) to DESIGN.md's Graticule Bar Charts vocabulary, with no data-binding or behavior changes.
paths:
  - token-metering/frontend/src/components/TokensPerDayPanel.tsx
  - token-metering/frontend/src/components/ActivityHeatmap.tsx
done_when: npm run build is clean inside token-metering/frontend/; npx playwright test is green (existing chart coverage — render, tooltip/hover, 15s live-poll update — re-run against new markup, extended with a graticule/trace-presence assertion if none exists today).
out_of_scope:
  - Replacing recharts with a bespoke SVG engine
  - Dashboard.tsx's chrome/readouts (Wave 2, merged) and sessions/drilldown (Wave 4)
  - mockups/dashboard.html (stays frozen)
  - Backend (tools/tokens/, token-metering's backend copy)
source: docs/features/token-metering-dashboard-ui/plans/03-charts.md
path: escalated
phase: merged
key_info: cairn:reviewer PASSed the diff (gates green - build clean,
  playwright 25/25, pytest 62/62; all design-fidelity checks confirmed:
  token cleanup, graticule/trace device, sparkline ComposedChart swap,
  ink-scale heatmap recolor). Actionable 8 (manual cairn:run check) done:
  seeded a populated scratch project, watched the 7D chart across a live
  15s poll cycle (confirmed via performance.getEntriesByType fetch
  timing) with a day selected - no flicker or break in the trace
  overlay/bars, selection persisted. PR #8
  (https://github.com/jisundr/cairn-2.0-token-metering/pull/8, branch
  wave-3-charts) opened, then required a merge with origin/main first -
  the branch predated Wave 2's merge (PR #7, commit b84ad1d), so the
  generated static/ dir conflicted (independently-rebuilt content-hashed
  filenames on both sides). Resolved via git rm -rf static + fresh npm
  run build from the merged tree (all frontend source files auto-merged
  cleanly, zero conflict markers) - commits a2cf3af (merge) and f475242
  (rebuilt static/), re-verified gates green post-merge (playwright
  26/26, pytest 62/62). PR #8 merged 2026-09-04 via merge commit
  4df7bed2, source branch wave-3-charts deleted. Built in worktree
  token-metering/.claude/worktrees/track-b.
flags:
  - "block-line token is undefined in index.css (Wave 1 didn't port it); plan swaps it for paper-line rather than adding it back (out of this wave's paths)."
  - "Chart-technique resolution (03-charts.md) read as scoped to where recharts already renders (sparkline); hourly/daily-click bars stay hand-rolled - see plan's Risks line."
  - "npm install had to be run fresh in the track-b worktree (frontend/node_modules wasn't present) before build/test would run - not a plan deviation, just worktree setup."
  - "impeccable hook flagged border-accent-on-rounded on the bar (rounded-t-[3px] + border-t-2); fixed to rounded-t-[1px] per DESIGN.md's 1px chart-element rule and the mockup's own border-radius: 1px (commit e8fa25c)."
---
