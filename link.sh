#!/usr/bin/env bash
set -euo pipefail

# Copy every skill in ./skills and agent in ./<tool>/agents into the
# central stage at ~/.config/agents first, then symlink from the stage
# into each tool's global config dir. Sandboxed tools only need read
# access to the stage, never to this repo. The stage is rebuilt from
# the repo on every run.
# Removes stale links to skills/agents that no longer exist here.
# Skips tools that aren't installed; skips a tool's agents if it has no
# ./<tool>/agents source folder. Creates the dest dirs if missing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills"
STAGE_ROOT="$HOME/.config/agents"

# Rebuild one stage dir from its repo source. Fresh copy every run;
# existing tool links keep resolving since they target the same path.
stage_contents() {
  local src="$1" dest="$2"
  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  echo "staged $src -> $dest"
}

stage_contents "$SRC" "$STAGE_ROOT/skills"

# Ensure the shared plans dir exists before any sandboxed AI run needs it.
# The sandbox grants ~/.local/share/ai-plans but not its parent, so the
# first-time bootstrap must happen here (human-run, unsandboxed).
PLANS_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/ai-plans"
mkdir -p "$PLANS_ROOT"

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

  link_contents "$STAGE_ROOT/skills" "$dest" "$name"

  agents_src="$SCRIPT_DIR/$name/agents"
  [ -d "$agents_src" ] || continue
  stage_contents "$agents_src" "$STAGE_ROOT/$name-agents"
  link_contents "$STAGE_ROOT/$name-agents" "$(dirname "$dest")/agents" "$name"
done
