# SignalButton — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-25)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/SignalButton.swift`

## Overview

The one orange CTA. A Dieter Rams "signal button" — reserved for the single highest-emphasis action on a screen. Visually it is `DsButton(.urgent, .large)` chrome with **+12pt extra horizontal padding on each side** to give it special status against adjacent primary/secondary buttons.

**Press strategy: invert** (see [semantic-tokens.md → Press strategies](../semantic-tokens.md#press-strategies)) — signal → ink fill, paper foreground.

**When to use:** the singular screen-level "do the thing" action (e.g. dashboard `+ ADD`).
**When NOT to use:** any non-signal action — that's `DsButton`. Urgent affordances inside a card (those stay `DsButton.urgent` without the extra padding). If a screen reaches for *two* signal buttons, the design is wrong — reconsider before duplicating.

**Considered alternative (rejected):** a `DsButton.signal` style or `.emphasized` size variant. The dedicated Primitive was chosen so call sites read `SignalButton(...)` — the intent is part of the type name, not buried in a parameter. Trade-off: one more file; same `ActionToken.urgent` palette, no token duplication.

## Anatomy

```
[Container — Capsule]
  ├── Background (signal fill, rest)
  ├── Border (1pt — clear at rest, ink on press)
  └── Label HStack
      ├── leading icon (optional)
      ├── Text label (omitted if iconPosition == .iconOnly)
      └── trailing icon (optional)
```

## Public API

```swift
struct SignalButton: View {
    let label: String
    var icon: String? = nil               // SF Symbol name
    var iconPosition: IconPosition = .leading
    var isDisabled: Bool = false
    let action: () -> Void
}

enum IconPosition { case leading, trailing, iconOnly }
```

## Dimensions

| Property | Value | Source |
|---|---|---|
| Visible height | 40pt | `Space.buttonHeightLg` |
| Tap area | ≥44pt | `Space.tapTarget` (outer `.frame(minHeight:)`) |
| H-padding (each side) | 32pt | `Space.buttonPaddingLg` (20) + 12pt extra |
| Font | `Type.Label.lg` (14pt DM Mono Medium, trackingLabel, uppercase) |  |
| Corner | Capsule | — |

The +12pt extra padding is a primitive-internal carve-out (foundations.md primitive-interior rule). Documented here rather than promoted to a token because it exists for exactly one purpose: SignalButton's special status.

## States

Reuses `ActionToken.urgent` palette — same source-of-truth as `DsButton(.urgent)`.

| State | Fill | Border | Foreground |
|---|---|---|---|
| Rest      | `signal`        | clear     | `paper` |
| Pressed   | `ink`           | `ink`     | `paper` |
| Disabled  | `signalMuted`   | clear     | `paper` |

Animation: asymmetric press feedback — instant on press (nil animation), `Motion.standard` (220ms ease-out) on release.

## SemanticTokens used

- `ActionToken.urgent` palette (fill / border / foreground × rest/pressed/disabled)
- `Type.Label.lg`
- `Space.buttonPaddingLg` (base), `Space.buttonHeightLg`, `Space.tapTarget`
- `Border.Width.normal`
- `Motion.standard`

## Example

```swift
SignalButton(
    label: "ADD",
    icon: IconCatalog.Action.add,
    action: { /* open + ADD popover */ }
)
```

## Decisions log

- **2026-05-25 — Promoted to dedicated Primitive (vs `DsButton.signal` variant).** Luis: "make the Add button a new class. this new class is SignalButton. its orange just like the urgent, its basically an urgent by with extra padding L and R 12 each saide, to give it a spoecial status as that dieter rams signal button." Designer surfaced the variant-vs-class trade-off; Luis confirmed dedicated class. The name is part of the contract — one SignalButton per screen.

## Cross-references

- `DsButton` — every other action affordance
- `ActionToken.urgent` — palette source
- TopBar `+ ADD` — current sole consumer
