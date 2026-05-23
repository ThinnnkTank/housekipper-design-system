# DsButton — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-22)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsButton.swift`

## Overview

The button primitive. Carries **visual variants** (primary/secondary/ghost/urgent) × three sizes (large/small/micro). Severity (attention/urgent) lives in `DsKeyButton` and status indicators — NOT here.

**When to use:** any tappable action.
**When NOT to use:** room/system tiles (use `DsKeyButton`). Status surfaces (use `DsStatusPill`, TBD).

## Anatomy

```
[Container — Capsule (default) or RoundedRectangle(radius.md)]
  ├── Background (fill per state + variant)
  ├── Border (1pt — visible only when borderColor ≠ .clear)
  └── Label HStack
      ├── leading icon (optional)
      ├── Text label (omitted if iconPosition == .iconOnly)
      └── trailing icon (optional)
```

## Public API

```swift
struct DsButton: View {
    let label: String
    var variant: ActionToken.Variant = .primary
    var size: Size = .large
    var icon: String? = nil               // SF Symbol name
    var iconPosition: IconPosition = .leading
    var shape: ButtonShape = .pill        // default: Capsule
    var isDisabled: Bool = false
    let action: () -> Void
}

enum Size            { case large, small, micro }
enum IconPosition    { case leading, trailing, iconOnly }
enum ButtonShape     { case pill, rounded }
```

## Sizes

| Size  | Visible height | Tap area | Horizontal padding | Font |
|---|---|---|---|---|
| large | 40 (`Space.buttonHeightLg`)    | ≥44 (`Space.tapTarget`) | 16 (`Space.buttonPaddingLg`) | `Font.hkButtonLg` — 13pt DM Mono Medium |
| small | 32 (`Space.buttonHeightSm`)    | ≥44 (outer)             | 12 (`Space.buttonPaddingSm`) | `Font.hkButtonSm` — 12pt DM Mono Medium |
| micro | 24 (`Space.buttonHeightMicro`) | ≥44 (outer)             | 12 (`Space.buttonPaddingSm`) | `Font.hkButtonMicro` — 11pt **DM Sans Bold** |

Tap area is always ≥44pt via outer `.frame(minHeight: Space.tapTarget)`. Visible button can be smaller.

## States

Three resolved palettes per variant: rest · disabled · pressed. Driver: `ActionToken.fill/border/foreground(_:)`, `…Disabled(_:)`, `…Pressed(_:)`. Border width is always 1pt (`Border.default.width`).

### Rest

| Variant | Fill | Border | Foreground |
|---|---|---|---|
| primary   | `ink`     | clear     | `paper` |
| secondary | `ink05`   | `ink`     | `ink`   |
| ghost     | clear     | clear     | `ink`   |
| urgent    | `signal`  | clear     | `paper` |

### Disabled

| Variant | Fill | Border | Foreground |
|---|---|---|---|
| primary   | `ink40`        | clear     | `paper`        |
| secondary | `ink05`        | `ink40`   | `ink40`        |
| ghost     | clear          | clear     | `ink40`        |
| urgent    | `signalTint`   | clear     | `signalStrong` |

### Pressed (the rule)

**Press feedback reuses the disabled palette of a related variant.** Buttons momentarily "soften" rather than invert dramatically:

- **primary press** → looks like **secondary-disabled** treatment (ink-05 fill, ink-40 border, ink-40 text)
- **secondary press** → looks like **secondary-disabled** treatment (same)
- **ghost press** → looks like **primary-disabled** treatment (ink-40 fill, paper text)
- **urgent press** → looks like **urgent-disabled** treatment (signalTint fill, signalStrong text)

State change animated with `Motion.quick` (120ms ease-out).

## Letter spacing

All button labels use `HkType.trackingLabel` (+1.0pt). Tight enough to cluster the bold characters in micro, wide enough for the mono large/small to feel like utility labels.

## SemanticTokens used

`ActionToken.{fill, border, foreground, fillDisabled, borderDisabled, foregroundDisabled, fillPressed, borderPressed, foregroundPressed}` · `Space.{buttonPaddingLg, buttonPaddingSm, buttonHeightLg, buttonHeightSm, buttonHeightMicro, tapTarget, tight}` · `Radius.md` · `Border.default.width` · `Font.{hkButtonLg, hkButtonSm, hkButtonMicro}` · `HkType.trackingLabel` · `Motion.quick`

## Example

```swift
// Default — primary, large, pill, leading icon
DsButton(label: "Mark done", icon: "checkmark", action: doIt)

// Secondary with trailing chevron
DsButton(label: "View all", variant: .secondary, icon: "chevron.down", iconPosition: .trailing, action: openList)

// Micro icon-only urgent
DsButton(label: "Alarm", variant: .urgent, size: .micro, icon: "bell.fill", iconPosition: .iconOnly, action: alarm)

// Disabled
DsButton(label: "Submit", isDisabled: true, action: submit)
```

## Cross-references

- Uses: `ActionToken`, `Space`, `Radius`, `Border`, `Font`, `HkType`, `Motion`
- Used by: TBD (Components)

## See also

- `ds-key-button.md` — severity-bearing tile primitive (different model)
- `semantic-tokens/action.md` — the variant palette
