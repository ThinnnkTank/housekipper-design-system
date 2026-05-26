# Semantic Tokens

Intent layer. Maps base values to use cases. **Primitives import these — never `BaseTokens` directly.**

Source: `houseKipper/houseKipper/DesignSystem/SemanticTokens/*.swift`.

---

## Background

| Token | Maps to | Use |
|---|---|---|
| `BackgroundToken.primary`   | `paper`  | Default screen background |
| `BackgroundToken.secondary` | `paper2` | Cards, sheets, recessed surfaces |

---

## Text

| Token | Maps to | Use |
|---|---|---|
| `TextToken.primary`   | `ink`    | Headings, body |
| `TextToken.strong`    | `ink80`  | Strong emphasis |
| `TextToken.secondary` | `ink60`  | Secondary text, helper |
| `TextToken.muted`     | `ink40`  | Captions, healthy status |
| `TextToken.faint`     | `ink20`  | Disabled-ish, hint |
| `TextToken.onSignal`  | `paper`  | Text on signal fill |
| `TextToken.onAction`  | `paper`  | Text on filled action |

---

## Action

Visual variants for `DsButton`. **Not for severity** — see Status below.

Variants: `primary` · `secondary` · `ghost` · `urgent`

Each has **three states** — rest, disabled, pressed — and **three properties** — fill, border, foreground. The 12 calls are exposed via:

```swift
ActionToken.fill(_:)               ActionToken.fillDisabled(_:)       ActionToken.fillPressed(_:)
ActionToken.border(_:)             ActionToken.borderDisabled(_:)     ActionToken.borderPressed(_:)
ActionToken.foreground(_:)         ActionToken.foregroundDisabled(_:) ActionToken.foregroundPressed(_:)
```

### Rest

| Variant | Fill | Border | Foreground |
|---|---|---|---|
| primary   | `ink`     | clear  | `paper` |
| secondary | `ink05`   | `ink`  | `ink`   |
| ghost     | clear     | clear  | `ink`   |
| urgent    | `signal`  | clear  | `paper` |

### Disabled

| Variant | Fill | Border | Foreground |
|---|---|---|---|
| primary   | `ink40`         | clear   | `paper` |
| secondary | `ink05`         | `ink20` | `ink40` |
| ghost     | clear           | clear   | `ink40` |
| urgent    | `signalMuted`   | clear   | `paper` |

### Pressed — the rule

**Press feedback reuses the disabled palette of a related variant.** Soft "softening" effect on tap, not stark inversion.

| Pressed | Uses palette of |
|---|---|
| `primary`   | `secondary-disabled` |
| `secondary` | `secondary-disabled` |
| `ghost`     | `primary-disabled`   |
| `urgent`    | `urgent-disabled`    |

Border *width* is set at the Primitive layer, not ActionToken. `DsButton` uses 1pt.

---

## Status

Severity ladder for **status indicators** (dots, pills, key buttons). Distinct from `ActionToken` (buttons).

| Severity | Tint | Soft fill |
|---|---|---|
| `healthy`   | `ink40` (muted) | — |
| `attention` | `signal` | — |
| `urgent`    | `signal` | `signalTint` |

**Decision 7 exception:** the `NextUpCard` Component (screen-level dominant urgent card) drops `signalTint` fill — flat signal border only. Exception applies ONLY to `NextUpCard`. `DsKeyButton` with `severity: .urgent` always gets the soft fill via `StatusToken.softFill(.urgent)`.

```swift
StatusToken.tint(.attention)
StatusToken.softFill(.urgent)
```

---

## Border

Two orthogonal axes — width × color. Callers pick independently.

### `Border.Width`

| Token | Value |
|---|---|
| `.normal` | 1pt (`BorderToken.hairline`) |
| `.strong` | 2pt (`BorderToken.strong`)   |

### `Border.Color`

| Token | Maps to | Use |
|---|---|---|
| `.subtle` | `ink20` | Soft separators, secondary affordances |
| `.muted`  | `ink40` | Mid-weight separators — `DsLabeledDivider` lines, anywhere `.subtle` reads too faint but `.normal` (full ink) is too strong |
| `.normal` | `ink`   | Default affordance ("this is interactive") |
| `.strong` | `signal` | Severity / urgent context |

### Usage

```swift
RoundedRectangle(cornerRadius: Radius.md)
    .strokeBorder(Border.Color.subtle, lineWidth: Border.Width.normal)
```

Six combinations from 3×2. No pre-named pairings (`Border.default`, `Border.affordance` — removed) because they were collapsing the two axes and creating naming debt.

`DsButton` uses `Border.Width.normal` (1pt) for all variant borders; the *color* comes from `ActionToken.border(_:)`/`borderDisabled(_:)`/`borderPressed(_:)` per variant + state.

### `Border.dashPattern`

Dash array `[3, 4]` (dash 3pt, gap 4pt). **Reserved exclusively for `DsDivider`** per the foundations rule. Audit enforces: any `StrokeStyle(... dash: ...)` outside `Primitives/DsDivider.swift` is a violation.

---

## Spacing

Intent-named. **Primitives use these, never `SpacingToken.sXX`.** Audit enforces.

| Token | Maps to | Use |
|---|---|---|
| `Space.hairline`         | `s4`  | Tiny gaps, divider padding |
| `Space.tight`            | `s8`  | Icon-to-label, inside chips |
| `Space.snug`             | `s12` | Between elements that belong together but need a beat (header→list, section→content, hero icon→content) |
| `Space.bodyPadding`      | `s16` | Default horizontal padding |
| `Space.cardPadding`      | `s20` | Inside cards |
| `Space.safeGutter`       | `s24` | Screen edge from safe area |
| `Space.sectionGap`       | `s32` | Between sections |
| `Space.pageInset`        | `s36` | Additive page-chrome top breathing (Screen-layer use; sits on top of SwiftUI safe-area inset). First consumer: DashboardScreen 2026-05-25. |
| `Space.blockSeparator`   | `s48` | Major content blocks |
| `Space.tapTarget`        | `s44` | iOS min tap height |
| `Space.buttonPaddingLg`        | `s20` | Large button horizontal padding — secondary / ghost / urgent at large |
| `Space.buttonPaddingPrimaryLg` | `s24` | **Primary** at large gets +4pt L/R extra so the screen's main CTA carries more visual weight than peers (Luis 2026-05-25) |
| `Space.buttonPaddingSm`        | `s12` | Small + micro button horizontal padding (all variants) |
| `Space.buttonHeightLg`   | `s40` | Large button visible height |
| `Space.buttonHeightSm`   | `s32` | Small button visible height |
| `Space.buttonHeightMicro`| `s24` | Micro button (icon control) |
| `Space.avatarRegular`    | `s32` | `DsAvatar` default diameter |

### Adding a new intent

Add row → add alias to `Space.swift` → then use in Primitive. **Never** reach for `SpacingToken.sXX` directly.

### Unmapped raw stops

`SpacingToken.s36` was promoted to `Space.pageInset` 2026-05-25 when `DashboardScreen.swift` shipped (the mock was audit-exempt by `_` prefix; the real Screen needs a SemanticToken alias). `Space.pageInset` = additive page-chrome top breathing — sits on top of SwiftUI's auto safe-area inset. First consumer: DashboardScreen's `.padding(.top, Space.pageInset)`.

---

## Radius

| Token | Maps to | Use |
|---|---|---|
| `Radius.sm`    | `r8`    | Small surfaces, badges |
| `Radius.md`    | `r12`   | Default card/button |
| `Radius.lg`    | `r16`   | Larger surfaces |
| `Radius.sheet` | `r18`   | ActionSheet, status stage |
| `Radius.hero`  | `r22`   | Hero panels |
| `Radius.pill`  | `rPill` | Pills, buttons, search |

---

## Motion

| Token | Maps to | Use |
|---|---|---|
| `Motion.quick`      | `easeOut 120ms`   | Toggle flip, press release |
| `Motion.standard`   | `easeOut 220ms`   | Sheet present, default UI transition |
| `Motion.gentle`     | `easeInOut 400ms` | Severity escalation, status reveal |
| `Motion.expressive` | `easeOut 600ms`   | Success confirmation, attention loop |

```swift
withAnimation(Motion.standard) { isOn.toggle() }
```

---

## Typography — `Type.{category}.{size}`

13 complete styles. Each style bundles face + size + weight + tracking + case. Applied via `.typeStyle(_:)` — single modifier per call site, no manual tracking/case.

| Style | Face / weight | Size | Tracking | Case | Use |
|---|---|---|---|---|---|
| `Type.Display.lg` | DM Sans Medium | 38 | 0 | — | Brand wordmark, onboarding hero |
| `Type.Title.xl`   | **DM Sans Bold** | 26 | 0 | — | **H1** — active-house heading (`TopBar`), room/project/settings titles. History: mono Medium 30 → mono Medium 26 → **sans Bold 26** (Luis 2026-05-25 — mono read too utility for the H1; sans Bold restores hierarchy and matches H2 family). |
| `Type.Title.lg`   | DM Sans Bold | 22 | -0.8 (tighter) | — | **H2** — card headlines (NextUpCard, ActiveProjectCard, modal titles) |
| `Type.Title.md`   | DM Sans Medium | 17 | 0 | — | **H3** — sub-section titles, MaintenanceRow title |
| `Type.Body.md`    | DM Sans Regular | 14 | 0 | — | Paragraph + list-row copy |
| `Type.Label.lg`   | DM Mono Medium | 14 | +0.8 | UPPER | `DsButton.large` labels |
| `Type.Label.md`   | DM Mono Medium | 13 | +0.2 (snug) | UPPER | `DsButton.small` labels |
| `Type.Label.sm`   | DM Mono Medium | 12 | +0.9 (micro) | UPPER | `DsButton.micro`, `DsKeyButton` tile labels, `DsWeatherChip`, MaintenanceRow location, NextUpCard dueLabel, MaintenanceList eyebrow. History: 12 → 13 → 12 (final, Luis 2026-05-25 dashboard density). |
| `Type.Label.xs`   | DM Mono Medium | 10 | +0.8 (label) | UPPER | `NavRail` chip labels, `DsLabeledDivider` labels, eyebrows. **Consumers MUST use `TextToken.primary` foreground** — at 10pt the role needs full ink contrast to remain legible. |
| `Type.Data.lg`    | DM Mono Regular | 13 | 0 | — | CalendarMonth date numbers. Larger tabular data that needs more presence than `.sm`. Added Luis 2026-05-25. |
| `Type.Data.md`    | DM Sans Bold | 13 | 0 | — | `DsBadge` content, ActiveProjectCard progress %. Only Bold weight in the system. |
| `Type.Data.sm`    | DM Mono Regular | 12 | 0 | — | Timestamps, maintenance metadata, descriptive captions, CalendarMonth legend today swatch |
| `Type.Data.xs`    | DM Mono Regular | 9 | 0 | — | Smallest data text, micro-labels |

### Reuse rule

Every typographic surface MUST map to one of the 12 styles. Reuse first; surface a new style only when the existing scale truly doesn't fit AND the proposal demonstrates ≥1 anticipated reuse beyond the first consumer.

Full rule in [`foundations.md → Typography`](foundations.md#typography). The scale itself lives in `houseKipper/houseKipper/DesignSystem/SemanticTokens/Type.swift`.

### Exceptions

When a surface needs the FONT portion of a style without its tracking/case bake (e.g. `DsSearchField` uses `Type.Label.lg.font` for typed input that should NOT auto-uppercase), use the `.font` property of the style directly and apply tracking separately. Document the exception inline with a code comment.

### `HkType` — typography helpers (legacy / advanced)

`HkType.tracking*` and `IconWeight.*` remain available for cases where a primitive applies its own tracking on top of a font (rare) or where SF Symbols need a specific weight independent of the role they sit alongside. **Most call sites should NOT reach for these directly** — `.typeStyle(...)` bakes the tracking already.

**Tracking** (point values, applied via `.tracking`):

| Token | Value | Use |
|---|---|---|
| `HkType.trackingNone`   | 0     | Default |
| `HkType.trackingSnug`   | +0.2  | Small button labels (13pt mono) |
| `HkType.trackingMicro`  | +0.9  | Micro button labels (12pt mono) |
| `HkType.trackingLabel`  | +0.8  | Large button labels (14pt mono) + mono utility |
| `HkType.trackingWide`   | +1.4  | Eyebrows, sparse headers |
| `HkType.trackingWider`  | +1.8  | Wider eyebrows |
| `HkType.trackingTight`  | -0.6  | Large display only |

**Line-height multipliers** (multiply the font size, apply via `.lineSpacing()` if needed):

| Token | × |
|---|---|
| `HkType.lineHeroMultiplier`    | 1.06 |
| `HkType.lineTitleMultiplier`   | 1.08 |
| `HkType.lineBodyMultiplier`    | 1.65 |
| `HkType.lineUtilityMultiplier` | 1.20 |

The `Hk` prefix is the houseKipper namespace for type helpers — see [foundations.md → Conventions](foundations.md) for the full prefix rules.

---

## Inventory

Pass-through SemanticToken aliases over `InventoryToken` so Primitives consume the SemanticToken layer (not BaseToken directly). Names match BaseToken since no semantic transformation is needed right now. If/when intent diverges from raw values, rename here.

| Token | Maps to |
|---|---|
| `Inventory.tileHeight`        | `InventoryToken.tileHeight` (60) |
| `Inventory.tileMinWidth`      | `InventoryToken.tileMinWidth` (100) |
| `Inventory.railColumnGap`     | `InventoryToken.railColumnGap` (6) |
| `Inventory.railRowGap`        | `InventoryToken.railRowGap` (6) |
| `Inventory.badgeSize`         | `InventoryToken.badgeSize` (20) |
| `Inventory.badgeSizeSmall`    | `InventoryToken.badgeSizeSmall` (17) |
| `Inventory.badgePaddingH`     | `InventoryToken.badgePaddingH` (6) |
| `Inventory.badgeOverhangRect` | `InventoryToken.badgeOverhangRect` (8) |
| `Inventory.badgeOverhangPill` | `InventoryToken.badgeOverhangPill` (2) |
| `Inventory.badgeBorderWidth`  | `InventoryToken.badgeBorderWidth` (2) |

**Source:** `SemanticTokens/Inventory.swift`.

---

## Press strategies

Documented vocabulary for how a Primitive's pressed state composes from existing SemanticTokens. Two named patterns today. Each Primitive's spec declares which strategy it uses; implementation is Primitive-internal (3-line composition) until a third consumer earns code extraction.

### `Press.soften` — used by `DsButton`

Pressed state reuses the **disabled-look palette** of a related variant. Visual feels like the button momentarily "deactivated."

Resolved via `ActionToken.{fill, border, foreground}Pressed(variant)` — already in code. See [primitives/ds-button.md](primitives/ds-button.md) for the per-variant mapping.

### `Press.invert` — used by `DsKeyButton`, future `MaintenanceRow`, future `ActionSheetItem`

Pressed state **inverts the surface**:

| Property | Resolved color |
|---|---|
| `fill`        | `TextToken.primary` (ink) |
| `border`      | `TextToken.primary` (ink) |
| `foreground`  | `BackgroundToken.primary` (paper) |

No new code at the SemanticToken layer — Primitives compose the three SemanticTokens directly in their pressed branch. If a third Primitive adopts invert, extract a helper.

---

## Icon weight

Icon weight is **decoupled from label weight** so icons hold uniform visual presence across button sizes.

| Token | Value | Use |
|---|---|---|
| `IconWeight.action` | `.bold`    | Icons inside `DsButton` / affordances |
| `IconWeight.body`   | `.regular` | Icons inline in body text |

```swift
Image(systemName: "checkmark").fontWeight(IconWeight.action)
```

Without this, an SF Symbol inside a button inherits the surrounding label font weight (DM Mono Medium for large/small, DM Sans Bold for micro), producing inconsistent stroke widths across sizes. `IconWeight.action` forces all button icons to render at bold thickness regardless of size.
