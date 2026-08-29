# cairn 2.0 — build brief and development contract

**Paste this whole file into a fresh Claude Code session in the empty `cairn-2.0` repo, then say: "Read the development contract in Part A, build `tools/budget.py` first, then proceed."**

No prior context is assumed. This file has two parts:

- **Part A — Development Contract.** Rules that bind *you, the AI building this repo*, while you build it. Non-optional and machine-checked.
- **Part B — What to build.** The architecture, the loading model, and the artifacts.

Part A exists because prose constraints on an AI fail the same way prose mandates on an agent fail: silently, under pressure, at the exact moment they matter. So Part A is backed by a script you write first and run continuously.

**The one-sentence thesis:** cairn is a guest in every project it enters — it leaves one line behind, it reads everything else on demand, it does nothing until the project has told it how the project works, and it can be removed without a trace.

---

# PART A — DEVELOPMENT CONTRACT

## A0. Build `tools/budget.py` before anything else

Nothing else in this repo gets written until `tools/budget.py` and `tools/test_budget.py` exist and pass. It is the mechanism that makes every rule below real.

- Python 3.11+, **stdlib only**. Exit `0` clean, `1` findings, `2` internal error.
- `budget.py` — check every rule in §A1–A4 and §A12. `--json` for machine output. `--report` regenerates `docs/BUDGET.md` (see §A6).
- Resolve the repo root from `__file__` so it runs from any cwd.
- `tools/test_budget.py` — one unit test per rule over a synthetic tmpdir tree, plus a regression test for every false positive you ever hit.

## A1. Run the gate after every single file

After **every** file you create or edit, run:

```
python tools/budget.py
```

If it reports findings, fix them before writing anything else. Do not batch file creation and check at the end — the failure mode being prevented is a 40 KB agent that "just needs one more section," and it only gets prevented if the check fires while the file is still small enough to fix cheaply.

State the measured byte count of each artifact as you finish it. Never assert that something is "small," "lean," or "concise" without the number next to it.

## A2. File size thresholds

Hard fail means `budget.py` exits 1 and you fix it before continuing. Soft cap means you note it and justify it in the same message.

| Artifact | Soft cap | **Hard fail** |
|---|---|---|
| Consuming project's root `CLAUDE.md` **addition** | 250 B | **400 B** |
| This plugin's own `CLAUDE.md` | 3,000 B | **4,096 B** |
| Agent frontmatter `description` | 250 B | **300 B** |
| **Agent body** (everything after frontmatter) | 3,000 B | **4,096 B** |
| `SKILL.md` (a skill's entry point) | 3,000 B | **4,096 B** |
| `skills/*/reference/*.md` (on-demand detail) | 6,000 B | **8,192 B** |
| Command file | 1,500 B | **2,048 B** |
| Hook script | 1,500 B | **2,048 B** |
| `.harness/*.md` | 40 lines | **60 lines** |
| `.harness/local/preferences.md` | 20 lines | **30 lines** |
| Plan file | 8,000 B | **12,288 B** |
| `STATE.md` | 800 B | **1,024 B** |
| **Any file the model reads at runtime** | — | **8,192 B** |
| **Total always-loaded frontmatter** (all agents + skills + commands) | 2,500 B | **3,000 B** |

Reference points, measured from the predecessors these caps exist to avoid: their agent bodies averaged 15–25 KB and topped out at 54 KB; one always-loaded memory file reached 110 KB, of which 82% was a description registry.

**When something will not fit, stop and report.** Never silently exceed a cap, and never split a file just to dodge the number while keeping the same total load. The three legitimate moves:

1. Move detail into `skills/<name>/reference/<topic>.md`, loaded only when that topic comes up.
2. Replace prose with a script the model *executes* rather than reads (§A5).
3. Cut the behaviour, and say plainly that you cut it and why.

If none of those work, report the conflict and stop. Do not raise a cap on your own authority — see §A7.

## A3. Read-only by default

Two distinct rules share this name. Both apply.

**A3a — Agent tool grants start read-only.** Every agent's `tools:` list begins as `Read, Glob, Grep`. Each additional tool must be earned, and each grant is recorded in `docs/REGISTRY.md` with a one-line justification in the same commit that adds it.

- `Write` / `Edit` go **only** to an agent whose entire purpose is authorship of a named artifact class. Name the paths it writes in its body, and keep those paths inside the §B2 allowlist.
- `Bash` implies unrestricted shell — there is no per-command scoping at that layer. Grant it only where the agent must run the project's own verification commands, and never alongside `Write` unless authorship genuinely requires both.
- A reviewing or auditing agent never gets `Write` or `Edit`. Omission is the enforcement; do not write prose claiming an agent won't write when the tool is present.
- Never state a restriction that the frontmatter doesn't back. If a limit can only be prose, either drop it or label it advisory in the same sentence.

`budget.py` checks: every agent's tool list is a subset of what `docs/REGISTRY.md` justifies for it, and any agent whose name or description contains `review`, `audit`, or `check` has neither `Write` nor `Edit`.

**A3b — Framework files are read-only at runtime.** Nothing this framework ships may edit `agents/`, `skills/`, `commands/`, or `hooks/` during a session. Changes to the framework go through a normal PR into this repo, reviewed like code.

Do not build a "meta" agent that authors other agents. A predecessor spent 72 KB of agent definitions plus a 38 KB linter plus a six-step sync ritual on exactly this, and the result was that its own backlog task carried a comment saying its own workflow could not be run against it. `budget.py` plus code review covers the same ground.

## A4. On demand means on demand

Every artifact is in exactly one of four load classes, and `docs/BUDGET.md` records which:

| Class | Cost | Rule |
|---|---|---|
| **Always loaded** | paid every turn of every context | Only: the ≤ 400 B marker block in the consuming project's root `CLAUDE.md` (§B2), and the frontmatter `description` of each agent/skill/command. Nothing else, ever. |
| **On demand** | paid once, in one context | Agent bodies, `SKILL.md`, `reference/*.md`, `.harness/*.md`. Loaded by an explicit `Glob` + `Read` at a named step. |
| **Executed** | ~0 tokens | Scripts. Invoked via `Bash`, return compact JSON. The model reads the output, never the source. |
| **Never loaded** | 0 | `docs/REGISTRY.md`, `docs/BUDGET.md`, tests, CI config. Read by tooling and humans only. |

Rules that follow:

- **No `@path` imports in any `CLAUDE.md`.** An import is an always-loaded file wearing a pointer's clothes.
- **No registry in memory.** Descriptions live in `docs/REGISTRY.md`, which only `budget.py` and humans read. This one rule is worth ~22,500 tokens per context against the heaviest predecessor.
- **No hook injects context on success.** A hook that prints on every session start is an always-loaded file with extra steps. Hooks stay silent unless something is wrong.
- **Progressive disclosure inside every skill.** `SKILL.md` holds the 20% needed every time plus a table naming each `reference/*.md` and the condition that warrants loading it. A reference file is never loaded speculatively.
- **Absence is never an error, with one deliberate exception.** Every on-demand read is presence-gated: `Glob` first, skip silently if missing, never suggest creating it mid-task. The exception is the `.harness/` directory as a whole, which is a precondition resolved once at the task boundary — see §B3. A *missing individual file inside a present* `.harness/` still skips silently.
- **Nothing is read twice in one chain.** If two agents would both load the same reference, the boundary between them is wrong. Merge them, or move the shared part into a script.

`budget.py` checks: no `@`-imports in any `.md`; every `reference/*.md` is named in its `SKILL.md`'s table; no `.md` over 8,192 B anywhere in a runtime path.

## A5. Deterministic work goes in a script, not in prose

Before writing any instruction, ask whether a script could check or do it. If yes, the script is the deliverable and the prose is a one-line pointer to it.

- A script returns compact JSON. `budget.py --json` returning 40 tokens of findings replaces 3,000 tokens of the model reading rules and applying them by hand.
- Every `.sh` exposes `--selftest` that unit-tests its pure logic with no process spawning and no interaction. `budget.py` checks that every shell script has it and that it exits 0.
- Any fix loop re-runs the deterministic check afterward and replaces its finding set from that fresh run. Never trust a fixer's own account of what it fixed.
- Any fix loop has a **no-progress escape**: if the finding set is unchanged after a round, stop and report `BLOCKED — manual review required`. Do not spend the remaining iterations.

## A6. `docs/BUDGET.md` — the ledger

`budget.py --report` regenerates it. One row per artifact: path, bytes, load class, cap headroom. It ends with the measured always-loaded total against the 3,000 B ceiling.

Regenerate at the end of every build phase and paste the always-loaded total into your message. This is the number the whole design exists to protect; it should be visible constantly, not discovered at the end.

## A7. Raising a cap

A cap can be raised, but only like this, and never mid-flow:

1. State the artifact, its current size, and the size it needs.
2. State what was already tried from §A2's three moves and why each failed.
3. Stop and ask for approval.

On approval, change the number in `budget.py` and add a line to `docs/BUDGET.md` recording the old cap, the new cap, and the reason. A cap changed without that record is a bug in the repo.

## A8. Don't build for later

If nothing loads a file today, don't write it. No scaffolding for future features, no stub sections, no `TODO` placeholders in shipped artifacts.

Two failures this prevents: a 7-line "workflow" file whose entire content duplicated a table that already existed elsewhere, created to prepare for workflows that never arrived; and a shipped agent whose step 4 was literally `<TODO placeholder — see Task 4>`, so the agent could not complete the flow its own requirements described.

`budget.py` checks: no `TODO`, `TBD`, `FIXME`, or `<placeholder` in `agents/`, `skills/`, `commands/`, `hooks/`.

## A9. One artifact per commit

Each commit adds or changes one artifact, plus its `docs/REGISTRY.md` line, plus its `CHANGELOG.md` entry. Never a sweep across many files.

A predecessor required every framework change to touch five registration sites and shipped 50 tagged releases in 29 days as a direct result. One artifact per commit keeps that fan-out visible instead of amortised into unreviewable batches.

## A10. No mandate language

Zero instances of `MUST`, `ALWAYS`, `NEVER`, `MANDATORY`, `NON-NEGOTIABLE`, or a `HARD REQUIREMENTS` heading anywhere in `agents/`, `skills/`, `commands/`, or `hooks/`. `budget.py` fails the build on them.

The predecessors carried 386 and 171 such instances. Neither count correlated with compliance; what held was tool-frontmatter omission, a Python conventions checker, and a shell linter. Mandate density measured the author's frustration, not the framework's integrity.

When something truly cannot be violated, say **how** it's prevented:

> Good: "`reviewer` has no `Write` tool, so it cannot edit files."
> Good: "`budget.py` fails on an agent body over 4,096 B; CI blocks the merge."
> Bad: "Agents MUST NEVER exceed the size limit."

Where a rule is advisory, label it advisory in the same sentence. Ambiguity about whether a rule is in force is worse than either answer.

## A11. From scratch means from scratch

Port **ideas** from cairn 1.x; do not copy files. Every artifact is re-derived under the caps in §A2. A copied 45 KB agent trimmed to 20 KB is still a 20 KB agent — starting from a blank file and the caps produces a genuinely different artifact.

No vendored third-party bundle over 100 KB. A predecessor carried a 2.17 MB JavaScript bundle, ~1.77 MB of which was inert in that deployment, copied into every consuming project.

## A12. Nothing lands in the consuming project

Before creating any artifact, ask: **does this require a consuming project to host a file?** If yes, it belongs in the plugin instead — as a skill, a reference file, or a script.

A consuming project hosts exactly four things, and every one of them is either the project's own content or removable without trace (§B2). If you find yourself writing an instruction that tells a project to create a framework file, a settings block, a doc scaffold, or a directory the framework needs in order to function, that is the signal you've put framework state in the wrong repo.

`budget.py` checks: no file under `agents/`, `skills/`, `commands/`, or `hooks/` names a consuming-project write path outside the §B2 allowlist.

## A13. Phase gate

At the end of each phase in §B10, run and paste the results of:

```
python tools/budget.py
python -m pytest tools/
for s in tools/**/*.sh; do "$s" --selftest; done
python tools/budget.py --report && tail -5 docs/BUDGET.md
```

If any fails, fix before starting the next phase. Report the always-loaded total every time.

---

# PART B — WHAT TO BUILD

## B1. Identity

**cairn 2.0** — a Claude Code plugin carrying a lean, on-demand, non-invasive development workflow.

- `name`: `cairn` (permanent — it prefixes every command and skill; changing it breaks every install)
- `displayName`: settable and changeable; use it for the human-readable label
- Distribution: private git repo, added as a marketplace. Nothing is copied into consuming projects.
- Shape: content flat at the repo root (`agents/`, `skills/`, `commands/`, `hooks/`) — Claude Code discovers those by convention, so the manifest stays trivial.

## B2. Non-invasiveness contract

This is the load-bearing principle of cairn 2.0. A predecessor's model was to copy 199 files and 3.5 MB into every consuming project, then overwrite them wholesale on upgrade. cairn 2.0 inverts that completely: **the framework lives in the plugin; the project keeps only what is genuinely the project's own.**

### B2a. One line in the project's `CLAUDE.md`

The only thing cairn ever adds to a consuming project's `CLAUDE.md` is this marker block, ≤ 400 B, written once by `/cairn-setup` and removed exactly by `/cairn-teardown`:

```
<!-- cairn:start -->
If the `cairn` plugin is available in this session, use it for development work in this repo — start with the `cairn:start` skill. If it is not available, ignore this block; nothing in it applies.
<!-- cairn:end -->
```

Properties that make this safe, and which the build must preserve:

- **It degrades to nothing.** A teammate without the plugin installed reads one conditional sentence that resolves to "ignore this." No broken references, no dangling instructions, no errors. The project still works normally for them.
- **It is the only always-loaded cost.** Everything else cairn knows is behind a skill, a reference file, or a script.
- **It names one entry point, not a workflow.** Do not enumerate agents, phases, or rules here. A predecessor's equivalent block listed sixteen agents by name and asserted "EVERY new user request MUST be routed through `intent-analyzer` — no exceptions," which is both a permanent context cost and a claim nothing enforces.
- **It is marker-delimited and idempotent.** `/cairn-setup` matches the exact `<!-- cairn:start -->` line and does nothing if present. `/cairn-teardown` removes the block and collapses the leftover blank line.
- **It is never written silently.** `/cairn-setup` shows the exact text and asks before touching `CLAUDE.md`. If the project has no `CLAUDE.md`, cairn says so and stops rather than creating one.

### B2b. The complete write allowlist

In a consuming project, cairn may write **only** these paths. Everything else is out of bounds, including paths it would find convenient.

| Path | When | Whose content |
|---|---|---|
| One marker block in root `CLAUDE.md` | `/cairn-setup`, on confirmation | cairn's, removable exactly |
| `.harness/*.md` | `/cairn-setup`, per-rule confirmation | **the project's** — cairn drafts, the team owns |
| `.harness/BUDGET.md` | `/cairn-setup`, after writing the four files | cairn's — a generated ledger, not user-confirmed, never read back by cairn |
| `.harness/BUDGET.roster.txt` | `/cairn-setup --track`/`--untrack`, on request | cairn's — records which extra cairn-owned artifacts to measure into `BUDGET.md`; never asserts about the project's own content |
| `.harness/local/` | `/cairn-setup --local`, on confirmation | **this developer's** — never committed (§B3e) |
| `docs/tasks/<slug>/` | escalated path only | the project's |
| `.cairn/` | runtime state | cairn's, self-ignoring |
| The files the user actually asked to change | during work | the project's — that's the job |

Both `.cairn/` and `.harness/local/` carry a `.gitignore` containing `*`, so each ignores itself and never appears in a diff. That pattern exists specifically so cairn never has to touch the project's own `.gitignore`.

**Never written, under any circumstance:**

- `.claude/settings.json` or `settings.local.json` — cairn never edits a project's settings. If the team wants the marketplace registered for everyone, they commit that themselves; the README shows the snippet.
- `.claude/agents/`, `.claude/skills/`, `.claude/commands/`, `.claude/hooks/` — cairn never installs copies of itself into a project. This is the single biggest difference from the predecessor.
- The project's `.gitignore` (except the self-contained one inside `.cairn/`).
- CI config, package manifests, lockfiles, git hooks, or `.git/` internals.
- Any doc scaffold the project didn't ask for — no auto-created `docs/requirements/`, no README the user didn't request.
- Anything outside the repository root.

### B2c. Clean removal

`/cairn-teardown` removes the marker block and `.cairn/`, then reports exactly what it left behind and why: `.harness/` and `docs/tasks/` stay, because they are the project's own content, not cairn's. It does not uninstall the plugin — that's `/plugin uninstall`, and it says so.

After teardown, `git status` on a clean tree shows one modified file: `CLAUDE.md`, with the block gone. That is the whole footprint, and it is worth verifying by hand once during the build.

## B3. The harness gate — the one precondition

Every instruction cairn gives depends on `.harness/`: it is how a project tells cairn what the project's stack, standards, environment, and workflow actually are. Without it, cairn would be asserting generic opinions about someone else's codebase, which is precisely the failure being designed out (a predecessor froze one team's stack — specific ORM, layering pattern, coverage threshold — into its most expensive agent's requirements).

So `.harness/` is not an optional refinement. It is the substrate. But making it a precondition must not make cairn pushy — the gate resolves **once, at the task boundary**, and declining is a real answer.

### B3a. Resolution, once per task

At the entry point (`cairn:start`), before any other work:

1. `Glob .harness/**/*.md` — **one** call, one time, covering both the team files and the local layer (§B3e). Record the result for the whole task.
2. **Present** → read the files the current step needs, proceed. Never re-glob mid-task.
3. **Partial** (directory exists, some files missing) → proceed with what's there. A missing individual file skips silently; it is not a gate. The local layer is always optional and its absence is never mentioned.
4. **Absent entirely** → do not proceed with cairn's workflow. Say plainly that cairn works from the project's own `.harness/` and offer `/cairn-setup`, once.

That last step is the whole design: **absent means offer setup, not proceed on assumptions, and not nag.** Only the four team files gate; the local layer never does.

### B3b. Declining is a real answer

If the user declines setup, cairn stands down for the session: it does not ask again, does not partially engage, and does not write anything. Claude keeps working on the request normally, without cairn. Nothing is left behind and nothing is broken.

That is what "non-invasive" means in practice — the framework's absence is a supported state, not a degraded one.

### B3c. Setup is observation, not assertion

`/cairn-setup` reads the codebase, derives candidate rules from what the team already does, presents each **with an evidence count** ("3 of 4 services follow this"), takes per-rule approve / edit / drop, and only then writes. It never seeds from a template of opinions, and it writes nothing before confirmation.

The four files it produces are the project's, not cairn's. The team edits them freely; cairn reads them.

`/cairn-setup <path>` scopes that same observe-confirm cycle to one subtree — e.g. a submodule added after the last full run — instead of the whole codebase. It never touches the marker block, and it requires the four files to already exist (a full `/cairn-setup` must run first). Candidates come only from `<path>`; one already matching what a root file says is skipped, one that diverges or introduces something the root files don't cover is offered as a path-scoped line (§B3d) under the matching section, same approve / edit / drop. Confirmed lines are inserted into the existing files — every other line stays untouched — and a file already at its cap is reported, not silently overflowed.

### B3d. The four files

| File | Cap | Sections |
|---|---|---|
| `architecture.md` | 40 lines | `## Stack`, `## Layering`, `## Boundaries`, `## Data` |
| `standards.md` | 40 lines | `## Naming`, `## Error handling`, `## Testing`, `## Logging` |
| `environment.md` | 30 lines | typed preconditions, below |
| `workflow.md` | 30 lines | `## Branching`, `## Commits / PR`, `## Gates` |

All four together are ~1,200 tokens, which is what makes on-demand loading affordable.

- **Refines, never overrides.** A harness file can add a check or tighten a standard; it cannot remove a step. Restate that ceiling in each file's own header line, so a file read without its skill still carries it.
- **No nested `.harness/`.** Resolution (§B3a) starts and stays at the project root; a submodule never gets its own `.harness/` tree. Where a submodule's rules diverge from the rest of the repo, they live in the parent's own four files, scoped by path — e.g. under `standards.md`'s `## Testing`, a line like `services/payments/: contract tests required`. `/cairn-setup`'s evidence count (§B3c) already surfaces this case ("1 of 4 services follow this"): a low count is the signal to write a scoped line instead of a repo-wide one, not a reason to drop the candidate.
- `##` anchors, so a finding can cite `standards.md#error-handling`.

`environment.md` is data, not prose:

```
tool-version python >=3.11        [blocking]
tool-version node >=20            [blocking]
port-open 5432                    [warning]
env-var-set DATABASE_URL          [blocking]
command "pnpm -v"                 [warning]
```

Failure semantics are uniform: a check whose command can't run counts as **failed**, and a line that can't be parsed also counts as **failed**. No silent-skip tier for any failure mode. A `[blocking]` failure stops the task before a branch is created.

`/cairn-setup` also writes `.harness/BUDGET.md` after the four files, mirroring this repo's own `docs/BUDGET.md`: one row per file, its current line count, its cap from the table above, and the headroom. It excludes `local/preferences.md` — gitignored and per-developer, not the team's committed record. Regenerated every setup run, so it can't drift from the files it measures. Cairn never reads it back; it is output for the team, not input to any task, and plays no part in §B3a's harness resolution.

Root `CLAUDE.md` is not tracked by default — cairn owns nothing in it beyond the marker block, and asserting a size opinion about the rest of the project's own file is out of bounds. A team that wants the installed marker block measured opts in explicitly: `/cairn-setup --track claude-md-marker` appends a line to `.harness/BUDGET.roster.txt` (created with its header comment if absent) and regenerates `.harness/BUDGET.md` immediately to include the row; `/cairn-setup --untrack claude-md-marker` removes it the same way. Once added, every later `/cairn-setup` run reads the roster and keeps the row current without asking again. `claude-md-marker` — measured as the exact substring between `<!-- cairn:start -->` and `<!-- cairn:end -->`, capped at 400 B — is the only recognized label; the roster's line format (`<label> <path> <cap-bytes>`) leaves room for a future label, but no measurement logic beyond `claude-md-marker` exists, and none should be added speculatively (§A8).

A pre-`0.2.1` `.harness/BUDGET.roster.md` (the original, wrongly-named file) is renamed to `.roster.txt` automatically the next time `/cairn-setup` runs; `/cairn-doctor` reports it as stale until then.

### B3e. The local layer — `.harness/local/`

The four team files answer *what must be true of this codebase*. They are committed, and everyone shares them. But a lot of what shapes a session is neither team truth nor framework logic — it's one developer's preference, and it has no business in a shipped skill or in a file the team reviews.

`.harness/local/preferences.md` is that layer: gitignored, per-developer, entirely optional, and read on demand alongside the team files.

The reason this matters more here than in most frameworks: teammates are on mixed plans. A developer on a lower tier and a developer on Max want genuinely different execution defaults from the same repo, and neither should have to edit a committed file — or a plugin — to get them.

**Format** — same shape as `environment.md`: data, not prose. Cap 30 lines.

```
model implementation opus
model review sonnet
model docs haiku
token-ceiling task 120000
narration quiet
optional-pass ui-polish off
prefer-path default
```

**What the local layer may set:**

- **Model preference per role** — the motivating case. Model choice belongs to the person paying for the tokens, not to a skill file.
- **A personal token ceiling per task**, so cairn warns at your number rather than a team-wide one.
- **Narration verbosity**, and whether optional passes run by default.
- **Local tool paths or ports** that differ from the team's `environment.md`.
- **A preference between the default and escalated path** for genuinely ambiguous cases.

**What it may not do — the precedence ceiling.** The local layer gets a deliberately *narrower* domain than the team files: it governs **how the work is executed**, never **what has to be true when it's done**.

- It may tighten a team standard. Stricter is always allowed.
- It may not relax, skip, or disable anything the team harness requires — not a gate, not a verification command, not a review step, not a coverage threshold.
- On a conflict about a requirement, the team file wins and the local line is ignored silently. The requirement applies; nothing is announced mid-task. `/cairn-doctor` is where an ignored line becomes visible.
- No secrets. It's a preferences file, not an env file — no keys, no tokens, no credentials. Say this in the template's own header line.

Restate the ceiling in the template header, same as the team files, so a local file read without its skill still carries it.

**Scope: the local layer configures cairn, nothing else.** Every line in it is a preference about how *this plugin* behaves. It is not a request for the host, the session, or the user to change anything.

That gives the layer one governing rule, and it is the most important sentence in this section:

> **A line cairn cannot act on is ignored silently.** No notice, no warning, no suggestion, no "you might want to switch." Not once, not at dispatch, not at session start. Silently inert.

This applies to three cases, identically:

- **A preference with no lever.** Model choice is the clear example. cairn cannot rewrite its own agent files at runtime (§A3b) and cannot change your session model. So `model implementation opus` is a recorded intent that cairn honours wherever it ever gains a lever, and otherwise does nothing at all — it does not mention it, and it does not point you at `/model`. You set your session model yourself; that's not cairn's business to prompt about.
- **An unknown key.** A line this version of cairn doesn't recognise is skipped without comment, so a newer preferences file never makes an older plugin complain.
- **A line the ceiling forbids.** Skipped silently in normal flow — the team requirement simply still applies. No lecture, no naming of files mid-task.

The reason for the strictness: an advisory that fires on a preference the user already knows about is pure noise, and noise on every session is exactly the always-loaded cost this whole design exists to avoid. A preferences file that nags is worse than no preferences file.

**Where an ignored line does become visible: `/cairn-doctor`, and only there.** Doctor is invoked explicitly — the user asked — so it's the right and only place to report which preference lines are active, which are inert and why, which are unrecognised, and whether the session model matches the recorded preference. Nothing about the local layer is ever surfaced in normal flow.

The alternative to all of this — pinning `model:` in a shipped agent — is exactly what forces one person's choice onto every teammate, which is the thing this layer exists to avoid. `budget.py` fails on any shipped agent that pins `model:` without a justification recorded in `docs/REGISTRY.md`.

`/cairn-setup --local` writes the file (and its self-ignoring `.gitignore`) after showing the exact contents. Neither setup nor doctor ever gates.

### B3f. One reader, propagated by prompt

A dispatched agent starts in a fresh context and inherits nothing the main thread loaded, so "the preferences are loaded" is not a property of the session — it's a property of one context. That leaves two possible designs, and only one of them is right.

**The rule: the main thread is the only reader.** `cairn:start` reads `.harness/local/preferences.md` once, in the same single `Glob` that resolves the harness gate (§B3a). No agent reads it, ever.

**Propagation: the applicable lines go into the dispatch prompt.** When the main thread dispatches an agent, it includes only the preference lines relevant to that agent's work — not the whole file. At ~200 bytes total, the relevant subset is a handful of tokens, and it arrives as part of a prompt that was being written anyway.

Why not let each agent read the file:

- It's a `Read` per hop for a file the main thread already has.
- Two readers can observe different states if the file changes mid-task, and nothing would detect the divergence.
- It puts a consuming-project path inside an agent body, which §A12 exists to prevent.

**What propagation cannot carry: the model.** Model selection happens *at* the dispatch, governed by the agent's frontmatter `model:` or inherited from the session — a prompt cannot change the model of the call that carries it. So a `model` line is inert for agents for the same reason it's inert for the main thread, and it is ignored with the same silence (§B3e). This is the general rule doing its job, not a special case.

**Preferences are never persisted into task state.** `STATE.md` holds the scope record (§B6c) and nothing from the local layer. Preferences are per-developer and current; a resumed task re-reads them from disk, so a teammate resuming someone else's task folder gets their own preferences, not the original author's.

## B4. Targets

| | Target | Predecessor A | Predecessor B |
|---|---|---|---|
| Always-loaded framework text | **≤ 1,000 tokens** | ~52,000 | ~9,000 |
| Files added to a consuming project | **1 block + project-owned content** | 199 files / 3.5 MB | plugin + marker block |
| Agents | **≤ 4** | 20 | 18 |
| Agent hops, default path | **2** | 10 | 10–12 |
| Scope/intent resolutions per session | **1 typical** | 1 per message | 1 per message |
| Tokens, small change | **≤ 40k** | 700k floor | ~200k |
| Tokens, medium feature | **≤ 150k** | 0.8–1.5M | 200–400k |
| Mandatory artifacts per feature | **≤ 3** | ~21 | ~6 |

The team constraint that overrides all of it: teammates are on mixed plans, some on lower tiers. A workflow that exhausts a weekly limit gets bypassed, and a bypassed workflow is worth nothing. Cheap-by-default is a correctness requirement.

## B5. Agents — four, thin

Under a 4,096 B body cap an agent cannot be a manual. It becomes a **thin router**: who it is, what it owns, which skill to load for detail, what it hands back. Depth lives in on-demand skill references.

| Agent | `tools:` | Owns |
|---|---|---|
| `planner` | `Read, Glob, Grep, Write, AskUserQuestion, Skill` | A task folder and a plan that **references** paths and contracts rather than embedding file bodies. Escalated path only. |
| `builder` | `Read, Glob, Grep, Write, Edit, Bash, Skill` | Code and its tests, in one context. No test/prod split across two agents. |
| `reviewer` | `Read, Glob, Grep, Bash, Skill` | Reviews **the diff only**, reruns the project's own verification commands. No `Write`/`Edit` — mechanically read-only. |
| `scribe` | `Read, Glob, Grep, Write, Edit, AskUserQuestion, Skill` | All documents — requirements, specs, READMEs — via skills. Scoped to `docs/`, and only where the user asked. |

Every agent receives the harness resolution (§B3a) and any applicable preference lines (§B3f) in its dispatch prompt rather than re-globbing or re-reading, and writes only inside the §B2b allowlist. No agent body names `.harness/local/`.

Not to be built, each a measured failure:

- A routing or intent-classifier **agent** that runs before every request. Routing is the main model's job. Scope resolution — a genuinely different concern, triggered at task boundaries rather than per message — is a skill; see §B6.
- An orchestrator that lacks the `Agent` tool. A coordinator whose handoffs are text blocks the main thread may ignore is a large prompt that does nothing; a predecessor's was 45 KB and loaded twice per task.
- A separate test-writer and test-reviewer pair with a handshake protocol. That split cost ~54 KB of mutual-exclusion bookkeeping.
- Three separate document agents for requirements, design, and architecture. One `scribe` plus skills.
- A read-only auditor as a universal gate. A predecessor's appeared in 9 of 15 workflows, could never fix anything, and turned every finding into a full round-trip.
- A feasibility fan-out spawning two large agents to return "ok".
- A meta agent that edits the framework (§A3b).

Leave `model:` unpinned unless there's a stated reason, so a teammate on a cheaper session isn't forced onto an expensive one. Pin the cheap model on mechanical work like releases.

## B6. Scope resolution — once per task, not once per message

Both predecessors ran an intent analyzer before every single request: one at 27 KB (~6,800 tokens), the other at 16.5 KB (~4,100 tokens) with its entry point asserting *"EVERY new user request MUST be routed through `intent-analyzer` first — no exceptions."* Over a ten-message session that is 41k–68k tokens spent producing a routing string the main model was already capable of producing for free.

cairn 2.0 keeps the *useful* half of that idea and drops the mandatory half. The useful half is not routing — it is turning a vague request into named actionables with a checkable done condition. That is worth doing **once at a task boundary**, and worth doing again only when the boundary moves.

### B6a. It is a skill, not an agent

`cairn:scope` runs in the main thread. Three reasons this is the right shape:

- **Clarification is interactive.** It needs `AskUserQuestion` with the user, who is in the main thread. Predecessor A documented that `AskUserQuestion` is unavailable in dispatched subagents, and worked around it with a hand-rolled handoff protocol that forced several agents onto the main thread anyway — arriving at this design by accident, after paying for the other one.
- **No fresh context to pay for.** An agent hop pays baseline plus its own body and returns a summary. A skill pays its own text once and the result is already where it's needed.
- **It keeps the agent budget at four.** §B5 stays as written.

### B6b. Deciding whether to run it costs nothing

The trap to avoid is a classifier that decides whether to run the classifier. So the decision is a **checklist the main model applies inline**, and it lives in `cairn:start` — loaded once per session at the entry point, resident and free for every message after that.

**Resolve scope when any of these is true:**

1. First substantive request of the session.
2. The request names a goal or area outside the active scope record (§B6c).
3. The request is underspecified: no clear object, or no checkable done condition, or you cannot name the files you would touch.
4. Acting on it would mean more than about three discrete actionables that aren't already listed in the scope record.
5. The user invalidates the active scope — "actually, let's…", "scrap that", "different idea".
6. Cold resume: a task folder exists from a previous session and there is no scope record in this one.

**Continue without resolving — the default, and it should be most messages:**

1. A refinement, correction, or follow-up inside the active scope.
2. An answer to a question you asked.
3. A concrete instruction where you can already name the files and the done condition.
4. Conversation, explanation, or a question about the work rather than a change to it.
5. Anything you can act on without guessing.

When a request extends the scope slightly — one more file, one more case, same goal and same done condition — **amend the scope record yourself** and carry on. That is free. Re-running `cairn:scope` is for a boundary that actually moved.

If a trigger fires and the answer turns out to be obvious, say so in one line and proceed. A resolution that produces no new information should cost one sentence, not an interview.

### B6c. The scope record makes "still in context" decidable

Without a written record, "is this still the same task?" is a judgement that drifts. With one, it is a comparison. Keep it under 400 B:

```yaml
goal: <one sentence>
paths: [<dirs or globs in scope>]
done_when: <checkable condition>
out_of_scope: [<explicitly excluded>]
path: default | escalated
```

The continuity test is then mechanical: **does this request fall inside `paths` and serve `goal` without changing `done_when`?** Yes → continue. No → resolve again.

Where it lives:

- **Default path** — held in the main thread for the session. Nothing written to disk; the session ending is the scope ending, which is correct.
- **Escalated path** — written into `docs/tasks/<slug>/STATE.md`, inside the existing 1,024 B cap, so a cold resume restores the scope by reading one small file instead of re-interviewing the user.

### B6d. What it produces

A resolution returns the scope record plus, when the request needed decomposition, a short list of named actionables — each one a thing you could start on, not a phase label. It does not route, does not name agents, and does not pick the path beyond recording `default` or `escalated` per the §B8 trigger.

`cairn:scope` is capped like any skill: `SKILL.md` under 4,096 B, with `reference/` files for the harder cases — a vague-request interview, and decomposition of a request that spans submodules — each loaded only when its named condition applies.

## B7. Skills — progressive disclosure

Each skill is a directory: a `SKILL.md` entry point under 4,096 B, plus `reference/*.md` under 8,192 B each, loaded only when their named condition applies.

```
---
name: <matches directory name>
description: <≤ 200 B — when to load this, in one sentence>
---

<the 20% needed every time this skill is used — under 3,000 B>

## Reference

| File | Load when |
|---|---|
| reference/<topic>.md | <specific, checkable condition> |
```

The "Load when" column is the whole mechanism. A vague condition means everything gets loaded every time and the skill is just a large file with a table of contents.

`cairn:start` is the entry-point skill named by the marker block, and the only one loaded once per session rather than once per use. It carries exactly three things: the harness gate (§B3a), the scope-resolution trigger checklist and record shape (§B6b–c), and the path choice (§B8). Nothing else — everything it decides to do next is a separate on-demand load.

It is loaded once and then resident, which is what makes the §B6b checklist free on every subsequent message. That makes its size the one place where a few hundred bytes matter more than elsewhere: keep it well under its 4,096 B cap and push anything conditional into `reference/`.

Two shared-skill patterns, both worth having and mechanically different:

- **Invoked shared skill** — `Skill(skill: "cairn:shared")`, holding mechanics several agents have in common. One definition, several callers.
- **Asset bundle read by path, never invoked** — templates under `skills/task-assets/assets/`, read with `Read` at the moment a file gets seeded. Use `${CLAUDE_PLUGIN_ROOT}/skills/...`; a bare relative path resolves against the consuming project's cwd and fails.

## B8. Two paths, cheap by default

- **Default path.** `builder` → `reviewer` → PR. Two hops, no task folder, no plan, no spec. Budget **≤ 40k tokens**. Most changes, all day.
- **Escalated path, opt-in.** `planner` → `builder` → `reviewer` → PR, with `docs/tasks/<slug>/STATE.md` for resume. Budget **≤ 150k tokens**.

**Escalation trigger, verbatim:** *escalate when the change spans more than one submodule, alters a published contract (API, schema, or event), or when you can't describe the change in two sentences.*

Never write "if in doubt, use the full chain." The heavy path being the default was the largest single cost driver in both predecessors, and in one the cheap alternative was explicitly fenced off.

`STATE.md` is YAML front matter, every field under 200 characters, capped at 1,024 B. A predecessor's real files reached 9.9 KB with one 2,655-character field on a single line, an unversioned schema, and out-of-order timestamps its own reporting keyed on.

Keep one distinction from that design, because it's subtle and correct: a `key_info` field is **overwritten** each phase, while a `flags` list is **append-only** and accumulates across the task, so the final step asks one consolidated question.

### B8a. Attendance modes

Three postures for running the same chain, not three chains:

| Mode | What it is |
|---|---|
| Interactive | A normal chat session. `AskUserQuestion` stops for scope ambiguity and plan approval; a human answers them as they come. |
| Attended | The same chain with tool calls auto-accepted. A human is still present to answer cairn's own questions. |
| Unattended | Dispatched, then left alone. No one is present to answer a question, so the chain doesn't ask one. |

Unattended is escalated-path only (§B8): the default path keeps its scope record in-thread with nothing on disk, so there'd be nothing to check once the run detaches.

Unattended changes exactly three things about the chain:

1. **No questions.** Anywhere the chain would call `AskUserQuestion` — `planner`'s open-choice check, `cairn:scope`'s vague-request interview — it instead takes the most conservative, most reversible reading and appends one `flags` line naming the assumption.
2. **Three terminal states, always written to `key_info` before stopping.** `done` — `reviewer` passed; the run stops there, leaving merge/PR/keep-as-is for a human. `needs-human` — a fork with no safe conservative reading (the goal is unnameable even conservatively, escalation to the interactive `cairn:brainstorm` isn't reachable). `stalled` — `reviewer` has rejected `builder`'s output 3 times running. No fourth state, no unbounded retry.
3. **Never publishes.** The run stops after `reviewer` passes or a terminal state is hit; it never opens a PR. Isolation (a worktree per run) is recommended, not built or enforced by cairn.

## B9. Commands

Four, all thin:

| Command | Does |
|---|---|
| `/cairn-setup` | Offers the marker block (shows exact text, asks). Then observe-then-confirm harness generation (§B3c). Refuses to create a `CLAUDE.md` that doesn't exist. Idempotent. |
| `/cairn-setup --local` | Writes `.harness/local/preferences.md` and its self-ignoring `.gitignore`, after showing the exact contents (§B3e). Never touches the team files. |
| `/cairn-setup <path>` | Observes only that subtree; matches its candidates against the existing root files and offers path-scoped lines for what diverges (§B3c, §B3d). Requires the four files to already exist; never touches the marker. |
| `/cairn-teardown` | Removes the marker block and `.cairn/`; reports what it left and why — including `.harness/local/`, which is the developer's own; points at `/plugin uninstall` for the rest. |
| `/cairn-doctor` | Reports: plugin version, marker-block presence, harness presence and per-file status, `.cairn/` state, a stale pre-`0.2.1` `.harness/BUDGET.roster.md` if found, and the local layer line by line — active, inert (no lever), unrecognised, or ignored by the ceiling. The only place an ignored preference is ever surfaced (§B3e). Reports only — installs nothing, fixes nothing, gates nothing. |
| `/cairn-tokens` | Runs the token report and relays it verbatim. |

## B10. Hooks, CI, and token metering

**Hooks — advisory only.** `SessionStart` for a structural self-check, a version log line, and a one-line nudge when the logged version changes, nothing else. Every script `set -uo pipefail` and `exit 0` on every path, degrading silently when `jq`, a marker file, or a session id is missing. The version log writes only if the project opted in (marker block present) — an un-set-up project gets a silent no-op, which is the correct non-invasive behaviour. No `PreToolUse` deny rules: a predecessor's blanket Bash denier rejected combined commands where only part matched, which reads as the wrong tool being blocked and cost more than it saved. Hooks nudge; they never gate.

**CI — where the teeth are.** Neither predecessor had CI beyond manifest validation, and both drifted. On every push and PR, all blocking:

1. `claude plugin validate . --strict`
2. `python tools/budget.py`
3. `python -m pytest tools/`
4. every `tools/**/*.sh --selftest`

Add `CODEOWNERS` so structural rules are a review gate and not just a sentence.

**Token metering — build it in phase 2.** A `Stop` hook writing to SQLite, in `.cairn/`. Four details easy to get wrong:

1. **`requestId` is the per-call unit and the dedup key.** One API call can span several transcript entries (a thinking block and a text block) sharing a `requestId` and carrying an *identical* `usage` snapshot; treating each line as a call double-counts.
2. **Full transcript rescan every Stop event**, no offset tracking. `INSERT OR IGNORE` against `request_id PRIMARY KEY` makes it idempotent. Revisit only if measurably slow.
3. **Exclude synthetic error entries.** A usage-limit hit arrives as a synthetic assistant entry with `isApiErrorMessage: true` and a zeroed-but-present `usage` object. Filter those from the calls table; record them in a separate `usage_limit_events` table.
4. **Price at report time, never at write time.** A `model → $/MTok` table whose fallback is empty, so an unrecognized model yields `cost: unknown` rather than a wrong number, and a group's cost stays `null` rather than a partial sum when any model in it is unpriced. A price change is a script edit, not a migration.

**Amended:** serve a live local dashboard instead of a static report. A prebuilt frontend (React, Vite, Recharts, Tailwind, shadcn/ui, `@tanstack/react-query`) ships as compiled static assets; a Python stdlib server (`http.server` + `sqlite3`, no new pip dependency) serves them plus the JSON reads. Node/npm is a cairn-dev-time-only build step — a consuming project runs `/cairn-tokens` and never invokes it. Rollups: per-day, per-session, per-agent, with a per-session trace nested under each agent's rollup, and a visible warning when any usage-limit event was recorded. Full requirements: `docs/features/token-metering/02-requirements.md`. Design: `docs/features/token-metering/03-architecture.md`. User flow: `docs/features/token-metering/04-user-flow.md`.

**Amended:** implementation code (`db.py`, `parser.py`, `pricing.py`, `server.py`, `frontend/`) targets a separate `token-metering` git submodule, not `tools/tokens/` in this repo. This repo keeps the design docs plus the two artifacts that stay cairn's own — `hooks/stop-tokens.sh` and `commands/cairn-tokens.md` — which reach across the submodule boundary to invoke the submodule's code. `tools/budget.py` covers only what ships from this repo; the submodule gates itself via its own `.harness/`. Sequencing: `docs/features/token-metering/ROADMAP.md`.

## B11. Build order

Each phase ends with the §A13 gate.

1. `tools/budget.py` + `tools/test_budget.py` + CI, blocking from the first commit.
2. Token metering — implementation lives in the `token-metering` submodule (see B10's amendment), sequenced by `docs/features/token-metering/ROADMAP.md`'s milestones; `hooks/stop-tokens.sh` and `commands/cairn-tokens.md` land in this repo alongside it.
3. `.claude-plugin/` manifests, this repo's `CLAUDE.md`, `README.md`, `docs/REGISTRY.md`, `docs/BUDGET.md`.
4. `skills/cairn-start/` — the entry point: harness gate (§B3a), scope trigger checklist and record shape (§B6b–c), path choice (§B8).
5. `skills/cairn-scope/` — the resolution procedure, plus its `reference/` files for vague-request interviews and cross-submodule decomposition.
6. `skills/task-assets/` templates — the four `.harness/` templates plus the `local/preferences.md` template, each carrying its precedence-ceiling header line.
7. `commands/cairn-setup.md` (both modes) and `commands/cairn-teardown.md` — write and manually verify the full install → teardown → `git status` cycle before anything else is built on top.
8. The four agents, smallest first, printing the frontmatter total after each.
9. Remaining skills, each as `SKILL.md` plus `reference/` files, printing the always-loaded total after each.
10. `hooks/`, `commands/cairn-doctor.md`, `commands/cairn-tokens.md`.
11. Full §A13 gate plus §B12.

## B12. Acceptance criteria

Verify each, with numbers:

1. `python tools/budget.py` exits 0; `python -m pytest tools/` passes.
2. `claude plugin validate . --strict` passes.
3. Always-loaded frontmatter total **≤ 3,000 B** — print the measured number.
4. The consuming-project `CLAUDE.md` marker block is **≤ 400 B** — print it.
5. No agent body over 4,096 B — print the largest.
6. No file in a runtime path over 8,192 B — print the largest.
7. **Footprint test, run by hand in a scratch repo:** `/cairn-setup` → do a small task → `/cairn-teardown` → `git status` shows only `CLAUDE.md` reverted, `.harness/` and `docs/tasks/` retained as project content, and nothing under `.claude/`.
8. **Absent-plugin test:** a project containing only the marker block, opened without the plugin installed, behaves normally and produces no errors or dangling references.
9. **Absent-harness test:** a project with the marker block but no `.harness/` offers setup once, and on decline writes nothing and does not ask again in that session.
10. **Scope frequency test:** run a scripted eight-message session — one opening request, then six in-scope follow-ups (a correction, an answer to a question, a concrete instruction, a question about the work, a one-file extension, a refinement), then one genuine topic change. `cairn:scope` runs exactly **twice**: message 1 and the topic change. The one-file extension amends the scope record in place without a resolution.
11. **Scope record test:** the record stays under 400 B; on the escalated path it round-trips through `STATE.md` within the 1,024 B cap, and a cold resume restores it without re-interviewing.
12. **Local-layer isolation test:** `/cairn-setup --local` writes only `.harness/local/preferences.md` and `.harness/local/.gitignore`; `git status` on a clean tree shows nothing; the project's own `.gitignore` is unmodified.
13. **Local-layer ceiling test:** a `preferences.md` line that would disable a team requirement (skip review, lower a coverage threshold) is ignored silently — the requirement still applies, and nothing is said about it during the task. `/cairn-doctor` lists it as ignored.
14. **Local-layer optionality test:** a project with the four team files and no `.harness/local/` runs normally and never mentions the local layer.
15. **Single-reader test:** no agent body or `reference/*.md` contains the string `.harness/local`; a task with two dispatches reads `preferences.md` exactly once, in the main thread, and the applicable lines appear in each dispatch prompt. `STATE.md` contains nothing from the local layer.
16. **Silent-inertness test:** with `model implementation opus` set and a sonnet session, plus one unrecognised key and one ceiling-violating line, a full task produces **zero** mentions of any of them — no notice at session start, none at dispatch, none at the end. `/cairn-doctor` then reports all three correctly: active, inert-no-lever, unrecognised, ignored-by-ceiling. No shipped agent pins `model:` without a `docs/REGISTRY.md` justification.
17. `grep -rE '\b(MUST|ALWAYS|NEVER|MANDATORY|NON-NEGOTIABLE)\b' agents/ skills/ commands/ hooks/` returns nothing.
18. `grep -rE 'TODO|TBD|FIXME|<placeholder' agents/ skills/ commands/ hooks/` returns nothing.
19. No `@path` imports in any `.md`.
20. ≤ 4 agents; `reviewer` has no `Write` or `Edit`.
21. Every agent's tool list matches what `docs/REGISTRY.md` justifies.
22. Every `reference/*.md` appears in its `SKILL.md`'s Load-when table.
23. No shipped file names a consuming-project write path outside the §B2b allowlist.
24. Every `tools/**/*.sh --selftest` exits 0.
25. Each hook script exits 0 with `jq` unavailable, with no session id, and in a project with no marker block.
26. The token report opens correctly from `file://`.
27. `docs/BUDGET.md` is current and its always-loaded total matches criterion 3.
28. `README.md` states both paths with their token budgets, the escalation trigger sentence, the load-class table from §A4, and the write allowlist from §B2b.

## B13. Non-goals

Do not build any of these. Each is a measured failure in a predecessor.

- Installing framework files into a consuming project's `.claude/`.
- Writing a project's `.claude/settings.json`.
- More than one block in a project's `CLAUDE.md`, or any block that enumerates agents or asserts unenforceable routing rules.
- Auto-created doc scaffolds the project didn't ask for.
- A description registry inside any `CLAUDE.md`.
- `@path` imports in a memory file.
- A meta layer whose subject is this framework's own consistency.
- A mandatory routing or intent agent.
- An orchestrator without the `Agent` tool.
- A read-only auditor as a universal gate.
- A separate test-writer / test-reviewer pair.
- Three separate document-writing agents.
- A feasibility fan-out that returns "ok".
- Plans that embed full file contents.
- Full-repo audits scoped to a single task.
- A copy-the-framework-into-the-project installer.
- Vendored bundles over 100 KB.
- Stack opinions frozen into agent prompts (specific ORMs, layering patterns, coverage thresholds). Those belong in a project's `.harness/standards.md`.
- Model choice pinned into a shipped agent without a recorded justification. Model preference belongs to the person paying for the tokens — `.harness/local/` (§B3e).
- A local preferences file that can relax a team requirement. The local layer governs execution, never the definition of done.
- Any runtime notice about a preference cairn cannot act on. Unactionable lines are silently inert; `/cairn-doctor` is the only place they surface.
- Secrets or credentials in any harness file.
- Any runtime file over 8,192 B.