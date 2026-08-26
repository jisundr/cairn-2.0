---
name: review-pr
description: Reviews an open PR/MR from the main thread — delegates finding-work to the native code-review skill, checks the diff against cairn's security checklist and fix-lane tags, and gates posting behind explicit confirmation.
---

# cairn:review-pr

## Resolve the target

Host from the URL (`github.com` → `gh`, a GitLab host → `glab`). Neither CLI resolves, or isn't authenticated for that host → report and point at that CLI's own login command, stop.

## Mode detection

Read the PR/MR's existing comments/discussions. Carries a `## Finding N` heading (or equivalent) from a prior run of this skill → Re-review. Otherwise → First review. The caller names Final review explicitly (e.g. "let's do the final pass") rather than this being auto-detected.

## Reference

| File | Load when |
|---|---|
| reference/draft-template.md | Drafting findings (First review step 3) or round replies (Re-review step 3) — the format to present and, once confirmed, post. |

## First review

1. Run `Skill(skill: "code-review", args: "<target> --comment")` for the full correctness/reuse/simplification/efficiency pass.
2. Load `Skill(skill: "cairn:shared")` and check the diff against its `reference/security-checklist.md` — a Critical or High finding fails the review. Tag any reuse/simplification/efficiency finding from step 1 with `reference/fix-lanes.md`'s Lane A/B — classification only, nothing auto-applied.
3. Present the combined findings as a draft, in the template's First review format; iterate freely, no gate yet.
4. `AskUserQuestion` — confirm before posting anything. On yes, post via step 1's own `--comment` mechanism.
5. Offer to keep monitoring the MR going forward. Declining is a clean no-op — no watcher, no state left behind.

## Re-review

1. For each prior finding, diff the current code against it: `fixed` / `partially-fixed` / `still-open` / `disputed`.
2. Rerun First review's steps 1–2, scoped to what changed since the last round, to catch anything new.
3. Draft a dated round reply per prior finding (ack fixes, hold open what isn't) plus any new finding from step 2, in the template's Re-review round format.
4. `AskUserQuestion` gate, then post — same as First review step 4.

## Final review + manual QA

1. Rerun First review's steps 1–2, scoped to what's changed since the last round, to catch regressions the fixes may have introduced.
2. Clean → `Skill(skill: "cairn:run")` to launch the app. Unavailable or fails to start → report it, ask the user to confirm manual QA is otherwise covered; don't block approval on it.
3. Hand off for human manual QA. A reported problem loops back to Re-review's assessment step rather than starting over.

## Approval + cleanup

1. Stop whatever Final review's `cairn:run` started.
2. Approve the MR and post a final summary comment, using the merge method / push-safety convention from `workflow.md`'s `## Commits / PR`. Convention undocumented → ask once; never guess a merge command.
3. Stop referencing the findings draft — nothing is persisted to disk to clean up.
4. Report done.
