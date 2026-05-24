# Foundations

The *why* behind every token. Each section is the intent; numeric values live in `base-tokens.md`, runtime APIs in `semantic-tokens.md`.

---

## Color

Monochrome palette + **one functional accent** (`signal`). Dieter Rams / Braun *Signalfarbe* discipline: signal is never decorative, only functional.

Calm, paper-warm baseline. Signal earns its presence by carrying meaning (attention or urgency).

### Visual severity ladder

`signal` is expressed at two intensities plus a no-severity baseline.

| Level | Treatment | SemanticToken |
|---|---|---|
| Healthy | 1px ink border, no fill | `ActionToken.healthy` (status) / `ink40` baseline |
| Attention | 2px signal border, no fill | `StatusToken.attention` |
| Urgent | 2px signal border + 8px left spine + optional soft tint fill | `StatusToken.urgent` |

**Hero exception (Decision 7):** the `NextUpCard` Component — the screen-level dominant urgent card — drops the soft tint and shows a flat signal border only. Avoids softening the alarm. This exception applies ONLY to `NextUpCard`. Key tiles (`DsKeyButton.urgent`) always get the soft `signalTint` fill regardless of position or prominence.

Severity is a Primitive concern (`DsKeyButton`, status indicators). Buttons use `ActionToken.urgent` for alarm actions but don't carry the severity ladder.

---

## Typography

Two faces. **DM Sans** for body + display; **DM Mono** for utility (labels, data). Space Grotesk dropped — DM Sans handles display at 22/30/38.

### Rules

- **Semantic Font roles only.** Use `Font.hk*` — never `Font.system(size:)` or raw `Font.custom()` in Primitives.
- All semantic roles use `relativeTo:` so Dynamic Type scales the system.
- **Tabular numerals on data.** `Font.hkData` is mono. For other data-aligned text, add `.monospacedDigit()`.
- **Tracking is part of the role.** Mono labels get `HkType.trackingLabel/Wide`, display gets `trackingTight`, eyebrows get `trackingWider`.
- Uppercase reserved for utility (buttons, eyebrows, badges). Body + headings stay sentence case.
- **Inputs are utility.** Search fields, text inputs, numeric fields use DM Mono (same family as buttons, data, and labels). DM Sans is reserved for body prose and display. Reuse an existing `hk*` role if the size matches before introducing a new one.

### Font registration

DM Sans + DM Mono `.ttf` files in `houseKipper/houseKipper/Fonts/`. Registered via `Info.plist` `UIAppFonts`. If `Font.hkBody` falls back to system, registration is missing.

---

## Spacing

Tight, disciplined, 4-base scale. Vnext-canonical with iOS-relevant additions for tap targets and hero layouts.

### The ladder (12 stops)

`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 44 · 48 · 64 · 80`

### Rules

- Primitives import only `Space` (SemanticToken). Never `SpacingToken.sXX` directly.
- If a Primitive needs a value with no semantic name, add the name to `semantic-tokens.md` and `Space.swift` FIRST.
- **Snap to the ladder. No in-between values.** When a tweak is needed, move to the *nearest existing stop* — never propose a new one mid-scale. 17 → 20. 14 → 10. 18 → 20. New stops are a BaseToken change and require explicit sign-off. The same snapping discipline applies across every token system (radius, opacity, font size, border width, motion duration) — pick the existing stop that's closest, don't invent an interpolation. Adding a token is "decisions that must be surfaced" (see CLAUDE.md).
- **Micro values are valid currency *inside* a primitive.** Sub-grid numbers like `1`, `1.5`, `2`pt are legitimate building blocks for primitive-internal construction — badge rings, hairline strokes, small offsets where rounded geometry demands precision, info-dense rendering. Where they're NOT valid: spacing or layout. A screen, pattern, or component composition uses only the 4-base `Space` ladder. The carve-out is the primitive interior, not the surrounding gaps. Examples: `InventoryToken.badgeBorderWidth = 2`, `badgeOverhangPill = 2`, `BorderToken.hairline = 1` are fine; `.padding(2)` between two cards on a screen is not.
- iOS-native control dimensions (toggle 51×31, tab bar 49pt) — honor the platform.
- Optical centering: an off-grid offset to make a button look right is fine. Comment why.

### Exemptions

Border widths · native Apple control dimensions · letter spacing, durations, opacities.

---

## Radius

From vnext usage. Specific radii used inline at Primitive layer when needed; standard intents at SemanticToken layer.

`r6/r8/r10/r12/r14/r16/r18/r22/rPill` available. Semantic intents: `sm · md · lg · sheet · hero · pill`.

---

## Border

Borders carry the depth paprLCD chose not to express in shadows. Defined on **two orthogonal axes**:

- **Width:** `normal` (1pt) · `strong` (2pt)
- **Color:** `subtle` (ink20, soft separator) · `normal` (ink, default affordance) · `strong` (signal, severity)

Six combinations from 3×2. Callers pick independently — no pre-named pairings.

### Rules

- Solid by default for borders. Containers, buttons, status pills — all solid.
- **Dashed lines are reserved exclusively for dividers.** Always `Border.Color.subtle` + `Border.Width.normal`. Drawn only through `DsDivider(style: .dashed)`. Never re-implement a dashed stroke elsewhere — the audit will reject `StrokeStyle(... dash: ...)` outside `Primitives/DsDivider.swift`.
- Never communicate state by border color alone — pair with structure (spine, fill).
- Signal borders (`Border.Color.strong`) are reserved for severity contexts (`StatusToken`). Not for ordinary interactive affordances.
- Use `Border.Color.*` and `Border.Width.*` (semantic), never raw `lineWidth:` or `Color(hex:)`. Audit enforces.

---

## Motion

Calm. Snappy when small, considered when meaningful. Never bouncy.

### Vocabulary

| Token | Duration | Use |
|---|---|---|
| `Motion.quick`      | 120ms | Micro — toggle flips, press release |
| `Motion.standard`   | 300ms | Default UI — sheets, dropdowns, press-release, color changes |
| `Motion.gentle`     | 400ms | Considered — status reveals |
| `Motion.expressive` | 600ms | Earned moments — success, attention loops |

### Rules

- **Symbol effects first.** For SF Symbol state changes use `.symbolEffect(.bounce/.pulse/etc.)`. Never hand-animate when an effect exists.
- **Respect Reduce Motion.** Read `@Environment(\.accessibilityReduceMotion)`. When on: kill expressive/gentle to quick; disable repeating loops.
- **No springs by default.** SwiftUI's `.bouncy`, `.spring` produce a personality that doesn't match paprLCD's restraint. Use only for explicit micro-interactions where rebound is semantically meaningful.
- Never raw `.easeIn`, `.linear`. Always `Motion.*`. Audit enforces.

---

## Elevation

paprLCD is **flat**. Depth lives in borders, not shadows. We ship one shadow (`ShadowToken.subtle`, 6×8×0 blur, 8% ink), used sparingly.

### Rules

- Default surfaces have no shadow. Use `Border.default/strong` to separate layers.
- `ShadowToken.subtle` only for elements that physically stand off the page — status stages, hovering popovers. Never on cards in lists.
- No blur. Vnext shadow is an offset stamp, not a soft drop.
- Never raw `.shadow(...)` in Primitives or above. Audit enforces.

---

## Iconography

SF Symbols-first. Native iOS, free Dynamic Type, free symbol effects, system-consistent.

### Rules

- **SF Symbols only.** No custom SVGs, no third-party icon libraries.
- The SF Symbols Mac app is the reference catalog.
- **Custom icons** only as a last resort when SF Symbols has no equivalent (grass, tree, shed, couch, faucet). Export as PDF vector → asset catalog. Custom-icon backlog tracked in `BACKLOG.md`.
- **Icon weight matches body font weight.** Bound when typography decisions firm up.
- **Microinteractions via `.symbolEffect`** (`.bounce`, `.pulse`, `.wiggle`, `.rotate`, `.variableColor`, `.replace`).

---

## Conventions

File and naming rules that aren't tokens or visual but affect how the system is read.

- **Primitive prefix.** SwiftUI Primitive views are prefixed `Ds` (`DsButton`, `DsDivider`). Avoids collision with SwiftUI's own types. Components and above are name-distinct, no prefix.
- **Type-helper prefix.** Typography helpers that aren't Fonts are prefixed `Hk` (`HkType.trackingLabel`, `HkType.lineBodyMultiplier`). SwiftUI's `.font()` modifier can't carry letter-spacing or line-height — those need their own modifiers (`.tracking()`, `.lineSpacing()`). `HkType` is the namespace holding those values so they pair cleanly with a `Font.hk*` role.
- **Audit-exempt files: `_`-prefix.** Any Swift file whose name starts with `_` (e.g. `_Swatches.swift`) is exempt from `audit.sh` layer-violation checks. Reserved for design-system instrumentation (live previews, demos) that intentionally reach across layers. Never use `_`-prefix on production code.
- **Preview blocks.** Code inside `#Preview { ... }` is also audit-exempt — same intent (previews demonstrate primitives, not build with them).
- **Test files** (`*Tests/`) are audit-exempt.

---

## Accessibility

Non-negotiable. ADHD users benefit disproportionately from accessibility-first design.

### Rules

- **Dynamic Type:** every text style scales. Use semantic styles only.
- **VoiceOver:** every interactive primitive ships with `.accessibilityLabel`, `.accessibilityHint` when label isn't self-evident, `.accessibilityValue` for stateful controls.
- **Contrast:** WCAG AA minimum. Verify with Xcode's color contrast tool during preview review.
- **Reduce Motion:** respect `@Environment(\.accessibilityReduceMotion)`. Disable bounces and replace `.replace` symbol transitions with instant swaps.
- **Tap targets:** 44×44pt minimum via `.frame(minHeight: Space.tapTarget)`.
- **No color-only signaling.** Severity ladder pairs color with stroke weight and structural spine for urgent. Never communicate state by hue alone.
