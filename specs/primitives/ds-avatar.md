# DsAvatar — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-24) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsAvatar.swift`

## Overview

Letter-in-circle identity marker. Two styles:
- **`.filled`** (default) — ink-filled circle, paper letter. Grounded identity treatment; used by NavRail's bottom user slot.
- **`.outline`** — ink hairline ring, ink letter, transparent fill. Used by MaintenanceRow's assignee column, where the surrounding row chrome is paper and the avatar is a quieter accent.

Both styles render a single capitalized letter at 32pt diameter. Apple ID profile photo, contact photo, SF Symbol fallback, and multi-initial variants are deferred — see `BACKLOG.md` → *DsAvatar enhancement*.

**Color rule (Luis 2026-05-23):** ink + paper only. Identity should feel grounded; deliberately does NOT use `signal` — that color is reserved for severity and would conflict semantically.

**When to use:** representing a specific person at a small surface.
**When NOT to use:** generic "user" icons (use `person.circle` SF Symbol). Severity indicators (use `DsBadge`). Status dots (use `DsStatusDot`).

## Anatomy

```
DsAvatar(style: .filled)                       NavRail bottom user slot
└── Text(initial.uppercased)
    ├── .typeStyle(Type.Body.md)                       14pt DM Sans Regular
    ├── .foregroundStyle(BackgroundToken.primary)      paper letter
    └── .frame(32×32)
        ↳ .background(Circle().fill(TextToken.primary))            ink fill

DsAvatar(style: .outline)                      MaintenanceRow assignee
└── Text(initial.uppercased)
    ├── .typeStyle(Type.Body.md)
    ├── .foregroundStyle(TextToken.primary)            ink letter
    └── .frame(32×32)
        ↳ .background(Circle().strokeBorder(TextToken.primary,     ink ring
                                            lineWidth: Border.Width.normal))   transparent fill
```

Letter is auto-capitalized inside the Primitive — caller passes any case, view always renders uppercase. Prevents call-site inconsistency.

## Public API

```swift
struct DsAvatar: View {
    enum Style { case filled, outline }

    let initial: Character
    var style: Style = .filled
}
```

Single size for now. A `Size` enum can be added later when a smaller variant surfaces. Per Luis 2026-05-23 — defer until needed.

**Caller mapping:**

```swift
DsAvatar(initial: "L")                       // user (Luis)
DsAvatar(initial: Character(name.prefix(1))) // derived from a User model at the Component layer
```

Initial derivation logic belongs at the Component layer (where the User / Assignee model lives), not inside the Primitive. The Primitive only knows how to render a single character.

## States

DsAvatar has no interactive states (no press, no disabled). It's an identity marker, not an affordance.

## SemanticTokens used

`TextToken.primary` · `BackgroundToken.primary` · `Border.Width.normal` (outline ring) · `Type.Body.md` · `Space.avatarRegular`

No new tokens. 32pt diameter via `Space.avatarRegular`.

## Example

```swift
// Nav rail bottom slot — filled (default)
DsAvatar(initial: "L")
    .accessibilityLabel("Luis")

// MaintenanceRow assignee — outline
DsAvatar(initial: assignee, style: .outline)
```

## Cross-references

- Uses: `TextToken`, `BackgroundToken`, `Font`
- Used by: `NavRail` Component (bottom slot) · `MaintenanceRow` Component (assignee, TBD)
- Backlog: Apple ID photo / contact photo / SF Symbol fallback / multi-initial — see `BACKLOG.md`

## Decisions log (this spec)

- **Letter-only, no photo, no symbol** (Luis 2026-05-23): keep minimal; richer modes are backlog.
- **Caller passes `Character` directly** (Luis 2026-05-23): no name-to-initial derivation inside the Primitive. "Dummy for now, this control will evolve."
- **One size for now** (Luis 2026-05-23): defer the Size enum until MaintenanceRow needs a smaller variant.
- **Ink fill + paper letter** (Luis 2026-05-23, option A): grounded identity. Mirrors press-invert palette. Reserves `signal` for severity.
- **`.outline` variant added** (Luis 2026-05-24, reference image for MaintenanceList): the maintenance row's assignee column needs a quieter avatar treatment so the row body (title + location + date) reads first. Ink ring + ink letter on transparent fill keeps the identity legible without competing with the title's visual weight. Existing NavRail use unchanged — `.filled` is still the default.
