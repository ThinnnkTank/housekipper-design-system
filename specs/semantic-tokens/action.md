# SemanticToken — Action

Visual variants for `DsButton`. **Not for severity** — that's `StatusToken`.

## Variants

`primary` · `secondary` · `ghost` · `urgent`

## Resolved palettes

Each variant has **three states** — rest, disabled, pressed — and **three properties** — fill, border, foreground. The 12 calls are exposed via:

```swift
ActionToken.fill(_:)               ActionToken.fillDisabled(_:)       ActionToken.fillPressed(_:)
ActionToken.border(_:)             ActionToken.borderDisabled(_:)     ActionToken.borderPressed(_:)
ActionToken.foreground(_:)         ActionToken.foregroundDisabled(_:) ActionToken.foregroundPressed(_:)
```

### Rest

| Variant | Fill | Border | Foreground |
|---|---|---|---|
| primary   | `ink`     | clear  | `paper` |
| secondary | `ink05`   | `ink`  | `ink`   |
| ghost     | clear     | clear  | `ink`   |
| urgent    | `signal`  | clear  | `paper` |

### Disabled

| Variant | Fill | Border | Foreground |
|---|---|---|---|
| primary   | `ink40`        | clear   | `paper`        |
| secondary | `ink05`        | `ink40` | `ink40`        |
| ghost     | clear          | clear   | `ink40`        |
| urgent    | `signalTint`   | clear   | `signalStrong` |

### Pressed — the rule

**Press feedback reuses the disabled palette of a related variant.** This produces a "softening" effect on tap rather than a stark inversion.

| Pressed | Uses palette of |
|---|---|
| `primary`   | `secondary-disabled` |
| `secondary` | `secondary-disabled` |
| `ghost`     | `primary-disabled`   |
| `urgent`    | `urgent-disabled`    |

Implementation: `ActionToken.fillPressed(.primary) → ActionToken.fillDisabled(.secondary)`. The three "Pressed" functions are thin remappers over the disabled palette.

## Why no `border` width here?

Button border width is decided at the Primitive layer. `DsButton` uses `Border.default.width` (1pt) for all variants. ActionToken provides only the *color* of the border.

## Source

`SemanticTokens/ActionTokens.swift`
