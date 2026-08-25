# Changelog

Reverse-chronological, one entry per artifact-commit (§A9). Never loaded by the model (§A4) — read by humans only.

## 2026-08-26

- Extended `skills/requirements/SKILL.md`: verify any file, function, or behavior the source material names against the codebase before writing Problem and Goals — a claim that doesn't hold goes under Constraints & assumptions as an open discrepancy, not into Problem as settled fact — and hand the written path back with an offer, not a trigger, to continue into planning, so the user can decline and stop at the task file. Spec at `docs/specs/task-file-intake.md` (gitignored, not committed).
- Wired `skills/scope/SKILL.md`'s default flow with a step 0: when a request points at an existing `docs/requirements/*.md` doc instead of describing the work directly, `goal`/`done_when` are read from its Goals/Success criteria and `paths` from what it names, rather than re-derived from the conversation. Also records the doc's path as a new optional `source` field on the scope record. Spec at `docs/specs/task-file-intake.md` (gitignored, not committed).

## 2026-08-25

- Amended `Cairn 2.0 build brief.md` §B10 — the token-metering report is now a live local dashboard (prebuilt React/Vite/Recharts/Tailwind/shadcn/`@tanstack/react-query` frontend served as static assets by a Python stdlib server), replacing the original "self-contained HTML file — no server, no CDN" line. Node/npm stays a cairn-dev-time-only build step. Full spec at `docs/requirements/token-metering.md`.
- Added `docs/requirements/token-metering.md` — the Phase 2 token-metering & dashboard requirements doc, using `cairn:requirements`'s extended structure. Covers the SQLite capture design from build brief §B10's four gotchas (requestId dedup, full-rescan idempotency, usage-limit-event separation, read-time pricing) plus the live-dashboard architecture decided in this session: per-session view as a call-by-call trace nested under each agent's rollup, checked-in price-table data file, polling-plus-manual refresh, and `/cairn-tokens` auto-opening the browser.
- Regenerated `docs/BUDGET.md` to reflect the requirements-doc extension and the planner/start approval-checkpoint changes. Always-loaded frontmatter total now 2019 B / 3000 B.
- Wired `skills/start/SKILL.md`'s escalated-path row to an approval checkpoint — the flow now reads `planner` → approval → `builder`, so the main thread pauses on `planner`'s plan before dispatching `builder` rather than dispatching automatically. Rejection falls under the existing scope-resolution rules (invalidate-and-re-resolve, or amend-and-continue) rather than new dedicated prose — the file had 4 B of headroom under its 3000 B soft cap, so the checkpoint had to be captured in the table alone. Spec at `docs/specs/planner-plan-writing-upgrade.md` (gitignored, not committed).
- Added a self-review step to `agents/planner.md`: after drafting the plan, `planner` now re-reads it against the scope record's `done_when` and actionable list, fixing anything vague enough that `builder` would have to guess, and adds an optional `Risks:` line only when a genuine risk turns up. Synthesized from maestro's `task-orchestrator` Plan Mode, superpowers' `writing-plans`, and Claude Code's native Plan Mode — adopting self-review, optional risk notes, and the approval gate above while rejecting parallel sub-agent assessment, per-agent scope breakdown, and embedded code as incompatible with cairn's 4-agent cap and 12,288 B plan-file cap. Spec at `docs/specs/planner-plan-writing-upgrade.md` (gitignored, not committed).
- Extended `skills/requirements/SKILL.md` with three optional sections — Stakeholders, Constraints & assumptions, Open questions — closing the gap against a heavier reference format (a separate multi-document requirements pipeline) without adopting its tiering, gates, or versioning. Governed by the file's existing "omit, don't placeholder" rule. Spec at `docs/specs/requirements-doc-structure.md` (gitignored, not committed).

- Wired `skills/scope/reference/vague-request.md` to escalate into `cairn:brainstorm` when `goal` still isn't nameable after the narrow questions — a new project, a subsystem with no existing flow, or an unformed idea.

- Added `skills/brainstorm/SKILL.md` — the `cairn:brainstorm` skill: clarifies an idea too unformed for `cairn:scope`'s narrow questions, weighs approaches only when a genuine choice exists, and recommends a `scribe` doc type without writing it. Not a 5th agent — `AskUserQuestion` needs the main thread, and §B4/§B5 cap agents at 4.

- Tightened `skills/start/SKILL.md`'s local-preferences dispatch rule: it said dispatch prompts must never carry "the file," which left room to instead name the file's *path* in a "don't read this" reminder — exactly what happened during live testing, where a dispatching session added `.harness/local/preferences.md`'s literal path to nested agents' briefs. Now explicit that dispatch prompts must never name the file or its path, since each agent's own brief already forbids reading it. Found via live acceptance testing of §B12 criteria 7–16.

- Fixed `commands/cairn-doctor.md`'s local-layer ceiling check: it only compared a local preference line against the four team harness files, so `optional-pass reviewer off` (or `builder off`) classified as merely **active** instead of **ignored by ceiling**, even though both stages run in every cairn path (§B12 default and escalated) and `reviewer`'s lack of `Write`/`Edit` exists specifically so it can't be bypassed. The ceiling check now also catches a line disabling either stage. Found via live acceptance testing of §B12 criteria 7–16.

- Fixed `tools/budget.py`'s `harness-file` cap check: it applied a uniform 40/60-line cap to every `.harness/*.md` file, contradicting the build brief's differentiated caps (`architecture.md` 40, `standards.md` 40, `environment.md` 30, `workflow.md` 30, per §B3d) and `cairn-setup.md`'s documented "cap (40/40/30/30)". Each of the four files is now checked against its own cap; unrecognised `.harness/*.md` files keep the prior 60-line fallback. Found via live acceptance testing of §B12 criteria 7–16.

- Regenerated `docs/BUDGET.md` to include `hooks/` and `commands/cairn-doctor.md`. Always-loaded frontmatter total now 1734 B / 3000 B — 1598 B carried in, plus 136 B for `cairn-doctor`'s description (`hooks/*` is executed-class, contributing nothing to the always-loaded total).

- Added `commands/cairn-doctor.md` — read-only diagnostic: plugin version, marker/harness/`.cairn/` state, and the local layer line by line (active / inert-no-lever / ignored-by-ceiling / unrecognised) — the only place an ignored local preference is ever surfaced (§B3e). `/cairn-tokens` intentionally not built this phase: it depends entirely on the still-deferred Phase 2 token-metering system; raised to the user, who chose to skip it until Phase 2 is explicitly requested.

- Added `hooks/hooks.json` + `hooks/session-start.sh`, wired via `.claude-plugin/plugin.json`'s new `hooks` field — the advisory `SessionStart` hook (§B10): a structural self-check (`jq`, session id, marker block, `.cairn/` writable) gating one version-log line to `.cairn/sessions.log`. Exits 0 on every path, no stdout ever. Manually verified all three named degrade cases (no `jq`, no session id, no marker block) plus the happy path.

- Regenerated `docs/BUDGET.md` to include the four Phase 9 skills. Always-loaded frontmatter total now 1598 B / 3000 B — 1055 B carried in, plus 127+132+156+128 B across `shared`/`requirements`/`spec`/`readme`'s descriptions.
- Added `skills/readme/SKILL.md` — the `cairn:readme` document-type skill `scribe` loads for READMEs, always written under `docs/` since the project root is outside scribe's scope. All four Phase 9 "remaining skills" now built.
- Added `skills/spec/SKILL.md` — the `cairn:spec` document-type skill `scribe` loads for design/spec docs.
- Added `skills/requirements/SKILL.md` — the `cairn:requirements` document-type skill `scribe` loads for requirements docs (§B5: "requirements, specs, READMEs — via skills").
- Added `skills/shared/SKILL.md` — the `cairn:shared` skill, centralizing STATE.md conventions and the verification-command-running mechanics that `planner`/`builder`/`reviewer` already referenced in Phase 8. First of the Phase 9 "remaining skills."
- Regenerated `docs/BUDGET.md` after the `builder.md` fix — only its own self-measured size shifted; always-loaded total unchanged at 1055 B.
- Regenerated `docs/BUDGET.md` to include the four agents. Always-loaded frontmatter total now 1055 B / 3000 B — 547 B carried in, plus 120+132+126+130 B across `scribe`/`reviewer`/`builder`/`planner`'s descriptions.
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
