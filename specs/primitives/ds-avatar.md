# DsAvatar — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsAvatar.swift`

## Overview

Letter-in-circle identity marker. Used wherever a person needs to be represented at a small surface: nav rail user slot, maintenance row assignee (TBD), future invitee chips.

**Minimal-first.** This first cut renders a single capitalized letter on an ink-filled circle. Apple ID profile photo, contact photo, SF Symbol fallback, and multi-initial variants are deferred — see `BACKLOG.md` → *DsAvatar enhancement*.

**Color rule (Luis 2026-05-23):** ink fill + paper letter. Identity should feel grounded; mirrors the press-invert palette. Avatar deliberately does NOT use `signal` — that color is reserved for severity and would conflict semantically.

**When to use:** representing a specific person at a small surface.
**When NOT to use:** generic "user" icons (use `person.circle` SF Symbol). Severity indicators (use `DsBadge`). Status dots (use `DsStatusDot`, TBD).

## Anatomy

```
DsAvatar
└── Text(initial)                              capitalized
    ├── .font(.hkBody)                         14pt DM Sans Regular
    ├── .foregroundStyle(BackgroundToken.primary)   paper
    └── .frame(width/height: 32pt)
        ↳ .background(Circle().fill(TextToken.primary))   ink
```

Letter is auto-capitalized inside the Primitive — caller passes any case, view always renders uppercase. Prevents call-site inconsistency.

## Public API

```swift
struct DsAvatar: View {
    let initial: Character
}
```

Single size for now. A `Size` enum can be added later (e.g. `.regular` / `.small`) when MaintenanceRow surfaces a smaller variant. Per Luis 2026-05-23 — defer until needed.

**Caller mapping:**

```swift
DsAvatar(initial: "L")                       // user (Luis)
DsAvatar(initial: Character(name.prefix(1))) // derived from a User model at the Component layer
```

Initial derivation logic belongs at the Component layer (where the User / Assignee model lives), not inside the Primitive. The Primitive only knows how to render a single character.

## States

DsAvatar has no interactive states (no press, no disabled). It's an identity marker, not an affordance.

## SemanticTokens used

`TextToken.primary` (ink fill) · `BackgroundToken.primary` (paper letter) · `Font.hkBody`

No new tokens. 32pt diameter snaps to `SpacingToken.s32` (existing stop, no new value introduced).

## Example

```swift
// Nav rail bottom slot
DsAvatar(initial: "L")
    .accessibilityLabel("Luis")
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
