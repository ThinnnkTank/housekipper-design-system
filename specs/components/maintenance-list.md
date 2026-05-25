# MaintenanceList — Component

**Layer:** Component
**Status:** 🟡 Implemented (2026-05-24) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/Components/MaintenanceList.swift`
**Reference:** Luis 2026-05-24 dashboard reference (UPCOMING MAINTENANCE card)

## Overview

Container for upcoming-maintenance rows. Pairs an eyebrow header with a `VIEW ALL →` secondary affordance, then renders a vertical stack of `MaintenanceRow`s separated by dashed dividers. **No outer card chrome** — the list sits directly on the Screen's paper background, consistent with `TopBar` and the legacy `actionsheet` family.

MaintenanceList is a Component — composes `MaintenanceRow`, `DsButton`, `DsDivider` only. Owns no token values.

**When to use:** the dashboard's Upcoming Maintenance region. Any "what's coming up" surface that needs the chronological-list treatment.
**When NOT to use:** the hero "what's most pressing" surface (use `NextUpCard`). Settings rows (different visual family — TBD).

## Anatomy

```
MaintenanceList
└── VStack(spacing: Space.bodyPadding)
    ├── header
    │   └── HStack
    │       ├── Text("UPCOMING MAINTENANCE")        Type.Label.xs + TextToken.primary
    │       ├── Spacer
    │       └── DsButton("VIEW ALL",                .secondary, .small, trailing arrow.right
    │                    variant: .secondary,
    │                    size: .small,
    │                    icon: "arrow.right",
    │                    iconPosition: .trailing)
    │       .padding(.horizontal, Space.cardPadding)
    │
    └── VStack(spacing: 0)                          deliberate zero gap
        ForEach(items):
        ├── MaintenanceRow(...)
        └── DsDivider(.dashed)                       only between rows — never below the last
            .padding(.horizontal, Space.cardPadding)
```

### Geometry

- **Header/list gap:** `Space.bodyPadding` (16pt)
- **Inter-row gap:** zero — rows own their full vertical rhythm via internal `Space.cardPadding`. Dividers sit flush between them with horizontal padding matching the rows' inset.
- **Divider inset:** `Space.cardPadding` (20pt) on each side — pulls the dashes away from the container edges so they read as separators within the list, not framing rules of the whole list.
- **Header inset:** `Space.cardPadding` (20pt) horizontal so eyebrow + VIEW ALL align with the row content underneath.

### States (v0)

- **Rest:** as above.
- **Empty (`items.isEmpty`):** v0 just renders the header. Empty-state messaging (`"All clear — no upcoming maintenance"`) is deferred to Screen wiring.
- **Pressed row:** handled inside `MaintenanceRow` (invert press). MaintenanceList doesn't override.

### Future states (BACKLOG)

- **Snoozed:** when the user snoozes the urgent `NextUpCard` task, the corresponding `MaintenanceRow` lifts into MaintenanceList with a *paused* treatment — orange (signal) accent + pause-glyph indicator. Cross-Component interaction; lands during Screen wiring.
- **Completed:** when the user marks the urgent `NextUpCard` task complete, the corresponding `MaintenanceRow` (if visible) gets a *strikethrough* on the title + muted foreground. Also cross-Component; lands during Screen wiring.

These are referenced here and tracked in `BACKLOG.md` → *Snoozed / completed row treatments* — implemented when the Dashboard Screen wires NextUpCard ↔ MaintenanceList.

## Public API

```swift
struct MaintenanceList: View {
    struct Item: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let location: String
        let date: String
        let frequency: String
        let assignee: Character
    }

    let items: [Item]
    var onTapItem: (Item) -> Void = { _ in }
    var onViewAll: () -> Void = {}
}
```

Caller passes a flat `[Item]` and two callbacks. When the maintenance model lands, `Item` is replaced with the real `MaintenanceTask` model and the conversion happens at the Screen layer.

## Composition

MaintenanceList composes:
- `MaintenanceRow` (Component, 🟡 pending vet) — each row
- `DsButton` (Primitive, ✅ locked) — VIEW ALL → secondary
- `DsDivider` (Primitive, ✅ locked) — dashed separator between rows

It does NOT extract a `ListHeader` Primitive — the eyebrow + VIEW ALL pattern is currently single-use here. If a second surface needs the same header treatment (Active Project carousel? Calendar? TBD), extract then.

## Rules

- **No outer card chrome.** Consistent with `TopBar` and the legacy `actionsheet` family — the list sits directly on Screen paper. Adding a border or background would over-frame and clash with the dashed divider rhythm.
- **Dashed dividers between rows only.** Never below the last row, never above the first. Eyebrow header is separated from the list by `Space.bodyPadding` whitespace, not a divider.
- **VIEW ALL button is `.secondary` size `.small`.** Matches the inline-affordance scale used in section headers across the dashboard. Don't promote to `.large` here — it would compete with the eyebrow's typographic weight.
- **Zero inter-row gap (`spacing: 0`) is deliberate.** Audit-exempted on the `VStack(spacing: 0)` line. Rows + dividers own all the rhythm; adding a gap would double the visual spacing because each row already has cardPadding.

## Cross-references

- Uses: `MaintenanceRow`, `DsButton`, `DsDivider`, `Type.Label.xs`, `TextToken.primary`, `Space.bodyPadding` / `.cardPadding`
- Used by: `DashboardScreen` (TBD) — right column
- Reference family: `TopBar` (also borderless content sitting on Screen paper)

## Decisions log (this spec)

- **Borderless / no outer card** (Luis 2026-05-24, ref image): matches the dashboard reference. The list breathes inside the right column without a competing frame.
- **Dashed dividers between rows** (Luis 2026-05-24, ref image): consistent with the dashed-only-for-dividers rule. `DsDivider(.dashed)` is the canonical primitive.
- **VIEW ALL: `.secondary` `.small` with trailing `arrow.right`** (Luis 2026-05-24, ref image): inline section affordance, doesn't compete with the eyebrow.
- **Eyebrow scale-up + VIEW ALL → `.micro`** (Luis 2026-05-25 dashboard vet): bumped "UPCOMING MAINTENANCE" eyebrow `Type.Label.xs` (10pt) → `Type.Label.sm` (12pt — note: Label.sm was 13pt at the time of this bump, then reverted to 12pt later in the same session for tile-label density) for more visual weight against the row content. VIEW ALL → button correspondingly downsized `.small` → `.micro` to keep it inline-secondary against the now-bigger eyebrow rather than competing.
- **`Item` struct nested inside MaintenanceList** (2026-05-24): simple flat shape for now. When the real model arrives, it replaces `Item` at the Screen layer and MaintenanceList accepts the model directly.
- **Snoozed + completed treatments deferred to Screen wiring** (Luis 2026-05-24): these are cross-Component interactions (NextUpCard mark-complete / snooze → MaintenanceList row state), not self-contained list behavior. Logged in BACKLOG; implemented during Screen assembly.
