# Changelog

Reverse-chronological, one entry per artifact-commit (§A9). Never loaded by the model (§A4) — read by humans only.

## 2026-08-25

- Regenerated `docs/BUDGET.md` to include `skills/scope/`.
- Added `skills/scope/SKILL.md` plus `reference/vague-request.md` and `reference/decomposition.md` — the `cairn:scope` resolution skill.
- CI: added `claude plugin validate .claude-plugin/plugin.json` (non-strict) — `validate . --strict` only checks the marketplace manifest, never descends into the plugin manifest, so component-level plugin checks were unexercised.
- Regenerated `docs/BUDGET.md` to include `skills/start/SKILL.md`.
- Added `skills/start/SKILL.md` — the `cairn:start` entry point: harness gate, scope-resolution trigger checklist, and path choice.
- Regenerated `docs/BUDGET.md` to reflect the final Phase 3 artifact set.
- Added `README.md` — install steps, both cost paths, load-class table, write allowlist.
- CI: added `claude plugin validate . --strict` and the `tools/**/*.sh --selftest` loop.
- Fixed `.claude-plugin/marketplace.json` — added the top-level `description` required by `claude plugin validate --strict`.
- Added `CODEOWNERS` — repo-root catch-all review gate.
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
