---
name: issue
description: >
  Expand a rough idea into a well-structured, actionable issue — then create it in the right
  tracker (GitHub, Linear, Jira). Use this skill whenever a user wants to create an issue,
  report a bug, propose a feature, request an improvement, or track any piece of work — even
  if they don't use the word "issue". Trigger on phrases like "I'd like a...", "we should
  add...", "there's a bug with...", "can we track...", "let's make an issue for...", or any
  description of desired functionality or a problem that needs solving. Don't wait for the
  user to ask explicitly — if they describe something that should be tracked, offer to create
  an issue.
---

# Issue Creator

Your goal is to turn a rough idea into a well-structured, actionable issue — then create it
in the right tracker. Work iteratively: ask focused questions, build understanding, and only
create the issue when it's genuinely worth making.

## Step 1 — Detect the tracker

Before asking anything else, figure out where issues live for this project. Check in order:

1. **CLAUDE.md or any `.claude/*.md` files** — look for mentions of GitHub, Linear, Jira,
   project keys, or tracker URLs
2. **`.github/` directory** — its presence strongly implies GitHub Issues
3. **`package.json`, `pyproject.toml`, `go.mod`** — repo metadata sometimes includes tracker links
4. **Git remote URL** — a `github.com` remote means GitHub Issues is available

If the tracker is unambiguous, proceed silently. If it is unclear or multiple trackers are
present, ask the user once: *"What issue tracker does this project use? (GitHub / Linear /
Jira / other)"*

Keep the tracker in mind — you will need it at the end.

## Step 2 — Understand the rough idea

Read what the user gave you. Before asking anything, identify the gaps:

- **Why does this matter?** — Is the motivation clear? Who is affected?
- **What does "done" look like?** — Can you describe acceptance criteria?
- **What is the scope?** — Is it clear what's in and out?
- **How should it work?** — Are there implementation decisions or preferences to surface?
- **Are there alternatives?** — Should we build it ourselves or use an existing library/package?

## Step 3 — Iterative questioning

Ask 2–3 focused questions per round — the most important gaps first. Don't dump every
question at once; pick what matters most right now. After each answer, reassess: do you
have enough, or is another round needed?

**Keep asking until the issue has all of these:**
- A clear problem statement and motivation (the *why*)
- Defined scope (what's in, what's out)
- Verifiable acceptance criteria (what does "done" look like?)
- Key implementation context or open decisions surfaced

**Good questions to draw from (use judgment, not a checklist):**
- What problem does this solve? Who runs into this and when?
- What should it look/feel/behave like? Any examples or references?
- Should we use an existing package, or build it ourselves?
- What are the edge cases or failure modes we should handle?
- What would you check to confirm it's working?
- Is anything explicitly out of scope for this issue?
- Are there related issues, PRs, or prior art we should reference?
- What's the priority — nice-to-have, or blocking something?

Be conversational. Don't interview the user — have a dialogue. If an answer raises a new
question, follow up on it before moving on.

## Step 4 — Draft the issue

Once you have enough context, produce a Markdown draft using this structure:

```
## Problem / Motivation

Why does this matter? What problem does it solve, and for whom?
Describe the "before" state — what's missing, broken, or frustrating.

## Proposed Solution

What should be built or changed? High-level description of the approach.
If there are meaningful alternatives considered, mention them briefly.

## Acceptance Criteria

- [ ] Specific, verifiable condition that defines "done"
- [ ] Another condition
- [ ] ...

## Implementation Notes

Key decisions, preferred approaches, packages to consider, constraints.
(Omit this section if there is nothing meaningful to say)

## Open Questions

- Anything still uncertain that should be resolved during implementation
(Omit this section if none)
```

Show the draft to the user:

> Here's the draft. Does this capture it correctly? Anything to add, change, or cut before
> I create it?

Apply any edits. Get a clear yes before proceeding.

## Step 5 — Create the issue

Use the right MCP tool for the detected tracker:

### GitHub

Use `mcp__plugin_github_github__issue_write`. You need:
- `owner` and `repo` — derive from the git remote (`git remote get-url origin`), or ask
- `title` — concise, imperative ("Add progress bar to model download")
- `body` — the full Markdown draft

### Linear

Authenticate first if needed (`mcp__claude_ai_Linear__authenticate`), then use the
appropriate Linear MCP tool. You need:
- Team or project identifier — check context files, or ask
- Title and description

### Jira

Authenticate first if needed (`mcp__claude_ai_Atlassian__authenticate`), then use the
appropriate Atlassian MCP tool. You need:
- Project key — check context files, or ask
- Summary (title) and description

### Other trackers

If the tracker has an MCP integration, use it. If not, output the formatted Markdown so
the user can paste it themselves, and say so clearly.

---

After creating, share the issue URL or ID so the user can find it immediately.
