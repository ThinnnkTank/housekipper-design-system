# DsProgressBar — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-24)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsProgressBar.swift`

## Overview

Thin horizontal LCD/LED-style segmented bar showing completion progress. Filling (0% = just started, 100% = done) — used for tracking projects and multi-step tasks. **Not** a time-until-due countdown; the metaphor here is "where am I in this thing," which suits real-world ADHD project reality where a kitchen reno can sit at 50% for weeks waiting on a permit or a contractor.

**Aesthetic:** discrete vertical segments evoke vintage LED bar displays — matches the paprLCD aesthetic family. Lit segments are ink; unlit cells are ink20 (visible as quiet housing). Smooth capsule fill was the iter 1 implementation; iter 2 moved to segmented to land the LCD feel.

**Color rule:** ink lit segments + ink20 unlit segments. No severity coloring — the bar stays quiet. Severity belongs to the parent card's border or to a `DsBadge`/`DsStatusDot` alongside the bar. The progress glyph itself reads as metadata, not alarm.

**When to use:** project completion on a card · multi-step task progress · checklist completion ratio.
**When NOT to use:** time-until-deadline (TBD — possibly a different Primitive). Loading/activity (use `ProgressView()` system spinner). Severity indication (use `DsBadge` / `DsStatusDot`).

## Anatomy

```
DsProgressBar
└── GeometryReader
    └── HStack(spacing: 1pt)
        └── ForEach(0..<count) → Rectangle
            ├── i <  filledCount → .fill(TextToken.primary)   ink — lit cell
            └── i >= filledCount → .fill(TextToken.faint)     ink20 — unlit cell (visible dashy housing)
            Frame: 3pt × 8pt (segmentWidth × barHeight)
```

- `count = floor(containerWidth / 4pt)` — `4pt` is segment + gap period
- `filledCount = round(count × clamp(progress, 0…1))`
- All three micros (`barHeight 8`, `segmentWidth 3`, `segmentGap 1`) are `private static let`s inside the Swift file — primitive-internal per the snapping-rule carve-out (`foundations.md` → Spacing → Rules).

**Both sides render as cells.** Lit cells are ink, unlit cells are ink20 — same geometry, only color differs. The unlit row reads as faint dashes (the LCD housing/cells before they light up), giving the bar a complete LED-strip identity end-to-end. Important: this is not a `StrokeStyle(dash:)` — it's a row of small Rectangles. Dashed strokes are reserved exclusively for `DsDivider` per `foundations.md` → Border → Rules; that rule remains intact.

**Why these values?**

- **8pt height** — strong enough to register as an LED strip, still thin enough to read as metadata under `Type.Title.lg`.
- **3pt × 8pt segment aspect** — taller than wide, reads as a vertical LED cell.
- **1pt gap** — separates cells distinctly without breaking the bar into too-busy ladder rungs. With 3pt segments, the 4pt period gives ~25 cells per 100pt of bar width.
- **Square interior cells, rounded endcaps** — the whole HStack is clipped to a `Capsule()`, which shaves only the outermost left/right corners of the bar. Leftmost lit cell and rightmost unlit cell get half-pill outer edges; everything between stays square. Reads as an LED strip housed in a rounded chassis.

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

`TextToken.faint` (ink20 unlit cells) · `TextToken.primary` (ink lit cells) · `Motion.standard` (cell-fill animation)

No new tokens introduced.

## Example

```swift
// NextUpCard body
VStack(alignment: .leading, spacing: Space.tight) {
    Text("Kitchen reno")
        .typeStyle(Type.Title.lg)
    DsProgressBar(progress: 0.5)
    Text("Waiting on permit")
        .typeStyle(Type.Data.sm)
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
- **6pt height, capsule ends** (Luis 2026-05-23, iter 1): smooth capsule fill with paper2 track. Replaced in iter 2 — see next.
- **LCD segmented rendering** (Luis 2026-05-24, iter 2): swapped the smooth capsule fill for an LED-style row of vertical cells. 3pt segments, 2pt gaps, square corners. Lit cells = ink, unlit = ink20. Both sides were rendered as discrete cells. Matches the paprLCD aesthetic family — the "LCD" in the brand isn't decorative. Animation transitions cells via `Motion.standard`, fading at threshold crossings instead of width-tweening.
- **Hybrid: lit cells + solid unlit bar** (Luis 2026-05-24, iter 3): cell gap reduced 2pt → 1pt for tighter LED rhythm. Unlit portion changed from individual cells to one continuous `ink20` rectangle. Was a fork in the road — iter 4 chose differently.
- **Cells on both sides, taller bar** (Luis 2026-05-24, iter 4): unlit portion goes back to cell-by-cell rendering — the "dashes" effect, matching the LED strip identity end-to-end. Bar height 6pt → 8pt for more presence. NOT implemented as a dashed `StrokeStyle` — that's reserved for `DsDivider` per foundations. It's just a row of small Rectangles with `ink20` fill, which visually reads as dashes.
- **Rounded endcaps via Capsule clip** (Luis 2026-05-24, iter 5): outer ends of the bar shaved to a capsule arc. Leftmost + rightmost cells get half-pill outer edges; interior cells remain square. Reads as an LED strip housed in a rounded chassis. Implemented as `.clipShape(Capsule())` on the HStack — no per-cell rounding, no shape-by-position branching.
