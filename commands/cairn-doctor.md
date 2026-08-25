---
description: Reports plugin version, marker/harness/.cairn state, and the local layer line by line. Read-only — installs, fixes, and gates nothing.
---

Read-only. Never writes, never blocks.

1. **Plugin** — read `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`, report `version`.
2. **Marker** — root `CLAUDE.md` present and contains `<!-- cairn:start -->`? Report yes/no.
3. **Harness** — for each of `architecture.md`, `standards.md`, `environment.md`, `workflow.md` under `.harness/`: present or absent.
4. **`.cairn/`** — present or absent; if present, `sessions.log` line count and its last line (skip anything else found there without asserting what it is).
5. **Local layer** — `.harness/local/preferences.md` absent → say so, stop. Else classify every line:
   - `model ...` → **inert (no lever)** — no runtime lever for session model (§B3f).
   - a line that would relax, skip, or disable something one of the four team files requires, or a stage cairn's own path always runs (`builder`, `reviewer`) → **ignored by ceiling**, naming the conflicting file/section or "cairn's own path".
   - a recognised key (`token-ceiling`, `narration`, `optional-pass`, `prefer-path`) not caught above → **active**.
   - anything else → **unrecognised**.

This is the only place any of #5 is ever said — nothing about the local layer surfaces during a normal task.
