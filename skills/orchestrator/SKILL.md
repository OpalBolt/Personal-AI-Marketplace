---
name: orchestrator
description: Run a pre-sliced plan to completion, unattended. Hand it a .scratch topic directory (produced by jam-with-me and to-tickets); it refines each slice into a worker spec, dispatches a leaf worker with the run model, commits, then a leaf reviewer verifies the diff and confirms the tests. Findings loop through the worker once, then the slice retries or skips. Use when the user says "orchestrate", "run the plan", "execute the slices", "run this overnight", or wants a sliced plan run autonomously end-to-end. Does not plan or slice; it only executes.
---

# Orchestrator

Run a pre-sliced plan to completion, unattended. One slice at a time, each
slice closed by a review.

This skill is the execution loop. It does not plan or slice. A plan arrives
already sliced (one file per slice) in a topic directory. You consume it.

## Inputs

- Invocation: `orchestrate <topic-dir> [model=<id>]`.
- A topic directory with an optional overarching `plan.md` and numbered slice
  files matching `[0-9][0-9]-*.md` anywhere under it — flat `slice-NN-*.md`
  and nested `issues/NN-*.md` both work.
- Each slice names its files in scope, its goal, its context, its acceptance
  criteria, and a `Blocked by` field (the slices it depends on).

## Before you run

- Resolve the topic dir. The invocation path wins. Without one, use the sole
  directory under `.scratch/`; ask when there are several or none.
- Resolve the run model. The invocation `model=<id>` wins. Without one, list
  the models your tool reports as available and ask the user to pick — before
  the run starts, never mid-run. If the tool cannot enumerate models, ask for
  a name. Every sub-agent in the run uses this one model.
- Discover slices. Glob `[0-9][0-9]-*.md` recursively, sort by the `NN`
  prefix. That is your run order, constrained by `Blocked by`. Read `plan.md`
  when present; ignore every other file.

## Status print

Before each slice, print exactly this block. First print of a run: `— run
starting` in place of the last slice's details.

```
✅ last:  <slice> — <status> · <commit> · review: <n> issues · <n> fixed · <verdict>
📊 run:   <done>/<total> done · <n> skipped · <n> blocked
➡️ next:  <slice> — "<title>" · model: <run model>
```

Fixed shape, so a scrolling log reads at a glance.

## The loop (sequential, one slice at a time)

For each slice, in order:

1. **Status.** Print the block above.
2. **Refine.** Turn the slice into a self-contained worker spec: the files in
   scope, the goal, the context the worker needs, and the acceptance criteria
   it can self-check. Write it to a scratch file. Record the current HEAD —
   it is the review's fixed point.
3. **Dispatch worker.** Spawn the `worker` subagent with the run model. Tell
   it to read its spec from the scratch file.
4. **Triage.** `done` or `partial`: commit the implementation (see Git), then
   review — `partial` gets reviewed like `done`; the reviewer decides whether
   the partial state is acceptable. `blocked`: re-refine the spec using what
   the failure revealed, retry once; if it blocks again, decide skip vs. stop
   (see Blocked).
5. **Review.** Write the reviewer spec: the slice's acceptance criteria, the
   diff and commit list from the recorded HEAD to now, and the trust command
   (the full test suite, or whatever builds trust in this repo — may be
   none). Spawn the `reviewer` subagent with the run model.
6. **Verdict.** `approve`: next slice. `issues`: write a fix spec from the
   findings, dispatch the worker again, re-review **once**. Still issues: the
   slice is blocked — the Blocked rules decide. Commit fixes (`fix:`) only
   when something changed.
7. **Close the run.** After the last slice, run the trust command once more
   across everything (per-slice green does not prove cross-slice green), then
   write the final summary: per slice — status, commit, review verdict,
   issues found and fixed; plus run-wide totals.

Never pause mid-run for human input. The plan was reviewed before you started.
That is the whole point: launch it, then leave.

## Git

You own all version control. Commit the implementation after each successful
slice, before review starts — finished work survives a crash, and the reviewer
gets a clean fixed point. Commit fixes after a re-approve. Rollback is
granular: revert one slice's commits. Sub-agents never run git.

## Blocked

A worker that cannot finish stops and reports `blocked`. It does not revert.
It does not half-finish. A slice whose review still reports issues after one
fix round is blocked the same way. In both cases:

- **Skip** when no remaining slice lists this one in its `Blocked by`. Roll
  back its files, mark it skipped, continue.
- **Stop** when any unrun slice depends on it. Halt the run and report.

## Lane discipline

The worker touches only what its slice names. It may make a one-hop fix to keep
a file valid, marked in code as `# spill: <reason>`. Anything beyond one hop is
a note, not a change. After each slice, grep for `# spill:` to review
out-of-lane changes.

## Conventions

- Topic dir: `.scratch/<topic>/` in the repo running the plan — gitignored.
  Any explicit path works too.
- Worker scratch spec: `/tmp/orchestrator/<slice-slug>.md`.
- Reviewer scratch spec: `/tmp/orchestrator/<slice-slug>.review.md`.
- Sub-agents: `worker` implements, `reviewer` verifies. Both use the run model.
- Reviewer method: the code-review skill's two axes — spec (the slice's
  acceptance criteria) and standards (its smell baseline) — in one pass by one
  leaf agent, returning a verdict, not a report.
