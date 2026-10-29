# Harness notes — Pi

Read this file only when you run as Pi — the `PI_` environment variables
are present. Other harnesses have their own `HARNESS-<name>.md`; those are
not yours.

How each capability the orchestrator skill names lands in Pi. Requires the
pi-subagents extension (its `worker` and `reviewer` agents).

| Capability | In Pi |
|---|---|
| Dispatch a sub-agent with model M | `subagent` tool; `model` takes the full `provider/id` string |
| Hard caps | `timeoutMs` (wall clock; harness default 30m) and `toolBudget {hard, soft, block}` — past `soft` the child is nudged to finalize, past `hard` its read/grep/find/ls calls are blocked so it must finish from context. That block list is the brake for a grep-loop. The incident's healthy retry took 42 calls; set soft/hard in that order, scaled to the slice |
| Telemetry | run metadata `*_meta.json` under `~/.pi/agent/sessions/<encoded-cwd>/subagent-artifacts/` holds usage tokens and exitCode (not call counts); count call-log facts (repeats, first-edit call, forbidden commands, evidence-not-read) with a one-line shell command over the transcript file — the transcript itself never enters context. Tool names can log as null; count calls from the argsPayload previews |
| Ask one structured question | `ask_user_question` |
| Read-only reviewer | the `reviewer` agent cannot run shell, and its `watchdog_diff` cannot see committed ranges — hence the evidence file as required reading |

Harnesses without a capability use the fallbacks the skill names: no turn
cap → the spec Budget plus the wall-clock timeout; no telemetry → the
child's self-report plus `git diff --stat`.
