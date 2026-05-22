# SemanticToken — Spacing

Intent-named spacing. **Primitives import these, never `SpacingToken.sXX` directly.** Audit enforces.

| Token | Maps to | Use |
|---|---|---|
| `Space.hairline`        | `SpacingToken.s4`  | Tiny gaps, divider padding |
| `Space.tight`           | `SpacingToken.s8`  | Icon-to-label, inside chips |
| `Space.bodyPadding`     | `SpacingToken.s16` | Default horizontal padding |
| `Space.cardPadding`     | `SpacingToken.s20` | Inside cards |
| `Space.safeGutter`      | `SpacingToken.s24` | Screen edge from safe area |
| `Space.sectionGap`      | `SpacingToken.s32` | Between sections |
| `Space.blockSeparator`  | `SpacingToken.s48` | Major content blocks |
| `Space.tapTarget`       | `SpacingToken.s44` | iOS min tap height (use for `.frame(minHeight:)`) |

## Adding a new intent

If a Primitive needs a value with no semantic name:
1. Add a row above with the new name and the `SpacingToken.sXX` it maps to.
2. Add the alias to `SemanticTokens/Space.swift`.
3. Then use it in the Primitive.

**Never** reach for `SpacingToken.sXX` directly from a Primitive.

**Source:** `SemanticTokens/Space.swift`.
