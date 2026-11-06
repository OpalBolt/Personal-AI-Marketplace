# Bubble Tea for Go Full TUIs

This reference targets Bubble Tea v1, Bubbles v1, and Lip Gloss v1. Check `go.mod` first. Keep each Charm package on the major version that the module declares. The v1 packages use `github.com/charmbracelet/bubbletea`, `github.com/charmbracelet/bubbles`, and `github.com/charmbracelet/lipgloss`.

Bubble Tea v2 uses the `charm.land/bubbletea/v2`, `charm.land/bubbles/v2`, and `charm.land/lipgloss/v2` module paths. Check the v2 migration notes when `go.mod` selects those paths. V1 models return `string` from `View` and receive `tea.KeyMsg`. V2 models return `tea.View` and receive `tea.KeyPressMsg` or `tea.KeyReleaseMsg`. Also verify model interfaces, program options, and component APIs. Do not pass types or components across an incompatible v1 and v2 boundary. Use the versions already selected by the project instead of copying this reference's target.

## Model, update, and view

Keep the model as the single owner of UI state. Keep domain types and I/O in services outside the model. The model implements `Init`, `Update`, and `View` for the selected major version.

Use `Init` for initial commands. Let `Update` apply one message and return the next model plus a command. Keep `Update` short and deterministic. Let `View` format current state only. It must not read files, call a network, wait, or mutate state.

Handle `tea.WindowSizeMsg` in `Update`. Store the width and height in the model. Recompute layout from those values. Show a short resize message below each view's minimum size. Render only visible rows and keep one frame flush per update.

Use `tea.Cmd` for effects. A command may read a file, call a service, wait for a timer, or return a result message. Return a command from `Update`, then handle its result in a later update. Never block `Update` or `View`. Add cancellation, timeouts, and a request identity when stale results can arrive after navigation.

## Keys and components

Use `bubbles/key` to define named bindings. Use `bubbles/help` to show the bindings that apply to the current view. Keep `Ctrl+C` as the global escape. Use `q` as a context action and leave it inactive while text input owns focus. Use `Escape` for cancel or back, `Enter` for confirm, `/` for search, and arrows or `j` and `k` for movement. Keep focus visible and restore it after returning to a view.

Choose a Bubbles component by state. Use `list` for a selectable set, `table` for a fixed snapshot, `textinput` for one line, `textarea` for multiline text, `viewport` for long content, `spinner` for unknown waits, `progress` for known totals, and `help` for discoverable bindings. Keep component state in its owner. Give every empty, loading, success, and error state a visible action or escape route.

Follow [interaction.md](interaction.md) for focus, navigation, and component choices. Follow [lipgloss-go.md](lipgloss-go.md) for color, spacing, width, tables, and plain output. Do not create a second styling rule set here.

## Screens and navigation

Use a small model with a screen field for a few peer views. Use a stack when a list opens a detail view and `Escape` returns. Keep screen-specific keys with that screen. For larger apps, split screen models and route messages at one owner. Preserve selection, filters, and focus across a return when the user expects them to remain.

Give every screen an escape route. Show the current screen and its useful keys in a footer or help view. Keep destructive actions safe by default. A modal must own focus until the user confirms or cancels.

## Async work and exit

Start asynchronous work through commands. Keep one request per resource at a time. Cancel or ignore work after a screen closes. Tag results with a generation or identity and discard stale results. Bound event queues, pasted input, displayed cells, and log lines. Show dropped or truncated data.

Bubble Tea's `tea.Program` owns terminal setup and restoration for normal program exits. Keep cleanup in the program lifecycle. Handle signals and panic paths according to the selected major version. Preserve the recovery rules in [robustness.md](robustness.md), including visible errors, retry or back actions, resize checks, and atomic state writes.

When stdin or stdout is not a TTY, choose the plain result path or fail with a clear stderr message and nonzero status. Do not start a key loop in a pipe, CI run, or `TERM=dumb` environment. Test the model and commands without a terminal. Feed key messages into `Update` and assert state changes, including quit, navigation, and one action result.

## Common mistakes

- Calling blocking I/O from `Update` or `View`.
- Starting a goroutine that mutates the model directly.
- Returning a stale command result after the user changed screens.
- Rebuilding component state on every render and losing focus or selection.
- Ignoring `tea.WindowSizeMsg` and assuming a fixed terminal.
- Hiding actions behind keys that the help view does not show.
- Using color as the only status signal.
- Starting a full-screen program for redirected input or output.
- Mixing v1 and v2 package paths or API assumptions.

## Review

Check `go.mod` and the selected major versions before writing imports. Check the first view, each navigation path, loading and error states, quit, resize, narrow layout, large paste, and repeated navigation. Run the headless key test at 80 columns and at a narrow size. Confirm that normal exit, signal handling, and panic recovery leave the terminal usable.
