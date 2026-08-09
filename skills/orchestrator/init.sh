#!/usr/bin/env bash
set -euo pipefail

# Initialize the plan dir for the current repo, expose it as AI_PLAN_DIR in
# ./.env (so skills read one var instead of re-deriving it), and print it.
# Plans live outside the repo so they never pollute it.

if ! repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "error: not inside a git repo" >&2
  exit 1
fi

PLANS_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/ai-plans"
plan_dir="$PLANS_ROOT/$(basename "$repo_root")"
mkdir -p "$plan_dir"

# Write AI_PLAN_DIR to the repo's .env, replacing any prior value, leaving
# other lines untouched.
env_file="$repo_root/.env"
touch "$env_file"
tmp="$(mktemp)"
grep -vE '^AI_PLAN_DIR=' "$env_file" > "$tmp" || true
printf 'AI_PLAN_DIR="%s"\n' "$plan_dir" >> "$tmp"
mv "$tmp" "$env_file"

echo "$plan_dir"
