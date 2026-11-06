# TUI patterns

Use a proven pattern when the app has a common shape. Choose the smallest pattern that fits the user's task. These patterns usually need the Full tier because they include navigation, focus, selection, or lasting view state. A Light version can print a snapshot or a short sequence of events without a key loop.

Use [design.md](design.md) for visual hierarchy, spacing, borders, and color. Use [states.md](states.md) for state wording. Use [interaction.md](interaction.md) for keys and focus. Use [unicode-and-text.md](unicode-and-text.md) for display width.

## Dashboard

**Use it for:** A quick view of related metrics, health signals, and recent activity.

**Usual tier:** Full when panels can receive focus or open detail views. Light for a fixed report or a short monitoring update.

### Layout

Put a title and connection or update status in the header. Place two to four key metrics near the top. Give the main trend or performance panel the largest remaining area. Put recent activity beside or below it. Keep quick actions and status in a footer or a small action area.

Keep panels at similar visual weight unless one metric is the clear focus. Leave a consistent one or two cell gutter. Keep the dashboard to four to six panels at a standard terminal size. At a narrow width, stack panels or keep only the key metrics and a link to detail views.

### States

- Loading shows known labels with quiet placeholders and names the work.
- Refreshing keeps current data visible and updates the status when new data arrives.
- Partial failure keeps working panels visible and marks the failed panel with a recovery action.
- Empty data explains what is missing and names the action that can add or load data.
- Success shows the latest update time and the change that completed.
- Error names the failed source and offers retry or a safe fallback.

### Design notes

Make metric values the most prominent text. Use a symbol and word for each status. Show a last-updated time when data does not refresh continuously. Keep charts simple. Use bars or sparklines only when they clarify a trend. Do not make a dashboard a collection of decorative cards.

## Log viewer

**Use it for:** Reading event streams, following live output, filtering levels, and inspecting one entry.

**Usual tier:** Full for scrolling, search, follow mode, selection, and a detail view. Light for a bounded report or a plain stream of log lines.

### Layout

Put the source name and stream state in the header. Put search and level filters below it. Use the main area for timestamp, level, source, and message columns. Keep a selected-entry detail area below or open it as a separate view. Put follow state, entry count, active filter, and key hints in the footer.

Render only visible rows. Keep a bounded buffer. Pause follow mode when the user scrolls away from the newest entry. On a narrow screen, shorten columns, hide optional source fields, or open details as a separate view.

### States

- Loading names the source and the range being fetched.
- Streaming appends new entries and reports the current count.
- Paused explains that new entries are buffered and names the key to resume.
- Filtered empty says which filter produced no matches and how to clear it.
- Disconnected keeps the last entries visible and gives a reconnect action.
- Error names the source failure and offers retry or exit.

### Design notes

Color only the level label or another small semantic part. Keep the message readable without color. Give error and warning levels a symbol and word. Batch updates so one event does not force one frame. Parse expensive structured details only when the user selects an entry. Use [robustness.md](robustness.md) for buffer, flood, timeout, and reconnect rules.

## Data browser

This pattern includes database browsing. Use it for records, API resources, collections, and other structured rows.

**Use it for:** Searching, filtering, sorting, selecting, and inspecting records in a list-to-detail flow.

**Usual tier:** Full for live filtering, navigation, selection, editing, or several views. Light for a fixed table, a filtered report, or one record summary.

### Layout

Put the resource name, active filters, and total count in the header. Put search, filter choices, and create actions below it. Use a master-detail body on wide screens. Give the list about half to three fifths of the width. Let the detail panel use the remaining space and scroll independently. Put connection state, result counts, and key hints in the footer.

At a narrow width, hide the detail panel and open details as a separate view. For database-style tools with several peer views, use a view stack. Keep tables, data, schema, query, and query history as clear destinations. Preserve page, cursor, sort, filter, and focus state when the user returns.

### States

- Loading shows the resource name and keeps old data during a refresh.
- Empty explains how to create or load the first record.
- Filtered empty names the active filter and explains how to clear or change it.
- No selection tells the user how to select a record.
- Refresh failure keeps the last usable rows visible and offers retry.
- Disconnected shows the retry state and attempt count without blanking the grid.
- Destructive actions name the exact target and use a safe confirmation default.

### Design notes

Use proportional columns based on content. Truncate cells by display width. Align numeric columns consistently. Show selection and multi-select counts without relying on color. Derive page size from the viewport and clamp it after changes. Keep one data-grid layout for rows, schemas, and query results when their behavior matches.

## File explorer

**Use it for:** Browsing directories, selecting files, previewing content, and acting on paths.

**Usual tier:** Full for tree expansion, selection, preview focus, and file actions. Light for a directory listing, search result, or one file summary.

### Layout

Put the current path and item count in the header. Put filter and file actions below it. Use a tree or list on the left and a metadata and preview panel on the right. Give the preview panel about half the width on a wide terminal. Put the path, item count, and key hints in the footer.

On a narrow screen, hide the preview panel and open a selected item as a detail view. Expand one directory at a time. Load child entries when the user expands a directory. Keep the selected item visible while the tree changes.

### States

- Loading names the directory being scanned and reports useful progress for large trees.
- Empty says that the directory has no items and offers create or parent navigation.
- Permission failure names the path and explains the next action.
- Binary preview shows metadata and says that content is not available as text.
- Missing path offers a parent, retry, or new location action.
- Error keeps the current path when possible and gives a recovery action.

### Design notes

Use indentation and symbols to show hierarchy. Keep file-type symbols meaningful without color. Sort directories and files consistently. Keep hidden-file behavior visible and session state predictable. Truncate previews by display width and cap the amount of content read. Use relative paths when they give useful context and absolute paths when disambiguation matters.

## Form workflow

**Use it for:** Creating records, editing values, and changing configuration through several related fields.

**Usual tier:** Full when fields need focus, validation, selection, or a dirty-state confirmation. Light for one-shot input with one answer per prompt. A multi-question form is Full.

### Layout

Put a back action and the form title in the header. Put labels above fields. Keep required markers and optional labels visible. Group related fields with consistent spacing. Use a common input width. Put save and cancel actions near the bottom, with a footer that shows the current field and useful keys.

Use text inputs for short values, multiline fields for descriptions, selects for bounded options, radio controls for a few mutually exclusive choices, and checkboxes for independent toggles. Keep the active cursor and focused control visible. For long forms, scroll fields and keep the save action reachable.

### States

- New forms show defaults, required markers, and focus on the first usable field.
- Editing forms show existing values and the title identifies the record.
- Validation failure points to the first invalid field, states the fix, and clears when the value changes.
- Saving disables conflicting actions and names the work.
- Save success confirms the change and states whether the view closes or remains open.
- Save failure keeps the user's input and offers retry or correction.
- A dirty cancel asks whether to discard changes. The safe action is the default.

### Design notes

Use explicit save actions. Let Enter confirm a choice or move through a form instead of submitting every field. Keep validation near the field it describes. Trap focus inside a modal confirmation. Preserve the user's values after a failed save. Use [terminal.md](terminal.md) for safe non-interactive input when a form has a Light path.
