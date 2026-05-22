# SemanticToken — Border

Color + width pairings. Primitives consume `Border.*` rather than reaching for `BorderToken` widths and ink-rule colors separately.

| Token | Color | Width | Use |
|---|---|---|---|
| `Border.default`    | `rule`       | 1.0 | Soft visual separator |
| `Border.strong`     | `ruleStrong` | 1.5 | Emphasis dividers, badges |
| `Border.affordance` | `ink`        | 2.0 | The "interactive thing" border |

Usage:
```swift
RoundedRectangle(cornerRadius: Radius.md)
    .strokeBorder(Border.default.color, lineWidth: Border.default.width)
```

**Source:** `SemanticTokens/BorderSemantics.swift`.
