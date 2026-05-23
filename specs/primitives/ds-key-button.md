# DsKeyButton — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsKeyButton.swift`

## Overview

The room / outdoor / system tile button. All tiles share the same flex layout (`Inventory.tileMinWidth × tileHeight`). Visual differentiation is **corner shape only**: `.rect` (rooms + outdoor, `Radius.sm` corners) or `.pill` (systems, `Capsule` ends). **Carries the severity ladder** (healthy / attention / urgent) via `StatusToken`.

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
        └── VStack(spacing: Space.tight)
            ├── Icon (SF Symbol)
            │   ├── .font(.hkBody)                   14pt anchor for symbol size
            │   ├── .fontWeight(IconWeight.action)   bold
            │   └── foreground: signal (att/urgent) or ink (healthy) or paper (pressed)
            └── Text(label)
                ├── .font(.hkButton)                 10pt DM Mono Medium
                ├── .tracking(HkType.trackingLabel)  +0.8pt
                ├── .textCase(.uppercase)            ALL CAPS render — preserves original string for VoiceOver
                └── foreground: ink (rest) or paper (pressed)
        Wrapped (uniform layout: flex within Inventory.tileMinWidth × tileHeight, 100×60pt):
        - .rect: RoundedRectangle(Radius.sm = 8pt) — rooms + outdoor
        - .pill: Capsule (fully rounded ends) — systems
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

enum Shape { case rect, pill }
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

Asymmetric animation: instant on press, `Motion.standard` (300ms) on release — same pattern as `DsButton`. Hit area is the full tile shape via `.contentShape(...)` — required because `.healthy` uses a clear fill, which otherwise leaves dead corners (SwiftUI hit-tests rendered pixels only).

## SemanticTokens used

`StatusToken.tint(_:)` / `softFill(_:)` · `TextToken.primary` · `BackgroundToken.primary` · `Border.Width.normal` / `Border.Width.strong` · `Inventory.tileHeight` / `tileMinWidth` · `Space.tight` · `Radius.sm` (rect shape) / `Capsule()` (pill shape) · `Font.hkBody` (icon anchor) · `Font.hkButton` (label) · `HkType.trackingLabel` · `IconWeight.action` · `Motion.standard`

## Example

```swift
// Rectangular room tile, calm default
DsKeyButton(label: "Master Bed", icon: "bed.double", action: openRoom)

// Rectangular outdoor tile, attention
DsKeyButton(label: "Front Lawn", icon: "leaf", severity: .attention, action: openSpace)

// Pill system tile, urgent
DsKeyButton(label: "HVAC", icon: "fan", severity: .urgent, shape: .pill, action: openSystem)
```

## Cross-references

- Uses: `StatusToken`, `TextToken`, `BackgroundToken`, `Border`, `Inventory`, `Space`, `Radius`, `Font`, `HkType`, `IconWeight`, `Motion`
- Used by: `SpaceCard` Component (the Rooms / Outdoor / Systems rail wrapper — TBD next round)
- Press-strategy peer: `DsButton` uses `Press.soften`

**Decision 7 does NOT apply here.** The hero-no-fill exception is reserved for the `NextUpCard` Component. `DsKeyButton.urgent` always gets `signalTint` fill regardless of position or prominence.
