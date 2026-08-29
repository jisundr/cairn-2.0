# Goal condition: token metering & dashboard

**Entry point for this feature** — read this file first when resuming or checking status; only open `GOAL-STATE.md` (full log + detailed milestone checklist), `GOAL.md` (process), or the design docs (`01-intent.md`/`02-requirements.md`/`03-architecture.md`) when the task at hand actually needs that detail, not by default.

Definition of done — the conditions that must hold for this feature to be considered complete.

## Current status

**On resume, before starting anything new: for any track below marked "PR open," check whether that PR has merged** (a sprint is published when its PR opens, but only closes on merge — see `GOAL.md`'s per-sprint steps). If merged, update this section and `GOAL-STATE.md` per `GOAL.md`'s resume instructions, then proceed; if not, work a different unblocked track or stop here.

M1 and M3 merged. Sprints run as three parallel tracks (full rationale: `GOAL.md`'s Sprint sequence table):

- **Track A — M1**: merged (https://github.com/jisundr/cairn-2.0-token-metering/pull/2). Track A continues into **M4** (`server.py`) — unblocked now that M1 **and** M3 are both merged — [plan](plans/m4-server.md).
- **Track B — M3**: merged (https://github.com/jisundr/cairn-2.0-token-metering/pull/1). Track B is done — it had only the one sprint.
- **Track C — M2** (`hooks/stop-tokens.sh`): unblocked now that M1 is merged — [plan](plans/m2-stop-hook.md).
- M5/M6 ([plans](plans/README.md)) still can't start until their own "Starts after" condition in `GOAL.md`'s table is merged.

Full history and reasoning behind each of these: `GOAL-STATE.md`'s Log.

## Known issues (check before starting new work)

Bugs hit mid-sprint that weren't fixed on the spot — a resuming session should address or consciously re-defer these before starting a new sprint on the affected track. Empty means none open.

*(none open)*

## Done when (overall)

- [ ] Running `/cairn-tokens` after a cairn session spanning multiple agent dispatches starts a local dashboard whose per-day/per-agent rollups sum to a plausible total against the transcript.
- [ ] Expanding an agent's rollup row in the per-session view reveals its call-by-call trace, in order, with per-call tokens/cost/duration.
- [ ] A deliberately triggered usage-limit event surfaces in the dashboard's warning banner rather than being folded into ordinary usage.
- [ ] Re-processing an already-recorded session's data does not double-count (idempotent on `request_id` / `tool_use_id`).
- [ ] No `npm`/`node` invocation is required on the machine running `/cairn-tokens`.

## Per-milestone gate

Each milestone's own condition — pulled from `ROADMAP.md`. A milestone isn't done until its gate passes, independent of the others.

- **M1**: `pytest test_db.py test_parser.py` green inside `token-metering/` — covers main+subagent attribution, dup `requestId`, dup `tool_use_id`, unmatched `agentId` → `"unknown"`, usage-limit routing.
- **M2**: `hooks/stop-tokens.sh --selftest` passes; `python tools/budget.py` clean; second `Stop` on the same session doesn't duplicate rows.
- **M3**: `pytest test_pricing.py` green — known-model pricing, unknown-model → `"unknown"`, mixed-group rollup → `null`.
- **M4**: `pytest test_server.py` green — rollup correctness (incl. `tool_uses` + heatmap), trace ordering, unpriced-model `null` propagation, cross-project union.
- **M5**: `npm run build` regenerates `token-metering/static/`; `npx playwright test` green against that build, covering every `mockups/dashboard.html` state (empty, populated, trace expansion, transcript-unavailable, usage-limit banner) plus the `/call/<session>/<n>` deep-link route; manual check remains only for the 15s-poll timing behavior.
- **M6**: full §A13 gate + relevant §B12 acceptance criteria; manual end-to-end run (real session, ≥1 subagent, `Stop` fires, `/cairn-tokens`, confirm rollups/trace/banner/idempotency).

## Invariants (must stay true throughout, not just at the end)

- Capture is advisory-only — a hook failure or missing opt-in never blocks or alters a session (silent `exit 0`).
- No prompt/response text is duplicated into `tokens.db` — always read on demand from the transcript file.
- Pricing is applied at read time only, never at write time — a price-table update never requires a data migration.
- Data and server stay local to the developer's machine — no shared or remote datastore, even when unioning across projects at user/local install scope.
- `tools/budget.py` covers only artifacts shipping from this repo (`hooks/`, `commands/`) — the submodule gates itself.

## Explicitly out of scope (not a failure to satisfy these)

- Real-time push / live-stream of an in-progress session.
- Billing, invoicing, or cost-recovery.
- Metering a session cairn's hooks didn't capture.
- A shared/remote datastore or multi-machine access.
- A native desktop app.

## Backlog (deferred, not scheduled to a milestone)

Ideas raised during the build that aren't part of any milestone's scope — pick up only if explicitly prioritized later.

- **`prices.json` staleness**: M3 ships it as a hand-maintained, checked-in table with no update trigger — a rate that drifts from Anthropic's published pricing goes undetected (only a model *absent* from the table hits the `"unknown"` path). No mechanism today beyond M3's one-time manual spot-check (`plans/m3-pricing.md` step 4). If ever prioritized: a periodic reminder, a script diffing `prices.json` against the published pricing page, or a live pricing API lookup — the last of which would need to be reconciled with the read-time-only, no-migration invariant above.
