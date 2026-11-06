# Lip Gloss and huh for Go Light output

This reference targets Lip Gloss 1.x, huh 1.x, and charmbracelet/log 1.x. Check the project's `go.mod` before using these package paths or APIs. Lip Gloss, huh, and Bubble Tea have v2 releases with API changes.

For the v1 target, import Lip Gloss from `github.com/charmbracelet/lipgloss`, huh from `github.com/charmbracelet/huh`, and logging from `github.com/charmbracelet/log`. Huh's standalone spinner is a separate module at `github.com/charmbracelet/huh/spinner`. Check that module in `go.mod` too. The v2 paths use `charm.land/lipgloss/v2`, `charm.land/huh/v2`, and `charm.land/log/v2`. Match every import and API to the versions in `go.mod`. Do not mix major versions in one app.

## Two gates

Keep styling and interaction apart.

- **Plain** is true when the output stream is not a TTY, `NO_COLOR` is set, `TERM=dumb`, or `CI` is set. Plain output uses completed lines. It removes color, spinners, and redraws.
- **Interactive** is true when stdin and stdout are TTYs and `CI` is not set. Only interactive runs may prompt.
- A TTY with `NO_COLOR` still permits prompts. It uses ordinary lines instead of color or animation.
- A pipe, redirected stdin, or CI run never prompts and never waits.

Make the decision per stream. Apply the stdout decision to data and the stderr decision to diagnostics. A redirected stderr stream also stays plain.

## Styled lines

Use Lip Gloss styles for short labels, headings, and status lines. Pair each status with a symbol and a word, such as `✓ done`, `! warning`, or `✗ failed`. Keep the meaning in the words so color never carries the status alone.

Use at most four colors. Style the label instead of the full paragraph. Keep the unstyled text as the source for logs and the plain path. Read the terminal width when printing. Use Lip Gloss width, padding, and truncation methods so CJK, emoji, and combining marks keep their display width.

## Tables

Use the v1 Lip Gloss table package at `github.com/charmbracelet/lipgloss/table` for a fixed snapshot. Give each column a clear heading and add one row per item. Shorten long values before adding rows. Keep status words and symbols in the cells. Use log lines for events over time.

Size the table for the current display width. A narrow terminal needs fewer columns or wrapped values. Print a plain, delimiter-separated table or named lines when the plain gate is active. Keep the same facts in both forms.

## Spinner

Use `github.com/charmbracelet/huh/spinner` for a short operation with no useful total. It is a separate module in the v1 target. Name the work, such as `Fetching packages`. Use one spinner at a time. Use a progress display when the total is known.

Start a spinner only when the output stream is interactive and color is allowed. In plain mode, print one line that names the work before it starts. Print the result line after the spinner or other live context closes, so it remains in scrollback.

## One-shot prompts

Use huh for one answer. Use a confirm for yes or no, a select for a small set of choices, an input for text, and a password field for secrets. Set a visible default. Set destructive confirms to `no` by default. Explain each choice in the prompt.

Gate every prompt on an interactive stdin and stdout. In a non-interactive run, read the answer from a flag or an environment variable. If a required answer is missing, write a clear message to stderr and exit nonzero. Never replace a missing answer with an empty string.

huh supports an accessible mode for users who need a simpler prompt flow. Offer it through the app's documented option when the task needs accessible interaction. Keep the same validation and non-interactive gate.

## Logging

Use charmbracelet/log for structured diagnostics and events. Send normal results to stdout. Send warnings, errors, and diagnostic context to stderr. Keep log fields stable and useful, such as the operation, item, and elapsed time.

Apply the plain decision to the logger's output stream. A pipe, `NO_COLOR`, `TERM=dumb`, or CI must produce readable log lines without escape codes. Keep secrets out of fields and messages.

## Plain fallback

Build each message as plain text first. Add Lip Gloss styles, a huh spinner, or redraw only after the stream decision allows it. A pipe must receive completed lines with no escape bytes and no animation. A TTY may receive styled lines and a spinner.

Use ordinary lines for each step in plain mode. Keep the final result line after any live operation. Preserve the status symbol and word in every mode. A prompt either takes a flag or environment value in plain mode or fails clearly on stderr with a nonzero exit.

A full-screen redraw needs the gate in [../LIGHT.md](../LIGHT.md). Light output has no key loop. Prefer ordinary lines or a short partial redraw when the gate does not pass.

## Check

Read `go.mod` first and confirm the major version of every Charm package. Run the same small program with stdout piped to a file and search it for escape bytes. Redirect stderr alone and run the same check. Test `NO_COLOR=1`, `TERM=dumb`, and `CI=1`. Check an interactive TTY at 80 and 40 columns.

Verify that a piped run prints plain lines, does not prompt, and exits without waiting. Verify that an interactive TTY prints styled lines and can show a spinner. Verify that the result line remains in scrollback.
