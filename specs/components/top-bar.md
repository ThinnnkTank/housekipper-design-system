# TopBar — Component

**Layer:** Component
**Status:** 🟡 Implemented (2026-05-24) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/Components/TopBar.swift`

## Overview

The top-of-screen chrome that frames every dashboard-class Screen. Two-zone layout:

- **Left:** page heading (large sans) with optional leading icon, plus `DsWeatherChip` below
- **Right cluster:** theme menu trigger · `DsSearchField` · "+ ADD" `DsButton.primary` (in that order, trailing-flush)

Caller-driven via bindings + callbacks; TopBar owns no app state.

**When to use:** dashboard, room detail, project detail Screens — any surface with a persistent header area.
**When NOT to use:** modals/sheets (those have their own chrome). Onboarding (separate flow without nav chrome).

## Anatomy

```
TopBar (borderless — no fill, no outline, no internal padding)
└── HStack(spacing: Space.bodyPadding, alignment: .center)
    ├── VStack(alignment: .leading, spacing: Space.hairline)         [LEFT ZONE — flex]
    │   ├── HStack(spacing: Space.tight)
    │   │   ├── Image(headingIcon)?    SF Symbol, hkPageHeading-anchored, signal-tinted
    │   │   └── Text(heading)          .typeStyle(Type.Title.xl) — 26pt DM Mono Medium + trackingTight (H1)
    │   └── DsWeatherChip(summary: weatherSummary)
    ├── Spacer()
    └── HStack(spacing: Space.bodyPadding, alignment: .center)       [RIGHT CLUSTER — fixed]
        ├── Menu { theme picker } label: { themeIcon + chevron.down } — 44pt tap target, bare (no chrome)
        ├── DsSearchField(text: $searchText, placeholder: "Search")
        │       .frame(maxWidth: 300)             cap so the right cluster doesn't push past safe area on wide screens
        └── DsButton("+ ADD", icon: plus, variant: .primary, size: .large) { onAdd() }
```

### Theme menu

A SwiftUI `Menu` with a `Picker` inside. On iPad, presents as a native popover anchored to the trigger (matches the reference image). On iPhone, presents as an action sheet from the bottom — both are stock iOS, no custom presentation logic.

```swift
Menu {
    Picker("Theme", selection: $themeMode) {
        Label("Light", systemImage: IconCatalog.Theme.light).tag(ThemeMode.light)
        Label("Dark",  systemImage: IconCatalog.Theme.dark).tag(ThemeMode.dark)
        Label("Auto",  systemImage: IconCatalog.Theme.auto).tag(ThemeMode.auto)
    }
} label: { ... }
```

The trigger label is a bare HStack: current-theme SF Symbol + small chevron-down indicator. No surrounding fill or border — utility control, transparent chrome. Native iOS Menu provides the popover dismiss + selection-checkmark behavior for free.

### Right-cluster vertical alignment

All three elements (theme trigger, search field, ADD button) center-align on the heading's baseline area. Search field is 40pt tall (`Space.buttonHeightLg`); ADD button is 40pt (`DsButton.large`); theme trigger is sized to 44pt (`Space.tapTarget`) so its hit area matches without making the visible glyph oversized.

### Heading icon

Optional `headingIcon: String?` parameter — when set, renders an SF Symbol before the heading text. The reference image shows an orange sun icon next to "7630 Ladson Ter" suggesting it reflects the current weather state. Color is `StatusToken.tint(.urgent)` (signal) to match the reference's orange tint.

If `headingIcon` is nil, the heading text sits flush to the leading edge.

## Public API

```swift
struct TopBar: View {
    enum ThemeMode: String, Hashable, CaseIterable {
        case light, dark, auto
    }

    let heading: String                 // typically house.name from the active House model
    var headingIcon: String?            // SF Symbol name (expected via IconCatalog.*); nil hides
    let weatherSummary: String          // dummy text for DsWeatherChip; future: structured weather data
    @Binding var searchText: String
    @Binding var themeMode: ThemeMode
    var onAdd: () -> Void
}
```

## Composition

TopBar composes:
- `DsWeatherChip` (Primitive) — weather summary line
- `DsSearchField` (Primitive, ✅ locked) — search input
- `DsButton` (Primitive, ✅ locked) — "+ ADD" affordance, primary variant
- Native SwiftUI `Menu` + `Picker` — theme switcher (action sheet on iPhone, popover on iPad — stock iOS)

It does NOT extract a `DsIconMenuTrigger` Primitive for the theme button. The bare-icon-plus-chevron is a one-off composition; promote to a Primitive only if a second surface adopts the same pattern.

## Rules

- **TopBar is layout-agnostic about positioning AND borderless.** Parent Screen places it (typically pinned to the top safe area) and owns edge insets / safe-area handling. TopBar applies no fill, outline, padding, or shadow of its own — per the dashboard reference, its content sits directly on the Screen's paper background. Surrounding cards (NavRail, SpaceCard, etc.) have their own chrome; TopBar does not.
- **Theme menu defers to iOS-native presentation.** Don't reach for the (backlog) ActionSheet pattern just for theme; native Menu does the right thing on every device class.
- **DsWeatherChip is dummy.** Caller passes a pre-formatted string. When real weather data integrates, the chip's internals change — TopBar's API stays.
- **Heading icon stays optional.** Don't force every screen to set one; some surfaces (settings, onboarding) have no natural icon.

## Cross-references

- Uses: `DsWeatherChip`, `DsSearchField`, `DsButton`, `IconCatalog.Theme`, `IconCatalog.Action.add`, `Type.Title.xl`, `Space`, `BackgroundToken`, `TextToken`, `Border`, `Radius`, `StatusToken`
- Used by: Dashboard Screen (TBD)
- Composition peer: `NavRail` (the left-edge counterpart)

## Decisions log (this spec)

- **Right-cluster order: theme → search → ADD** (Luis 2026-05-24): originally I proposed search-theme-ADD; Luis corrected. The theme trigger is the lightest-weight control (utility), search is the dominant input, ADD is the heaviest (primary action) — visual weight increases left-to-right within the cluster.
- **Native `Menu` + `Picker` for theme** (Luis 2026-05-24): "icon button, popover so it remains pressed until modal is dismissed." iOS's stock `Menu` does exactly this on iPad (popover anchored to trigger, dismisses on outside tap, the trigger stays in its pressed-emphasis state while the menu is open). No custom action sheet needed; defers the `ActionSheet` backlog item.
- **`DsWeatherChip` as a Primitive** (Luis 2026-05-24): even though current implementation is just styled text, the slot is reserved as a Primitive so future weather-data integration can be transparent to callers.
- **Theme menu trigger is bare (no chrome)** (Luis 2026-05-24, from reference image): no fill, no border around the icon+chevron. Reads as utility, not as a heavy button. 44pt invisible tap target via `.contentShape`.
- **Heading icon optional, signal-tinted when present** (Luis 2026-05-24, from reference image): the orange-sun-next-to-address treatment from the reference. Caller decides if the screen has one; color uses signal (`StatusToken.tint(.urgent)`) to match the reference's orange.
- **Search field capped at 300pt** (Luis 2026-05-24, iter 3): on wide screens the search field would otherwise grow with the right cluster's available space, pushing the theme trigger toward the safe-area edge. Constrained via `.frame(maxWidth:)` at the TopBar call site (kept as a `private static let` rather than a Space token — component-internal layout value).
- **Borderless — no surface of its own** (Luis 2026-05-24, iter 2): initial draft wrapped TopBar in paper2 fill + outline + Radius.md corners + cardPadding, matching the chrome of NavRail/SpaceCard. Luis flagged via the reference image: in the real dashboard, TopBar's content sits directly on the page background; the surrounding cards have chrome, the heading does not. Removed all surface treatment — Component is now pure content layout. The swatch panel's outer `panel(...)` wrapper provides containerization for isolated vetting only.
