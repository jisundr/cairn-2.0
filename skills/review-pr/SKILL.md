---
name: review-pr
description: Reviews an open PR/MR from the main thread — delegates finding-work to the native code-review skill, checks the diff against cairn's security checklist and fix-lane tags, and gates posting behind explicit confirmation.
---

# cairn:review-pr

## Resolve the target

Host from the URL (`github.com` → `gh`, a GitLab host → `glab`). Neither CLI resolves, or isn't authenticated for that host → report and point at that CLI's own login command, stop.

## First review

1. Run `Skill(skill: "code-review", args: "<target> --comment")` for the full correctness/reuse/simplification/efficiency pass.
2. Load `Skill(skill: "cairn:shared")` and check the diff against its `reference/security-checklist.md` — a Critical or High finding fails the review. Tag any reuse/simplification/efficiency finding from step 1 with `reference/fix-lanes.md`'s Lane A/B — classification only, nothing auto-applied.
3. Present the combined findings as a draft; iterate freely, no gate yet.
4. `AskUserQuestion` — confirm before posting anything. On yes, post via step 1's own `--comment` mechanism.
5. Offer to keep monitoring the MR going forward. Declining is a clean no-op — no watcher, no state left behind.
