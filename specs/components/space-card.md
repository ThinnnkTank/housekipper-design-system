# SpaceCard — Component

**Layer:** Component
**Status:** ✅ Locked (2026-05-27 — vertical padding aligned with dashboard grid)
**Implementation:** `houseKipper/houseKipper/Components/SpaceCard.swift`

## 2026-05-27 update — vertical padding

Vertical padding: `.padding(.vertical, snug)` (12/12) → `.padding(.top, bodyPadding) + .padding(.bottom, safeGutter)` (16/24). The 16pt top adds breathing above the first "ROOMS" divider AND pushes the card bottom into alignment with the Tasks card's bottom (right column). L/R padding unchanged at 8pt (`tight`).

## Overview

The dashboard's inventory surface. Composes three rails — **Rooms**, **Outdoor**, **Systems** — into a single card with eyebrow labels and dashed section dividers. Each rail has a distinct layout algorithm:

| Rail | Layout | Tile shape |
|---|---|---|
| Rooms | Z-pattern, 2 rows | `.rect` (Radius.sm) |
| Outdoor | Single row, flex | `.rect` (Radius.sm) |
| Systems | Single row, flex | `.pill` (Capsule) |

Tiles are `DsKeyButton`s with optional `DsBadge` overlays. All severity ordering, badge derivation, and empty-state handling lives inside SpaceCard — callers just hand over arrays of `SpaceItem` and an `onTap` callback.

**When to use:** dashboard inventory section. Currently the only consumer.
**When NOT to use:** non-inventory lists of items (use `MaintenanceList`, TBD). Single-rail surfaces that don't need section structure (compose `DsKeyButton`s directly).

## Anatomy

```
SpaceCard
└── VStack(spacing: Space.sectionGap)
    ├── (ROOMS section, if rooms.isEmpty == false)
    │   ├── DsLabeledDivider("ROOMS")         dashed line / label / dashed line
    │   └── ZPatternRail (rooms, sorted by severity, shape: .rect)
    ├── (OUTDOOR section, if !outdoor.isEmpty)
    │   ├── DsLabeledDivider("OUTDOOR")
    │   └── SingleRowRail (outdoor, sorted by severity, shape: .rect)
    └── (SYSTEMS section, if !systems.isEmpty)
        ├── DsLabeledDivider("SYSTEMS")
        └── SingleRowRail (systems, sorted by severity, shape: .pill)
```

### Section header

Each non-empty section starts with a `DsLabeledDivider` carrying the section's eyebrow label. The labeled divider IS the section separator — no standalone `DsDivider` between sections, because the next section's `DsLabeledDivider` provides the visual break. Empty sections omit both the labeled divider and the rail.

The labeled-divider styling (`hkCaption` + `trackingWider` + `muted` ink40 + uppercase) is owned by `DsLabeledDivider` — SpaceCard just passes the label string.

### Flex-or-scroll layout

Both the Z-pattern and single-row rails use `ViewThatFits(in: .horizontal)` with two child layouts:

1. **Flex (preferred):** plain HStack/VStack with no ScrollView. The HStack inherits the rail container's width, and each tile's `maxWidth: .infinity` causes tiles to spread evenly to fill that width. This matches the Primitives panel behavior — one pill fills the row, two split, three split into thirds, etc.
2. **Scroll (fallback):** same content wrapped in `ScrollView(.horizontal)` with `.scrollIndicators(.hidden)` and `.scrollClipDisabled()`. Used only when the natural HStack content exceeds the container width (sum of tile min-widths + gaps > available space).

`ViewThatFits` picks the first child that satisfies the proposed dimensions. With this structure, layout behavior is:

- 1 tile → tile fills the full rail width (flex)
- 2-N tiles where N × `Inventory.tileMinWidth` + (N-1) × `Inventory.railColumnGap` ≤ rail width → tiles split the width evenly (flex)
- Beyond that → horizontal scroll engages, tiles at `Inventory.tileMinWidth`

`.scrollClipDisabled()` is critical: without it, the `DsBadge` overlay (8pt overhang past the tile edge) gets clipped by the ScrollView's content bounds. With it, badges render past the rail's natural bounds and stay visible.

### Z-pattern rail (Rooms)

Algorithm: sort items by severity (urgent → attention → healthy, preserving original order within a severity), then split by index parity. Even indices (0, 2, 4, …) go to row 1; odd indices (1, 3, 5, …) go to row 2. Reading order across the two rows traces a Z pattern, surfacing the most severe items in the top row first.

**Column alignment with odd counts.** When the total item count is odd, row 1 has one more tile than row 2. Both rows render with the SAME number of flex slots (= row 1's count); row 2's missing trailing slot renders as a transparent placeholder with identical flex behavior to a real tile. This preserves column alignment — a tile in row 2 sits directly below its corresponding row 1 column, never at a misaligned half-step. Matches the original paprLCD reference.

```
sorted: [urgent A, urgent B, attention C, healthy D, healthy E, healthy F]
                      →
Row 1:  [A]  [C]  [E]
Row 2:  [B]  [D]  [F]
```

Tiles use `DsKeyButton(shape: .rect)`. Horizontal scroll engages when the row width exceeds container width — handled natively by SwiftUI `ScrollView(.horizontal)`. Per the dashboard spec, ~12 items fit at iPad portrait width without scroll (6 columns × 2 rows); 13+ items engages scroll.

### Single-row rail (Outdoor + Systems)

Tiles flow horizontally in a single row, each with `DsKeyButton`'s built-in flex behavior (`maxWidth: .infinity, minWidth: Inventory.tileMinWidth`). When the row's combined width exceeds the container, horizontal scroll engages. Outdoor uses `.rect`; Systems uses `.pill`.

### Badges

Badge derivation is automatic from `SpaceStatus`:

| Status | Badge rendered |
|---|---|
| `.healthy` | None |
| `.attention(count: N)` | `DsBadge(mode: .count(N))` |
| `.urgent` | `DsBadge(mode: .urgent)` |

Positioning: top-trailing overlay on each tile, offset by `Inventory.badgeOverhangRect` (8pt) for rect tiles or `Inventory.badgeOverhangPill` (2pt) for pill tiles.

### Empty rails

If a section's array is empty, that **entire section** (eyebrow + rail + surrounding divider) is omitted. The card resizes to fit the remaining sections. Future: when `DsAddTile` ships (backlog), every rail always renders at least one tile (the "+ Add" cell at the end), eliminating empty-state branching entirely. The hide-empty behavior is the v1 stopgap.

## Public API

```swift
struct SpaceCard: View {
    let rooms:   [SpaceItem]
    let outdoor: [SpaceItem]
    let systems: [SpaceItem]
    let onTap:   (SpaceItem) -> Void
}

struct SpaceItem: Identifiable {
    let id: UUID
    let label: String
    let icon: String            // SF Symbol name, expected via IconCatalog.*
    let status: SpaceStatus
}

enum SpaceStatus {
    case healthy
    case attention(count: Int)
    case urgent
}
```

`onTap` receives the tapped item; the card itself doesn't manage selection. Severity ordering and badge derivation are internal.

## Composition

SpaceCard composes:
- `DsKeyButton` (✅ locked) — every tile, rect or pill
- `DsBadge` (✅ locked) — overlaid on tiles with attention/urgent status
- `DsLabeledDivider` — section header for each non-empty section (line / label / line). Uses `DsDivider(.dashed)` internally.

It does NOT extract `RoomsRail` / `OutdoorRail` / `SystemsRail` as separate Components. They live inline as private view-builders. Extract only when a second screen surfaces a need for an individual rail.

## Rules

- **Severity sort is internal.** Callers may pass items in any order; SpaceCard always presents urgent first, then attention, then healthy. Within a severity, original caller-provided order is preserved.
- **Tiles render `IconCatalog` strings.** Caller is responsible for mapping its domain (Room model, etc.) to the right `IconCatalog.Room.*` / `Outdoor.*` / `System.*` value.
- **Empty sections hide.** No empty placeholder, no "no rooms yet" message — that's a Screen-level concern. Future: `DsAddTile` backfills empty rails.
- **Scrollbars hidden by default.** Each rail uses `.scrollIndicators(.hidden)` — iOS-native gesture-driven scrollbar appearance.

## Cross-references

- Uses: `DsKeyButton`, `DsBadge`, `DsDivider`, `Inventory`, `Space`, `Font`, `HkType`, `TextToken`
- Used by: Dashboard Screen (TBD)
- Composition peers: `MaintenanceList` (TBD — vertical stack of rows), `NextUpCard` (TBD — single hero card)

## Decisions log (this spec)

- **API: enum-based `SpaceStatus`** (Luis 2026-05-24): severity + badge derivation from a single `status` field. No separate count or badge mode props — `.attention(count: 3)` carries everything.
- **Severity sort inside the Component** (Luis 2026-05-24, option A): the "urgent first" rule is a presentation concern, belongs with the layout that enforces it.
- **Empty sections hide (v1)** (Luis 2026-05-24, option A): pragmatic stopgap until `DsAddTile` ships. When DsAddTile lands, every rail will always have at least one tile (the always-visible "+ Add" cell), and SpaceCard's empty-section branch becomes dead code to remove.
- **No rail sub-Components** (Luis 2026-05-24): Z-pattern + single-row rails live inline as private view-builders. Extract when reused.
- **Dashed dividers only between non-empty sections** (Luis 2026-05-24): dividers are separators, not bookends. No leading/trailing dividers; no divider when only one section is non-empty.
- **Section header is the divider** (Luis 2026-05-24, iter 2): originally eyebrow text sat above each rail with a standalone `DsDivider(.dashed)` between sections. Replaced with `DsLabeledDivider` (new Primitive) — the dashed line and the section label are now one element, line / label / line. Matches Luis's reference image where every section opens with a labeled dashed boundary.
- **Internal scroll padding (not `.scrollClipDisabled`)** (Luis 2026-05-24, iter 3): iter 2 used `.scrollClipDisabled()` to keep badges visible past scroll bounds, but that also let off-screen tiles bleed past the panel's right edge during carousel scrolling. Replaced with internal padding on the scroll content (`Space.top + .trailing` = `Inventory.badgeOverhangRect`). Default ScrollView clipping stays on (no horizontal bleed), and the padding gives badges room to render inside the clipped content bounds.
- **Identical padding on both `ViewThatFits` branches** (Luis 2026-05-24, iter 4): the padding sat only on the scroll branch initially, causing an 8pt vertical position shift when items count crossed the flex → scroll threshold. Now both branches apply the same padding inside their content, so rail geometry stays stable regardless of which layout `ViewThatFits` picks.
- **Section inner spacing reduced to `Space.tight` (8pt)** (Luis 2026-05-24, iter 5): the rail's internal 8pt badge-overhang padding was silently making the below-label gap 24pt while the above-label gap stayed at 16pt. Reduced sectionView's inner VStack spacing from `bodyPadding` (16pt) to `tight` (8pt). Total visible gap below label = 8pt + 8pt internal = 16pt, matching the 16pt above. Equal spacing on both sides of the label.
- **Odd-count Z-pattern column alignment** (Luis 2026-05-24, iter 3): bottom row keeps the same slot count as the top row when items count is odd. Missing tiles render as transparent flex placeholders. Matches the original paprLCD reference's column alignment.
- **Outer border added** (Luis 2026-05-25 dashboard vet — "why doesnt spacecard have a border also?"): initially `Border.Color.muted`, **revised same-day** to `Border.Color.subtle` so SpaceCard, ActiveProjectCard, and CalendarMonth all share the lighter ink20 outline.
- **Horizontal padding added** (Luis 2026-05-25 follow-up — "add padding to the spacecard left, right now 0 buttons are butt smacked against card edge"): `Space.tight` (8pt) horizontal. Vertical stays `Space.snug` (12pt). Trade-off: SYSTEMS row loses 16pt of effective width; if pill count exceeds available width, `ViewThatFits` falls back to ScrollView (graceful).
