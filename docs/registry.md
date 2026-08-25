# Agent tool registry

Never loaded by the model (§A4) — read by `tools/budget.py` and humans only.

Every tool an agent's frontmatter grants must be justified here, one section per agent:

```
## <agent-name>
- <Tool> — <one-line justification>
```

`budget.py` fails the build if an agent grants a tool this file doesn't justify for it, or if an agent whose name/description reads as a reviewer (`review`, `audit`, `check`) grants `Write` or `Edit`.

## scribe
- Read — baseline
- Glob — baseline
- Grep — baseline
- Write — authors new documents under docs/
- Edit — updates existing documents under docs/
- AskUserQuestion — clarifies a document's scope or audience with the user before writing
- Skill — loads the relevant document-type skill for the requested format

## reviewer
- Read — baseline
- Glob — baseline
- Grep — baseline
- Bash — reruns the project's own verification commands against the diff
- Skill — loads cairn:shared for mechanics shared with the other agents
