---
name: draft-template
description: The structured format review-pr presents combined findings in before posting — one header per PR/MR, one block per finding, plus a dated section for each re-review round.
---

# Draft template

`SEVERITY` is Critical/High/Medium/Low from `reference/security-checklist.md` for a security finding, or Blocking/Suggestion for anything else. `CATEGORY` is the finding's own category — the security checklist's category name, or the code-review category with its fix-lane in parentheses (e.g. `simplification (Lane A)`).

## First review

````markdown
# <PR #<number> | MR !<IID>> — <Short Title> (<repo>)

**URL**: <PR/MR URL>
**Branch**: `<source-branch>` → `<target-branch>`
**Diff refs**: base `<base_sha>` / head `<head_sha>`

Status: <draft reviewed and approved by user as-is | pending user review>

---

### [SEVERITY] `CATEGORY` — `file:line`
```<language>
<offending snippet>
```
<why this is in scope — tie back to the diff's own stated motivation when possible, not a pre-existing issue>
**Fix:** <concrete fix, or "no action required unless ..." for a Low/Suggestion finding>

<!-- repeat one block per finding, most severe first -->
````

## Re-review round

Appended to the same draft, one section per round:

````markdown
---

**Update (<YYYY-MM-DD>):** re-review round, diff refs base `<base_sha>` → head `<head_sha>`.

### [SEVERITY] `CATEGORY` — `file:line`
```<language>
<snippet>
```
<explanation — cite the prior round's related fix if it's the same class of issue>
**Fix:** <fix>

Status: <fixed | partially-fixed | still-open | disputed>. Verified against `<branch>` at head `<sha>`.

**Posting plan:** <new top-level comment/discussion | reply to thread #<n>>. Awaiting explicit posting confirmation.
````
