---
description: Offers the CLAUDE.md marker block, then observe-then-confirm harness generation; --local writes .harness/local/preferences.md.
argument-hint: [--local]
---

Templates: `${CLAUDE_PLUGIN_ROOT}/skills/task-assets/assets/` (names below relative to it).

`--local` in the arguments → **`--local` mode**; else **Default mode**.

## Default mode

1. No root `CLAUDE.md` → say so, stop; never creates one.
2. `CLAUDE.md` already has `<!-- cairn:start -->` → skip to 4.
3. Else read `claude-md-marker.md`, show the exact text, ask before appending (blank line first if the file doesn't already end in one).
4. Observe the codebase against the four team files' sections. Show each candidate rule with an evidence count ("3 of 4 services follow this"), ask approve / edit / drop.
5. For `architecture.md`, `standards.md`, `environment.md`, `workflow.md`: read the template, fill sections with only confirmed rules, write to `.harness/<name>` — keep the header line unchanged.

Refines, never overrides — tightens a check, never asserts what the project doesn't actually do.

## `--local` mode

Never touches the team files or the marker block.

1. Ask which local preferences to set — model per role, token ceiling, narration verbosity, optional-pass defaults, local tool paths, default-vs-escalated leaning. Skip what's unwanted.
2. Show the exact contents, then write `.harness/local/preferences.md` (base: `local/preferences.md`) plus `.harness/local/.gitignore` containing `*`.
