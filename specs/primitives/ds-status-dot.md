# DsStatusDot — Primitive

**Layer:** Primitive
**Status:** ✅ Locked (2026-05-24)
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsStatusDot.swift`

## Overview

A small dot carrying the severity ladder. **Severity-driven** like every other status-bearing Primitive (DsKeyButton border, DsBadge content). Three states match the paprLCD vnext canonical reference:

| Severity | Visual | Color |
|---|---|---|
| `healthy`   | Hollow ring (2.5pt at regular, 2pt at small) | `TextToken.muted` (ink40) — quiet but visible |
| `attention` | Hollow ring (2.5pt at regular, 2pt at small) | `StatusToken.tint(.attention)` (signal) |
| `urgent`    | Filled circle      | `StatusToken.tint(.urgent)` (signal) |

The hollow-vs-filled distinction encodes "is this an alarm" — only `urgent` fills. Healthy + attention stay structurally identical, only the color differs.

**Primary use:** calendar day-cell indicators · list-row severity markers · anywhere a tiny "what's the state" glyph is warranted at a small surface.
**When NOT to use:** numeric counters (use `DsBadge`). Identity (use `DsAvatar`). Larger labeled status pills (use `DsStatusPill`, TBD).

## Anatomy

```
DsStatusDot
└── Circle
    ├── .healthy   → .strokeBorder(TextToken.muted,              lineWidth: ringWidth)
    ├── .attention → .strokeBorder(StatusToken.tint(.attention), lineWidth: ringWidth)
    └── .urgent    → .fill(StatusToken.tint(.urgent))
    Frame: diameter×diameter (driven by Size)
```

### Size + ring width

| Size      | Diameter | Ring width            | Use |
|---|---|---|---|
| `.regular`| 12pt     | 2.5pt (hollow modes) | Legend, labeled severity rows — paprLCD canonical reference weight |
| `.small`  | 8pt      | 2pt (hollow modes)   | Calendar day cell, list-row markers — denser surfaces |

**Ring weight is size-driven, not severity-driven.** Healthy and attention share the same stroke thickness at any given size — only the color differs. Heavier strokes on the smaller dot would dominate the circle; thinner strokes on the larger dot would read anemic next to body text. Same principle as DsKeyButton — stroke is proportional to the surface it sits on, not to which severity is being expressed.

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

`StatusToken.Severity` · `StatusToken.tint(.attention)` / `tint(.urgent)` · `TextToken.muted` (ink40 for healthy ring) · `Border.Width.strong` (2pt stroke for hollow modes — 1pt read too thin at 12pt)

No new tokens introduced.

## Example

```swift
// Inline severity legend
HStack(spacing: Space.tight) {
    DsStatusDot(severity: .healthy)
    Text("ALL GOOD").typeStyle(Type.Label.sm)
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
- **Color rule (2026-05-23, iter 2):** healthy uses `TextToken.muted` (ink40 ring) so it reads as "quiet but visible." Attention + urgent both use signal, with the fill/hollow split carrying the alarm escalation. *(iter 2 originally used `TextToken.faint` / ink20 — bumped on iPad 2026-05-24, see iter 5 below.)*
- **12pt diameter (2026-05-23, iter 2):** matches paprLCD reference visual weight. Was 6pt in iter 1; too small alongside labeled severity rows.
- **Iter 3 (2026-05-23):** Hollow ring bumped 1pt → 2pt at `.regular` size. At 12pt diameter, 1pt looked anemic. Divergence from DsKeyButton's healthy=1pt is intentional — stroke weight is proportional to the surface it sits on.
- **Iter 4 (2026-05-23):** Added `Size` enum (`.regular` / `.small`) per Luis's calendar-density question. Ring width scales with diameter (2pt at 12, 1pt at 6) so the stroke stays proportional at both sizes. Shipped now rather than backlogged — calendar surface will need `.small` and we already had the API decision ready.
- **Iter 5 (2026-05-24):** Healthy ring color bumped `TextToken.faint` (ink20, 22%) → `TextToken.muted` (ink40, 50%). Luis on iPad: ink20 was nearly invisible. Doubling the perceived weight while still reading quieter than attention/urgent (which use full signal). Local to DsStatusDot only — other consumers of `TextToken.faint` (placeholder, disabled-ish text) remain unchanged.
- **Iter 6 (2026-05-24):** Small diameter 6pt → 8pt per Luis. Initially tried "healthy +1pt thicker than attention" to compensate for ink40's lower visual weight — overreach, reverted in iter 7.
- **Iter 7 (2026-05-24):** Locked the rule: **hollow ring thickness is purely size-driven, same for all hollow severities at a given size.** Color alone carries severity. Final values: regular 2.5pt, small 2pt. The 3pt-at-regular tried in iter 6 was too heavy; 2.5pt reads strong without dominating. Swatch panel label corrected (was still "6pt" after the diameter bump).
