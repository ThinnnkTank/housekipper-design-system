# DsKeyButton — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsKeyButton.swift`

## Overview

The room / outdoor / system tile button. Rectangular (rooms + outdoor) or circular (systems). **Carries the severity ladder** (healthy / attention / urgent) via `StatusToken`.

**Press strategy: invert** (see [semantic-tokens.md → Press strategies](../semantic-tokens.md#press-strategies)) — pressed state inverts background to `TextToken.primary` (ink) and foreground to `BackgroundToken.primary` (paper). Different from `DsButton`'s `Press.soften`.

Distinct from `DsButton`:
- `DsButton` = action affordance, visual variants, soften press
- `DsKeyButton` = persistent tile carrying state, severity-driven, invert press

**When to use:** rooms grid, outdoor grid, systems grid (the dashboard's `SpaceCard`).
**When NOT to use:** action affordances (use `DsButton`). Inline list rows (use `MaintenanceRow`, TBD). Status pills (use `DsStatusPill`, TBD).

## Anatomy

```
DsKeyButton
└── Button (placeholder label — visual built inside ButtonStyle)
    └── DsKeyButtonStyleImpl (computes palette per severity + pressed)
        └── VStack
            ├── Icon (SF Symbol, IconWeight.action, foreground per severity)
            └── Text (Font.hkButtonMicro, foreground inherited/ink)
        Wrapped in:
        - .rect: RoundedRectangle(Radius.md), flex width within Inventory.tileMinWidthRect/Height
        - .circle: Circle, fixed Inventory.tileCircleSize inside tileCircleWrapper for tap area
```

## Public API

```swift
struct DsKeyButton: View {
    let label: String
    let icon: String                              // SF Symbol name
    var severity: StatusToken.Severity = .healthy
    var shape: Shape = .rect
    let action: () -> Void
}

enum Shape { case rect, circle }
```

Argument order at call sites must be: `label, icon, [severity], [shape], action`.

## States

Resolved palettes: rest × severity, plus pressed (overrides severity).

### Rest

| Severity | Fill | Border | Icon | Label | Border width |
|---|---|---|---|---|---|
| `healthy`   | clear | `ink` | `ink` | `ink` | 1pt (`Border.Width.normal`) |
| `attention` | clear | `signal` | `signal` | `ink` | 2pt (`Border.Width.strong`) |
| `urgent`    | `signalTint` | `signal` | `signal` | `ink` | 2pt |

Note: in attention and urgent the **icon goes signal-colored** while the **label stays ink**. The badge (when wired in via `DsBadge`, separate Primitive) carries the numeric/`!` counter.

### Pressed (overrides severity)

Per the **invert** strategy:

| Property | Color |
|---|---|
| Fill   | `TextToken.primary` (ink) |
| Border | `TextToken.primary` (ink) |
| Icon   | `BackgroundToken.primary` (paper) |
| Label  | `BackgroundToken.primary` (paper) |

Asymmetric animation: instant on press, `Motion.standard` (220ms) on release — same pattern as `DsButton`.

## SemanticTokens used

`StatusToken.tint(_:)` / `softFill(_:)` · `TextToken.primary` · `BackgroundToken.primary` · `Border.Width.normal` / `Border.Width.strong` · `Inventory.tileHeightRect` / `tileMinWidthRect` / `tileCircleSize` / `tileCircleWrapper` · `Space.tight` · `Radius.md` · `Font.hkButtonMicro` · `HkType.trackingMicro` · `IconWeight.action` · `Motion.standard`

## Example

```swift
// Rectangular room tile, calm default
DsKeyButton(label: "Master Bed", icon: "bed.double", action: openRoom)

// Rectangular outdoor tile, attention
DsKeyButton(label: "Front Lawn", icon: "leaf", severity: .attention, action: openSpace)

// Circular system tile, urgent
DsKeyButton(label: "HVAC", icon: "fan", severity: .urgent, shape: .circle, action: openSystem)
```

## Cross-references

- Uses: `StatusToken`, `TextToken`, `BackgroundToken`, `Border`, `Inventory`, `Space`, `Radius`, `Font`, `HkType`, `IconWeight`, `Motion`
- Used by: `SpaceCard` Component (the Rooms / Outdoor / Systems rail wrapper — TBD next round)
- Press-strategy peer: `DsButton` uses `Press.soften`

**Decision 7 does NOT apply here.** The hero-no-fill exception is reserved for the `NextUpCard` Component. `DsKeyButton.urgent` always gets `signalTint` fill regardless of position or prominence.
