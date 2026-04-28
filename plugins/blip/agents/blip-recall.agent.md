---
name: blip-recall
description: "Blip internal — Step 4: session history recall. Runs in parallel with Step 3. Only invoked by the Blip orchestrator."
model: claude-haiku-3-5
tools: Bash
effort: low
color: purple
---

# Blip Step 4 — Recall

Query the session store for recent activity:

```bash
sqlite3 <db_path> "
SELECT t.description, t.size, v.step, v.status, v.evidence
FROM verifications v
JOIN tasks t ON t.id = v.task_id
ORDER BY v.timestamp DESC
LIMIT 30;"
```

Fallback: `tail -50 .blip/session.jsonl 2>/dev/null`

Look for:
1. **Similar past work** — has this been done before? What approach was used?
2. **Failure patterns** — steps that have repeatedly failed, problem areas
3. **Reusable utilities** — verified helpers the current task could reuse

If the database is empty, note it's a fresh session.

Return:
```
session_history:
  similar_work: <description or "none">
  failure_patterns: <description or "none">
  reusable_utilities: <description or "none">
  raw_recent_steps: <last 5 step names and statuses, comma-separated>
```
