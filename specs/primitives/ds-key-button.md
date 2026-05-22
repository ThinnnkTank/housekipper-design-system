# DsKeyButton — Primitive

**Layer:** Primitive
**Status:** spec locked, implementation pending Phase 1a
**Since:** —

## Overview

The room / system / category tile button. Square (128×56) or circular (68×68). Composes label + icon + optional badge counter. **Carries the severity ladder** (healthy / attention / urgent) via `StatusToken`.

Distinct from `DsButton`:
- `DsButton` = action affordance, visual variants
- `DsKeyButton` = persistent tile carrying state, severity-driven

## Anatomy

```
[Container (rounded — square or circle)]
  └── Border (severity-driven via StatusToken)
      └── Icon (top)
      └── Label (bottom)
      └── Optional badge counter (top-right, signal-filled)
```

## SemanticTokens used

- `StatusToken.tint(severity)` (border color)
- `StatusToken.softFill(severity)` (background; `.clear` for healthy/attention, `signalTint` for urgent — except hero exception)
- `Border.affordance.width` (2pt borders, signal for attention/urgent)
- `Space.tight`, `Space.bodyPadding`
- `Radius.md` (square variant) or implicit `Capsule()` (circle)
- `Font.hkCaption` (label)
- `Motion.quick` (press)

## API

```swift
struct DsKeyButton: View {
    let label: String
    let icon: String                      // SF Symbol name
    var severity: StatusToken.Severity = .healthy
    var shape: Shape = .square
    var badgeCount: Int? = nil
    var isHero: Bool = false              // suppresses signalTint for urgent hero
    let action: () -> Void
}

enum Shape { case square, circle }
```

## States

| Severity | Border | Fill | Notes |
|---|---|---|---|
| `healthy`   | `ink` 1px       | — | Calm default |
| `attention` | `signal` 2px    | — | Asks for a look |
| `urgent`    | `signal` 2px    | `signalTint` | Demands action |
| `urgent + isHero` | `signal` 2px | — | **Decision 7**: hero cards skip the tint |

## Example

```swift
DsKeyButton(label: "Kitchen", icon: "fork.knife", action: openKitchen)
DsKeyButton(label: "Filter due", icon: "drop.degreesign", severity: .attention, action: openFilters)
DsKeyButton(label: "Water leak", icon: "drop.fill", severity: .urgent, badgeCount: 1, action: openLeak)
```

## Cross-references

- Uses: `StatusToken`, `Border`, `Space`, `Radius`, `Font`, `Motion`
- Used by: `RoomGrid` (Component, TBD), `SystemGrid` (Component, TBD)
