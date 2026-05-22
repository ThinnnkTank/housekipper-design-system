# BaseToken — Border

Stroke widths used across paprLCD vnext.

| Token | Value (pt) | Use |
|---|---|---|
| `BorderToken.hairline` | 1.0 | Default rule |
| `BorderToken.regular`  | 1.5 | Emphasized rule, spec-table headers, badges |
| `BorderToken.strong`   | 2.0 | Affordance border, signal urgent |
| `BorderToken.icon`     | 1.8 | SF Symbol stroke alignment |

**Status:** locked.
**Source:** `BaseTokens/BorderTokens.swift`.
**Access rule:** never imported by Primitives. Use `Border.default/strong/affordance` (semantic) which pair width with color.
