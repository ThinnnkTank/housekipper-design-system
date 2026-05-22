# SemanticToken — Action

Visual variants for `DsButton`. **Not for severity** — that's `StatusToken`.

| Variant | Fill | Border | Foreground | Pressed Fill |
|---|---|---|---|---|
| `primary`   | `ink`  | — | `paper` | `paper` (inverts) |
| `secondary` | —      | `ink` | `ink`   | `ink` (inverts to filled) |
| `ghost`     | —      | —     | `ink`   | `ink10` (subtle wash) |
| `urgent`    | `signal` | `signal` | `paper` | `signalStrong` |

Disabled treatment: apply `.opacity(ActionToken.disabledOpacity)` = `0.38`. Works across all variants without color changes.

API:
```swift
ActionToken.fill(.primary)
ActionToken.border(.secondary)
ActionToken.foreground(.ghost)
ActionToken.fillPressed(.urgent)
```

**Status:** locked.
**Source:** `SemanticTokens/ActionTokens.swift`.
