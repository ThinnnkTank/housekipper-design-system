# Elevation — Foundation

## Intent

paprLCD is **flat**. Depth lives in borders, not shadows. We ship exactly one shadow token (`ShadowToken.subtle`, 6px/8px/0 blur, 8% ink), used sparingly.

## Rules

- Default surfaces have **no shadow.** Use `Border.default` or `Border.strong` to separate layers.
- `ShadowToken.subtle` is used only for elements that physically "stand off" the page — status stages, hovering popovers. Never on cards in lists.
- No blur. The vnext shadow is an offset stamp, not a soft drop shadow. Modern iOS apps default to softer; we deliberately don't.
- Never use raw `.shadow(...)` modifiers in Primitives or above. If needed, wrap into a Primitive helper. Audit enforces.

See `base-tokens/shadow-tokens.md`.
