# TUI review checklist

Review the result at the end of the task. Mark each item pass, fail, or not applicable. The tag shows which tier owns the check.

Read [SKILL.md](../SKILL.md) for the shared contract. Read [LIGHT.md](../LIGHT.md) or [FULL.md](../FULL.md) for tier rules. Use [design.md](design.md), [terminal.md](terminal.md), [unicode-and-text.md](unicode-and-text.md), [states.md](states.md), and [robustness.md](robustness.md) as the detailed sources.

## Choice and restraint

- **[Both]** The chosen tier matches the user's request and the interaction need.
- **[Both]** The layout gives the important content the strongest visual hierarchy.
- **[Both]** Spacing and alignment stay consistent at the tested sizes.
- **[Both]** Borders group related content instead of decorating every element.
- **[Both]** The design uses no more than four colors for semantic meaning.
- **[Both]** Every status has a symbol and a word. Color never carries status alone.
- **[Both]** The plain path keeps the same meaning when color, borders, and redraw disappear.

## Terminal contract

- **[Both]** Piped, redirected, CI, `TERM=dumb`, and `NO_COLOR` output has no escape codes or animation.
- **[Both]** Data and normal status go to stdout. Diagnostics and errors go to stderr.
- **[Both]** Failure paths return useful nonzero results and name a recovery action.
- **[Both]** Layout uses display width for padding, wrapping, and truncation.
- **[Both]** Output is readable at 80x24 and at a narrow width.
- **[Both]** Review includes enhanced and no-color output.
- **[Both]** The process restores terminal state on normal exit, errors, signals, and crash paths that the framework does not cover.
- **[Both]** Every pointer in the router and tier docs resolves to an existing reference.

## Light behavior

- **[Light]** Scrollback remains useful after the command exits.
- **[Light]** Each live or changing operation names its work and leaves a final result line.
- **[Light]** A progress total comes from the real input length.
- **[Light]** A live result line appears after the live context closes.
- **[Light]** A non-interactive prompt takes a flag, environment value, or safe default. It fails to stderr instead of waiting when no safe value exists.
- **[Light]** Plain output has no redraw controls, animation, or blocking prompt.
- **[Light]** Full-screen redraw meets every gate in [LIGHT.md](../LIGHT.md) and has an explicit reason.
- **[Light]** Empty, loading, progress, success, warning, error, and prompt states have a useful line when they apply.

## Full behavior

- **[Full]** The render path and event handlers contain no blocking I/O.
- **[Full]** One state owner controls shared data, focus, selection, scroll, and input state.
- **[Full]** Every view has a visible escape route. `Ctrl+C` remains a global escape.
- **[Full]** `q` does not quit while a text input owns focus.
- **[Full]** Focus is visible, predictable, and restored after returning to a view.
- **[Full]** Loading, success, timeout, and error states keep useful context and offer retry, dismiss, or back actions.
- **[Full]** Resize and minimum-size behavior are explicit. Narrow layouts collapse, truncate, or show a clear message.
- **[Full]** Requests, events, pasted text, displayed cells, and log lines have bounds.
- **[Full]** Stale work cannot overwrite a newer view or request.
- **[Full]** Persistent context writes atomically and invalid data falls back safely.
- **[Full]** Repeated navigation, refresh, search, and stream events stay responsive and do not force one render per event.

## Tests

- **[Both]** Unit tests cover state transitions, layout math, display width, and error mapping without a terminal.
- **[Both]** Snapshot or golden tests use fixed dimensions and deterministic input.
- **[Both]** Interaction tests cover the reachable key or prompt paths for the chosen tier.
- **[Light]** Captured output tests cover stdout, stderr, piped output, TTY policy, `NO_COLOR`, and narrow width.
- **[Full]** Headless tests cover the initial view, navigation or action, quit, error recovery, resize, and bounded input.
- **[Both]** The test command runs without a TTY and checks the same meaning in plain and enhanced modes.
