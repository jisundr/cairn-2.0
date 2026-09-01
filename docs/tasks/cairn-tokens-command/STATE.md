---
goal: Add commands/cairn-tokens.md — starts token-metering/server.py in background, opens browser to dashboard.
paths: [commands/cairn-tokens.md]
done_when: M6 gate (full §A13 + relevant §B12) passes; manual e2e (session w/ subagent -> Stop -> /cairn-tokens -> rollups/trace/banner/idempotency) succeeds.
out_of_scope: [token-metering submodule changes (server.py/frontend already built)]
source: docs/features/token-metering/plans/m6-cairn-tokens-command.md
path: escalated
phase: built
key_info: Actionables 1-4,7 done. Gate passes. Step 1 uses python3 -u so run_in_background captures the readiness line. Actionable 4 verified via live API (rollup/trace/idempotency/banner). Uncommitted.
flags:
  - "Step 1 needs python3 -u or readiness line never appears over run_in_background."
  - "B12 #26 superseded by live-server amendment; verified via http://."
  - "No browser-open visual check this session (no Claude-in-Chrome) — same gap as M5."
---
