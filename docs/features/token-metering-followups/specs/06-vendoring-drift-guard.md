# Spec: catch drift between `tools/tokens/` and `token-metering/`'s frozen backend copy

Implementation spec for `requirements.md` issue 6 / goal 6. A verification script plus one new, separate CI job — not a change to the existing `budget` job, for a reason specific to this repo's CI setup (see Architecture).

## Architecture

The two candidate approaches named in the issue were a diff-based test/CI check, or a documented single-source-of-truth + sync process. A documented-process-only fix was rejected: `docs/tasks/vendor-token-metering-backend/plan.md`'s Decision 2 already documents the intended relationship (`tools/tokens/` is the live source, `token-metering/`'s backend copy is frozen, kept only for that repo's own frontend e2e fixtures) — the gap isn't missing documentation, it's that nothing *checks* the documented invariant holds. A mechanical check is proportional here precisely because the invariant is simple (byte-for-byte equality of a fixed file list) and already has a natural place to run.

The mechanical check itself is one script, not a test in the usual `pytest` sense — it needs both trees present to compare, and `tools/tokens/test_*.py`'s existing gate (`python -m pytest tools/`) runs in CI without the `token-metering` submodule checked out (`.github/workflows/ci.yml`'s `actions/checkout@v4` doesn't set `submodules: true` — deliberately, per `plan.md` Decision 3, as the standing regression check that an installed plugin works with the submodule absent). A `pytest` test under `tools/tokens/` that tries to diff against `token-metering/` would either fail every CI run (submodule never present) or have to silently skip when the submodule's absent — and a check that's silently skipped in its only automated run is worse than no check, since it creates false confidence. So this check does **not** live in `tools/tokens/test_*.py` or run as part of the existing `budget` CI job.

Instead: a standalone script, and a **second, separate CI job** that explicitly checks out submodules (only for that job), runs the script, and fails the build on mismatch. This keeps the existing `budget` job's submodule-absent condition exactly as it is today (nothing added to it, nothing about its checkout step changes) while giving the drift check a job where the comparison is actually possible. The two jobs run independently and in parallel; a drift-guard failure doesn't block or interact with the budget job's own pass/fail.

## Components

### `tools/tokens/check_vendoring_sync.py` (new)

```python
#!/usr/bin/env python3
"""Fails if tools/tokens/ and token-metering/ disagree on any file both
should carry byte-for-byte, per docs/tasks/vendor-token-metering-backend/
plan.md's Decision 2. Requires the token-metering submodule checked out
(git submodule update --init) - not run by tools/budget.py or the
existing CI job, both of which intentionally run without it. See
docs/features/token-metering-followups/specs/06-vendoring-drift-guard.md.
"""
import filecmp
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
VENDORED_FILES = [
    "db.py",
    "parser.py",
    "pricing.py",
    "prices.json",
    "server.py",
    "test_db.py",
    "test_parser.py",
    "test_pricing.py",
    "test_server.py",
]


def main() -> int:
    submodule_dir = REPO_ROOT / "token-metering"
    if not (submodule_dir / "server.py").exists():
        print("token-metering/ submodule not initialized - run "
              "`git submodule update --init` before this check.", file=sys.stderr)
        return 1

    mismatches = []
    for name in VENDORED_FILES:
        vendored = REPO_ROOT / "tools" / "tokens" / name
        submodule = submodule_dir / name
        if not vendored.exists() or not submodule.exists():
            mismatches.append(f"{name}: missing from one side (tools/tokens/={vendored.exists()}, "
                               f"token-metering/={submodule.exists()})")
            continue
        if not filecmp.cmp(vendored, submodule, shallow=False):
            mismatches.append(f"{name}: content differs between tools/tokens/ and token-metering/")

    if mismatches:
        print("Vendoring drift detected (tools/tokens/ vs token-metering/):", file=sys.stderr)
        for m in mismatches:
            print(f"  - {m}", file=sys.stderr)
        print("\nSync the two copies per docs/tasks/vendor-token-metering-backend/"
              "plan.md's Decision 2, or update VENDORED_FILES if the intended set changed.",
              file=sys.stderr)
        return 1

    print(f"tools/tokens/ and token-metering/ agree on all {len(VENDORED_FILES)} vendored files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

Plain stdlib (`filecmp`, `pathlib`), consistent with `tools/tokens/`'s existing zero-pip footprint. Not registered as a `pytest` test (per Architecture's reasoning) and not one of `tools/budget.py`'s own checks — it's invoked directly by the new CI job and by a maintainer locally after touching either copy. `static/index.html` and `static/assets/*` are deliberately excluded from `VENDORED_FILES` — those are frontend build output, already covered by a different consistency question (whether the checked-in `static/` matches the current `frontend/` source, which is `token-metering/`'s own `npm run build` gate, not this script's concern).

### `.github/workflows/ci.yml` — new job

```yaml
  vendoring-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: python tools/tokens/check_vendoring_sync.py
```

Added as a sibling job to the existing `budget` job, not a step within it — a separate job gets its own checkout, so `submodules: true` here has no effect on `budget`'s checkout (each job in a GitHub Actions workflow runs on its own fresh runner/checkout). Both jobs must pass for CI to go green overall (GitHub's default "all jobs required" behavior, matching how a two-job matrix already behaves without any extra `needs:`/`required` configuration).

## Data flow

1. On every push/PR, GitHub Actions runs `budget` (submodule absent, exactly as today) and `vendoring-drift` (submodule initialized) as two independent jobs.
2. `vendoring-drift` compares each of the nine listed files byte-for-byte between `tools/tokens/` and `token-metering/`.
3. Any mismatch (content differs, or a file exists on only one side) fails the job with a message naming the specific file(s) and pointing at the sync process to resolve it.
4. A maintainer syncing a fix from one copy to the other (or intentionally vendoring a new file) re-runs `python tools/tokens/check_vendoring_sync.py` locally (after `git submodule update --init`) before pushing, to catch drift before CI does.

## Error handling

- `token-metering/` submodule not initialized when the script runs (e.g. a maintainer runs it locally without having pulled the submodule) → clear stderr message naming the fix (`git submodule update --init`), exit code 1 rather than a raw `FileNotFoundError` traceback.
- A file present in `tools/tokens/` with no corresponding file in `token-metering/` (or vice versa) — e.g. one side gained a new test file the other hasn't picked up yet → reported as a mismatch by name, same as a content difference, rather than silently skipped.
- `VENDORED_FILES` itself going stale (a new file added to one copy but never added to this list) is not detected automatically — this is the one gap in the guard's own coverage, called out here rather than silently assumed away: the list needs a manual update whenever the vendored file set changes, same as any other explicit allowlist. Left as-is rather than auto-discovering the file set (e.g. "every `.py` file in both directories") because auto-discovery would also need to exclude `token-metering/`'s submodule-only files (`README.md`, `CLAUDE.md`, `.harness/`, `frontend/`) that were deliberately never vendored (`plan.md` Decision 1) — an explicit list is clearer about intent than an exclusion pattern that has to enumerate everything vendoring intentionally left out.

## Testing

This script is itself the test for the invariant it guards; it doesn't need its own `pytest` suite given its size, but a minimal self-check keeps it from silently breaking:

- Manual/CI verification: intentionally edit one line in `tools/tokens/pricing.py` without touching `token-metering/pricing.py`, run the script, confirm it exits 1 and names `pricing.py` specifically — done once during implementation to confirm the script actually detects drift, not committed as a permanent test fixture (there's no clean way to fixture "two directories deliberately out of sync" without maintaining a stale-by-design test double).
- Confirm a clean run (both copies in sync, current state) exits 0 with the "agree on all 9" message — the actual state at merge time.

Gate: `python tools/tokens/check_vendoring_sync.py` exits 0 against a submodule-initialized checkout, added as CI's new `vendoring-drift` job. Not part of `python tools/budget.py` or `python -m pytest tools/` (Architecture's reasoning) — `.github/workflows/ci.yml`'s existing `budget` job is otherwise untouched.
