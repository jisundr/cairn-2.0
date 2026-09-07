# Plan — dashboard contrast + transcript redesign (supersedes prior plan.md)

Two independent changes, both per `requirements.md` (settled source of truth):
(A) WCAG-failing color tokens in `index.css`, and (B) `SessionDrilldown.tsx`'s
chat-thread rebuilt as a turn-grouped conversation with inline tool actions,
requiring `server.py`'s on-demand transcript-read layer to grow a field and
the now-redundant "view full detail" UI/route to be removed. Nothing in
`pricing.py`/`parser.py`/`db.py`, the SQLite schema, or the frozen
mockup/layout language is touched. Supersedes the prior plan's Actionable 5
("server.py — no change") and its client-side dedup — Goal 6/7 requires
tool-call data from a new `CallDetail` field, server-extracted like
`prompt`/`response`, never persisted to `tokens.db`.

**Mid-build exception** (see `requirements.md`'s Non-goals): `--ch2` also
needed darkening — its original hex only cleared 4.37:1 against `--bone-dim`,
leaving no room for `--ch3` to be both lighter (Goal 2) and AA (Goal 1).
User approved re-deriving the whole ch1–ch4 ramp; `--ch2` is in scope for
Actionable 1 despite being listed unchanged below.

## Scope (paths, from requirements.md)

- `token-metering/frontend/src/index.css`
- `token-metering/frontend/src/components/SessionDrilldown.tsx`
- `token-metering/frontend/src/components/SessionsTable.tsx`
- `token-metering/frontend/src/components/ui/tabs.tsx`
- `token-metering/server.py`
- `token-metering/frontend/src/api/types.ts`
- `token-metering/frontend/src/App.tsx`, `Dashboard.tsx`
- `token-metering/frontend/src/routing.ts` (deleted)
- `token-metering/frontend/src/api/hooks.ts`
- `token-metering/frontend/src/components/TraceDetailContent.tsx`,
  `TraceDrawer.tsx`, `CallPage.tsx` (all deleted)
- `token-metering/frontend/e2e/populated/dashboard.spec.ts`,
  `timezone.spec.ts`, `e2e/fixtures/seed.py`
- `docs/DESIGN.md`
- `tools/tokens/` (server.py mirror, static/ re-vendor, test_server.py mirror)

Out of scope (confirmed unchanged): `pricing.py`/`parser.py`/`db.py` and the
SQLite schema; `mockups/dashboard.html`; `--signal`, `--signal-soft`,
`--signal-line`, `--ink`, `--ink-soft`, `--ch1`, `--window`, `--bone`,
`--bone-dim`, `--block` hex values (`--ch2` is the approved exception above);
any replacement deep-linking mechanism for `/call/<session>/<n>` (the backend
route itself is kept, per requirements.md's non-goals).

## Part A — Contrast

1. **`index.css` — raise `--ink-faint`, `--ch2`, `--ch3`, `--ch4` to AA**: new
   hex values for these custom properties (and `@theme` `--color-*` mirrors)
   so each clears 4.5:1 against `--window`/`--bone`/`--bone-dim` (the binding
   case, L≈0.725). Preserve ordering — `ink` < `ink-soft` < `ink-faint`;
   `ch1` < `ch2` < `ch3` < `ch4`. `ch1`/`ink`/`ink-soft` untouched. `--ch3`/
   `--ch4`'s new values apply everywhere those tokens are used as fills too
   (agent-select checkbox swatches, mini-bars in `SessionDrilldown.tsx`) —
   these reference the CSS custom properties by name so need no code change,
   just a visual recheck (Actionable 12).

2. **`index.css` + `SessionsTable.tsx` + `ui/tabs.tsx` — new `--signal-ink`
   token**: add `--signal-ink` (+ `--color-signal-ink`), a color clearing
   4.5:1 against unchanged `--signal` (#c1741c) — no light color, including
   `--ink`, clears that bar, so this must be new and dark. Swap
   `text-(--window)` to `text-(--signal-ink)` in the only two places pairing
   `bg-(--signal)` with light text: `SessionsTable.tsx`'s `FilterPill` and
   `ui/tabs.tsx`'s `Tabs`. `--signal`/`--signal-soft`/`--signal-line` stay
   byte-for-byte unchanged elsewhere (dots, borders, wash fills).

3. **`docs/DESIGN.md` — sync the source-of-truth**: update the frontmatter
   `colors:` block (ink-faint/ch2/ch3/ch4 hex; add signal-ink); update
   `components.chart-tab-active.textColor`/`pill-active.textColor` from
   `{colors.window}` to `{colors.signal-ink}`; update the Colors-section prose
   for the changed tokens and add one bullet introducing `--signal-ink`.
   Leave every other Colors/Named-Rules sentence as-is.

4. **Contrast verification (throwaway script, not shipped)**: implement the
   standard WCAG relative-luminance formula and confirm every pairing clears
   4.5:1 before treating 1–3 as done. Check: ink-faint/ch2/ch3/ch4 vs
   window/bone/bone-dim; signal-ink vs signal.

## Part B — Transcript redesign

5. **`server.py` — extract tool-call info alongside prompt/response**:
   `_extract_call_content` currently collects only `type == "text"` blocks
   and drops `tool_use` blocks. Extend it to also collect, in encounter order
   per `request_id`, one `{name, summary}` per `tool_use` block: `summary`
   from `block["input"]` via a small per-tool-name field mapping (mirroring
   `parser.py`'s `skill` pattern) — `file_path` for `Read`/`Write`/`Edit`/
   `NotebookEdit`, `command` for `Bash`, `pattern` for `Grep`/`Glob`, `url`
   for `WebFetch`, `description` for `Task`, `skill` for `Skill` — `""` when
   unmapped/non-string. Return as a third tuple element; `call_detail()`
   unpacks it into `"tool_calls"` (`[]` when unavailable). No change to
   `_tool_result_text`/`_is_tool_result_only`, `db.py`, `parser.py`, or the
   `tool_uses` table.

6. **`api/types.ts`**: add `tool_calls: { name: string; summary: string }[]`
   to `CallDetail`. `api/client.ts`/`api/hooks.ts`'s `useCallDetails` need no
   change — they pass the JSON envelope through.

7. **`SessionDrilldown.tsx` — turn-grouped rendering**: replace "one
   `ChatTurn` per call" with "one per human turn":
   - Per agent, using `AgentTrace.trace`'s own chronological order (never
     merged `global_position` — a subagent's calls come from a separate
     transcript file), group consecutive calls into a turn while both the
     current and immediately preceding same-agent call's detail have loaded,
     both are `available`, and the current call's `prompt` non-emptily
     equals the previous one's. Unloaded previous detail → don't merge (fail
     safe).
   - Merge agents' turns into one sequence ordered by each turn's first
     call's `global_position` (today's continuous-thread behavior); agent-
     select dimming stays call-agent-based, per turn.
   - Render each turn: the human prompt once (left bubble, today's
     `ChatBubble` role="prompt" styling); then per call in order, its
     metadata line (agent · position · timestamp · model · tokens · cost ·
     duration, inline, not hidden) followed by its tool-action lines — one
     per `tool_calls` entry, a verb-by-tool-name map (`Read`, `Write`,
     `Edit`→"Edited", `Bash`→"Ran", `Grep`/`Glob`→"Searched",
     `WebFetch`→"Fetched", `Task`→"Dispatched", `Skill`→"Invoked", else bare
     name) plus the summary when non-empty; then the turn's final reply —
     last call's `response`, only if non-empty — as a right bubble in
     `--ch1-soft`. Empty final response → turn ends after its action lines,
     no empty bubble ever.
   - Remove "view full detail" button/`view-full-detail-*` testid;
     `SessionDrilldownProps` drops `onOpenCall`; `Dashboard.tsx` call site
     drops the prop.
   - `ChatBubble`'s "Transcript unavailable." case is unchanged.

8. **Remove the frontend "view full detail" surface**: delete
   `TraceDetailContent.tsx`, `TraceDrawer.tsx`, `CallPage.tsx`, `routing.ts`
   (confirmed by grep: no other importer). `App.tsx` renders `<Dashboard />`
   with no props (drop `CallRoute`/`parseCallRoute`/`callRoutePath`,
   `standaloneCall`/`drawerCall` state, `openCall`/`closeDrawer`/
   `viewFullPage`/`backToDashboard`, `<CallPage>` branch). `Dashboard.tsx`
   drops `onOpenCall`/`drawerCall`/`onCloseDrawer`/`onViewFullPage` props,
   the `TraceDrawer` import/render, and the prop passed to
   `<SessionDrilldown>`. `api/hooks.ts` deletes singular `useCallDetail`
   (only callers deleted); plural `useCallDetails`/`api.callDetail` kept —
   `SessionDrilldown.tsx` keeps using them. Backend `/call/<session>/<n>`
   unchanged in shape apart from Actionable 5's additive field.

9. **`e2e/fixtures/seed.py` + `dashboard.spec.ts` + `timezone.spec.ts`**:
   `seed_transcript()` has no `tool_use` blocks and no two same-agent calls
   sharing a prompt — extend its `AVAILABLE_REQUEST_ID` assistant entry with
   a `tool_use` block (e.g. `Read` with `input.file_path`); confirm
   `dashboard.spec.ts`'s chat-thread tests pass against the turn-grouped
   structure (`chat-turn-*` testids become per-turn, suffixed by the turn's
   first call's `global_position`). Remove drawer/full-page/standalone-load
   tests and the "call detail deep link" `describe` block
   (`/call/e2e-session-main/1`, `/2`). `timezone.spec.ts`'s standalone-page
   test loads `/call/tz-demo/1` directly — port to the drilldown's inline
   timestamp: intercept `/api/session/tz-demo/trace` and
   `/api/call/tz-demo/*` so the thread renders a call at
   `2026-06-15T13:45:30Z`, assert the turn's metadata line contains
   `09:45:30` not `13:45:30`. Other `timezone.spec.ts` tests unaffected. No
   existing e2e assertion targets `text-(--window)` (checked by grep).

## Gate, re-vendor, review

10. **Gate** (`token-metering/.harness/workflow.md`): `pytest test_*.py` in
    `token-metering/` (extend `test_server.py` for the new `tool_calls`
    field/mapping); `npm run build` in `frontend/` (regenerates `static/` —
    commit the rebuild, never hand-edit); `npx playwright test` against that
    build.

11. **Re-vendor**: `server.py`/`test_server.py` are `check_vendoring_sync.py`
    byte-for-byte `VENDORED_FILES` — copy the updated files into
    `tools/tokens/` after Actionable 5/10. Re-vendor `tools/tokens/static/`
    from the fresh build output. Run `check_vendoring_sync.py` and
    `tools/budget.py` in the outer repo, confirm clean.

12. **Manual check** (`cairn:run`), against a real captured session with a
    multi-tool-call human turn and a pure-tool-use call: confirm prompt shown
    once, tool actions inline in order, final reply only if produced,
    per-call metadata visible throughout; confirm the pill/tab active-state
    text reads clearly with `--signal-ink`; confirm ch2–ch4's new values
    still read as distinct channel colors.

13. **Review** — `cairn:reviewer` agent (established preference over the
    `review-pr` skill), scoped to this diff only.

14. **PR** — opened inside the `token-metering` submodule, scoped to this fix
    only; description calls out the `--ch2` exception as a deliberate,
    user-approved deviation from the original requirements doc.

## Done when

`--ink-faint`/`--ch2`/`--ch3`/`--ch4` each clear 4.5:1 against
`--window`/`--bone`/`--bone-dim`; `--signal-ink` clears 4.5:1 against
`--signal` and is the only light text on a `--signal` fill; ordering
preserved; `docs/DESIGN.md` matches shipped hex; drilldown for a multi-tool
human turn shows its prompt exactly once, tool calls as inline action lines
in order, final reply if any, per-call metadata inline, no blank bubble; no
"view full detail" control, `/call/<session>/<n>` frontend route, or
`TraceDetailContent`/`TraceDrawer`/`CallPage` remains, backend endpoint still
works; `pytest`/`npm run build`/`npx playwright test` green, with
`dashboard.spec.ts`'s drawer/standalone tests removed and `timezone.spec.ts`'s
`formatTimeOfDay` coverage ported; `tools/tokens/` re-vendored and
`python tools/budget.py` clean in the outer repo.

## Risks

- **Tool-call summary field mapping (Actionable 5) is this plan's own
  choice**, not dictated by `requirements.md` beyond "tool name + short
  summary." Covers common cases, not exhaustive; unmapped tool falls back to
  bare name — confirm against a real multi-tool session (Actionable 12).
- **Turn-merging has a load-order race**: `useCallDetails` fetches each
  call's detail independently with no ordering guarantee, so boundaries can
  shift mid-load. Fails safe (never merges speculatively).
- **`e2e/fixtures/seed.py` changes touch a shared fixture** (tool-rollup
  counts, agent dominance, request IDs) — the added `tool_use` block must not
  change `EXTRA_TOOL_NAMES`-derived counts or request-id-keyed assertions;
  verify the full suite, not just the tests this plan names.
