# Dashboard — Screen

**Layer:** Screen
**Status:** ✅ Locked (2026-05-27) — chrome architecture rewritten to absolute positioning to defeat tab-dependent TopNav drift. **Page bg + card-fill hierarchy** added 2026-05-27 [explore].

## 2026-05-27 update — page bg + card-fill hierarchy [explore]

Dashboard now uses a two-tier surface model: **page bg** (`BackgroundToken.page` = `#D5D7D1`) sits behind everything; **cards** paint `BackgroundToken.primary` (`paper` = `#E0E2DC`) on top, lifting them visually. The 11-unit luminance step is subtle but clearly readable as separation. Implementation: GeometryReader's bg switched `BackgroundToken.primary` → `.page`; every card (NextUpCard, ActiveProjectCard, SpaceCard, CalendarMonth, MaintenanceList) gained `.background(RoundedRectangle(cornerRadius: Radius.md).fill(BackgroundToken.primary))`. NextUpCard uses a single ZStack-background so the urgent spine layers correctly above the paper fill.
**Implementation:** `houseKipper/houseKipper/Screens/DashboardScreen.swift`

## History

| Date | Phase |
|---|---|
| 2026-05-25 | Original `DashboardScreen` graduated from `_DashboardMock.swift`. Sidebar NavRail + 3-column body. ✅ Locked. |
| 2026-05-26 | Luis sketched a top-tab alternate layout. Built as `DashboardScreenAlt` for A/B vet on iPad. `DsTabItem` Primitive + `TopNav` Component shipped. |
| 2026-05-27 (AM) | Alt won. Original sidebar dashboard retired. `DashboardScreenAlt.swift` renamed → `DashboardScreen.swift` via `git mv`. |
| 2026-05-27 (PM) | Chrome drift bug surfaced (TopNav shifted 12.5pt down between Home and stub tabs). After iterating through `VStack`, `.safeAreaInset(edge: .top)`, and `.overlay(alignment: .top)` — all produced tab-dependent positions — diagnosed as SwiftUI declarative layout cascading from `homeBody`'s mixed HStack columns (`.fixedSize` + `.frame(maxHeight: .infinity)`). **Solution: absolute positioning via `GeometryReader` + `.frame` + `.offset`.** Pixel-verified 0 drift across all 4 tabs. |

## Overview

First-launch home screen + daily anchor surface. Composes a single horizontal `TopNav` chrome at the top, with a 2-column body whose content depends on the selected tab.

iPad-first (designed/vetted at iPad Pro 11" landscape, 1194 × 834). iPhone is a future stacking adaptation (separate spec when surfaced).

## Anatomy

```
DashboardScreen
└── GeometryReader { proxy in
    └── ZStack(alignment: .topLeading) {
        ├── BackgroundToken.primary             ← fills proxy.size (full screen)
        │
        ├── tabBody                              ← BODY — absolute positioned
        │   .padding(.horizontal, bodyPadding=16)
        │   .padding(.bottom, snug=12)
        │   .frame(width: proxy.size.width,
        │          height: proxy.size.height - chromeHeight)
        │   .offset(y: chromeHeight)            ← starts 96pt from screen top
        │
        └── TopNav                               ← CHROME — anchored top, fixed height
            .padding(.top, chromeTopPadding=40) ← 40pt: clears status bar + 16pt breathing
            .padding(.horizontal, bodyPadding=16)
            .padding(.bottom, snug=12)
            .frame(width: proxy.size.width,
                   height: chromeHeight=100, alignment: .top)
    }
}
.ignoresSafeArea()   ← GeometryReader owns the full screen; safe area is manual
```

### Why absolute positioning instead of declarative SwiftUI

Three declarative iterations (VStack at root, `.safeAreaInset(edge: .top)`, `.overlay(alignment: .top)`) all produced **tab-dependent TopNav drift** of 12–27pt between the Home tab and the stub tabs. Pixel-precise screenshot diffing on the iPad simulator (2026-05-27) confirmed it wasn't perception.

Root cause: SwiftUI's layout pass propagates sizing requests up the tree. `homeBody`'s HStack with mixed `.fixedSize(vertical: true)` left column + `.frame(maxHeight: .infinity)` right column (containing a `ScrollView`) produces a different "intrinsic content" measurement than the stubs' centered `ComingSoonStub`. That difference cascades up through every declarative chrome attachment and shifts the TopNav.

`GeometryReader` + absolute `.frame` + `.offset` owns the layout ourselves. Body content cannot influence chrome position because chrome y-coordinate is a hard-coded value (`0 + chromeHeight` is the body offset; TopNav is anchored at y=0).

Trade-off: less idiomatic SwiftUI, but the chrome is **pixel-locked** across every tab and every future Screen. The dashboard is the primary surface in the app — this rigidity is worth the unusual shape.

### Tab body

```
tabBody = @ViewBuilder switch selectedTab {
    case .home        → HomeTab()              ← own View struct (this file)
    case .spaces      → SpacesScreen()         ← stub
    case .fileCabinet → FileCabinetScreen()    ← stub
    case .ledger      → LedgerScreen()         ← stub
}
```

**Sibling-symmetry rule:** every tab returns its own `View` struct — never an inline `@ViewBuilder` computed var. When tabs are structural peers, SwiftUI's layout pass treats them uniformly. (The earlier mix of inline `homeBody` + struct-based stubs was one source of the cascade asymmetry.)

### HomeTab anatomy

```
HomeTab
└── HStack(alignment: .top, spacing: snug=12)
    ├── leftColumn                              ← flex width
    │   .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    │   └── VStack(alignment: .leading, spacing: tight=8)
    │       ├── SpaceCard (rooms / outdoor / systems)
    │       ├── NextUpCard (urgent state)
    │       ├── ActiveProjectCard
    │       └── Spacer(minLength: 0)
    │
    └── rightColumn                             ← 390pt fixed width
        .frame(width: 390, alignment: .topLeading)
        .frame(maxHeight: .infinity)
        └── VStack(alignment: .leading, spacing: tight=8)
            ├── CalendarMonth.sampleMay2026
            └── ScrollView(.vertical) { MaintenanceList }
```

## Locked dimensions

| Geometry | Value | Source |
|---|---|---|
| **Chrome zone (TopNav frame)** | | |
| Chrome height | 100pt = `chromeTopPadding` (44) + tapTarget (44) + `Space.snug` (12) | Screen-internal carve-out |
| Chrome top padding | 44pt — clears status bar (~24pt) + 20pt breathing room | Luis 2026-05-27 — screen-internal carve-out |
| **Hero card height** | 164pt (`HomeTab.heroHeight`) — math: 4 top + 44 header rail + 0 inner spacing + 96 content row (NextUp's 2-button stack min) + 20 bottom | Luis 2026-05-27 lock |
| Hero card padding | top 4 (`hairline`) / horizontal 16 (`bodyPadding`) / bottom 20 (`cardPadding`) — heroes only | Luis 2026-05-27 [explore] |
| Hero card inner VStack spacing | 0 (audit:exempt — header rail provides breathing) | Luis 2026-05-27 |
| Hero card header rail | 44pt (`Space.tapTarget`) — eyebrow top-aligned via `HStack(alignment: .top)` | Luis 2026-05-27 |
| Hero card icon | 48pt SF Symbol + 12pt L/R breathing (`.padding(.horizontal, snug)`) | Luis 2026-05-27 |
| Eyebrow typography (heroes + Tasks) | `.font(Type.Label.lg.font)` — DM Mono Medium 14pt, no tracking, no upper-bake (matches DsSearchField) | Luis 2026-05-27 |
| SpaceCard padding | top 16 (`bodyPadding`) / horizontal 8 (`tight`) / bottom 24 (`safeGutter`) | Luis 2026-05-27 |
| CalendarMonth padding | top 8 / horizontal 16 / bottom 24 — natural height (no fixed-height grid lock) | Luis 2026-05-27 |
| MaintenanceList (Tasks card) padding | top 8 / bottom 24, inner horizontal 16 on header + rows | Luis 2026-05-27 |
| MaintenanceList header | TASKS (uppercase) + VIEW ALL **pinned at top**; rows scroll internally under pinned header | Luis 2026-05-27 |
| Inter-card gap (both columns) | `Space.snug` (12pt) | Luis 2026-05-27 |
| Chrome side padding | `Space.bodyPadding` (16pt) | Luis 2026-05-27 (was `Space.cardPadding` 20pt) |
| Chrome bottom padding | `Space.snug` (12pt) | Gap from TopNav row to body |
| TopNav row visible height | 32pt (search/ADD/avatar at `.small`); 44pt tapTarget min enforces actual row | Luis 2026-05-27 "deaccent + normalize" |
| Search field width cap | 256pt | Luis 2026-05-27 (was 300pt) |
| ADD button | `SignalButton(.small)` + 24pt extra L/R padding | Luis 2026-05-27 — `.small` extra +12 → +24 |
| **Body zone** | | |
| Body top offset | 100pt (= chromeHeight) | Pushes body below chrome |
| Body side padding | `Space.bodyPadding` (16pt) | Matches chrome |
| Body bottom padding | `Space.snug` (12pt) | Locked |
| **HomeTab specifics** | | |
| Inter-column gap | `Space.snug` (12pt) | HStack default |
| Calendar column width | 390pt fixed | Prior-engineer spec |
| Right-col overflow handling | `MaintenanceList` wrapped in `ScrollView(.vertical, showsIndicators: false)` | Same handling |
| **Tab styling** | | |
| Tab style | Active = `DsButton(.primary, .small)`; Inactive = `DsButton(.ghost, .small)` | `DsTabItem` |
| Avatar diameter | 32pt (`Space.avatarRegular`) | |

## Chrome invariance rule (lock-in 2026-05-27)

**The chrome — `chromeTopPadding` + TopNav row + chrome bottom padding — is pixel-invariant across every tab and every future Screen.** No tab body, no stub Screen, no future Screen may push TopNav down, shrink the outer padding, or alter the chrome's position. Content lives **inside** the body region (the rectangle starting at y=`chromeHeight`); when content exceeds it, scroll INSIDE the body — never displace the chrome.

**Architectural enforcement (no code change can break this):**
- DashboardScreen owns the chrome ONCE, via absolute positioning inside a GeometryReader.
- TopNav's y-coordinate is a hard-coded `0` inside the ZStack; cannot be influenced by tab body content.
- Body's y-coordinate is `chromeHeight` (offset). Body content fills the body region; if it overflows, it must wrap in a `ScrollView`.
- Every tab body returns **content only** — no TopNav, no outer padding, no top/leading offsets.
- Future Screens reusing this dashboard pattern: copy the GeometryReader + ZStack structure. Don't reinvent.

If a future Screen needs different chrome (e.g. a modal sheet with no TopNav), it's a separate Screen pattern with its own spec — it does not silently mutate this one.

## Composed surfaces

**Reused from prior locked dashboard (unchanged):**
- `SpaceCard` (✅ locked)
- `NextUpCard` (✅ locked)
- `ActiveProjectCard` (✅ locked)
- `CalendarMonth` (✅ locked)
- `MaintenanceList` (✅ locked) — wraps `MaintenanceRow` (✅ locked)
- `DsSearchField` (✅ locked, gained `.small` Size 2026-05-27)
- `SignalButton` (✅ locked, gained `.small` Size 2026-05-27, `.small` extra padding 12 → 24 2026-05-27)
- `DsAvatar` (✅ locked)

**New for the alt that won:**
- `DsTabItem` (✅ locked 2026-05-27)
- `TopNav` (✅ locked 2026-05-27)
- 3 stub sub-screens: `SpacesScreen`, `FileCabinetScreen`, `LedgerScreen` — render `ComingSoonStub`
- `ComingSoonStub` helper view
- `HomeTab` (private View struct in `DashboardScreen.swift`)

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
