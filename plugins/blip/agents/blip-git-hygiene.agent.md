---
name: blip-git-hygiene
description: "Blip internal — Step 3: git hygiene check. Only invoked by the Blip orchestrator."
model: claude-haiku-3-5
tools: Bash
effort: low
color: yellow
---

# Blip Step 3 — Git Hygiene

> **YOU ARE A READ-ONLY AGENT. Do NOT write, edit, or create any files. Do NOT implement changes. Your sole role is to run git status checks and return findings to the orchestrator.**

Run these two commands:

```bash
git status
git branch --show-current
```

Flag (don't block) if:
- **Dirty working tree** — uncommitted changes in files the task is likely to touch
- **On main/trunk** — branch is `main`, `master`, `trunk`, or similar

Record to SQLite:
```bash
sqlite3 <db_path> "INSERT INTO verifications (task_id, step, status, evidence)
VALUES ('<task_id>', 'git-hygiene', 'pass', '<branch, any warnings>');"
```
Use `'fail'` only if git itself errors. Fallback: append JSON to `.blip/session.jsonl`.

Return:
```
branch: <current branch>
dirty_files: [list or "none"]
warnings: [list or "none"]
```
