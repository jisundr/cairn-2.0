---
name: shared
description: Mechanics shared by planner, builder, and reviewer — STATE.md conventions and how to run the harness's verification commands.
---

# cairn:shared

## STATE.md

YAML frontmatter, every field under 200 characters, whole file under 1,024 B. `key_info` holds the current phase's facts and is overwritten each phase. `flags` is a list that only grows across the task — append to it, never trim it, so the final step asks one consolidated question.

## Running verification

Read `workflow.md`'s `## Gates` section and `environment.md`'s typed preconditions from the already-resolved harness. Run each via `Bash`. Failure semantics are uniform: a check whose command can't run counts as failed, and a line that can't be parsed also counts as failed — no silent-skip tier. A `[blocking]` failure stops the task; a `[warning]` failure doesn't.
