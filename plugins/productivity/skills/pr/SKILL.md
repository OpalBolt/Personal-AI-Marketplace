---
name: pr
description: >
  Create a well-structured GitHub pull request that gives the reviewer full context: what
  issue is being addressed, what problem it solves, what changed, why, and how to verify.
  Use this skill whenever you are about to run `gh pr create`, open a pull request, or produce
  a PR for completed work. Also use it at the end of any autonomous agent loop that resolves
  a GitHub issue — even if the user didn't explicitly ask for a PR.
---

# PR Skill

You are about to open a pull request. A good PR lets the reviewer understand the work without
having to reverse-engineer the diff. Follow every step.

## Step 1 — Verify you are on a branch

```bash
git branch --show-current
```

If the output is `main`, **stop immediately**:

> You are on `main`. A pull request requires a feature branch. Create one for this work
> before opening a PR.

Do not proceed until you are on a non-main branch.

## Step 2 — Find the issue number

Every PR must reference a GitHub issue. Look in this order:

1. **Branch name** — extract from patterns like `feature/123-...`, `fix/123`,
   `issue/123-slug`, `123-slug`, `GH-123`.
2. **Recent commits** — if the commits on this branch reference `#42`, that is likely the issue.
3. **Conversation or task context** — the user or task description may have stated it.

If you cannot find an issue number, **stop completely**:

> No GitHub issue found for this work. Please provide the issue number — every PR must
> trace back to an issue.

Do not invent a number. Do not use a placeholder. Do not proceed without a real issue number.

## Step 3 — Understand what changed

Run these commands before writing a single word of the PR:

```bash
git log main..HEAD --oneline          # commits on this branch
git diff main..HEAD --stat            # files changed, lines added/removed
git diff main..HEAD                   # full diff
gh issue view <number>                # the problem statement and acceptance criteria
```

Read everything. The issue tells you the *problem*. The diff shows the *solution*.
The commit log shows the *sequence of decisions*. You need all three to write a good PR.

## Step 4 — Write the PR

### Title

Format: `type(scope): description (#issue)`

Same rules as commit messages:
- **type**: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`
- **scope**: optional — use it when it meaningfully narrows the context
- **description**: lowercase, imperative mood ("add", "fix", not "added" or "fixes"), no trailing period
- **72 characters or fewer** — count them

```
feat(auth): add JWT refresh token rotation (#42)
fix(api): handle nil pointer in user lookup (#87)
chore: upgrade Go toolchain to 1.23 (#101)
```

### Body

Use this exact structure — every section, every time:

```
Closes #<issue>

## Problem

<What was broken, missing, or needed. Describe the "before" state: what happened, what
failed, what was absent. One to three sentences. Pull from the issue body if it explains
it well — don't reinvent it.>

## Changes

<Bullet list of what was changed. Files, components, behaviours. Focus on the what —
keep it scannable. Don't pad this with obvious things like "updated tests"; mention
the things a reviewer will actually want to navigate to.>

- ...
- ...

## Why

<The reasoning. Why this approach and not another? What constraint or insight drove the
design? If a simpler solution was rejected, say why. Be honest about trade-offs. This
is the section that ages best — six months from now, nobody will remember why, and this
is where they'll look.>

## How to verify

<Step-by-step instructions a reviewer can follow to confirm the changes work. Concrete
enough that someone unfamiliar can execute it. If there are tests, name them. If it's a
CLI command, write it out. If it requires setup, say so.>

1. ...
2. ...
```

Keep each section proportional to the change. A one-line fix doesn't need three
paragraphs. A significant refactor deserves real detail. Don't pad; don't omit.

## Step 5 — Create the PR

```bash
gh pr create \
  --title "<title>" \
  --body "$(cat <<'EOF'
Closes #<issue>

## Problem

<problem>

## Changes

<changes>

## Why

<why>

## How to verify

<how-to-verify>
EOF
)" \
  --base main
```

After the PR is created, output the URL so the user can find it immediately.
