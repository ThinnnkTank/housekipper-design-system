# Spacing — Foundation

## Intent

Tight, disciplined, 4-base scale. Vnext-canonical with iOS-relevant additions for tap targets and hero-screen layouts.

## The ladder (12 stops)

`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 44 · 48 · 64 · 80`

Lives in `base-tokens/spacing-tokens.md` and `BaseTokens/SpacingTokens.swift`.

## Rules

- Primitives import only `Space` (SemanticToken). They never touch `SpacingToken.sXX` directly.
- If a Primitive needs a value with no semantic name, add the name to `semantic-tokens/spacing.md` FIRST.
- iOS-native control dimensions (toggle 51×31, tab bar 49pt, Dynamic Type sizes) are exempt — honor the platform.
- Optical centering is exempt — if an off-grid offset makes a tappable region feel right, that's fine; comment why.

## Exemptions

- Border widths — see `border.md`.
- Native Apple control dimensions.
- Letter spacing, durations, opacities — not geometric.
