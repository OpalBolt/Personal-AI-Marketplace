# AGENTS.md

## Project overview
Markdown skills and shell scripts, no build step. `link.sh` stages `skills/` and each tool's agents through `~/.config/agents` into every tool's global config directory.

## Commands
- `./link.sh` — install skills and agents into all tools
- `skills/orchestrator/init.sh` — set up the orchestrator plan dir; writes `AI_PLAN_DIR` to `./.env`
- `nix develop` — dev shell (sqlite, gh)

## Artifacts
- Artifact home: `.scratch/` — specs, tickets, maps. Local markdown, untracked.

## Boundaries
### ✅ Always
- Write Conventional Commits (`feat(scope):`, `fix(scope):`, `refactor:`)
- Run `./link.sh` after adding, renaming, or removing a skill or agent

### ⚠️ Ask first
- Add a new skill or agent
- Edit model IDs in `skills/orchestrator/models.json`
- Change `.mcp.json`

### 🚫 Never
- Commit `.env` or plan files — `init.sh` writes `AI_PLAN_DIR` to `.env`; plans live outside the repo by design
- Edit skills in the linked global copies or the `~/.config/agents` stage — the stage is rebuilt from this repo on every run; edit the source here

## Code style
Prose and shell, KISS and human readable above all. Shell scripts use `set -euo pipefail`. Comments only for a non-obvious why, a workaround, or a hidden risk.
