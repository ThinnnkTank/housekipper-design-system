# DsButton — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-22)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsButton.swift`

## Overview

The button primitive. Carries **visual variants** (primary/secondary/ghost/urgent) × three sizes (large/small/micro). Severity (attention/urgent) lives in `DsKeyButton` and status indicators — NOT here.

**Press strategy: soften** (see [semantic-tokens.md → Press strategies](../semantic-tokens.md#press-strategies)) — pressed state reuses the disabled-look palette of a related variant. Different from `DsKeyButton`'s `Press.invert`.

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

| Size  | Visible height | Tap area | H-padding | Font | Tracking |
|---|---|---|---|---|---|
| large | 40 (`Space.buttonHeightLg`)    | ≥44 (`Space.tapTarget`) | 16 | `Font.hkButtonLg` — 14pt DM Mono Medium | `trackingLabel` (+0.8) |
| small | 32 (`Space.buttonHeightSm`)    | ≥44 (outer)             | 12 | `Font.hkButtonSm` — 13pt DM Mono Medium | `trackingSnug` (+0.2) |
| micro | 24 (`Space.buttonHeightMicro`) | ≥44 (outer)             | 12 | `Font.hkButtonMicro` — 12pt DM Mono Medium | `trackingMicro` (+0.9) |

Tap area is always ≥44pt via outer `.frame(minHeight: Space.tapTarget)`. Visible button heights stay smaller; outer padding extends the tap region.

## States

Three resolved palettes per variant: rest · disabled · pressed. Driver: `ActionToken.fill/border/foreground(_:)`, `…Disabled(_:)`, `…Pressed(_:)`. Border width is always 1pt (`Border.Width.normal`).

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
| primary   | `ink40`         | clear     | `paper` |
| secondary | `ink05`         | `ink20`   | `ink40` |
| ghost     | clear           | clear     | `ink40` |
| urgent    | `signalMuted`   | clear     | `paper` |

### Pressed (the rule)

**Press feedback reuses the disabled palette of a related variant.** Buttons momentarily "soften" rather than invert dramatically:

- **primary press** → looks like **secondary-disabled** treatment (ink-05 fill, ink-40 border, ink-40 text)
- **secondary press** → looks like **secondary-disabled** treatment (same)
- **ghost press** → looks like **primary-disabled** treatment (ink-40 fill, paper text)
- **urgent press** → looks like **urgent-disabled** treatment (signalTint fill, signalStrong text)

**Asymmetric press feedback:** press is **instant** (no animation), release is animated with `Motion.standard` (220ms ease-out). User expects immediate acknowledgement on touch-down, and the slower release gives the eye time to register that a tap happened.

Implementation:
```swift
.animation(pressed ? nil : Motion.standard, value: pressed)
```

## Letter spacing

Tracking is size-dependent per the sizes table above. Mono labels need breathing room at large; small tightens to `snug` (+0.4); micro goes to `none` (0) since DM Sans Bold clusters naturally.

## Icon weight

Icons render at `IconWeight.action` (`.bold`) regardless of size or surrounding label weight. This keeps stroke width visually constant — without it, the mono Medium labels at large/small would yield thin icons that don't match the bold micro icons.

```swift
Image(systemName: icon).fontWeight(IconWeight.action)
```

## SemanticTokens used

`ActionToken.{fill, border, foreground, fillDisabled, borderDisabled, foregroundDisabled, fillPressed, borderPressed, foregroundPressed}` · `Space.{buttonPaddingLg, buttonPaddingSm, buttonHeightLg, buttonHeightSm, buttonHeightMicro, tapTarget, tight}` · `Radius.md` · `Border.Width.normal` · `Font.{hkButtonLg, hkButtonSm, hkButtonMicro}` · `HkType.trackingLabel` · `Motion.quick`

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
