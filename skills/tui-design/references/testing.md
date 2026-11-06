# TUI testing

Test the state and the rendered result without a terminal. Keep the domain, state transitions, layout math, and rendering deterministic. Check the project's `pyproject.toml` or `go.mod` before choosing APIs.

This reference targets Rich 14.x and Textual 8.x for Python. It targets Bubble Tea v1, Bubbles v1, and Lip Gloss v1 for Go. Keep the major version selected by the project. Read [rich-python.md](rich-python.md), [textual-python.md](textual-python.md), and [bubbletea-go.md](bubbletea-go.md) for framework rules.

## Test layers

Use all applicable layers for either tier and either language:

- **Unit:** Test state transitions, action mapping, layout math, wrapping, truncation, display width, and error mapping as pure functions.
- **Snapshot:** Render fixed state at fixed dimensions and compare captured output or a golden file. Inject time, randomness, network results, and other changing inputs.
- **Interaction:** Feed a short sequence of input events and assert the resulting state and visible output.

Run Python tests with `pytest`. Run Go tests with `go test ./...`. Both commands run headless. Keep any real-PTY check separate from the normal test suite.

## Light tests

Light output has two gates. Test the plain gate and the interactive gate separately. The plain gate applies when output is piped, redirected to a file, running in CI, `TERM=dumb`, or `NO_COLOR` is set. The interactive gate requires the input and output streams to be TTYs and excludes CI.

### Unit

Test the policy that chooses plain or interactive output for each stream. Cover stdout and stderr independently. Check that plain output has no color, animation, redraw controls, or blocking prompt. Check that an interactive stream can use styling or redraw only when its gate passes.

Inject terminal width and test a standard 80-column layout and a narrow layout. Test truncation and wrapping by display width. Include values with wide characters, combining marks, and emoji when the tool aligns text.

Test prompt policy with a supplied flag, environment value, safe default, and missing value. A non-interactive required prompt must write a clear error to stderr and return a nonzero result. It must not replace a missing value with an empty string.

### Captured output

For Python, use pytest's `capsys` fixture to capture stdout and stderr. For Rich output, pass `record=True` and a `file` such as an in-memory text stream to `Console`. Assert the captured text, stream choice, status symbol and word, and exit result. Use Rich's recorded output only when it represents the stream under test.

For Go, render into a `bytes.Buffer` or another injected writer. Assert stdout and stderr separately. Keep the writer independent from TTY detection so the test can exercise both policy branches without changing the test process's own terminal.

### Snapshot

Capture a complete plain result for a piped run. Capture a styled or bordered result separately for an interactive run when that display is part of the contract. Inspect piped and file output for escape bytes. Set `NO_COLOR`, `TERM=dumb`, and CI conditions one at a time and together where they can interact.

Use a fixed width for every snapshot. Include 80 columns and at least one narrow width. Use a fixed input length for progress so totals come from real input rather than a hard-coded display value. Keep the final result outside a live or redraw context in the captured output.

### Interaction

Use Light interaction tests only for one-shot input, prompt acceptance or decline, safe defaults, and any explicitly allowed redraw without a key loop. Test a TTY path and a non-TTY path. Confirm that a pipe or CI path finishes without waiting for input.

## Full tests

Full apps must test state changes without starting the terminal program. Keep file, network, database, and subprocess work behind commands or workers that tests can replace with deterministic results. Read [textual-python.md](textual-python.md) and [bubbletea-go.md](bubbletea-go.md) before writing framework tests.

### Unit

Test the model or state owner with initial, empty, loading, success, warning, error, and narrow-size states that the app can reach. Test selection, focus, scroll, filters, pagination, resize handling, quit, and safe cancellation. Test bounds for rows, cells, pasted text, queued events, and log buffers.

Test that render code reads state only. It must not perform blocking I/O, wait, mutate state, or depend on the current terminal.

### Snapshot

For Python, use Textual's `App.run_test()` context to create a headless app and capture the widget or screen state at a fixed size. Keep snapshots stable by fixing time, data, and network results. Use the project's snapshot tooling when it already has one.

For Go, render the model's `View()` at a fixed size and compare the result with a checked-in golden file. Decide whether the golden keeps style sequences or removes them for a layout-only assertion. Keep that choice consistent. Update a golden only after reviewing the intended layout change.

### Interaction

For Python, use `App.run_test()` and its Pilot. Drive keys with `Pilot.press`, then assert the active screen, focused widget, state, or rendered content. Cover the initial view, a navigation or action path, a modal confirm and cancel path, quit, error recovery, and resize.

For Go, feed `tea.KeyMsg` and `tea.WindowSizeMsg` values into the model's `Update` method. Assert the returned model and command, then inspect `View()` after a scripted sequence. Cover navigation, quit, modal confirm and cancel, errors, resize, and a bounded paste event.

## Shared checks

Run the full suite with `pytest` or `go test ./...` in CI without a TTY. Keep tests deterministic. Do not use a real clock, network, terminal size, or random source when the result is part of a snapshot.

Check the same meaning in enhanced and plain output. A TTY may add color, borders, and redraw. A pipe or file must retain the result as ordinary lines. Read [terminal.md](terminal.md), [unicode-and-text.md](unicode-and-text.md), and [review-checklist.md](review-checklist.md) for the output contract and final review.
