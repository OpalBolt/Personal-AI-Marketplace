# Terminal design

Good terminal output makes the next useful fact easy to find. Start with plain text, then add style where it carries meaning.

## Hierarchy

Give each run a clear order:

1. Put the task name or result first.
2. Put the main data next.
3. Put labels, counts, and hints after the data.
4. Use borders and separators only to group related content.

Use three or four levels of emphasis. Bold titles and important values. Use dim text for labels and hints. Keep body text normal.

## Spacing and alignment

- Leave one cell at the terminal edge.
- Put one blank line between major sections.
- Keep related values close together.
- Align labels and columns on a grid.
- Left-align text. Right-align numbers when a column needs comparison.
- Give bordered content at least one cell of inner padding.

Read [unicode-and-text.md](unicode-and-text.md) before calculating padding or column widths.

## Color

Start without color. Add no more than four colors for one display. Assign each color one role:

| Role | Meaning |
|---|---|
| Base | Normal text |
| Muted | Labels and secondary detail |
| Accent | Current task or selected item |
| Warning or error | A condition that needs attention |

Use a symbol and a word with every status. `✓ done`, `✗ failed`, and `! warning` remain clear without color.

Do not use color for decoration. Do not color every label. Do not make a status depend on color alone. Honor `NO_COLOR`, `TERM=dumb`, and non-TTY output as described in [terminal.md](terminal.md).

## Borders and layout

Use a border to group a named panel, a summary, or a prompt. Use whitespace for content that already groups itself. Do not border every line.

Pick a layout that matches the work:

| Work | Layout |
|---|---|
| One task | Title, body, result |
| Fixed data | Header and table |
| Several sections | Named panels with spacing |
| Monitoring | One short live region or a gated display |

Keep a layout useful at 40 columns. At a narrow width, remove decoration before removing the result or the next action.

## Symbols

Use symbols that still make sense in plain output:

| Symbol | Use |
|---|---|
| `✓` | Completed |
| `✗` | Failed |
| `!` | Warning |
| `…` | More text or work in progress |
| `-` | Neutral list item |

Offer ASCII alternatives when the target terminal cannot show Unicode.
