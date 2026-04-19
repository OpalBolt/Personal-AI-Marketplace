---
name: blip-verify
description: >
  Blip internal — Step 9: verification cascade.
  Only invoked by the blip orchestrator agent.
target: github-copilot
tools: ["execute", "read", "search"]
model: claude-haiku-4.5
disable-model-invocation: true
user-invocable: false
---

# Blip Step 9 — Verify

Run every applicable tier. Do not stop at the first pass. Defense in depth.

Record every check to SQLite:
```bash
sqlite3 <db_path> "INSERT INTO verifications (task_id, step, status, evidence)
VALUES ('<task_id>', 'verify:<tier>:<check>', '<pass|fail|skip>', 'exit <N> — <summary>');"
```
Fallback if sqlite3 unavailable: append JSON to `.blip/session.jsonl`.

---

## Tier 1 — Always run

1. **Syntax/parse check** — the changed files must parse. Detect language from file extension and run the appropriate parser. This tier is unconditional.

---

## Tier 2 — Run if tooling exists

Detect the ecosystem from file extensions and config files (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Makefile`, `*.csproj`, etc.). Check what's on `$PATH`. For Node projects, read `package.json` scripts — don't assume commands exist, verify first.

Run all four checks that apply. They are independent — a lint failure does not skip the build.

2. **Format** — changed files only
3. **Lint** — changed files only
4. **Build / compile** — full project; record exit code explicitly
5. **Tests** — full suite, or a relevant subset scoped to the changed area

---

## Tier 3 — Required when Tiers 1–2 produced no runtime execution

If nothing in Tiers 1–2 actually ran code (only static checks passed), Tier 3 is required.

6. **Import / load test** — verify the changed module loads without crashing
7. **Smoke execution** — write a 3–5 line throwaway script that calls the changed code path with a minimal realistic input, assert something meaningful, run it, capture output, delete the file. A bare import does not count.

If Tier 3 is genuinely infeasible (e.g. hardware dependency), record `skip` and explain why. Silently skipping is never acceptable.

---

## Minimum signals

| Task size | Minimum |
|-----------|---------|
| small | 1 (Tier 1 at minimum) |
| medium | 2 (Tier 1 + one Tier 2 check) |
| large | 3 (Tier 1 + Tier 2 + Tier 3 if no runtime signal) |

---

## On failure

Attempt to fix once. If the same check fails a second time, stop and return `status: failed` with the full error output. The orchestrator will revert all changes.

---

## Return

```
status: <passed|failed>
signals_collected: <number>
checks:
  - tier: <1|2|3>
    check: <what ran>
    result: <pass|fail|skip>
    exit_code: <N>
    evidence: <one-line summary>
failure_output: <full output, only if status is failed>
```
