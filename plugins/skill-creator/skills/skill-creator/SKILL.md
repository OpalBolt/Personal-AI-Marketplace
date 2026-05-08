---
name: skill-creator
description: Create new skills or improve existing ones. Use when users want to create a skill from scratch, edit an existing skill, or capture a workflow as a reusable skill. Trigger on phrases like "make this a skill", "create a skill for X", "turn this workflow into a skill", or "improve the X skill".
---

# Skill Creator

Help users create and improve skills through a simple iterative process: understand intent, draft the skill, test it, refine based on feedback.

## What Makes a Good Skill

Skills capture reusable workflows that the agent should follow consistently. Good skills have:

- **Clear triggering conditions** — The description tells the agent exactly when to use this skill
- **Focused purpose** — One coherent workflow, not a kitchen sink of unrelated tasks
- **Progressive disclosure** — Keep SKILL.md under 500 lines; reference additional docs when needed
- **Explanation over enforcement** — Explain *why* something matters rather than rigid MUSTs and NEVERs
- **Examples** — Show concrete inputs and outputs to clarify expectations

## Creating a New Skill

### Step 1: Capture Intent

The user might have already demonstrated a workflow in the current conversation. If so, extract the key elements first:

- What tools and commands were used?
- What was the sequence of steps?
- What corrections did the user make?
- What input/output formats emerged?

Then confirm or gather these details:

1. **What should this skill enable?** The specific capability or workflow to capture.
2. **When should it trigger?** What phrases, contexts, or tasks should invoke this skill?
3. **What's the expected output?** Files, reports, actions — what does success look like?
4. **Are there dependencies?** Specific tools, scripts, or environment requirements?

Ask these conversationally. If something is obvious from context, skip it.

### Step 2: Draft the SKILL.md

Create a directory in your skills folder (e.g., `skills/<skill-name>/`) with a `SKILL.md` file.

#### Frontmatter

```yaml
---
name: skill-name
description: What this skill does and when to use it. Be specific and concrete. Include trigger contexts.
---
```

**Name rules**: lowercase, hyphens only, 1-64 chars, matches directory name.

**Description best practices**:

- Combine *what* the skill does with *when* to use it
- Include specific trigger phrases and contexts
- Be slightly "pushy" — AI assistants tend to undertrigger skills, so make it clear when this skill applies
- 1024 character limit

Good: "Extract text and tables from PDF files, fill PDF forms, and merge multiple PDFs. Use when working with PDF documents, converting PDFs to other formats, or when the user mentions PDF processing."

Poor: "Helps with PDFs."

#### Body Structure

Organize the instructions in clear sections. Common patterns:

**For procedural workflows:**

```markdown
## Step 1: Understand the Input
<instructions>

## Step 2: Process the Data
<instructions>

## Step 3: Generate Output
<instructions>
```

**For tool-specific workflows:**

```markdown
## Setup
Run-once installation or configuration steps.

## Usage
The main workflow with examples.

## Edge Cases
How to handle common problems.
```

**For multi-domain skills:**

```markdown
## Overview
When to use this skill and how to choose the right approach.

## Workflows
### For AWS
<instructions>

### For GCP
<instructions>
```

#### Writing Style

- **Use imperative form**: "Run this command" not "You should run this command"
- **Explain why**: "The upstream API intermittently returns 503 under load. Three retries with exponential backoff keeps errors below 0.1%."
- **Show examples**: Include realistic input/output pairs inline
- **Keep it practical**: Focus on what the agent needs to do, not meta-commentary
- **Avoid over-constraining**: Let the agent apply intelligence rather than following rigid rules

#### Template for Output Formats

When the skill produces structured output, show the template clearly:

```markdown
## Report Structure

Use this template:

# [Title]

## Executive Summary
Brief overview of findings.

## Key Findings
- Point 1
- Point 2

## Recommendations
Specific next steps.
```

#### Examples Pattern

```markdown
## Commit Message Format

**Example 1:**
Input: Added user authentication with JWT tokens
Output: `feat(auth): implement JWT-based authentication`

**Example 2:**
Input: Fixed crash when API returns null
Output: `fix(api): handle nil pointer in user lookup`
```

### Step 3: Review and Refine the Draft

Before showing the user, read your draft with fresh eyes:

- Is the description specific enough to trigger at the right times?
- Does the body explain *why* steps matter, not just *what* to do?
- Are there concrete examples for complex concepts?
- Is anything unnecessarily rigid or prescriptive?
- Could an agent following these instructions produce the intended result?

Make improvements, then present it to the user.

### Step 4: Manual Testing

Suggest 2-3 realistic test prompts — the kind of thing a real user would actually say. Ask the user to confirm or modify them.

Then **test each one manually**: follow the skill instructions yourself and complete the task. Show the user the results.

Ask for specific feedback:

- Did it produce the right output?
- Was anything missing or incorrect?
- Should the workflow be different?

### Step 5: Iterate

Based on feedback:

1. **Generalize, don't overfit** — If something failed, think about the broader pattern, not just this specific case
2. **Keep it lean** — Remove instructions that didn't help or made things worse
3. **Explain the why** — If the agent missed something important, explain why it matters
4. **Bundle repeated work** — If you keep doing the same setup or helper task across tests, consider adding a script or reference doc

Make your improvements, test again, repeat until the user is satisfied.

## Improving an Existing Skill

The user might ask you to update an existing skill. The process is similar:

1. **Read the current skill** — Understand what it does and how it's structured
2. **Understand the problem** — What isn't working? What needs to change?
3. **Make targeted improvements** — Edit the relevant sections, preserving the overall structure
4. **Test the changes** — Run through scenarios to verify the improvement works
5. **Iterate based on feedback**

**Important**: Keep the original name. Don't rename skills during updates.

## Adding Reference Documentation

If a skill needs detailed reference material (API docs, configuration options, troubleshooting guides), put them in a subdirectory and reference them from SKILL.md:

```markdown
See [the API reference](references/api.md) for complete endpoint documentation.
```

Only create reference docs when:

- The information is too detailed for SKILL.md but needed occasionally
- Different domains/frameworks need separate guides
- You want the agent to load context on-demand rather than always

Keep the main SKILL.md focused on the workflow; references are for deep dives.

## Adding Helper Scripts

If the skill involves repetitive tasks that shouldn't be reinvented every time (generating specific file formats, calling APIs, data transformations), create helper scripts in a `scripts/` directory:

```
my-skill/
├── SKILL.md
└── scripts/
    └── process_data.py
```

Reference them clearly in SKILL.md:

```markdown
## Processing Data

Run the bundled processor:

```bash
python scripts/process_data.py input.csv output.json
```

Only bundle scripts when they save meaningful work across multiple invocations. Don't bundle things the agent can easily write fresh each time.

## Progressive Disclosure

Skills use three loading levels:

1. **Metadata** (name + description) — Always in context, ~100 words
2. **SKILL.md body** — Loaded when the skill triggers, ideally <500 lines
3. **References and scripts** — Loaded on-demand as needed

Design your skill to take advantage of this:

- Put everything the agent needs for common cases in SKILL.md
- Move detailed references, alternate workflows, and reference implementations to subdirectories
- Make it clear in SKILL.md when to consult references: "For AWS-specific configuration, see `references/aws.md`"

## Validation

Skills are validated automatically by the AI agent. Most issues are warnings but the skill still loads:

- Name doesn't match directory
- Name has invalid characters
- Description exceeds 1024 characters

Skills without a description won't load.

## Final Check

Before considering a skill done:

- [ ] Name follows the rules (lowercase, hyphens, matches directory)
- [ ] Description clearly states what it does AND when to use it
- [ ] Instructions are clear and explain why steps matter
- [ ] Examples clarify complex concepts
- [ ] You've tested it on realistic prompts
- [ ] The user is satisfied with the results

## Package and Share

When the skill is ready, tell the user where it's located:

```
Your skill is ready at: skills/<skill-name>/

It's already in your skills directory, so it's available for use immediately.
```

If the user wants to share the skill with others, they can copy the entire directory or package it as a `.skill` file (though packaging is optional for local use).

---

Remember: skills are about capturing reusable workflows, not one-off tasks. If you find yourself creating a skill for something the agent already does well, suggest doing the task directly instead.
