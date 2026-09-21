# cairn 2.0 — portfolio case study

External-evaluation material for cairn 2.0. Every claim below traces to a file, commit, or number already in this repo — see the pointer in parentheses after each one. Not committed as part of cairn's shipped surface; see `docs/tasks/2026-09-11-0759-portfolio-interview-docs/requirements.md` for why.

## What it is

cairn is a Claude Code plugin that gives a software project a governed AI development workflow — a fixed `builder → reviewer` pipeline (with an opt-in `planner` and `scribe`), run under a disclosed, enforced token budget, that reads a project's own rules instead of imposing its own conventions, and that can be removed without a trace (`README.md`). It ships as a single plugin (~192 commits at this writing, `git log`) at version `0.14.5` (`.claude-plugin/plugin.json`), plus a bundled sub-application — a local token-usage metering dashboard (`token-metering/`, `tools/tokens/`) — with its own Python backend, frontend, and test suite.

## Role classification

**Primary: AI/Agentic Systems Engineering.** The core of this project is a multi-agent pipeline where correctness comes from *structural* constraints, not prompting: each agent's tool grants are least-privilege and enforced by an automated gate (`tools/budget.py`, 421 lines + `tools/test_budget.py`) that fails the build if an agent's frontmatter grants a tool `docs/REGISTRY.md` doesn't justify, or if an agent whose name/description reads as a reviewer (`review`, `audit`, `check`) is ever granted `Write`/`Edit` (`docs/REGISTRY.md`). Three "attendance postures" (interactive, attended, unattended) run the *same* chain, with unattended mode required to stop at one of three typed terminal states (`done`/`needs-human`/`stalled`) written into a resumable `STATE.md` rather than either hanging or guessing silently (`README.md`, `skills/start/reference/unattended.md`).

**Strong secondary: Platform/Developer Experience Engineering.** The plugin enforces a non-invasiveness contract on every project it's installed into — a fixed, disclosed write-allowlist (a `CLAUDE.md` marker block, `.harness/*.md`, `.cairn/`, and only the files a task actually asks it to change) with an explicit "never written" list (`.claude/settings.json`, agents/skills/commands/hooks directories, CI config, lockfiles, `.git/` internals) and a teardown command that reports exactly what it leaves behind (`README.md`). The repo enforces its own architecture the same way it enforces the plugin's contract: `tools/budget.py` measures every artifact against a load-class budget (`docs/BUDGET.md`) and a size cap, and CI runs both that gate and a byte-for-byte vendoring-drift check (`.github/workflows/ci.yml`, `tools/tokens/check_vendoring_sync.py`) on every change.

**Supporting: Full-Stack.** `token-metering/` is a complete secondary application — a stdlib-only Python backend (`server.py`, 36 KB; SQLite via `db.py`; a usage parser and pricing engine) and a React frontend, both vendored byte-for-byte into `tools/tokens/` so a plugin install works even when `/plugin install` doesn't recurse git submodules (`CHANGELOG.md`, 2026-09-01). It has its own test suite (`test_server.py`, 22 KB; `test_db.py`; `test_parser.py`; `test_pricing.py`) including timezone-correctness Playwright coverage (fixed-timezone, DST spring-forward, DST fall-back, local-calendar-day-crossing cases — `CHANGELOG.md`, 2026-09-02).

## Design decisions and tradeoffs

**Rewriting for a token budget, not just features.** cairn 2.0 is a ground-up rewrite of a predecessor whose own measured footprint had grown to 18 agents (278 KB) and 10 skills (87 KB), with 200–400k tokens spent per feature. The rewrite's explicit goal was a *provable*, not asserted, cost: 4 agents (5.5 KB), 10 skills (14.6 KB), a ~800-token baseline before a user types anything, and a disclosed ceiling of ≤40k tokens for the default path / ≤150k for the escalated path (`docs/PRODUCT.md`, Evidence on Hand). Two other (unnamed, private) agent frameworks were evaluated during the redesign for comparison: one ran ~52k baseline tokens and 0.7–1.5M+ tokens for a single medium feature, driven by a large always-loaded registry and 10+ agent hops per task; the other showed a ~1–2k baseline was achievable, but only by giving up nearly all enforcement (no CI, no blocking checks) — informing cairn's own choice to keep the gate rather than trade it away for a lower floor (`docs/PRODUCT.md`).

**A caught security/trust bug, not a hypothetical one.** The `review-pr` skill's re-review step called `code-review --comment`, which posts findings to a live PR/MR immediately — before the skill's own confirmation gate was ever reached. This meant the confirmation step was structurally unreachable for anything `code-review` posted, and it wasn't caught in design or in normal use — it was live-observed as a findings comment landing on a real MR with no prompt (GitHub issue #4). The fix separated concerns cleanly: `code-review` now runs draft-only (no `--comment`), and the skill posts directly via `gh`/`glab` itself, after confirmation, matching how its own summary comment was already posted (`CHANGELOG.md`, 2026-09-10). The lesson generalized past this one bug: a confirmation gate is only real if nothing upstream of it can perform the gated action on its own.

**A deliberate, cited scope loss.** `docs/BUILD_BRIEF.md` (671 lines, the project's original build spec) was retired only after an audit confirmed everything it specified was already built and gate-passing; its remaining process rules were folded into `.harness/standards.md`, and a stale, silently-broken phase-gate command it had originated (a glob that matched zero files) was fixed in the same pass. Part of the original document — its design rationale and non-goals — had no other home in the repo and was not preserved beyond what `docs/REGISTRY.md`/`.harness/architecture.md` already capture. That loss was written down as accepted, not treated as an oversight to silently absorb (`CHANGELOG.md`, 2026-09-09).

**Consistency across a submodule and a public-repo copy.** The token-metering backend is developed in its own submodule but vendored as a byte-for-byte copy into `tools/tokens/` (a fresh `/plugin install` doesn't reliably recurse git submodules — anthropics/claude-code#17293). That created a real drift risk: two copies of the same nine files that could silently disagree. The fix wasn't a manual-sync convention — it's a standalone script (`check_vendoring_sync.py`) wired into its own CI job with an independent submodule checkout, so a mismatch fails the build rather than surfacing as a runtime bug later (`CHANGELOG.md`, 2026-09-02).

**Governance discipline that survives founder-forgetting.** The per-commit rule bumping `.claude-plugin/plugin.json`'s version was itself revised mid-project: an early rule ("bump only for behavior-affecting changes") left every docs-only commit invisible to already-installed consumers, since a plugin install re-syncs on version change, not content diff. The rule was changed to "bump on every commit, docs-only included," closing a gap that had already silently affected real merged commits (landing page, README, brief retirement, `.gitignore` hardening) before it was caught (`CHANGELOG.md`, 2026-09-09).

## Measured results

| Metric | Before | After | Source |
|---|---|---|---|
| Agent count / size | 18 agents, 278 KB | 4 agents, 5.5 KB | `docs/PRODUCT.md` |
| Skill count / size | 10 skills, 87 KB | 10 skills, 14.6 KB | `docs/PRODUCT.md` |
| Baseline tokens (before any work) | ~9k | ~800 | `docs/PRODUCT.md` |
| Tokens per feature | 200–400k | ≤40k default / ≤150k escalated | `docs/PRODUCT.md` |
| Repo maturity | — | 0.14.5, ~192 commits, docs-only version bumps included | `.claude-plugin/plugin.json`, `git log`, `CHANGELOG.md` |

## Resume / LinkedIn copy

- Designed and shipped a governed multi-agent development workflow (Claude Code plugin) enforcing least-privilege tool grants and load-class token budgets via a custom static-analysis gate that fails CI on violation.
- Rewrote a prior agent framework to cut baseline token overhead ~10x (9k→800 tokens) and per-feature cost 5–10x (200–400k→≤40k tokens), while adding, not removing, automated enforcement.
- Found and fixed a live security/trust bug where a review workflow's confirmation gate could be bypassed by an upstream flag, causing unconfirmed comments to post to a real pull request; redesigned the control boundary so no step upstream of a confirmation gate can perform the gated action.
- Built and maintained a vendoring-consistency guard (custom script + dedicated CI job) keeping a git-submodule-developed backend and its byte-for-byte public-repo copy from silently drifting.
- Shipped a full-stack local analytics dashboard (Python/SQLite backend, React frontend, timezone-correctness test coverage including DST edge cases) as a bundled feature of the plugin.
