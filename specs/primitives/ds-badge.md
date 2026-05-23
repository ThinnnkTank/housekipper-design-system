# DsBadge — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsBadge.swift`

## Overview

A small circular counter that overlays a tile (key button, nav rail item) to draw attention to actionable items. **Severity drives the content mode:**

- **Attention** → numeric count (informational: "you have N things")
- **Urgent** → single `!` glyph (emotional: pulls focus without listing items — Luis: *"15 triggers procrastination, ! generates interest"*)
- **Healthy** → no badge rendered at all

This means DsBadge has only two visual modes, not three. The caller (SpaceCard, NavRail) decides whether to render a badge at all based on severity.

DsBadge is **render-only** — it draws the circle. Positioning (top-right overhang on a tile) is the consumer's responsibility, handled at the Component layer via `.overlay(alignment: .topTrailing)` + `InventoryToken.badgeOverhang`. Keeps the Primitive small and reusable in non-tile contexts.

**When to use:** counter overlay on key tiles, nav rail items, anywhere a "needs your attention" badge is warranted.
**When NOT to use:** status pills with a label (use `DsStatusPill`, TBD). Inline severity icons (use `DsStatusDot`, TBD). Avatar notification dots (use `DsAvatar`'s built-in dot, TBD).

## Anatomy

```
DsBadge
└── ZStack
    ├── Circle (fill: signal)
    ├── Circle (strokeBorder: paper, lineWidth: Inventory.badgeBorderWidth = 1.5pt)
    └── content (centered)
        ├── .count(N) → Text("\(N)" or "99+")
        │   ├── .font(.hkCaption)               9pt DM Mono
        │   ├── .tracking(HkType.trackingNone)  tight — needs room for "99+"
        │   └── foregroundStyle: paper
        └── .urgent → Text("!")
            ├── .font(.hkBadgeUrgent)           NEW role — DM Sans Bold 12pt
            └── foregroundStyle: paper
        Frame: Inventory.badgeSize (18pt) or badgeSizeSmall (15pt)
```

The paper ring is `strokeBorder` (drawn inside the circle's edge) so it cleanly separates the badge from whatever tile fill sits behind it — works against ink (pressed tile), `signalTint` (urgent tile fill), or paper (rest tile background).

## Public API

```swift
struct DsBadge: View {
    enum Mode {
        case count(Int)   // attention — capped at "99+"
        case urgent       // shows "!"
    }
    enum Size {
        case regular      // 18pt (Inventory.badgeSize)
        case small        // 15pt (Inventory.badgeSizeSmall)
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
case .urgent:    DsBadge(mode: .urgent)                 // always "!"
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
| `.count(N)` | `signal` | `paper` (1.5pt) | `paper` | `Font.hkCaption` (9pt mono) |
| `.urgent`   | `signal` | `paper` (1.5pt) | `paper` | `Font.hkBadgeUrgent` (12pt sans bold) — **new role** |

Both modes share the same circle (same fill, same ring, same size). Only the glyph differs.

## SemanticTokens used

`StatusToken.tint(.urgent)` (signal fill — same color for both modes) · `BackgroundToken.primary` (paper ring) · `TextToken.onSignal` (paper foreground) · `Inventory.badgeSize` / `badgeSizeSmall` / `badgeBorderWidth` · `Font.hkCaption` · `Font.hkBadgeUrgent` (new) · `HkType.trackingNone`

## New tokens required

**🔴 Surface for sign-off before implementation:**

1. **`Font.hkBadgeUrgent`** — new semantic font role. DM Sans Bold at 12pt (uses existing `Face.sansBold` already registered, and existing size step `12`). Reason: DM Mono ships no Bold, and the `!` needs visual weight to deliver the emotional pull Luis described. Caption-sized mono `!` reads as a typo, not an alert.

   *Pattern context:* this isn't a face-swap exception — it's a new role for a new context. Symmetric with `hkButtonMicro` precedent (where we explicitly stayed in mono). Here the role is "alert glyph" and Sans Bold serves that intent.

2. **`HkType.trackingNone`** — exposes `0` letter spacing as a named token. Needed because "99+" mono at 9pt with the default `trackingLabel` (+0.8) overflows the 18pt circle. Will likely already exist or be trivial to add; flagging for completeness.

If either is rejected, fallback for (1) is `Font.hkButtonMicro` (DM Mono Medium 10pt) and we accept a quieter `!`. Fallback for (2) is to use `Font.hkCaption` and accept potential overflow at 99+ — verify on iPad.

## Example

```swift
// Attention tile with 3 items
DsKeyButton(label: "Garage", icon: "car", severity: .attention, action: openRoom)
    .overlay(alignment: .topTrailing) {
        DsBadge(mode: .count(3))
            .offset(x: Inventory.badgeOverhang, y: -Inventory.badgeOverhang)
    }

// Urgent system tile
DsKeyButton(label: "HVAC", icon: "fan", severity: .urgent, shape: .pill, action: openSystem)
    .overlay(alignment: .topTrailing) {
        DsBadge(mode: .urgent)
            .offset(x: Inventory.badgeOverhang, y: -Inventory.badgeOverhang)
    }
```

The overlay + offset pattern lives in the **SpaceCard Component** (forthcoming), not at the screen layer. DsBadge itself stays positioning-agnostic.

## Cross-references

- Uses: `StatusToken`, `BackgroundToken`, `TextToken`, `Inventory`, `Font`, `HkType`
- Used by: `SpaceCard` Component (tile overlay) · `NavRail` Component (rail item counter)
- Severity peer: `DsKeyButton` carries the border/fill side of the severity ladder; DsBadge carries the counter side

## Open questions

None at draft time — Luis answered the four design questions on 2026-05-23.

## Decisions log (this spec)

- **Severity → mode mapping** (Luis 2026-05-23): urgent = `!`, attention = number, healthy = no badge.
- **Cap at "99+"** (Luis 2026-05-23).
- **Render-only Primitive** (Luis 2026-05-23): positioning lives in the consumer, not the badge.
- **Same fill for both modes** (Luis 2026-05-23 — implicit in #1): badge color doesn't vary by severity; the glyph carries the difference.
