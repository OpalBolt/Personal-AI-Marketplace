# Interaction

This reference targets Textual 8.x and the Go TUI library major versions declared in `go.mod`. Check `pyproject.toml` or `go.mod` first. Keep the interaction model language-neutral.

## Keys

Every action must have a keyboard path. Keep these conventions stable:

- `q` and `Ctrl+C` quit or leave the current context.
- `Escape` cancels, closes an overlay, or goes back.
- `?` opens help.
- `Tab` and `Shift+Tab` move focus.
- `Enter` activates or confirms.
- `/` opens search or filtering.
- `j` and `k`, or arrow keys, move within a list.
- `Home` and `End` move to the first and last item.
- `Space` toggles a selection.
- `n`, `e`, `s`, and `r` create, edit, save, and refresh when those actions exist.

Use number keys for a small set of peer views. Keep panel movement consistent with `Tab` or dedicated left and right bindings. Show the current context's keys in a footer or status bar.

## Focus

Keep exactly one focused control. Make focus visible with reverse video, a border, bold text, or a cursor. Move focus in reading order or another stable loop.

In lists, focus follows the selected row. In forms, `Tab` follows field order. In overlays, trap focus until the user confirms or cancels. Restore focus when the user returns to a view.

When focus moves off-screen, scroll it into view with nearby context. Keep an escape route from every focus state.

## Navigation

Choose one model for the app and name it in the transcript:

- Tabs suit a small set of peer views. Number keys can jump to a view.
- A sidebar suits many sections. `Tab` moves between the sidebar and content.
- A stack suits list, detail, and edit flows. `Enter` opens the next view and `Escape` returns.
- A hybrid combines these models. Keep each boundary visible.

Do not make a modal depend on background focus. Keep destructive confirmation on the safe action by default. Let `Escape` cancel without applying changes.

## Component choices

- Use a table for a fixed snapshot. Show headers, selection, sorting, and position.
- Use a list for a selectable set. Show the selected row and an empty state with a next action.
- Use a form for labeled fields. Put validation below the field and show required values.
- Use tabs for a few peer views. Keep the active tab clear on one line.
- Use a sidebar for sections. Collapse it at narrow widths when content needs the space.
- Use a split pane for master-detail work. Enforce a useful minimum size for each pane.
- Use a status bar for location, connection state, counts, and key hints.
- Use a modal for a short decision. Keep focus inside it and make the safest choice the default.
- Use a search bar for filtering. Show match counts and let `Escape` restore the full set.
- Use a toast for brief feedback. Put lasting errors beside the affected content.

## Discoverability

Show only the keys that apply to the current context. Put global actions after local actions. A help view should list local bindings first, then global bindings.

Give a complex first view a short, dismissible hint. Do not hide actions behind undocumented keys. Keep feedback visible after save, delete, refresh, and failure.
