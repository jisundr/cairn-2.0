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

## Data
- `.cairn/` and `.harness/` are the only self-writing directories; both gitignore themselves
- Token-metering data is local-only SQLite (`.cairn/tokens.db`), never shared/remote
