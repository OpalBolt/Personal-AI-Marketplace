#!/bin/bash
# Render the worker spec for one slice into <topic-dir>/orch/<slug>.worker.md.
# usage: mkspec.sh <repo> <topic-dir> <slice-file> [notes-file]
# env: TRUST_CMD  self-check command for the repo (optional)
#      PLAN_DOC   overall plan or glossary the worker reads first (optional)
set -euo pipefail
repo=$1
topic=$2
slice=$3
notes=${4:-}

# drop the NN- prefix: scratch file names must never start with a digit,
# or slice discovery ([0-9][0-9]-*.md) would pick them up as slices
slug=$(basename "${slice%.md}")
slug=${slug#*-}

if [ -n "${TRUST_CMD:-}" ]; then
  check="Self-check: \`cd $repo && $TRUST_CMD\` must pass (baseline: all green)."
else
  check="No trust command for this repo. Verify your change another way and say how."
fi

mkdir -p "$topic/orch"
out="$topic/orch/$slug.worker.md"
cat > "$out" <<EOT
# Worker spec — $slug

Repo: $repo. Work only in this repo.

## Your slice (goal, scope, acceptance criteria)
$(cat "$slice")

## Implementation notes from the orchestrator
$( [ -n "$notes" ] && cat "$notes" || echo "(none)")

## Context to read first
$( [ -n "${PLAN_DOC:-}" ] && echo "- $PLAN_DOC — the overall plan this slice belongs to." )
- The files the notes name, and the code you will change. Follow existing patterns.

## Rules
- The orchestrator owns version control. You never run git — not even read-only commands like status or diff.
- Lane discipline: touch only what this slice needs (its code, tests, and the docs it names). A one-hop fix to keep another file valid is allowed, marked \`# spill: <reason>\`. Anything further is a note, not a change.
- \`# spill:\` markers left by earlier plans are not yours to resolve; ignore them.
- Every acceptance criterion with a checkbox is required.

## Budget — hard rules
- Read only what you need: this spec, then the files the notes name. Never repeat an identical grep or read.
- Make your first edit within 20 tool calls. If after 40 tool calls you still have no edit, or you cannot decide something, STOP and report blocked with the exact question. A blocked report beats a loop.
- Aim for the smallest diff that meets the checkboxes.

## Self-check
$check

## Report
End with: status (done | partial | blocked), files changed, how each acceptance criterion is met, tool calls made, and any notes or spills.
EOT
echo "$out"
