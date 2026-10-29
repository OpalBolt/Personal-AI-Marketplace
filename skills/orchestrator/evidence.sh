#!/bin/bash
# Run the trust command and the slice diff into <topic-dir>/orch/<slug>.evidence.md.
# Prints the trust exit line; the output itself stays on disk, out of context.
# usage: evidence.sh <repo> <topic-dir> <slice-file> <fixed-point>
# env: TRUST_CMD  the command that builds trust in this repo (default: skip)
set -euo pipefail
repo=$1
topic=$2
slice=$3
fp=$4
slug=$(basename "${slice%.md}")
slug=${slug#*-}
e="$topic/orch/$slug.evidence.md"

cd "$repo"
{
  echo "# Evidence $slug"
  echo
  echo "## Trust: ${TRUST_CMD:-none}"
  echo '```'
  if [ -n "${TRUST_CMD:-}" ]; then
    # pipefail off for this pipeline: a failing trust run is data, not an abort
    set +o pipefail
    timeout 900 bash -c "$TRUST_CMD" 2>&1 | tail -40
    rc=${PIPESTATUS[0]}
    set -o pipefail
    echo "exit=$rc"
  else
    echo "exit=0 (no trust command)"
  fi
  echo '```'
  echo
  echo "## git diff $fp..HEAD"
  echo '```diff'
  git diff "$fp..HEAD"
  echo '```'
} > "$e"
grep '^exit=' "$e"
