# cairn 2.0 — interview stories (STAR)

Companion to `docs/PORTFOLIO.md`. Five STAR-format narratives drawn from this repo's own commit history (`CHANGELOG.md`) and current state, mapped to common technical-interview question types. Not committed as part of cairn's shipped surface.

## 1. System design — rewriting for a provable cost budget

**Question type:** "Tell me about a system you designed" / "walk me through a redesign you led."

- **Situation:** A prior version of this same Claude Code workflow framework had grown to 18 agents (278 KB) and 10 skills (87 KB), spending 200–400k tokens per feature — a cost that was real but never disclosed or bounded.
- **Task:** Rewrite the framework so its cost was a stated, enforced ceiling rather than an emergent, undisclosed number.
- **Action:** Restructured the pipeline down to 4 agents (5.5 KB) and 10 skills (14.6 KB), and split every artifact into one of four explicit load classes — always-loaded, on-demand, executed, never-loaded — each tracked in a generated ledger (`docs/BUDGET.md`). Backed the redesign with a comparison against two other agent frameworks: one that scaled *up* enforcement machinery and hit 0.7–1.5M+ tokens for one feature, and one that hit a ~1–2k baseline but only by giving up all CI/blocking checks. That comparison is what shaped the actual target — not "lowest possible cost," but the lowest cost that still kept enforcement.
- **Result:** ~800-token baseline (down from ~9k), ≤40k tokens for the default two-hop path, ≤150k for the opt-in escalated path — each number backed by a script (`tools/budget.py`) that fails the build if any artifact exceeds its budgeted class, not just a claim in a README.

## 2. Debugging / failure — a confirmation gate that wasn't actually a gate

**Question type:** "Tell me about a bug you found" / "describe a time you caught something that could have gone wrong."

- **Situation:** A PR-review skill was designed to draft findings, then gate posting them behind an explicit user confirmation (`AskUserQuestion`) before anything touched a real pull request.
- **Task:** Nothing was flagged in design or code review — this surfaced live: a findings comment posted to a real merge request with no confirmation prompt at all (filed as GitHub issue #4).
- **Action:** Traced the call path and found the actual defect: the review step invoked the underlying code-review tool with a `--comment` flag, which posts to the live PR *immediately* — before the skill's own confirmation step was ever reached in the control flow. The confirmation gate existed in the code, but nothing upstream of it respected it. Fixed it by removing the flag (making that call draft-only) and moving the actual post to a point strictly after confirmation, using the same posting mechanism the skill's own approval step already used.
- **Result:** The specific bug was fixed, but the more durable output was the generalized rule it left behind: a confirmation gate is only real if no step upstream of it can independently perform the gated action — a check now worth applying to every other gated workflow in the system, not just this one.

## 3. Technical depth — keeping two copies of a backend from silently disagreeing

**Question type:** "Tell me about a technically tricky problem you solved."

- **Situation:** A backend (token-usage metering) is developed in its own git submodule, but a public plugin install doesn't reliably recurse submodules — so the same backend is also vendored as a byte-for-byte copy directly into the main repo. That's two copies of nine files that need to stay identical, with no natural mechanism forcing them to.
- **Task:** Prevent the vendored copy from silently drifting from the submodule source — a class of bug that wouldn't show up until a consuming project's plugin install served a stale build.
- **Action:** Wrote a standalone script that diffs the nine files byte-for-byte between the submodule and the vendored copy, and wired it into its own CI job with an independent, full submodule checkout — separate from the main gate's job, which intentionally runs *without* the submodule checked out, so neither job's assumptions contaminate the other.
- **Result:** Drift is now a CI failure, not a support ticket. The same project separately caught and fixed a related class of bug in the vendored frontend — a timezone-bucketing bug in a usage heatmap that only manifested across a DST transition — by adding fixed-timezone, DST-spring-forward, DST-fall-back, and calendar-day-crossing test cases directly, rather than trusting manual QA to catch a date-boundary condition.

## 4. Tradeoff / decision-making — killing a 671-line document on purpose

**Question type:** "Tell me about a decision where you had to accept a real loss" / "when did you decide to remove something instead of keep building on it."

- **Situation:** The project's original build spec had grown to 671 lines and had accumulated both active build rules and a large amount of now-historical design rationale.
- **Task:** Decide whether to keep maintaining it as a living document or retire it, without just quietly deleting institutional knowledge.
- **Action:** Ran an audit first — confirmed every rule the document specified was already built and passing its own gate — before proposing retirement. Folded the remaining *active* rules into the project's permanent standards doc, and separately, explicitly recorded which part of the original document (its design rationale, agent-count justification, and non-goals) had no other home in the repo and would not be preserved beyond what already-adjacent docs captured.
- **Result:** A leaner permanent doc set, with the tradeoff written down in the changelog as a deliberate, accepted loss rather than something later discovered to be missing — the kind of decision that's more defensible in retrospect because the cost was named at the time it was made, not after the fact.

## 5. Process / governance — a versioning rule that had already silently failed

**Question type:** "Tell me about a process you improved" / "describe a time you found a gap in your own process."

- **Situation:** The project's rule was to bump its plugin version only for changes that affected user-facing behavior — docs-only or internal-refactor commits didn't need one.
- **Task:** That rule seemed reasonable until the actual install mechanism was reconsidered: a consuming project's plugin install re-syncs on version *change*, not on content diff. Under the existing rule, several already-merged commits (a landing page, a README update, a 671-line doc retirement, `.gitignore` hardening) were invisible to anyone who'd already installed the plugin — not a hypothetical gap, but one that had already happened.
- **Action:** Changed the rule to bump on every commit, docs-only included, and updated the enforcement discipline immediately rather than treating it as a documentation nice-to-have.
- **Result:** Every subsequent commit — including this one — carries a version bump specifically so this class of "invisible to existing installs" gap can't recur, and the changelog records the old rule's failure mode explicitly so the reasoning survives the next person who might otherwise reintroduce it.
