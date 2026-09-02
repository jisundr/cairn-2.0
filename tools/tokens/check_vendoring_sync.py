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
