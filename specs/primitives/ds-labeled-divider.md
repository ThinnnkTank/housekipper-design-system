# DsLabeledDivider — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-24)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsLabeledDivider.swift`

## Overview

A section-header divider — dashed line / centered label / dashed line. The label sits with breathing room on both sides so the line doesn't cross through it. Used wherever a block of content needs a labeled boundary above it (SpaceCard rails today; future settings sections, list groupings).

**Composes `DsDivider`**, doesn't re-implement the dashed stroke. The dashed-only-for-dividers rule (`foundations.md → Border`) is preserved: this primitive is still a divider, just one with a label embedded in its midpoint.

**When to use:** section header between or before content blocks where you want both the visual separation (line) and the section title (label) in one element.
**When NOT to use:** plain dashed separators with no label (use `DsDivider(style: .dashed)`). Eyebrow labels that don't need a line (use `Type.Data.xs` + tracking inline).

## Anatomy

```
DsLabeledDivider
└── HStack(spacing: Space.bodyPadding)
    ├── DsDivider(style: style, color: Border.Color.subtle).frame(maxWidth: .infinity)   left segment, flex-grow, ink40 line
    ├── Text(label)
    │   ├── .typeStyle(Type.Data.xs)                                9pt DM Mono Regular
    │   ├── .tracking(HkType.trackingWider)                  +1.8pt
    │   ├── .textCase(.uppercase)
    │   └── .foregroundStyle(TextToken.muted)               ink40 (matches line color)
    └── DsDivider(style: style, color: Border.Color.subtle).frame(maxWidth: .infinity)   right segment, flex-grow, ink40 line
```

The two `DsDivider` segments share remaining horizontal space evenly because both have `maxWidth: .infinity`. The label takes its intrinsic width. `Space.bodyPadding` (16pt) gives breathing room on each side so the line doesn't visually crash into the text.

## Public API

```swift
struct DsLabeledDivider: View {
    let label: String
    var style: DsDivider.Style = .dashed
}
```

Default style is `.dashed` because that's the dominant use case (eyebrow-style section headers). `.solid` is allowed for cases where the section needs harder demarcation.

## States

No interactive states. Render-only.

## SemanticTokens used

`Type.Data.xs` · `HkType.trackingWider` · `TextToken.muted` · `Border.Color.muted` · `Space.bodyPadding`

Plus the tokens `DsDivider` itself consumes (`Border.Width.normal`, `Border.dashPattern`) — but only transitively through the composed primitive. The line color is passed explicitly (`.muted` instead of DsDivider's default `.subtle`) — line and label sit one ink step darker than ordinary dividers because section headers need a touch more presence.

No new tokens introduced.

## Example

```swift
VStack(alignment: .leading, spacing: Space.tight) {
    DsLabeledDivider(label: "ROOMS")
    HStack(spacing: Inventory.railColumnGap) {
        DsKeyButton(label: "Master Bed", icon: IconCatalog.Room.masterBed, action: {})
        DsKeyButton(label: "Kitchen",    icon: IconCatalog.Room.kitchen,    action: {})
    }
}
```

## Cross-references

- Uses: `DsDivider`, `Font`, `HkType`, `TextToken`, `Space`
- Used by: `SpaceCard` Component (section headers for ROOMS / OUTDOOR / SYSTEMS)
- Dashed-line peer: `DsDivider(style: .dashed)` — same dashed pattern, no label

## Decisions log (this spec)

- **Composes `DsDivider` rather than re-stroking dashes** (Luis 2026-05-24): keeps the dashed-only-for-dividers rule honest. The new Primitive is a *labeled* divider; the line segments are still `DsDivider` instances.
- **`Space.bodyPadding` (16pt) gap around label** (Luis 2026-05-24): enough breathing room that the dashed line doesn't visually crash into the uppercase label glyphs. Smaller gaps (tight/hairline) made the label feel hemmed in.
- **Default `.dashed` style** (2026-05-24): dominant use case is eyebrow-style section headers, which are always dashed. Solid available for harder demarcation.
- **Line color `.muted`, label `.secondary`** (Luis 2026-05-24, iter 2): initial draft used `Border.Color.subtle` (ink20) line + `TextToken.muted` (ink40) label. On iPad both read too faint to anchor a section header. Each bumped one step darker — line ink20 → ink40 (new `Border.Color.muted` added to the semantic-token layer), label ink40 → ink60 (`TextToken.secondary`).
- **Label softened back to `.muted` ink40** (Luis 2026-05-25, dashboard vet): with the dashboard's compact tile labels (Type.Label.sm dropped 13→12pt), the ink60 section header dominated the section content. Label now matches the line color (ink40) — both at the same weight, section headers recede into the rhythm rather than competing with tiles.
- **Lines softened ink40 → ink20** (Luis 2026-05-27, cosmetic round 3): plain `DsDivider` defaults to `Border.Color.subtle` (ink20) and is used by Tasks + Calendar; SpaceCard's labeled section dividers (ROOMS / OUTDOOR / SYSTEMS) were reading visibly darker (ink40) than those siblings. Flipped the labeled variant's lines to match — both segments now use `Border.Color.subtle`. Label color stays ink40 (`TextToken.muted`). Affects every consumer of `DsLabeledDivider`; only consumer at the time was SpaceCard.
