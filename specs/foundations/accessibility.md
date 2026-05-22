# Accessibility — Foundation

## Intent

Non-negotiable. ADHD users benefit disproportionately from accessibility-first design. We hold a higher bar than typical apps.

## Rules

- **Dynamic Type:** every text style scales. Use semantic styles only.
- **VoiceOver:** every interactive primitive ships with `.accessibilityLabel`, `.accessibilityHint` when label isn't self-evident, and meaningful `.accessibilityValue` for stateful controls.
- **Contrast:** WCAG AA minimum. Verify with Xcode's color contrast tool during preview review.
- **Reduce Motion:** respect `@Environment(\.accessibilityReduceMotion)` — disable bounces, replace `.replace` symbol transitions with instant swaps.
- **Tap targets:** 44×44pt minimum. Audit script flags violations.
- **No color-only signaling.** Severity ladder pairs color with stroke weight and a structural spine for urgent. Never communicate state by hue alone.
