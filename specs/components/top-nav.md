# TopNav — Component

**Layer:** Component
**Status:** 🟡 Implemented (2026-05-27) — built for `DashboardScreenAlt` chrome; locks when alt is vetted
**Implementation:** `houseKipper/houseKipper/Components/TopNav.swift`

## Overview

Top-of-screen horizontal chrome for the alternate dashboard layout (`DashboardScreenAlt`). Replaces `TopBar`'s heading + weather in the alt world with a tab strip; right cluster reuses TopBar's theme menu + search + ADD pattern, plus an avatar at the far right that opens an iOS-native account menu (Profile / Settings / Sign out).

**When to use:** Screens that need horizontal top-tab navigation (currently the alt dashboard only). If alt wins the A/B vet, TopNav becomes the canonical Screen chrome.
**When NOT to use:** Screens that aren't tab-roots — they should use `TopBar` (heading + lean/full variants).

## Anatomy

```
TopNav (borderless — no fill, no outline, no internal padding)
└── HStack(spacing: 16, alignment: .center)
    ├── tabStrip                                    [LEFT — flex]
    │   └── HStack(spacing: Space.tight)
    │       ├── DsTabItem("Home",          isActive: …, onTap: …)
    │       ├── DsTabItem("Spaces",        isActive: …, onTap: …)
    │       ├── DsTabItem("File Cabinet",  isActive: …, onTap: …)
    │       └── DsTabItem("Ledger",        isActive: …, onTap: …)
    ├── Spacer
    └── rightCluster                                [RIGHT — fixed]
        └── HStack(spacing: Space.bodyPadding)
            ├── Menu { theme picker } label: { themeIcon + chevron.down } — 44pt tap target
            ├── DsSearchField
            │       .frame(maxWidth: 300)   cap so right cluster doesn't push past safe area
            ├── SignalButton("ADD")
            └── Menu { Profile / Settings / Sign out } label: { DsAvatar }   44pt tap target
```

### Tab selection

Tabs drive selection via a `@Binding<Tab>` — caller owns the state. Tap on a tab fires `withAnimation(Motion.quick) { selectedTab = tab }`, which `DashboardScreenAlt` then uses to swap the body content.

### Avatar menu

Opens a SwiftUI `Menu` with three rows:
- **Profile** (`person.crop.circle`)
- **Settings** (`gearshape`)
- Divider
- **Sign out** (`role: .destructive`, `rectangle.portrait.and.arrow.right`)

TopNav owns the chrome; the caller wires what each callback does. On iPad the menu renders as a popover anchored to the avatar; on iPhone as an action sheet. No custom presentation logic needed — stock iOS Menu does both.

## Public API

```swift
struct TopNav: View {

    enum Tab: String, Hashable, CaseIterable, Identifiable {
        case home, spaces, fileCabinet, ledger    // 4 tabs (Warranties + Plans dropped 2026-05-27)
    }

    @Binding var selectedTab: Tab
    @Binding var searchText: String
    @Binding var themeMode: TopBar.ThemeMode   // reuse TopBar's enum
    var avatarInitial: Character = "L"

    var onAdd:         () -> Void = {}
    var onProfileTap:  () -> Void = {}
    var onSettingsTap: () -> Void = {}
    var onSignOutTap:  () -> Void = {}
}
```

## Composition

- `DsTabItem` (Primitive, 🟡 pending vet) — × 4
- `DsSearchField` (Primitive, ✅ locked)
- `SignalButton` (Primitive, ✅ locked)
- `DsAvatar` (Primitive, ✅ locked)
- Native SwiftUI `Menu` + `Picker` — theme switcher
- Native SwiftUI `Menu` + `Button` rows — account menu

Reuses `TopBar.ThemeMode` enum directly — same vocabulary, no duplication.

## Rules

- **Borderless content, no surface chrome.** Same as `TopBar` — TopNav lays out controls directly on the Screen's paper background. The Screen (DashboardScreenAlt) owns outer padding + safe-area handling.
- **Tab selection is single-state.** Exactly one tab is active at any moment. No multi-select.
- **Right cluster order: theme → search → ADD → avatar.** Visual weight increases left-to-right: theme is the lightest (icon-only utility), search is the dominant input, ADD is the signal CTA, avatar is the personal/identity terminator at the far edge.
- **Theme menu trigger is bare (no chrome).** No fill, no border. 44pt invisible tap target via `.contentShape`. Mirrors TopBar's pattern.
- **Avatar tap = account menu, never direct navigation.** Tapping the avatar always opens the menu — never jumps straight to Profile or Settings. iOS-canonical pattern (Mail, Calendar, Maps).

## Cross-references

- Used by: `DashboardScreenAlt` (Screen, 🟡 experimental)
- Sibling chrome: `TopBar` (locked) — used by `DashboardScreen` (locked). The two chromes coexist during the A/B vet; one wins after iPad use.
- Uses: `DsTabItem`, `DsSearchField`, `SignalButton`, `DsAvatar`, `IconCatalog.Theme`, `IconCatalog.Action.add`, `Space.{tight, bodyPadding, tapTarget, hairline}`, `Type.Body.md`, `Type.Data.xs`, `TextToken.primary`, `Motion.quick`

## Decisions log

- **2026-05-27 — Avatar tap opens an account menu, not direct nav** (Luis option 1A from a 3-option menu). Settings lives inside the menu, not as a sixth tab — keeps the tab row reserved for content sections, not utility.
- **DsTabItem active style — subtle pill (Option C) → full invert (Luis 2026-05-27 same-day vet).** Initial active treatment was ink05 fill + ink20 border (the subtle-pill option). Vet flipped it to full invert (ink fill + paper text) so the active tab reads as a primary affordance, not a chip. See `primitives/ds-tab-item.md` for the full iteration history.
- **4 fixed tabs (was 5).** Warranties + Plans dropped Luis 2026-05-27 — content folds into File Cabinet or Ledger later. "Docs + Files" renamed to "File Cabinet" (single concrete noun reads better than the compound); "Finances" renamed to "Ledger" (matches the warmer / more-paper-feeling vocabulary). If a 5th tab is added later AND the strip overflows iPad 11" landscape, surface as a separate decision: shrink Menu typography, abbreviate labels, or introduce horizontal scroll.
