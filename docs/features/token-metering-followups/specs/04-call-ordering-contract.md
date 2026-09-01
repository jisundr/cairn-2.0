# Spec: server-computed call position, removing the client's duplicated sort

Implementation spec for `requirements.md` issue 4 / goal 4. Adds one field to the session-trace API response so `SessionDrilldown.tsx` never needs to re-derive `call_detail()`'s ordering itself.

## Architecture

`build_session_trace()` (`tools/tokens/server.py:357-409`) already sorts every call in the session chronologically before grouping by agent (line 367: `calls = sorted(calls, key=lambda r: (r["timestamp"], r["request_id"]))`) — this is the exact same sort `call_detail()` uses to compute `n` (line 710, identical key). The session trace's per-agent `trace` entries currently only carry a per-agent `position` (`i + 1` within that agent's own call list, line 381) — there's no field carrying the call's position in the *whole-session* ordering, which is what `/api/call/<session>/<n>` actually indexes by. That gap is exactly why `SessionDrilldown.tsx` re-derives it client-side today.

Fix: compute the whole-session position once, server-side, in `build_session_trace()` (which already has every call sorted the way `call_detail()` needs), and add it to each trace call's JSON shape as `global_position`. The client then reads `call.global_position` instead of recomputing it, and the duplicated sort in `SessionDrilldown.tsx` (lines 21-31) is deleted outright rather than kept as a fallback — a fallback that's never exercised is exactly the kind of unreachable code that made the original duplication risky in the first place (a second copy nobody notices going stale).

This makes `session_trace()`'s output the single source of truth for both orderings (per-agent `position`, whole-session `global_position`), matching `call_detail()`'s existing sort exactly because both are now the same code path: `build_session_trace()` sorts once at the top (line 367) and that same sorted list's index is what determines `global_position`, precisely mirroring `call_detail()`'s `calls.sort(...)` then `calls[n - 1]` (lines 710-714).

## Components

### `tools/tokens/server.py`'s `build_session_trace()`

Current (lines 357-409, relevant excerpt):

```python
def build_session_trace(session_id: str, calls: list[dict]) -> dict | None:
    if not calls:
        return None

    calls = sorted(calls, key=lambda r: (r["timestamp"], r["request_id"]))
    by_agent = defaultdict(list)
    for row in calls:
        by_agent[row["agent"]].append(row)

    ordered_agents = sorted(by_agent.items(), key=lambda kv: kv[1][0]["timestamp"])
    agents_out = []
    for agent, agent_calls in ordered_agents:
        trace = []
        for i, row in enumerate(agent_calls):
            next_row = agent_calls[i + 1] if i + 1 < len(agent_calls) else None
            duration = _seconds_between(row["timestamp"], next_row["timestamp"]) if next_row else None
            trace.append(
                {
                    "position": i + 1,
                    "request_id": row["request_id"],
                    ...
                }
            )
        agents_out.append({...})
    ...
```

New — build a `request_id -> global_position` map from the already-sorted `calls` list (the same list `call_detail()` would produce, since it's the same sort), and add `global_position` to each trace entry:

```python
def build_session_trace(session_id: str, calls: list[dict]) -> dict | None:
    if not calls:
        return None

    calls = sorted(calls, key=lambda r: (r["timestamp"], r["request_id"]))
    global_position = {row["request_id"]: i + 1 for i, row in enumerate(calls)}

    by_agent = defaultdict(list)
    for row in calls:
        by_agent[row["agent"]].append(row)

    ordered_agents = sorted(by_agent.items(), key=lambda kv: kv[1][0]["timestamp"])
    agents_out = []
    for agent, agent_calls in ordered_agents:
        trace = []
        for i, row in enumerate(agent_calls):
            next_row = agent_calls[i + 1] if i + 1 < len(agent_calls) else None
            duration = _seconds_between(row["timestamp"], next_row["timestamp"]) if next_row else None
            trace.append(
                {
                    "position": i + 1,
                    "global_position": global_position[row["request_id"]],
                    "request_id": row["request_id"],
                    ...
                }
            )
        agents_out.append({...})
    ...
```

Only the two added lines (`global_position = {...}` and the new dict entry) — every other field and the function's existing structure is untouched.

### `token-metering/frontend/src/api/types.ts`'s `TraceCall`

Add the new field:

```ts
export interface TraceCall {
  position: number;
  global_position: number;
  request_id: string;
  timestamp: string;
  ...
}
```

This is an additive API contract change — existing consumers of `TraceCall` that don't reference the new field are unaffected; only `SessionDrilldown.tsx` needs to change.

### `token-metering/frontend/src/components/SessionDrilldown.tsx`

Delete the duplicated-sort block entirely (current lines 21-31):

```ts
// server.py's `/api/call/<session>/<n>` numbers `n` across the *whole*
// session in chronological order (`calls.sort(key=(timestamp,
// request_id))` in `call_detail`), not per-agent like each trace row's
// own `position` (build_session_trace's per-agent `i + 1`). Recomputing
// that same global ordering here from `request_id` is what lets a
// trace row's detail toggle open the right call.
const globalPosition = new Map<string, number>();
trace.agents
  .flatMap((a) => a.trace)
  .sort((a, b) => (a.timestamp === b.timestamp ? (a.request_id < b.request_id ? -1 : 1) : a.timestamp < b.timestamp ? -1 : 1))
  .forEach((call, i) => globalPosition.set(call.request_id, i + 1));
```

`AgentRow`'s `globalPosition: Map<string, number>` prop is removed along with its threading through `SessionDrilldown`'s render (line 49) and `AgentRow`'s own signature (lines 57-69). The one call site that read from it:

```ts
onClick={() => onOpenCall(sessionId, globalPosition.get(call.request_id) ?? call.position)}
```

becomes:

```ts
onClick={() => onOpenCall(sessionId, call.global_position)}
```

No `?? call.position` fallback — `global_position` is always present on a `TraceCall` once the server change ships (an additive, non-optional field), so a fallback here would silently mask a real server/client version mismatch rather than surfacing it.

## Data flow

1. `TokenMeteringApp.session_trace()` calls `build_session_trace()` exactly as today; the returned dict now carries `global_position` on every trace entry, with no change to the method's own signature or the route dispatch in `handle_api()`.
2. The frontend's `useSessionTrace()` hook (`api/hooks.ts`) fetches the same `/api/session/<id>/trace` endpoint; its response now includes the new field, requiring no hook change beyond `types.ts`'s shape update.
3. `SessionDrilldown.tsx` reads `call.global_position` directly wherever it previously looked up its own computed map.

## Error handling

- A `TraceCall` from a stale cached response (e.g. `@tanstack/react-query`'s cache serving a pre-upgrade shape mid-deploy) missing `global_position` → not specially guarded; `docs/features/token-metering/03-architecture.md`'s existing deploy model (checked-in static build, no rolling API/frontend version skew within one dashboard load) means server and frontend ship together, so this isn't a runtime case this feature needs to handle, consistent with how every other additive field in `TraceCall`/`SessionTrace` is already treated.
- Two calls in the same session sharing an identical `(timestamp, request_id)` pair → cannot occur, since `request_id` is the `calls` table's primary key (`db.py`'s `CALLS_SCHEMA`) — `global_position`'s dict comprehension keys on `request_id`, so a collision is structurally impossible, not just unlikely.

## Testing

`tools/tokens/test_server.py` (extended, alongside the existing `test_session_trace_orders_calls_and_groups_by_agent` around line 208):

- `build_session_trace()`'s output assigns `global_position` values `1..len(calls)` in chronological order across the whole session, independent of which agent a call belongs to — a fixture with two agents interleaved in time (agent A's 2nd call happens after agent B's 1st) asserts agent A's later call gets a higher `global_position` than agent B's earlier one, while each agent's own `position` field still restarts at 1.
- `build_session_trace()`'s `global_position` for a given `request_id` matches what `call_detail()` independently computes as `n` for that same `request_id`, for the same set of calls — the regression check this whole spec exists to make impossible to violate silently again.

`token-metering/frontend`'s Playwright suite (`e2e/populated/dashboard.spec.ts`):

- Expanding an agent's row and clicking a trace row's detail toggle opens the correct call's detail (matching `request_id`), for a session with more than one agent — this already needs to be true today; the test change is to assert it post-refactor rather than relying on the now-deleted client-side sort to make it true.

Gate: `python tools/budget.py` clean; `python -m pytest tools/` green. `npm run build && npx playwright test` green inside `token-metering/frontend`, per `token-metering/.harness/workflow.md`. `docs/features/token-metering/03-architecture.md`'s Components/Data-flow sections don't need updating for this change (they describe the API at a level above individual field names), but if `specs/07-architecture-doc-staleness.md`'s correction hasn't shipped yet by the time this lands, no interaction between the two is expected either way.
