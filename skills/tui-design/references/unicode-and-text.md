# Unicode and text width

String length is not terminal width. Bytes, code points, grapheme clusters, and display cells can all differ.

| Text | Display width |
|---|---:|
| `Hello` | 5 |
| `中文` | 4 |
| `é` | 1 |
| `👨‍💻` | 2 |
| `🇮🇶` | 2 |

Combining marks join a base character. Joiner sequences form one visible symbol. CJK characters and many emoji use two cells. Terminal and font support can vary, so do not make a layout depend on an unusual symbol.

## Rules

1. Store user text unchanged.
2. Measure with a display-width helper, not `len()`.
3. Truncate at a grapheme boundary, then append `…` when it fits.
4. Pad with spaces until the target display width.
5. Measure unstyled text. ANSI style codes have zero display width.
6. Keep byte offsets out of cursor and slice calculations.

Rich handles common terminal width calculations for its renderables. Use its layout and table APIs instead of hand-padding styled strings. Use `wcwidth` when application code must measure text directly.

## Python

Use `wcwidth` for display width. CJK counts 2 columns per character, a combining mark adds 0, and a ZWJ emoji sequence counts as 2 in total. When `wcwidth` is not already a project dependency, prefer the chosen display library's helper. Do not add a second width implementation for the same path.

## Narrow output

At 40 columns, shorten decoration first. Preserve the task name, status word, result, and recovery action. Use a width-aware table or wrap long values. Verify columns with CJK, combining marks, and emoji.
