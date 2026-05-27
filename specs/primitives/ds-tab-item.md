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
            ├── .typeStyle(Type.Menu.lg)                13pt DM Sans Bold, mixed case, no tracking (dedicated nav role)
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
| **Active** | `ink` | `ink` | `paper` |
| Pressed (inactive) | `ink` | `ink` | `paper` (previews the active treatment) |
| Pressed (active) | `ink` | `ink` | `paper` (no change — already there) |

Asymmetric press animation: instant on press, `Motion.standard` (220ms) on release — matches `DsButton`/`DsKeyButton`.

## SemanticTokens used

`Type.Menu.lg` (mono Medium 14pt, no upper bake — DsSearchField pattern) · `TextToken.primary` · `BackgroundToken.primary` · `Border.Color.subtle` · `Border.Width.normal` · `Radius.md` · `Space.tapTarget` · `Motion.standard`

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
- **Font iteration 2026-05-27 (4 passes).**<br>1. Initial: `Type.Title.md` (17pt sans Medium).<br>2. Luis "smaller and bolder + same as MaintRow titles" → new `Type.Title.sm` role (13pt sans Bold), pointed both consumers at it.<br>3. Luis "lets try DsSearchField's style" → tabs switched to `Type.Label.lg.font` (14pt mono Medium, no upper bake). MaintRow stayed on Title.sm, which got bumped to 14pt.<br>4. **Luis: "this was a mistake we should have left that Sans. let's harden this, warn me before such changes even if im being explicit. I think its sensible to have a different class for the menu"** → reverted from mono → added dedicated `Type.Menu.lg` (13pt sans Bold, no tracking, mixed case). Hardened surface rule in CLAUDE.md ("warn even when explicit").
- **Active state 2026-05-27 — subtle pill → full invert.** Initial (Luis option C): `ink05` fill + `ink20` border. Same-day vet "for selected style make it like a primary black bg paper font" → switched to full invert (ink fill + paper text). Active now reads as a primary-button treatment, not a tab-chip treatment. Press collapses: active visual == pressed visual, so pressed-active is a no-op transition; pressed-inactive previews the active treatment.

## Cross-references

- Used by: `TopNav` (Component) — `specs/components/top-nav.md`
- Visual family: shares the `ink05` rest tint with `DsButton.secondary` and `DsKeyButton.healthy`
- Press family: shares invert vocabulary with `DsKeyButton`, `MaintenanceRow`, `NavRail` active
