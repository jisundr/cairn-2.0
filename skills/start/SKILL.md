---
name: start
description: Entry point, loaded once per session. Resolves the .harness/ gate, decides whether scope needs resolving, and picks default vs escalated.
---

# cairn:start

## Harness gate

One `Glob .harness/**/*.md` call, once per task; hold the result — never re-glob mid-task.

- **Present** — read what the current step needs, proceed.
- **Partial** — proceed with what's there. A missing individual file skips silently.
- **Absent** — don't proceed with cairn's workflow. Say cairn works from the project's own `.harness/`, and offer `/cairn-setup`, once. If declined, stand down for the session: no more asking, no partial engagement, no writes. Keep working on the request normally, without cairn.

## Local preferences

Also covered by the glob: `.harness/local/preferences.md`, classified per `/cairn-doctor` (active / inert / ignored-by-ceiling / unrecognised). Dispatch prompts carry only active values — never the file, its path, or a non-active line; no agent reads it. Active `prefer-path` feeds the path choice.

## Scope resolution

On cold resume — a task folder's `STATE.md` holds a scope record but this session has none — read it back as the active record; no interview, no `cairn:scope`.

Otherwise, resolve scope — invoke `Skill(skill: "cairn:scope")` — when any of these is true:

1. First substantive request of the session.
2. The request names a goal or area outside the active record.
3. Underspecified: no clear object, no done condition, or you can't name the files you'd touch.
4. More than about three actionables not already in the record.
5. The user invalidates active scope ("actually, let's…", "scrap that", "different idea").
6. Cold resume, no record to restore.

Otherwise, continue without resolving — this should be most messages: a refinement inside scope, an answer to a question you asked, an instruction you can already act on, or conversation about the work. A request that only slightly extends scope (one more file, one more case, same goal, same done condition) — amend the record directly instead of re-resolving.

**Scope record**, under 400 B:

```yaml
goal: <one sentence>
paths: [<dirs or globs in scope>]
done_when: <checkable condition>
out_of_scope: [<explicitly excluded>]
source: <doc, if any>
path: default | escalated
```

Continuity test: request fits `paths`, serves `goal`, doesn't change `done_when`? Yes → continue; no → resolve again.

Default path: held in the main thread, nothing written to disk. Escalated path: written into `docs/tasks/<slug>/STATE.md`.

## Path choice

| Path | Flow | Budget |
|---|---|---|
| Default | `builder` → `reviewer` → PR | ≤ 40k tokens |
| Escalated | `planner` → approval → `builder` → `reviewer` → PR, with `docs/tasks/<slug>/STATE.md` | ≤ 150k tokens |

Escalation trigger, verbatim: escalate when the change spans more than one submodule, alters a published contract (API, schema, or event), or can't be described in two sentences.
