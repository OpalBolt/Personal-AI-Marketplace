# Textual for Python Full TUIs

Targets **Textual 8.x**. Check `pyproject.toml` and the lock file first. Keep one Textual major version across the app. Check the installed version when APIs differ.

## Structure

`App` owns global bindings, shared services, and the screen stack. A `Screen` owns one view and its local widget tree. Widgets compose focused pieces such as navigation, tables, forms, and status bars. Keep domain models and I/O outside rendering code.

Use a small app for one to three screens. Split screens, widgets, domain services, and styles as the app grows. Give each custom widget a clear input, state, messages, and rendering responsibility.

Use `compose` to build the widget tree. Use `push_screen` for drill-down views and `pop_screen` to return. Set a title and subtitle when the Header provides useful context.

## TCSS

Keep shared styles in `.tcss` files. Use Textual design tokens for surfaces, text, borders, accents, warnings, errors, and success. Keep layout rules responsive. Derive flexible sizes from the available region.

Use classes and IDs for stateful styling. Reserve inline styles for a local, dynamic exception. Define a minimum usable size. At a smaller size, collapse optional panels or show a short resize message.

## Reactive state

Use `reactive` for state that changes the rendered view. Watchers should update dependent widgets or start a small state transition. Keep domain mutations in services or actions, not in render methods.

Keep focus, selection, scroll position, input, loading, and error state explicit. Use a single state owner for values shared by several widgets. Avoid duplicate state that can drift.

## Workers and async safety

Use `@work` from `textual`, not `textual.work`. Use an async worker for awaitable I/O. Use a thread worker for blocking synchronous I/O. The render path and event handlers must stay short.

Mark mutually exclusive work so repeated refresh keys do not race. Add timeouts, cancellation, and a generation check when an old result can arrive after navigation. Update widgets on the app thread through Textual's worker facilities.

Show loading, success, timeout, and error states. Keep old data visible when a refresh fails. Give each failure a retry or dismiss action.

## Bindings and focus

Declare global bindings on the app and view-specific bindings on the screen or widget. Show important actions in the Footer. Use hidden bindings only for secondary movement keys.

Use `Tab` and `Shift+Tab` in forms and panels. Use arrow keys or `j` and `k` in lists when the context supports them. Reserve `Escape` for cancel, close, or back. Keep `Ctrl+C` as the global escape. Make `q` context-sensitive and do not trigger it while a text input has focus.

Focus one usable control on each view. Make focus visible and restore it after returning to a screen. Trap focus inside a modal until the user confirms or cancels.

## Messages

Use typed custom messages for child-to-parent events such as selection, save, and status changes. Post the message from the widget and handle it at the nearest owner that can act on it. Keep messages small and name their payloads clearly.

Use `notify` for brief, non-blocking feedback. Put durable errors near the affected content or in a status area with a recovery action.

## Testing with Pilot

Use `App.run_test()` and its Pilot to drive the app without a terminal. Press a key with Pilot, then assert the active screen, focused widget, reactive state, or rendered widget content. Cover the initial view and at least one navigation or action path.

Keep domain tests separate from Pilot tests. Add a resize test for layouts with a minimum size. Test error and cancellation paths when a worker changes screen state.

## Review

Check the app at 80x24 and a narrow size. Check plain and color modes when the app can run outside a TTY. Confirm that every screen has a visible escape route and that terminal restoration covers every exit path.
