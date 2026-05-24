# DsStatusDot — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23, iter 2) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsStatusDot.swift`

## Overview

A small dot carrying the severity ladder. **Severity-driven** like every other status-bearing Primitive (DsKeyButton border, DsBadge content). Three states match the paprLCD vnext canonical reference:

| Severity | Visual | Color |
|---|---|---|
| `healthy`   | 1pt ring (hollow) | `TextToken.faint` (ink20) — quiet |
| `attention` | 1pt ring (hollow) | `StatusToken.tint(.attention)` (signal) |
| `urgent`    | Filled circle      | `StatusToken.tint(.urgent)` (signal) |

The hollow-vs-filled distinction encodes "is this an alarm" — only `urgent` fills. Healthy + attention stay structurally identical, only the color differs.

**Primary use:** calendar day-cell indicators · list-row severity markers · anywhere a tiny "what's the state" glyph is warranted at a small surface.
**When NOT to use:** numeric counters (use `DsBadge`). Identity (use `DsAvatar`). Larger labeled status pills (use `DsStatusPill`, TBD).

## Anatomy

```
DsStatusDot
└── Circle
    ├── .healthy   → .strokeBorder(TextToken.faint,                    lineWidth: 1pt)
    ├── .attention → .strokeBorder(StatusToken.tint(.attention),       lineWidth: 1pt)
    └── .urgent    → .fill(StatusToken.tint(.urgent))
    Frame: 12×12pt (primitive-internal constant)
```

**Why 12pt?** Matches the visual weight of the canonical paprLCD reference. Bigger than a calendar accent (~6pt would get lost next to labeled severity rows); smaller than a badge. The dot needs to read as a "status presence" alongside body text, not as either an afterthought or a counter.

12pt sits on the existing Space ladder (`SpacingToken.s12`) but is kept as a `private static let` inside `DsStatusDot.swift` rather than promoted — it's primitive-internal geometry, not a layout dimension. Fits the snapping-rule carve-out per `foundations.md` → Spacing → Rules.

## Public API

```swift
struct DsStatusDot: View {
    let severity: StatusToken.Severity
}
```

Argument order: `severity`. No default — severity is the whole point of this Primitive, the caller must pick.

## States

DsStatusDot has no interactive states (no press, no disabled). It's metadata, not an affordance.

## SemanticTokens used

`StatusToken.Severity` · `StatusToken.tint(.attention)` / `tint(.urgent)` · `TextToken.faint` (ink20 for healthy ring) · `Border.Width.normal` (1pt stroke for hollow modes)

No new tokens introduced.

## Example

```swift
// Inline severity legend
HStack(spacing: Space.tight) {
    DsStatusDot(severity: .healthy)
    Text("ALL GOOD").font(.hkButton)
}

// Calendar day cell (CalendarMonth, TBD)
VStack(spacing: 2) {
    Text("\(day.number)")
    if let worst = day.worstSeverity { DsStatusDot(severity: worst) }
}
```

The mapping (day → severity) lives at the CalendarMonth Component, not inside DsStatusDot.

## Cross-references

- Uses: `StatusToken`, `TextToken`, `Border`
- Used by: `CalendarMonth` Component (TBD), `MaintenanceRow` Component (TBD), any surface needing a small severity indicator
- Severity peers: `DsKeyButton` (tile border + fill), `DsBadge` (counter overlay) — DsStatusDot is the lightest-weight expression of the same ladder

## Decisions log (this spec)

- **Iter 1 → 2 (2026-05-23):** Rewrote from presentational `Style { filled, hollow }` to severity-driven `severity: StatusToken.Severity`. Iter 1 broke from the established severity-driven pattern (DsKeyButton, DsBadge) by trying to make the Primitive "domain-agnostic." Luis caught it via the paprLCD vnext reference screenshot — the canonical dot trio IS the severity ladder, not a generic shape. Bringing it back in line.
- **Color rule (2026-05-23, iter 2):** healthy uses `TextToken.faint` (ink20 ring) so it reads as "quiet, in the system but unalarming." Attention + urgent both use signal, with the fill/hollow split carrying the alarm escalation.
- **12pt diameter (2026-05-23, iter 2):** matches paprLCD reference visual weight. Was 6pt in iter 1; too small alongside labeled severity rows.
