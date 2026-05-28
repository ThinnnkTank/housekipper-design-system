# NextUpCard — Component

**Layer:** Component
**Status:** ✅ Locked (2026-05-27 — re-locked after hero-card unification round)
**Implementation:** `houseKipper/houseKipper/Components/NextUpCard.swift`

## 2026-05-27 update — hero-card anatomy unified with ActiveProjectCard

Both hero cards now share anatomy. NextUpCard structure: `VStack(spacing: 0)` containing a **44pt header rail** (`HStack(alignment: .top)` with eyebrow + `Spacer`) above the content row (icon · content VStack · buttons VStack). Eyebrow uses `.font(Type.Label.lg.font)` (DM Mono Medium 14pt, no tracking/upper — matches DsSearchField + ActiveProject + MaintenanceList "TASKS"). 48pt SF Symbol urgent indicator gains `.padding(.horizontal, Space.snug)` (12pt L/R breathing). Outer padding asymmetric: `top: hairline (4)` / `horizontal: bodyPadding (16)` / `bottom: cardPadding (20)` / `leading +tight (8)` for spine clearance. HomeTab applies `.frame(height: 164)` — math: 4 + 44 + 0 + 96 (2-button stack tapTarget min) + 20 = 164.

## Overview

The dashboard's hero "what's most pressing" card. Three states:

| State | Trigger | Visual signature |
|---|---|---|
| `urgent` | Task is due today or overdue | Signal border (2pt) + left-edge **signal spine** + signal `!` indicator + "DUE TODAY" eyebrow in signal color. **No `signalTint` fill** (Decision 7 — hero exception). |
| `upcoming` | Task is due in 1–14 days | Standard card chrome (muted border, 1pt). "DUE IN N DAYS" eyebrow in ink60. No spine, no urgent indicator. Same buttons. |
| `allClear` | Nothing actionable for 15+ days | Quiet centered layout. Inline `✓ All clear, [next task] in [N] days` message + secondary "+ NEW MAINTENANCE TASK" button. |

The left-edge spine is novel to this card — a thick signal-colored tab that follows the rounded corner. Implemented as an overlay rectangle clipped by the same RoundedRectangle that defines the card's shape; the corner-rounding comes free.

**When to use:** the dashboard's "NEXT UP" position. One per Screen at most.
**When NOT to use:** as a generic task row (use `MaintenanceRow`). As a list item (use `MaintenanceList`).

## Anatomy

```
NextUpCard
└── ZStack
    ├── RoundedRectangle(Radius.md).fill(paper2)                    base
    ├── if .urgent:
    │     Rectangle(signal).frame(width: spine, alignment: .leading)  leading spine
    └── VStack(.leading)
        ├── "NEXT UP" eyebrow (Type.Label.xs · muted)              constant across states
        └── state-specific body:
            ├── .urgent / .upcoming:
            │     HStack
            │       ├── exclamationmark.circle icon (~48pt, signal — urgent only)
            │       ├── VStack — eyebrow ("DUE TODAY" or "DUE IN N DAYS")
            │       │              title (Type.Title.lg)
            │       │              meta ("LOCATION · EVERY 90 DAYS", Type.Label.xs muted)
            │       └── HStack — MARK COMPLETE (primary) + SNOOZE ⌄ (secondary)
            └── .allClear:
                  VStack (centered)
                    ├── "✓ All clear, [message]" (Type.Body.md inline check + text)
                    └── "+ NEW MAINTENANCE TASK" (secondary)
    .clipShape(RoundedRectangle(Radius.md))                          clips spine to corners
.overlay(RoundedRectangle.strokeBorder(stateColor, lineWidth: stateWidth))
```

### State-specific chrome

| State | Border color | Border width | Spine | Eyebrow color | Indicator |
|---|---|---|---|---|---|
| `urgent` | `Border.Color.strong` (signal) | 2pt | 8pt signal rect on leading edge | signal | `exclamationmark.circle` 48pt signal |
| `upcoming` | `Border.Color.muted` (ink40) | 1pt | — | `TextToken.secondary` (ink60) | none |
| `allClear` | `Border.Color.muted` (ink40) | 1pt | — | n/a | inline checkmark in body text |

### Spine construction

```swift
// Inside ZStack, after the paper2 base fill:
HStack {
    Spacer()
    Rectangle()
        .fill(StatusToken.tint(.urgent))   // signal
        .frame(width: 8)                    // private static let inside the .swift
}
// The outer .clipShape(RoundedRectangle(cornerRadius: Radius.md))
// trims the spine to follow the card's corner curve.
```

The spine width (8pt) is a NextUpCard-internal layout value, not promoted to a token. Single use, primitive-internal-style carve-out.

### Decision 7 (hero exception)

**`urgent` does NOT apply `signalTint` fill** even though `DsKeyButton.urgent` does. The hero NextUpCard is the screen's loudest urgency surface; adding the soft tint fill on top of the signal border + spine creates a wash that softens the alarm. Per `foundations.md → Color → Hero exception`, this exception applies ONLY to NextUpCard.

## Public API

```swift
struct NextUpCard: View {
    enum State {
        case urgent(  title: String, location: String, frequency: String, dueLabel: String)
        case upcoming(title: String, location: String, frequency: String, dueLabel: String)
        case allClear(message: String)
    }

    let state: State
    var onMarkComplete: () -> Void = {}
    var onSnooze: () -> Void = {}
    var onNewTask: () -> Void = {}
}
```

`dueLabel` is caller-formatted ("DUE TODAY", "DUE IN 3 DAYS", etc.) — the Component renders the string but doesn't compute it.

## Composition

NextUpCard composes:
- `DsButton` (✅ locked) — both primary (MARK COMPLETE) and secondary (SNOOZE, NEW MAINTENANCE TASK)
- SF Symbols directly — `exclamationmark.circle` for the urgent indicator, `checkmark` for the MARK COMPLETE button, `chevron.down` trailing on SNOOZE
- All typography via `Type.{Category}.{size}`

It does NOT extract a separate "urgent indicator" Primitive. The big circled `!` is a single SF Symbol; building a Primitive for it would be speculative.

## Rules

- **One NextUpCard per Screen.** It's the hero position.
- **The spine appears ONLY in `urgent` state.** Don't render it on upcoming or all-clear.
- **No signalTint fill** even on urgent (Decision 7). The signal border + spine carry the alarm; a tint over the top muddies it.
- **All-clear is calm, not loud.** Centered layout, secondary button only, no urgency colors. The whole point of all-clear is the user feels done.
- **The 15-day threshold for all-clear is the Screen's call**, not the Component's. NextUpCard renders the state it's handed.

## Animation (deferred)

Per Luis 2026-05-24: when MARK COMPLETE is tapped, the urgent task should slide-and-fade right-to-left while the next item replaces it. This is a Screen-level animation, not a Component concern. The Component fires `onMarkComplete`; the Screen wires `.transition(.move(edge: .leading).combined(with: .opacity))` on its NextUpCard-hosting view + flips the state. Tracked in BACKLOG for when the dashboard Screen lands.

## Cross-references

- Uses: `DsButton`, `IconCatalog.Status.urgent`, `IconCatalog.Action.checkmark`, `Type.*`, `Space`, `BackgroundToken`, `TextToken`, `Border`, `Radius`, `StatusToken`
- Used by: Dashboard Screen (TBD) — one per Screen
- Decision-7 peer: `DsKeyButton.urgent` (which DOES get `signalTint` fill — opposite policy)
- Sibling: `MaintenanceList` (the rows below, for non-hero tasks)

## Decisions log (this spec)

- **Three states with associated data** (Luis 2026-05-24): `urgent`, `upcoming`, `allClear`. Each carries the data it needs in the enum case — no optional fields, no inconsistent states.
- **Left-edge spine on urgent only** (Luis 2026-05-24, from reference image): 8pt signal rect overlaid on the leading edge + clipped by the card's RoundedRectangle so the corner-rounding follows naturally. Single SwiftUI overlay + clipShape — no custom Shape. (Iter 1 placed it on the trailing edge; corrected when Luis pointed at the reference.)
- **Equal-width buttons in the action column** (Luis 2026-05-24, iter 2): MARK COMPLETE and SNOOZE share the wider button's width (MARK COMPLETE drives the size). Implemented via `.frame(maxWidth: .infinity)` on each button inside a VStack with `.fixedSize(horizontal: true, vertical: false)` — the VStack settles at the natural max-child width, then each button stretches to fill.
- **Tighter eyebrow → body rhythm** (Luis 2026-05-24, iter 2): gap between "NEXT UP" eyebrow and the body row reduced from `Space.bodyPadding` (16pt) to `Space.tight` (8pt). Cards now read compact yet spacious — the eyebrow stays close to its content.
- **Buttons sized `.small` (not `.large`)** (Luis 2026-05-24, iter 3): `.large` (40pt + 14pt mono) made the hero card read big and thin — too much vertical mass with too much whitespace inside each button. Stepped down one size: `.small` = 32pt visible height + `Type.Label.md` (13pt mono medium). Applies to all three action buttons (MARK COMPLETE, SNOOZE, NEW MAINTENANCE TASK). Brings the card heights closer to the original reference's compact rhythm without inventing a non-ladder button size.
- **Decision 7: no signalTint fill on urgent NextUpCard** (locked previously, restated here): hero card's signal border + spine are the alarm; tint fill softens that. Applies ONLY to NextUpCard, NEVER to DsKeyButton.urgent (which keeps its signalTint).
- **`exclamationmark.circle` SF Symbol for urgent indicator** (Luis 2026-05-24): no new Primitive — single glyph rendered at large size with signal color. Promoted to `IconCatalog.Status.urgent` for reuse if other urgent contexts adopt it.
- **All-clear is quiet** (Luis 2026-05-24): "this tranquil (feeling im done)" should not compete with urgency states. Centered layout, secondary button, no signal colors. The 15-day threshold is caller-decided.
- **Animation deferred** (Luis 2026-05-24): slide-and-fade-on-complete is a Screen concern; Component fires the callback. BACKLOG entry pending when dashboard Screen surfaces.
- **Snooze popover deferred** (Luis 2026-05-24): the snooze options (1 day / 3 days / 1 week) live in a popover anchored to the SNOOZE button. NextUpCard fires `onSnooze`; the popover is a future Pattern (already in BACKLOG as Popover Pattern).
