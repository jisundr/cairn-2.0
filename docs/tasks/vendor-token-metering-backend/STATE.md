---
goal: Vendor token-metering's backend runtime into cairn-2.0, dropping the submodule as a runtime dependency; frontend/ stays in the submodule as a dev-only build tool.
paths: [token-metering/, docs/BUILD_BRIEF.md, docs/features/token-metering/, commands/cairn-tokens.md, hooks/stop-tokens.sh, tools/budget.py, .gitmodules]
done_when: backend files (server.py, db.py, parser.py, pricing.py, prices.json, static/, tests) are regular tracked files in cairn-2.0, not submodule content; /cairn-tokens works with no submodule-init step; BUILD_BRIEF.md + ROADMAP.md reflect the split; tools/budget.py gates the vendored files.
out_of_scope: [token-metering/frontend/ source and its build tooling (stays in submodule), changing Claude Code's own plugin-install submodule behavior]
path: escalated
phase: reviewed
key_info: Actionables 1-6 done. Phase-gate green, reviewer PASS. Manual check: /cairn-tokens verified w/ submodule uninitialized. PR next.
flags:
  - "plugin.json bump: patch, not minor (unattended call)."
---
