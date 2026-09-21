# docs

Index of this repo's own documentation — for developing cairn, not for a consuming project's `.harness/`.

| File | What it is |
|---|---|
| [`REGISTRY.md`](REGISTRY.md) | Justification for every tool an agent's frontmatter grants. Checked by `tools/budget.py`, never loaded by the model. |
| [`BUDGET.md`](BUDGET.md) | Generated size/load-class report for every budgeted artifact. Regenerate with `python tools/budget.py --report`. |
| [`AI_TIPS.md`](AI_TIPS.md) | Notes from experience working with AI coding agents — the practices this repo's own discipline is built on. |
| [`PRODUCT.md`](PRODUCT.md), [`DESIGN.md`](DESIGN.md) | Product context and design system for the token-metering dashboard. |
| [`DESIGN-landing.md`](DESIGN-landing.md), [`index.html`](index.html) | Design system and source for the public GitHub Pages landing page (`assets/` holds its images). |
| [`portfolio/`](portfolio/) | External-evaluation material: `PORTFOLIO.md` (case study) and `INTERVIEW-STORIES.md` (STAR narratives). |

## `specs/`

Gitignored scratch (`YYYY-MM-DD-topic.md`) — design notes written before a non-trivial change, local only. Absent on a fresh clone.

## `tasks/`

Created by the escalated path (`planner` → `builder` → `reviewer`) — a `docs/tasks/<slug>/STATE.md` and plan per escalated task. Finished tasks are removed; git history keeps them.
