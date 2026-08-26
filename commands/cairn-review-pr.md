---
description: Reviews an open PR/MR — code-review findings plus cairn's security checklist and fix-lane tags, drafted and gated behind confirmation before anything posts.
argument-hint: <PR/MR URL>
---

No URL given → ask for one.

Invoke `Skill(skill: "cairn:review-pr")` with it. That skill owns host resolution, mode detection, and every review scenario — this command is only its entry point.
