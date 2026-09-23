---
name: research
description: Resolves a topic and its active task folder, then hands off to the main thread to dispatch the research agent for a parallel-subagent investigation.
---

# cairn:research

## Steps

1. No topic or question given → ask for one.
2. No active task folder for this session → say so, stop. This skill does not create one — `research` requires that folder to already exist.
3. Hand back a dispatch scope — the topic, the active task folder's path — to the main thread, which dispatches `research` with it.
