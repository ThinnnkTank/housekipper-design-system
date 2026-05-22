# Motion — Foundation

## Intent

Calm. Snappy when small, considered when meaningful. Never bouncy or playful — paprLCD is a tactile instrument, not a toy.

## Vocabulary

Four durations + three easings (see `base-tokens/motion-tokens.md`). Each duration has a use case:

| Duration | Use |
|---|---|
| `quick` (120ms) | Micro-interactions you barely notice — toggle flips, press release |
| `standard` (220ms) | Default UI transitions — sheets, dropdowns, severity color changes |
| `gentle` (400ms) | Considered transitions where the eye should follow — status reveals |
| `expressive` (600ms) | Earned moments — success confirmation, attention loops |

## Rules

- **Symbol effects first.** For SF Symbol state changes, use `.symbolEffect(.bounce/.pulse/etc.)` — never hand-animate when an effect exists. See `iconography.md`.
- **Respect Reduce Motion.** Read `@Environment(\.accessibilityReduceMotion)` — when on: kill `expressive` and `gentle` to `quick`; disable repeating loops.
- **No springs by default.** SwiftUI's `.bouncy`, `.spring` produce a personality that doesn't match paprLCD's instrument-like restraint. Use only for explicit micro-interactions where rebound is semantically meaningful (rare).
- **Never raw `.easeIn`, `.linear`, etc.** Always `Motion.*` semantic. Audit enforces.
