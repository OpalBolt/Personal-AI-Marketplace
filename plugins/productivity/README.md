# Productivity Skills

A comprehensive suite of productivity skills designed to enhance AI-assisted development workflows. This marketplace entry bundles 7 essential skills into one cohesive, easy-to-install package.

## Included Skills

### interview-me
Spec interviewer for tools and features. Reads a file or requirement, quickly scans the codebase for context, then conducts a focused 1-on-1 interview using AskUserQuestion to produce a clean specification document.

**Use when:** User wants to be interviewed about a tool or feature, types `/interview-me`, or says things like "help me spec out X", "interview me about X", or "I want to build X".

### markdown-writer
Create concise, consistent markdown documents following KISS principles. Ensures content is to-the-point, filters fluff, splits long documents, uses minimal emojis, and maintains relaxed but professional tone.

**Use when:** Creating README files, documentation, guides, or any .md files.

### refine-issue
Fetch a GitHub issue and refine its description through a focused interview to create implementation-ready specifications.

**Use when:** A user wants to improve an issue's clarity, add missing details, or make it more actionable for AI tools or developers.

### skill-creator
Create new skills or improve existing ones.

**Use when:** Users want to create a skill from scratch, edit an existing skill, or capture a workflow as a reusable skill. Trigger on phrases like "make this a skill", "create a skill for X", "turn this workflow into a skill", or "improve the X skill".

### git-commit
Write well-formed git commit messages following Conventional Commits, enforce issue references, and ensure commit bodies explain why — not what.

**Use when:** About to run git commit, stage changes, or need to produce a commit message. Also for any git workflow involving committing: feature branches, bug fixes, CI automation, or autonomous agent loops.

### issue
Expand a rough idea into a well-structured, actionable issue — then create it in the right tracker (GitHub, Linear, Jira).

**Use when:** User wants to create an issue, report a bug, propose a feature, request an improvement, or track any piece of work. Triggers on phrases like "I'd like a...", "we should add...", "there's a bug with...", "can we track...", "let's make an issue for...", or any description of desired functionality or a problem that needs solving.

### pr
Create a well-structured GitHub pull request that gives the reviewer full context: what issue is being addressed, what problem it solves, what changed, why, and how to verify.

**Use when:** About to run `gh pr create`, open a pull request, or produce a PR for completed work. Also at the end of any autonomous agent loop that resolves a GitHub issue.

## Installation

Install this productivity suite as a single marketplace entry to get all 7 skills at once.

## Credits

- **interview-me** is based on the original work from [Sorbh/interview-me](https://github.com/Sorbh/interview-me) - Huge thanks for the inspiration and foundation!

## License

Please refer to the main project's LICENSE file for licensing information.
