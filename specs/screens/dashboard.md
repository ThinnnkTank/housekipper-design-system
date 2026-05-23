# Dashboard — Screen

**Layer:** Screen
**Status:** 🟡 Draft (planning) — locks when implementation matches the source mockup on iPad
**Implementation:** TBD `houseKipper/houseKipper/Screens/DashboardScreen.swift`
**Source mockup:** user-provided dashboard reference (2026-05-23) — save into `design-sys/refs/dashboard-v1.png` when ready

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
- **Eyebrow labels** (ROOMS, OUTDOOR, SYSTEMS, NEXT UP, ACTIVE PROJECT, UPCOMING MAINTENANCE) use `Font.hkCaption` + `HkType.trackingWider` + `TextToken.muted`.
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

### Round 3 — Screen

- [ ] `DashboardScreen.swift` — assemble everything
- [ ] Wire into `houseKipperApp.swift` (debug routing swaps to dashboard, replacing `_Swatches`)
- [ ] Iterate on iPad against the mockup
- [ ] Lock dashboard ✅

## Verification

- Audit clean throughout — every commit.
- After each Round 1 + Round 2 item: matching spec updated + appears in preview + Luis signs off.
- Round 3: iPad render matches the mockup. Luis signs off. Dashboard spec moves from 🟡 Draft → ✅ Locked.

## Cross-references

- Foundations: [foundations.md](../foundations.md) (color philosophy · spacing ladder · iconography rules)
- Tokens: [semantic-tokens.md](../semantic-tokens.md) (ActionToken, StatusToken, Border, Space, Radius, Font)
- Primitives: [ds-button.md](../primitives/ds-button.md) · [ds-divider.md](../primitives/ds-divider.md) · [ds-key-button.md](../primitives/ds-key-button.md)
- Components: [nav-rail.md](../components/nav-rail.md)
