# Skill Creator

Help users create and improve skills through a simple iterative process: understand intent, draft the skill, test it, refine based on feedback.

## Installation

Install from Personal AI Marketplace:

```bash
pi marketplace install skill-creator
```

## Usage

This skill triggers automatically when you:
- Ask to create a new skill
- Want to improve an existing skill
- Say things like "make this a skill", "create a skill for X", or "turn this workflow into a skill"

## What It Does

The skill-creator guides you through:

1. **Understanding intent** — What workflow should the skill capture?
2. **Drafting SKILL.md** — Creating well-structured skill documentation
3. **Testing** — Manual validation with realistic prompts
4. **Refinement** — Iterative improvements based on feedback

## Features

- Creates skills following pi best practices
- Ensures proper frontmatter with name and description
- Guides you through clear triggering conditions
- Helps add examples and explanations
- Tests skills before considering them complete

## What Makes a Good Skill

Skills capture reusable workflows that the agent should follow consistently. Good skills have:

- **Clear triggering conditions** — The description tells the agent exactly when to use this skill
- **Focused purpose** — One coherent workflow, not a kitchen sink of unrelated tasks
- **Progressive disclosure** — Keep SKILL.md under 500 lines; reference additional docs when needed
- **Explanation over enforcement** — Explain *why* something matters rather than rigid MUSTs and NEVERs
- **Examples** — Show concrete inputs and outputs to clarify expectations
