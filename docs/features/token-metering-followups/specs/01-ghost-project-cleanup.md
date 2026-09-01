# Spec: ghost-project cleanup

Implementation spec for `requirements.md` issue 1 / goal 1. Pins down the exact fix so `builder` can implement without re-deciding shape.

## Architecture

Read-time pruning: `discover_projects()` skips a `known-projects.json` entry whose resolved path no longer exists on disk, rather than turning it into a `Project`. No write to `known-projects.json` itself, no hook into worktree teardown.

Chosen over a write-time GC (something removing the entry when a worktree is torn down) because the only place that currently touches `known-projects.json` is `hooks/stop-tokens.sh`'s append-only block (lines 46-50), which fires on `Stop`, not on worktree teardown — there is no existing hook point for `ExitWorktree` (or equivalent) to react to. Wiring one would mean either adding a new hook cairn doesn't have today, or teaching an existing hook about worktree lifecycle it doesn't otherwise need to know about. Read-time pruning needs neither: `discover_projects()` already resolves every path in the file every time it runs (`tools/tokens/server.py:121`), so an existence check is a one-line addition to a loop that already runs, with no new failure mode (a stat call that can raise `OSError` on a permissions-denied parent directory is handled the same defensive way the file read already is, at lines 108-111).

**Tradeoff, left unresolved by design (see `requirements.md`'s Open questions):** `known-projects.json` itself never shrinks under this approach — a torn-down worktree's path stays listed in the file forever, just filtered out of what's displayed. On a machine that creates and tears down many worktrees over months, the file grows without bound even though the UI stays clean. If that ever matters in practice (file large enough to affect the per-request read in `discover_projects()`, or a user wanting to audit what's in the file), a future write-time GC can be layered on top of this without conflicting with it — the read-time check stays correct either way. Not solved here because there's no hook point to solve it at yet, and the file's per-entry size (one string) means it would take a very large number of stale entries before the read-time cost of parsing it becomes material.

## Components

### `tools/tokens/server.py`'s `discover_projects()` (and `token-metering/server.py`'s identical copy — see `specs/06-vendoring-drift-guard.md`)

Current loop body (lines 117-125):

```python
if isinstance(entries, list):
    for entry in entries:
        if not isinstance(entry, str) or not entry:
            continue
        other_root = Path(entry).resolve()
        if other_root in seen:
            continue
        seen.add(other_root)
        roots.append(other_root)
```

New loop body — one additional guard, same style as the existing `isinstance`/`in seen` checks:

```python
if isinstance(entries, list):
    for entry in entries:
        if not isinstance(entry, str) or not entry:
            continue
        other_root = Path(entry).resolve()
        if other_root in seen:
            continue
        if not other_root.is_dir():
            continue
        seen.add(other_root)
        roots.append(other_root)
```

`is_dir()` (not `exists()`) matches what a project root actually is — a directory — and is already the check style `db_path()`/`Project.db_path` implicitly assume elsewhere in this file. A path that exists but isn't a directory (e.g. clobbered by a stray file) is treated the same as one that doesn't exist: skipped.

No change to `Project`, `_disambiguate_labels()`, or `_filter_projects()` — they operate on whatever `roots` ends up containing, unaware of where those roots came from.

## Data flow

1. `discover_projects()` reads `known-projects.json` exactly as today (unchanged: existence check on the file itself, `json.loads`, `isinstance(entries, list)` guard).
2. For each entry, resolve to a path, skip if already seen (unchanged), then skip if the resolved path is not currently a directory (new).
3. Surviving roots are labeled and returned exactly as today.

`known-projects.json` on disk is untouched by this change in every case — the function only ever reads it.

## Error handling

- A `known-projects.json` entry pointing at a path removed since the file was last written → silently excluded from the returned project list, same silent-degradation style as an unparseable JSON entry or a non-string entry already handled in this function.
- A path that exists but has since become a plain file rather than a directory → also excluded (`is_dir()` covers both cases in one check).
- A path on an unmounted/inaccessible volume that raises on `is_dir()` (e.g. an `OSError` from a stale network mount) → not currently guarded; if `is_dir()` can raise in practice for such a path, wrap the check in the same `try/except OSError` style already used for `path.read_text()` (lines 108-111), treating a raise as "not present" (skip). Confirm during implementation whether `pathlib.Path.is_dir()` on this codebase's supported platforms ever raises rather than returning `False` for an inaccessible mount before adding the `try/except` — Python's own docs note it returns `False` on most `OSError` cases already, so the wrapper may be unnecessary.

## Testing

`tools/tokens/test_server.py` (extended, same `tmp_path` + literal-JSON style as `test_discover_projects_disambiguates_colliding_last_segment_labels`, line 282):

- A `known-projects.json` entry pointing at a directory that exists → included in `discover_projects()`'s result (regression check — today's passing tests already cover this implicitly, since their fixture directories exist; make it explicit).
- A `known-projects.json` entry pointing at a path that does not exist on disk → excluded from `discover_projects()`'s result, and does not raise.
- A `known-projects.json` entry pointing at a path that exists but is a file, not a directory → excluded.
- A `known-projects.json` file with a mix of existing and non-existing entries → only the existing ones appear, in the same relative order as before pruning (pruning doesn't reorder).
- `known-projects.json` itself is unchanged on disk after a call to `discover_projects()` that pruned an entry (read the file's bytes before and after, assert equality) — confirms this is read-time-only, not a write-time GC.

Same tests apply verbatim to `token-metering/test_server.py` once `specs/06-vendoring-drift-guard.md`'s sync process carries this fix across.

Gate: `python tools/budget.py` clean; `python -m pytest tools/` green (this repo). `pytest test_server.py` inside `token-metering/`, per that repo's own `.harness/workflow.md`, once the fix is mirrored there.
