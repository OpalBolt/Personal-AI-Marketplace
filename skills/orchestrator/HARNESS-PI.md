# Harness notes — Pi

Read this file only when you run as Pi — the `PI_` environment variables
are present. Other harnesses have their own `HARNESS-<name>.md`; those are
not yours.

How each capability the orchestrator skill names lands in Pi. Requires the
pi-subagents extension (its `worker` and `reviewer` agents).

| Capability | In Pi |
|---|---|
| Dispatch a sub-agent with model M | `subagent` tool; `model` takes the full `provider/id` string |
| Hard caps | `timeoutMs` on every child (wall clock); `turnBudget {maxTurns, graceTurns}` for a turn cap |
| Telemetry | run metadata `*_meta.json` under `~/.pi/agent/sessions/<encoded-cwd>/subagent-artifacts/` gives usage numbers; call-log facts (repeats, first-edit call, forbidden commands, evidence-not-read) are counted with a one-line shell command over the transcript file — the transcript itself never enters context |
| Ask one structured question | `ask_user_question` |
| Read-only reviewer | the `reviewer` agent cannot run shell, and its `watchdog_diff` cannot see committed ranges — hence the evidence file as required reading |

Harnesses without a capability use the fallbacks the skill names: no turn
cap → the spec Budget plus the wall-clock timeout; no telemetry → the
child's self-report plus `git diff --stat`.
