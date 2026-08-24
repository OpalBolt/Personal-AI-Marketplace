---
name: agent-writer
description: Write or regenerate the root AGENTS.md context file for a project by introspecting the repo and interviewing the user for only what cannot be inferred. Use when user wants to create, write, or regenerate an AGENTS.md, or mentions agents.md, context file, or onboarding an agent to a project.
---

# Agent Writer

Write a tight `AGENTS.md` at the repo root. Not persona agents. Not `.github/agents/*.md`. One file, root level. For how to write it — pointer wording, information hierarchy, pruning — follow `writing-for-agents`; this skill owns the workflow, not the writing style.

## Governing Principle

Include only what an agent cannot infer from the repo or its training. Everything else is noise that drifts. Context files packed with inferable content perform *worse* at higher token cost (an ETH Zurich study on context-file effectiveness).

## Workflow

1. **Confirm scope** — "I'll write `AGENTS.md` covering overview, commands, boundaries, and one static code-style line. Sound right?"
2. **Introspect first** — run the checklist below before asking anything. The survey confirms what you found; it doesn't fill blanks.
3. **Run the survey** — four questions, show-your-work style.
4. **Oddities → jam** — if Q4 surfaces anything weird or counterintuitive, invoke `jam-with-me` to unpack it; harvest the result into overview or boundaries.
5. **Draft** — fill the output template using introspected + surveyed data only.
6. **Overwrite** — write to `AGENTS.md`. If one exists, overwrite. Do not diff or merge — the old file is a disposable snapshot, not a hand-curated artifact. Git tracks the change.
7. **Report** — "Written to `AGENTS.md`. Run `git diff` to see what changed."

## Introspection Checklist

Language-agnostic signals. Look for:

- canonical build/test/lint/dev commands — what the project *actually* uses, not the default
- non-standard tooling choices (pixi over pip, buf over protoc, justfile over Makefile) — highest signal
- directory layout — to decide what *not* to document (agents can `ls`)
- existing README / docs — to avoid duplicating
- existing `AGENTS.md` / `.cursorrules` / `CLAUDE.md` — harvest the non-inferable bits before overwriting
- `.env.example` / secrets indicators — to inform the 🚫 Never tier
- CI config (`.github/workflows`) — reveals the commands the project actually trusts

## Survey

Every question shows introspected work and asks for confirmation or correction — never an open blank.

1. **Overview** — "This is [stack + versions from package files] for [purpose from README/repo name]. Accurate? Anything non-standard I should flag?"
2. **Commands** — "Found: [build/test/lint/dev from package files, CI, Makefile, justfile]. Correct and complete? Any commands you run that live in no script?"
3. **Boundaries** — seed the three tiers below, then ask "what else per tier?":
   - ✅ **Always:** run lint before commit; list only human authors in commits
   - ⚠️ **Ask first:** database schema changes; adding new dependencies
   - 🚫 **Never:** commit secrets or `.env`; force push to main; modify generated/vendored files
4. **Oddities** — "Anything about this project that looks wrong to an outsider but is intentional?" If yes → `jam-with-me`.
5. **Artifacts** — "Specs, tickets, and planning maps default to `.scratch/` (local markdown, untracked). Keep that, or does this repo use a real tracker (GitHub Issues, Jira, …)?" Record the answer in the template's Artifacts section — agents cannot infer where a repo's planning artifacts live.

## Output Template

```md
# AGENTS.md

## Project overview
[One sentence: stack + versions + what's non-standard.]

## Commands
- Build: `[full command with flags]`
- Test: `[full command with flags]`
- Lint: `[full command with flags]`
- Dev: `[full command with flags]`

## Artifacts
- Specs/tickets/maps: `.scratch/` (local markdown, untracked)

## Boundaries
### ✅ Always
- …

### ⚠️ Ask first
- …

### 🚫 Never
- Commit secrets or `.env` files
- Force push to main
- …

## Code style
Self-documenting code, KISS and human readable above all. Linter is the source of truth (gofmt/golangci-lint, ruff/black, shellcheck). No comments unless critically necessary — to explain a non-obvious why, a workaround, or a hidden risk. Not for restating what the code does.
```

## Cut List

If tempted to add any of these, don't:

- **Architecture summaries / structure maps** — agents can `ls`.
- **Code style beyond the static line** — no snippets, no naming conventions beyond what the linter enforces.
- **Git workflow** — owned by `git-commit`. The agent loads it when needed.
- **Testing rules** — covered by Commands (how to run tests).
- **Anything already in the README** — redundant; increases drift.
