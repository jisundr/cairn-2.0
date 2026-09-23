---
description: Offers the CLAUDE.md marker, then observe-confirm harness generation; --local writes local prefs; --track toggles marker-ledger tracking.
argument-hint: [<path>] [--local] [--track <label>] [--untrack <label>]
---

Templates: `${CLAUDE_PLUGIN_ROOT}/skills/task-assets/assets/` (relative below).

`--track`/`--untrack` → Track mode; `--local` → `--local` mode; else Default.

## Default mode

1. No root `CLAUDE.md` → say so, stop; never creates one.
2. `CLAUDE.md` already has `<!-- cairn:start -->` → skip to 4.
3. Else read `claude-md-marker.md`, show it, ask before appending (blank line first if needed).
4. Observe the codebase against the four sections. Show each candidate with an evidence count ("3/4 services"), ask approve/edit/drop.
5. For `architecture.md`, `standards.md`, `environment.md`, `workflow.md`: read template, fill confirmed rules, write to `.harness/<name>`, header unchanged.
6. Write `docs/BUDGET.md`: lines, cap 40/40/30/30, headroom, roster rows; never read back; skip one missing header `# Harness budget ledger`. Delete a stale `.harness/BUDGET.md`.
7. Bare `<path>` (needs `.harness/`, else run unscoped first) → skip 1-3; 4 observes only `<path>`'s uncovered patterns; 5 inserts lines as `<path>: <rule>`.
8. Unless a bare `<path>`, follow `tasks/setup.md`.

## Track mode

Edits only the roster, reruns step 6; never touches team files or marker text.

1. `--track claude-md-marker`: no marker → say so, stop. Else add `claude-md-marker CLAUDE.md 400` to the roster (idempotent). `--untrack` removes it, else says so.
2. Other `<label>` → unrecognized; stop.

## `--local` mode

Never touches team files or the marker.

1. Ask which local prefs to set (model per role, per agent (builder/planner/reviewer/scribe/research), skip unanswered, one `model <agent> = <model>` line each; token ceiling, narration, optional-pass, tool paths, escalation leaning); skip unwanted.
2. Show exact contents, write `.harness/local/preferences.md` plus `.harness/local/.gitignore` containing `*`.
