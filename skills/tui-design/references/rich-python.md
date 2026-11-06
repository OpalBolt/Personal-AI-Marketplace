# Rich for Python Light output

Targets **Rich 14.x**. Check the project's dependency first. Keep one Rich major version across the app.

Build every message as plain text first. Add style, tables, and redraw only on a TTY.

## Two gates

Keep styling and interaction apart.

- **Plain** is true when stdout is not a TTY, `NO_COLOR` is set, or `TERM=dumb`. Plain turns off color, spinners, progress refresh, and live regions. Print ordinary completed lines instead.
- **Interactive** is true when stdin and stdout are both TTYs and `CI` is not set. Only interactive runs may prompt.
- Redraw needs interactive and not plain. `NO_COLOR` on a TTY still allows a prompt, but never a spinner or live region.
- A pipe, redirected stdin, or CI run never prompts and never waits.

## Console policy

Create one console for data on stdout and one with `stderr=True` for failures and diagnostics. Build both from the same plain decision, so every component follows one policy. Pass this console to every Rich component.

## Styled lines

Pair each status with a symbol and a word: `✓ done`, `! warning`, `✗ failed`. Use at most 4 colors. Style the label, not the paragraph.

## Tables

Use `Table` for a snapshot with fixed columns. Let Rich size the columns. Shorten long values before adding the row. Use log lines, not a table, for events over time.

## Progress bars

Use `Progress` when the total is known. Take the total from the real input length. Show a spinner column, a description that names the work, a bar, and a count. In plain mode, print one line per step with its count. Keep one bar on screen unless several rows belong to one table. Print the result line after the context closes.

## Spinner

Use `console.status` when there is no useful total. Name the work. In plain mode, print one line that names the work before it starts. Never show a spinner and a bar for the same operation.

## Live region

Use `Live` for a short region whose content changes. Partial redraw is the default. Keep the final result line outside the live context so it stays in scrollback. In plain mode, print a line per update or per milestone.

Use a full-screen redraw only when the gate in [../LIGHT.md](../LIGHT.md) passes.

## One-shot prompts

Use `Confirm.ask` and `Prompt.ask` with `default=` set and `console=` passed. Use `password=True` for secrets. Destructive confirms default to no.

When the run is not interactive, read the answer from a flag or an environment variable. If a required value is missing, print a clear message to stderr and exit nonzero. Never substitute an empty string.

## Check

Run the same code piped to a file and search it for escape bytes. Run it with `NO_COLOR=1`, with `TERM=dumb`, with `CI=1` on a TTY, at 80 and 40 columns. The result line keeps its symbol and word in every case.
