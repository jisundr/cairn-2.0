---
description: Reviews an open PR/MR with cairn's security checklist and fix-lane tags; drafts first, posts only on confirmation.
argument-hint: <PR/MR URL>
---

No URL given → ask for one.

Invoke `Skill(skill: "cairn:review-pr")` with it. That skill owns host resolution, mode detection, and every review scenario — this command is only its entry point.
