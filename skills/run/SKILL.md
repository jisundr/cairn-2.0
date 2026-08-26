---
name: run
description: Starts this project's app to exercise a change — reads the start command from environment.md, or asks; reports how to reach it.
---

# cairn:run

1. Read `.harness/environment.md` for a line naming how to start the app. Absent or file missing → ask once for the command; don't write it back — persisting it is `/cairn-setup`'s job, not this skill's.
2. Start it via `Bash` with `run_in_background`; wait for it to report ready (bound port, "listening", etc.) rather than a fixed sleep.
3. Report the URL/port reached and the background task id, so the caller can drive it and stop it later. This skill never stops what it starts on its own.
