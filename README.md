# Personal AI Marketplace

Skills for AI coding tools. `./link.sh` installs them into opencode, pi, Claude Code, and GitHub Copilot. Markdown skills and shell scripts, no build step.

## Install

```bash
./link.sh     # install skills and agents into every tool
```

Run `./link.sh` outside a sandbox. It stages `skills/` to `~/.config/agents` and links from there into each tool's config directory. Tools that are not installed get skipped. Re-run it after you add, rename, or remove a skill.

## The process

An idea becomes working code in five moves. Each move ends with an artifact. The next move reads that artifact, so nothing gets retold.

```
/jam-with-me ──► /grill-with-docs ──► /to-spec ──► /to-tickets ──► implement
    bundle            CONTEXT.md          spec.md       issues/NN     the frontier
                      + ADRs
                      │
                      └─ session ends early → .scratch/<effort>/map.md, resume later
```

### 1. Make the idea — /jam-with-me

Think out loud. The session follows your energy, then captures the result as an idea bundle: core idea, open questions, next steps. Already know the shape? Skip this step and start with grilling.

### 2. Sharpen it — /grill-with-docs

The agent interviews you in rounds. Each round asks the open questions and recommends an answer. As terms settle, they go straight into the project's `CONTEXT.md` glossary. Hard-to-reverse trade-offs become ADRs. When no questions remain, you move on.

A question that words cannot answer? Take a `/prototype` detour and react to real code.

The session runs out before the questions do? The skill writes a map — destination, decisions so far, open questions — to `.scratch/<effort>/map.md`. A later session loads it and continues.

### 3. Write the spec — /to-spec

No interview here. The agent synthesizes what you already discussed into `.scratch/<feature>/spec.md`: problem, solution, decisions, and one optional check that proves the thing works.

### 4. Cut tickets — /to-tickets

The spec becomes vertical slices. Each ticket delivers something you can verify on its own, fits one agent session, and names the tickets that block it. Tickets land in `.scratch/<feature>/issues/`, one file per ticket. The agent walks you through the breakdown before it writes anything.

### 5. Implement

Work the frontier: any ticket whose blockers are done. Keep it KISS and human readable. Non-trivial logic gets one runnable check. Nothing more.

When a session dies mid-move and no artifact covers the work yet, `/handoff` compacts it into a document for the next agent.

## Skills

| Skill | Use it to |
|---|---|
| `/jam-with-me` | Think out loud about a rough idea; end with an idea bundle |
| `/grill-with-docs` | Interview the idea into shape; capture terms and decisions |
| `/prototype` | Answer a design question with throwaway code |
| `/to-spec` | Turn the session into a spec |
| `/to-tickets` | Slice the spec into tickets with blocking edges |
| `/issue` | File work in a tracker (GitHub, Linear, Jira) |
| `/handoff` | Hand a dying session to the next agent |
| `/orchestrator` | Run a pre-sliced plan unattended (rethink pending) |
| `/agent-writer` | Write or regenerate a project's `AGENTS.md` |
| `grilling` | Stress-test a plan without the domain capture (the primitive under grill-with-docs) |
| `code-review` | Review a diff against standards and spec |
| `git-commit` | Write well-formed Conventional Commits |
| `pr` | Open a pull request with full context |
| `markdown-writer` | Write prose that reads human |
| `writing-for-agents` | Author or edit skills — the standard for this repo |

## Where things live

- Planning artifacts — specs, tickets, maps: `.scratch/<feature>/` in the project. Untracked scratch.
- Domain docs — `CONTEXT.md` and `docs/adr/`: in the project repo. Tracked.
- `AGENTS.md`: each project's rules. It names that project's artifact home, so repos on GitHub Issues or Jira override the `.scratch/` default. `/agent-writer` writes it.

## Conventions

- Conventional Commits everywhere: `feat(scope):`, `fix(scope):`, `refactor:`.
- Edit skill sources in this repo. Never edit the linked copies or the `~/.config/agents` stage. Run `./link.sh` after changes.
- Keep implementations KISS and human readable. Each project's `AGENTS.md` carries this rule.
- `ATTRIBUTION.md` records what we adapted, and from where. Most of the interview skills trace back to [mattpocock/skills](https://github.com/mattpocock/skills).

## Repo layout

```
skills/            the skills — edit here
link.sh            installer
ATTRIBUTION.md     upstream lineage
```
