# DsWeatherChip — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-24) — pending iPad vetting, locks after Luis sign-off · **dummy implementation** (text-only) reserving the slot for a real weather widget later.
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsWeatherChip.swift`

## Overview

Compact weather summary chip — a single line of mono-uppercased text describing current conditions and immediate forecast. Lives under the TopBar's page heading.

**Currently a dummy.** Just renders the caller's `summary` string with the locked utility-text styling. Reserves the Primitive slot so future work can wrap actual weather data (temperature, conditions, hourly forecast, alerts) without callers needing to change. Per Luis 2026-05-24: "make a DsWeatherChip so we can replace in future, for now just a dummy."

**When to use:** TopBar's page-heading meta line.
**When NOT to use:** anywhere else right now. The chip's content is opinionated about being a weather summary; for other meta-line styling, use `Type.Data.sm` directly.

## Anatomy

```
DsWeatherChip
└── Text(summary)
    ├── .typeStyle(Type.Label.sm)             mono medium 12pt + trackingMicro + UPPER (all baked)
    └── .foregroundStyle(TextToken.secondary) ink60 — mid-weight
```

## Public API

```swift
struct DsWeatherChip: View {
    let summary: String   // e.g. "72°F · SUNNY · RAIN @6PM · UV 7 HIGH"
}
```

## SemanticTokens used

`Type.Label.sm` · `TextToken.secondary`

No new tokens.

## Example

```swift
DsWeatherChip(summary: "72°F · SUNNY · RAIN @6PM · UV 7 HIGH")
```

## Cross-references

- Uses: `Font`, `HkType`, `TextToken`
- Used by: `TopBar` Component
- Future: real `WeatherData` model + icon-led layout when the weather integration ships

## Decisions log (this spec)

- **Dummy now, real later** (Luis 2026-05-24): the visual slot is shipped as a styled `Text` view so call sites lock in their TopBar composition. When real weather data lands, this Primitive's body becomes an icon + structured layout — call sites don't change.
- **Mono uppercase, ink60** (Luis 2026-05-24): matches the reference image's "72°F · SUNNY · RAIN @6PM · UV 7 HIGH" treatment. Mono for data alignment, uppercase for utility, ink60 to recede behind the heading.
