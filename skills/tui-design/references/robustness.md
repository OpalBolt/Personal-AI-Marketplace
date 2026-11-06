# Robustness

This reference targets Textual 8.x and the Go TUI library major versions declared in `go.mod`. Check `pyproject.toml` or `go.mod` first. Apply the rules in a framework-neutral way, then use each framework's exit and worker APIs.

## Async safety

Keep file, network, database, and subprocess work out of rendering and event handling. Run it in an async task or a thread worker for blocking APIs.

Allow one request per resource at a time. Cancel work when its view closes. Tag requests with a generation or identity and discard stale results. Give every request a timeout and render loading, success, timeout, and failure states.

Debounce remote search. Filter locally before starting a request. Bound event and stream queues. Count dropped events and show the count. Keep the event loop responsive during a flood of keys.

## Errors and exit

Treat missing files, failed connections, invalid queries, and timeouts as visible states. Keep the last usable data and the user's position when possible. Give each error a retry, dismiss, or back action.

Rely on framework-managed cleanup to restore the terminal, as Textual does in its app lifecycle. Add signal handling and a final terminal-state verification only where the framework does not cover them. Fail before fullscreen when required startup resources are missing.

Keep `Ctrl+C` as the global escape. Make `q` context-sensitive and do not trigger it while a text input has focus. Make a second `Ctrl+C` an immediate escape when the first is handled by a modal or pending save.

## Resize and rendering

Define a minimum width and height for each view. Show a short resize message below that size. Recompute column widths, page sizes, and pane splits from the current dimensions on every resize.

Render only the visible rows. Build one frame and flush it once. Debounce expensive layout during a resize drag. Keep inline output to a fixed number of lines.

## Persistence

Persist only the user context the app needs, such as the last view, cursor, sort, filter, theme, or history. Save on significant transitions and exit, not only on a clean exit.

Write to a temporary file and atomically rename it. Validate loaded state and fall back to defaults when it is corrupt. Tell the user when context was restored and provide a clear action to remove it.

## Flood and paste limits

Make repeated navigation a bounded operation. Clamp selection and scroll positions. Coalesce redraws instead of forcing one render per key.

Strip newlines from single-line paste. Cap pasted input and show the limit. Pasted text must remain data, not trigger action keys. Truncate giant cells and log lines before layout. Preserve a visible marker when data is truncated.

Render empty, missing, and null values differently when the data source distinguishes them. Keep malformed rows visible with a placeholder and a count.

## Verification

Exercise resize from a wide screen to a narrow screen and back. Run with `TERM=dumb` and without color. Kill a dependency during a request. Hold a navigation key. Paste a large value. Interrupt a modal. Interrupt a state write. Confirm the UI stays usable and state remains valid.
