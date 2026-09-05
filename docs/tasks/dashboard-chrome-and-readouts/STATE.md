---
goal: Restyle the dashboard's chrome & readouts — Header.tsx (instrument-window chrome, brand mark, install-scope toggle), Dashboard.tsx's top-of-page meter-box totals, WarningBanner.tsx (dashed signal-line border, signal-soft fill, mono code treatment), and EmptyState.tsx (dashed-border card, circular mono-glyph mark, numbered steps) — to DESIGN.md's vocabulary and Wave 1's token/primitive system, with no data-binding or behavior changes.
paths:
  - token-metering/frontend/src/components/Header.tsx
  - token-metering/frontend/src/Dashboard.tsx
  - token-metering/frontend/src/components/WarningBanner.tsx
  - token-metering/frontend/src/components/EmptyState.tsx
done_when: npm run build is clean inside token-metering/frontend/; npx playwright test is green (existing cold-start/populated e2e coverage re-run against new markup, extended only if a DESIGN.md device isn't yet exercised by an assertion); no file among these four references pre-Wave-1 tokens/fonts.
out_of_scope:
  - Dashboard.tsx's composed panels (charts, sessions — Waves 3-4)
  - Any prop or behavior change beyond the meter-row addition (install-scope toggle stays a static string)
  - mockups/dashboard.html (stays frozen)
  - Backend (tools/tokens/, token-metering's backend copy)
source: docs/features/token-metering-dashboard-ui/plans/02-chrome-and-readouts.md
path: escalated
phase: merged
key_info: cairn:reviewer PASSed on the third pass (base 4eeb88d, tip
  4667243, 7 commits) — full accumulated diff reviewed fresh, gates rerun
  clean (pytest 62, build clean, playwright 26/26), visual comparison
  against the frozen mockup confirmed correct with no regressions. 3 rounds
  of findings fixed across the wave: missing .window frame + formatCost
  null-coercion (commit 1de3374), chrome-bar flush-edge bleed (commit
  4667243). PR #7 merged 2026-09-04 via merge commit b84ad1d, branch
  wave-2-chrome-and-readouts deleted. Wave 2 closed.
flags:
  - "Dashboard.tsx is at frontend/src/Dashboard.tsx, not src/components/Dashboard.tsx (source plan/ROADMAP say the latter)."
  - "Install-scope toggle read as mockup review-harness only; no live toggle built, header caption stays a static string."
  - "frontend/.vite.dev-proxy.config.ts is an untracked scratch leftover in the worktree — delete before opening the PR, don't let it get swept into a commit."
---
