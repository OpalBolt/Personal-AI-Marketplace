# AGENTS.md

## Project overview
Personal AI Marketplace ships markdown skills and shell scripts — no build step. `./link.sh` stages `skills/` and each tool's agents through `~/.config/agents` into the global config directories of opencode, pi, Claude Code, and Copilot. A Nix flake provides the dev shell.

## Commands
- `./link.sh` — install skills and agents into every tool's config dir
- `skills/orchestrator/init.sh` — initialize the orchestrator plan dir; writes `AI_PLAN_DIR` to `./.env`
- `nix develop` — dev shell (sqlite, gh)

## Artifacts
- Specs/tickets/maps: `.scratch/` (local markdown, untracked). Real trackers per project when warranted.

## Boundaries
### ✅ Always
- Write Conventional Commits (`feat(scope):`, `fix(scope):`, `refactor:`)
- Run `./link.sh` after you add, rename, or remove a skill or agent

### ⚠️ Ask first
- Add a new skill or agent
- Edit model IDs in `skills/orchestrator/models.json`
- Change `.mcp.json`

### 🚫 Never
- Commit `.env` — `init.sh` writes `AI_PLAN_DIR` to it. Commit no plan files either; they live under `AI_PLAN_DIR`, outside the repo by design.
- Edit skills in the linked global location or the `~/.config/agents` stage — `link.sh` rebuilds the stage from the repo on every run. Edit the source in this repo.

## Code style
Self-documenting prose and shell, KISS and human readable above all. Shell scripts use `set -euo pipefail`. Add a comment only when it explains a non-obvious why, a workaround, or a hidden risk. Do not restate what the code does.
