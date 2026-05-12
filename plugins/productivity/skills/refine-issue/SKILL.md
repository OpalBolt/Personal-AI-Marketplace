---
name: refine-issue
description: Fetch a GitHub issue and refine its description through a focused interview to create implementation-ready specifications. Use when a user wants to improve an issue's clarity, add missing details, or make it more actionable for AI tools or developers. Trigger on phrases like "refine issue #123", "improve this issue", "clarify issue", "make issue #X more detailed", or "prepare issue for implementation".
argument-hint: <issue-number-or-url>
allowed-tools: Bash, Read, AskUserQuestion, Write
---

# Refine Issue

Transform vague or incomplete GitHub issues into clear, actionable specifications that AI tools and developers can implement confidently.

## Overview

Many issues start as rough ideas — "add feature X" or "fix problem Y". This skill takes an existing GitHub issue and guides you through a structured interview to:

- Clarify the problem and desired outcome
- Identify edge cases and constraints
- Define acceptance criteria
- Add technical context and implementation hints

The result is a refined issue description that can be posted back to GitHub or saved locally.

## Step 1: Fetch the Issue

Parse `$ARGUMENTS` to get the issue reference. Accepted formats:

- Issue number: `123`
- GitHub URL: `https://github.com/owner/repo/issues/123`
- Full reference: `owner/repo#123`

Fetch the issue using gh CLI:

```bash
gh issue view <issue-number> --json number,title,body,url,state,labels
```

If you're not in a git repository or the issue is from a different repo, use:

```bash
gh issue view <issue-number> --repo owner/repo --json number,title,body,url,state,labels
```

Extract and present to the user:
- Issue number and title
- Current description
- Labels (if relevant)
- URL for reference

If the fetch fails, explain the error and suggest fixes (wrong repo, authentication needed, etc.).

## Step 2: Analyze the Current Issue

Before asking questions, identify what's missing or unclear:

**Problem clarity:**
- Is the problem or goal clearly stated?
- Is it obvious *why* this matters or who benefits?

**Technical detail:**
- Are there hints about implementation approach?
- Are dependencies or constraints mentioned?

**Scope:**
- Is it clear what's in scope and out of scope?
- Are there edge cases or special scenarios?

**Acceptance criteria:**
- Can you tell when this is "done"?
- Are there specific test cases or validation steps?

Quickly scan the project if relevant:
- Check for similar features or patterns
- Note conventions that should be followed
- Identify related code that might need changes

Keep this analysis internal — don't show it to the user yet.

## Step 3: Interview

Ask questions one at a time using AskUserQuestion. Each question should have 2–4 concrete options that represent common choices or trade-offs.

Focus on areas where the current issue is weak:

**Problem & Goals (if vague):**
- Who is this for? What problem does it solve?
- What's the expected outcome or user experience?
- Why is this important now?

**Technical Approach (if missing):**
- How should this work under the hood?
- Are there existing patterns or libraries to follow?
- What are the key technical constraints?

**Scope & Boundaries:**
- What's explicitly out of scope for this issue?
- Are there related but separate issues this depends on or blocks?
- Should this be broken into smaller pieces?

**Edge Cases:**
- What can go wrong? How should errors be handled?
- What about edge cases like empty input, large datasets, concurrent access?
- Are there backward compatibility concerns?

**Acceptance Criteria:**
- How will we know this is working correctly?
- What specific test cases should pass?
- Are there performance or quality requirements?

**Rules:**
- One question per turn, always via AskUserQuestion
- Skip questions the original issue already answers well
- Skip questions irrelevant to this type of issue (e.g., don't ask about UI for a backend API)
- Push back gently if answers are contradictory or create obvious problems
- Stop when you have enough to write implementation-ready specs (typically 3-7 questions)

Don't over-interview — this should feel focused and efficient, not exhausting.

## Step 4: Generate Refined Description

Create a refined issue description. Adapt sections based on what the interview revealed:

### Common Sections

```markdown
## Problem / User Story
[What needs to be solved and why]

## Requirements
[Core functionality, constraints, technical approach]

## Acceptance Criteria
- [ ] [Testable requirement]
- [ ] [Another requirement]

## Out of Scope
[What this explicitly excludes]
```

### Optional Sections (add only when needed)

- **Edge Cases** — Complex scenarios or error handling
- **Technical Design** — Architecture details, data models, integration points  
- **Testing** — Specific test cases or verification steps
- **Future Considerations** — Related work that's deferred

**Guidelines:**
- Be specific and concrete — avoid vague language
- Include examples for complex concepts
- Keep descriptions scannable — use bullets and short paragraphs
- Note any "Open Questions" if uncertainty remains
- Preserve useful content from the original

## Step 5: Present and Offer to Update

Show the refined description to the user and ask what they'd like to do:

**A)** Save locally to `./issues/refined-issue-<number>.md` for manual copy/paste
**B)** Update the GitHub issue directly using:

```bash
gh issue edit <issue-number> --body "$(cat refined-description.md)"
```

**C)** Post as a comment instead (preserves original issue):

```bash
gh issue comment <issue-number> --body "## Refined Specification\n\n$(cat refined-description.md)"
```

**D)** Make more changes (iterate on the interview)

Default to option A (save locally) unless the user explicitly wants to update GitHub.

If updating GitHub, show the confirmation:
```
✓ Updated issue #123: <title>
  <url>
```

## Examples

**Example 1: Vague feature request**

Original:
> Add user authentication

After interview discovers OAuth requirement, token expiry needs, and backward compatibility:

> ## Problem
> Users can currently access all features without identity verification, creating security risks for private data and preventing personalized experiences.
> 
> ## Proposed Solution  
> Implement OAuth 2.0 authentication with JWT tokens...
> [full refined spec]

**Example 2: Incomplete bug report**

Original:
> App crashes sometimes on mobile

After interview reveals iOS-specific issue during background sync:

> ## Current Behavior
> The iOS app crashes when entering background mode during an active sync operation.
>
> ## Steps to Reproduce
> 1. Start a large file sync (>100MB)
> 2. Switch to another app mid-sync
> 3. App crashes within 5-10 seconds
> [full refined spec]

## Progressive Enhancement

If the issue is already well-written, acknowledge that:

> "This issue is already quite detailed. I can help refine specific areas if needed. What would you like to clarify or expand?"

Focus your interview only on the gaps the user identifies, or suggest small improvements rather than forcing a full interview.

## Handling Multiple Issues

If the interview reveals the issue should be split into multiple smaller issues:

1. Suggest the split explicitly: "This covers two distinct features: X and Y. Should we split this into two issues?"
2. If yes, create refined specs for each
3. Note the relationship between them (dependencies, implementation order)
4. Offer to create the new issues using the `issue` skill

Don't automatically split unless the user agrees — sometimes a larger issue is intentional.

---

**Remember:** The goal is actionable clarity, not exhaustive documentation. A developer or AI tool should be able to start implementing with confidence after reading the refined description.
