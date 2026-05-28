# Inspector — Dev tool

**Layer:** Dev tool (audit-exempt by `_` prefix · `#if DEBUG`-gated)
**Status:** 🟢 v0 shipped (2026-05-24) — pending iPad vetting
**Implementation:** `houseKipper/houseKipper/DesignSystem/_Inspector.swift`

## Overview

Touch-to-context tool. Eliminates the "context-giving" cost: long-press any annotated element in the swatches → identity payload (surface name, tokens used, file:line) lands on the clipboard → paste in chat → agent has full context without typed description.

**Why it exists:** typography tweaks across this DS routinely cost 3–5 chat turns each just identifying the surface ("the eyebrow above the title in the urgent NextUpCard", "the small label below the icon in the NavRail items"). Inspector collapses that to one long-press.

**Activation:** persistent **INSPECT** toggle in the swatches header — visible on every tab (Foundations, Primitives, Components). Flip ON, then long-press any annotated element in any panel to capture its identity *in its real context*. Flip OFF and everything goes back to normal interaction (button taps, scroll, etc.). The toggle is the single global on/off; there is no separate "Inspector tab" — that would defeat the point of inspecting Primitives + Components where they actually live.

## Public API

```swift
extension View {
    func identify(
        _ name: String,
        tokens: [String] = [],
        file: String = #file,
        line: Int = #line
    ) -> some View
}
```

Drop one line at any view's call site:

```swift
Text("NEXT UP")
    .typeStyle(Type.Label.xs)
    .foregroundStyle(TextToken.primary)
    .identify("NextUpCard.NEXT_UP_eyebrow",
              tokens: ["Type.Label.xs", "TextToken.primary"])
```

## State holder

```swift
@Observable
final class Inspector {
    var isEnabled: Bool = false
    var lastTouched: Identity?

    struct Identity: Identifiable, Hashable {
        let id = UUID()
        let name: String           // "NextUpCard.NEXT_UP_eyebrow"
        let tokens: [String]       // ["Type.Label.xs", "TextToken.primary"]
        let file: String           // #file
        let line: Int              // #line
        let timestamp: Date
    }
}
```

Plumbed via `@Environment(\.dsInspector)`. `_Swatches` owns the instance; the header **INSPECT** `Toggle` drives `isEnabled`. Clearing `lastTouched` happens when the toggle flips OFF.

> **2026-05-27 rename note:** the Environment key was originally `\.inspector` but collided with SwiftUI's iOS 17+ `View.inspector(isPresented:content:)` modifier — Swift's resolver disagreed with the indexer and emitted ~211 phantom "Cannot find type" errors across `_Swatches.swift` (Xcode's red squigglies disagreed with the actual compiler, which built clean). Renamed to `\.dsInspector` to disambiguate. EnvironmentKey type stayed `InspectorKey` (private); only the public extension property renamed. Two consumers: `IdentifyModifier` reads via `@Environment(\.dsInspector)`; `_Swatches` injects via `.environment(\.dsInspector, inspector)`.

## Identity payload (the format that lands on the clipboard)

Three lines, structured but human-readable:

```
NextUpCard.title
Type.Title.lg · TextToken.primary
NextUpCard.swift:112
```

Copyable as one block. Pastes cleanly into chat.

## Activation flow

1. Flip the **INSPECT** toggle in the swatches header (top-right). The toggle persists across tabs.
2. Every annotated view in the current tab gets a subtle orange hairline overlay so you can see which surfaces are identified.
3. Switch tabs freely — Foundations / Primitives / Components — inspector stays on. Long-press elements where they really live (a DsButton in the Primitives panel, a NavRail item in the Components panel).
4. Long-press (0.4s) → haptic confirmation → identity captures, banner slides up from the bottom.
5. Banner shows: surface name · tokens · file:line. **Copy** writes the three-line payload to `UIPasteboard.general`; **Dismiss** clears.
6. Paste in chat. Agent has full context.
7. Flip the toggle OFF when done → normal interaction resumes.

## Adoption (v0 — all locked Primitives + Components)

**Primitives (root-level identify on the rendered element):**
- `DsButton.{variant}.{size}[.disabled]`
- `DsKeyButton.{shape}.{severity}`
- `DsBadge.{size}`
- `DsAvatar.letter`
- `DsStatusDot.{severity}.{size}`
- `DsProgressBar`
- `DsSearchField`
- `DsDivider.{style}.{orientation}`
- `DsLabeledDivider`
- `DsWeatherChip.summary`

**Components (key sub-surfaces — the parts the agent gets asked to tweak):**
- `NextUpCard.{NEXT_UP_eyebrow, dueLabel, title, metaLine}`
- `NavRail.item.{Home,Tasks,Spaces,Alerts,Settings}`
- `TopBar.{heading, themeMenu, search, addButton}`
- `SpaceCard.section.{ROOMS, OUTDOOR, SYSTEMS}`

**Resolution rule:** when a Component wraps a Primitive *and* both carry an identify, the **outer (more specific) identity wins**. So long-pressing the `+ ADD` button while on the Components tab returns `TopBar.addButton`, not the underlying `DsButton.primary.large`. Long-pressing a standalone DsButton on the Primitives tab returns the primitive's identity. Use the right tab for the right level.

**Adoption discipline going forward:** every new Primitive + Component adds `.identify()` to its root view (Primitive) and its key sub-surfaces (Component). One-line addition per surface — part of the same commit that ships the Primitive/Component.

## What v0 explicitly does NOT do

- **No live token editing** — identification only. Drift-back risk too high.
- **No deep-link to Xcode** — file:line is in the payload; open via Cmd+O on the Mac if needed.
- **No release behavior** — `@ViewBuilder` branch short-circuits to `self` in release.
- **No history** — only the most recent capture.

## Future (v1 / v2)

Tracked in [BACKLOG.md](../BACKLOG.md) → "Inspector v1/v2":
- **v1**: token consumers map (JSON of `Type.X.y` → users) surfaced in the banner ("Token also used by 4 other surfaces").
- **v2**: MCP side-channel (iPad POSTs payload → Mac daemon → `mcp__housekipper-inspector__last_touched` MCP tool → agent auto-reads on next turn, zero paste).

## Rules

- **Annotate at the consumer's call site, not inside primitives** (with one exception: `DsWeatherChip.summary` — the primitive *is* the surface for ID purposes, no consumer indirection).
- **Name format:** `Surface.role` — e.g. `NextUpCard.title`, `NavRail.item.Home`. Dot-separated, no spaces. Names should be greppable.
- **Tokens list:** include every SemanticToken the surface consumes that the agent might want to tweak (type style, foreground, border, fill). Skip layout tokens (Space, Radius) unless they're the point of the surface.
- **Do not annotate inside `#Preview` blocks.** Inspector is for the swatch app's interactive flow.

## Cross-references

- Uses: `BackgroundToken`, `TextToken`, `Border`, `Radius`, `Space`, `ShadowToken`, `Motion`, `DsButton`, `DsDivider`
- Used by: every annotated Primitive + Component
- Surfaces in: `_Swatches.swift` Inspector segment
