> Refines, never overrides — this file can add a check or tighten a standard; it cannot remove a step cairn's workflow already requires.

## Naming
- Docs specs: `docs/specs/YYYY-MM-DD-<slug>.md`, gitignored scratch
- Skill/agent/command names: lowercase-with-dashes
- Commit subjects: imperative mood, short, one artifact per commit

## Error handling
- Hooks: `set -uo pipefail`, silent `exit 0` on any missing dependency/field — advisory, never blocking
- Unknown/unpriced data reports `"unknown"`/`null`, never a silently-partial number

## Testing
- Python: `pytest`, `tmp_path`-based fixtures, one `test_*.py` per module
- Shell: every `tools/**/*.sh` requires `--selftest`, enforced by `tools/budget.py`

## Logging
- None by design — advisory-only philosophy, no logging framework
