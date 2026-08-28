# CLAUDE.md — working on cairn itself

This file guides work **on this repo** (building the cairn plugin). It is not the marker block cairn writes into a *consuming* project's `CLAUDE.md` — that's a separate, ≤ 400 B template at `skills/task-assets/assets/claude-md-marker.md`.

## What cairn is

cairn 2.0 is a Claude Code plugin carrying a lean, on-demand, non-invasive development workflow: it leaves one marker line in a consuming project's `CLAUDE.md`, reads everything else on demand, does nothing until the project's `.harness/` has told it how the project works, and can be removed without a trace.

## Source of truth

`Cairn 2.0 build brief.md` at the repo root is the complete development contract and build spec. Read it before making any structural change here — this file only summarizes the parts that recur on every commit.

## Discipline for every change

- **One artifact per commit**, plus its `docs/registry.md` line (if it adds an agent) and its `CHANGELOG.md` entry. Never a sweep across many files.
- **Bump `.claude-plugin/plugin.json`'s version** whenever a change affects the plugin's behavior (new/changed command, skill, agent, or hook behavior) — not for docs-only or internal-refactor changes. Minor for a new capability, patch for a fix, matching past bumps (see `CHANGELOG.md`).
- **Run the gate after every file**: `python tools/budget.py`. Fix findings before writing anything else.
- **No mandate language** (`MUST`, `ALWAYS`, `NEVER`, `MANDATORY`, `NON-NEGOTIABLE`, a `HARD REQUIREMENTS` heading) in `agents/`, `skills/`, `commands/`, or `hooks/`. Say how a rule is enforced instead — e.g. "`reviewer` has no `Write` tool."
- **No scaffolding for later.** If nothing loads a file today, don't write it. No `TODO`/`TBD`/`FIXME`/`<placeholder>` in shipped artifacts.

## Phase gate

At the end of each build phase, run and paste the results of:

```
python tools/budget.py
python -m pytest tools/
for s in tools/**/*.sh; do "$s" --selftest; done
python tools/budget.py --report && tail -5 docs/BUDGET.md
```

If any step fails, fix it before starting the next phase.

<!-- cairn:start -->
If the `cairn` plugin is available in this session, use it for development work in this repo — start with the `cairn:start` skill. If it is not available, ignore this block; nothing in it applies.
<!-- cairn:end -->
