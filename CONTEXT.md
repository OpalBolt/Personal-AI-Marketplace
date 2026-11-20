# Personal-AI-Marketplace

Skills and agents shared across AI tools via `link.sh`. This glossary fixes the
language of the orchestrator pattern so skills, agent prompts, and docs use one
word per concept.

## Language

**Model roles**:
The three model slots a run resolves once, before it starts: **work**
(implements slices), **fallback** (the net), **review** (verdicts). One
startup question picks a preset; the catalog names all three. Never
resolved mid-run.
_Avoid_: model map, model mapping

**Orchestrator**:
The primary agent that runs a topic's slices — up to the worker cap in
flight — unattended. Owns git, commits, triage, and the status prints. Never
implements or reviews itself.
_Avoid_: runner, agent-in-charge

**Topic dir**:
A directory (under `.scratch/`, gitignored) holding one effort's slice files
and an optional `plan.md`. The orchestrator's input path. A fully approved
run renames it to `<topic>-DONE`; discovery ignores those.
_Avoid_: plan dir, AI_PLAN_DIR, plans dir

**Slice**:
One numbered file in a topic dir naming its files in scope, goal, context,
acceptance criteria, and `Blocked by` (the slices it depends on).

**Worker**:
Leaf subagent that implements exactly one slice or one fix spec. Touches only
its lane, never runs git, never runs the full test suite.
_Avoid_: fixer (a fix is the worker re-dispatched with a fix spec)

**Reviewer**:
Leaf subagent that reviews one slice's diff and confirms the tests. Never edits
files; findings go back to the worker as a fix spec.
_Avoid_: code-review sub-agent

**Verdict**:
The reviewer's closed-set reply: `approve` or `issues` (each with file, what,
suggested fix, severity `must-fix` or `nit`).
_Avoid_: review report, findings list

**Canary**:
The check the orchestrator runs after every child dispatch, comparing the
child's telemetry against the trip signals.
_Avoid_: health check, gate

**Lane**:
The set of files a slice names as in scope. Two slices whose lanes intersect
never run at the same time — the scheduler serializes them.
_Avoid_: file scope, ownership

**Ready set**:
The slices whose `Blocked by` are all done and whose lanes are disjoint from
every in-flight slice. What the scheduler dispatches from.
_Avoid_: available slices, unlocked slices

**In flight**:
Dispatched but not yet merged and approved. A slice's worktree lives exactly
this long.
_Avoid_: running, active slice

**Worktree**:
A linked git worktree at `.scratch/worktrees/<topic>-<run-id>/<slice-slug>`,
branched at dispatch. The run-id keeps repeated topic names from colliding.
One slice's isolation: its own HEAD, index, and tree for trust runs. Removed
when the slice closes.
_Avoid_: branch, checkout, clone

**Merge-back**:
The orchestrator moving a worktree's slice commit into the main checkout —
fast-forward when main never moved, a merge commit when slices interleaved.
The orchestrator runs all git; workers still never do.
_Avoid_: combining, integrating

**Trip**:
A canary signal firing on a child.
_Avoid_: failure, alert

**Budget**:
The soft call limits written into a worker spec — first edit within 20
calls, stop and report blocked at 40. The worker reads them; nothing
enforces them.
_Avoid_: limit, cap (that is Hard caps)

**Hard caps**:
The wall-clock and turn limits the orchestrator sets on every child
dispatch. The harness enforces them; hitting one ends the child as blocked.
_Avoid_: timeout, budget

**Fallback**:
The run's safety net. A tripped role switches to it, one-way, for the rest
of the run — whichever role tripped. When all roles share one model there
is no net: one retry on the same model, then the run stops.
_Avoid_: relief model, backup model

**Catalog**:
A `models.json` file in the orchestrator skill's harness dir (`pi/`,
`claude/`, …), one per harness, holding named presets — each naming the
three model roles, ids optionally suffixed `:thinking`. Read at startup
to build the model question.
_Avoid_: model list, model map

**Light tier**:
Terminal presentation for a running app, in the `tui-design` skill. Output
only. Input is a one-shot prompt. Partial redraw is the default, and
full-screen redraw is gated. The default tier.
_Avoid_: simple mode, basic CLI

**Full tier**:
A key-driven terminal app, in the `tui-design` skill, with views, focus,
and state that outlives a key press. Used only when asked for, or when the
task needs all three.
_Avoid_: rich TUI, interactive mode
