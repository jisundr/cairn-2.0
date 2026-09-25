---
name: scope
description: Resolves scope when cairn:start's checklist fires. Turns a request into a scope record; interviews only if vague, decomposes only if it spans multiple areas.
---

# cairn:scope

Turn the request into a scope record — most of the time this needs no interview.

## Default flow

0. If the request points at an existing doc — `docs/requirements/*.md`, or any doc inside a `docs/tasks/*/` folder (its `requirements.md`, a `findings.md`, a `comparison.md`) — rather than describing the work directly, read it first: `goal` and `done_when` come from what the request itself asks for, else the doc's Goals and Success criteria, else its folder's `goal` and `done_when`; `paths` from whatever files or areas it names, and record its path as `source`. For a doc inside `docs/tasks/*/`: if that folder's stage isn't done (per `cairn:shared`) and the goal fits its `goal` and `out_of_scope`, that folder is the task folder. Otherwise the goal becomes its next numbered sub-task, `0N-<kind>-slug/` (N = highest existing number + 1), per `reference/decomposition.md` — never a new top-level folder. A doc inside a sub-task folder applies this to that sub-task, so new work nests one level deeper. A sub-task that follows the enclosing folder's own work records `depends_on: parent`. No such doc → skip to 1.
1. From the request and conversation so far, name: `goal` (one sentence), `paths` (dirs or globs), `done_when` (checkable condition), `out_of_scope` (explicit exclusions — omit if none).
2. Apply `cairn:start`'s escalation trigger to set `path: default` or `path: escalated`. If the call is genuinely unclear — it could plausibly read as one submodule or several, or "two sentences" would mean dropping something material — ask via `AskUserQuestion` instead of guessing.
3. State the resolved record back in one line and continue. A resolution that produces no new information costs one sentence, not an interview.

```yaml
goal: <one sentence>
paths: [<dirs or globs>]
done_when: <checkable condition>
out_of_scope: [<explicit exclusions>]
source: <requirements doc it was resolved from, if any>
path: default | escalated
```

## Escalated path

Name the folder `docs/tasks/YYYY-MM-DD-HHMM-<kind>-slug/`: the current local date and time, a `<kind>`, then a short kebab-case slug from `goal` (e.g. `2026-09-22-0600-build-add-oauth-login`). `<kind>` is `research` (a question, a brainstorm, or digesting an external source — no code implied), `build` (requirements → plan → build → PR), or `review` (a PR/MR review thread, named and created by `review-pr`, not here). It records how the thread started and is never renamed. Create it with two standard files. `STATE.md` is the record above as frontmatter, per `cairn:shared`. `requirements.md` is reused if the folder already has one; otherwise, if a task file was supplied (a ticket, a Slack thread, a doc), it holds that content and `source` names where it came from; otherwise write a short one from the record — Problem from `goal`, Goals and Success criteria from `done_when`, Non-goals from `out_of_scope`, leaving out any section the record does not supply. A small task gets only that — deliberately thinner than `cairn:requirements`' full shape (which adds Stakeholders, Constraints & assumptions, Open questions); that structure is for docs `scribe` writes directly, not interchangeable with this one. Dispatched unattended, write it the same way and append one `flags` line saying so. Default path: the record stays in the main thread; nothing is written to disk.

## Reference

| File | Load when |
|---|---|
| reference/vague-request.md | You cannot name `goal`, `paths`, or `done_when` without guessing. |
| reference/decomposition.md | The request spans more than one submodule, or implies more than about three discrete actionables. |
