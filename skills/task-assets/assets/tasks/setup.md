# Setting up docs/tasks/

1. Create `docs/tasks/` if absent, with an empty `.gitkeep`.
2. Copy `tasks/_template/` to `docs/tasks/_template/`, skipping any file already there.
3. Show these exact lines and ask before appending them to the root `.gitignore` (create it if absent; skip lines already present):

```
docs/tasks/*
!docs/tasks/.gitkeep
!docs/tasks/_template/
```

4. Report what was created and what already existed. A re-run changes nothing. The rule does not untrack task folders already committed; that is the owner's call.
