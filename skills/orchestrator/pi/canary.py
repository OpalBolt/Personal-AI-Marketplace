#!/usr/bin/env python3
"""Canary facts for one child run — meta numbers plus call-log counts, as one
key=value line. usage: canary.py <run-id-prefix | ->
"-" means the newest child run. Artifacts are matched newest-first across
all session dirs, so the caller passes nothing but a prefix.
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
        ("PYTHONPATH=/home/mads/git/x python -m y", False),
        ("cat .gitignore", False),
        ("git status", True),
        ("cd repo && git diff a.py", True),
        ("ls; git log", True),
        ("echo $(git rev-parse HEAD)", True),
    ]:
        assert bool(GIT_CMD.search(cmd)) == want, cmd
    print("ok")
    sys.exit()

pat = sys.argv[1] if len(sys.argv) > 1 else "-"
if pat == "-":
    # newest child of the repo this runs from; concurrent orchestrators in
    # other repos cannot collide with it
    cwd_dir = "--" + os.getcwd().strip("/").replace("/", "-") + "--"
    matches = glob.glob(os.path.expanduser(
        f"~/.pi/agent/sessions/{cwd_dir}/subagent-artifacts/*_meta.json"))
    label = "-"
else:
    matches = glob.glob(os.path.expanduser(
        f"~/.pi/agent/sessions/*/subagent-artifacts/{pat}*_meta.json"))
    label = pat
if not matches:
    sys.exit(f"canary: no artifacts match '{label}' (for '-', run it from the repo being orchestrated)")
meta_path = max(matches, key=os.path.getmtime)

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

calls, first_edit, evidence, git_ran = [], None, False, False
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
        cmd = (b.get("arguments") or {}).get("command")
        if name == "bash" and isinstance(cmd, str) and GIT_CMD.search(cmd):
            git_ran = True
        if name in ("edit", "write") and first_edit is None:
            first_edit = len(calls)
        if ".evidence.md" in args:
            evidence = True

if calls or os.path.exists(tr):
    seen = {}
    for pair in calls:
        seen[pair] = seen.get(pair, 0) + 1
    repeats = sum(v - 1 for v in seen.values() if v > 1)
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
