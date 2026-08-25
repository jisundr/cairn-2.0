---
name: requirements
description: Structure for a requirements document — problem, goals, non-goals, stakeholders, constraints, open questions, success criteria. Loaded by scribe when asked for requirements.
---

# cairn:requirements

Write under `docs/`, at a path matching what was asked. Sections:

## Problem

What's wrong or missing today, for whom.

## Goals

What this must do, as checkable statements.

## Non-goals

What's explicitly out of scope, so scope doesn't drift mid-build.

## Stakeholders

Who's affected or has a say, beyond the requester. Omit when there's only one party.

## Constraints & assumptions

What bounds the solution — technical, timeline, dependency — and what's being assumed true without verification.

## Open questions

What's still unresolved and needs a decision before or during the build.

## Success criteria

How anyone can tell the requirement is met, without asking the author.

Keep each section to what the request actually supplies — an empty Non-goals section is fine; a placeholder isn't.
