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
4. Follow `harness-generation.md` to observe, confirm, and write the four harness files plus `docs/BUDGET.md`; also covers the bare-`<path>` variant.
5. Unless a bare `<path>`, follow `tasks/setup.md`.

## Track mode

Edits only the roster, rewrites `docs/BUDGET.md`; never touches team files or marker text.

1. `--track claude-md-marker`: no marker → say so, stop. Else add `claude-md-marker CLAUDE.md 400` to the roster (idempotent). `--untrack` removes it, else says so.
2. Other `<label>` → unrecognized; stop.

## `--local` mode

Never touches team files or the marker.

1. Ask which local prefs to set: model per role (builder/planner/reviewer/scribe/research; one `model <agent> = <model>` line each), path-choice leaning (one `prefer-path = default` or `= escalated` line), token ceiling, narration, optional-pass; skip unwanted.
2. Show exact contents, write `.harness/local/preferences.md` (base: `local/preferences.md`) plus `.harness/local/.gitignore` containing `*`.
