#!/bin/bash
# Stage everything under the repo except the excluded pathspecs, commit, print
# the short hash. Excludes protect the user's own uncommitted files (e.g.
# roadmap.md CONTEXT.md).
# usage: commit.sh <repo> "<message>" [exclude-pathspec ...]
set -euo pipefail
repo=$1
msg=$2
shift 2
cd "$repo"
excludes=()
for p in "$@"; do excludes+=(":!$p"); done
git add -A -- . "${excludes[@]}"
if git diff --cached --quiet; then
  echo "nothing to commit"
  exit 0
fi
git commit -q -m "$msg"
git rev-parse --short HEAD
