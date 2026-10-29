# Orchestrator

Run a sliced plan to completion, unattended. One slice at a time, each closed
by a review. This page is the human-facing explainer; the skill itself lives
in `skills/orchestrator/` and is what the agent reads.

## What it does

The orchestrator takes a topic dir that is already sliced into files and runs
it end to end. It does not plan or slice. For each slice, the orchestrator:

1. Prints a status block: last slice, run totals, next slice, last child's
   telemetry.
2. Refines the slice into a worker spec — implementation notes (exact files,
   existing helpers, decisions made in advance, red herrings) and a Budget
   (first edit within 20 calls, report blocked rather than loop) — then
   spawns a leaf worker under hard caps.
3. Commits the implementation.
4. Runs the trust command and the diff into an evidence file, then spawns a
   leaf reviewer whose spec names that file as required reading; the
   reviewer reads evidence, never runs.
5. Routes findings back to the worker as a fix spec, re-reviews once, commits
   the fixes.
6. Moves to the next slice — or skips or stops when a slice stays blocked.

After every child, a canary checks its telemetry. A tripped role switches to
the fallback model for the rest of the run — the run keeps going unattended.
It commits after every slice, so finished work survives a crash, and it never
stops to ask a question mid-run. A run where every slice closed approved
renames its topic dir to `<topic>-DONE`.

## Workflow

1. `jam-with-me` (optional) — writes `plan.md` into the topic dir.
2. `grilling` / `grill-with-docs` — stress-test the plan; settle the open
   decisions.
3. `to-spec` — synthesize the session into a spec.
4. `to-tickets` — slice it into one `NN-slug.md` file per slice.
5. `orchestrate .scratch/<topic>` — asks one question (which model for the
   run), then runs every slice to completion and writes a summary.

## Where files live

| Path | Holds |
|---|---|
| `.scratch/<topic>/` | `plan.md` and the `NN-*.md` slice files |
| `.scratch/<topic>-DONE/` | a finished run — discovery ignores these |
| `.scratch/<topic>/orch/` | the run's worker specs, reviewer specs, evidence files, `final-trust.log` |
| `skills/orchestrator/` | the skill, its scripts, catalogs, harness notes |
| `test/orchestrator/` | the fixture generator for repeatable testing |

Run scratch lives inside the topic dir, so two orchestrators on the same
machine never share files. Topic dirs default to `.scratch/<topic>/` in the
repo — gitignored, so they never pollute the history. An explicit path
anywhere else also works.

## Models

Three roles: **work** implements, **review** verdicts, **fallback** is the
net. At startup the orchestrator asks one question — "Which model for this
run?" — with options from the curated `models-*.json` catalogs next to the
skill (order is your preference, and you can always type your own). Your pick
fills work and review. The fallback is the first catalog entry different
from your pick: your own second preference, no extra question, visible in
the startup block. The orchestrator's own model is never used for a role.
Roles are resolved once, before the run; never mid-run.

## Brakes and the canary

Instructions alone did not stop a weak model from looping 366 tool calls
with zero edits, so the loop has brakes:

- **Hard caps** on every child: wall clock always, turns where the harness
  supports it. Hitting a cap ends the child as blocked.
- **A Budget in every worker spec**: first edit within 20 calls, no repeated
  lookups, report blocked rather than loop.
- **A canary after every child** — workers, fix rounds, reviewers alike.
  Trip signals: zero edits, a cap hit, 10+ identical repeated calls, first
  edit later than call 40, a forbidden git command, a reviewer approving in
  fewer than 10 calls or without reading the evidence. On a trip the role
  switches to the fallback, one-way. With no distinct fallback, one retry on
  the same model, then the run stops. If the fallback itself trips, the run
  stops.
- **Telemetry as numbers only**: usage summaries and shell-counted facts.
  Transcripts and diffs never enter the orchestrator's context; they stay in
  the evidence files on disk.

## Failure policy

A slice that cannot finish reports `blocked`. A slice whose review still
reports issues after one fix round is treated the same. The orchestrator
retries a blocked slice once with a refined spec. If it blocks again:

- **Skip** when no later slice depends on it.
- **Stop** when a later slice needs it.

Each slice declares what it is blocked by, so the orchestrator can tell.

## Testing it

`test/orchestrator/mkfixture.sh` builds a fresh throwaway git repo with a
sliced `.scratch/smoke` topic — see its header for the happy-path and
trip-path procedures.
