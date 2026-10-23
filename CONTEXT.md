# Personal-AI-Marketplace

Skills and agents shared across AI tools via `link.sh`. This glossary fixes the
language of the orchestrator pattern so skills, agent prompts, and docs use one
word per concept.

## Language

**Run model**:
The single model every sub-agent in a run uses — worker and reviewer alike.
Named in the invocation, or chosen from the tool's available models before the
run starts. Never chosen mid-run.
_Avoid_: worker model, reviewer model, model mapping

**Orchestrator**:
The primary agent that runs a topic's slices sequentially, unattended. Owns
git, commits, triage, and the status prints. Never implements or reviews
itself.
_Avoid_: runner, agent-in-charge

**Topic dir**:
A directory (under `.scratch/`, gitignored) holding one effort's slice files
and an optional `plan.md`. The orchestrator's input path.
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
