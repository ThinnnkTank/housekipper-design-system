# DsTabItem — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-27) — built for `TopNav` alt-dashboard chrome; locks when DashboardScreenAlt is vetted
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsTabItem.swift`

## Overview

Tab strip item for top-tab navigation. **Composes `DsButton` directly** with variant-by-state and the `typeStyle:` override pointed at `Type.Menu.lg`. No own chrome — DsButton owns the geometry, fills, borders, press animation; DsTabItem owns the role + typography choice.

Active state = `DsButton(.primary, .micro)` (capsule + ink fill + paper text). Inactive = `DsButton(.ghost, .micro)` (bare text, no chrome). The button's standard "soften" press strategy carries over.

**When to use:** horizontal tab strips. Current consumer: `TopNav` (4 tabs across the alt dashboard chrome).
**When NOT to use:** primary affordances (use `DsButton` directly). Severity surfaces (use `DsKeyButton` / `DsStatusDot`).

## Anatomy

```
DsTabItem
└── DsButton
        label:     <tab name>
        variant:   isActive ? .primary : .ghost
        size:      .micro            (24pt visible height; ≥44pt tap area)
        shape:     .pill             (Capsule — matches CalendarMonth's date pill)
        typeStyle: Type.Menu.lg      (sans Bold 13pt mixed case, no tracking — overrides Label.sm default)
        action:    onTap
```

## Public API

```swift
struct DsTabItem: View {
    let label: String
    var isActive: Bool = false
    let onTap: () -> Void
}
```

Three params — minimal surface; everything else inherited from DsButton.

## Composition

DsTabItem composes:
- `DsButton` (Primitive, ✅ locked) — `.primary.micro` when active, `.ghost.micro` when inactive
- `Type.Menu.lg` (SemanticToken, ✅ locked 2026-05-27) — typography override

It does **NOT** own its own chrome rendering, palette resolution, or press animation. All of that comes from DsButton. This is the lesson of the C-1 refactor (Luis 2026-05-27): "if you had a mind for reusability you could have said, ok i can reuse these two style in the menu, but ill make Type.Menu because this may change in other templates."

## States

States are inherited from DsButton:

| State | Inherited from |
|---|---|
| Inactive rest | `DsButton(.ghost, .micro)` rest — bare text, no fill, no border |
| Inactive pressed | `DsButton(.ghost, .micro)` pressed — soften (primary-disabled palette) |
| **Active rest** | `DsButton(.primary, .micro)` rest — ink fill + paper text + capsule |
| Active pressed | `DsButton(.primary, .micro)` pressed — invert (secondary-disabled palette) |

Animation: asymmetric press feedback inherited from DsButton — instant on press, `Motion.standard` (220ms) on release.

## SemanticTokens used

Only via DsButton composition:
- `Type.Menu.lg` (the one override)
- DsButton internally: `ActionToken.{primary, ghost}`, `Space.tapTarget`, `Space.buttonHeightMicro`, `Space.buttonPaddingSm`, `Border.Width.normal`, `Motion.standard`, `Radius.md` (via Capsule shape — no rounded rectangle here)

## Example

```swift
HStack(spacing: Space.tight) {
    DsTabItem(label: "Home",         isActive: tab == .home,        onTap: { tab = .home })
    DsTabItem(label: "Spaces",       isActive: tab == .spaces,      onTap: { tab = .spaces })
    DsTabItem(label: "File Cabinet", isActive: tab == .fileCabinet, onTap: { tab = .fileCabinet })
    DsTabItem(label: "Ledger",       isActive: tab == .ledger,      onTap: { tab = .ledger })
}
```

## Decisions log

- **2026-05-27 — Composed via DsButton + `typeStyle` override (Luis C-1 refactor).** Earlier the same day, DsTabItem owned its own chrome (RoundedRectangle fill + overlay + size constants). After Luis raised the reusability lens ("you could have said, ok i can reuse these two styles in the menu"), refactored: DsButton gained an optional `typeStyle: TypeStyle?` param; DsTabItem became a 5-line wrapper that picks the variant by `isActive` and passes `Type.Menu.lg`. `Type.Menu.lg` stays the dedicated nav role so future templates can change nav typography without touching DsButton.
- **Active state — full invert (`.primary.micro`).** Initial implementation used the subtle-pill (ink05 fill + ink20 border) per Luis option C; same-day vet flipped to "primary black bg paper font." Active reads as a primary affordance, not a chip.
- **Capsule shape, not RoundedRectangle.** Matches CalendarMonth's date pill (also `DsButton(.primary, .micro)` capsule). Tab chip aesthetic stays consistent with the calendar pill aesthetic.
- **Font iteration history (4 passes, 2026-05-27).**<br>1. `Type.Title.md` (17pt sans Medium).<br>2. `Type.Title.sm` (13pt sans Bold) — Luis: "smaller and bolder."<br>3. `Type.Label.lg.font` (14pt mono Medium, no upper bake) — Luis: "lets try DsSearchField's style." **Reverted same day** ("this was a mistake we should have left that Sans").<br>4. `Type.Menu.lg` (13pt sans Bold, dedicated role) — final. CLAUDE.md surface rule hardened in this session: warn before face/family swaps even when user is explicit.

## Cross-references

- Composes: `DsButton` (Primitive, ✅) — see `primitives/ds-button.md` for the chrome/state/animation source-of-truth
- Used by: `TopNav` (Component) — `specs/components/top-nav.md`
- Type role: `Type.Menu.lg` — see `semantic-tokens.md` Typography table
