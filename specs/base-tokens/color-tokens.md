# BaseToken — Color

Canonical paprLCD vnext palette. Light-mode values shown. Dark mode lives in `Assets.xcassets/Colors/<token>.colorset` Dark Appearance and resolves automatically.

## Ink scale (text + control hierarchy)

| Token | Light | Dark | Use |
|---|---|---|---|
| `ink`   | `#1C1C1A` | `#E8EDE5` | Primary text, strong border |
| `ink80` | `rgba(28,28,26,0.82)` | `paper @ 82%` | Strong emphasis |
| `ink60` | `rgba(28,28,26,0.68)` | `paper @ 68%` | Secondary text |
| `ink40` | `rgba(28,28,26,0.50)` | `paper @ 50%` | Muted text · healthy status |
| `ink20` | `rgba(28,28,26,0.22)` | `paper @ 22%` | Faint text · hairline alt |
| `ink10` | `rgba(28,28,26,0.11)` | `paper @ 11%` | Hover fill |
| `ink05` | `rgba(28,28,26,0.055)` | `paper @ 5.5%` | Secondary fill rest |

## Surfaces

| Token | Light | Dark | Use |
|---|---|---|---|
| `paper`  | `#E8EDE5` | `#161A17` | Primary surface |
| `paper2` | `#DDE1DA` | `#1E2420` | Secondary surface |

## Rule lines (borders)

| Token | Light | Dark | Use |
|---|---|---|---|
| `rule`       | `rgba(28,28,26,0.18)` | `paper @ 18%` | Default hairline |
| `ruleStrong` | `rgba(28,28,26,0.35)` | `paper @ 35%` | Emphasized divider |

## Signal (the one accent)

| Token | Light | Dark | Use |
|---|---|---|---|
| `signal`         | `#E06518` | `#FF7D30` | Attention/urgent |
| `signalStrong`   | `#B84E0E` | `#FF7D30` | Pressed/emphasized signal |
| `signalTint`     | `signal @ 12%` | `#FF8F54 @ 16%` | Urgent soft fill |
| `signalTintSoft` | `signal @ 7%`  | `#FF8F54 @ 10%` | Hover/pre-press tint |

**Status:** locked from vnext.
**Source:** `Assets.xcassets/Colors/*.colorset` (runtime), `BaseTokens/ColorTokens.swift` (spec mirror).
**Access rule:** Primitives use `BackgroundToken`, `TextToken`, `ActionToken`, `StatusToken`, `Border` — never `ColorToken` or asset catalog names directly.
