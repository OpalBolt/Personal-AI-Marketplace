---
name: grill-with-docs
description: Relentless interview that sharpens a plan or design while writing the domain docs — glossary and ADRs — as decisions land. Invoke with /grill-with-docs.
disable-model-invocation: true
---

# Grill With Docs

Run `grilling` for the interview mechanics — rounds, frontier, recommended answers. This skill adds the domain discipline: while you grill, build and sharpen the project's domain model and write it down the moment it crystallises.

## During the session

- **Challenge against the glossary.** When a term conflicts with `CONTEXT.md`, call it out immediately: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"
- **Sharpen fuzzy language.** When a term is vague or overloaded, propose a precise canonical one: "'account' — the Customer or the User? Those are different things."
- **Discuss concrete scenarios.** When domain relationships come up, stress-test them with edge-case scenarios that force precision about the boundaries between concepts.
- **Cross-reference with code.** When the user states how something works, check the code agrees; surface contradictions: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

## Capturing

- **Update `CONTEXT.md` inline, as each term is resolved** — batching loses them. It is a glossary and nothing else: define what a term IS, keep implementation detail, specs, and scratch out. Format and multi-context layout: [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md).
- **Create files lazily** — only when you have something to write. First resolved term creates `CONTEXT.md`; first ADR creates `docs/adr/`.
- **Offer an ADR when all three hold:** hard to reverse, surprising without context, a real trade-off. Format and what qualifies: [ADR-FORMAT.md](ADR-FORMAT.md).

## Persist when the session ends early

If the frontier won't empty in one sitting, don't force it. Write the destination, the decisions so far, and the remaining open questions to `.scratch/<effort>/map.md` (or wherever the repo's AGENTS.md names as the artifact home). A later session resumes by loading that file and continuing the interview from its frontier.

The map is scratch, not an artifact: crystallised terms go to `CONTEXT.md`, real trade-offs to ADRs, and once `to-spec` synthesizes the session the map file is disposable.

When the frontier empties and the user confirms shared understanding, hand off to `to-spec` to synthesize the session into a spec.
