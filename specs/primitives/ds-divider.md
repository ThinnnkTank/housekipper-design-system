# DsDivider — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-22)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsDivider.swift`

## Overview

Single-line divider for separating content. Two styles: `solid` (default) and `dashed`. The *only* place in the codebase that may produce dashed strokes — audit enforces.

**When to use:** any horizontal or vertical separator between sections, list rows, panels.
**When NOT to use:** SwiftUI's built-in `Divider` is fine for trivial system-default rules, but `DsDivider` is preferred for any user-visible surface where the design system's `Border.Color.subtle` should apply.

## Anatomy

```
DsDivider
└── Path(.horizontal | .vertical)
    .stroke(Border.Color.subtle, lineWidth: Border.Width.normal, [dash: Border.dashPattern])
```

## Public API

```swift
struct DsDivider: View {
    var style: Style = .solid
    var orientation: Orientation = .horizontal
}

enum Style       { case solid, dashed }
enum Orientation { case horizontal, vertical }
```

## SemanticTokens used

- `Border.Color.subtle` (ink20) — color
- `Border.Width.normal` (1pt) — width
- `Border.dashPattern` (`[3, 4]`) — dash array, used **only** when `style == .dashed`

## Example

```swift
// Solid horizontal — default
DsDivider()

// Dashed (for "warmth" dividers between major sections)
DsDivider(style: .dashed)

// Vertical separator
DsDivider(orientation: .vertical)
    .frame(height: SpacingToken.s32)
```

## The rule

**Dashed lines are reserved for dividers.** This Primitive is the sole consumer of `Border.dashPattern`. The audit (`design-sys/audit.sh`) flags any `StrokeStyle(... dash: ...)` outside `DsDivider.swift` as a violation. If a future design needs a dashed stroke for a non-divider purpose, the rule needs to be discussed and the spec updated first.

## Cross-references

- Uses: `Border.Color`, `Border.Width`, `Border.dashPattern`
- Used by: TBD (Components/Patterns)
