#!/bin/bash
# Render the reviewer spec for one slice into <topic-dir>/orch/<slug>.review.md.
# Expects the evidence file at <topic-dir>/orch/<slug>.evidence.md (see evidence.sh).
# usage: mkreview.sh <repo> <topic-dir> <slice-file>
set -euo pipefail
repo=$1
topic=$2
slice=$3
slug=$(basename "${slice%.md}")
slug=${slug#*-}
ev="$topic/orch/$slug.evidence.md"
out="$topic/orch/$slug.review.md"

cat > "$out" <<EOT
# Review spec — $slug

Repo: $repo. You are read-only: you judge, you never edit.

REQUIRED READ FIRST: $ev — it holds the trust-command output and the full
committed diff for this slice. Do not ask for the diff; it is there.

## Slice under review
$(cat "$slice")

## Review on two axes, in one pass
1. Spec: is every checkbox acceptance criterion met by the diff? Name any unmet one.
2. Standards: bugs, unsafe behaviour, missing tests for new logic, needless code, out-of-lane changes (beyond one-hop, or \`# spill:\` markers without a reason).

## Return
A verdict, not an essay. First line: \`VERDICT: approve\` or \`VERDICT: issues\`.
Then, if issues, a numbered list: file:line — problem — required fix. Only
real, actionable issues; nits do not block. State how you confirmed the tests.
EOT
echo "$out"
