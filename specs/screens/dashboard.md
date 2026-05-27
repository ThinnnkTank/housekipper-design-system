# Dashboard — Screen

**Layer:** Screen
**Status:** ✅ Locked (2026-05-27) — promoted from `DashboardScreenAlt` after A/B vet on iPad; previous sidebar dashboard retired.
**Implementation:** `houseKipper/houseKipper/Screens/DashboardScreen.swift`

## History

| Date | Phase |
|---|---|
| 2026-05-25 | Original `DashboardScreen` graduated from `_DashboardMock.swift`. Sidebar NavRail + 3-column body. ✅ Locked. |
| 2026-05-26 | Luis sketched a top-tab alternate layout. Built as `DashboardScreenAlt` (experimental sibling) for A/B vet on iPad. `DsTabItem` Primitive + `TopNav` Component shipped. |
| 2026-05-27 | Alt won. Original sidebar dashboard retired (`TopBar` + `NavRail` Components deleted; their specs marked ✗ Removed). `DashboardScreenAlt.swift` renamed → `DashboardScreen.swift` via `git mv` (history preserved). |

## Overview

First-launch home screen + daily anchor surface. Composes a single horizontal `TopNav` chrome at the top, with a 2-column body whose content depends on the selected tab.

iPad-first (designed/vetted at iPad Pro 11" landscape, 1194 × 834). iPhone is a future stacking adaptation (separate spec when surfaced).

## Anatomy

```
DashboardScreen
└── ZStack
    ├── BackgroundToken.primary (.ignoresSafeArea())
    └── VStack
        ├── TopNav                                        ✅ Locked Component
        │   ├── DsTabItem("Home", active)                  (4 tabs at .small / 32pt)
        │   ├── DsTabItem("Spaces")
        │   ├── DsTabItem("File Cabinet")
        │   ├── DsTabItem("Ledger")
        │   ├── (Spacer)
        │   ├── themeMenu                                  (bare-icon utility, 44pt tap)
        │   ├── DsSearchField(.small)                      (32pt, capped 300pt width)
        │   ├── SignalButton(.small, "ADD")                (32pt)
        │   └── DsAvatar (top-right, 32pt)                 (taps → Profile / Settings / Sign out menu)
        │       .padding(.bottom, Space.snug)              gap from TopNav to tab body
        │
        └── tabBody (switches by selectedTab)
            ├── .home → HStack(spacing: Space.snug, alignment: .top)
            │   ├── Left col (flex width, .fixedSize(vertical: true) — sets HStack height)
            │   │   ├── SpaceCard
            │   │   ├── NextUpCard
            │   │   └── ActiveProjectCard
            │   └── Right col (390pt fixed width, .frame(maxHeight: .infinity))
            │       ├── CalendarMonth.sampleMay2026
            │       └── ScrollView { MaintenanceList }     scrolls internally if it overflows
            │
            ├── .spaces      → SpacesScreen()              stub
            ├── .fileCabinet → FileCabinetScreen()         stub
            └── .ledger      → LedgerScreen()              stub

Outer padding (locked):
  .padding(.top, Space.cardPadding)        20pt above TopNav
  .padding(.horizontal, Space.bodyPadding) 16pt sides
  .padding(.bottom, Space.bodyPadding)     16pt page bottom
  .frame(maxWidth: .infinity, alignment: .topLeading)
```

## Locked dimensions

| Geometry | Value | Source |
|---|---|---|
| Top padding above TopNav | `Space.cardPadding` (20pt) — additive on SwiftUI safe-area inset | Luis 2026-05-25 lock-in (carried over from sidebar dashboard) |
| Padding below TopNav | `Space.snug` (12pt) | Gap from TopNav row to tab body |
| Page side padding | `Space.bodyPadding` (16pt) | Locked |
| Page bottom padding | `Space.bodyPadding` (16pt) | Locked |
| TopNav row height | 32pt visible (all 5 elements: tabs, theme, search, ADD, avatar) | Luis 2026-05-27 "deaccent + normalize" — search + ADD bumped down to `.small`, avatar already 32pt |
| Inter-column gap (Home tab) | `Space.snug` (12pt) | HStack default |
| Calendar column width (Home tab) | 390pt fixed | Prior-engineer spec |
| HStack height source (Home tab) | Col 2's natural via `.fixedSize(vertical: true)` | Floor-alignment fix carried over |
| Col 3 overflow handling (Home tab) | `MaintenanceList` wrapped in `ScrollView(.vertical, showsIndicators: false)` | Same handling |
| Tab style | Active = `DsButton(.primary, .small)` ink fill + paper text; Inactive = `DsButton(.ghost, .small)` bare text | `DsTabItem` |
| ADD button | `SignalButton(.small)` orange + 12pt extra L/R padding | Luis 2026-05-27 |
| Avatar diameter | 32pt (`Space.avatarRegular`) | Already 32pt; no change needed for the normalization pass |

## Composed surfaces

**Reused from prior locked dashboard (unchanged):**
- `SpaceCard` (✅ locked)
- `NextUpCard` (✅ locked)
- `ActiveProjectCard` (✅ locked)
- `CalendarMonth` (✅ locked)
- `MaintenanceList` (✅ locked) — wraps `MaintenanceRow` (✅ locked)
- `DsSearchField` (✅ locked, gained `.small` Size 2026-05-27)
- `SignalButton` (✅ locked, gained `.small` Size 2026-05-27)
- `DsAvatar` (✅ locked)

**New for the alt that won:**
- `DsTabItem` (✅ locked 2026-05-27)
- `TopNav` (✅ locked 2026-05-27)
- 3 stub sub-screens: `SpacesScreen`, `FileCabinetScreen`, `LedgerScreen` — render `ComingSoonStub`
- `ComingSoonStub` helper view

**Retired alongside the old dashboard:**
- `TopBar` (✗ Removed 2026-05-27)
- `NavRail` (✗ Removed 2026-05-27)

## Open decisions (tracked in BACKLOG)

- Hero card (NextUpCard) styling refinements
- Upcoming Maintenance row styles
- Overall content size + scroll behavior across the body
- Minor TopNav row adjustments (positioning, spacing)

## Cross-references

- Chrome: [components/top-nav.md](../components/top-nav.md)
- Tab item: [primitives/ds-tab-item.md](../primitives/ds-tab-item.md)
- Inventory: [components/space-card.md](../components/space-card.md)
- Hero: [components/next-up-card.md](../components/next-up-card.md)
- Project carousel: [components/active-project-card.md](../components/active-project-card.md)
- Calendar: [components/calendar-month.md](../components/calendar-month.md)
- Maintenance list: [components/maintenance-list.md](../components/maintenance-list.md) (uses [maintenance-row.md](../components/maintenance-row.md))
- Retired chrome: [components/top-bar.md](../components/top-bar.md) (✗) · [components/nav-rail.md](../components/nav-rail.md) (✗)
- Dev router: `houseKipper/houseKipper/DesignSystem/_Root.swift` (Swatches ↔ Dashboard via 3-finger horizontal swipe)
