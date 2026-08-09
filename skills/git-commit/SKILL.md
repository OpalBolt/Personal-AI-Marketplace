---
name: git-commit
description: >
  Write well-formed git commit messages following Conventional Commits, enforce issue references,
  and ensure commit bodies explain why — not what. Use this skill whenever you are about to run
  git commit, stage changes, or need to produce a commit message. Also use it when helping with
  any git workflow that involves committing: feature branches, bug fixes, CI automation, or
  autonomous agent loops.
---

# Git Commit Skill

You are about to create a git commit. Follow every rule here — these conventions keep the project
history readable by humans and parseable by tools, now and years from now.

## Step 1 — Understand what changed

Run these commands to understand the full picture:

```bash
git status
git diff --staged        # what will be committed
git diff                 # what is still unstaged (decide if it belongs in this commit)
git branch --show-current
git log --oneline -5
```

Read the output carefully. Commit one coherent unit of work. If staged changes span multiple
unrelated concerns, split them into separate commits.

## Step 2 — Find the issue number

Every commit must reference a GitHub issue. This is non-negotiable. Look in this order:

1. **Branch name** — extract the number from patterns like `feature/123-...`, `fix/123`,
   `123-slug`, `issue-123`, `GH-123`.
2. **Recent commits** — if the last few commits all reference `#42`, this work likely belongs there.
3. **Conversation or task context** — the user or task description may have mentioned an issue.

**If you cannot find an issue number**, ask the user before proceeding:

> No GitHub issue or issue-linked branch found for this work. Commits without an issue
> reference are harder to trace later. Do you want to commit anyway without an issue number?
> (yes / no)

If the user confirms yes, proceed to Step 3 and omit the `#issue` suffix from the subject
line. If the user says no, stop and suggest they create an issue first.

Do not invent a number. Do not use a placeholder.

## Step 3 — Write the commit message

### Subject line (first line)

Format: `type(scope): description #issue`

Rules:
- **type** must be exactly one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`,
  `chore`, `ci`, `build` — no other values.
- **scope** is optional. Use it when it meaningfully narrows the context (e.g., `feat(auth):`,
  `fix(api):`). Omit it when the change is broad or the scope is self-evident.
- **description** is lowercase, imperative mood ("add", "fix", not "added" or "fixes"), no
  trailing period.
- **#issue** goes at the very end, separated by a space.
- The entire subject line must be **72 characters or fewer**. Count them. Shorten if needed.

Examples:
```
feat(auth): add JWT refresh token rotation #42
fix(api): handle nil pointer in user lookup #87
chore: upgrade Go toolchain to 1.23 #101
docs: add setup instructions to README #15
```

### Body (optional but strongly encouraged)

Leave a blank line after the subject, then write the body. The body answers **why** — not what.
The diff shows what changed. The body explains the reasoning: the bug that was observed, the
constraint encountered, the decision that was made.

Bad body: "Added retry logic to the HTTP client."
Good body: "The upstream API intermittently returns 503 under load. Without retries, user-facing
requests fail hard. Three retries with exponential backoff keeps the error rate below 0.1%."

Keep body lines under 72 characters.

### Full example

```
fix(api): return 404 when resource is soft-deleted #88

Soft-deleted records were being returned in GET responses, leaking
data that users had explicitly removed. The ORM default scope was
not filtering on deleted_at, which we now enforce at the model level.
```

## Step 4 — Commit

Stage the relevant files and commit. Do not use `--no-verify`. Do not amend an existing commit
unless the user has explicitly asked for it.

```bash
git add <relevant files>
git commit -m "$(cat <<'EOF'
type(scope): description #issue

Optional body explaining why.
EOF
)"
```

## Commit often

For autonomous agent workflows, prefer many small coherent commits over one large one. Scaffolding,
implementation, tests, and documentation are usually separate commits. This makes review, bisect,
and revert tractable.

If you find yourself writing "and" in the subject line, it probably needs to be two commits.
