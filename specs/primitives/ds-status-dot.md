# DsStatusDot — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23, iter 2) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsStatusDot.swift`

## Overview

A small dot carrying the severity ladder. **Severity-driven** like every other status-bearing Primitive (DsKeyButton border, DsBadge content). Three states match the paprLCD vnext canonical reference:

| Severity | Visual | Color |
|---|---|---|
| `healthy`   | 2pt ring (hollow) | `TextToken.faint` (ink20) — quiet |
| `attention` | 2pt ring (hollow) | `StatusToken.tint(.attention)` (signal) |
| `urgent`    | Filled circle      | `StatusToken.tint(.urgent)` (signal) |

The hollow-vs-filled distinction encodes "is this an alarm" — only `urgent` fills. Healthy + attention stay structurally identical, only the color differs.

**Primary use:** calendar day-cell indicators · list-row severity markers · anywhere a tiny "what's the state" glyph is warranted at a small surface.
**When NOT to use:** numeric counters (use `DsBadge`). Identity (use `DsAvatar`). Larger labeled status pills (use `DsStatusPill`, TBD).

## Anatomy

```
DsStatusDot
└── Circle
    ├── .healthy   → .strokeBorder(TextToken.faint,              lineWidth: ringWidth)
    ├── .attention → .strokeBorder(StatusToken.tint(.attention), lineWidth: ringWidth)
    └── .urgent    → .fill(StatusToken.tint(.urgent))
    Frame: diameter×diameter (driven by Size)
```

### Size + ring width

| Size      | Diameter | Ring width            | Use |
|---|---|---|---|
| `.regular`| 12pt     | `Border.Width.strong` (2pt) | Legend, labeled severity rows — paprLCD canonical reference weight |
| `.small`  | 6pt      | `Border.Width.normal` (1pt) | Calendar day cell, list-row markers — denser surfaces |

**Ring weight scales with size.** 2pt against a 6pt dot would dominate the circle; 1pt against a 12pt dot reads anemic next to body text. Same principle as DsKeyButton (1pt on a 100×60pt tile reads fine; on a 12pt dot it doesn't). Stroke weight is proportional to the surface it sits on.

Both diameters and ring widths are primitive-internal — kept as computed properties inside `DsStatusDot.swift` rather than promoted to BaseTokens. Fits the snapping-rule carve-out per `foundations.md` → Spacing → Rules ("Micro values are valid currency *inside* a primitive").

## Public API

```swift
struct DsStatusDot: View {
    enum Size {
        case regular   // 12pt — legend, severity rows
        case small     // 6pt  — calendar day cell, denser surfaces
    }

    let severity: StatusToken.Severity
    var size: Size = .regular
}
```

Argument order: `severity, [size]`. No default for severity — it's the whole point of the Primitive, caller must pick. Size defaults to `.regular`.

## States

DsStatusDot has no interactive states (no press, no disabled). It's metadata, not an affordance.

## SemanticTokens used

`StatusToken.Severity` · `StatusToken.tint(.attention)` / `tint(.urgent)` · `TextToken.faint` (ink20 for healthy ring) · `Border.Width.strong` (2pt stroke for hollow modes — 1pt read too thin at 12pt)

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
- **Iter 3 (2026-05-23):** Hollow ring bumped 1pt → 2pt at `.regular` size. At 12pt diameter, 1pt looked anemic. Divergence from DsKeyButton's healthy=1pt is intentional — stroke weight is proportional to the surface it sits on.
- **Iter 4 (2026-05-23):** Added `Size` enum (`.regular` / `.small`) per Luis's calendar-density question. Ring width scales with diameter (2pt at 12, 1pt at 6) so the stroke stays proportional at both sizes. Shipped now rather than backlogged — calendar surface will need `.small` and we already had the API decision ready.
