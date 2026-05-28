# CalendarMonth — Component

**Layer:** Component
**Status:** ✅ Locked (2026-05-27 — padding rhythm aligned with dashboard grid)
**Implementation:** `houseKipper/houseKipper/Components/CalendarMonth.swift`
**Reference:** paprLCD vnext calendar redline (Luis 2026-05-25)

## 2026-05-27 update — paper card fill [explore]

Card gained explicit paper fill (`.background(RoundedRectangle(cornerRadius: Radius.md).fill(BackgroundToken.primary))`) to lift it visually against the new darker page bg.

## 2026-05-27 update — padding rhythm

Outer padding: `top snug/horizontal cardPadding/bottom cardPadding (12/20/20)` → `top tight/horizontal bodyPadding/bottom safeGutter (8/16/24)`. Brings the calendar onto the same internal rhythm as the hero cards and Tasks card; calendar's date pill top edge now aligns with hero eyebrows. Natural height (an earlier attempt at fixed 352pt grid-lock was reverted — `.frame(height:)` doesn't clip and natural content overflowed the card frame's top edge).

## Overview

Month-view calendar for the dashboard's right column (above MaintenanceList). Header pill + nav arrows + day-of-week row + 6×7 date grid + status dots under days + dashed-divider legend.

CalendarMonth is a Component — composes `DsButton`, `DsStatusDot`, `DsDivider`. Owns no token values; all chrome routes through SemanticTokens with primitive-internal micro-values carved out for cell + dot geometry that doesn't fit the Space ladder.

**When to use:** dashboard right column. Any "schedule + indicators at a glance" surface.
**When NOT to use:** scheduling input (a day-picker UI is a separate Component, TBD). Detail views (use a list).

## Anatomy

```
CalendarMonth (rounded ink20 border, Radius.md, paper background via Screen)
└── VStack(spacing: Space.bodyPadding)
    ├── Header
    │   └── HStack
    │       ├── DsButton(title, .primary, .micro, action: onDateTap)   ← date pill, future bimonthly popout
    │       ├── Spacer
    │       ├── DsButton(.primary, .micro, iconOnly: "arrow.left",  action: onPrev)
    │       └── DsButton(.primary, .micro, iconOnly: "arrow.right", action: onNext)
    ├── Weekday row (S M T W T F S)
    │   └── HStack(spacing: 0) — 7 equal-flex columns of Type.Label.xs
    ├── Grid (6 week rows × 7 day cells)
    │   └── VStack(spacing: weekRowGap=2)
    │       └── per row: HStack(spacing: 0) — 7 equal-flex day cells
    ├── DsDivider(.dashed)
    └── Legend
        └── HStack(spacing: Space.snug)
            ├── TASK DUE entry  (filled signal dot + Type.Label.xs)
            ├── PROJ DUE entry  (hollow signal ring + Type.Label.xs)
            └── TODAY entry     (20pt ink swatch with paper "2" + Type.Label.xs)
.padding(Space.cardPadding)
```

### Day cell anatomy

```
dayCell
└── VStack(spacing: cellGap=2)
    ├── ZStack
    │   ├── if isToday → Circle().fill(TextToken.primary).frame(28×28)
    │   └── Text(day)
    │       ├── .typeStyle(Type.Data.sm)              12pt DM Mono Regular
    │       └── .foregroundStyle(isToday ? paper : ink)
    │       .frame(height: 28)                        matches todayCircle
    ├── if marker: DsStatusDot                        6pt — taskDue (filled) or projDue (hollow)
    └── else: Color.clear (reserves 6pt vertical so numbers line up)
.frame(maxHeight: .infinity)                          cells flex to fill body height per spec
```

Empty cells (`nil` in `weeks`) reserve the same vertical footprint as a filled cell (`todayCircle + cellGap + 6`) so the grid stays uniform across the partial first/last weeks.

### Primitive-internal micro-values (foundations.md carve-out)

Calendar interior values that don't fit the Space ladder. All kept as private statics inside `CalendarMonth.swift`:

| Constant | Value | Use |
|---|---|---|
| `todayCircle`    | 28pt | Today's date-circle diameter |
| `legendDateSize` | 20pt | "TODAY" swatch in the legend (aligns with `SpacingToken.s20`) |
| `cellGap`        | 2pt  | Vertical gap between date number and dot |
| `weekRowGap`     | 2pt  | Gap between week rows |
| `legendItemGap`  | 6pt  | Gap between a legend dot and its label |

All audit-exempted on the lines that consume them with `audit:exempt` markers.

### States (v0)

| State | Visual |
|---|---|
| Rest | Date number ink, dot present if marker exists |
| Today | 28pt ink circle behind the number, number becomes paper. Luis 2026-05-24 override of the spec's `ink-10` (11% opacity) treatment — high-contrast wins for the dashboard's anchor date. |
| Selected (deferred) | 1.5pt ink border around the date — spec'd but not implemented in v0; lands when day-cell tap → detail sheet wires up (BACKLOG). |
| Active / press (deferred) | Spec calls for invert fill on tap; not implemented in v0 (day cells aren't tappable yet). |

## Public API

```swift
struct CalendarMonth: View {
    struct Day: Hashable {
        let number: Int
        var isToday: Bool = false
        var marker: Marker? = nil
    }

    enum Marker: Hashable {
        case taskDue   // filled signal dot — DsStatusDot(.urgent, .small)
        case projDue   // hollow signal ring — DsStatusDot(.attention, .small)
    }

    let title: String                  // e.g. "SATURDAY, MAY 2"
    let weeks: [[Day?]]                // 5-6 rows, each 7 cells (nil for blank)
    var onDateTap: () -> Void = {}     // future: bimonthly popout
    var onPrev:    () -> Void = {}
    var onNext:    () -> Void = {}
}
```

v0 accepts the rendered shape directly (`weeks: [[Day?]]`). When real date math lands, the caller computes `weeks` from a `Date`-anchored model; CalendarMonth doesn't grow date logic.

## Composition

CalendarMonth composes:
- `DsButton` (Primitive, ✅ locked) — date pill + nav arrows, all `.primary, .micro`
- `DsStatusDot` (Primitive, ✅ locked) — task/proj marker dots + legend dots
- `DsDivider` (Primitive, ✅ locked, dashed) — divider above legend

It does NOT extract a `CalendarDayCell` Primitive — cell layout is component-internal and not reused elsewhere. If a future bimonthly popout uses similar cell geometry, extract then.

## Rules

- **Date pill, arrows, and any future bimonthly-popout entry point all use `DsButton.primary.micro`.** The whole nav cluster reads as one button family at one scale. Don't mix small + micro within the header.
- **Day numbers are mono.** Calendar dates are tabular data, not headlines — `Type.Data.sm` (DM Mono Regular 12pt) keeps glyph widths stable column-to-column.
- **Today = solid ink, not ink-10.** Luis 2026-05-24 override. The dashboard's anchor date needs high contrast.
- **Day cells flex to fill body height** via `.frame(maxHeight: .infinity)`. Spec calls for `flex: 1` rows; SwiftUI equivalent is unbounded vertical flexibility on each cell, with the parent VStack stretching naturally.
- **All micro-values stay inside CalendarMonth.swift as private statics.** Don't promote 2pt / 6pt / 20pt / 28pt to BaseTokens — they're calendar-specific.
- **DsStatusDot is the only legitimate dot Primitive here.** Don't draw raw Circles for the markers — reuse the severity-driven Primitive so a future change to dot weight cascades automatically.

## Surfaced deviations from spec

These were accepted in the sizing pass (Luis 2026-05-25) to preserve "reuse existing Primitives first":

1. **Date pill font:** spec wants `10pt mono 700 / 0.14em`; we land `12pt mono 500 / micro tracking` via `DsButton.primary.micro` (which uses `Type.Label.sm`). +2pt size, lighter weight, similar visual family. Acceptable for reuse. (Label.sm was 13pt at initial decision; reverted to 12pt later in the same session.)
2. **DOW label font:** spec wants `11pt mono 500`; we land `10pt mono 500` via `Type.Label.xs`. -1pt, avoids inventing an 11pt Type role for a single surface.
3. **Nav button aspect:** spec wants `36×22` rectangular; we land `24×24` square via `DsButton.micro` icon-only. Same DS family; aspect differs.
4. **Today background opacity:** spec wants `ink-10` (11%); we keep solid ink (Luis 2026-05-24).

## SemanticTokens used

`Type.Label.xs` (DOW + legend labels) · `Type.Data.sm` (date numbers + today swatch number) · `TextToken.primary` · `BackgroundToken.primary` · `StatusToken.tint(.urgent)` / `.attention` (via DsStatusDot) · `Border.Color.subtle` · `Border.Width.normal` · `Radius.md` · `Space.bodyPadding` / `.cardPadding` / `.snug`

No new tokens. The `audit:exempt` markers on `VStack(spacing: 0)`, `HStack(spacing: 0)`, and the carved-out micro-value spacings sit on the lines that consume them.

## Cross-references

- Uses: `DsButton`, `DsStatusDot`, `DsDivider`, `Type.Data.sm`, `Type.Label.xs`, `TextToken`, `BackgroundToken`, `StatusToken`, `Border`, `Radius`, `Space`
- Used by: `DashboardScreen` (TBD) — right column, above `MaintenanceList`
- Severity peers: `DsKeyButton` (tile severity), `DsBadge` (count severity), `DsStatusDot` (the inline dot used here) — same ladder, different surface

## Decisions log (this spec)

- **Initial scaffold (2026-05-24):** Built using `DsStatusDot`, `DsDivider`, `DsButton.small`, custom-styled date pill (Text-in-Capsule). `Type.Title.md` for date numbers, 32pt today circle. Shipped without a spec file (rushed); spec now landing alongside the sizing pass.
- **Today = solid ink** (Luis 2026-05-24): spec called for `ink-10` 11% opacity background; Luis preferred high-contrast ink. Override stands.
- **Sizing pass — paprLCD redline (Luis 2026-05-25):** all dimensional changes documented above and in `CHANGELOG.md`. Headline moves: date pill → `DsButton.primary.micro` (no-op `onDateTap` action wired for future popout); arrows → `DsButton.micro` (was `.small`); day number font → `Type.Data.sm` (was `Type.Title.md`); today circle → 28pt (was 32); dots → 6pt via `DsStatusDot.small` iter 8 revert (was 8pt); DOW + legend labels → `Type.Label.xs` (was `Type.Label.sm`); cells flex to fill body (was fixed 56pt); various 2pt / 6pt / 12pt / 20pt micro-values landed as primitive-internal carve-outs.
- **Day-cell tap → detail sheet (deferred BACKLOG):** spec's "selected" 1.5pt border state and `:active` invert press both depend on tappable cells. Defer until detail sheet design lands.
- **Real `Date`-based month math (deferred BACKLOG):** `sampleMay2026` static is the v0 demo data. When the maintenance model + calendar driver land, replace with computed weeks.
