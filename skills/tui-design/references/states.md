# Output states

Every Light run needs a useful line for each state it can reach. The line should say what happened and what the user can do next.

## Empty

Explain what is missing and name the next action.

```text
No records found. Add one with `tool create`.
```

A blank table is not an empty state. A filtered empty result should name the filter and suggest how to change it.

## Loading

Show loading output at once. Name the work instead of saying only `Loading…`.

```text
… Fetching 42 packages
```

Use a spinner when the duration is unknown. Use a count or progress bar when the work has a known total. Use one animated indicator at a time.

## Progress

Show progress as work changes. Include a count when it helps the user estimate the remaining work.

```text
Syncing records 12/48
```

Keep progress output quiet when stdout is not a TTY. Print useful completed lines instead of animation.

## Success

End with a result that names the change.

```text
✓ Sync complete — 48 records updated
```

Leave this line in scrollback after a live region or bordered display ends.

## Warning

Explain the risk and give a safe next action.

```text
! Connection is slow — using cached data
```

A warning remains readable without color. Do not hide it in dim text.

## Error

State the failed operation, the reason when safe to show, and the recovery action. Send the failure summary and diagnostic detail to stderr (for Python, use `Console(stderr=True)`). Keep data output on stdout and use a nonzero exit code for failure.

```text
✗ Sync failed — check the network and retry
```

## Prompt

Show the default and explain each choice before asking. Destructive confirmations default to `no`.

```text
Delete the cache? [y/N]
```

A non-TTY run must use a supplied value or a documented default. It must not wait for input.

## State checklist

Before implementation, list the states the operation can reach:

- empty input or empty result
- loading or queued work
- progress and cancellation
- success
- warning or degraded output
- error and recovery
- prompt accepted, declined, or skipped

Give each applicable state a plain transcript line. Test the line without a terminal.
