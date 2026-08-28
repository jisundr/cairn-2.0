> Refines, never overrides — this file can add a check or tighten a standard; it cannot remove a step cairn's workflow already requires.

## Branching
- Direct commits to `main`, no feature branches observed

## Commits / PR
- One artifact per commit + its `docs/REGISTRY.md` line (if it adds an agent) + `CHANGELOG.md` entry — never a sweep
- Bump `.claude-plugin/plugin.json` version for any behavior-affecting change

## Gates
- `python tools/budget.py` clean after every file
- Phase-end: `budget.py` + `pytest tools/` + every `--selftest` + `budget.py --report`
- No mandate language (MUST/ALWAYS/NEVER/MANDATORY/NON-NEGOTIABLE) in shipped artifacts
