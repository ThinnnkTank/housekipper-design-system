# DashboardScreen (Alt) — Screen

**Layer:** Screen
**Status:** 🟡 Experimental sibling (2026-05-27) — alternate layout being prototyped alongside the locked `DashboardScreen` for A/B vet on iPad. Content built; pending real-iPad sign-off.
**Implementation:** `houseKipper/houseKipper/Screens/DashboardScreenAlt.swift`

## Overview

Alternate dashboard layout exploring **horizontal top-tab navigation** in place of the locked dashboard's vertical `NavRail` sidebar. Lives as a sibling Screen so neither version is in flux during the comparison — current `DashboardScreen` (`✅ Locked 2026-05-25`) is untouched. If alt wins after iPad vet, we promote it and deprecate the locked version; if it doesn't, we delete this file.

**Source sketch:** user-provided sketch (2026-05-26) — see CHANGELOG entry of that date for the asks captured from Luis's hand-drawn layout.

## Anatomy

```
DashboardScreenAlt
└── ZStack
    ├── BackgroundToken.primary  (ignoresSafeArea)
    └── VStack
        ├── TopNav                       (new Component — horizontal tabs + theme + search + ADD + avatar)
        │   ├── HStack
        │   │   ├── DsTabItem("Home", active)
        │   │   ├── DsTabItem("Spaces")
        │   │   ├── DsTabItem("Docs + Files")
        │   │   ├── DsTabItem("Finances")
        │   │   └── DsTabItem("Warranties + Plans")
        │   ├── Spacer
        │   ├── themeMenu                (theme picker — reused from TopBar)
        │   ├── DsSearchField
        │   ├── SignalButton("ADD")
        │   └── DsAvatar (top-right corner)
        │
        └── HStack (2-column main canvas — no NavRail)
            ├── Left col (~2/3 width)
            │   ├── SpaceCard
            │   ├── NextUpCard
            │   └── ActiveProjectCard
            │
            └── Right col (~1/3 width, ≈390pt fixed)
                ├── CalendarMonth
                └── MaintenanceList (in ScrollView)
```

## Differences vs locked `DashboardScreen`

| | Locked DashboardScreen | DashboardScreenAlt (target) |
|---|---|---|
| Primary nav | `NavRail` vertical sidebar (48pt wide, 5 chips + avatar) | Horizontal tabs at the top (5 tabs + avatar in top-right) |
| Page heading | "7630 Ladson Ter" via lean TopBar | None — tabs replace the heading role |
| Layout columns | 3 (NavRail · col 2 flex · col 3 fixed 390pt) | 2 (col 1 flex · col 2 fixed 390pt) |
| Theme · Search · ADD | TopBar right cluster | TopNav right cluster (same controls, same right-to-left order) |
| User avatar | NavRail utility cluster (bottom-left) | TopNav top-right corner |

## Composed surfaces

**Reused from locked dashboard (no changes):**
- `SpaceCard` (✅ locked)
- `NextUpCard` (✅ locked)
- `ActiveProjectCard` (✅ locked)
- `CalendarMonth` (✅ locked)
- `MaintenanceList` (✅ locked)
- `DsSearchField` (✅ locked)
- `SignalButton` (✅ locked)
- `DsAvatar` (✅ locked)

**New surfaces built 2026-05-27:**
- `DsTabItem` Primitive (🟡) — subtle-pill on active. Spec: [primitives/ds-tab-item.md](../primitives/ds-tab-item.md)
- `TopNav` Component (🟡) — composes 5 tabs + theme menu + search + ADD + avatar. Spec: [components/top-nav.md](../components/top-nav.md)
- 4 stub sub-screens routed from the tabs: `SpacesScreen`, `DocsFilesScreen`, `FinancesScreen`, `WarrantiesPlansScreen` (each renders `ComingSoonStub` with the tab name)
- `ComingSoonStub` helper view — shared placeholder body for the 4 non-Home stubs

## Resolved decisions (2026-05-27 build)

- **Settings location** → tap-the-avatar menu (Luis option 1A). Menu rows: Profile · Settings · Sign out. Same iOS-canonical pattern as Mail/Calendar/Maps.
- **Active-tab style** → subtle pill (Luis option C from A/C/D menu). `ink05` fill + `ink20` border + `Radius.md`. See `primitives/ds-tab-item.md` decisions log for the full comparison.
- **Avatar tap behavior** → opens the account menu (above). Never direct nav.
- **Non-Home tab stubs** → centered "Coming soon" body via `ComingSoonStub` helper. Single source so all 4 stubs stay consistent; easy to delete when each tab gets real content.

## Open decisions

- **Tab routing semantics when more tabs ship for real.** Current pattern: each tab is a Screen, DashboardScreenAlt switches the body inline. If sub-screens get deep nav (e.g. Spaces → Room detail), we'll need a NavigationStack per tab. Defer until a tab actually has nav depth.

## Promotion / deprecation path

This Screen is **experimental sibling** of the locked Screen. Three outcomes:

1. **Alt wins after vet** → promote to `DashboardScreen` (rename + replace), demote / archive the current locked one. The 4 stub sub-screens get built out for real. NavRail gets marked deprecated.
2. **Alt loses** → delete `DashboardScreenAlt.swift`, delete the TopNav + DsTabItem if they have no other consumers, revert `_Root` to 2 modes (Swatches + Dashboard). Locked dashboard remains.
3. **Both stay** for different contexts (less likely; we'd need a real reason to maintain two dashboard chromes).

## Cross-references

- Source sketch: CHANGELOG entry 2026-05-26 — "Dev router: gesture-based cycling + DashboardScreenAlt stub"
- Locked sibling: [screens/dashboard.md](dashboard.md)
- TopNav (TBD): [components/top-nav.md](../components/top-nav.md) — not yet written
- DsTabItem (TBD): [primitives/ds-tab-item.md](../primitives/ds-tab-item.md) — not yet written
- Router: `_Root.swift` cycles Swatches → Dashboard → DashboardAlt via 3-finger horizontal swipe (`_RouterSwipeGesture.swift`)
