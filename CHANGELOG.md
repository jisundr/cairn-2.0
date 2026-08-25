# Changelog

Reverse-chronological, one entry per artifact-commit (§A9). Never loaded by the model (§A4) — read by humans only.

## 2026-08-25

- Added `docs/registry.md` — the agent tool-justification registry, stub until Phase 8 adds the first agent.
- Added repo `CLAUDE.md` — operating guidance for building cairn itself.
- Added `.claude-plugin/marketplace.json` — this repo listed as its own marketplace, `source: "."`.
- Added `.claude-plugin/plugin.json` — the plugin manifest.
- Generated `docs/BUDGET.md` via `budget.py --report`.
- Added CI: run `budget.py` and `pytest` on push/PR.
- Added `tools/test_budget.py` — one unit test per `budget.py` rule.
- Added `tools/budget.py` — the budget gate (§A0).
- Added `.gitignore` for Python build artifacts.
- Added the cairn 2.0 build brief (`Cairn 2.0 build brief.md`) — the development contract and source of truth for this repo.
