---
name: scope
description: Resolves scope when cairn:start's checklist fires. Turns a request into a scope record; interviews only if vague, decomposes only if it spans multiple areas.
---

# cairn:scope

Turn the request into a scope record — most of the time this needs no interview.

## Default flow

1. From the request and conversation so far, name: `goal` (one sentence), `paths` (dirs or globs), `done_when` (checkable condition), `out_of_scope` (explicit exclusions — omit if none).
2. Apply `cairn:start`'s escalation trigger to set `path: default` or `path: escalated`.
3. State the resolved record back in one line and continue. A resolution that produces no new information costs one sentence, not an interview.

```yaml
goal: <one sentence>
paths: [<dirs or globs>]
done_when: <checkable condition>
out_of_scope: [<explicit exclusions>]
path: default | escalated
```

## Escalated path

Derive a short kebab-case slug from `goal` (e.g. `add-oauth-login`). Create `docs/tasks/<slug>/STATE.md` — the record above as YAML front matter, under the 1,024 B cap. Default path: the record stays in the main thread; nothing is written to disk.

## Reference

| File | Load when |
|---|---|
| reference/vague-request.md | You cannot name `goal`, `paths`, or `done_when` without guessing. |
| reference/decomposition.md | The request spans more than one submodule, or implies more than about three discrete actionables. |
