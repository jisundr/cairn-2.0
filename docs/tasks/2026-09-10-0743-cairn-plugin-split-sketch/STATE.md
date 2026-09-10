---
goal: Sketch splitting cairn into cairn-core/cairn-review/cairn-docs
  plugins; confirm whether cross-plugin skill invocation works.
paths:
  - docs/tasks/2026-09-10-0743-cairn-plugin-split-sketch/
done_when: STATE.md exists; diagram's Open-question card reflects the
  confirmed finding; a repo-layout sketch doc exists; diagram HTML lives in
  this folder.
out_of_scope:
  - Actually implementing the split.
  - Diagram polishing beyond the one card update.
source: (none)
path: escalated
phase: sketch-complete
key_info: Confirmed - general-purpose agent invoked
  marketing-skills:copy-editing (a separate plugin's skill) successfully.
  cairn:reviewer refused the same call, but that was its own scope
  discipline, not a platform restriction. Skill tool has no cross-plugin
  gate; real gap is plugin.json has no dependency field.
flags: []
---
