# cairn

A lean, on-demand, non-invasive development workflow for Claude Code.

cairn is a guest in every project it enters: it leaves one line behind, it reads everything else on demand, it does nothing until the project has told it how the project works, and it can be removed without a trace. Nothing is copied into a consuming project — the framework lives entirely in this plugin.

## Install

This repo is private. The `owner/repo` shorthand below uses SSH by default, so it works as-is once `github.com` is in your `known_hosts` and your SSH key is loaded in `ssh-agent`:

```
/plugin marketplace add jisundr/cairn-2.0
/plugin install cairn@cairn-marketplace
```

If SSH isn't set up yet, or you'd rather be explicit, use the full SSH URL instead:

```
/plugin marketplace add git@github.com:jisundr/cairn-2.0.git
/plugin install cairn@cairn-marketplace
```

Then, in the project you want cairn to work in, run `/cairn-setup`.

## Two paths, cheap by default

| Path | Flow | Budget |
|---|---|---|
| **Default** | `builder` → `reviewer` → PR. Two hops, no task folder, no plan, no spec. | ≤ 40k tokens |
| **Escalated** (opt-in) | `planner` → `builder` → `reviewer` → PR, with `docs/tasks/<slug>/STATE.md` for resume. | ≤ 150k tokens |

**Escalation trigger:** escalate when the change spans more than one submodule, alters a published contract (API, schema, or event), or when you can't describe the change in two sentences.

The default path is the default for a reason — most changes, all day, at two hops. Escalating is a deliberate choice for the cases above, not a fallback for uncertainty.

## Attendance modes

Three postures for running the same chain — not three chains:

| Mode | Posture |
|---|---|
| **Interactive** | Normal chat session. cairn asks when it needs to. |
| **Attended** | Same chain, tool calls auto-accepted. A human is still present to answer. |
| **Unattended** | Dispatched, then left alone. Escalated path only — cairn defaults and flags an assumption instead of asking, and stops at one of three outcomes (`done`, `needs-human`, `stalled`) written into `STATE.md`. |

Unattended never publishes — it stops after `reviewer` passes and leaves merging or opening a PR to you. To run one: confirm the launch once, then hand the task to an isolated worktree and either a headless Claude Code run you start yourself or a scheduled/triggered one. To check back, resume the task normally — cold-resume reads `STATE.md` back, the stop-marker in `key_info` says why it stopped, and any `flags` list what it assumed along the way.

See `skills/start/reference/unattended.md` for the mechanics.

## What gets loaded, and when

Every artifact cairn ships is in exactly one of four load classes, tracked in [`docs/BUDGET.md`](docs/BUDGET.md):

| Class | Cost | Rule |
|---|---|---|
| **Always loaded** | paid every turn of every context | Only: the ≤ 400 B marker block in the consuming project's root `CLAUDE.md`, and the frontmatter `description` of each agent/skill/command. Nothing else, ever. |
| **On demand** | paid once, in one context | Agent bodies, `SKILL.md`, `reference/*.md`, `.harness/*.md`. Loaded by an explicit `Glob` + `Read` at a named step. |
| **Executed** | ~0 tokens | Scripts. Invoked via `Bash`, return compact JSON. The model reads the output, never the source. |
| **Never loaded** | 0 | `docs/registry.md`, `docs/BUDGET.md`, tests, CI config. Read by tooling and humans only. |

## What cairn writes in your project

In a consuming project, cairn writes **only** these paths — everything else is out of bounds, including paths it would find convenient:

| Path | When | Whose content |
|---|---|---|
| One marker block in root `CLAUDE.md` | `/cairn-setup`, on confirmation | cairn's, removable exactly |
| `.harness/*.md` | `/cairn-setup` or `/cairn-retro`, per-rule confirmation | the project's — cairn drafts, the team owns |
| `.harness/local/` | `/cairn-setup --local`, on confirmation | this developer's — never committed |
| `docs/tasks/<slug>/` | escalated path only | the project's |
| `.cairn/` | runtime state | cairn's, self-ignoring |
| The files you actually asked to change | during work | the project's — that's the job |

**Never written, under any circumstance:** `.claude/settings.json` or `settings.local.json`; `.claude/agents/`, `.claude/skills/`, `.claude/commands/`, `.claude/hooks/`; the project's own `.gitignore` (except the self-contained one inside `.cairn/`); CI config, package manifests, lockfiles, git hooks, or `.git/` internals; any doc scaffold the project didn't ask for; anything outside the repository root.

Run `/cairn-teardown` to remove the marker block and `.cairn/` and see exactly what's left behind and why.

## Developing cairn

See [`Cairn 2.0 build brief.md`](docs/Cairn%202.0%20build%20brief.md) for the full development contract, and [`CLAUDE.md`](CLAUDE.md) for the condensed per-commit discipline.
