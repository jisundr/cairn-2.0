> Refines, never overrides — this file can add a check or tighten a standard; it cannot remove a step cairn's workflow already requires.

## Stack
- Python 3.12 (pyenv-managed dev machine; CI pins 3.11) — stdlib only, no pip runtime deps for `tools/`
- Bash (`set -uo pipefail`) + `jq` for hooks
- Node 22/npm — CI + frontend-build only, never a consuming-project runtime dependency

## Layering
- Flat at repo root: `agents/`, `skills/`, `commands/`, `hooks/`, `tools/`, `docs/`
- Subsystem files group under their own `tools/<name>/` dir rather than flattening into `tools/` root

## Boundaries
- Plugin writes only within the non-invasiveness allowlist in a consuming project — never `.claude/settings.json` or `.claude/{agents,skills,commands,hooks}`
- Single plugin, no split: `review-pr` stays inside `cairn` core rather than becoming a standalone plugin — its coupling to core (`cairn:shared`'s two reference docs, `cairn:run`) is one-directional and small enough that vendoring it elsewhere would only add sync overhead. If a specialized plugin is ever split out, the dependency runs specialized → core, never the reverse.
- `tools/tokens/` (backend + `static/`) is vendored from the `token-metering` submodule — change it upstream, then re-vendor; never edit it in place. CI's `vendoring-drift` job (`tools/tokens/check_vendoring_sync.py`) enforces this.
- `agents/*.md` run as Task-dispatched subagents in a separate context and lose the interactive channel — no `AskUserQuestion` access, attended or not. `skills/*.md` load into the invoking thread itself and keep it. A new agent that wants an interview path doesn't have one; route it through a skill invoked from the main thread instead.

## Data
- `.cairn/` and `.harness/` are the only self-writing directories; both gitignore themselves
- Token-metering data is local-only SQLite (`.cairn/tokens.db`), never shared/remote
