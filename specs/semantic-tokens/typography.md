# SemanticToken — Typography

Intent-named font roles. Every role uses `relativeTo:` so Dynamic Type still scales.

| Token | Size | Face | Use |
|---|---|---|---|
| `Font.hkDisplay`      | 38 | DM Sans | Hero / display |
| `Font.hkPageHeading`  | 30 | DM Sans | Page heading |
| `Font.hkCardHeadline` | 22 | DM Sans | Card headline |
| `Font.hkSectionTitle` | 17 | DM Sans | Section title |
| `Font.hkBody`         | 14 | DM Sans | Body |
| `Font.hkData`         | 12 | DM Mono | Data, timestamps, tabular |
| `Font.hkButton`       | 10 | DM Mono Medium | Legacy/utility — NOT for DsButton (see hkButtonLg/Sm/Micro) |
| `Font.hkCaption`      | 9  | DM Mono Regular | Caption, eyebrow |
| `Font.hkButtonLg`     | 13 | DM Mono Medium | DsButton large |
| `Font.hkButtonSm`     | 12 | DM Mono Medium | DsButton small |
| `Font.hkButtonMicro`  | 11 | DM Sans Bold | DsButton micro (mono pattern broken at this size for maximum punch — DM Mono ships no Bold) |

Pair with tracking via `HkType.tracking*` and line height via `HkType.line*Multiplier` when needed:

```swift
Text("MAINTENANCE")
    .font(.hkButton)
    .tracking(HkType.trackingWide)
```

**Source:** `SemanticTokens/Font+Tokens.swift`.
