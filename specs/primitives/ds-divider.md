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
    .stroke(color, lineWidth: Border.Width.normal, [dash: Border.dashPattern])
```

The stroke color is parameterized. Default is `Border.Color.subtle` (ink20). Callers can pass any `Border.Color.*` for stronger presence — `DsLabeledDivider` uses `.muted` (ink40) for its line segments.

## Public API

```swift
struct DsDivider: View {
    var style: Style = .solid
    var orientation: Orientation = .horizontal
    var color: SwiftUI.Color = Border.Color.subtle
}

enum Style       { case solid, dashed }
enum Orientation { case horizontal, vertical }
```

## SemanticTokens used

- `Border.Color.subtle` (ink20) — default color
- `Border.Color.muted` / `.normal` / `.strong` — alternates available via the `color` parameter
- `Border.Width.normal` (1pt) — width
- `Border.dashPattern` (`[3, 4]`) — dash array, used **only** when `style == .dashed`

## Example

```swift
// Solid horizontal — default (ink20 line)
DsDivider()

// Dashed at default subtle color
DsDivider(style: .dashed)

// Darker line for section-header use cases (composed by DsLabeledDivider)
DsDivider(style: .dashed, color: Border.Color.muted)

// Vertical separator
DsDivider(orientation: .vertical)
    .frame(height: SpacingToken.s32)
```

## The rule

**Dashed lines are reserved for dividers.** This Primitive is the sole consumer of `Border.dashPattern`. The audit (`design-sys/audit.sh`) flags any `StrokeStyle(... dash: ...)` outside `DsDivider.swift` as a violation. If a future design needs a dashed stroke for a non-divider purpose, the rule needs to be discussed and the spec updated first.

## Cross-references

- Uses: `Border.Color`, `Border.Width`, `Border.dashPattern`
- Used by: `DsLabeledDivider` (composes two `DsDivider(.dashed, color: .muted)` segments around a centered label) · `SpaceCard` swatch panel (solid horizontal rule under the rail controls)

## Decisions log (this spec)

- **`color` parameter added (Luis 2026-05-24).** Initially the stroke color was hardcoded to `Border.Color.subtle`. When `DsLabeledDivider` shipped, its line segments needed `Border.Color.muted` (ink40) for more presence as section-header chrome. Parameterizing kept DsDivider as the sole owner of dashed strokes (the foundations rule) while letting consumers pick how loud the line reads. Default stays `.subtle` — no breaking change to existing callers.
