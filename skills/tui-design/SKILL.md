---
name: tui-design
description: Design, build, review, or fix terminal presentation in Python or Go. Use for CLI output, dashboards, log viewers, Rich or Textual apps, Lip Gloss or Bubble Tea apps, terminal fallbacks, Unicode width, or headless TUI tests.
disable-model-invocation: true
---

# TUI Design

Terminal work has two tiers. Pick a tier before writing code, then read its entry file.

| Tier | Use it for | Python | Go | Entry file |
|---|---|---|---|---|
| **Light** | Printed output and one-shot input. | Rich | Lip Gloss, huh | [LIGHT.md](LIGHT.md) |
| **Full** | Key-driven views, focus, editing, and lasting state. | Textual | Bubble Tea, Bubbles, Lip Gloss | [FULL.md](FULL.md) |

## Pick a tier

Use **Light** by default. It keeps output in scrollback and uses input only for one answer.

Choose **Full** only when the user asks for it, or when the task needs all three conditions:

- The user moves between views or panes.
- The user acts on displayed data by selecting, filtering, editing, or scrolling.
- State must survive a key press.

If a Light design needs a key loop, explain why and ask before changing tiers. Do not grow scope without that decision.

If the requested language is not Python or Go, state that this skill does not cover it and stop.

## Non-negotiables

Apply these rules to both tiers:

1. Start with a monochrome design. Use at most four colors when color carries meaning.
2. Pair each status with a symbol and a word. Use `✓ done`, `✗ failed`, or `! warning`.
3. Honor `NO_COLOR` and `TERM=dumb`. Treat a non-TTY stream as plain output.
4. Keep pipes, CI, and files free of escape codes, animation, and blocking prompts.
5. Send errors to stderr. Send data to stdout. Keep exit codes script-friendly.
6. Measure display width, not string length. Read [references/unicode-and-text.md](references/unicode-and-text.md) for layout work.
7. Restore terminal state on normal exit, errors, signals, and crashes.
8. Check output at 80 columns and at a narrow width. Check color and plain modes.

## Workflow

1. Identify the app, language, tier, output stream, and terminal limits. Ask only for details you cannot infer.
2. Read the selected tier file before choosing components or a library.
3. Load only the references named for the current work.
4. Write a plain-text transcript or screen mockup before code.
5. Build with the library already used by the project. Check its version first.
6. Keep domain work separate from rendering and terminal I/O.
7. Add a plain path for pipes, CI, files, `NO_COLOR`, and `TERM=dumb`.
8. Test state changes and rendered output without a TTY.
9. Review the result with [references/review-checklist.md](references/review-checklist.md).

A step is complete when its transcript, fallback, and relevant tests agree.

## Shared references

Load a reference when its topic appears in the task:

- [references/design.md](references/design.md) — hierarchy, spacing, color, borders, and layout.
- [references/states.md](references/states.md) — empty, loading, progress, success, and error output.
- [references/terminal.md](references/terminal.md) — terminal checks, fallbacks, prompts, and signals.
- [references/unicode-and-text.md](references/unicode-and-text.md) — display width, truncation, and padding.
- [references/testing.md](references/testing.md) — headless tests for both tiers.
- [references/review-checklist.md](references/review-checklist.md) — final review of output and behavior.

## Light routing

Choose Light when the user needs a command that prints a result, reports work, or asks one question.

Read [LIGHT.md](LIGHT.md) first. Then load only the references that match the work:

- Use `design.md` for hierarchy, spacing, borders, symbols, and color.
- Use `states.md` when the operation has loading, progress, empty, warning, or error paths.
- Use `terminal.md` when output can be piped, prompts can block, or redraw needs a TTY.
- Use `unicode-and-text.md` when output contains user text or aligned columns.
- Use `rich-python.md` for Python output.

The Light result is complete when the transcript names each reachable state, the plain path works, and the final result survives in scrollback.

## Full routing

Choose Full only after the user asks for it or the Light boundary blocks the task.

Read [FULL.md](FULL.md) before choosing views, focus, navigation, or persistent state. Load only the references named there for that task.

Keep domain logic independent of the render loop. Test state changes without a terminal. Restore terminal state on every exit path.

## Output contract

Every tier must preserve the same meaning across display modes:

- A TTY may add color, borders, tables, and redraw.
- A pipe or file prints lines that carry the result.
- `NO_COLOR` and `TERM=dumb` remove color and optional control sequences.
- A prompt has a safe flag, value, or default in automation.
- A failure has a useful message and a nonzero exit code.

A display change is not complete until both the enhanced and plain transcripts make sense.

## Review gate

Before calling the task done, check:

1. The chosen tier matches the user's request.
2. The transcript covers empty, loading, success, warning, error, and prompt states that apply.
3. Status remains clear without color.
4. Width-aware layout works at standard and narrow widths.
5. Piped output has no escape codes or animation.
6. Errors use stderr and exits stay script-friendly.
7. Tests cover the state and rendering paths that changed.

Record any condition that does not apply instead of adding unrelated UI.

## Tier boundaries

Light may redraw a live region or a bordered display when its gate in [LIGHT.md](LIGHT.md) passes.

Light does not own navigation, focus, multi-screen state, or a key loop. Those belong to Full.

Full must keep blocking work out of its render loop and restore the terminal on every exit path.

When a request crosses the boundary, name the missing Light capability and ask before using Full.
