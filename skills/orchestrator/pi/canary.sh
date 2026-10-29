#!/bin/bash
# Canary facts for one child run — meta numbers plus call-log counts, as one
# key=value line. usage: canary.sh <run-id-prefix | ->
# "-" means the newest child run. Artifacts are matched newest-first across
# all session dirs, so the caller passes nothing but a prefix.
set -euo pipefail

pat="$1"
[ "$pat" = "-" ] && pat="*"
meta=$(ls -t "$HOME"/.pi/agent/sessions/*/subagent-artifacts/${pat}*_meta.json 2>/dev/null | head -1) || true
if [ -z "${meta:-}" ]; then
  echo "canary: no artifacts match '${1}'" >&2
  exit 2
fi

python3 - "$meta" <<'EOF'
import json, os, re, sys

meta_path = sys.argv[1]
m = json.load(open(meta_path))
u = m.get("usage") or {}
tr = meta_path[: -len("_meta.json")] + "_transcript.jsonl"

facts = dict(
    run=str(m.get("runId", "?"))[:8],
    agent=m.get("agent", "?"),
    model=m.get("model", "?"),
    exit=m.get("exitCode", "?"),
    turns=u.get("turns", "?"),
    duration_s=round((m.get("durationMs") or 0) / 1000),
    cost=round(u["cost"], 6) if "cost" in u else "?",
)

calls, first_edit, evidence = [], None, False
for line in open(tr) if os.path.exists(tr) else []:
    try:
        e = json.loads(line)
    except ValueError:
        continue
    for b in (e.get("message") or {}).get("content") or []:
        # tool names can log as null; the arguments preview identifies the
        # call well enough for counting
        if not (isinstance(b, dict) and b.get("type") == "toolCall"):
            continue
        name = b.get("name") or "?"
        args = json.dumps(b.get("arguments") or {}, sort_keys=True)
        calls.append((name, args))
        if name in ("edit", "write") and first_edit is None:
            first_edit = len(calls)
        if ".evidence.md" in args:
            evidence = True

if calls or os.path.exists(tr):
    seen = {}
    for pair in calls:
        seen[pair] = seen.get(pair, 0) + 1
    repeats = sum(v - 1 for v in seen.values() if v > 1)
    git_ran = any(n == "bash" and re.search(r"\bgit\b", a) for n, a in calls)
    facts.update(
        calls=len(calls),
        first_edit=f"#{first_edit}" if first_edit else "-",
        repeats=repeats,
        git="yes" if git_ran else "no",
        evidence_read="yes" if evidence else "no",
    )
else:
    # no transcript to count from — meta's toolCount is all there is
    facts.update(
        transcript="absent",
        calls=m.get("toolCount", "?"),
        first_edit="-",
        repeats="?",
        git="?",
        evidence_read="?",
    )

print(" ".join(f"{k}={v}" for k, v in facts.items()))
EOF
