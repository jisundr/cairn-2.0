---
name: spec
description: Structure for a design/spec document — architecture, components, data flow, error handling, testing. Loaded by scribe when asked for a spec or design doc.
---

# cairn:spec

Write under `docs/`, at a path matching what was asked. Sections, scaled to what's actually decided:

## Architecture

The shape of the solution and why, over the alternatives considered.

## Components

Each piece: what it does, how it's used, what it depends on.

## Data flow

How information moves through the components.

## Error handling

What can go wrong and what happens when it does.

## Testing

How the design gets verified.

Omit any section the request hasn't actually resolved yet — an unresolved section stays unwritten, not filled with a placeholder.
