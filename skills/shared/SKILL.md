---
name: shared
description: Mechanics shared by planner, builder, and reviewer — STATE.md conventions and how to run the harness's verification commands.
---

# cairn:shared

## STATE.md

A task folder's `STATE.md` has two parts. **Frontmatter** is the state read on resume: the scope record, `key_info`, and `flags`. Every field is under 200 characters and the block is under 1,024 B; `tools/budget.py` fails a block over that. `key_info` holds the current facts and the next step, overwritten as work moves. `flags` only grows — appended, never pruned, even once a flag is resolved; it's a permanent decision log, not a to-do list. The final step asks one consolidated question. There is no `phase` field: the stage follows from what exists (no `plan.md` — requirements; a plan and no merged PR — building; a merged PR — done; a `research` folder expects no PR and is done when its `key_info` says so). Check merged with `gh pr list --head <folder-name> --state merged --json number -q 'length'`; anything but a clean `0` or `1` — skip the check and go by `key_info` instead. **The body** below the closing `---` is an append-only log, one dated line per event, never edited and not read on resume — open it only to explain something.

## Task folder

`docs/tasks/YYYY-MM-DD-HHMM-<kind>-slug/` (kinds per `cairn:scope`'s Escalated path), holding `requirements.md` and `STATE.md` — except a `review` folder, which holds `DRAFT.md` instead, per `review-pr`'s `reference/draft-template.md`; `plan.md` follows once requirements exist. Working outputs (briefs, mockups, findings) live in the same folder, loose; group them in a named subfolder when several cluster. A task too big for one PR splits into numbered sub-task folders (`01-<kind>-slug/`) inside it, each with its own `requirements.md` and `STATE.md`, its own branch, and its own restated `out_of_scope`; only that sub-task's session writes them. A follow-on goal sourced from a doc in an existing folder nests there as its next sub-task instead of a new top-level folder (a doc inside a sub-task nests inside that sub-task), per `cairn:scope` step 0. Sub-tasks run in parallel unless one names `depends_on`. That assumes worktree isolation, absent in a single-repo project — sub-tasks then share one working tree, where files touched only by commit convention (`plugin.json`, `CHANGELOG.md`) collide without appearing in any `paths` list. Give one sub-task, via `depends_on` on the rest, sole ownership of that bump.

## Running verification

Read `workflow.md`'s `## Gates` section and `environment.md`'s typed preconditions from the already-resolved harness. Run each via `Bash`. Failure semantics are uniform: a check whose command can't run counts as failed, and a line that can't be parsed also counts as failed — no silent-skip tier. A `[blocking]` failure stops the task; a `[warning]` failure doesn't.

Also measure the active task's `STATE.md` frontmatter — its own task folder, not `source` (which may point elsewhere, e.g. a standalone `docs/requirements/*.md` with no `STATE.md` of its own) — with `awk '{print} NR>1&&/^---$/{exit}' STATE.md | wc -c`, which counts from the opening `---` through the closing one, or the whole file if there is no closing one. Over 1,024 B counts as a `[warning]` failure: name the file and its size, do not stop the task. Old oversized files therefore warn and never block.

## Reference

| File | Load when |
|---|---|
| reference/security-checklist.md | Reviewing a diff — check it against these categories alongside whatever the review already covers. |
| reference/fix-lanes.md | Tagging a diff review's own reuse/simplification/efficiency findings, for human triage. |
