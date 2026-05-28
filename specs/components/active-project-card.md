# ActiveProjectCard — Component

**Layer:** Component
**Status:** ✅ Locked (2026-05-27 — restructured to mirror NextUpCard anatomy)
**Implementation:** `houseKipper/houseKipper/Components/ActiveProjectCard.swift`
**Reference:** dashboard mock + paprLCD canonical Active Project surface

## 2026-05-27 restructure — anatomy mirrors NextUpCard

Significant API + visual restructure to make the two hero cards true visual peers:
- **Removed `nextStep:` parameter** + "NEXT · INSTALL WALL ANCHORS" meta line.
- **Removed PHOTO thumbnail placeholder** → 48pt `hammer.fill` SF Symbol icon, same treatment as NextUpCard's urgent indicator (`.padding(.horizontal, Space.snug)` for 12pt L/R breathing).
- **Anatomy: VStack(spacing: 0) of [header rail (44pt tapTarget min, contains eyebrow + spacer + dots + spacer + arrows) ; content row (icon + content VStack)].** Eyebrow uses `.font(Type.Label.lg.font)` (matches DsSearchField + NextUp + MaintenanceList unified treatment). Arrows are `DsButton(.secondary, .micro, iconOnly)`.
- **Outer padding asymmetric:** `top: hairline (4)` / `horizontal: bodyPadding (16)` / `bottom: cardPadding (20)`.
- **Border:** `Border.Color.muted` (ink40) 1pt — matches NextUp's non-urgent default.
- HomeTab applies `.frame(height: 164)` (same heroHeight as NextUp).

Call sites updated: `DashboardScreen.HomeTab.leftColumn` + `_Swatches.activeProjectCardSection`.

## Overview

Dashboard "what you're working on" card. Sits below `NextUpCard` in the left column. Eyebrow + carousel position dots + nav arrows on top; thumbnail + title + next-step + progress bar + started/est dates inside.

ActiveProjectCard is a Component — composes `DsProgressBar` and `DsButton`. Owns no token values; chrome routes through SemanticTokens. Same outer chrome family as `NextUpCard.upcoming` (border with `Border.Color.subtle`, transparent fill, `Radius.md`) — the cards visually relate but carry different content roles.

**When to use:** dashboard's "active project" surface. Any "in-flight project carousel" use later.
**When NOT to use:** task hero (use `NextUpCard.urgent`). Project list rows (different Component, TBD).

## Anatomy

```
ActiveProjectCard (Border.Color.subtle outline, transparent fill, Radius.md)
└── VStack(spacing: Space.snug)
    ├── Header
    │   └── HStack(spacing: Space.bodyPadding)
    │       ├── Text("ACTIVE PROJECT")              Type.Label.xs · ink
    │       ├── Spacer
    │       ├── carouselDots                        HStack(spacing: hairline) of 6pt circles
    │       └── HStack(spacing: Space.tight)
    │           ├── DsButton(.primary, .micro, iconOnly: "arrow.left",  action: onPrev)
    │           └── DsButton(.primary, .micro, iconOnly: "arrow.right", action: onNext)
    └── Content
        └── HStack(alignment: .top, spacing: Space.bodyPadding)
            ├── Thumbnail (100×100, Radius.sm, paper2 fill, ink20 border, SF Symbol placeholder + PHOTO pill)
            └── VStack(spacing: Space.snug)
                ├── Title block
                │   ├── Text(title)                 Type.Title.lg · ink
                │   └── HStack: NEXT · {nextStep}   Type.Label.xs · muted + ink
                ├── Progress block
                │   ├── HStack: "PROGRESS" + Spacer + "{n}%"   Label.xs muted · Data.md ink
                │   └── DsProgressBar(progress)
                └── Date footer
                    └── HStack: "STARTED {date}" + Spacer + "EST. {date}"   Type.Label.xs muted
.padding(Space.cardPadding)
```

### Primitive-internal micro-values

| Constant | Value | Use |
|---|---|---|
| `thumbnailSize`    | 80pt  | Thumbnail square edge length (dropped 100→80pt Luis 2026-05-25 so the card fits the dashboard's 144pt fixed-height row slot without crowding title + progress + dates) |
| `carouselDotSize`  | 6pt   | Carousel position dot diameter (matches `DsStatusDot.small` after iter 8 revert — visual rhythm consistent across calendar + project carousel) |

Both kept inside `ActiveProjectCard.swift` — not promoted to BaseTokens, not reused elsewhere yet.

## Public API

```swift
struct ActiveProjectCard: View {
    let title: String          // "Garage shelving build"
    let nextStep: String       // "INSTALL WALL ANCHORS"
    let progress: Double       // 0.0 – 1.0
    let startedDate: String    // "MAR 12"
    let estDate: String        // "MAY 15"
    let pageCount: Int         // 3 (carousel total)
    let currentPage: Int       // 0-indexed
    var onPrev: () -> Void = {}
    var onNext: () -> Void = {}
}
```

v0 accepts flat strings + a `Double` for progress. When the project model lands, this card consumes it directly at the Screen.

## Composition

ActiveProjectCard composes:
- `DsProgressBar` (Primitive, ✅ locked) — progress bar
- `DsButton` (Primitive, ✅ locked) — prev/next arrows, both `.primary, .micro` icon-only

It does NOT compose `DsStatusDot` for the carousel dots — those are simple position indicators (filled = current, muted = other), not severity-driven. Drawing inline `Circle().fill(...)` with `frame(width:carouselDotSize, height:carouselDotSize)` is the appropriate primitive interior.

The thumbnail is a placeholder block — when real project images land, swap the SF Symbol + paper2 fill for an `Image(...)`.

## Rules

- **All nav buttons stay `DsButton.primary.micro`.** Matches the CalendarMonth nav cluster — both surfaces in the dashboard use the same scale for the same interaction pattern.
- **Carousel dots are inline `Circle`, not DsStatusDot.** Different semantic (position, not severity). 6pt to match the calendar's dot rhythm visually, but conceptually distinct.
- **Card chrome matches NextUpCard.upcoming**: `Border.Color.subtle`, transparent fill, `Radius.md`, `Border.Width.normal`. The cards visually relate; intentional.
- **PHOTO pill in the thumbnail uses `Type.Label.xs` inverted** (paper on ink Capsule). When a real image lands, the pill stays as a metadata marker.

## SemanticTokens used

`Type.Title.lg` (title) · `Type.Label.xs` (eyebrow, NEXT line, PROGRESS label, dates, PHOTO pill) · `Type.Data.md` (progress percentage — sans bold 13pt) · `TextToken.primary` / `.muted` · `BackgroundToken.primary` / `.secondary` · `Border.Color.subtle` / `.muted` · `Border.Width.normal` · `Radius.md` / `.sm` · `Space.cardPadding` / `.bodyPadding` / `.snug` / `.tight` / `.hairline`

No new tokens introduced.

## Cross-references

- Uses: `DsProgressBar`, `DsButton`, `Type.*`, `TextToken`, `BackgroundToken`, `Border`, `Radius`, `Space`
- Used by: `DashboardScreen` (TBD) — left column, below `NextUpCard`
- Chrome peer: `NextUpCard.upcoming` (same outline family)

## Decisions log (this spec)

- **Initial scaffold (2026-05-25):** Built same day as the sizing pass. Composes existing Primitives; thumbnail is placeholder for v0 (SF Symbol + PHOTO pill). Arrows shipped at `.small` then immediately downsized to `.micro` in the same session (see below) — single iteration on the dashboard mock vet.
- **Arrows: `.small` → `.micro`** (Luis 2026-05-25): part of the CalendarMonth sizing pass. Calendar's nav arrows moved to micro for spec alignment; ActiveProjectCard's arrows follow for visual consistency across the dashboard's nav clusters.
- **Carousel dots: inline Circle, not DsStatusDot** (2026-05-25): considered reusing DsStatusDot for the page-position dots, but that Primitive's contract is severity-driven (healthy / attention / urgent). Carousel position is a different semantic (which page is current). Inline Circle with `TextToken.primary` (current) vs `TextToken.muted` (other) is the right composition primitive here.
- **Real carousel logic (deferred BACKLOG):** v0 accepts `pageCount` + `currentPage` and renders the dots, but the prev/next callbacks are caller-driven; no internal state. Real swiping + index management lands when the Screen wires up.
- **Real image (deferred BACKLOG):** placeholder thumbnail with SF Symbol; swap to `Image(...)` when the project model lands.
- **Internal compression for 144pt row slot** (Luis 2026-05-25 grid pass): outer padding `Space.cardPadding` (20pt) → `Space.bodyPadding` (16pt); thumbnail 100 → 80pt. Both changes preserve every existing element visible at the dashboard's mandated 144pt row height. No content cut.
