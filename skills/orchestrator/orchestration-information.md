# Orchestrator

Run a sliced plan to completion, unattended. One slice at a time.

## What it does

The orchestrator takes a plan that is already sliced into files and runs it end
to end. It does not plan or slice. Pair it with `jam-with-me`, which writes the
overarching plan, and `to-tickets`, which slices it.

For each slice, the orchestrator:

1. Refines the slice into a worker spec.
2. Spawns a leaf worker with the matched model.
3. Validates and commits the result.
4. Moves to the next slice.

It commits after every slice, so finished work survives a crash. It never stops
to ask a question mid-run.

## Workflow

1. Run `jam-with-me`. It writes `plan.md` to the plan directory.
2. Run `to-tickets`. It writes one `slice-NN-slug.md` file per slice.
3. Invoke the orchestrator. It runs every slice to completion and writes a
   summary.

## Where files live

Plans live outside your repo so they never pollute it.

| Path | Holds |
|---|---|
| `~/.local/share/ai-plans/<repo-slug>/` | `plan.md` and the `slice-NN-*.md` files |
| `/tmp/orchestrator/<slice-slug>.md` | the worker spec for the current slice |

`repo-slug` is the basename of the repo root.

## Initialize

Run the init script from inside the repo. It creates the plan directory,
writes its path to `./.env` as `AI_PLAN_DIR`, and prints it.

```sh
skills/orchestrator/init.sh
```

Skills read `AI_PLAN_DIR` from `.env` instead of re-deriving the path, so
`jam-with-me`, `to-tickets`, and the orchestrator all agree on one location.

## Models

The worker runs a cheaper model than the orchestrator. The pairing is data, not
a guess.

`models.json` maps each orchestrator model to the worker model, grouped by
tool. When the model or the tool is not listed, the worker inherits the
orchestrator model.

```json
{
  "default": { "worker": "inherited" },
  "opencode": {
    "zai-coding-plan/glm-5.2": { "worker": "glm-4.7" },
    "deepseek-pro": { "worker": "deepseek-lite" }
  }
}
```

Edit the model IDs to match what each tool reports. Add a role key, such as
`reviewer`, to extend the scheme without changing the shape.

## Failure policy

A slice that cannot finish reports `blocked`. The orchestrator retries it once
with a refined spec. If it blocks again:

- **Skip** when no later slice depends on it.
- **Stop** when a later slice needs it.

Each slice declares what it is blocked by, so the orchestrator can tell.
