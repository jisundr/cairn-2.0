> Refines, never overrides — this file can add a check or tighten a standard; it cannot remove a step cairn's workflow already requires.

## Branching
- Direct commits to `main`, no feature branches observed

## Commits / PR
- One artifact per commit + its `docs/REGISTRY.md` line (if it adds an agent) + `CHANGELOG.md` entry — never a sweep
- Bump `.claude-plugin/plugin.json` version on every commit, including docs-only — the marketplace re-syncs a consuming project's install on version change, not on content diff, so an un-bumped change never reaches installs. Patch for docs/fixes, minor for a new capability.

## Gates
- `python tools/budget.py` clean after every file
- Phase-end: `budget.py` + `pytest tools/` + `for s in hooks/*.sh; do "$s" --selftest; done` + `budget.py --report`
- No mandate language (MUST/ALWAYS/NEVER/MANDATORY/NON-NEGOTIABLE) in shipped artifacts
