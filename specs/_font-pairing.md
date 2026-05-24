# Type Lab (FontPairing) — Dev tool

**Layer:** Dev tool (audit-exempt by `_` prefix · `#if DEBUG`-gated)
**Status:** 🟢 v0 shipped (2026-05-24) — pending iPad vetting
**Implementation:** `houseKipper/houseKipper/DesignSystem/_FontPairing.swift`
**UI:** `_Swatches.swift` → **Type Lab** segment (4th tab)

## Overview

A safe sandbox for auditioning alternative typeface pairings against the live 12-style scale. Zero impact on the real DS — `Type.swift`, `TypographyTokens.swift`, asset catalog, every Primitive and Component on the other tabs stay exactly as they are. The lab renders samples in *parallel* to the real Type enum so any pairing can be evaluated against the same size / weight / tracking / case spec values that ship today.

**Why it exists:** locking on DM Sans + DM Mono was right for round one (Luis 2026-05-22), but type is the most-debated layer in any DS. Before extending the typography work further, we want a one-click way to compare alternatives without risking accidental drift into the real renderer.

## Activation

Pick the **Type Lab** segment in the swatches. Loud "EXPLORATION — not wired to DS" warning banner at the top so the tab can never be mistaken for live state. A `CURRENT DS` chip marks whichever pairing is currently active in `Type.swift` (DM at v0).

## Public surface

```swift
struct FontPairing: Identifiable, Hashable {
    let id: String
    let name: String
    let display: String   // PostScript name for display/body face — "" → system
    let mono: String      // PostScript name for mono/utility face — "" → system

    func font(size: CGFloat, weight: Font.Weight, isDisplay: Bool) -> Font
}
```

Catalog ships 6 pairings — DM (current), SF Pro/SF Mono, Avenir Next/Menlo, Futura/Courier New, Georgia/Menlo, Gill Sans/Courier New. All faces are pre-registered on iOS; no font files added.

A parallel `TypeLabRole` struct mirrors each entry in the live `Type` enum with raw size / weight / tracking / case / face-axis values, so any `FontPairing` can render the full 12-style scale.

## Architecture decisions

1. **`_` prefix + top-level `DesignSystem/` location** (not the inbox-planned `SemanticTokens/FontPairing.swift`). Matches the existing dev-tool cluster (`_Swatches.swift`, `_Inspector.swift`). The `_` prefix is the established audit-exempt-by-convention rule (see `foundations.md → Conventions`). When the lab promotes (see Promotion path below), the file relocates to `SemanticTokens/FontPairing.swift` and drops the `_`.
2. **`#if DEBUG` gate** strips the whole file from release builds. No risk of the lab leaking into shipped code paths.
3. **`TypeLabRole` is parallel to `Type`, not derived from it.** Intentional duplication — the lab needs raw values to feed into `FontPairing.font(...)`, but the real `Type` enum should keep baking face + size + weight + tracking + case into a single `TypeStyle` for drift safety (per the foundations rule). Bridging the two would require either exposing internals of `TypeStyle` or coupling the lab to the live renderer; neither is worth it for a dev tool. The duplication collapses on promotion.

## Promotion path (when a pairing wins)

1. Drop the `#if DEBUG` gate on `_FontPairing.swift`.
2. Move file to `SemanticTokens/FontPairing.swift` (drop `_` prefix).
3. Store selection in `UserDefaults` (e.g. `@AppStorage("activeFontPairing")`).
4. In `Type.swift`, replace the hardcoded `Face.sansMedium` / `Face.monoMedium` constants with values resolved from the active pairing.
5. Delete `TypeLabRole` and the lab's per-role rendering; the live `Type` enum becomes the single source of truth, and the lab becomes "swap the active pairing globally" rather than a parallel renderer.

No rework needed — the struct is designed for it.

## What v0 does NOT do

- **Does not mutate `Type.swift`** — no Picker in the lab can change live rendering.
- **Does not register new fonts** — only auditions faces already on iOS.
- **Does not persist selection** — picking a pairing affects the current view only; restarting resets to DM.
- **Does not export comparison side-by-side** — single pairing at a time. (Easy v1 if it earns the time.)

## Rules

- **Never reference `FontPairing` from `Type.swift` or any Primitive/Component.** The whole point is that it stays sandboxed.
- **When adding a new role to the live `Type` enum, also add a `TypeLabRole` entry** so the lab covers the full scale. Both edits in the same commit (per spec discipline).
- **Pairings catalog is a flat array — pick faces shipped on iOS by default**, no new font files for exploration purposes. If a candidate face needs registration (e.g. a Google Font we don't yet bundle), that's a decision worth surfacing.

## Cross-references

- Lives next to: `_Inspector.swift`, `_Swatches.swift` (dev tooling cluster)
- Renders against: `TypeLabRole.scale` — parallel of `Type` enum values
- Inbox plan: `inbox.md → "Type Lab tab" entry` (now archived to ✅ Resolved)
- BACKLOG promotion trigger: when a pairing wins iPad vet → execute Promotion path above
