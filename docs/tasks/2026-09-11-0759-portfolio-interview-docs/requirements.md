# Requirements — external-evaluation materials for cairn 2.0

## Problem

cairn 2.0's engineering surface — a governed multi-agent pipeline, enforced token budgets, self-testing tooling, a full sub-application — has never been distilled into materials suitable for someone evaluating it from outside the repo: no stated role/category classification, no case study, no interview-ready narrative, no resume-form summary.

## Goals

1. State a role/category classification this project's engineering surface best demonstrates, with each claim traceable to something already in the repo (matches `docs/PRODUCT.md`'s own "no invented social proof" principle — extended here to any external-facing claim).
2. Produce a portfolio case study: problem → design decisions → tradeoffs → measured results.
3. Produce 3–5 STAR-format narratives, mapped to common technical-interview question types (system design, tradeoffs/conflict, debugging/failure, technical depth).
4. Produce resume/LinkedIn-form copy: 3–5 lines, quantified.

## Non-goals

- No changes to cairn's actual product, code, or `docs/PRODUCT.md` / `docs/DESIGN.md` — this task reads from them, doesn't alter them.
- Not a general rewrite of the repo's existing documentation.

## Stakeholders

- The project's author, who draws on these materials directly.
- Anyone evaluating the project from outside the repo — recruiters, technical interviewers, future collaborators — as the audience the framing is written for.

## Constraints & assumptions

- `docs/` in this repo is reserved for cairn's own development docs (indexed in `docs/README.md`: `REGISTRY.md`, `BUDGET.md`, `AI_TIPS.md`, `specs/`, `features/`, `tasks/`). A career doc is not a shipped product artifact, so the final deliverables live under `docs/` as standalone meta files (same category as `AI_TIPS.md`) rather than as a product spec/feature doc.
- This repo's `CLAUDE.md` requires a `plugin.json` version bump + `CHANGELOG.md` entry on every commit, docs-only included. That discipline is for cairn's shipped surface; these external-evaluation files are written but **not committed**, so they don't trigger a version bump for non-product content.
- Framing targets a generic IC audience — flexible across role levels and company types (startup vs. enterprise), not tuned to a specific application.
- Every claim/number in the final docs must trace to something actually in the repo (README, CLAUDE.md, `.harness/*.md`, `docs/PRODUCT.md`, `docs/DESIGN.md`, `docs/BUDGET.md`, `docs/REGISTRY.md`, `CHANGELOG.md`, `docs/specs/*`, `tools/budget.py`) — no invented metrics or embellished scope.

## Open questions

None outstanding.

## Success criteria

- A stated primary role classification (proposed: AI/Agentic Systems Engineering) plus secondary framings (Platform/DevEx Engineering; Full-Stack via `token-metering/`), each backed by a specific file or number.
- `docs/PORTFOLIO.md` exists with the case study, classification, and resume bullets.
- `docs/INTERVIEW-STORIES.md` exists with 3–5 STAR stories.
- Either doc can be used directly in an application or interview without further fact-checking against the repo.
