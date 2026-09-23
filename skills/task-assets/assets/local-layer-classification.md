# Classifying `.harness/local/preferences.md` lines

- A line that would relax, skip, or disable something one of the four team files requires, or a stage cairn's own path always runs (`builder`, `reviewer`) → **ignored by ceiling**, naming the conflicting file/section or "cairn's own path".
- `model <agent> = <model>`, `<agent>` one of `builder`/`planner`/`reviewer`/`scribe`/`research`, `<model>` one of `sonnet`/`opus`/`haiku`/`fable`, not caught above → **active**.
- A recognised key (`token-ceiling`, `narration`, `optional-pass`, `prefer-path`) not caught above → **active**.
- Anything else → **unrecognised**.
