# Decomposing a request that spans multiple areas

List actionables as things you could start on — "add the login form," not "implementation" or "testing."

Each actionable should be independently nameable: someone reading just its name should know what file or area it touches.

Group by submodule or area when the request spans more than one — that's the same condition that sets `path: escalated` via `cairn:start`'s escalation trigger.

Keep the list short enough to scan. Five to eight items is a signal to fold some together, not to keep splitting further.

The list itself carries no ordering, dependencies, or phase names — that's the escalated path's `planner`, not scope resolution.

When a task is too big for one PR or one context window, make it a parent folder and split it into numbered sub-task folders (`01-<kind>-slug/`, `<kind>` per `cairn:scope`'s Escalated path), each with its own `STATE.md` and `REQUIREMENTS.md`. Sub-tasks run in parallel; add `depends_on` (a sibling's number, or `parent` for work that follows the enclosing folder's own scope) to a sub-task's `STATE.md` only where one truly needs another's result, and fix any shared schema or API in the parent's `REQUIREMENTS.md` first, or make it an earlier sub-task the rest depend on. Compare sibling `paths` before writing anything: two sub-tasks whose paths overlap are merged, or one takes a `depends_on`. Without worktree isolation (no submodules), also treat files touched only by commit convention — `plugin.json`, `CHANGELOG.md` — as an implicit overlap even though no sub-task lists them: give one sub-task, via `depends_on` on the rest, sole ownership of that bump, per `cairn:shared`. Each sub-task restates `out_of_scope` in its own `STATE.md`. Create the parent's `ROADMAP.md` in the same pass as the first numbered folder, one row per sub-task — see `cairn:shared`'s Task folder section for its shape and who keeps it current. The no-dependencies rule above is for the actionable list inside one task, not for splitting into sub-task folders.

Before dispatching an agent for a sub-task, bind the task pointer to that sub-task's folder — and to the parent's folder for the parent's own scope — per `cairn:start`'s `reference/dispatch-pointer.md`.
