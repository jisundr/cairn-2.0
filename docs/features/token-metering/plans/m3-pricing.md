# Plan — Track B / M3: `prices.json` + `pricing.py`

Design: `../03-architecture.md` §Capture side ("Prices are looked up at read time..."). Pure data + pure function — no dependency on M1/M2's runtime, only on `db.py`'s row shape.

## Scope

- `token-metering/prices.json` — new, checked-in `model → $/MTok` table
- `token-metering/pricing.py` — new, read-time cost lookup
- `token-metering/test_pricing.py` — new

## Steps

1. **Worktree**: branch inside `token-metering/` for this sprint.
2. **Implement** — `cairn:builder`:
   - `prices.json`: current published per-model input/output (and cache-read/cache-write, matching `db.py`'s column granularity) rates for every model cairn is expected to run under.
   - `pricing.py`: a lookup function over a `calls`/`tool_uses`-shaped row (or rollup group) — unrecognized model → `cost: "unknown"` for that call; a rollup group containing any unpriced model → `cost: null`, never a silently-partial sum.
3. **Gate** — `pytest test_pricing.py` inside `token-metering/`.
4. **Manual test** — spot-check `prices.json`'s rates for 2-3 models against their current published pricing pages, since this table is the one piece of hand-entered data in the whole feature (everything else is derived). No end-to-end manual test possible yet — `server.py` (M4) is what actually calls this.
5. **Confirm tests** — known-model pricing, unknown-model → `"unknown"`, mixed-group rollup → `null` (per `../ROADMAP.md`'s M3 test list).
6. **PR** — `cairn:review-pr`, diff scoped to `prices.json`/`pricing.py`/tests.

## Done when

M3's gate in `../GOAL-CONDITION.md` is satisfied and its PR has merged. Flip M3 in `../GOAL-STATE.md`, log it — Track B is done. M3 merging is also one of the two conditions gating Track A's M4 sprint (the other being M1).
