# Base Tokens

Raw values — the foundation layer. Mirror of `houseKipper/houseKipper/DesignSystem/BaseTokens/*.swift`. Primitives never reach here directly; they go through `semantic-tokens.md`.

---

## Color

Canonical paprLCD vnext palette. Light-mode values shown. Dark mode lives in `Assets.xcassets/Colors/<token>.colorset` Dark Appearance.

### Ink scale (opacity steps on `#1C1C1A`)

| Token | Light | Use |
|---|---|---|
| `ink`   | `#1C1C1A`             | Primary text, strong border |
| `ink80` | `rgba(0,0,0,0.82)`    | Strong emphasis |
| `ink60` | `rgba(0,0,0,0.68)`    | Secondary text |
| `ink40` | `rgba(0,0,0,0.50)`    | Muted text · healthy status |
| `ink20` | `rgba(0,0,0,0.22)`    | Faint text · hairline alt |
| `ink10` | `rgba(0,0,0,0.11)`    | Hover fill |
| `ink05` | `rgba(0,0,0,0.055)`   | Secondary fill rest |

### Surfaces

| Token | Light | Dark |
|---|---|---|
| `paper`  | `#E8EDE5` | `#161A17` |
| `paper2` | `#DDE1DA` | `#1E2420` |

### Rule lines

| Token | Value |
|---|---|
| `rule`       | `ink @ 18%` |
| `ruleStrong` | `ink @ 35%` |

### Signal

| Token | Light | Dark |
|---|---|---|
| `signal`         | `#E06518` | `#FF7D30` |
| `signalStrong`   | `#B84E0E` | `#FF7D30` |
| `signalMuted`    | `signal @ 40%` | `#FF8F54 @ 40%` |
| `signalTint`     | `signal @ 12%` | `#FF8F54 @ 16%` |
| `signalTintSoft` | `signal @ 7%`  | `#FF8F54 @ 10%` |

---

## Spacing

12 stops. Vnext-canonical (8) + iOS extras (44/48/64/80).

`SpacingToken.s4 · s8 · s12 · s16 · s20 · s24 · s32 · s40 · s44 · s48 · s64 · s80`

`s44` = iOS minimum tap target.

---

## Radius

`RadiusToken.r6 · r8 · r10 · r12 · r14 · r16 · r18 · r22 · rPill (999)`

Use the smallest stop that fits the corner.

---

## Typography

### Faces

| Token | Value | Use |
|---|---|---|
| `Face.sans` | `"DMSans"`  | Body + display |
| `Face.mono` | `"DMMono"`  | Labels, metadata, data |
| `Face.sansBold` | `"DMSans-Bold"` | Micro button (DM Mono ships no Bold) |

### Sizes

`9 · 10 · 11 · 12 · 13 · 14 · 17 · 22 · 30 · 38` (size9, size10, …, size38)

`size9/11/13` are explicit exemptions to the 4-grid — needed for micro-utility text.

### Weights

`light (300) · regular (400) · medium (500) · semibold (600) · bold (700) · black (900)` — DM Sans range.

DM Mono ships: Light, Regular, Medium only.

### Tracking (pts, applied via `.tracking`)

| Token | Value |
|---|---|
| `Tracking.none`   | 0 |
| `Tracking.snug`   | +0.4 (small button labels) |
| `Tracking.micro`  | +1.1 (micro button labels — bold sans needs slight breathing at 11pt) |
| `Tracking.label`  | +1.0 (mono utility labels) |
| `Tracking.wide`   | +1.4 |
| `Tracking.wider`  | +1.8 |
| `Tracking.tight`  | -0.6 (large display only) |

### Line height ratios

| Token | × |
|---|---|
| `LineHeight.hero`    | 1.06 |
| `LineHeight.title`   | 1.08 |
| `LineHeight.compact` | 1.12 |
| `LineHeight.utility` | 1.20 |
| `LineHeight.body`    | 1.65 |

---

## Border

Stroke widths.

| Token | Value |
|---|---|
| `BorderToken.hairline` | 1.0 |
| `BorderToken.regular`  | 1.5 |
| `BorderToken.strong`   | 2.0 |
| `BorderToken.icon`     | 1.8 (SF Symbol stroke alignment) |

---

## Motion

### Durations (seconds)

| Token | Value |
|---|---|
| `MotionToken.dFast`   | 0.120 |
| `MotionToken.dBase`   | 0.220 |
| `MotionToken.dSlow`   | 0.400 |
| `MotionToken.dSlower` | 0.600 |

### Easings (Swift `Animation`)

| Token | Curve |
|---|---|
| `MotionToken.easeOut`   | `(0.20, 0.80, 0.20, 1.00)` |
| `MotionToken.easeIn`    | `(0.60, 0.04, 0.98, 0.34)` |
| `MotionToken.easeInOut` | `(0.60, 0.00, 0.40, 1.00)` |

Use `MotionToken.easeOut(_:)`, `.easeIn(_:)`, `.easeInOut(_:)` to construct with custom duration.

---

## Shadow

Single subtle elevation.

| Token | Color | Radius | x | y |
|---|---|---|---|---|
| `ShadowToken.subtle` | `ink @ 8%` | 0 | 6 | 8 |

No blur — offset only. Stamped/embossed feel.
