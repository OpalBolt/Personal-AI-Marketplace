---
name: to-spec
description: Turn the current conversation into a spec and publish it to `.scratch/<feature>/spec.md` — no interview, just synthesis of what you've already discussed. Invoke with /to-spec.
disable-model-invocation: true
---

Do NOT interview the user — synthesize what you already know. Most often the conversation is a `grill-with-docs` session; a `wayfinder` map collapses into a spec here too, its decisions becoming the buildable plan.

## Process

1. Explore the repo, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch the seams at which you'll test the feature. Prefer existing seams to new ones, and use the highest seam possible. The ideal number of seams is one.

Check with the user that these seams match their expectations.

3. Write the spec using the template below, then publish it to `.scratch/<feature>/spec.md` (local tracker convention), ready for `to-tickets`.

<spec-template>

## Problem Statement

The problem, from the user's perspective.

## Solution

The solution, from the user's perspective.

## User Stories

A LONG, numbered list covering every aspect of the feature:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

## Implementation Decisions

The decisions made. Include:

- Modules to build or modify
- Their interfaces
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include file paths or code snippets. They go stale fast.

Exception: if a prototype snippet encodes a decision more precisely than prose (state machine, reducer, schema, type shape), inline it in the relevant decision, note that it came from a prototype, and trim to the decision-rich parts.

## Testing Decisions

Include:

- What makes a good test (external behavior, not implementation details)
- Which modules will be tested
- Prior art (similar tests in the codebase)

## Out of Scope

## Further Notes

</spec-template>
