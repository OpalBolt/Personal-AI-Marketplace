---
name: preferred-tools
description: Defines which CLI tools to use for common operations in this environment. Always apply these tool preferences when searching files or processing data. Prefer modern alternatives over traditional Unix tools when available.
---

# Preferred Tools

| Task | Use | Instead of |
|------|-----|------------|
| Search file contents | `rg` | `grep`, `grep -r` |
| Find files by name/type | `fd` | `find` |
| Process JSON | `jq` | `python -m json.tool` |
| Process YAML | `yq` | manual parsing |
| HTTP requests | `curl` | `wget` |
| GitHub operations | `gh` | raw API calls |

## Nix Environments

If a `.nix` file or `flake.nix` exists in the project root, run all build and development commands through Nix rather than invoking tools directly. This ensures tools are available regardless of what is installed on the host system. Never try to run tools directly from the nix store,

- Run a command in the dev environment: `nix develop --command python main.py`
- Run a shell script in the dev environment: `nix develop --command bash -c "mkdir build && cmake .. && make"`
- Run a flake app: `nix run`
- Build the project: `nix build`

Do not assume tools like `node`, `cargo`, `go`, `python`, etc. are available natively — run them via `nix develop` or `nix run` instead.
