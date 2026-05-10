---
name: markdown-writer
description: Create concise, consistent markdown documents following KISS principles. Use when creating README files, documentation, guides, or any .md files. Ensures content is to-the-point, filters fluff, splits long documents, uses minimal emojis, and maintains relaxed but professional tone. Trigger on any markdown creation or documentation task.
---

# Markdown Writer

Help create concise markdown documents that follow KISS principles and maintain consistency.

## Writing Principles

Apply these filters to every document:

### KISS - Keep It Simple
- Get to the point in the first sentence
- Cut unnecessary words
- Prefer bullets over prose when listing items
- If it doesn't add value, remove it

### Auto-filter Fluff
Remove these patterns:
- "It's important to note that..." → Just state it
- "This section will cover..." → Start with the content
- "As you can see..." → Show instead
- "You might want to consider..." → Use "Use X when..."

### Document Length
- Single file: Under ~300 lines
- Over 300 lines: Suggest splitting into multiple files
- Prefer `doc/` folder for multi-file docs
- Check for existing .md files first — follow that convention

### Tone
- Relaxed but professional (NOT posh)
- Write like explaining to a colleague
- Avoid corporate jargon and buzzwords

### Emoji Usage
- Default: No emojis
- Acceptable: Tables for status (✅ ❌ ⚠️)
- Acceptable: Where emojis convey info text can't
- NOT acceptable: Decoration (🎉 🚀 ✨)

## Workflow

Copy this checklist for each markdown task:

```
Markdown Creation:
- [ ] Check existing .md files for conventions
- [ ] Verify length is appropriate (split if >300 lines)
- [ ] Remove all fluff patterns
- [ ] Apply KISS principles
- [ ] Use minimal/purposeful emojis only
- [ ] Ensure relaxed but professional tone
```

**Step 1: Check conventions**

```bash
find . -name "*.md" -type f | head -20
```

Note: location (root/docs/doc), heading style, naming patterns

**Step 2: Understand requirements (for new docs or major edits)**

For new markdown documents or significant restructuring, see [questions.md](questions.md) to explore:
- Purpose and audience
- What's essential vs nice-to-have
- Structure and organization preferences
- Tone and style expectations

Skip this step for minor edits or when requirements are clear.

**Step 3: Write concise content**

Apply filters from Writing Principles section above. Question every paragraph: "Does the reader need this?"

**Step 4: Format consistently**

- Use proper heading hierarchy (# ## ### ####)
- Add language tags to code blocks
- Use descriptive link text
- Tables for structured data only

**Step 5: Quality check**

Run through checklist. If any item fails, revise.

## Document Types

### README Files
1. One-line description
2. Quick start (get them running)
3. Core features (bullets, not essays)
4. Examples (when they convey useful information)
5. Links to detailed docs

Don't include: backstories, detailed API docs (link instead), complete changelogs

### Documentation Guides
1. What (brief explanation)
2. Why (one sentence on when to use)
3. How (step-by-step with examples)
4. Troubleshooting (if needed)

### Technical Reference
- Headings match API/function names
- Code examples for each item
- Parameter tables with types
- Return value examples

## Examples

**Good README structure:**

```
# Tool Name

One-line description.

## Installation

[command]

## Usage

[command with example]

## Options

- --flag — Description
```

**Bad patterns to avoid:**

Starting with: "Welcome to..." or "This tool was created to..."

Including: "## Introduction - In this section we will cover..."

**When to split files:**

Good structure for 300+ lines:
```
doc/
├── README.md      # Overview and quick start
├── setup.md       # Installation details
├── config.md      # Configuration
└── examples.md    # Use cases
```

Bad: Single 800-line README with everything

## Edge Cases

**Inconsistent project conventions:**
- Use most common pattern
- Note inconsistency to user
- Suggest standardizing

**User wants verbose docs:**
- Explain KISS principles
- Offer separate detailed files
- Keep main doc concise with links

**Emoji usage unclear:**
- Default to no emoji
- Ask if uncertain
- Tables and status are usually fine

## Quality Verification

Before delivering, confirm:
1. Purpose clear from first sentence?
2. Every paragraph necessary?
3. Removing any section would reduce usefulness?
4. Sounds human-written?

If no to any: revise before delivering.
