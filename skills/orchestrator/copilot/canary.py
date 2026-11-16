#!/usr/bin/env python3
"""Canary facts for one Copilot CLI sub-agent run, as one key=value line.
usage: canary.py [<agent-id-prefix> | -] [<session-dir>]
"-" means the newest sub-agent. The session defaults to the newest one in
~/.copilot/session-state whose cwd is the current directory.
"""
import glob
import json
import os
import re
import sys

# shortcut: not caught: `env X=1 git`, `xargs git`, `sh -c "git ..."`; a heredoc
# line starting with "git " is a false hit. Upgrade only if that bites.
GIT_CMD = re.compile(r"(?:^|[;&|`(\n]|\$\()\s*git\s")

if sys.argv[1:] == ["--selftest"]:
    for cmd, want in [
        ("cd /home/mads/git/x && uv run pytest -q", False),
        ("cat .gitignore", False),
        ("git status", True),
        ("cd repo && git diff a.py", True),
        ("echo $(git rev-parse HEAD)", True),
    ]:
        assert bool(GIT_CMD.search(cmd)) == want, cmd
    print("ok")
    sys.exit()

pat = sys.argv[1] if len(sys.argv) > 1 else "-"
root = os.path.expanduser("~/.copilot/session-state")

if len(sys.argv) > 2:
    log = os.path.join(sys.argv[2], "events.jsonl")
else:
    cwd = os.getcwd()
    candidates = []
    for p in glob.glob(os.path.join(root, "*", "events.jsonl")):
        try:
            with open(p) as f:
                start = json.loads(f.readline())
        except (OSError, ValueError):
            continue
        if (start.get("data", {}).get("context") or {}).get("cwd") == cwd:
            candidates.append(p)
    if not candidates:
        sys.exit(f"canary: no session found for cwd {cwd}")
    log = max(candidates, key=os.path.getmtime)

events = []
for line in open(log):
    try:
        events.append(json.loads(line))
    except ValueError:
        continue

started = [e for e in events if e["type"] == "subagent.started"
           and (pat == "-" or e.get("agentId", "").startswith(pat))]
if not started:
    sys.exit(f"canary: no sub-agent matches '{pat}' in {log}")
s = started[-1]
aid = s["agentId"]
sd = s["data"]
done = next((e for e in events if e["type"] == "subagent.completed"
             and e.get("agentId") == aid), None)
dd = done["data"] if done else {}

facts = dict(
    agent=aid[:8],
    type=sd.get("agentType", "?"),
    model=dd.get("model") or sd.get("model", "?"),
    exit="ok" if done else "incomplete",
    duration_s=round((dd.get("durationMs") or 0) / 1000),
    tokens=dd.get("totalTokens", "?"),
)

calls, first_edit, evidence, git_ran = [], None, False, False
for e in events:
    if e["type"] != "tool.execution_start" or e.get("agentId") != aid:
        continue
    d = e["data"]
    name = d.get("toolName") or "?"
    args = d.get("arguments") or {}
    blob = json.dumps(args, sort_keys=True)
    calls.append((name, blob))
    cmd = args.get("command")
    if name == "bash" and isinstance(cmd, str) and GIT_CMD.search(cmd):
        git_ran = True
    if name in ("edit", "create") and first_edit is None:
        first_edit = len(calls)
    if ".evidence.md" in blob:
        evidence = True

seen = {}
for pair in calls:
    seen[pair] = seen.get(pair, 0) + 1
facts.update(
    calls=len(calls),
    first_edit=f"#{first_edit}" if first_edit else "-",
    repeats=sum(v - 1 for v in seen.values() if v > 1),
    git="yes" if git_ran else "no",
    evidence_read="yes" if evidence else "no",
)
print(" ".join(f"{k}={v}" for k, v in facts.items()))
