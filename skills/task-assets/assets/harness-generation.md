# Generating the harness

1. Observe the codebase against the four sections (`architecture.md`, `standards.md`, `environment.md`, `workflow.md`). Show each candidate with an evidence count ("3/4 services"), ask approve/edit/drop.
2. For each of the four: read its template, fill confirmed rules, write to `.harness/<name>`, header unchanged.
3. Write `docs/BUDGET.md`: lines, cap 40/40/30/30, headroom, roster rows; never read back; skip one missing header `# Harness budget ledger`. Delete a stale `.harness/BUDGET.md`.

A bare `<path>` (needs `.harness/` already present, else run unscoped first) skips the marker steps entirely: step 1 observes only `<path>`'s uncovered patterns, and step 2 inserts confirmed lines as `<path>: <rule>` instead of rewriting the section.
