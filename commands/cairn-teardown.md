---
description: Removes the marker block and .cairn/; reports what it left behind and why. Points at /plugin uninstall for the rest.
---

1. If `CLAUDE.md` contains the `<!-- cairn:start -->` … `<!-- cairn:end -->` block, remove it and collapse the leftover blank line. If absent, say so.
2. If `.cairn/` exists, remove it. If absent, say so.
3. Report what was left and why: `.harness/` and `docs/tasks/` are the project's own content; `.harness/local/` is the developer's own. None of these are touched.
4. Point at `/plugin uninstall` for removing the plugin itself — this command only undoes what `/cairn-setup` wrote.
