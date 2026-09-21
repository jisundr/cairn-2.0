# Resuming a task

Read only the frontmatter of `STATE.md` — from the opening `---` to the closing `---`. The log below it is opened only to explain something.

**Finding the folder.** One task in progress under `docs/tasks/` → that one. Several → ask which, newest first.

**Sub-tasks.** A parent folder holds numbered sub-task folders. Pick the one the user names ("resume 02-site-mvp"); in a submodule worktree, the one whose name matches the worktree's branch; otherwise ask. Do not read every sub-task to decide. Read each sub-task's frontmatter only when asked for the parent's status.

**Worktrees.** Worktrees exist only in submodules; the parent repo is never one. Task folders are gitignored and stay in the parent checkout. A dispatch into a submodule worktree carries the parent-repo path of its sub-task folder; with no dispatch and no folder to be found, ask rather than search.
