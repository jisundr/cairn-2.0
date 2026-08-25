# Agent tool registry

Never loaded by the model (§A4) — read by `tools/budget.py` and humans only.

Every tool an agent's frontmatter grants must be justified here, one section per agent:

```
## <agent-name>
- <Tool> — <one-line justification>
```

`budget.py` fails the build if an agent grants a tool this file doesn't justify for it, or if an agent whose name/description reads as a reviewer (`review`, `audit`, `check`) grants `Write` or `Edit`.

Empty until Phase 8 adds the first agent.
