#!/usr/bin/env bash
set -euo pipefail

# Link every skill in ./skills into each tool's global skills directory.
# Link every agent in ./<tool>/agents into that tool's global agents directory.
# Removes stale links to skills/agents that no longer exist here.
# Skips tools that aren't installed; skips a tool's agents if it has no
# ./<tool>/agents source folder. Creates the dest dirs if missing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills"

# name | executable | global skills dir
tools=(
  "opencode|opencode|$HOME/.config/opencode/skills"
  "pi|pi|$HOME/.pi/agent/skills"
  "claude|claude|$HOME/.claude/skills"
  "copilot|copilot|$HOME/.copilot/skills"
)

# ponytail: link each entry, not the whole dir, so a tool's own pre-existing
# skills/agents survive. Replace links that already point into src; skip real
# files; drop links whose source has vanished.
link_contents() {
  local src="$1" dest="$2" label="$3"
  mkdir -p "$dest"
  local item name link target
  for item in "$src"/*; do
    [ -e "$item" ] || [ -L "$item" ] || continue
    name="$(basename "$item")"
    link="$dest/$name"
    if [ -L "$link" ]; then
      rm "$link"
    elif [ -e "$link" ]; then
      echo "[$label] $name already exists (not a symlink), skipping"
      continue
    fi
    ln -s "$item" "$link"
    echo "[$label] linked $name"
  done
  for link in "$dest"/*; do
    [ -L "$link" ] || continue
    target="$(readlink -f "$link")"
    case "$target" in
      "$src"/*) ;;
      *) continue ;;
    esac
    [ -e "$target" ] || { rm "$link"; echo "[$label] removed stale $(basename "$link")"; }
  done
}

for entry in "${tools[@]}"; do
  IFS='|' read -r name bin dest <<< "$entry"

  command -v "$bin" >/dev/null 2>&1 || { echo "[$name] not installed, skipping"; continue; }

  link_contents "$SRC" "$dest" "$name"

  agents_src="$SCRIPT_DIR/$name/agents"
  [ -d "$agents_src" ] || continue
  link_contents "$agents_src" "$(dirname "$dest")/agents" "$name"
done
