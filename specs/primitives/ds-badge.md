# DsBadge — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-23)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsBadge.swift`

## Overview

A small circular counter that overlays a tile (key button, nav rail item) to draw attention to actionable items. **Severity drives the content mode:**

- **Attention** → numeric count (informational: "you have N things")
- **Urgent** → `!!` glyph (emotional: pulls focus without listing items — Luis: *"15 triggers procrastination, ! generates interest"*). Two characters intentionally — at 13pt Sans Bold the pair exceeds the circular minDiameter so urgent renders as a slim pill, visually distinct from any single-digit count (which always renders circular).
- **Healthy** → no badge rendered at all

This means DsBadge has only two visual modes, not three. The caller (SpaceCard, NavRail) decides whether to render a badge at all based on severity.

DsBadge is **render-only** — it draws the badge. Positioning (top-right overhang on a tile) is the consumer's responsibility, handled at the Component layer via `.overlay(alignment: .topTrailing)` + the appropriate `Inventory.badgeOverhang{Rect,Pill}` for the tile shape. Keeps the Primitive small and reusable in non-tile contexts.

**Shape is adaptive.** A single `Capsule` is used throughout — when content is a single character (`!` or one digit), the capsule's width equals its height and reads as a circle; with 2+ characters the capsule extends horizontally into a pill. No mode switch needed — geometry handles it.

**When to use:** counter overlay on key tiles, nav rail items, anywhere a "needs your attention" badge is warranted.
**When NOT to use:** status pills with a label (use `DsStatusPill`, TBD). Inline severity icons (use `DsStatusDot`, TBD). Avatar notification dots (use `DsAvatar`'s built-in dot, TBD).

## Anatomy

```
DsBadge
└── Text(content)                                "!!", "3", "12", "99+"
    ├── .font(.hkBadge)                          13pt DM Sans Bold (shared by both modes)
    ├── .foregroundStyle(paper)
    ├── .padding(.horizontal, Inventory.badgePaddingH)  6pt — breathing room; lets capsule extend for multi-char
    ├── .frame(minWidth/minHeight: 20 or 17)     min diameter — single char stays circle
    ├── .background(Capsule().fill(signal))      signal fill (same color, both modes)
    └── .overlay(Capsule().strokeBorder(paper, lineWidth: Inventory.badgeBorderWidth = 2pt))
```

The paper ring is `strokeBorder` (drawn inside the capsule's edge) so it cleanly separates the badge from whatever tile fill sits behind it — works against ink (pressed tile), `signalTint` (urgent tile fill), or paper (rest tile background).

## Public API

```swift
struct DsBadge: View {
    enum Mode {
        case count(Int)   // attention — capped at "99+"
        case urgent       // shows "!!"
    }
    enum Size {
        case regular      // 20pt (Inventory.badgeSize)
        case small        // 17pt (Inventory.badgeSizeSmall)
    }

    let mode: Mode
    var size: Size = .regular
}
```

Argument order at call sites: `mode, [size]`.

**Caller mapping (Component layer):**

```swift
switch severity {
case .healthy:   EmptyView()                            // no badge
case .attention: DsBadge(mode: .count(itemCount))       // even N=0? caller decides
case .urgent:    DsBadge(mode: .urgent)                 // always "!!"
}
```

## States

DsBadge has no interactive states (no press, no disabled). It's a status indicator, not an affordance. Tap handling belongs to the parent tile.

### Count rendering rules

| Input | Renders |
|---|---|
| `.count(0)`     | `"0"` — caller should decide if a zero-count badge is meaningful; the Primitive doesn't hide itself |
| `.count(1..99)` | `"N"` — exact number |
| `.count(100+)`  | `"99+"` — capped |
| `.count(<0)`    | `"0"` — clamped, negative makes no sense for a counter |

### Visual

| Mode | Fill | Ring | Foreground | Glyph |
|---|---|---|---|---|
| `.count(N)` | `signal` | `paper` (2pt) | `paper` | `Font.hkBadge` (13pt DM Sans Bold) |
| `.urgent`   | `signal` | `paper` (2pt) | `paper` | `Font.hkBadge` (13pt DM Sans Bold) |

Both modes share the same capsule (same fill, same ring, same font). Only the glyph string differs. Geometry is content-driven — single character renders as a circle, multi-character extends into a pill.

## SemanticTokens used

`StatusToken.tint(.urgent)` (signal fill — same color for both modes) · `BackgroundToken.primary` (paper ring) · `TextToken.onSignal` (paper foreground) · `Inventory.badgeSize` / `badgeSizeSmall` / `badgeBorderWidth` · `Inventory.badgeOverhangRect` / `badgeOverhangPill` (consumer-side) · `Inventory.badgePaddingH` · `Font.hkBadge`

## Example

```swift
// Attention tile with 3 items
DsKeyButton(label: "Garage", icon: "car", severity: .attention, action: openRoom)
    .overlay(alignment: .topTrailing) {
        DsBadge(mode: .count(3))
            .offset(x: Inventory.badgeOverhangRect, y: -Inventory.badgeOverhangRect)
    }

// Urgent system tile — pill shape uses the tighter overhang so the badge
// visually touches the curved stroke (8pt looks detached on a rounded edge).
DsKeyButton(label: "HVAC", icon: "fan", severity: .urgent, shape: .pill, action: openSystem)
    .overlay(alignment: .topTrailing) {
        DsBadge(mode: .urgent)
            .offset(x: Inventory.badgeOverhangPill, y: -Inventory.badgeOverhangPill)
    }
```

The overlay + offset pattern lives in the **SpaceCard Component** (forthcoming), not at the screen layer. DsBadge itself stays positioning-agnostic.

## Cross-references

- Uses: `StatusToken`, `BackgroundToken`, `TextToken`, `Inventory`, `Font`, `Space`
- Used by: `SpaceCard` Component (tile overlay) · `NavRail` Component (rail item counter)
- Severity peer: `DsKeyButton` carries the border/fill side of the severity ladder; DsBadge carries the counter side

## Open questions

None at draft time — Luis answered the four design questions on 2026-05-23.

## Decisions log (this spec)

- **Severity → mode mapping** (Luis 2026-05-23): urgent = `!!` (revised iter 3 from `!`), attention = number, healthy = no badge.
- **Cap at "99+"** (Luis 2026-05-23).
- **Render-only Primitive** (Luis 2026-05-23): positioning lives in the consumer, not the badge.
- **Same fill for both modes** (Luis 2026-05-23 — implicit in #1): badge color doesn't vary by severity; the glyph carries the difference.
- **Adaptive Capsule shape** (Luis 2026-05-23, iter 2): switch from fixed-diameter Circle to Capsule throughout. Multi-digit content was overflowing the 18pt circle. With Capsule, single-character renders as a circle (width == height) and 2+ characters extend horizontally into a pill. No mode change required — geometry handles it.
- **Font consolidated → `hkBadge`** (Luis 2026-05-23, iter 2): both `.count` and `.urgent` now use DM Sans Bold at 13pt (was 9pt mono for numbers, 12pt sans bold for `!`). Numbers needed the same weight to land on a small surface. One role, both modes.
- **Ring width 1.5pt → 2pt** (Luis 2026-05-23, iter 2): iOS-native badge rings sit visually closer to 2pt than 1.5. Also snaps to existing `Border.Width.strong` (2pt) — same visual weight as the severity border, consistent across the system.
- **Pill-tile overhang** (Luis 2026-05-23, iter 2): rect tiles keep 8pt overhang; pill tiles use 2pt so the badge visually kisses the curved stroke. New `InventoryToken.badgeOverhangPill = 2`. Caller picks based on tile shape.
- **Bigger badges + breathing room** (Luis 2026-05-23, iter 3): `badgeSize` 18 → 20, `badgeSizeSmall` 15 → 17, added `badgePaddingH = 6` (was `Space.hairline` = 4). Numbers needed more room to land. Single-character circles still circular because min diameter grew with the padding.
- **Urgent: `!` → `!!`** (Luis 2026-05-23, iter 3): two characters intentionally exceed the circular minDiameter so urgent renders as a slim pill. Now visually distinct from any single-digit count (which stays circular). Symbolic alert reads stronger doubled.
