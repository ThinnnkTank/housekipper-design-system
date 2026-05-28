# Handoff — for Claude Designer

This document is the entry point for **Claude Designer** (external Claude environment that renders HTML mocks + prototypes against a shared design system). Read this first. It maps our existing structure onto the layout you proposed, answers your platform questions, embeds the token quick-reference tables, and lists the deliverables we'd like back.

**Roles:**
- **You (Claude Designer)** = source of truth for *visual* specs — `tokens.css`, per-component HTML kitchen-sinks, full-screen mocks.
- **Us (Claude Code, in the SwiftUI codebase)** = source of truth for *implementation*.
- **The loop:** you compose mocks from documented Primitives + Components; we translate those mocks back to SwiftUI; the canonical specs in `design-sys/specs/` stay synced with both sides.

---

## 1. Quick orient

houseKipper is an iOS (SwiftUI) app for adults with ADHD to manage their household — chores, rooms, maintenance, projects. The design system lives under `design-sys/`.

**Read order after this doc:**
1. `README.md` — philosophy + the 6-layer model
2. `specs/foundations.md` — the *why* (color, type, spacing, border, motion intent)
3. `specs/base-tokens.md` — raw values (hex, sizes, durations)
4. `specs/semantic-tokens.md` — intent aliases (the layer Primitives consume)
5. Any specific Primitive or Component you're mirroring → `specs/primitives/<name>.md` or `specs/components/<name>.md`

`CHANGELOG.md` carries every dated decision. `BACKLOG.md` tracks deferred work. Skip those on first pass — come back when you need decision history.

---

## 2. Layer-to-file map

Your proposed skeleton vs. our actual paths:

| Your expected path | Our actual file(s) |
|---|---|
| `/design-system/README.md` | `design-sys/README.md` + this `HANDOFF.md` |
| `/design-system/tokens/colors.md` | `specs/base-tokens.md § Color` + `specs/semantic-tokens.md § Background/Text/Border/Status/Action` |
| `/design-system/tokens/typography.md` | `specs/base-tokens.md § Typography` + `specs/semantic-tokens.md § Typography` |
| `/design-system/tokens/spacing.md` | `specs/base-tokens.md § Spacing` + `specs/semantic-tokens.md § Spacing` |
| `/design-system/tokens/radii.md` | `specs/base-tokens.md § Radius` + `specs/semantic-tokens.md § Radius` |
| `/design-system/tokens/shadows.md` | `specs/base-tokens.md § Shadow` |
| `/design-system/tokens/motion.md` | `specs/base-tokens.md § Motion` + `specs/semantic-tokens.md § Motion` |
| `/design-system/components/Button.md` | `specs/primitives/ds-button.md` |
| `/design-system/components/Card.md` | We split: `specs/primitives/*.md` for atomic Primitives, `specs/components/*.md` for compositions |
| `/design-system/patterns/` | `specs/patterns/` (sparse — only `popup.md` today) + `specs/screens/` |

### The 6-layer model (one paragraph)

We use **BaseToken → SemanticToken → Primitive → Component → Pattern → Screen**. Composition reaches one level down: Primitives consume SemanticTokens, Components compose Primitives, etc. Components/Patterns/Screens may *also* consume SemanticTokens directly for chrome (background, text, geometry, motion). The strict boundary is **BaseTokens** — only the SemanticToken layer touches raw values. `audit.sh` enforces this. We keep this layering deliberately because it caught real drift in early rounds; please mirror it conceptually in your CSS (e.g. base custom-properties → semantic aliases → component classes), not flatten it.

### Token quick-reference vs. canonical specs

Your brief asked for a markdown file per token category (colors / typography / spacing / radii / shadows / motion). We've **embedded those quick-reference tables in § 4 below** rather than split them into six new files. The canonical specs (`base-tokens.md`, `semantic-tokens.md`) are richer — they include decision history, deprecated values, edge cases. The tables in § 4 are the flat surface you asked for; the canonical specs are the deep context. If you genuinely need separated files (`tokens/colors.md`, etc.), tell us and we'll generate them as projections.

---

## 3. Platform & architecture answers

### Target platforms

- **iOS 17+** minimum.
- **iPad-primary.** Our vet device is iPad Pro 13" landscape — the dashboard is laid out for that.
- **iPhone** is secondary (not yet vet-tested in this iteration; layouts assume tablet width).
- SwiftUI throughout. No UIKit except where SwiftUI forces it (window-level gestures).

### Typography

- **DM Sans** (body + display) + **DM Mono** (utility, labels, data). Both Google Fonts, SIL OFL license — confirmed legal to ship inside an iOS app.
- Font files bundled at `design-sys/fonts/DM_Sans/` and `design-sys/fonts/DM_Mono/`. Production code references them via `Type.{Category}.{size}` (15 complete styles — see § 4 below).
- **Display category:** DM Sans Medium for hero (`Type.Display.lg` 38pt).
- **Title category:** DM Sans Bold for H1/H2/H4, DM Sans Medium for H3.
- **Menu category:** DM Sans Bold 13pt — dedicated role for top-tab nav labels.
- **Body category:** DM Sans Regular.
- **Label category:** DM Mono Medium uppercase + tracking — buttons, eyebrows, tile labels.
- **Data category:** DM Mono Regular mixed case — timestamps, captions, calendar dates. One exception: `Type.Data.md` is DM Sans Bold (badges, progress %).
- **Dynamic Type:** roles declare `relativeTo:` so the system scales, but the dynamic-type strategy is **not yet implemented end-to-end** — flagged in BACKLOG.

### Light / dark mode

- **Both modes supported.**
- Token *names are mode-agnostic* — same name in Swift, same name everywhere. Resolution happens in the iOS Asset Catalog (`Assets.xcassets/Colors/<token>.colorset/Contents.json`) with separate Light + Dark Appearance entries.
- Mirror in CSS as custom properties scoped under `:root` (light) and `[data-theme="dark"]` (dark). Single API for component CSS; resolver swap at the root.
- Example: `BackgroundToken.page` resolves to `#D5D7D1` light / `#0E120F` dark. Every other token follows the same pattern.

### Brand assets

- **App icon:** `houseKipper/Assets.xcassets/AppIcon.appiconset/` (not in this design-sys repo).
- **Logo SVG / marketing imagery:** none yet. **Known gap** — if you need a logo for kitchen-sink branding, use the app name "houseKipper" as a wordmark in `Type.Display.lg` (DM Sans Medium 38pt) as a placeholder. Don't fabricate a logo.
- **Fonts** at `design-sys/fonts/` (DM Sans + DM Mono TTF files).

### Naming conventions

- **Primitives use `Ds*` prefix:** `DsButton`, `DsKeyButton`, `DsBadge`, `DsAvatar`, `DsStatusDot`, `DsProgressBar`, `DsSearchField`, `DsDivider`, `DsLabeledDivider`, `DsWeatherChip`, `DsTabItem`.
- **Components have no prefix:** `NextUpCard`, `ActiveProjectCard`, `SpaceCard`, `CalendarMonth`, `MaintenanceList`, `MaintenanceRow`, `TopNav`.
- **One named exception:** `SignalButton` (a specialized one-off — may dissolve back into `DsButton` later).
- **Tokens are camelCase accessed via Swift enums:** `Space.bodyPadding`, `Type.Label.lg`, `TextToken.primary`, `BackgroundToken.page`, `Radius.md`, `Motion.standard`, `ActionToken.fill(.primary)`. For CSS we recommend kebab-case mirrors: `--space-body-padding`, `--type-label-lg`, `--text-primary`, `--bg-page`, `--radius-md`, `--motion-standard`, `--action-fill-primary`.
- **Dev-tool files prefixed `_`** (e.g. `_Swatches.swift`, `_Inspector.swift`) — audit-exempt, `#if DEBUG`-gated. Not part of the shipped surface area.

### Architecture quirks

- **Two press strategies coexist.** Document both when you render pressed states:
  - **`Press.soften`** (used by `DsButton`) — pressed reuses the disabled-look palette of a related variant. Soft "deactivation" feel.
  - **`Press.invert`** (used by `DsKeyButton`) — pressed inverts surface: ink fill + ink border + paper text. Stark inversion feel.
- **Asymmetric press animation.** Press is **instant** (no animation); release is animated with `Motion.standard` (300ms ease-out). Touch-down feels immediate; release gives the eye time to register the tap.
- **Dashed lines reserved for `DsDivider` only.** Every other border is solid. Audit rejects `StrokeStyle(... dash: ...)` outside `DsDivider.swift`.
- **`.identify(name:tokens:file:line:)` modifier** is a dev tool (Inspector), not a real component. Long-press in the dev swatch app captures element identity → clipboard for agent context. Audit-exempt.
- **Icon weight is decoupled from label weight** via `IconWeight.action` (`.bold`) so icons hold uniform stroke across button sizes.
- **`IconCatalog.*`** is the production indirection from concept name → SF Symbol name (`IconCatalog.Room.kitchen` → `"fork.knife"`). DS Primitives accept a generic `String` icon param; the catalog is the call-site discipline.
- **`signal` is functional, not decorative.** Dieter Rams *Signalfarbe* — orange is reserved for attention/urgent severity. Never use as accent for a normal CTA.

---

## 4. Token quick-reference

Format: `Token | Value | Use for`. Each subsection ends with a pointer to the canonical spec for deeper context.

### Colors

#### Ink scale (opacity steps on `#1C1C1A`)

| Token | Light | Dark | Use |
|---|---|---|---|
| `ink`   | `#1C1C1A`             | per colorset | Primary text, strong border |
| `ink80` | `rgba(0,0,0,0.82)`    | per colorset | Strong emphasis |
| `ink60` | `rgba(0,0,0,0.68)`    | per colorset | Secondary text |
| `ink40` | `rgba(0,0,0,0.50)`    | per colorset | Muted text · healthy status |
| `ink20` | `rgba(0,0,0,0.22)`    | per colorset | Faint text · hairline alt |
| `ink10` | `rgba(0,0,0,0.11)`    | per colorset | Hover fill |
| `ink05` | `rgba(0,0,0,0.055)`   | per colorset | Secondary fill rest |

#### Surfaces

| Token | Light | Dark | Role |
|---|---|---|---|
| `paper`  | `#E0E2DC` | `#161A17` | Card / chip / pill surface — sits ON TOP of `pageBg` |
| `paper2` | `#DDE1DA` | `#1E2420` | Recessed input surface (DsSearchField, Inspector banner) |
| `pageBg` | `#D5D7D1` | `#0E120F` | Page / app background — sits BEHIND all cards. Notably darker than `paper` so cards lift visually |

#### Signal (the single functional accent)

| Token | Light | Dark | Use |
|---|---|---|---|
| `signal`         | `#E06518` | `#FF7D30` | Attention / urgent severity, urgent button fill |
| `signalStrong`   | `#B84E0E` | `#FF7D30` | Pressed signal, strong signal text |
| `signalMuted`    | `signal @ 40%` | `#FF8F54 @ 40%` | Disabled urgent button |
| `signalTint`     | `signal @ 12%` | `#FF8F54 @ 16%` | Urgent soft-fill background |
| `signalTintSoft` | `signal @ 7%`  | `#FF8F54 @ 10%` | Even softer wash |

#### Semantic aliases over the base colors

| Token | Maps to | Use |
|---|---|---|
| `BackgroundToken.primary`   | `paper`  | Card fill |
| `BackgroundToken.secondary` | `paper2` | Recessed input surfaces |
| `BackgroundToken.page`      | `pageBg` | App background |
| `TextToken.primary`   | `ink`    | Headings, body |
| `TextToken.strong`    | `ink80`  | Strong emphasis |
| `TextToken.secondary` | `ink60`  | Secondary text |
| `TextToken.muted`     | `ink40`  | Captions, healthy status |
| `TextToken.faint`     | `ink20`  | Disabled-ish |
| `TextToken.onSignal`  | `paper`  | Text on signal fill |
| `TextToken.onAction`  | `paper`  | Text on filled action |
| `Border.Color.subtle` | `ink20`  | Soft separators, secondary affordances |
| `Border.Color.muted`  | `ink40`  | Mid-weight separators |
| `Border.Color.normal` | `ink`    | "This is interactive" |
| `Border.Color.strong` | `signal` | Severity / urgent |

Full context: `specs/base-tokens.md § Color` + `specs/semantic-tokens.md § Background/Text/Border/Status/Action`.

### Typography

#### Faces

| Token | Value | Use |
|---|---|---|
| `Face.sans`     | `"DMSans"`      | Body + display |
| `Face.mono`     | `"DMMono"`      | Labels, metadata, data |
| `Face.sansBold` | `"DMSans-Bold"` | Bold weight |

#### Size ramp

`9 · 10 · 11 · 12 · 13 · 14 · 17 · 22 · 26 · 30 · 38` pt

`size9/11/13` are explicit exemptions to the 4-grid (needed for micro-utility text). `size26` bridges 22→30 for H1.

#### Weights

DM Sans: `light(300) · regular(400) · medium(500) · semibold(600) · bold(700) · black(900)`.
DM Mono: `light · regular · medium` only (no Bold ships with DM Mono — DM Sans Bold fills that role at the micro button size).

#### The complete scale (15 styles — `Type.{category}.{size}`)

| Style | Face / weight | Size | Tracking | Case | Use |
|---|---|---|---|---|---|
| `Type.Display.lg` | DM Sans Medium | 38pt | 0 | — | Brand wordmark, onboarding hero |
| `Type.Title.xl`   | DM Sans **Bold** | 26pt | 0 | — | **H1** — house heading, room/project/settings titles |
| `Type.Title.lg`   | DM Sans **Bold** | 22pt | -0.8 | — | **H2** — card headlines (NextUpCard, ActiveProjectCard) |
| `Type.Title.md`   | DM Sans Medium | 17pt | 0 | — | **H3** — sub-section titles |
| `Type.Title.sm`   | DM Sans **Bold** | 14pt | 0 | — | **H4** / compact item title (MaintenanceRow titles) |
| `Type.Menu.lg`    | DM Sans **Bold** | 13pt | 0 | — | Top-tab nav labels (TopNav tabs) — mixed case |
| `Type.Body.md`    | DM Sans Regular | 14pt | 0 | — | Paragraph + list-row copy |
| `Type.Label.lg`   | DM Mono Medium | 14pt | +0.8 | UPPER | `DsButton.large` labels |
| `Type.Label.md`   | DM Mono Medium | 13pt | +0.2 | UPPER | `DsButton.small` labels |
| `Type.Label.sm`   | DM Mono Medium | 12pt | +0.9 | UPPER | `DsButton.micro`, `DsKeyButton` tile labels, eyebrows |
| `Type.Label.xs`   | DM Mono Medium | 10pt | +0.8 | UPPER | NavRail chips, `DsLabeledDivider` labels — MUST use `TextToken.primary` foreground |
| `Type.Data.lg`    | DM Mono Regular | 13pt | 0 | — | CalendarMonth date numbers |
| `Type.Data.md`    | DM Sans **Bold** | 13pt | 0 | — | `DsBadge` content, ActiveProjectCard progress % — only Bold weight in `Data` |
| `Type.Data.sm`    | DM Mono Regular | 12pt | 0 | — | Timestamps, maintenance metadata, captions |
| `Type.Data.xs`    | DM Mono Regular | 9pt  | 0 | — | Smallest data text |

#### Tracking tokens (pts, applied via `.tracking`)

| Token | Value | Use |
|---|---|---|
| `Tracking.none`   | 0     | Default |
| `Tracking.snug`   | +0.2  | Small mono labels |
| `Tracking.micro`  | +0.9  | Micro mono labels |
| `Tracking.label`  | +0.8  | Large mono labels |
| `Tracking.wide`   | +1.4  | Eyebrows |
| `Tracking.wider`  | +1.8  | Section header eyebrows |
| `Tracking.tight`  | -0.6  | Large display only |

#### Line-height ratios

| Token | × | Use |
|---|---|---|
| `LineHeight.hero`    | 1.06 | Display |
| `LineHeight.title`   | 1.08 | Titles |
| `LineHeight.compact` | 1.12 | Compact UI |
| `LineHeight.utility` | 1.20 | Labels, data |
| `LineHeight.body`    | 1.65 | Body prose |

**Reuse rule:** every typographic surface MUST map to one of the 15 styles. Apply via `.typeStyle(_:)`. Never `Font.system(size:)` or raw `Font.custom()` in code above the Primitive layer.

Full context: `specs/foundations.md § Typography` + `specs/base-tokens.md § Typography` + `specs/semantic-tokens.md § Typography`.

### Spacing

#### Base ladder (13 stops, 4-base)

`4 · 8 · 12 · 16 · 20 · 24 · 32 · 36 · 40 · 44 · 48 · 64 · 80` pt

Accessed as `SpacingToken.s4 … s80`. Primitives never reach here directly.

#### Semantic intents

| Token | Maps to | Use |
|---|---|---|
| `Space.hairline`         | `s4`  | Tiny gaps, divider padding |
| `Space.tight`            | `s8`  | Icon-to-label, inside chips |
| `Space.snug`             | `s12` | Header→list, section→content, hero icon→content |
| `Space.bodyPadding`      | `s16` | Default horizontal padding |
| `Space.cardPadding`      | `s20` | Inside cards |
| `Space.safeGutter`       | `s24` | Screen edge from safe area |
| `Space.sectionGap`       | `s32` | Between sections |
| `Space.pageInset`        | `s36` | Additive page-chrome top breathing (Screen-layer) |
| `Space.blockSeparator`   | `s48` | Major content blocks |
| `Space.tapTarget`        | `s44` | iOS min tap height |
| `Space.buttonPaddingLg`        | `s20` | Large button horizontal padding (secondary / ghost / urgent) |
| `Space.buttonPaddingPrimaryLg` | `s24` | **Primary** at large gets +4pt L/R extra |
| `Space.buttonPaddingSm`        | `s12` | Small + micro button horizontal padding |
| `Space.buttonHeightLg`         | `s40` | Large button visible height |
| `Space.buttonHeightSm`         | `s32` | Small button visible height |
| `Space.buttonHeightMicro`      | `s24` | Micro button visible height |
| `Space.avatarRegular`          | `s32` | `DsAvatar` default diameter |

**Snap-to-ladder rule.** No in-between values. When a tweak is needed, move to the nearest existing stop — never propose a new one mid-scale. 17→20, 14→10, 18→20. New stops require explicit sign-off.

**Micro-values inside primitives:** sub-grid numbers (1, 1.5, 2pt) are valid for primitive-internal construction — badge rings, hairline strokes. Never valid in layout (`.padding(2)` between cards is rejected).

Full context: `specs/foundations.md § Spacing` + `specs/base-tokens.md § Spacing` + `specs/semantic-tokens.md § Spacing`.

### Radii

| Token | Value | Use |
|---|---|---|
| `Radius.sm`    | 8pt  | Small surfaces, badges |
| `Radius.md`    | 12pt | Default card / button |
| `Radius.lg`    | 16pt | Larger surfaces |
| `Radius.sheet` | 18pt | ActionSheet, status stage |
| `Radius.hero`  | 22pt | Hero panels |
| `Radius.pill`  | 999  | Pills, buttons, search |

Base values: `RadiusToken.r6 · r8 · r10 · r12 · r14 · r16 · r18 · r22 · rPill`. Use the smallest stop that fits the corner.

Full context: `specs/base-tokens.md § Radius` + `specs/semantic-tokens.md § Radius`.

### Border (orthogonal: width × color)

#### Widths

| Token | Value | Use |
|---|---|---|
| `Border.Width.normal` | 1pt | Default |
| `Border.Width.strong` | 2pt | Severity, emphasis |

#### Colors

| Token | Maps to | Use |
|---|---|---|
| `Border.Color.subtle` | `ink20` | Soft separators, secondary affordances |
| `Border.Color.muted`  | `ink40` | Mid-weight separators |
| `Border.Color.normal` | `ink`   | Default affordance |
| `Border.Color.strong` | `signal` | Severity / urgent |

Six pairings total. No pre-named combos. Callers pick independently.

#### Special

| Token | Value | Use |
|---|---|---|
| `BorderToken.dashLength` | 3pt | `DsDivider` dash length |
| `BorderToken.dashGap`    | 4pt | `DsDivider` dash gap |

Dashed strokes reserved exclusively for `DsDivider`. Audit-enforced.

Full context: `specs/base-tokens.md § Border` + `specs/semantic-tokens.md § Border`.

### Shadows

Single subtle elevation. paprLCD aesthetic is flat — depth via borders, not shadows.

| Token | Color | Radius | x | y |
|---|---|---|---|---|
| `ShadowToken.subtle` | `ink @ 8%` | 0 | 6 | 8 |

No blur — offset only. Stamped/embossed feel. Use sparingly for elements that physically stand off the page (status stages, popovers). Never on cards in lists.

Full context: `specs/base-tokens.md § Shadow` + `specs/foundations.md § Elevation`.

### Motion

#### Base durations + easings

| Token | Value |
|---|---|
| `MotionToken.dFast`   | 0.120s |
| `MotionToken.dBase`   | 0.300s |
| `MotionToken.dSlow`   | 0.400s |
| `MotionToken.dSlower` | 0.600s |
| `MotionToken.easeOut`   | `cubic-bezier(0.20, 0.80, 0.20, 1.00)` |
| `MotionToken.easeIn`    | `cubic-bezier(0.60, 0.04, 0.98, 0.34)` |
| `MotionToken.easeInOut` | `cubic-bezier(0.60, 0.00, 0.40, 1.00)` |

#### Semantic motion vocabulary

| Token | Curve + duration | Use |
|---|---|---|
| `Motion.quick`      | easeOut 120ms | Toggle flip, press release |
| `Motion.standard`   | easeOut 300ms | Sheet present, default UI transition |
| `Motion.gentle`     | easeInOut 400ms | Severity escalation, status reveal |
| `Motion.expressive` | easeOut 600ms | Success confirmation, attention loop |

**Rules:**
- No springs by default — paprLCD restraint doesn't tolerate bounce.
- SF Symbol effects first (`.symbolEffect(.bounce/.pulse)`) over hand-animation.
- Respect Reduce Motion — when on, collapse expressive/gentle to quick; disable repeating loops.

Full context: `specs/base-tokens.md § Motion` + `specs/foundations.md § Motion` + `specs/semantic-tokens.md § Motion`.

### Inventory (SpaceCard tile geometry)

Component-internal geometry for the dashboard's `SpaceCard` (Rooms / Outdoor / Systems rails). Doesn't fit the general 4-grid — kept in its own category.

| Token | Value (pt) | Use |
|---|---|---|
| `Inventory.tileHeight`        | 60  | Visible tile height (uniform across rect + pill) |
| `Inventory.tileMinWidth`      | 100 | Tile min-width |
| `Inventory.railColumnGap`     | 8   | Between tiles horizontally |
| `Inventory.railRowGap`        | 8   | Between Z-pattern rows |
| `Inventory.badgeSize`         | 20  | Badge min diameter |
| `Inventory.badgeSizeSmall`    | 17  | Cramped contexts |
| `Inventory.badgePaddingH`     | 6   | Inner horizontal padding |
| `Inventory.badgeOverhangRect` | 8   | Offset from rect tile top-right |
| `Inventory.badgeOverhangPill` | 2   | Tighter offset for pill tiles |
| `Inventory.badgeBorderWidth`  | 2   | Paper ring (matches iOS-native badge ring) |

Full context: `specs/base-tokens.md § Inventory` + `specs/semantic-tokens.md § Inventory`.

---

## 5. Component status roster

Status legend: **✅ Locked** (signed off, safe to compose with) · **🟡 Implemented** (pending vet, may iterate) · **✗ Removed** (retained for history).

### Primitives (`Ds*` prefix, atomic SwiftUI views)

| Name | Status | Purpose | Spec |
|---|---|---|---|
| `DsButton` | ✅ 2026-05-22 | Action affordance. 4 variants × 3 sizes × pill/rounded shape. `Press.soften` strategy | `specs/primitives/ds-button.md` |
| `DsKeyButton` | ✅ 2026-05-23 | Severity-bearing tile (rooms/outdoor/systems). Carries `healthy/attention/urgent`. `Press.invert` strategy | `specs/primitives/ds-key-button.md` |
| `DsBadge` | ✅ 2026-05-23 | Numeric/symbol counter (capsule, paper ring). 2 sizes | `specs/primitives/ds-badge.md` |
| `DsAvatar` | ✅ 2026-05-25 | Letter avatar circle | `specs/primitives/ds-avatar.md` |
| `DsStatusDot` | ✅ 2026-05-24 | Severity dot (healthy/attention/urgent) | `specs/primitives/ds-status-dot.md` |
| `DsProgressBar` | ✅ 2026-05-24 | Linear progress fill | `specs/primitives/ds-progress-bar.md` |
| `DsSearchField` | ✅ 2026-05-24 | Pill input with magnifier icon | `specs/primitives/ds-search-field.md` |
| `DsDivider` | ✅ 2026-05-22 | Solid or dashed line, 2 orientations. Dashed reserved exclusively for this primitive | `specs/primitives/ds-divider.md` |
| `DsLabeledDivider` | ✅ 2026-05-24 | Section header: dashed line / centered label / dashed line | `specs/primitives/ds-labeled-divider.md` |
| `DsTabItem` | ✅ 2026-05-27 | Top-tab nav pill (composes `DsButton`) | `specs/primitives/ds-tab-item.md` |
| `SignalButton` | ✅ 2026-05-25 | Specialized one-off (urgent CTA variant). May dissolve into `DsButton` later | `specs/primitives/signal-button.md` |
| `DsWeatherChip` | 🟡 2026-05-24 | Dummy text-only summary — reserves slot for a real weather widget. Not visual final | `specs/primitives/ds-weather-chip.md` |

### Components (no prefix, compose Primitives)

| Name | Status | Purpose | Spec |
|---|---|---|---|
| `NextUpCard` | ✅ 2026-05-27 | Hero card — next urgent task with 48pt SF Symbol indicator, urgent variant carries signal spine + border | `specs/components/next-up-card.md` |
| `ActiveProjectCard` | ✅ 2026-05-27 | Hero card — current project carousel mirror of NextUpCard anatomy. 48pt SF Symbol + progress bar | `specs/components/active-project-card.md` |
| `SpaceCard` | ✅ 2026-05-27 | Rooms / Outdoor / Systems rails. Composes `DsKeyButton` tiles + `DsLabeledDivider` section headers | `specs/components/space-card.md` |
| `CalendarMonth` | ✅ 2026-05-27 | Month grid (day numbers in DM Mono, today pill, severity dots, dashed-divider legend) | `specs/components/calendar-month.md` |
| `MaintenanceList` | ✅ 2026-05-27 | Pinned-header card. TASKS eyebrow + VIEW ALL action, scrollable body of `MaintenanceRow`s | `specs/components/maintenance-list.md` |
| `MaintenanceRow` | ✅ 2026-05-25 | List row: avatar/icon + title + meta + chevron | `specs/components/maintenance-row.md` |
| `TopNav` | ✅ 2026-05-27 | Dashboard chrome — tabs (HOME/SPACES/FILE CABINET/LEDGER) + theme menu + search + +ADD + avatar | `specs/components/top-nav.md` |
| `TopBar` | ✗ Removed 2026-05-27 | Was sidebar-dashboard chrome. Replaced by `TopNav` when the top-tab layout won the A/B vet | `specs/components/top-bar.md` |
| `NavRail` | ✗ Removed 2026-05-27 | Was sidebar-dashboard's vertical 48pt rail. Replaced by `TopNav` + `DsTabItem` | `specs/components/nav-rail.md` |

### Patterns

| Name | Status | Purpose | Spec |
|---|---|---|---|
| `popup` | (sparse) | Popover / overlay pattern — early draft | `specs/patterns/popup.md` |

### Screens

| Name | Status | Purpose | Spec |
|---|---|---|---|
| `DashboardScreen` | ✅ Locked | Home tab — 2-column iPad layout: COL 1 (NextUpCard + ActiveProjectCard + SpaceCard), COL 2 (CalendarMonth + MaintenanceList with pinned header) | `specs/screens/dashboard.md` |

---

## 6. What we'd like Claude Designer to produce

Two deliverables, in order:

### a. Mirror pass (parity baseline)

- **`tokens.css`** — every value in § 4 above expressed as CSS custom properties. Use kebab-case (`--space-body-padding`, `--type-label-lg-size`, `--bg-page`, `--action-fill-primary`, …). Scope dark-mode overrides under `[data-theme="dark"]`. The CSS is the surface; the canonical spec is the contract.
- **One HTML file per locked Primitive** under `components/<name>.html`. Render every variant × size × state visible on a single page (kitchen-sink-per-component). For `DsButton` that's 4 variants × 3 sizes × 4 states (rest/disabled/pressed/iconOnly). For `DsKeyButton` it's 3 severities × 2 shapes × 2 states (rest/pressed). Use the values from § 4 — no improvisation.
- **`tokens.html`** — visual swatches for colors, type ramp, spacing ruler, radii samples, shadow stamp, motion strip. Helps us proof-check the CSS.

### b. Kitchen-sink + Dashboard parity mock

- **`kitchen-sink.html`** — every locked Primitive + Component on one page, grouped by layer. Single source of "what does the system look like."
- **`dashboard.html`** — full-page recreation of our locked `DashboardScreen` at iPad Pro 13" landscape (1366×1024 viewport, but compose at logical 1133×744 if iOS scale is easier to think about). Use only documented Primitives + Components — no improvisation. This is the visual cross-check that our SwiftUI renders parity with the HTML mock.

### Future asks (after parity is established)

Once a→b is in place, the loop opens: "design a Settings screen / Spaces detail / Tasks detail using our system." You compose mocks from the documented surfaces; we translate back to SwiftUI; the canonical specs grow in lockstep. You don't invent visual language at the Primitive layer — that's our discipline. New Primitives only enter the system through the Prime Directive audit (`CLAUDE.md → Prime Directive`).

---

## 7. Open questions / known drift

- **Patterns layer is sparse.** Only `popup.md` exists. As you mock screens, you'll surface natural patterns (form rows, list groupings, headers). Flag them so we promote properly rather than reinventing per screen.
- **One Screen locked (Dashboard).** Settings / Spaces detail / Tasks detail / File Cabinet / Ledger are TBD — fair game for you to propose visual treatment, but compose from existing Primitives + Components first; surface gaps before reaching for new ones.
- **`DsWeatherChip` is a dummy** (text-only) reserving the slot for a real weather widget. Don't take its current visual as final.
- **Dynamic Type not yet implemented** end-to-end. Type roles use `relativeTo:` but the runtime experience hasn't been vet-tested. Out of scope for the initial parity pass.
- **No logo / brand SVG.** Wordmark "houseKipper" in `Type.Display.lg` as placeholder. Don't fabricate a logo.
- **Light-mode is the default.** Dark mode is supported but most iteration has been in light.
- **iPhone layouts.** Dashboard is locked for iPad landscape. iPhone vetting is a separate workstream — don't try to derive iPhone variants from the iPad spec without checking with us.

Recent decision history lives in `CHANGELOG.md`. Deferred work in `BACKLOG.md`.

---

## 8. Setup for Claude Designer

### Repo URL

This mirror repo: **`<PUBLIC_MIRROR_URL>`** *(filled in by Luis after the mirror is created)*

The mirror is a public subtree of the private parent repo (`ThinnnkTank/houseKipper`). It contains only `design-sys/` — no Swift, no app code. Cross-links inside `design-sys/` resolve fine; the small number of links that point OUT of the folder (into `houseKipper/*.swift` or repo-root files like `CLAUDE.md`) will 404 on the mirror. Expected — those are context for the SwiftUI side only.

### Anchor folder

You're reading from the root of this repo. The structure is:

```
.
├── HANDOFF.md                  ← this file
├── README.md                   ← philosophy + 6-layer model
├── ARCHITECTURE.md             ← rationale
├── CHANGELOG.md                ← dated decision log
├── BACKLOG.md                  ← deferred work
├── audit.sh                    ← layer-violation linter (Swift-side, ignore for HTML)
├── fonts/
│   ├── DM_Sans/                ← TTF files (SIL OFL)
│   └── DM_Mono/                ← TTF files (SIL OFL)
├── specs/
│   ├── foundations.md          ← the *why*
│   ├── base-tokens.md          ← raw values
│   ├── semantic-tokens.md      ← intent aliases
│   ├── primitives/             ← 12 Primitive specs
│   ├── components/             ← 9 Component specs (7 active + 2 ✗ Removed)
│   ├── patterns/               ← 1 Pattern spec
│   └── screens/                ← 1 Screen spec (Dashboard)
└── _legacy/                    ← archived paprLCD style sheets, reference only
```

### Recommended read order

1. `HANDOFF.md` *(you are here)*
2. `README.md` *(20 lines, 6-layer model)*
3. `specs/foundations.md` *(the philosophy — why we made these choices)*
4. `specs/base-tokens.md` *(raw values; § 4 above is the flat summary)*
5. `specs/semantic-tokens.md` *(intent aliases; § 4 above includes these too)*
6. Pick a Primitive and read its spec end-to-end — `specs/primitives/ds-button.md` is a good representative example.

### A note on `CLAUDE.md`

The repo-root `CLAUDE.md` (in the parent SwiftUI repo, not the mirror) carries our working agreement and Prime Directive audit. **That's iOS-side discipline — it doesn't bind you.** You're free to compose, propose, and explore; we'll Prime-Directive-audit anything that lands back on the Swift side. The audit is a one-way gate from your mocks → our code, not a constraint on your authoring.

---

When you're ready to start the mirror pass, ping back and we'll calibrate on the first 2–3 Primitives before scaling out.
