# BaseToken — Typography

## Faces

| Token | Value | Notes |
|---|---|---|
| `Face.sans` | `"DMSans"` | Body + display (size 22/30/38 use this too) |
| `Face.mono` | `"DMMono"` | Labels, metadata, data, buttons, captions |

Space Grotesk **dropped**. DM Sans handles display sizes. Decision revisitable if hero typography feels weak.

Fonts ship as .ttf in `design-sys/fonts/` and must be registered in Info.plist (`UIAppFonts`) before runtime.

## Sizes (vnext scale, 8 stops)

| Token | Size (pt) | Use |
|---|---|---|
| `size9`  | 9  | Dense labels, faint utility |
| `size10` | 10 | Buttons, badges |
| `size12` | 12 | Data, compact values (mono) |
| `size14` | 14 | Titles, dense body |
| `size17` | 17 | Section titles |
| `size22` | 22 | Card headlines |
| `size30` | 30 | Page headings |
| `size38` | 38 | Hero / display |

## Weights

`light (300) · regular (400) · medium (500) · semibold (600) · bold (700) · black (900)` — full DM Sans range.

## Tracking

| Token | pt at 10pt size | Use |
|---|---|---|
| `Tracking.none`   | 0    | Body, titles |
| `Tracking.label`  | +1.0 | Mono labels |
| `Tracking.wide`   | +1.4 | Buttons |
| `Tracking.wider`  | +1.8 | Eyebrows, sparse headers |
| `Tracking.tight`  | -0.6 | Large display sizes |

## Line heights (ratios)

| Token | Multiplier | Use |
|---|---|---|
| `LineHeight.hero`    | 1.06 | 38pt display |
| `LineHeight.title`   | 1.08 | 22-30pt titles |
| `LineHeight.compact` | 1.12 | 14pt body in tight contexts |
| `LineHeight.utility` | 1.20 | 10-12pt utility labels |
| `LineHeight.body`    | 1.65 | Long prose |
| `LineHeight.prose`   | 1.65 | Long prose |

## Numerals

Tabular + lining numerals are applied via `Font.hkData` and any future data-aligned text style. Use `.monospacedDigit()` to enforce.

**Status:** locked. Face: DM Sans + DM Mono.
**Source:** `BaseTokens/TypographyTokens.swift`.
**Access rule:** never imported by Primitives. Use `Font.hk*` semantic extensions.
