# MaintenanceRow — Component

**Layer:** Component
**Status:** ✅ Locked (2026-05-25)
**Implementation:** `houseKipper/houseKipper/Components/MaintenanceRow.swift`
**Reference:** legacy `_legacy/paprlcd-vnext-style-sheet.html` → "Card-chip family" → split chip variant

## Overview

Single upcoming-maintenance task row. Lives inside `MaintenanceList` (TBD) which provides the outer card chrome. Press strategy: **invert** — pressed inverts the row background to ink and every glyph (plus the avatar) to paper. Same vocabulary as `DsKeyButton` press + `NavRail` active.

MaintenanceRow is a Component — composes `DsAvatar` and owns no token values; all visual chrome (typography, foreground, fill, radius) routes through SemanticTokens.

**When to use:** any vertical list of maintenance tasks. Dashboard's Upcoming Maintenance section is the primary consumer.
**When NOT to use:** the hero "what's most pressing" surface (use `NextUpCard`). Calendar day cells (use `DsStatusDot`). Settings rows (different visual family — TBD).

## Anatomy

```
MaintenanceRow (full-width, Radius.sm rounded press surface)
└── HStack(spacing: Space.bodyPadding)
    ├── DsAvatar(initial: assignee, style: .outline)   leading — 32pt ring + ink letter
    ├── VStack(alignment: .leading) {
    │     Text(title)                     Type.Title.md (17pt DM Sans Medium)
    │     Text(location)                  Type.Label.sm + TextToken.secondary
    │   }
    ├── Spacer()
    └── VStack(alignment: .trailing) {
          Text(date)                      Type.Data.sm (12pt DM Mono Regular — tabular)
          Text(frequency)                 Type.Label.xs + TextToken.secondary
        }
```

### Geometry

- **Padding:** `Space.cardPadding` (20pt) all around — gives the row breathing room inside the parent container
- **Min height:** `Space.tapTarget` (44pt) — meets iOS minimum tap area even when the row's natural height is smaller
- **Inner column spacing:** `Space.hairline` (2pt) inside both VStacks — title-to-meta and date-to-frequency stay visually paired
- **Inter-section gap:** `Space.bodyPadding` (16pt) between avatar / left column / right column
- **Corner radius:** `Radius.sm` (8pt) — soft press surface; clips the pressed-state ink fill cleanly
- **Inter-row gap** (caller-controlled): `Space.tight` (8pt) per current swatch usage. Final value locks when `MaintenanceList` ships.

### States

| State | Visual |
|---|---|
| Rest | Transparent background. Title `TextToken.primary`. Location + frequency `TextToken.secondary` (ink60). Date `TextToken.primary`. Avatar: ink fill, paper letter. |
| Pressed | `RoundedRectangle(Radius.sm).fill(TextToken.primary)` — full-row ink fill. All text → `BackgroundToken.primary` (paper). Avatar inverted via `.colorInvert()` — paper fill, ink letter. |

Asymmetric press animation: instant on press, `Motion.standard` (300ms) on release — matches `DsButton` + `DsKeyButton`. Hit area is the full Radius.sm shape via `.contentShape(...)`.

### Press-invert mechanics

The avatar carries its own ink-fill rendering. Naively flipping the row foreground to paper would leave the avatar untouched (still ink-on-ink at press time → invisible). The fix is `.colorInvert()` applied to the avatar only when `pressed == true`. It flips the already-rendered avatar's colors in-place without leaking knowledge of avatar internals into MaintenanceRow.

A tiny `colorInvert(when:)` View extension lives at file scope to avoid the ternary-typed-view headache (different return types per branch).

## Public API

```swift
struct MaintenanceRow: View {
    let title: String        // "Coffee machine descale"
    let location: String     // "Kitchen"
    let date: String         // "May 2"
    let frequency: String    // "Every 90 days"
    let assignee: Character  // "L"
    let onTap: () -> Void
}
```

All content is flat strings + a single `Character` for the avatar. When the maintenance model lands, these tie into the model layer (a `MaintenanceTask` struct probably).

## Composition

MaintenanceRow composes:
- `DsAvatar` (Primitive, ✅ locked) — assignee letter

It does NOT compose a `DsStatusDot` — severity treatment is deferred. The legacy reference doesn't show a status indicator on these rows (urgency comes from sort order + `NextUpCard` lifting the most pressing item out). If a future surface needs an inline status dot on the row, we add a `severity` param.

It does NOT compose a `DsButton.micro` (e.g. checkmark). The row's primary affordance is the tap (opens detail). Inline actions would create a competing target inside the press-invert surface. If quick-complete becomes needed, surface as a swipe action (iOS-native pattern), not a button.

## Rules

- **Row chrome is provided by the caller** (`MaintenanceList` or any other container). MaintenanceRow renders no outer border, no fill at rest, no shadow.
- **Press invert is the only state feedback.** No hover, no focus highlight beyond what SwiftUI provides for free.
- **Severity is not visualized here in v0.** Urgent items belong in `NextUpCard`; "needs attention" items land in the list and rely on sort + the date string ("Due in 2 days") to convey urgency. Add a `severity` param later if real screens demand it.
- **Title `lineLimit(1)`.** Long task titles truncate rather than wrap — keeps row heights uniform across a list. Location also `lineLimit(1)`.
- **Date column right-alignment is intentional.** Tabular date (`Type.Data.sm` DM Mono Regular) keeps glyph-stable across rows; right-aligning forms a visual second column that scans naturally for "next thing up."

## Cross-references

- Uses: `DsAvatar`, `Type.Title.md` / `Type.Label.sm` / `Type.Data.sm` / `Type.Label.xs`, `TextToken.primary` / `.secondary`, `BackgroundToken.primary`, `Radius.sm`, `Space.cardPadding` / `.bodyPadding` / `.hairline` / `.tight` / `.tapTarget`, `Motion.standard`
- Used by: `MaintenanceList` (TBD) — vertical stack with container chrome
- Press-strategy peers: `DsKeyButton` (transient invert on press), `NavRail` item (persistent invert when active)

## Decisions log (this spec)

- **Chip-style, not divider-separated** (Luis ref: legacy paprLCD "card-chip" family, 2026-05-24): each row is a self-contained press surface with rounded corners. Inter-row separation is whitespace (`Space.tight` gap), not horizontal rules. Matches the legacy reference and gives the press-invert ink fill a clean clipping bounds.
- **Press strategy: invert** (per Dashboard spec line 72): same vocabulary as `DsKeyButton` press + `NavRail` active. Reinforces the system-wide "tactile feedback = invert" pattern.
- **No status dot in v0**: the legacy reference doesn't show one on these rows; urgency is communicated via sort order + the date string. Add when a real screen proves it's needed.
- **No inline DsButton (e.g. checkmark)**: the row's full surface is the tap target. Inline buttons would create competing targets inside the press-invert area; quick-complete belongs as a swipe action (iOS-native) when it lands.
- **`.colorInvert(when:)` helper for the avatar** (2026-05-24): the avatar carries its own ink ring + letter (outline mode). Without an inversion step, the ring and letter disappear against the pressed ink-fill row. SwiftUI's `.colorInvert()` flips the already-rendered avatar's colors in-place; gating it via a tiny `@ViewBuilder` extension keeps the conditional clean.
- **Outline avatar** (Luis 2026-05-24, ref image): MaintenanceRow uses `DsAvatar(style: .outline)` rather than the default filled style. The row's body (title + location + date) carries the visual weight; the assignee should accompany but not compete. Decision is logged on the DsAvatar spec — `.outline` was added as a new variant on the existing Primitive rather than introducing a separate Primitive.
- **Min height `Space.tapTarget` (44pt)**: row's natural height (avatar 32pt + 20pt padding × 2 = 72pt) clears 44pt easily, but the floor is explicit so future content variants stay accessible.
