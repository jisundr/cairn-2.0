# Sketch: splitting cairn into three plugins

Not implemented — a sketch to accompany `cairn-plugin-split.html`. See STATE.md
for the confirmed finding this rests on: cross-plugin `Skill` calls work today
with no platform-level gate; the real gap is that `plugin.json` has no
dependency field.

## Today

One marketplace, one plugin:

```
.claude-plugin/marketplace.json   # lists a single plugin, source: "."
.claude-plugin/plugin.json        # name: "cairn", version, description
agents/      builder.md planner.md reviewer.md scribe.md
skills/      brainstorm/ readme/ requirements/ review-pr/ run/ scope/
             shared/ spec/ start/ task-assets/
commands/    cairn-doctor.md cairn-retro.md cairn-review-pr.md
             cairn-setup.md cairn-teardown.md cairn-tokens.md
```

## Split

Same repo, three plugin roots under it, one marketplace listing all three:

```
.claude-plugin/marketplace.json     # lists 3 plugins, source: "./cairn-core"
                                     # etc. - same pattern cairn's own
                                     # marketplace.json already uses for "."

cairn-core/.claude-plugin/plugin.json   # name: "cairn-core"
cairn-core/agents/     builder.md
cairn-core/skills/     start/ scope/ shared/
cairn-core/commands/   cairn-setup.md cairn-doctor.md cairn-teardown.md

cairn-review/.claude-plugin/plugin.json # name: "cairn-review"
cairn-review/agents/   reviewer.md
cairn-review/skills/   review-pr/
cairn-review/commands/ cairn-review-pr.md

cairn-docs/.claude-plugin/plugin.json   # name: "cairn-docs"
cairn-docs/agents/     planner.md scribe.md
cairn-docs/skills/     brainstorm/ readme/ requirements/ spec/ task-assets/
cairn-docs/commands/   cairn-retro.md cairn-tokens.md
```

`cairn-review`'s `reviewer.md` and `cairn-docs`'s agents would call
`Skill(skill: "cairn-core:shared")` instead of `Skill(skill: "shared")` —
a naming change in each agent's instructions, not an architecture change.

## What actually changes vs. today

- **`.harness/*.md` isn't cairn's to keep at the repo root — it's the consuming
  project's own file**, created there via `/cairn-setup`. The harness gate
  globs it relative to cwd, so whichever project installs cairn supplies its
  own copy; all three plugins would read that same project-owned file, not
  one cairn ships. `docs/REGISTRY.md` and `CHANGELOG.md` genuinely are cairn's
  own repo-root docs, unchanged by the split.
- **Three `plugin.json`s to version instead of one.** Each needs its own
  bump-every-commit discipline (this repo's CLAUDE.md rule), which is 3x
  the bookkeeping for a change that touches all three.
- **No enforced dependency.** Nothing in the plugin manifest format stops
  someone installing `cairn-review` or `cairn-docs` without `cairn-core`.
  Whoever ships the split has to document "install cairn-core first" and
  accept that an unknown-skill error is the failure mode if someone doesn't.
- **Payoff is agent-list clutter, not tokens.** Skill bodies already load
  lazily today (only descriptions are always-loaded) — the split doesn't
  reduce token cost. What it buys: someone who only wants PR review doesn't
  see `builder`/`scribe`/`planner` in their agent picker.

## Recommendation

Worth doing only if agent-list clutter is an active complaint. Otherwise the
one-plugin-with-scoped-agents shape cairn already has gets most of the value
for a third of the version/changelog overhead.
