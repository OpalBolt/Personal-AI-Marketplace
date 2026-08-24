# Attribution

Adapted skills live in `skills/`; this file is the single record of what came from where — the adapted skills carry no per-file footers, so their loaded context stays clean. Add a `##` section whenever material is adopted from a new source.

## [mattpocock/skills](https://github.com/mattpocock/skills)

| Skill | Adapted from | What changed |
|---|---|---|
| grilling | grilling | tracker fetch added in front; refine-issue trigger phrases absorbed; replaces interview-me |
| code-review | code-review | setup-matt-pocock-skills and issue-tracker-doc machinery dropped; spec fetched via `gh issue view` |
| tdd | tdd | "Skill tool"/codebase-design pointer dropped; examples translated from TypeScript to Python |
| tdd (tests.md, seam vocabulary) | codebase-design | seam/testability vocabulary folded in and trimmed per the map's trim ruling |
| prototype | prototype | examples translated from TypeScript to Python / neutral pseudo-code |
| handoff | handoff | "Skill tool" phrasing neutralized |
| writing-for-agents | writing-for-agents | adopted verbatim; replaces skill-creator as the skill-authoring standard |
| grill-with-docs | grill-with-docs + domain-modeling | merged into one skill per map ruling; grilling stays the pure primitive beneath; ADR gate deduped — criteria in SKILL.md, elaboration in ADR-FORMAT.md |
| grill-with-docs (persist paragraph) | wayfinder | the one idea worth keeping from wayfinder: an unfinished session persists destination + decisions + open questions to a scratch map and resumes later; all tracker machinery (labels, claims, ticket types, fog doctrine) dropped |
| to-spec | to-spec | tracker machinery stripped (setup-matt-pocock-skills dep, ready-for-agent label); publishes to `.scratch/<feature>/spec.md`; upstream chain noted (grill-with-docs sessions, wayfinder maps) |
| to-tickets | to-tickets + to-issues | to-issues renamed; absorbs to-tickets' local-file publishing + per-ticket template, context-window slice sizing, prefactor look; HITL/AFK typing and KISS-first ticket rule added; expand–contract doctrine dropped (no wide refactors in this portfolio) |
