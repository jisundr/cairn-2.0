---
name: shared
description: Mechanics shared by planner, builder, and reviewer — STATE.md conventions and how to run the harness's verification commands.
---

# cairn:shared

## STATE.md

A task folder's `STATE.md` has two parts. **Frontmatter** is the state read on resume: the scope record, `key_info`, and `flags`. Every field is under 200 characters and the block is under 1,024 B; `tools/budget.py` fails a block over that. `key_info` holds the current facts and the next step, overwritten as work moves. `flags` only grows, so the final step asks one consolidated question. There is no `phase` field: the stage follows from what exists (no `plan.md` — requirements; a plan and no merged PR — building; a merged PR — done). **The body** below the closing `---` is an append-only log, one dated line per event, never edited and not read on resume — open it only to explain something.

## Task folder

`docs/tasks/YYYY-MM-DD-HHMM-slug/`, always holding `requirements.md` and `STATE.md`; `plan.md` follows once requirements exist. Working outputs (briefs, mockups, findings) live in the same folder, loose; group them in a named subfolder when several cluster. A task too big for one PR splits into numbered sub-task folders (`01-slug/`) inside it, each with its own `requirements.md` and `STATE.md`, its own branch, and its own restated `out_of_scope`; only that sub-task's session writes them. Sub-tasks run in parallel unless one names `depends_on`.

## Running verification

Read `workflow.md`'s `## Gates` section and `environment.md`'s typed preconditions from the already-resolved harness. Run each via `Bash`. Failure semantics are uniform: a check whose command can't run counts as failed, and a line that can't be parsed also counts as failed — no silent-skip tier. A `[blocking]` failure stops the task; a `[warning]` failure doesn't.

## Reference

| File | Load when |
|---|---|
| reference/security-checklist.md | Reviewing a diff — check it against these categories alongside whatever the review already covers. |
| reference/fix-lanes.md | Tagging a diff review's own reuse/simplification/efficiency findings, for human triage. |
