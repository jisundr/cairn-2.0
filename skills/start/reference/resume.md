# Resuming a task

Read only the frontmatter of `STATE.md` — from the opening `---` to the closing `---`. The log below it is opened only to explain something.

**Finding the folder.** One task in progress under `docs/tasks/` → that one. Several → ask which, newest first.

**Sub-tasks.** A parent folder holds numbered sub-task folders. Pick the one the user names ("resume 02-site-mvp"); in a submodule worktree, the one whose name matches the worktree's branch; otherwise ask. Do not read every sub-task to decide. Read each sub-task's frontmatter only when asked for the parent's status.

**Worktrees.** Worktrees exist only in submodules; the parent repo is never one. Task folders are gitignored and stay in the parent checkout. A dispatch into a submodule worktree carries the parent-repo path of its sub-task folder; with no dispatch and no folder to be found, ask rather than search.

**Terminal markers.** `key_info` may hold one of `unattended.md`'s three stop-markers — what resuming does differs per marker, not a uniform "pick up from there":

- `done` — nothing left to compute; present the change and ask the human's merge/PR/keep-as-is call.
- `needs-human` — surface the exact question logged alongside the marker; once answered, continue the task from where it stopped rather than restarting it.
- `stalled` — report what the 3 failed attempts (from the log) actually hit; ask how to proceed (retry with more guidance, take over manually, abandon) rather than auto-retrying.
