# DsButton — Primitive

**Layer:** Primitive
**Status:** spec locked, implementation pending Phase 1a
**Since:** —

## Overview

The button primitive. Carries **visual variants** (primary/secondary/ghost/urgent) and three sizes. Severity language (attention) lives in `DsKeyButton` and status indicators — NOT here.

**When to use:** any tappable action.
**When NOT to use:** room/system tiles (use `DsKeyButton`). Status surfaces (use `DsStatusPill`, TBD).

## Anatomy

```
[Container (rounded corner per Radius.md or Radius.pill)]
  └── Border (variant-driven)
      └── Label · optional leading/trailing icon
```

## SemanticTokens used

- `ActionToken.fill(_:)` / `.border(_:)` / `.foreground(_:)` / `.fillPressed(_:)`
- `Space.bodyPadding` (lg) · `Space.tight` (sm/micro)
- `Radius.md` or `Radius.pill` (configurable)
- `Font.hkButton`
- `HkType.trackingWide`
- `Motion.quick` (press release)

## API

```swift
struct DsButton: View {
    let label: String
    var variant: ActionToken.Variant = .primary
    var size: Size = .large
    var icon: String? = nil          // SF Symbol name
    var iconPosition: IconPosition = .leading
    var isDisabled: Bool = false
    let action: () -> Void
}

enum Size { case large, small, micro }      // heights 44 / 32 / 22
enum IconPosition { case leading, trailing, only }
```

## States

| State | Visual |
|---|---|
| `default`  | Per `ActionToken.fill/border/foreground(variant)` |
| `pressed`  | Per `ActionToken.fillPressed(variant)` — most variants invert |
| `disabled` | `.opacity(ActionToken.disabledOpacity)` (0.38) |

## Example

```swift
DsButton(label: "Mark done", variant: .primary, action: doIt)
DsButton(label: "Cancel", variant: .secondary, size: .small, action: cancel)
DsButton(label: "Stop leak", variant: .urgent, icon: "drop.fill", action: emergency)
```

## Cross-references

- Uses: `ActionToken`, `Space`, `Radius`, `Font`, `Motion`
- Used by: TBD (Components)

## See also

- `ds-key-button.md` — severity-bearing tile primitive
