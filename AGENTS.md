# AGENTS.md

## Project overview
Personal AI Marketplace ships opencode skills and a generic `worker` agent. `link.sh` symlinks the skills and agents into each tool's global config directory. A Nix flake provides the dev shell (sqlite, gh). MCP servers run from `.mcp.json`. There is no build step. The repo holds markdown skills and shell scripts.

## Commands
- Run `./link.sh` to link skills and agents into each tool's config directory.
- Run `skills/orchestrator/init.sh` to initialize the orchestrator plan dir. The script writes `AI_PLAN_DIR` to `./.env`.
- Run `nix develop` to start the dev shell.

## Artifacts
- Specs/tickets/maps: `.scratch/` (local markdown, untracked). Real trackers stay available per project when warranted.

## Boundaries
### ✅ Always
- Write Conventional Commits (`feat(scope):`, `fix(scope):`, `refactor:`)
- Run `./link.sh` after you add or rename a skill or agent. This symlinks the new file into each tool's config directory.

### ⚠️ Ask first
- Add a new skill or agent
- Edit model IDs in `models.json`
- Change `.mcp.json`

### 🚫 Never
- Commit `.env`. `init.sh` writes `AI_PLAN_DIR` to it.
- Edit skills in the linked, global location, or in the `~/.config/agents` stage — `link.sh` rebuilds the stage from the repo on every run. Edit the source in this repo.
- Commit plan files. They live outside the repo by design, under `AI_PLAN_DIR`.

## Code style
Self-documenting prose and shell, KISS and human readable above all. Shell scripts use `set -euo pipefail`. Add a comment only when it explains a non-obvious why, a workaround, or a hidden risk. Do not restate what the code does.
