# SemanticToken — Status

Severity ladder for **status indicators** (dots, pills, key buttons). Distinct from `ActionToken` (which is for buttons).

| Severity | Tint | Soft fill |
|---|---|---|
| `healthy`   | `ink40` (muted) | — |
| `attention` | `signal` (border or icon color) | — |
| `urgent`    | `signal` (border + spine) | `signalTint` |

**Decision 7 exception:** Urgent **hero cards** (single dominant card on a screen) do NOT get `signalTint` fill — flat signal border only. Avoids softening the alarm.

API:
```swift
StatusToken.tint(.attention)
StatusToken.softFill(.urgent)
```

**Status:** locked.
**Source:** `SemanticTokens/StatusTokens.swift`.
