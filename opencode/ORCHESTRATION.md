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
[task] -> orchestrator -> [slice spec] -> worker -> [report]
                 orchestrator: commit impl
                 orchestrator -> [review spec] -> reviewer -> [verdict]
                 approve -> next slice | issues -> [fix spec] -> worker (once)
                 orchestrator: end-of-run validation | rollback
```

## Roles

| Responsibility | Orchestrator | Leaf worker | Leaf reviewer |
|----------------|--------------|-------------|----------------|
| Split and refine slices | yes | no | no |
| Implement one slice | no | yes | no |
| Review a slice's diff | no | no | yes |
| Run the full test suite | end of run | no | yes, per slice |
| Git (status, diff, commit, rollback) | yes | no | no — the diff arrives in the spec |
| Recurse into subagents | yes | no (`task: deny`) | no (`task: deny`) |
| Risky moves | yes | no | no |

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

Validation runs in three tiers.

1. Worker self-check (cheap, local). Lint the touched files. Typecheck them
   only when the change crosses types. No full test suite. No integration
   runs. The worker reports the exact commands and the result.
2. Reviewer, per slice. Reviews the committed diff against the slice's
   acceptance criteria and the code-review smell baseline, runs the trust
   command (usually the full test suite; sometimes nothing), and returns a
   verdict.
3. Orchestrator, end of run. One full-suite pass across all slices —
   per-slice green does not prove cross-slice green.

The worker self-check turns the reviewer job into confirmation, not
discovery, for the files in the lane. The reviewer verdict turns the
orchestrator job into triage, not judgement.

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

The reviewer returns:

```
## Verdict
approve | issues

## Issues
- <file>:<line> — <what> · <suggested fix> · must-fix | nit

## Tests
<command> — <result>
```

`Verdict` is one keyword from a closed set, same reason as `Status`. The
reviewer never edits files; findings become a fix spec for the worker.

## Review cycle

Each slice closes with a review, before the next slice starts:

1. The worker reports `done` or `partial`; the orchestrator commits the
   implementation (`feat:` or similar).
2. The orchestrator writes the review spec — acceptance criteria, the diff
   and commit list since the commit before the slice, the trust command —
   and dispatches the reviewer with the run model.
3. `approve`: next slice. `issues`: the findings become a fix spec, the
   worker runs it, the reviewer re-reviews once.
4. Still `issues`: the slice is blocked (see Blocked and rollback).

Fixes commit as `fix:` only when something changed. One fix round per slice —
an unbounded fix loop is the overnight-run killer.

## Models

One run model per run, shared by every sub-agent — worker and reviewer
alike. It is named in the invocation or chosen from the tool's available
models before the run starts, never mid-run. There is no static model map.

## Blocked and rollback

- A blocked worker stops. It leaves the tree as it stands and reports
  `blocked`. It does not revert. It does not half-finish.
- A slice still reporting review issues after one fix round is blocked the
  same way.
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

- The orchestrator prompt and permissions, as an opencode agent file.
- Whether workers run in parallel, and the coordination that requires.
