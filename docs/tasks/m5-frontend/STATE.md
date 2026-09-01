---
goal: Build token-metering dashboard frontend matching mockups/dashboard.html, with Playwright e2e against the built static bundle.
paths: [token-metering/frontend/, token-metering/static/, token-metering/frontend/e2e/, token-metering/frontend/playwright.config.ts, token-metering/.harness/workflow.md]
done_when: npm run build regenerates static/; npx playwright test green covering every dashboard.html state plus the /call/<session>/<n> deep-link route.
out_of_scope: [server.py/API changes (M4, merged), commands/cairn-tokens.md (M6), 15s-poll timing check (manual)]
source: docs/features/token-metering/plans/m5-frontend.md
path: escalated
phase: built
key_info: Actionables 1-8 built & green (build, 13 playwright, 52 pytest). HOME risk confirmed fine.
flags:
  - "2 webServer instances - one db can't show populated+missing states."
  - "environment.md's node check stays warning-level, outside scope."
  - "Fixed: drilldown used per-agent position for call_detail's n; ProjectsPanel totals client-derived."
---
