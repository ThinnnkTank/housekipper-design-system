# DsProgressBar — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsProgressBar.swift`

## Overview

Thin horizontal bar showing completion progress. Filling (0% = just started, 100% = done) — used for tracking projects and multi-step tasks. **Not** a time-until-due countdown; the metaphor here is "where am I in this thing," which suits real-world ADHD project reality where a kitchen reno can sit at 50% for weeks waiting on a permit or a contractor.

**Color rule:** ink track (subtle) + ink fill. No severity coloring — the bar stays quiet. Severity belongs to the parent card's border or to a `DsBadge`/`DsStatusDot` alongside the bar. The progress glyph itself reads as metadata, not alarm.

**When to use:** project completion on a card · multi-step task progress · checklist completion ratio.
**When NOT to use:** time-until-deadline (TBD — possibly a different Primitive). Loading/activity (use `ProgressView()` system spinner). Severity indication (use `DsBadge` / `DsStatusDot`).

## Anatomy

```
DsProgressBar
└── ZStack (alignment: leading)
    ├── Capsule (track)
    │   └── .fill(TextToken.faint)                       ink20 — quiet empty state
    └── Capsule (fill)
        └── .fill(TextToken.primary)                     ink — completed portion
        Width: full width × clamp(progress, 0...1)
    Frame height: 6pt (primitive-internal constant)
```

Both layers are full-width `Capsule()`; the fill layer's width is clamped progress × container width. GeometryReader handles the responsive width — no fixed bar width.

**Why 6pt?** Thick enough to read as a real bar, thin enough to feel like metadata. Sits cleanly under a `Font.hkCardHeadline` (22pt) without competing. Same proportional logic as DsStatusDot: stroke/bar weight matches the surface it sits on.

6pt is primitive-internal; lives as `private static let barHeight: CGFloat = 6` inside the .swift file. Snapping-rule carve-out per `foundations.md` → Spacing → Rules.

## Public API

```swift
struct DsProgressBar: View {
    let progress: Double   // 0.0 ... 1.0 (clamped internally)
}
```

Argument order: `progress`. No defaults — the bar exists to show a value, caller must pass it.

**Clamping:** out-of-range input is clamped to `[0, 1]`. Negative → 0. >1 → 1. The Primitive never throws.

## States

DsProgressBar has no interactive states. It's a render of a value. Updates animate via the caller's `withAnimation { ... }` if desired — the Primitive doesn't impose a default animation.

## SemanticTokens used

`TextToken.faint` (ink20 track) · `TextToken.primary` (ink fill) · `Radius.pill` (implicit via `Capsule()`)

No new tokens introduced.

## Example

```swift
// NextUpCard body
VStack(alignment: .leading, spacing: Space.tight) {
    Text("Kitchen reno")
        .font(.hkCardHeadline)
    DsProgressBar(progress: 0.5)
    Text("Waiting on permit")
        .font(.hkData)
        .foregroundStyle(TextToken.muted)
}
```

## Cross-references

- Uses: `TextToken`
- Used by: `NextUpCard` Component (TBD), `ActiveProjectCard` Component (TBD)
- Severity peers: none — DsProgressBar is intentionally severity-free; the parent card carries severity if needed

## Decisions log (this spec)

- **Filling, not depleting** (Luis 2026-05-23): the bar fills as work completes. Use case is projects that can stall (50% for weeks while waiting on a contractor), not deadline countdowns. Depleting interpretation would create false alarm during legitimate pauses.
- **Always ink, no severity coupling** (Luis 2026-05-23): keeps the bar as quiet metadata. Severity (urgent / overdue / etc.) is carried by the parent card border or alongside as a `DsBadge` / `DsStatusDot` — not by recoloring the bar.
- **6pt height, capsule ends** (Luis 2026-05-23): bar reads as proper progress without dominating a card. Rounded ends match the rest of the system's pill vocabulary (DsBadge multi-char, DsKeyButton pill systems).
