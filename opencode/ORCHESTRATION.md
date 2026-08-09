# Orchestration Spec

This document is the source of truth for the orchestrator and leaf-worker
pattern. It records the rules agreed during design. Agent prompts implement
these rules. They do not redefine them. Check any orchestrator or worker
agent against this document.

## Pattern

An orchestrator (a primary agent) splits a larger task into vertical slices.
It refines each slice into a self-contained spec, then hands the spec to a
leaf worker (a subagent). The worker implements its slice and reports back.
The orchestrator owns the risk. It runs the final validation, does the git
operations, and rolls back when needed.

```
[task] -> orchestrator -> [slice spec] -> worker -> [report] -> orchestrator
                                      orchestrator: validate | commit | rollback
```

## Roles

| Responsibility | Orchestrator | Leaf worker |
|----------------|--------------|-------------|
| Split and refine slices | yes | no |
| Implement one slice | no | yes |
| Git (status, diff, commit, rollback) | yes | no |
| Final and overarching validation | yes | no |
| Recurse into subagents | yes | no (`task: deny`) |
| Risky moves | yes | no |

## Slice contract

A slice is self-contained. It names:
- The file or files in scope (the worker lane).
- The goal for those files.
- The context the worker needs to implement without further research.
- The acceptance criteria the worker can self-check against.

The worker does not decompose the work, does not research broadly, and does
not recurse. If the slice is ambiguous, the worker makes the smallest safe
assumption, writes it down, and proceeds. If it cannot, it reports `blocked`.

## Lane discipline

- The worker touches only what its slice names.
- A minimal spill is allowed. If a touched file will not stay valid without
  a one-hop change elsewhere (for example, a caller signature), the worker
  makes the smallest fix and marks it in the code:

      # spill: Required for <reason>

- One hop only. No transitive spills.
- Anything beyond one hop, or any "while I am here" expansion, becomes a
  note, never a change. The worker reports it and stops if it must.
- The `# spill:` marker is greppable. The orchestrator can find every
  out-of-lane change across the repo with one search.

## Validation contract

Validation runs in two tiers.

1. Worker self-check (cheap, local). Lint the touched files. Typecheck them
   only when the change crosses types. No full test suite. No integration
   runs. The worker reports the exact commands and the result.
2. Orchestrator final validation. Whatever builds trust in the whole: the
   full test suite, integration checks, review across slices. The
   orchestrator sets the bar per task.

The worker self-check turns the orchestrator job into confirmation, not
discovery, for the files in the lane.

## Report format

The worker returns:

```
## Status
done | partial | blocked

## Notes
- Short bullets only. No prose.
- What changed, and why.
- Every spill, with its reason.
- What was verified (commands and result).
- Anything the orchestrator must know.
```

`Status` is one keyword from a closed set. The orchestrator can triage many
results without parsing prose. There is no `Files changed` section. The
orchestrator reads the changed files from `git status`.

## Blocked and rollback

- A blocked worker stops. It leaves the tree as it stands and reports
  `blocked`. It does not revert. It does not half-finish.
- The orchestrator decides what to do next: roll back (restore the worker
  files), send a better slice, or escalate.
- The worker avoids a broken tree. If its partial work would break the build
  or lint, it reports `blocked` before it gets there.

## Concurrency

- Today, one worker runs at a time.
- The contract lets this lift to parallel later without rework. Each worker
  carries its own context, writes a disjoint lane, and reports on its own.
  Coordination rules are deferred until parallelism is needed.

## Open (pinned for the orchestrator design)

- The orchestrator prompt, model, and permissions.
- How the orchestrator splits a task into slices and tracks them.
- The default bar for orchestrator final validation.
- Whether workers run in parallel, and the coordination that requires.
