# Harness notes — Copilot CLI

Read this file only when you run as GitHub Copilot CLI — you have the `task`
tool and `ask_user`. Other harnesses have their own `<harness>/HARNESS.md`;
those are not yours.

How each capability the orchestrator skill names lands in Copilot CLI.

| Capability | In Copilot CLI |
|---|---|
| Dispatch a sub-agent with model M | `task` tool, `mode: "sync"`. Worker: `agent_type: "general-purpose"`. Reviewer: `agent_type: "code-review"` (read-only). `model` takes the bare model id; a `:effort` suffix in the catalog becomes `reasoning_effort` (`gpt-5.6-luna:high` → `model: "gpt-5.6-luna"`, `reasoning_effort: "high"`). The prompt only says: read the spec file, do it, end with one status token |
| Hard caps | The `task` tool has no wall-clock or tool-call cap. The brake is the spec's Budget section plus the canary after the child returns. A runaway child cannot be killed from inside the run |
| Telemetry | `canary.py` in this directory — `canary.py [<agent-id-prefix> \| -] [<session-dir>]` prints one key=value line: `agent type model exit duration_s tokens calls first_edit repeats git evidence_read`. It reads the session log `~/.copilot/session-state/<session>/events.jsonl`. `-` means the newest sub-agent of the session; the session defaults to the newest one whose cwd is the repo you run from — pass the session dir to pin it when several sessions share a repo. `task` results carry no agent id, so `-` is the normal mode |
| Ask one structured question | `ask_user` — one form, a single `string` enum field of the preset names |
| Read-only reviewer | the `code-review` agent cannot run the trust command — hence the evidence file as required reading |

Edit calls are `edit` and `create`. A child that dies leaves no
`subagent.completed` event: the canary reports `exit=incomplete`, and that
is a trip.

Harnesses without a capability use the fallbacks the skill names: no turn
cap → the spec Budget; no telemetry → the child's self-report plus
`git diff --stat`.
