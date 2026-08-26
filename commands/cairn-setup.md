---
description: Offers the CLAUDE.md marker, then observe-confirm harness generation; --local writes local prefs; --track toggles marker-ledger tracking.
argument-hint: [<path>] [--local] [--track <label>] [--untrack <label>]
---

Templates: `${CLAUDE_PLUGIN_ROOT}/skills/task-assets/assets/` (relative below).

`--track`/`--untrack` → Track mode; `--local` → `--local` mode; else Default.

## Default mode

1. No root `CLAUDE.md` → say so, stop; never creates one.
2. `CLAUDE.md` already has `<!-- cairn:start -->` → skip to 4.
3. Else read `claude-md-marker.md`, show the exact text, ask before appending (blank line first if needed).
4. Observe the codebase against the four sections. Show each candidate with an evidence count (e.g. "3/4 services"), ask approve/edit/drop.
5. For `architecture.md`, `standards.md`, `environment.md`, `workflow.md`: read the template, fill with confirmed rules, write to `.harness/<name>`, header unchanged.
6. Stale `.harness/BUDGET.roster.md` (pre-`0.2.1`) → rename to `.txt`. Write `.harness/BUDGET.md`: line count, cap (40/40/30/30), headroom, plus roster rows. Regenerated every run, never read back.
7. Bare `<path>` (needs `.harness/` set up, else run unscoped first) → skip 1-3; 4 observes only `<path>`, uncovered patterns only; 5 inserts lines as `<path>: <rule>`.

## Track mode

Edits only the roster, reruns step 6; never touches team files or marker text.

1. `--track claude-md-marker`: no marker → say so, stop. Else add `claude-md-marker CLAUDE.md 400` to the roster (create if absent, no-op if present). `--untrack` removes it if present, else says so.
2. Other `<label>` → only `claude-md-marker` is recognized; stop.

## `--local` mode

Never touches the team files or the marker block.

1. Ask which local prefs to set (model per role, token ceiling, narration, optional-pass, tool paths, escalation leaning); skip unwanted.
2. Show the exact contents, write `.harness/local/preferences.md` (base: `local/preferences.md`) plus `.harness/local/.gitignore` containing `*`.
