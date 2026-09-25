---
description: Sorts task folders.
---

Read-only. Never writes, never blocks. Per-folder facts are `/cairn-doctor` step 8; this only sorts them.

1. **Scan** — `Glob` `docs/tasks/**/STATE.md` (not `Grep`: `docs/tasks/` is gitignored), skipping `_template/`. From each, read `key_info` and the last `YYYY-MM-DD:` log line; none → the folder name's date. Folders without `STATE.md` (a `review` `DRAFT.md`) go on one trailing line.
2. **Branching** — `.harness/workflow.md`'s `## Branching` says commits go straight to main or no feature branches → direct-commit. Section absent → not.
3. **Classify** — first match wins:
   - **Needs attention now** — `needs-human` or `stalled` in `key_info` (`skills/start/reference/unattended.md` Ending).
   - **Ready to close** — whole-word `done`/`close(d)`/`complete`, any case, as `key_info`'s own status, not history or negated. Not direct-commit: or `gh pr list --head <folder-name> --state merged --json number -q 'length'` = `1`; output other than `0`/`1` → go by `key_info`. Direct-commit or `research` folder: skip `gh`.
   - **Still in progress** — last log date within 14 days of the newest log date across all folders.
   - **Looks abandoned** — older than that.
4. **Report** — four headings in that order, "none" if empty; name the anchor date. One line per folder, sub-tasks indented: name, deciding marker or last log date, and for Ready to close whether `key_info` or `gh` decided. No full `key_info`, no file written.
