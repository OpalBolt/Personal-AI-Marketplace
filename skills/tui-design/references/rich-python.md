# Rich for Python Light output

Examples target **Rich 14.x**. Check the project's dependency before adding Rich. Keep one Rich major version across the application.

Rich should improve a TTY run without changing the meaning of the plain path. Build each message as plain text first. Add styles, tables, and redraw only when stdout is a TTY and `NO_COLOR` is absent.

## Console policy

Use one `Console` for a run. Make plain mode explicit so every component follows the same policy.

```python
# Rich 14.x
import os
import sys
from rich.console import Console

plain = (
    not sys.stdout.isatty()
    or "NO_COLOR" in os.environ
    or os.environ.get("TERM") == "dumb"
)
console = Console(
    no_color=plain,
    force_terminal=False if plain else None,
)
interactive = console.is_terminal and not plain
```

A pipe gets plain lines. `NO_COLOR` gets plain lines even on a TTY. Use `interactive` before starting a spinner, progress refresh, live region, or prompt.

## Styled lines

Use a symbol and a word with each status. The word keeps the line clear without color.

```python
# Rich 14.x
console.print("[bold]Build package[/bold]")
console.print("[green]✓ done[/green] 42 files")
console.print("[yellow]! warning[/yellow] cache is stale")
console.print("[red]✗ failed[/red] could not write the archive")
```

Choose a small palette. Avoid styling an entire paragraph when one label carries the meaning.

## Tables

Use `Table` for a fixed snapshot. Let Rich calculate column widths. Give long values a sensible maximum or shorten them before adding the row.

```python
# Rich 14.x
from rich.table import Table

summary = Table(title="Packages")
summary.add_column("Name")
summary.add_column("Status")
summary.add_column("Files", justify="right")
summary.add_row("core", "✓ ready", "42")
summary.add_row("docs", "! skipped", "0")
console.print(summary)
```

A table is not a log. Use one line per event when the user needs a history of work.

## Progress bars

Use `Progress` when the total is known. A pipe should receive completed lines, not a refreshing bar.

```python
# Rich 14.x
from rich.progress import BarColumn, Progress, SpinnerColumn, TextColumn

if interactive:
    with Progress(
        SpinnerColumn(),
        TextColumn("{task.description}"),
        BarColumn(),
        "{task.completed}/{task.total}",
        console=console,
    ) as progress:
        task = progress.add_task("Syncing records", total=3)
        for record in records:
            sync(record)
            progress.advance(task)
else:
    for number, record in enumerate(records, 1):
        sync(record)
        console.print(f"Syncing records {number}/{len(records)}")
```

Keep one progress bar on screen unless several rows belong to one table. End with a result line after the context closes.

## Spinner

Use a spinner when the duration has no useful total. Name the work. `console.status` stops cleanly when its context ends.

```python
# Rich 14.x
if interactive:
    with console.status("Fetching package metadata", spinner="dots"):
        fetch_metadata()
else:
    console.print("Fetching package metadata")
    fetch_metadata()
console.print("[green]✓ done[/green] package metadata fetched")
```

Do not animate a pipe or CI log. Do not show a spinner and a progress bar for the same operation.

## Live region

Use `Live` for a short region whose content changes. Partial redraw is the default Light redraw. Keep the final result outside the live context so it remains in scrollback.

```python
# Rich 14.x
from rich.live import Live
from rich.table import Table


def worker_table(done: int, total: int) -> Table:
    table = Table(title="Workers")
    table.add_column("Task")
    table.add_column("State")
    table.add_row("Index files", f"{done}/{total}")
    return table

if interactive:
    with Live(worker_table(0, 3), console=console, refresh_per_second=8) as live:
        for done, item in enumerate(items, 1):
            process(item)
            live.update(worker_table(done, len(items)))
else:
    for done, item in enumerate(items, 1):
        process(item)
        console.print(f"Processing {done}/{len(items)}")

console.print("[green]✓ done[/green] all workers finished")
```

Use a full-screen redraw only when the gate in [../LIGHT.md](../LIGHT.md) passes. In particular, it needs a TTY, no key loop, a changing whole display, a user request or a stated reason, and a final line on every exit path including Ctrl+C. A live region is usually the smaller choice.

## One-shot prompts

Ask only for one answer. Show the default. Keep prompts out of non-TTY runs.

```python
# Rich 14.x
from rich.prompt import Confirm, Prompt

if interactive:
    delete = Confirm.ask("Delete the cache?", default=False, console=console)
    environment = Prompt.ask(
        "Environment",
        choices=["dev", "prod"],
        default="dev",
        console=console,
    )
    token = Prompt.ask("API token", password=True, console=console)
else:
    delete = False
    environment = os.environ.get("APP_ENV", "dev")
    token = os.environ.get("APP_TOKEN", "")
    console.print(f"Using environment {environment} without prompting")
```

A destructive confirmation defaults to `False`. Require a flag or environment value when a non-TTY run cannot use a safe default. Return a clear error instead of waiting.

## Plain fallback

This small example targets **Rich 14.x** and exercises the policy that matters most. It prints plain lines when piped, styled output on a TTY, and plain output when `NO_COLOR` is set.

```python
# Rich 14.x
import os
import sys
from rich.console import Console


def main() -> None:
    plain = (
        not sys.stdout.isatty()
        or "NO_COLOR" in os.environ
        or os.environ.get("TERM") == "dumb"
    )
    console = Console(
        no_color=plain,
        force_terminal=False if plain else None,
    )
    console.print("[bold]Backup[/bold]")
    console.print("[green]✓ done[/green] 3 files copied")
    console.print("[yellow]! warning[/yellow] cache was skipped")


if __name__ == "__main__":
    main()
```

Check the plain path by piping to a file and searching for escape bytes. Check `NO_COLOR=1` in a TTY and in a pipe. The final result should still include the status symbol and word.
