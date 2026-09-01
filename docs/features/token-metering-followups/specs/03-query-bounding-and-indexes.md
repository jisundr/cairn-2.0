# Spec: bound `session_trace`/`call_detail`'s queries + add supporting indexes

Implementation spec for `requirements.md` issue 3 / goal 3. Two changes, one commit: an index on `db.py`'s schema, and a time bound on the two `TokenMeteringApp` methods that currently scan `calls` unbounded.

## Architecture

Two complementary fixes rather than either alone:

- **Indexes** fix the underlying table-scan cost regardless of how a query is shaped — `session_trace()`/`call_detail()` already filter to one `session_id` in Python after fetching every row (`tools/tokens/server.py:702`, `:707`); an index on `calls.session_id` doesn't change that Python-side filter, but every other rollup method's `_fetch_table()` (`server.py:571-600`) already does its filtering in SQL via a `WHERE substr(timestamp, 1, 19) >= ? AND ... < ?` clause, and that clause can't use a plain index on `timestamp` — `substr(...)` is a computed expression, and SQLite only uses an index on the literal column unless the index itself is declared on that same expression. An expression index (`CREATE INDEX ... ON calls (substr(timestamp, 1, 19))`) fixes that class of query too, and is the smaller, more broadly useful fix since it speeds up every ranged rollup, not just the two unbounded ones.
- **Bounding `session_trace()`/`call_detail()`** fixes the specific pattern named in the issue: fetching *every* row ever captured to find one session's rows is wasteful independent of indexing, since a session's own time range is already knowable (the `sessions` rollup derives `started`/`ended` from `min`/`max` of a group's timestamps, `rollup_group`'s sibling `rollup_sessions()` at `server.py:327-354`) — a session's calls, by definition, all fall within that same window. Bounding the query to a small margin around a session's known window turns "scan everything" into "scan roughly one session's worth," with the `session_id`-filtered index doing the rest.

Both together: add the `session_id` index (covers the Python-side filter's underlying table scan being smaller to begin with) and the `substr(timestamp,1,19)` expression index (covers the new time-bounded query in `session_trace`/`call_detail`, and every existing ranged rollup for free) — plus change `session_trace()`/`call_detail()` to look up the session's own window first, then fetch calls bounded to it.

## Components

### `tools/tokens/db.py` — new index statements

```python
CALLS_SESSION_INDEX = "CREATE INDEX IF NOT EXISTS idx_calls_session_id ON calls (session_id)"
CALLS_TIMESTAMP_INDEX = "CREATE INDEX IF NOT EXISTS idx_calls_timestamp_trunc ON calls (substr(timestamp, 1, 19))"
TOOL_USES_SESSION_INDEX = "CREATE INDEX IF NOT EXISTS idx_tool_uses_session_id ON tool_uses (session_id)"
USAGE_LIMIT_EVENTS_SESSION_INDEX = (
    "CREATE INDEX IF NOT EXISTS idx_usage_limit_events_session_id ON usage_limit_events (session_id)"
)
```

`connect()` (currently three `conn.execute(...)` calls for the three `CREATE TABLE` schemas) executes these four alongside them, same idempotent `IF NOT EXISTS` pattern already used for the tables themselves. `tool_uses.session_id` and `usage_limit_events.session_id` get indexes for consistency with `calls` and because `rollup_sessions()` cross-references `usage_limit_events` by `(project, session_id)` (`server.py:332`) even though that cross-reference currently happens in Python over an already-fetched, range-bounded set — indexing them now costs nothing at write time (index maintenance on `INSERT OR IGNORE`, already paid on `calls`) and is available if a future query pushes that filter into SQL.

`tools/tokens/prices.json` and `pricing.py` are untouched — this spec doesn't touch pricing.

### `tools/tokens/server.py`'s `TokenMeteringApp.session_trace()` and `call_detail()`

Current (`server.py:700-712`):

```python
def session_trace(self, session_id: str, project_filter: str | None = None) -> dict | None:
    projects = _filter_projects(self.projects(), project_filter)
    calls = [r for r in self._fetch_calls(projects) if r["session_id"] == session_id]
    return build_session_trace(session_id, calls)

def call_detail(self, session_id: str, n: int, project_filter: str | None = None) -> dict | None:
    projects = _filter_projects(self.projects(), project_filter)
    calls = [r for r in self._fetch_calls(projects) if r["session_id"] == session_id]
    ...
```

New — both route through one bounded helper:

```python
def _fetch_session_calls(self, projects: list[Project], session_id: str) -> list[dict]:
    """Every call for `session_id` across `projects`, without scanning the
    full `calls` table. `calls.session_id` has no cross-project uniqueness
    guarantee ruled out elsewhere in this class, so this still filters in
    Python after fetching - the win is querying SQL by `session_id`
    directly (indexed, per `db.py`) instead of by unbounded time range.
    """
    rows = []
    for project in projects:
        conn = _open_readonly(project.db_path, "calls")
        if conn is None:
            continue
        try:
            for row in conn.execute("SELECT * FROM calls WHERE session_id = ?", (session_id,)):
                record = dict(row)
                record["project"] = project.label
                rows.append(record)
        finally:
            conn.close()
    return rows

def session_trace(self, session_id: str, project_filter: str | None = None) -> dict | None:
    projects = _filter_projects(self.projects(), project_filter)
    calls = self._fetch_session_calls(projects, session_id)
    return build_session_trace(session_id, calls)

def call_detail(self, session_id: str, n: int, project_filter: str | None = None) -> dict | None:
    projects = _filter_projects(self.projects(), project_filter)
    calls = self._fetch_session_calls(projects, session_id)
    ...
```

`_fetch_session_calls()` queries `WHERE session_id = ?` directly rather than going through `_fetch_table()`'s `since`/`until` machinery — a direct `session_id` equality match is simpler and more precise than deriving a session's time window first (which would need an extra round trip to `rollup_sessions()` or an equivalent lookup) and then bounding by it; it also sidesteps the requirements doc's suggestion of "bounding by the session's own time range" in favor of the more direct fix once `calls.session_id` is indexed, since an indexed equality lookup is strictly cheaper than an indexed range scan over the same rows. This is the one point where this spec deviates from the requirements doc's suggested approach — flagged here rather than silently changed, since the reasoning (equality beats range once you have the option) is a small, low-risk deviation from what was asked, but it is a deviation.

No change to `build_session_trace()` (pure function, already only cares about the rows it's given) or to `call_detail()`'s sort/slice logic beyond the input it now receives.

## Data flow

1. `session_trace()`/`call_detail()` resolve `projects` exactly as today.
2. `_fetch_session_calls()` issues one `SELECT * FROM calls WHERE session_id = ?` per project (using the new `idx_calls_session_id` index), instead of `_fetch_table()`'s unbounded `SELECT * FROM calls`.
3. Everything downstream (`build_session_trace()`'s sort/group, `call_detail()`'s sort/slice/lookup) is unchanged — same shape of rows in, same output.
4. Every other rollup method (`timeseries`, `day_detail`, `agent_rollup`, `sessions`, etc.) continues to call `_fetch_table()`/`_fetch_calls()` with `since`/`until` exactly as today; those queries now benefit from `idx_calls_timestamp_trunc` without any code change to those methods, since the index is declared on the same `substr(timestamp, 1, 19)` expression their `WHERE` clause already uses.

## Error handling

- A project whose `.cairn/tokens.db` predates this change (no index yet) → `CREATE INDEX IF NOT EXISTS` in `connect()` creates it on first open, same as any other schema migration this codebase already does via `IF NOT EXISTS`; no explicit migration script needed since `connect()` runs on every server start (`server.py`'s `_open_readonly()` opens read-only, but the *write* path — `parser.py`'s `db.connect()` — is what actually calls `connect()` and creates the index; a dashboard-only read-only project that's never had a `Stop` event fire since this change ships won't have the index until the next write, which is fine since `_open_readonly()` already handles a missing-table case as "no data yet").
- `session_id` with zero matching rows (unknown session) → `_fetch_session_calls()` returns an empty list, `build_session_trace()` already returns `None` for that case (existing behavior, unchanged) and `call_detail()` already returns `None` for `not calls` (existing behavior, unchanged).
- Cross-project ambiguity (the same `session_id` string existing in two different projects' `tokens.db`, extremely unlikely given Claude Code's own session-id generation but not ruled out by schema) → `_fetch_session_calls()` unions rows from every project exactly as `_fetch_calls()` did before, no behavior change here.

## Testing

`tools/tokens/test_db.py` (extended):

- `idx_calls_session_id`, `idx_calls_timestamp_trunc`, `idx_tool_uses_session_id`, `idx_usage_limit_events_session_id` all appear in `sqlite_master` (`WHERE type='index'`) after `connect()`.
- Re-running `connect()` against an existing db (already covered by `test_connect_is_idempotent_across_calls`, extended) doesn't error on the `IF NOT EXISTS` index statements.

`tools/tokens/test_server.py` (extended, same `make_project`/`tmp_path` fixture style as the existing `session_trace`/`call_detail` tests around lines 208-230, 297-314):

- `_fetch_session_calls()` (or `session_trace()`/`call_detail()` observably) returns the same rows for a session as the old unbounded-then-Python-filtered approach did, for a fixture with calls from more than one session in the same project — a regression check that scoping the query doesn't drop or duplicate rows.
- `EXPLAIN QUERY PLAN SELECT * FROM calls WHERE session_id = ?` against a connection opened via `_open_readonly()` reports use of `idx_calls_session_id` (`sqlite_master`-adjacent introspection query, asserting the string `"USING INDEX idx_calls_session_id"` or equivalent appears in the plan's output) — the concrete verification named in `requirements.md`'s success criterion 3.
- A ranged rollup query (any existing `_fetch_table()` caller, e.g. `test_fetch_calls_includes_subsecond_timestamps_at_the_lower_boundary`) continues to pass unchanged — confirms the new expression index doesn't alter query results, only their plan.

Gate: `python tools/budget.py` clean; `python -m pytest tools/` green. Same tests and gate apply to `token-metering/`'s copy once `specs/06-vendoring-drift-guard.md`'s sync process carries the fix across; `pytest test_db.py test_server.py` inside `token-metering/` per its own `.harness/workflow.md`.
