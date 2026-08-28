# docs

Index of this repo's own documentation — for developing cairn, not for a consuming project's `.harness/`.

| File | What it is |
|---|---|
| [`BUILD_BRIEF.md`](BUILD_BRIEF.md) | The complete development contract and build spec — source of truth for structural changes to this repo. |
| [`REGISTRY.md`](REGISTRY.md) | Justification for every tool an agent's frontmatter grants. Checked by `tools/budget.py`, never loaded by the model. |
| [`BUDGET.md`](BUDGET.md) | Generated size/load-class report for every budgeted artifact. Regenerate with `python tools/budget.py --report`. |
| [`AI_TIPS.md`](AI_TIPS.md) | Notes from experience working with AI coding agents — the practices this repo's own discipline is built on. |

## `specs/`

Dated design notes (`YYYY-MM-DD-topic.md`) written before a non-trivial change, capturing the alternatives considered and why. One per decision, never edited after the fact.

## `features/`

Per-feature doc folders, one per shipped or in-progress feature. Currently: `token-metering/` — the Phase 2 token-metering feature, starting from `01-intent.md` (why it exists, in one page) through `02-requirements.md`, `03-architecture.md`, and `04-user-flow.md`, plus a `mockups/` dashboard.

## `tasks/`

Created only by the escalated path (`planner` → `builder` → `reviewer`) — a `docs/tasks/<slug>/STATE.md` and plan per in-progress escalated task. Absent when no escalated task is in flight.
