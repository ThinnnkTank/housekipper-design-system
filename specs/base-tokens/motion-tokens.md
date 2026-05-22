# BaseToken — Motion

Durations and easings. From the paprLCD non-canonical motion vocabulary (richer than the canonical, which only shipped `--dur` and `--ease`).

## Durations

| Token | Value (s) | Use |
|---|---|---|
| `MotionToken.dFast`   | 0.120 | Micro-interactions (toggle flip, press release) |
| `MotionToken.dBase`   | 0.220 | Default UI transition |
| `MotionToken.dSlow`   | 0.400 | Considered transitions (severity escalation, sheet present) |
| `MotionToken.dSlower` | 0.600 | Expressive moments (success confirmation, attention loop) |

## Easings (SwiftUI `Animation` values)

| Token | Curve | Feels like |
|---|---|---|
| `MotionToken.easeOut`   | `(0.20, 0.80, 0.20, 1.00)` | Snappy arrival |
| `MotionToken.easeIn`    | `(0.60, 0.04, 0.98, 0.34)` | Confident departure |
| `MotionToken.easeInOut` | `(0.60, 0.00, 0.40, 1.00)` | Balanced symmetric |

Use `MotionToken.easeOut(_:)`, `.easeIn(_:)`, `.easeInOut(_:)` to construct an animation with a specific duration.

**Status:** locked.
**Source:** `BaseTokens/MotionTokens.swift`.
**Access rule:** never imported by Primitives. Use `Motion.quick/standard/gentle/expressive` (semantic).
