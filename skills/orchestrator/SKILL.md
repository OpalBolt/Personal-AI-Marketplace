---
name: orchestrator
description: Run a pre-sliced plan to completion, unattended. Hand it a sliced plan directory (produced by jam-with-me and to-issues); it refines each slice into a worker spec, dispatches a leaf worker subagent with the matched model, validates, commits per slice, and retries or skips on failure. Use when the user says "orchestrate", "run the plan", "execute the slices", "run this overnight", or wants a sliced plan run autonomously end-to-end. Does not plan or slice; it only executes.
---

# Orchestrator

Run a pre-sliced plan to completion, unattended. One worker at a time.

This skill is the execution loop. It does not plan or slice. A plan arrives
already sliced (one file per slice) in a plan directory. You consume it.

## Inputs

- A plan directory with an overarching `plan.md` and numbered slice files
  `slice-NN-slug.md`.
- Each slice names its files in scope, its goal, its context, its acceptance
  criteria, and a `Blocked by` field (the slices it depends on).

## Before you run

- Resolve the plan directory: read `AI_PLAN_DIR` from `.env` in the repo root
  (written there by `init.sh`). If `.env` has no `AI_PLAN_DIR`, run `init.sh`
  first.
- Discover slices: glob `slice-*.md` in the plan dir, sort by the `NN` prefix.
  That is your run order.
- Find the worker model in `models.json` (sibling), keyed by runtime then model
  ID, with a `default` fallback:

  ```sh
  jq -r --arg t "<runtime>" --arg m "<your-model-id>" \
    '.[$t][$m].worker // .default.worker' models.json
  ```

  Substitute `<runtime>` (e.g. `opencode`) and `<your-model-id>`. A `default` or
  `inherited` result means the worker uses your model. If you cannot determine
  your own runtime or model ID, ask the user.
  

## The loop (sequential, one slice at a time)

For each slice, in order:

1. **Refine.** Turn the slice into a self-contained worker spec: the files in
   scope, the goal, the context the worker needs, and the acceptance criteria
   it can self-check. Write it to a scratch file.
2. **Dispatch.** Spawn a worker subagent. Tell it to read its spec from the
   scratch file. Pass the worker model from the lookup.
3. **Receive.** The worker returns a status: `done`, `partial`, or `blocked`.
4. **Triage.**
   - `done` or `partial`: validate (see Validation), then commit (see Git).
     Move to the next slice.
   - `blocked`: re-refine the spec using what the failure revealed, then retry
     the slice once. If it blocks again, decide skip vs. stop (see Blocked).
5. After the last slice, write a final summary: slices done, skipped, blocked,
   and why.

Never pause mid-run for human input. The plan was reviewed before you started.
That is the whole point: launch it, then leave.

## Validation

Two tiers. The worker self-checks the files in its lane (lint; typecheck only
if the change crosses types) and reports the commands and the result. You own
the final check across the whole: the full test suite, or whatever builds
trust. You set the bar per run.

## Git

You own all version control. Commit after each successful slice, before the
next slice starts. This keeps finished work safe if the run dies. Rollback is
granular: revert one slice's commit. Workers never run git.

## Blocked

A worker that cannot finish stops and reports `blocked`. It does not revert.
It does not half-finish. After the single retry, decide:

- **Skip** when no remaining slice lists this one in its `Blocked by`. Roll
  back its files, mark it skipped, continue.
- **Stop** when any unrun slice depends on it. Halt the run and report.

## Lane discipline

The worker touches only what its slice names. It may make a one-hop fix to keep
a file valid, marked in code as `# spill: <reason>`. Anything beyond one hop is
a note, not a change. After each slice, grep for `# spill:` to review
out-of-lane changes.

## Conventions

- Plan directory: `AI_PLAN_DIR` from the repo's `.env` (set by `init.sh`).
- Worker scratch spec: `/tmp/orchestrator/<slice-slug>.md`.
- The worker subagent is `worker`.
