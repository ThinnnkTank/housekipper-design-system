# houseKipper Design System

Source of truth for every visual and structural decision in the app. **Specs are the contract. Swift is the artifact.** LLMs read specs first.

> Full architecture rationale lives in [ARCHITECTURE.md](ARCHITECTURE.md).

## The 6-layer model

```
BaseToken       raw values · no SwiftUI
SemanticToken   intent mapping · asset catalog + Swift aliases
Primitive       atomic SwiftUI view · consumes SemanticTokens only
Component       composes Primitives
Pattern         composes Components
Screen          composes Patterns + Components
```

**Rule:** each layer reaches one level down only. Audit script enforces.

## Where things live

| What | Spec | Swift |
|---|---|---|
| Color values | [base-tokens/color-tokens.md](specs/base-tokens/color-tokens.md) | `BaseTokens/ColorTokens.swift` + `Assets.xcassets/Colors/` |
| Spacing values | [base-tokens/spacing-tokens.md](specs/base-tokens/spacing-tokens.md) | `BaseTokens/SpacingTokens.swift` |
| Radius values | [base-tokens/radius-tokens.md](specs/base-tokens/radius-tokens.md) | `BaseTokens/RadiusTokens.swift` |
| Typography values | [base-tokens/typography-tokens.md](specs/base-tokens/typography-tokens.md) | `BaseTokens/TypographyTokens.swift` |
| Border widths | [base-tokens/border-tokens.md](specs/base-tokens/border-tokens.md) | `BaseTokens/BorderTokens.swift` |
| Motion values | [base-tokens/motion-tokens.md](specs/base-tokens/motion-tokens.md) | `BaseTokens/MotionTokens.swift` |
| Shadow values | [base-tokens/shadow-tokens.md](specs/base-tokens/shadow-tokens.md) | `BaseTokens/ShadowTokens.swift` |
| Background | [semantic-tokens/background.md](specs/semantic-tokens/background.md) | `SemanticTokens/BackgroundTokens.swift` |
| Text | [semantic-tokens/text.md](specs/semantic-tokens/text.md) | `SemanticTokens/TextTokens.swift` |
| Action variants | [semantic-tokens/action.md](specs/semantic-tokens/action.md) | `SemanticTokens/ActionTokens.swift` |
| Status severity | [semantic-tokens/status.md](specs/semantic-tokens/status.md) | `SemanticTokens/StatusTokens.swift` |
| Borders | [semantic-tokens/border.md](specs/semantic-tokens/border.md) | `SemanticTokens/BorderSemantics.swift` |
| Space intents | [semantic-tokens/spacing.md](specs/semantic-tokens/spacing.md) | `SemanticTokens/Space.swift` |
| Radius intents | [semantic-tokens/radius.md](specs/semantic-tokens/radius.md) | `SemanticTokens/Radius.swift` |
| Motion intents | [semantic-tokens/motion.md](specs/semantic-tokens/motion.md) | `SemanticTokens/Motion.swift` |
| Typography roles | [semantic-tokens/typography.md](specs/semantic-tokens/typography.md) | `SemanticTokens/Font+Tokens.swift` |
| DsButton | [primitives/ds-button.md](specs/primitives/ds-button.md) | `Primitives/DsButton.swift` (Phase 1a) |
| DsKeyButton | [primitives/ds-key-button.md](specs/primitives/ds-key-button.md) | `Primitives/DsKeyButton.swift` (Phase 1a) |
| NavRail | [components/nav-rail.md](specs/components/nav-rail.md) | `Components/NavRail.swift` (Phase 1b) |
| Pop-up behavior | [patterns/popup.md](specs/patterns/popup.md) | `Patterns/Popup.swift` (Phase 1c) |

## Foundations (the *why*)

- [Color](specs/foundations/color.md)
- [Typography](specs/foundations/typography.md)
- [Spacing](specs/foundations/spacing.md)
- [Radius](specs/foundations/radius.md)
- [Motion](specs/foundations/motion.md)
- [Border](specs/foundations/border.md)
- [Elevation](specs/foundations/elevation.md)
- [Iconography](specs/foundations/iconography.md)
- [Accessibility](specs/foundations/accessibility.md)

## Vetting

`houseKipper/houseKipper/DesignSystem/_Swatches.swift` is the live preview of every populated token. Open it in Xcode → Preview to see colors (light + dark), type ramp, spacing ruler, radii, borders, motion, shadow. Luis signs off on swatches before any Primitive is built.

## Audit

Run before every commit:

```bash
./design-sys/audit.sh
```

Zero violations required. Pre-commit hook coming in Phase 1.

## Status

| Phase | Layer | Status |
|---|---|---|
| 0a | Skeleton | ✅ |
| 0b | BaseTokens + SemanticTokens (values) | ✅ values populated · awaiting visual sign-off via `_Swatches.swift` |
| 1a | Primitives | Specs written for DsButton, DsKeyButton. Implementation pending sign-off. |
| 1b–2 | Components / Patterns / Screens | Not started. |

[BACKLOG.md](BACKLOG.md) · [CHANGELOG.md](CHANGELOG.md)
