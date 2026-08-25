# Changelog

Reverse-chronological, one entry per artifact-commit (§A9). Never loaded by the model (§A4) — read by humans only.

## 2026-08-25

- Added `agents/planner.md` — the fourth and final §B5 agent (`Read, Glob, Grep, Write, AskUserQuestion, Skill`), escalated path only. Owns `docs/tasks/<slug>/`: a plan that references paths and contracts rather than embedding file bodies, plus `STATE.md`. All four agents built; `docs/registry.md` fully populated.
- Added `agents/builder.md` — writes code and its tests in one context (`Read, Glob, Grep, Write, Edit, Bash, Skill`), the only agent that edits application code. No test/prod split across two agents.
- Added `agents/reviewer.md` — reviews the diff only and reruns the harness's own verification commands (`Read, Glob, Grep, Bash, Skill`); no `Write`/`Edit`, enforced by omission, so it cannot alter what it reviews. Hands back pass/fail to the main thread, which opens the PR itself.
- Added `agents/scribe.md` — the document-authorship agent (`Read, Glob, Grep, Write, Edit, AskUserQuestion, Skill`), scoped to `docs/` and only what's asked. `docs/registry.md` now carries its tool justifications, no longer a stub.
- Regenerated `docs/BUDGET.md` — `commands/cairn-setup.md` grew (new step 6) but its trimmed `description` field shrank the always-loaded total to 547 B.
- Amended `Cairn 2.0 build brief.md` (§B2b, §B3d) and `commands/cairn-setup.md` — `/cairn-setup` now writes `.harness/BUDGET.md`, a committed line-count-vs-cap ledger for the four team harness files, regenerated every run and never read back by cairn.

- Regenerated `docs/BUDGET.md` to include `commands/` and `skills/task-assets/assets/claude-md-marker.md`.
- Added `commands/cairn-setup.md` (default + `--local` modes) and `commands/cairn-teardown.md`, plus `skills/task-assets/assets/claude-md-marker.md` — the exact `CLAUDE.md` marker block cairn-setup reads and inserts. Manually verified the install → teardown → `git status` cycle in a scratch repo.
- Regenerated `docs/BUDGET.md` to include `skills/task-assets/assets/`.
- Added `skills/task-assets/assets/` — the five `.harness/` templates (`architecture.md`, `standards.md`, `environment.md`, `workflow.md`, `local/preferences.md`), each carrying its precedence-ceiling header line. Asset bundle read by path, never invoked — no `SKILL.md`.
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
