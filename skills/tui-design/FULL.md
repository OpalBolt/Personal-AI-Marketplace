# Full Tier

Full builds a key-driven terminal UI. Use it when the user asks for a full TUI, or when all three conditions apply:

- The user moves between views or panes.
- The user acts on displayed data by selecting, filtering, editing, or scrolling.
- State must survive a key press.

Light is the default. If a Light design needs a key loop, name the missing capability and ask before you escalate. Apply the escalation question rule in [SKILL.md](SKILL.md).

## Steps

1. Write a plain screen transcript. Cover the initial, empty, loading, success, error, and narrow-screen states that apply.
2. Separate domain work from UI state and rendering. Choose screens, widgets, focus order, and navigation before styling.
3. Check `pyproject.toml` and the lock file before choosing Textual APIs. This guide targets Textual 8.x. Keep the project's major version.
4. Load [interaction.md](references/interaction.md) for keys, focus, navigation, and component choices.
5. Load [robustness.md](references/robustness.md) for async work, errors, terminal restore, resize, persistence, flood control, and paste limits.
6. Load [textual-python.md](references/textual-python.md) for Textual structure, styling, state, and tests in Python projects.
7. Load [bubbletea-go.md](references/bubbletea-go.md) for Bubble Tea, Bubbles, and Go model tests in Go projects.
8. When stdout or stdin is not a TTY, print a plain result path, or fail with a clear stderr message and nonzero exit if no result can be produced. Never start the TUI.
9. Test state changes without a terminal. Add a headless Pilot test that presses keys and asserts screen state for Python, or a headless Bubble Tea model test that feeds key messages into `Update` for Go.
10. Test at 80x24 and a narrow size. Exercise quit, errors, resize, large paste, and repeated navigation.

## Tier rules

- Keep the render path free of blocking I/O. Put file, network, and database work in async workers or a thread worker for synchronous APIs.
- Keep one source of truth for application state. Keep focus, cursor, scroll, and input state close to the component that owns them.
- Give every view an escape route. Keep `Ctrl+C` as a global escape. Make `q` context-sensitive and do not trigger it while a text input has focus.
- Show the focused element clearly. Keep focus order predictable and restore focus when a user returns.
- Pair status with a symbol and a word. Keep meaning clear without color.
- Keep terminal restoration on normal exit, errors, signals, and crashes.
- Treat a failed operation as a visible state with a recovery action. Keep the user's position and filters when possible.
- Make resize and minimum-size behavior explicit. Collapse, truncate, or show a clear message instead of breaking the frame.
- Bound input, pasted text, queued events, and displayed cells. Tell the user when the app drops or truncates data.
- Persist user context atomically when the app needs state across runs.

## Completion gate

The Full plan is complete when the transcript, fallback, key flow, error states, and headless test agree. Every pointer above must resolve before the task ends.
