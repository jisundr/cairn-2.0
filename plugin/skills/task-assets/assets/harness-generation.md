# Generating the harness

1. Observe the codebase against the four sections (`architecture.md`, `standards.md`, `environment.md`, `workflow.md`). Show each candidate with an evidence count ("3/4 services"), ask approve/edit/drop.
1b. For `workflow.md`'s `## Release`, propose `cairn:release`'s keys (`${CLAUDE_PLUGIN_ROOT}/skills/release/SKILL.md`) from what the repo shows: default branch, host CLI from the remote, tag format from existing tags. Same approve/edit/drop; keys left out use the skill's defaults.
2. For each of the four: read its template, fill confirmed rules, write to `.harness/<name>`, header unchanged.
3. Unless root `CLAUDE.md` already mentions `.harness/`, show this line and ask before appending it outside the cairn marker block, so any Claude session reads the rules, with or without cairn: `Project rules live in .harness/ (architecture, standards, environment, workflow); read the relevant file before changing code.` It is the project's line, and `/cairn-teardown` leaves it.
4. Write `docs/BUDGET.md` from `budget.md`: each harness file's line count and headroom, one roster row per tracked file; never read back. Delete a stale `.harness/BUDGET.md`.

A bare `<path>` (needs `.harness/` already present, else run unscoped first) skips the marker steps entirely: step 1 observes only `<path>`'s uncovered patterns, and step 2 inserts confirmed lines as `<path>: <rule>` instead of rewriting the section.
