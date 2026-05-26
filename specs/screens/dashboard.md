# Dashboard — Screen

**Layer:** Screen
**Status:** ✅ Locked (2026-05-25) — promoted from `_DashboardMock` after the 8-surface 🟡 → ✅ batch closure
**Implementation:** `houseKipper/houseKipper/Screens/DashboardScreen.swift`
**Source mockup:** user-provided dashboard reference (2026-05-23) — save into `design-sys/refs/dashboard-v1.png` when ready

> **Current state of truth:** this spec was written as a planning doc before Components shipped. For the *as-implemented* dashboard (3-column grid, locked outer-padding contract, layout architecture), see `CHANGELOG.md` entries dated 2026-05-25 + inline lock-in notes in `Screens/DashboardScreen.swift`. The "Build order" + "Open decisions" sections below are historical now — Rounds 1–3 are all complete.

### Locked dimensions

| Geometry | Value | Source |
|---|---|---|
| Top padding above TopBar | `Space.cardPadding` (20pt) — additive on SwiftUI safe-area inset | **LOCKED Luis 2026-05-25** — iteration history: pageInset 36 → 40 (symmetric attempt, rejected) → 16/16 even → 20/12 asymmetric (this). |
| Padding below TopBar | `Space.snug` (12pt) — applied as TopBar's own `.padding(.bottom)`; outer VStack spacing forced to 0 to prevent double-stacking | Same lock — 20 top + 12 bottom reads better than 16/16 even. |
| Page side padding | `Space.bodyPadding` (16pt) | Prior-engineer spec |
| Page bottom padding | `Space.bodyPadding` (16pt) | Prior-engineer spec |
| Outer sides + bottom padding | `Space.bodyPadding` (16pt) | Prior-engineer dashboard spec |
| NavRail width | 48pt fixed (= chip width — was 64pt; reduced Luis 2026-05-25 after rail chrome was dropped) | NavRail spec |
| Calendar column width | 390pt fixed | Prior-engineer dashboard spec |
| Col 2 (flex) row heights | Driven by content — no fixed-height frames | Dropped 2026-05-25 (the 420/144/144 frames overflowed Calendar's content into MaintenanceList) |
| Inter-column gap (col 2 → col 3) | `Space.snug` (12pt) | Prior-engineer dashboard spec |
| Inter-column gap (NavRail → col 2) | `Space.snug` (12pt HStack) + extra `Space.tight` (8pt) `.padding(.leading)` on col 2 = 20pt effective | Luis 2026-05-25 — wanted more breathing between rail + content column specifically |
| Inter-row gap (col 2) | `Space.tight` (8pt) | Luis 2026-05-25 yellow vet |
| Inter-row gap (col 3) | `Space.tight` (8pt) | Same |
| HStack height source | **Col 2's natural via `.fixedSize(vertical: true)`** | Luis 2026-05-25 floor-alignment fix — ActiveProject's bottom = the floor for NavRail + col 3 |
| Col 3 overflow handling | `MaintenanceList` wrapped in `ScrollView(.vertical, showsIndicators: false)` | Same fix — scrolls internally when MaintList exceeds remaining vertical inside col 3 |
| TopBar heading style | `Type.Title.lg` (22pt sans Bold + tighter) | Luis 2026-05-25 "try large instead of XL, looking to fisher pricey" |
| ADD button | `SignalButton` (orange + 12pt extra L/R padding) | Luis 2026-05-25 — the dashboard's one Dieter-Rams signal action |

## Overview

First-launch home screen and the daily anchor surface. The single view that orients an ADHD user to:

- **What needs attention right now** — Next Up card (urgent treatment)
- **What's happening in each space** — rooms / outdoor / systems key-button grids
- **What's coming up** — calendar (this month) + upcoming maintenance list
- **What they're working on** — Active Project card

iPad-first composition. iPhone is a stacking adaptation (separate spec when surfaced).

## Anatomy (regions)

```
DashboardScreen
├── NavRail                       (left, full height)
└── Main canvas
    ├── TopBar                    title · weather · theme toggle · search · ADD
    ├── Two-column lockup
    │   ├── Left column
    │   │   ├── SpaceCard                       wrapper composing three rails:
    │   │   │   ├── RoomsRail                     ROOMS — Z-pattern 2-row, flex (rect tiles)
    │   │   │   ├── OutdoorRail                   OUTDOOR — single-row flex (rect tiles)
    │   │   │   └── SystemsRail                   SYSTEMS — single-row flex (pill tiles)
    │   │   ├── NextUpCard                      hero, urgent treatment (Decision 7 applies HERE only)
    │   │   └── ActiveProjectCard               carousel + progress
    │   └── Right column
    │       ├── CalendarMonth                   month grid + dots + legend
    │       └── MaintenanceList                 upcoming maintenance rows
```

## Composition rules

- **Two-column lockup** at iPad landscape; collapses to single-scroll on iPad portrait or iPhone.
- **Section dividers** between ROOMS / OUTDOOR / SYSTEMS use `DsDivider(.dashed)` per the dashed-only-for-dividers rule.
- **Eyebrow labels** (ROOMS, OUTDOOR, SYSTEMS, NEXT UP, ACTIVE PROJECT, UPCOMING MAINTENANCE) use `Type.Data.xs` + `HkType.trackingWider` + `TextToken.muted`.
- **Section spacing** between major blocks: `Space.sectionGap` (32pt).
- **NextUpCard** uses the urgent-hero treatment per Decision 7 — signal border, no signalTint fill.

## Primitives + Components used

### Already exist ✅

- `DsButton` (all variants × sizes) — "MARK COMPLETE", "SNOOZE ▾", "VIEW ALL →", calendar arrows, "+ ADD"
- `DsDivider` (solid + dashed) — section dividers, list row separators

### New Primitives (Round 1 — build first)

1. **`DsKeyButton`** — square (rooms, outdoor) + circle (systems). Severity (healthy / attention / urgent). Badge support. Spec already drafted at [primitives/ds-key-button.md](../primitives/ds-key-button.md).
2. **`DsBadge`** — small numeric/symbol counter. Used on key buttons + nav rail.
3. **`DsAvatar`** — letter-in-circle. Nav bottom (user) + maintenance list (assignee).
4. **`DsStatusDot`** — tiny filled or hollow dot. Calendar indicators.
5. **`DsProgressBar`** — horizontal progress with percentage. Active Project card.
6. **`DsSearchField`** — pill input with leading magnifier + placeholder.

### New Components (Round 2)

7. **`NavRail`** — spec already exists at [components/nav-rail.md](../components/nav-rail.md). Vertical app nav.
8. **`SpaceCard`** — wrapper that composes three rails (`RoomsRail`, `OutdoorRail`, `SystemsRail`) with dashed-divider section labels (ROOMS / OUTDOOR / SYSTEMS). Each rail has its own layout algorithm:
   - **`RoomsRail`** — Z-pattern 2 rows. Sort by severity (urgent → attention → healthy) THEN split: even sorted-indices to row 1, odd to row 2. Columns flex to fill; below `Inventory.tileMinWidthRect` (100pt) per column horizontal scroll engages. ~12 items fit no-scroll (6 columns × 2 rows); 13+ scrolls.
   - **`OutdoorRail`** — single-row flex. Tiles stretch evenly when few, scroll horizontally when many.
   - **`SystemsRail`** — single-row flex (pill tiles, fully rounded ends — `DsKeyButton(shape: .pill)`). Same flex behavior as outdoor; pill shape is the only visual differentiator from rooms/outdoor.
   - **Scrollbars: iOS-native default** (hidden until scroll gesture). NOT always-visible.
9. **`CalendarMonth`** — header pill + day-label row + date cells + status dots + legend.
10. **`MaintenanceRow`** — single upcoming-maintenance row. Press strategy: invert.
11. **`MaintenanceList`** — vertical stack of `MaintenanceRow`s + section header.
12. **`NextUpCard`** — hero urgent card composing icon, eyebrow, title, meta, action buttons. Decision 7 applies HERE (no signalTint fill on urgent).
13. **`ActiveProjectCard`** — thumbnail + title + meta + `DsProgressBar` + carousel dots/arrows.
14. **`TopBar`** — assembles title + weather metadata + theme toggle + `DsSearchField` + ADD button.

Note: the "+ ADD" tile at the end of each rail is **deferred** — not built this round. When surfaced, it'll likely be a new appearance-only `DsAddTile` Primitive (separate from `DsKeyButton`) per Luis's call.

### Candidate — decide as we go

- **`DsWeatherChip`**: the "72°F · SUNNY · RAIN @6PM · UV 7 HIGH" string under the address. Could be its own Primitive or just an inline composition in `TopBar`. Defer — likely inline.

## States (TBD)

Once Primitives land, define dashboard-level states:

- **Loading** — skeleton state on first render
- **Empty** — no rooms / no tasks / fresh install
- **Fully stocked** — the mockup state

## Open decisions

Resolve before locking:

- **`WeatherChip`** — Primitive or inline? Lean inline.
- **Calendar interactions** — what happens on date tap? Open a day-detail sheet? Filter Next Up + Maintenance to that day?
- **ADD button behavior** — popover with quick-add options (task, project, note)? Full modal? New screen?
- **Project carousel data model** — Active Project assumes ≥1 project exists; what's the empty state?
- **NavRail badge counts** — driven by what model? (count of attention/urgent tiles? unread alerts?)

---

## Build order — the plan

> Strikethrough as each item locks.

### Round 1 — Primitives (6 items)

- [ ] `DsKeyButton` (sq + circle, severity, badge slot) — spec locked, implementation pending
- [ ] `DsBadge`
- [ ] `DsAvatar`
- [ ] `DsStatusDot`
- [ ] `DsProgressBar`
- [ ] `DsSearchField`

Each: spec → impl → swatches preview → Luis signs off → lock.

### Round 2 — Components (8 items)

- [ ] `NavRail` — spec exists, just implement
- [ ] `SectionedKeyGrid` (this is what proves the rooms/outdoor/systems blocks look right)
- [ ] `CalendarMonth`
- [ ] `MaintenanceRow` + `MaintenanceList`
- [ ] `NextUpCard`
- [ ] `ActiveProjectCard`
- [ ] `TopBar`

Each: spec → impl → live preview in a Components section of `_Swatches.swift` (or a dedicated `_Components.swift`) → Luis signs off → lock.

### Round 3 — Screen ✅

- [x] `DashboardScreen.swift` — assembled, lives at `houseKipper/houseKipper/Screens/DashboardScreen.swift`
- [x] Wired into `_Root.swift` (debug router toggles swatches ↔ dashboard)
- [x] Iterated on iPad Pro 11" landscape against the reference (multiple vet rounds 2026-05-25)
- [x] Locked 2026-05-25 ✅ — all 8 composing Components + 2 new Primitives (SignalButton, DsAvatar.outline) locked the same day; Screen promoted from `_DashboardMock.swift` (deleted) with `Space.pageInset` SemanticToken alias added to replace the mock's direct `SpacingToken.s36` reference

## Verification

- Audit clean throughout — every commit.
- After each Round 1 + Round 2 item: matching spec updated + appears in preview + Luis signs off.
- Round 3: iPad render matches the mockup. Luis signs off. Dashboard spec moves from 🟡 Draft → ✅ Locked.

## Cross-references

- Foundations: [foundations.md](../foundations.md) (color philosophy · spacing ladder · iconography rules)
- Tokens: [semantic-tokens.md](../semantic-tokens.md) (ActionToken, StatusToken, Border, Space, Radius, Font)
- Primitives: [ds-button.md](../primitives/ds-button.md) · [ds-divider.md](../primitives/ds-divider.md) · [ds-key-button.md](../primitives/ds-key-button.md)
- Components: [nav-rail.md](../components/nav-rail.md)
