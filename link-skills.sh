#!/usr/bin/env bash
set -euo pipefail

# Link every skill in ./skills into each tool's global skills directory.
# Removes stale links to skills that no longer exist here.
# Skips tools that aren't installed; creates the skills dir if missing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills"

# name | executable | global skills dir
tools=(
  "opencode|opencode|$HOME/.config/opencode/skills"
  "pi|pi|$HOME/.pi/agent/skills"
  "claude|claude|$HOME/.claude/skills"
  "copilot|copilot|$HOME/.copilot/skills"
)

# ponytail: link per-skill, not the whole dir, so a tool's own pre-existing skills survive.
for entry in "${tools[@]}"; do
  IFS='|' read -r name bin dest <<< "$entry"

  command -v "$bin" >/dev/null 2>&1 || { echo "[$name] not installed, skipping"; continue; }

  mkdir -p "$dest"
  for skill in "$SRC"/*/; do
    [ -d "$skill" ] || continue
    skill_name="$(basename "$skill")"
    link="$dest/$skill_name"
    if [ -L "$link" ]; then
      rm "$link"
    elif [ -e "$link" ]; then
      echo "[$name] $skill_name already exists (not a symlink), skipping"
      continue
    fi
    ln -s "$skill" "$link"
    echo "[$name] linked $skill_name"
  done

  # Remove links to skills no longer in ./skills (deleted or renamed).
  for link in "$dest"/*; do
    [ -L "$link" ] || continue
    target="$(readlink -f "$link")"
    # Only touch links that pointed into our source tree.
    case "$target" in
      "$SRC"/*) ;;
      *) continue ;;
    esac
    [ -e "$target" ] || { rm "$link"; echo "[$name] removed stale $(basename "$link")"; }
  done
done
