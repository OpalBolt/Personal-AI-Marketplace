# Orchestrator

Run a sliced plan to completion, unattended. One slice at a time, each closed
by a review.

## What it does

The orchestrator takes a topic dir that is already sliced into files and runs
it end to end. It does not plan or slice. Pair it with `jam-with-me`, which
writes the overarching plan, and `to-tickets`, which slices it.

For each slice, the orchestrator:

1. Prints a status block: last slice, run totals, next slice.
2. Refines the slice into a worker spec and spawns a leaf worker.
3. Commits the implementation.
4. Runs the trust command, then spawns a leaf reviewer with the diff and the
   test output pasted into its spec; the reviewer reads evidence, never runs.
5. Routes findings back to the worker as a fix spec, re-reviews once, commits
   the fixes.
6. Moves to the next slice — or skips or stops when a slice stays blocked.

It commits after every slice, so finished work survives a crash. It never
stops to ask a question mid-run.

## Workflow

1. Run `jam-with-me`. It writes `plan.md` into the topic dir.
2. Run `to-tickets`. It writes one `NN-slug.md` file per slice.
3. Invoke the orchestrator: `orchestrate .scratch/<topic> [model=<id>]`. It
   runs every slice to completion and writes a summary.

Topic dirs default to `.scratch/<topic>/` in the repo — gitignored, so they
never pollute the history. An explicit path anywhere else also works.

## Where files live

| Path | Holds |
|---|---|
| `.scratch/<topic>/` | `plan.md` and the `NN-*.md` slice files |
| `/tmp/orchestrator/<slice-slug>.md` | the worker spec for the current slice |
| `/tmp/orchestrator/<slice-slug>.review.md` | the reviewer spec |

## Models

One run model per run, used by every sub-agent — worker and reviewer alike.
Name it in the invocation (`model=<id>`), or pick it from the tool's available
models when the orchestrator asks before the run starts. There is no static
model map; the choice is per run, by design.

## Failure policy

A slice that cannot finish reports `blocked`. A slice whose review still
reports issues after one fix round is treated the same. The orchestrator
retries a blocked slice once with a refined spec. If it blocks again:

- **Skip** when no later slice depends on it.
- **Stop** when a later slice needs it.

Each slice declares what it is blocked by, so the orchestrator can tell.
