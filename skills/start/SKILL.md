---
name: start
description: Entry point, loaded once per session at the marker block. Resolves the .harness/ gate, decides whether scope needs resolving, and picks the default vs escalated path.
---

# cairn:start

## Harness gate

One `Glob .harness/**/*.md` call, once per task. Hold the result for the whole task — never re-glob mid-task.

- **Present** — read what the current step needs, proceed.
- **Partial** — proceed with what's there. A missing individual file skips silently.
- **Absent** — don't proceed with cairn's workflow. Say plainly that cairn works from the project's own `.harness/`, and offer `/cairn-setup`, once. If the user declines, stand down for the session: don't ask again, don't partially engage, don't write anything. Keep working on the request normally, without cairn.

## Local preferences

Also covered by the glob above: `.harness/local/preferences.md`. Classify each line as `/cairn-doctor` does (active / inert / ignored-by-ceiling / unrecognised); never mention a non-active line. An active `prefer-path` feeds the path choice below.

Dispatch prompts carry only the relevant active lines, never the file; no agent reads it.

## Scope resolution

On cold resume — a task folder exists with a scope record in its `STATE.md` frontmatter but none in this session — read that record back directly as the active one; no interview, no `cairn:scope`.

Otherwise, resolve scope — invoke `Skill(skill: "cairn:scope")` — when any of these is true:

1. First substantive request of the session.
2. The request names a goal or area outside the active scope record.
3. Underspecified: no clear object, no checkable done condition, or you can't name the files you'd touch.
4. More than about three discrete actionables not already in the scope record.
5. The user invalidates the active scope ("actually, let's…", "scrap that", "different idea").
6. Cold resume: a task folder exists from a previous session and there's no scope record in this one.

Otherwise, continue without resolving — the default, and it should be most messages: a refinement inside the active scope, an answer to a question you asked, a concrete instruction you can already act on, or conversation about the work rather than a change to it. A request that only extends the active scope slightly (one more file, one more case, same goal, same done condition) — amend the scope record directly instead of re-resolving.

**Scope record**, under 400 B:

```yaml
goal: <one sentence>
paths: [<dirs or globs in scope>]
done_when: <checkable condition>
out_of_scope: [<explicitly excluded>]
path: default | escalated
```

Continuity test: does this request fall inside `paths` and serve `goal` without changing `done_when`? Yes → continue. No → resolve again.

Default path: held in the main thread for the session, nothing written to disk. Escalated path: written into `docs/tasks/<slug>/STATE.md`.

## Path choice

| Path | Flow | Budget |
|---|---|---|
| Default | `builder` → `reviewer` → PR | ≤ 40k tokens |
| Escalated (opt-in) | `planner` → `builder` → `reviewer` → PR, with `docs/tasks/<slug>/STATE.md` | ≤ 150k tokens |

Escalation trigger, verbatim: escalate when the change spans more than one submodule, alters a published contract (API, schema, or event), or when you can't describe the change in two sentences.
