# BaseToken — Shadow

Single subtle elevation. paprLCD avoids stacked shadows — depth lives in borders.

| Token | Color | Radius | x | y |
|---|---|---|---|---|
| `ShadowToken.subtle` | `ink @ 8%` | 0 | 6 | 8 |

No blur — offset only. Creates a stamped/embossed feel without softness.

**Status:** locked.
**Source:** `BaseTokens/ShadowTokens.swift`.
**Access rule:** never used inside `.shadow()` modifiers in Primitives. Future `Elevation` semantic token will wrap if more than one is ever needed.
