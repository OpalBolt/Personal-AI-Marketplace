---
name: orchestrator
description: Run a pre-sliced plan to completion, unattended. Hand it a .scratch topic directory (produced by jam-with-me and to-tickets); it refines each slice into a worker spec, dispatches a leaf worker under hard caps, commits, then a leaf reviewer verifies the diff and confirms the tests. A canary checks every child's telemetry; a tripped role switches to the fallback model, and the run never stops to ask. Findings loop through the worker once, then the slice retries or skips. Use when the user says "orchestrate", "run the plan", "execute the slices", "run this overnight", or wants a sliced plan run autonomously end-to-end. Does not plan or slice; it only executes.
---

# Orchestrator

Run a pre-sliced plan to completion, unattended. One slice at a time, each
slice closed by a review. Every child runs under hard caps and lands in a
canary check; a tripped role switches to the fallback model, one-way.

This skill is the execution loop. It does not plan or slice. A plan arrives
already sliced (one file per slice) in a topic directory. You consume it.

## Inputs

- Invocation: `orchestrate <topic-dir>`. The models come from one startup
  question.
- A topic directory with an optional overarching `plan.md` and numbered slice
  files matching `[0-9][0-9]-*.md` anywhere under it.
- Each slice names its files in scope, its goal, its context, its acceptance
  criteria, and a `Blocked by` field (the slices it depends on).

## Before you run

- Resolve the topic dir. The invocation path wins. Without one, use the sole
  directory under `.scratch/` that does not end in `-DONE`; ask when there
  are several or none.
- Resolve the three model roles — **work** (implements), **fallback** (the
  net), **review** (verdicts) — once, before the run, never mid-run:
  - Ask **one** structured question: "Which model for this run?" Build its
    options from the `models-*.json` catalogs next to this skill (order is
    preference; free text welcome). No catalog → the models your tool
    reports → failing that, ask for a name.
  - The answer is the run model: it fills work and review. Fallback is the
    first catalog entry different from it — your second preference, no
    extra question. No catalog or no different entry → fallback is the run
    model; say so: no net.
  - Never resolve a role to your own model.
  - Record all three in full `provider/id` form and reuse them throughout;
    do not re-derive mid-run.
- Print the startup block with the resolved roles. When fallback equals work,
  say so plainly: `fallback: =work (a trip retries once on the same model,
  then stops)`.
- Discover slices. Glob `[0-9][0-9]-*.md` recursively, sort by the `NN`
  prefix. That is your run order, constrained by `Blocked by`. Read
  `plan.md` when present; ignore every other file.

## Status print

Before each slice, print exactly this block. First print of a run: `— run
starting` in place of the last-slice line, and no child line yet.

```
✅ last:  <slice> — <status> · <commit> · review: <n> issues · <n> fixed · <verdict>
📊 run:   <done>/<total> done · <n> skipped · <n> blocked · trips: <n>
➡️ next:  <slice> — "<title>" · work: <model> · review: <model>
🔍 child: <n> calls · first edit #<n or —> · <n> repeats · git: <yes|no>
```

Fixed shape, so a scrolling log reads at a glance.

## The loop (sequential, one slice at a time)

For each slice, in order:

1. **Status.** Print the block above.
2. **Refine.** Read the slice *and the files it names* — the notes come from
   the code, not the slice text. Write the implementation notes: exact files
   to touch, existing seams and helpers to reuse, decisions made in advance,
   known red herrings (including stale `# spill:` markers). Render the worker
   spec with `mkspec.sh` (next to this skill); its notes and Budget sections
   are the point, not garnish. Record the current HEAD — the review's fixed
   point.
3. **Dispatch worker.** Work model, hard caps on wall clock — and on turns
   where the harness supports it. The child reads its spec from the file.
4. **Canary.** Check the child's telemetry (below) and act on a trip at once.
5. **Triage.** `done` or `partial`: commit via `commit.sh`, build the
   evidence via `evidence.sh`, then review — `partial` gets reviewed like
   `done`; the reviewer decides whether the partial state is acceptable.
   `blocked`: re-refine the spec using what the failure revealed, retry once;
   if it blocks again, skip or stop (see Blocked).
6. **Review.** Reviewer on the review model, its spec rendered by
   `mkreview.sh`, the evidence file as required reading. Canary the reviewer
   like a worker. `approve`: next slice. `issues`: write a fix spec from the
   findings, dispatch the worker again, commit, rebuild the evidence,
   re-review **once**. Still issues: the slice is blocked.
7. **Close the run.** After the last slice, run the trust command once more
   across everything (per-slice green does not prove cross-slice green) into
   `<topic>/orch/final-trust.log`; the summary carries the exit code, and on
   failure a tail of that log. The summary: per slice — status, commit,
   review verdict, issues found and fixed; every trip and model switch, with
   what tripped; run-wide totals; leftover `# spill:` markers. Then execute
   any close-out steps `plan.md` names — the plan already authorized them.
   When every slice closed approved — none skipped, none blocked — rename
   the topic dir to `<topic>-DONE`; if the name is taken, note it in the
   summary instead.

Never pause mid-run for human input. The plan was reviewed before you
started. That is the whole point: launch it, then leave.

## Canary (after every child — workers, fix rounds, reviewers)

Telemetry is numbers only: a usage summary, the child's self-report, a
`git diff --stat`. Where a machine-readable call log exists, count its facts
with a one-line shell command — repeats, first-edit call, forbidden
commands, evidence-not-read — and keep only the number. Transcripts never
enter your context.

A child **trips** on any of:

- Tier A, any harness: zero file edits at end while not reporting blocked ·
  hard cap hit · reviewer approved in fewer than 10 calls.
- Tier B, only with a call log: 10+ identical repeated calls · first edit
  later than call 40 · a forbidden command (git) ran · reviewer never read
  the evidence file.

On a trip:

- The tripped role switches to the **fallback**, one-way, for the rest of
  the run. Print the switch. A cap trip also re-refines the spec; the retry
  runs on the fallback.
- A tripped reviewer: re-review this slice on the fallback; the review role
  switches.
- Fallback equals work (no distinct net): re-refine, retry once on the same
  model; a second trip stops the run.
- The fallback itself trips: the net is torn — stop the run and report.

## Git

You own all version control. Commit the implementation after each successful
slice, before review starts — finished work survives a crash, and the
reviewer gets a clean fixed point. Commit fixes after a re-approve. Rollback
is granular: revert one slice's commits. Sub-agents never run git — the canary
watches for it, so the rule is a trip signal, not just a request.

## Blocked

A worker that cannot finish stops and reports `blocked`. It does not revert.
It does not half-finish. A slice whose review still reports issues after one
fix round is blocked the same way. In both cases:

- **Skip** when no remaining slice lists this one in its `Blocked by`. Roll
  back its files, mark it skipped, continue.
- **Stop** when any unrun slice depends on it. Halt the run and report.

## Lane discipline

The worker touches only what its slice names. It may make a one-hop fix to
keep a file valid, marked in code as `# spill: <reason>`. Anything beyond
one hop is a note, not a change. After each slice, grep for `# spill:` —
close-out reports what is left.

## Conventions

- Run scratch: `<topic-dir>/orch/` — worker specs `<slug>.worker.md`,
  reviewer specs `<slug>.review.md`, evidence `<slug>.evidence.md`, final
  trust `final-trust.log`. Slugs drop the `NN-` prefix, so scratch never
  collides with slice discovery, and per-topic placement keeps concurrent
  orchestrators on the machine apart.
- Scripts and catalogs live next to this skill: `mkspec.sh`, `mkreview.sh`,
  `evidence.sh`, `commit.sh` (each takes `<repo> <topic-dir> …`). The trust
  command comes from `plan.md` or the repo's own test setup; export it as
  `TRUST_CMD` when you call the scripts. Run them; do not restate them.
- `models-*.json` catalogs: one per harness, curated by the user, read at
  startup to build the model question.
- Harness specifics — dispatch-with-model, caps, telemetry source, the
  question tool: in `HARNESS-<name>.md` files next to this skill. Read only
  the one for the harness you run in; the rest are not yours.
