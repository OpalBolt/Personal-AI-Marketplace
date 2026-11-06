# Light Tier

Light presents a running app as readable output. The app prints, and the user reads.
Input is a one-shot prompt asked only when the app needs one answer.

Light covers:

- Styled lines, headers, key-value summaries, and tables.
- Spinners and progress bars for named work.
- A live region that redraws in place.
- A bordered display that redraws without a key loop.
- One-shot confirm, select, text, and password prompts.
- Styled errors and a final result line.

Light is the default tier. It does not own navigation, focus, or lasting view state. Those are [FULL.md](FULL.md).

## Steps

1. **Write the transcript.** Mock start, progress, result, and failure as plain text. Include every reachable state from [references/states.md](references/states.md).
2. **Choose one form per moment:**

   | Moment | Form |
   |---|---|
   | Short status | One line with a symbol and word |
   | Known steps | Progress bar with a count |
   | Unknown wait | Spinner with a label that names the work |
   | Parallel items | Live table with one row per item |
   | Monitoring without input | Live bordered display, only if the gate below passes |
   | Needs one answer | One-shot prompt |
   | End of run | Summary and result line, then exit |

3. **Build** with [references/rich-python.md](references/rich-python.md) or [references/lipgloss-go.md](references/lipgloss-go.md).
4. **Add the plain path.** With stdout piped, print readable lines without escape codes or animation. A prompt must use a flag or default, or fail clearly without waiting.
5. **Check** at 80 columns, at 40 columns, with `NO_COLOR=1`, and piped to a file.

The Light plan is complete when each reachable state has a transcript line, the plain path does not block, and the result remains in scrollback.

## Redraw gate

Partial redraw of a live region is the default for changing output. Keep it short, near one third of the terminal height or less.

Full-screen redraw is a gated exception. Use it only when every condition holds:

- The whole display changes state.
- The app has no key loop.
- stdout is a TTY.
- Every exit path leaves a final summary line in scrollback, including Ctrl+C.
- The user asked for full-screen redraw, or the agent states why inline output is not enough.

If any condition fails, use partial redraw or ordinary lines. Never turn a Light app into a key-driven interface to justify the exception.

## Rules

- **Scrollback is the product.** Leave a final line after any output that replaces itself.
- Use a live region only for state that changes.
- Use one spinner or progress bar at a time unless rows belong to one live table.
- Name the work: `Fetching 42 packages…`, not `Loading…`.
- End with what changed, how long it took, and the next action after failure.
- Show prompt defaults. Explain each choice. Set destructive confirms to `no` by default.
- Read terminal width at print time. Truncate or wrap by display width.
- Use tables for fixed snapshots. Use log lines for events over time.

## Escalate to Full

Stop and ask when the design needs result-set scrolling, selection among many rows, a filter box, or several screens. Those needs belong to Full.
