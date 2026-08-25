---
description: Offers the CLAUDE.md marker, then observe-confirm harness generation; --local writes local preferences only.
argument-hint: [--local]
---

Templates: `${CLAUDE_PLUGIN_ROOT}/skills/task-assets/assets/` (paths below relative).

`--local` present → **`--local` mode**; else **Default mode**.

## Default mode

1. No root `CLAUDE.md` → say so, stop; never creates one.
2. `CLAUDE.md` already has `<!-- cairn:start -->` → skip to 4.
3. Else read `claude-md-marker.md`, show the exact text, ask before appending (blank line first if needed).
4. Observe the codebase against the four files' sections. Show each candidate with an evidence count (e.g. "3/4 services"), ask approve/edit/drop.
5. For `architecture.md`, `standards.md`, `environment.md`, `workflow.md`: read the template, fill with confirmed rules only, write to `.harness/<name>`, header line unchanged.
6. Write `.harness/BUDGET.md`: line count, cap (40/40/30/30), headroom per file. Regenerated every run, never read back.

Refines, never overrides — tightens a check, never asserts what the project doesn't do.

## `--local` mode

Never touches the team files or the marker block.

1. Ask which local preferences to set — model per role, token ceiling, narration verbosity, optional-pass defaults, local tool paths, escalation leaning. Skip what's unwanted.
2. Show the exact contents, then write `.harness/local/preferences.md` (base: `local/preferences.md`) plus `.harness/local/.gitignore` containing `*`.
