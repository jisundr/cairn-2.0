# Setting up docs/reviews/

1. Create `docs/reviews/` if absent, with an empty `.gitkeep`.
2. Copy `reviews/_template/` to `docs/reviews/_template/`, skipping any file already there.
3. Show these exact lines and ask before appending them to the root `.gitignore` (create it if absent; skip lines already present):

```
docs/reviews/*
!docs/reviews/.gitkeep
!docs/reviews/_template/
```

4. Report what was created and what already existed. A re-run changes nothing. The rule does not untrack review folders already committed; that is the owner's call.
