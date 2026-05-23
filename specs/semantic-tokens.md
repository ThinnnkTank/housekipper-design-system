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

**Decision 7 exception:** Urgent **hero cards** (single dominant card on a screen) drop `signalTint` fill — flat signal border only.

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
| `Space.bodyPadding`      | `s16` | Default horizontal padding |
| `Space.cardPadding`      | `s20` | Inside cards |
| `Space.safeGutter`       | `s24` | Screen edge from safe area |
| `Space.sectionGap`       | `s32` | Between sections |
| `Space.blockSeparator`   | `s48` | Major content blocks |
| `Space.tapTarget`        | `s44` | iOS min tap height |
| `Space.buttonPaddingLg`  | `s16` | Large button horizontal padding |
| `Space.buttonPaddingSm`  | `s12` | Small + micro button horizontal padding |
| `Space.buttonHeightLg`   | `s40` | Large button visible height |
| `Space.buttonHeightSm`   | `s32` | Small button visible height |
| `Space.buttonHeightMicro`| `s24` | Micro button (icon control) |

### Adding a new intent

Add row → add alias to `Space.swift` → then use in Primitive. **Never** reach for `SpacingToken.sXX` directly.

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

## Typography

| Token | Size | Face | Use |
|---|---|---|---|
| `Font.hkDisplay`      | 38 | DM Sans Medium | Hero / display |
| `Font.hkPageHeading`  | 30 | DM Sans Medium | Page heading |
| `Font.hkCardHeadline` | 22 | DM Sans Medium | Card headline |
| `Font.hkSectionTitle` | 17 | DM Sans Medium | Section title |
| `Font.hkBody`         | 14 | DM Sans Regular | Body |
| `Font.hkData`         | 12 | DM Mono Regular | Data, timestamps, tabular |
| `Font.hkButton`       | 10 | DM Mono Medium | Legacy/utility — NOT for DsButton |
| `Font.hkCaption`      | 9  | DM Mono Regular | Caption, eyebrow |
| `Font.hkButtonLg`     | 13 | DM Mono Medium | `DsButton` large |
| `Font.hkButtonSm`     | 12 | DM Mono Medium | `DsButton` small |
| `Font.hkButtonMicro`  | 11 | DM Mono Medium | `DsButton` micro — mono pattern preserved; icon presence comes from `IconWeight.action` |

Pair with `HkType.tracking*` and `HkType.line*Multiplier` when needed:

```swift
Text("MAINTENANCE")
    .font(.hkButton)
    .tracking(HkType.trackingLabel)
```

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
