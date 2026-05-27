# DsTabItem — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-27) — built for `TopNav` alt-dashboard chrome; locks when DashboardScreenAlt is vetted
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsTabItem.swift`

## Overview

Single tab item for top-tab navigation strips. Renders bare text by default; active state adds a subtle pill chrome (`ink05` fill + `ink20` border + `Radius.md`). Press strategy: **invert** — chip flips to ink fill + paper text, matching `DsKeyButton` / `MaintenanceRow` / `NavRail` active vocabulary.

**When to use:** any horizontal tab strip. Current consumer: `TopNav` (5 tabs across the alt dashboard chrome).
**When NOT to use:** primary affordances (use `DsButton`). Severity-laden status indicators (use `DsKeyButton` or `DsStatusDot`).

## Anatomy

```
DsTabItem
└── Button(action: onTap) { Color.clear }
    └── DsTabItemStyleImpl (computes palette per state)
        └── Text(label)
            ├── .font(Type.Label.lg.font)               14pt DM Mono Medium, no upper bake (DsSearchField pattern)
            ├── foreground: ink (rest/active) or paper (pressed)
            ├── padding: 12pt H · 8pt V (primitive-internal carve-out)
            ├── background: RoundedRectangle(Radius.md).fill(...)
            │     fill = ink05 (active) · ink (pressed) · clear (inactive)
            └── overlay:    RoundedRectangle(Radius.md).strokeBorder(...)
                  border = ink20 (active) · ink (pressed) · clear (inactive)
        Outer: .frame(minHeight: Space.tapTarget)  ≥44pt tap area
```

## Public API

```swift
struct DsTabItem: View {
    let label: String
    var isActive: Bool = false
    let onTap: () -> Void
}
```

## States

| State | Fill | Border | Foreground |
|---|---|---|---|
| Inactive (rest) | clear | clear | `ink` |
| **Active** | `ink05` | `ink20` (`Border.Color.subtle`) | `ink` |
| Pressed (any) | `ink` | `ink` | `paper` |

Asymmetric press animation: instant on press, `Motion.standard` (220ms) on release — matches `DsButton`/`DsKeyButton`.

## SemanticTokens used

`Type.Label.lg.font` (mono Medium 14pt, no upper bake — DsSearchField pattern) · `TextToken.primary` · `BackgroundToken.primary` · `Border.Color.subtle` · `Border.Width.normal` · `Radius.md` · `Space.tapTarget` · `Motion.standard`

Primitive-internal carve-outs: `horizontalPadding: 12` · `verticalPadding: 8`.

## Example

```swift
HStack(spacing: Space.tight) {
    DsTabItem(label: "Home",         isActive: tab == .home,    onTap: { tab = .home })
    DsTabItem(label: "Spaces",       isActive: tab == .spaces,  onTap: { tab = .spaces })
    DsTabItem(label: "Docs + Files", isActive: tab == .docs,    onTap: { tab = .docs })
}
```

## Decisions log

- **2026-05-27 — Active style = subtle pill (Option C), not underline.** Luis picked option C from a 3-style menu (A=underline, C=subtle pill, D=typography-only). Pill reads "card-like" and inherits the `ink05` rest-tint vocabulary from `DsButton.secondary` / `DsKeyButton.healthy`.
- **Press strategy = invert.** Same vocabulary as DsKeyButton + MaintenanceRow + NavRail active. Keeps the DS coherent — every "card-like" interactive element flips to ink-on-press.
- **Font iteration 2026-05-27.** Three passes same day:<br>1. Initial: `Type.Title.md` (17pt sans Medium).<br>2. Luis: "needs to be smaller and bolder + same as MaintRow titles." Added new `Type.Title.sm` role (13pt sans Bold), pointed both consumers at it.<br>3. Luis: "lets try the style used in DsSearchField" → tabs switched to `Type.Label.lg.font` (14pt **DM Mono Medium**, no upper bake — same pattern DsSearchField uses for its text). MaintRow stayed on Title.sm, which got bumped to 14pt independently. The two roles are now DIFFERENT — sans Bold 14 vs mono Medium 14. Face change surfaced per CLAUDE.md.

## Cross-references

- Used by: `TopNav` (Component) — `specs/components/top-nav.md`
- Visual family: shares the `ink05` rest tint with `DsButton.secondary` and `DsKeyButton.healthy`
- Press family: shares invert vocabulary with `DsKeyButton`, `MaintenanceRow`, `NavRail` active
