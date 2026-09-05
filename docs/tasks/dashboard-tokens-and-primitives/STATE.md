---
goal: Replace the old token system (--paper, --paper-line, --ink, --ink-soft, --graphite, --block, --block-line, --window, --blue, --blue-soft, --flag, --flag-soft; Archivo, Space Mono) in token-metering/frontend/src/ with DESIGN.md's new scale (bone/bone-dim/window/block, ink/ink-soft/ink-faint, signal/signal-soft/signal-line, --ch1–--ch4) and self-hosted Big Shoulders/Public Sans/Martian Mono fonts, and restyle the four shared ui/ primitives (button.tsx, badge.tsx, panel.tsx, tabs.tsx) to the new corner-radius range, hairline borders, and Bezel-Not-Shadow elevation — no prop or behavior changes.
paths:
  - token-metering/frontend/src/index.css
  - token-metering/frontend/public/fonts/ (new)
  - token-metering/frontend/src/components/ui/button.tsx
  - token-metering/frontend/src/components/ui/badge.tsx
  - token-metering/frontend/src/components/ui/panel.tsx
  - token-metering/frontend/src/components/ui/tabs.tsx
  - Tailwind v4 @theme mapping (in index.css or wherever this project's CSS-first config lives)
done_when: npm run build is clean inside token-metering/frontend/; npx playwright test is green (zero test-behavior change expected, only unasserted visuals); no file under the touched paths references --paper, --blue, --flag, --graphite, Archivo, or Space Mono.
out_of_scope:
  - Any component outside the four ui/ primitives and index.css
  - Prop or behavior changes to the ui/ primitives
  - mockups/dashboard.html (stays frozen)
  - Backend (tools/tokens/, token-metering's backend copy)
  - State management, routing.ts, api/hooks.ts, api/client.ts
source: docs/features/token-metering-dashboard-ui/plans/01-tokens-and-primitives.md
path: escalated
phase: merged
key_info: Implemented (commits bc1fcbe, a54f58d, 64a51b8, c789fa9 on branch wave-1-tokens-and-primitives, rebased onto main), gated (build/playwright/pytest all green), manually checked, reviewed (pass, no blocking findings). Merged via PR #6 (https://github.com/jisundr/cairn-2.0-token-metering/pull/6), merge commit 4eeb88d, 2026-09-04.
flags:
  - "badge.tsx reassigned to mockup's circular/mono .badge (not label face) — inferred from its sole numeric-count consumer, not literal in DESIGN.md prose."
---
