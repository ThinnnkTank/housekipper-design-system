# NavRail — Component

**Layer:** Component
**Status:** ✅ Locked (2026-05-24)
**Implementation:** `houseKipper/houseKipper/Components/NavRail.swift`

## Overview

Primary app navigation. Vertical rail anchored to the left edge of every Screen (except onboarding), full safe-area height. Houses two clusters: a **main cluster** at top (Home, Tasks, Spaces, Alerts) and a **utility cluster** at bottom (Settings + user avatar). A flexible spacer separates them.

NavRail is a Component — composes Primitives only, owns no token values. Selected-section state is caller-driven via a `@Binding`.

**When to use:** every dashboard / detail / settings Screen.
**When NOT to use:** onboarding, full-screen sheets, modal flows. Those screens stand alone without nav chrome.

## Anatomy

```
NavRail (64pt wide × safe-area-height tall, paper2 fill, 1pt ink20 full outline, Radius.md corners)
└── VStack(spacing: Space.tight)
    ├── Main cluster (top)
    │   ├── Item: Home    (IconCatalog.Nav.home)
    │   ├── Item: Tasks   (IconCatalog.Nav.tasks)    + optional DsBadge
    │   ├── Item: Spaces  (IconCatalog.Nav.spaces)
    │   └── Item: Alerts  (IconCatalog.Nav.alerts)   + optional DsBadge
    ├── Spacer  (flexible)
    └── Utility cluster (bottom)
        ├── Item: Settings (IconCatalog.Nav.settings)
        └── DsAvatar(initial: ...)
```

### Per-item geometry

- **Tap target / visible chip:** 48×48pt (above the iOS 44pt minimum). The extra height gives icon+label content (~30pt) more breathing room than 44pt allowed (7pt → 9pt vertical padding) and fits longer labels horizontally with full trackingLabel.
- **Content stack:** `VStack(spacing: Space.hairline)` of icon + optional label inside the chip
  - **Icon:** `Font.hkSectionTitle` (17pt) — large enough to read confidently
  - **Label:** `Font.hkNavLabel` (9pt DM Mono Medium), `HkType.trackingLabel` (+0.8), `.textCase(.uppercase)`. Same family/weight as `DsKeyButton` tile labels — one size step down (9pt vs 10pt) so the smaller character width allows the full `trackingLabel` (+0.8) used by tile labels.
  - **Settings is icon-only.** "SETTINGS" (8 chars) at 9pt + trackingLabel renders ≈49pt — overflows a 48pt chip. The gear icon (`gearshape`) is universally recognized; iOS sidebars commonly treat Settings as icon-only. Other four items keep their labels.
- **Shape:** `RoundedRectangle(cornerRadius: Radius.md)` (12pt corners — soft, not pill, not sharp)
- **Inter-item gap:** `Space.tight` (8pt)
- **Outer rail padding:** 8pt horizontal each side — 48pt chip centers inside 64pt-wide rail (8 + 48 + 8 = 64)
- **Cluster-to-cluster:** `Spacer()` between main and utility — vertical space stretches to fill safe-area height

### States per item

| State | Visual |
|---|---|
| Inactive (rest) | Transparent background. Icon + label `TextToken.primary` (ink). |
| Inactive (pressed) | `Press.soften` — slight opacity dip (0.6) on icon + label. No background. |
| **Active** (selected) | `RoundedRectangle(Radius.md).fill(TextToken.primary)` (ink fill) + icon + label both `BackgroundToken.primary` (paper). **Persistent invert** — same vocabulary as DsKeyButton's press feedback, applied here as the "you are here" indicator. |

The active treatment intentionally borrows the invert vocabulary from `DsKeyButton`'s press state — same compositional palette, different semantic role (persistent rather than transient). This conflicts with neither the severity ladder (no signal used) nor the dashed-only-for-dividers rule (no dashed strokes).

### Badges

Optional `DsBadge` overlays on Tasks + Alerts (and others as needed). Top-right of the 44pt chip, using `Inventory.badgeOverhangRect` (8pt) — same overhang as rect key tiles. Severity → badge mode follows the standard mapping: `attention` → `.count(N)`, `urgent` → `.urgent`, `healthy` → no badge.

## Public API

```swift
struct NavRail: View {
    enum Section: CaseIterable {
        case home, tasks, spaces, alerts, settings
    }

    @Binding var selected: Section
    var avatarInitial: Character = "L"
    var tasksBadge: BadgeState = .none
    var alertsBadge: BadgeState = .none

    enum BadgeState {
        case none
        case attention(Int)   // count
        case urgent
    }
}
```

Caller drives `selected` via a binding (typically owned by the root Screen). Avatar initial and badges are flat props for now — when the User model and notification system land, these tie into the model layer.

## Composition

NavRail composes:
- `DsAvatar` (Primitive, ✅ locked) — bottom utility slot
- `DsBadge` (Primitive, ✅ locked) — optional overlay on any item

It does NOT extract a `DsNavItem` Primitive — nav-item geometry is component-internal (44pt chip, 12pt corner, invert active state) and not reused elsewhere. If a future surface needs the same chip shape, we'll extract then.

## Rules

- **Settings lives in the utility cluster**, not the main cluster — that legacy rule from the paprLCD spec survives.
- **No dashed strokes anywhere on NavRail.** The legacy "active = dashed ink border" rule was incompatible with our `foundations.md → Border` discipline (dashed reserved for `DsDivider`). Replaced by the persistent-invert treatment above (Luis 2026-05-24, option B).
- **Severity badges only.** Don't use NavRail badges for non-actionable counts (e.g. "12 rooms total"). Badges signal "needs your attention" — same discipline as DsKeyButton.
- **Rail width is fixed at 64pt.** Don't responsive-collapse; on iPhone, the screen omits NavRail entirely rather than shrinking it. iPad portrait + landscape both render at 64pt.
- **NavRail does not own positioning.** Parent Screen places NavRail in an `HStack` alongside the main canvas. NavRail doesn't `.ignoresSafeArea` on its own; the Screen decides whether the rail extends under safe areas.
- **NavRail is a self-defined floating card.** Full outline (`Border.Color.subtle` × 1pt, all four edges) + `Radius.md` rounded corners + paper2 fill. Earlier draft used a right-edge-only stroke with sharp corners, assuming "always docked to screen leading edge" — that locked the Component to one layout context. The self-defined card works whether docked to the edge (left corners align with the screen frame, visually neutral) or floating with padding (full card definition).

## Cross-references

- Uses: `DsAvatar`, `DsBadge`, `IconCatalog.Nav`, `Space.tapTarget` / `Space.tight`, `Radius.md`, `BackgroundToken.primary` / `.secondary`, `TextToken.primary`, `Border.Color.subtle`, `Border.Width.normal`, `Font.hkSectionTitle`, `Inventory.badgeOverhangRect`
- Used by: every Screen except onboarding / sheets / modals
- Active-state vocabulary peer: `DsKeyButton` press state (same invert palette, persistent here)

## Decisions log (this spec)

- **Rail width 64pt** (Luis 2026-05-24): iPad sidebar conventions sit 60–80pt. 64pt comfortably hosts a 44pt tap target with 8pt left padding.
- **Active state = persistent invert** (Luis 2026-05-24, option B): rejected the legacy "dashed ink border" treatment which conflicts with our dashed-only-for-dividers rule. Borrows the invert vocabulary from DsKeyButton press feedback — same composition, persistent role.
- **No new DsNavItem Primitive** (Luis 2026-05-24): item rendering inlined inside NavRail. Component-internal geometry; extract only when a second surface reuses the chip shape.
- **IconCatalog from day one** (Luis 2026-05-24): NavRail consumes `IconCatalog.Nav.*` rather than literal SF Symbol strings. Sets the call-site convention going forward.
- **Tiny labels under icons** (Luis 2026-05-24, iter 2): each chip's content is `VStack { icon, label }` rather than icon-only. Labels uppercase mono + trackingTight (-0.6) to fit "SETTINGS" inside the 44pt chip. Both icon and label flip to paper on active. Improves scannability vs icon-only — a nav rail with no labels reads as decoration rather than navigation.
- **Label font journey** (Luis 2026-05-24, iters 2-4):
  - iter 2: `hkCaption` (mono Regular 9pt, trackingTight -0.6) — read too thin against the chip
  - iter 3: `hkButton` (mono Medium 10pt, trackingTight -0.6) — heavier, but tight tracking felt cramped
  - briefly explored DM Sans Bold for more weight; aborted (only have Light/Regular/Medium/Bold cuts bundled, and Bold at 10pt still didn't read decisively heavier than mono medium)
  - iter 4: `hkButton` + `trackingSnug` (+0.2) — closer, but +0.2 tracking still felt cramped next to DsKeyButton's +0.8 rhythm
  - iter 5: new `hkNavLabel` role = DM Mono Medium 9pt + `trackingLabel` (+0.8) — same family/weight/tracking as `DsKeyButton`, one size step smaller. At 44pt chip width "SETTINGS" still overflowed (~49pt > 44pt).
  - iter 6 (landed): chip 44 → 48pt (more vertical breathing room AND more horizontal room) + Settings becomes icon-only since "SETTINGS" still doesn't fit cleanly at 48pt with full trackingLabel. Four labeled items + one icon-only (Settings) at the bottom.
