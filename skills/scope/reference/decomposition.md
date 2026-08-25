# Decomposing a request that spans multiple areas

List actionables as things you could start on — "add the login form," not "implementation" or "testing."

Each actionable should be independently nameable: someone reading just its name should know what file or area it touches.

Group by submodule or area when the request spans more than one — that's the same condition that sets `path: escalated` via `cairn:start`'s escalation trigger.

Keep the list short enough to scan. Five to eight items is a signal to fold some together, not to keep splitting further.

The list itself carries no ordering, dependencies, or phase names — that's the escalated path's `planner`, not scope resolution.
