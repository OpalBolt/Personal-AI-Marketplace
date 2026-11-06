# Terminal fallbacks

Treat the terminal as an optional display upgrade. The plain path must remain useful in a pipe, CI job, file, or basic terminal.

## Output checks

At startup, derive these facts once:

- `sys.stdout.isatty()` says whether output can be redrawn.
- `NO_COLOR` disables color when present, even on a TTY.
- `TERM=dumb` calls for plain text and simple symbols.
- A non-TTY output stream needs lines, no animation, and no control sequences.

Send data and normal status to stdout. Send diagnostics to stderr. Keep exit codes meaningful for scripts.

Rich and other libraries can detect a TTY, but the application still owns the policy. Pass the plain-mode decision to every component that can animate or style output.

## Feature order

Use this order when adding terminal features:

1. Plain lines that carry the full meaning.
2. Symbols and spacing that survive without color.
3. Styles and borders on a TTY.
4. Live redraw only for changing state.
5. A full-screen redraw only after the gate in [../LIGHT.md](../LIGHT.md) passes.

Do not make an optional feature a hard requirement. If a capability is missing, keep the same text and remove the decoration.

## Prompts

A prompt is safe only when the process can receive an answer. For a non-TTY run:

- accept a flag or environment value
- use a documented default when it is safe
- fail with a clear message when no safe default exists

Never leave a pipe waiting for input. A destructive prompt defaults to `no`.

## Redraw and cleanup

Partial redraw requires a TTY. Stop animation before printing the final result. Flush one final plain line to scrollback.

A full-screen redraw must meet every condition in [../LIGHT.md](../LIGHT.md). Install cleanup for normal exit, errors, and Ctrl+C. Ctrl+C must leave the final summary line before the process exits.

Read the current width at print time. At narrow widths, wrap or truncate by display width. Keep the result and recovery action visible.

## Terminal contract

Document the contract for a tool:

```text
Required: UTF-8 output
Enhanced: color and a TTY
Fallback: plain lines in pipes, CI, files, TERM=dumb, and NO_COLOR mode
```

Test at 80 columns, 40 columns, a pipe, and `NO_COLOR=1`. Inspect piped output for escape bytes.
