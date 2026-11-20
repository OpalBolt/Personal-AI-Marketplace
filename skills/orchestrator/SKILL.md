---
name: orchestrator
description: Run a pre-sliced plan to completion, unattended. Hand it a .scratch topic directory of to-tickets slices; for each slice it dispatches a leaf worker under hard caps and commits, then a dedicated leaf reviewer judges the diff against the slice's acceptance criteria and standards, citing the trust-command output. A canary checks every child's telemetry; a tripped role switches to the fallback model, and the run never stops to ask. Findings loop through the worker once, then the slice retries or skips. Use when the user says "orchestrate", "run the plan", "execute the slices", "run this overnight", or wants a sliced plan run autonomously end-to-end. Does not plan or slice; it only executes.
disable-model-invocation: true
---

# Orchestrator

Run a pre-sliced plan to completion, unattended. A scheduler keeps up to
two slices In flight at a time, each in its own Worktree, each closed by a
review. Every child runs under hard caps and lands in a canary check; a
tripped role switches to the fallback model, one-way.

This skill is the scheduler. It does not plan or slice. A plan arrives
already sliced (one file per slice) in a topic directory. You consume it.

## Inputs

- Invocation: `orchestrate <topic-dir>`. The models come from one startup
  question.
- A topic directory with an optional overarching `plan.md` and numbered slice
  files matching `[0-9][0-9]-*.md` anywhere under it.
- Each slice names its files in scope (its Lane), its goal, its context, its
  acceptance criteria, and a `Blocked by` field (the slices it depends on).

## Before you run

- Resolve the topic dir. The invocation path wins. Without one, use the sole
  directory under `.scratch/` that does not end in `-DONE`; ask when there
  are several or none.
- Resolve the three model roles — **work** (implements), **fallback** (the
  net), **review** (verdicts) — once, before the run, never mid-run:
  - Ask **one** structured question: "Which setup for this run?" Its
    options are the presets in your harness's `models.json` catalog (in the
    harness dir next to this skill) — each names all three roles, and ids
    may carry a `:thinking` suffix. Free text welcome: a typed `provider/id` fills all three roles
    — no distinct net; say so. No catalog → the models your tool reports
    → failing that, ask for a name.
  - Never resolve a role to your own model.
  - Record all three in full form and reuse them throughout; do not
    re-derive mid-run.
- Print the startup block with the resolved roles. When fallback equals work,
  say so plainly: `fallback: =work (a trip retries once on the same model,
  then stops)`.
- Discover slices. Glob `[0-9][0-9]-*.md` recursively, sort by the `NN`
  prefix. That is your dispatch order, constrained by `Blocked by` and the
  Lane gate. Read `plan.md` when present; ignore every other file.
- Prune worktrees. `worktree.sh prune <repo> <topic-slug>` drops the topic's
  emptied run-id dirs, so a crashed run cannot poison this one.

## Status print

Before each dispatch, print exactly this block: four fixed lines, then one
`🔍 child:` line per slice In flight. First print of a run: `— run starting`
in place of the last-slice line, and no child lines yet.

```
✅ last:  <slice> — <status> · <commit> · review: <n> issues · <n> fixed · <verdict>
📊 run:   <done>/<total> done · <n> skipped · <n> blocked · trips: <n>
➡️ next:  <slice> — "<title>" · work: <model> · review: <model>
🔍 child: <slice> · <n> calls · first edit #<n or —> · <n> repeats · git: <yes|no>
```

Fixed shape, so a scrolling log reads at a glance.

## The scheduler

While slices remain: dispatch from the Ready set up to the cap, and take
each landing — worker returns, Merge-back, review — as it comes. When the
cap is full or nothing is Ready, wait for a landing.

- **Ready set**: slices whose `Blocked by` are all done AND whose Lane is
  disjoint from every slice In flight. Empty `Blocked by` alone never
  qualifies; the Lane gate beats a plan's "(parallel)" hints. A slice that
  names no files has an unknown Lane: it intersects everything, so it runs
  alone — it serializes, and it never blocks others.
- **Cap: two workers In flight.** Fix rounds and resolve rounds occupy a
  worker slot; reviewers are exempt. One review at a time.
- **Uniform Worktrees**: every slice runs in one — even when it is the only
  slice In flight. No main-checkout worker path, no mode flag.
- A harness that cannot dispatch into a Worktree (its HARNESS.md says so)
  degrades to cap 1: the same loop, sequential. The uniform-worktree rule
  still holds wherever the harness can dispatch into one.

For each slice, in dispatch order:

1. **Status.** Print the block above.
2. **Refine.** Read the slice *and the files it names* — the notes come from
   the code, not the slice text. Write the implementation notes: exact files
   to touch, existing seams and helpers to reuse, decisions made in advance,
   known red herrings (including stale `# spill:` markers). Render the
   worker spec with `mkspec.sh` (next to this skill); its notes and Budget
   sections are the point, not garnish.
3. **Dispatch worker.** `worktree.sh new <repo> <topic-slug> <slice-slug>`
   prints the Worktree path; pass it as the dispatch's `worktree_path`.
   Work model, hard caps on wall clock and — where the harness supports
   it — on browse-type tool calls. The child reads its spec by absolute
   path from `<topic>/orch/` in the main checkout: the Worktree has no
   `.scratch` content.
4. **Canary.** Check the child's telemetry (below) from the Worktree, and
   act on a trip at once.
5. **Triage.** `done` or `partial`: commit in the Worktree via
   `commit.sh <worktree> "<msg>"`, then Merge-back — record main's HEAD
   right before `worktree.sh merge <repo> <worktree>` as the evidence
   fixed point — then, still in the same turn and in main, build the
   evidence via `evidence.sh`: the fixed point is exact because Merge-back
   and evidence build happen in one synchronous orchestrator turn. Then
   review — `partial` gets reviewed like `done`; the reviewer decides
   whether the partial state is acceptable. `merge` printing `conflict`:
   main stays clean; `worktree.sh resolve <repo> <worktree>` lands the
   markers in the Worktree; dispatch the worker there with a resolve spec
   (a fix-spec variant: the markers are in its files, it edits, it never
   runs git), finish with `commit.sh <worktree>`, retry the merge once —
   still conflicting, the slice is blocked (see Blocked). `blocked`:
   re-refine the spec using what the failure revealed, retry once; if it
   blocks again, skip or stop (see Blocked).
6. **Review.** One review at a time, in main, on the merged tree — canary
   attribution stays unambiguous. Reviewer on the review model, its spec
   rendered by `mkreview.sh`, the evidence file as required reading. Canary
   the reviewer like a worker, from main. The reviewer is read-only and
   judges two axes in one pass: every acceptance criterion met (spec), and
   bugs, needless code, missing tests, out-of-lane changes (standards). It
   confirms tests from the evidence file's trust-command output, never by
   running them. `approve`: `worktree.sh clean <repo> <worktree>`, next
   dispatch. `issues`: fix spec, worker again into the same Worktree,
   commit, Merge-back, rebuild the evidence, re-review **once**. Still
   issues: the slice is blocked.
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
`git diff --stat`. Count call-log facts — repeats, first-edit call,
forbidden commands, evidence-not-read — by running the canary script named
in the harness file, and take its output as the whole picture. Canary a
worker from its Worktree, a reviewer from main — telemetry is keyed by the
child's cwd, so concurrent workers' canaries never cross.

A child **trips** on any of:

- Tier A, any harness: zero file edits at end while not reporting blocked ·
  hard cap hit.
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

You own all version control — a Worktree is still your git; workers never
run it, and the canary watches, so the rule is a trip signal, not just a
request. Each slice commits in its Worktree and merges back into main
before review — finished work survives a crash, and the reviewer judges
the merged tree. Fixes land the same way: Worktree, commit, Merge-back.
Rollback is granular: revert one slice's commits.

## Blocked

A worker that cannot finish stops and reports `blocked`. It does not revert.
It does not half-finish. A slice whose review still reports issues after one
fix round is blocked the same way, and so is a Merge-back that still
conflicts after its one resolve round. In each case:

- **Skip** when no remaining slice lists this one in its `Blocked by`. Roll
  back its files, mark it skipped, continue.
- **Stop** when any unrun slice depends on it. Halt the run and report.

## Lane discipline

The worker touches only what its slice names — its Lane. It may make a
one-hop fix to keep a file valid, marked in code as `# spill: <reason>`.
Anything beyond one hop is a note, not a change. After each slice, grep for
`# spill:` outside `.scratch` — Worktree copies hold the same markers — and
close-out reports what is left.

## Conventions

- Run scratch: `<topic-dir>/orch/` — worker specs `<slug>.worker.md`,
  reviewer specs `<slug>.review.md`, evidence `<slug>.evidence.md`, final
  trust `final-trust.log`. Slugs drop the `NN-` prefix, so scratch never
  collides with slice discovery, and per-topic placement keeps concurrent
  orchestrators on the machine apart.
- Worktrees live at
  `.scratch/worktrees/<topic>-<run-id>/<slice-slug>` — under `.scratch`, so
  existing grants and ignore rules cover them; the run-id keeps concurrent
  runs of one topic apart.
- Scripts live next to this skill: `mkspec.sh`, `mkreview.sh`,
  `evidence.sh`, `commit.sh`, `worktree.sh` (each takes the repo — or, for
  `commit.sh`, the Worktree — as its first arg, from any cwd). The
  harness dir `<harness>/` (e.g. `pi/`) holds its `HARNESS.md`, `models.json`
  catalog, and harness scripts such as the canary. The trust command comes
  from `plan.md` or the repo's own test setup; export it as `TRUST_CMD` when
  you call the scripts. Run them; do not restate them.
- `<harness>/models.json` catalogs: one per harness, curated by the user;
  each preset names the three model roles. Read at startup to build the
  model question.
- Harness specifics — dispatch-with-model, caps, telemetry source, the
  question tool: in `<harness>/HARNESS.md`. Read only the one for the
  harness you run in; the rest are not yours.
