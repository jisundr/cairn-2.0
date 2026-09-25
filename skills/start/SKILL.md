---
name: start
description: Entry point, loaded once per session. Resolves the .harness/ gate, scope, path, and attendance.
---

# cairn:start

## Harness gate

One `Glob .harness/**/*.md` call, once per task; hold the result — never re-glob mid-task.

- **Present** — read what the current step needs, proceed.
- **Partial** — proceed with what's there. A missing individual file skips silently.
- **Absent** — don't proceed with cairn's workflow. Say cairn works from the project's own `.harness/`, and offer `/cairn-setup`, once. If declined, stand down for the session: no more asking, no writes. Keep working on the request normally, without cairn.

## Local preferences

Also covered by the glob: `.harness/local/preferences.md`, classified per `/cairn-doctor` (active / ignored-by-ceiling / unrecognised). Dispatch prompts carry only active values — never the file or its path; no agent reads it. Active `prefer-path` feeds the path choice. Active `model <agent> = <model>` feeds the `model` param on that role's `Agent()` dispatch call, not dispatch-prompt text — a no-op by construction for a `subagent_type: "fork"` dispatch, per `Agent`'s own documented behavior; a role with no matching line dispatches unchanged.

Absent — before the first agent dispatch, offer `/cairn-setup --local`'s model-per-role step, once. Declined → stand down for the session: no more asking that session, same pattern as the Harness gate's Absent case above. No cross-session persistence — a later session re-evaluates fresh.

## Scope resolution

On cold resume — `STATE.md` holds a scope record but this session has none — read its frontmatter as the active record, per `reference/resume.md`; no interview, no `cairn:scope`.

Otherwise, resolve scope — invoke `Skill(skill: "cairn:scope")` — when any of these is true:

1. First substantive request.
2. Goal or area outside the active record.
3. Underspecified: no object, no done condition, or unnamed files.
4. More than ~3 actionables not already in the record.
5. User invalidates scope ("actually, let's…", "scrap that").
6. Cold resume, no record to restore.

Otherwise, continue without resolving — most messages: a refinement inside scope, an answer to a question you asked, an instruction you can already act on, or conversation about the work. A request that only slightly extends scope — amend the record directly instead of re-resolving.

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

Default path: held in the main thread, nothing written to disk. Escalated path: written to the task folder's `STATE.md`.

## Path choice

| Path | Flow | Budget |
|---|---|---|
| Default | `builder` → `reviewer` → PR | ≤ 40k tokens |
| Escalated | requirements (approved) → `planner` (approved) → `builder` → `reviewer` → PR, with `STATE.md` | ≤ 150k tokens |

Escalation trigger, verbatim: escalate when the change spans more than one submodule, alters a published contract (API, schema, or event), or can't be described in two sentences.

A change touching `docs/` also dispatches `scribe` — `builder` never writes there.

## Delegating investigation

Resolving an open question or scope ambiguity in the main thread costs whatever it reads there. One file settles it — read it directly. Answering it needs more than one file — delegate to an agent instead: `Explore`, or `general-purpose` where `Explore` isn't offered in this session.

## Attendance

| Mode | Posture |
|---|---|
| Interactive | Questions answered as they come. |
| Attended | Auto-accepted; human still answers. |
| Unattended | Escalated only; default-and-flag; stops at a terminal state in `key_info`. See `reference/unattended.md` |
