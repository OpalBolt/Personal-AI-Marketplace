#!/usr/bin/env bash
set -euo pipefail

# Initialize the central plan directory for the current repo and print its path.
# Plans live outside the repo so they never pollute it.

PLANS_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/ai-plans"

if ! repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "error: not inside a git repo" >&2
  exit 1
fi

slug="$(basename "$repo_root")"
plan_dir="$PLANS_ROOT/$slug"
mkdir -p "$plan_dir"
echo "$plan_dir"
