# Design System Backlog (deferred — do not action)

- **Popover Pattern + Primitives** (formerly "ActionSheet"). The rich-content popover anchored to "+ ADD" on the dashboard TopBar: list of options with icon + label + subtitle, separable groups via dashed dividers (e.g. routine actions vs. "Urgent repair" emergency mode in a separate group). iPad-native popover with arrow anchor; iPhone falls back to a confirmation dialog or sheet. SwiftUI: `.popover(isPresented:)` with a custom view inside (stock `Menu` can't render rich rows). Item rows use `Press.invert` (per the established vocabulary).
  - **Primitive needed:** `DsPopoverItem` — icon + label + subtitle row with invert press.
  - **Pattern needed:** `Popover` (or `DsPopover`) — wraps the SwiftUI popover with our chrome (paper2 fill, ink border, Radius.md, group separation via DsLabeledDivider or DsDivider.dashed).
  - **TopBar's `onAdd` callback** currently just dispatches — the popover presentation belongs to the Screen hosting TopBar. When the Screen lands, it wires `.popover(isPresented:)` onto its layout root.
  - Defer until the dashboard Screen is being assembled.
- **ActionCard Component.** Pairs with `DsSearchField` — the "+ add an item" affordance card that often sits next to a search filter. Luis 2026-05-23: deferred until first screen that needs it surfaces.
- **Inspector overlay — touch-to-context tool for the swatch + future screens.** Solves the "context-giving" cost. Luis touches an element on iPad → identity lands somewhere the agent can read it → next chat turn already has full context (component, role, tokens used, file:line). Triggered by [`inbox.md`](../inbox.md) → 🦊 *Inspector tool* (Luis 2026-05-24).

  ### Why this matters (concrete friction we just lived through)

  Recent sessions burned ~10 turns each describing which element Luis was tweaking — "the eyebrow above the title in the urgent NextUpCard," "the small label below the icon in the NavRail items," "the meta line under the address in the TopBar." Every typography tweak forced this dance. Today's session alone:
  - Title.lg tracking change → 4 turns identifying surface
  - Label.xs ink change → 3 turns + a grep audit by me to find every consumer
  - Label.sm size bump → 2 turns + manual call-site updates

  With Inspector v0, the dance collapses to: long-press → copy → paste → I have the surface name, the tokens it uses, and the source location. With v2 (MCP side-channel below) it collapses further to: long-press → silently writes payload → I auto-detect the touch event on my next read → zero typing.

  ### Architecture

  **New file:** `houseKipper/houseKipper/DesignSystem/_Inspector.swift` (audit-exempt via `_` prefix, gated by `#if DEBUG`).

  **Public surface:**
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

  Wraps the view in a long-press gesture (0.5s minimum) that, when fired, posts an `InspectorEvent` to an `@Environment(\.inspector)` state holder.

  **State holder:**
  ```swift
  @Observable
  final class Inspector {
      var isEnabled: Bool = false
      var lastTouched: Identity?

      struct Identity: Identifiable, Hashable {
          let id = UUID()
          let name: String           // "NextUpCard.NEXT_UP_eyebrow"
          let tokens: [String]       // ["Type.Label.xs", "TextToken.primary"]
          let file: String           // "/Users/mclovin/.../NextUpCard.swift"
          let line: Int              // 91
          let timestamp: Date
      }
  }
  ```

  **Identity payload (the format Luis copies / I read):**
  ```
  NextUpCard · NEXT_UP eyebrow
  Type.Label.xs · TextToken.primary
  NextUpCard.swift:91
  ```

  Three lines, structured but human-readable. Copyable as one block.

  ### Activation flow

  1. **5th `Segment` in `_Swatches`:** `.inspector = "Inspector"`. Selecting it sets `inspector.isEnabled = true` globally; other tabs unaffected.
  2. **Long-press any annotated element** → identity posts to state.
  3. **Overlay UI:**
     - A persistent floating card at the bottom of the swatch (visible when `isEnabled` AND `lastTouched != nil`)
     - Shows the three-line identity payload
     - **Copy** button → puts the formatted string on `UIPasteboard.general`
     - **Dismiss** button → clears `lastTouched`
  4. Luis pastes the copied block in chat. Agent has full context.

  ### Adoption mechanics

  Every locked Primitive + Component gets `.identify(...)` calls on its root view and on any sub-element the agent might need to address independently:

  ```swift
  // NextUpCard.swift
  Text("NEXT UP")
      .typeStyle(Type.Label.xs)
      .foregroundStyle(TextToken.primary)
      .identify("NextUpCard.NEXT_UP_eyebrow",
                tokens: ["Type.Label.xs", "TextToken.primary"])
  ```

  One-line additions per surface. Can land incrementally — ship the modifier first, adopt one surface at a time. Per-change discipline: when iterating on a Component, add `.identify()` calls as you go.

  ### What v0 explicitly does NOT do

  - **No live token editing** — just identification. Drift-back risk too high.
  - **No deep-link to Xcode** — file:line is in the payload; Luis opens via Cmd+O on the Mac if needed.
  - **No release behavior** — `#if DEBUG` strips everything.
  - **No persistence of touch history** — just the most recent. Avoids state bloat.

  ### v1 — Token consumers map

  Static analysis pass over Swift files producing a JSON file `~/.housekipper-token-consumers.json`:
  ```json
  {
    "Type.Label.xs": [
      "NavRail.swift:77 (chip label)",
      "DsLabeledDivider.swift:19 (section title)",
      "NextUpCard.swift:91 (NEXT_UP eyebrow)",
      "NextUpCard.swift:114 (meta line)",
      "DsKeyButton.swift:143 (preview eyebrow)"
    ],
    "Border.Color.muted": [...],
    ...
  }
  ```

  Inspector reads the JSON and adds a fourth line to the identity payload: "Token also used by: 4 other surfaces." Lets Luis decide *before* a token tweak whether the change touches more than just the one element he's looking at.

  Built as a Bash/Python script that runs as part of `audit.sh` or as a separate `tools/build-token-map.sh`. Output JSON is checked in (deterministic).

  ### v2 — MCP side-channel (the workflow Luis sketched)

  The "sniff iPad touches" vision works as a pull side-channel, not a true sniffer:

  1. **iPad side:** Inspector writes every long-press's payload to a local file the running app can reach — e.g. via `URLSession` POSTing to `localhost:5455` (a tiny dev server on the Mac), or writing to a shared file via iCloud Drive / a file-coordinator.
  2. **Mac side:** a small daemon (or just a watched file) accumulates the payloads, exposes them via an MCP tool — e.g. `mcp__housekipper-inspector__last_touched` returns the most recent identity.
  3. **Agent side:** on the next turn, the agent calls the MCP tool first thing → has Luis's current focus before he types a single word.

  This makes the loop: Luis touches → ~250ms → agent has context → Luis says "make the title bigger" and I know exactly which title.

  **v2 complications to flag:**
  - Requires a Mac daemon process (running while we work)
  - Trust boundary — payloads include source paths, fine for solo dev
  - iPad → Mac network reachability needs same-LAN

  Build v0 + v1 first; promote to v2 when the basic loop has proven its value.

  ### Implementation cost (estimates)

  - **v0** (modifier + state holder + 5th segment + adoption across all 12 locked surfaces): ~3-4 hours
  - **v1** (token consumers JSON + Inspector integration): ~2 hours
  - **v2** (MCP side-channel): ~6-8 hours including the Mac daemon + MCP tool

  ### Promotion path

  If v0 and v1 prove their worth, the Inspector graduates from `_` prefix to a real (still DEBUG-gated) DS dev tool: `DesignSystem/Inspector/`. Source remains audit-exempt-by-folder.

- **Token consumers map (small dev tool).** Static analysis pass over Swift files producing a JSON map of `Type.{Category}.{size}` → list of consumers. Used by the Inspector and surfaced as a "Token Inspector" panel in the swatch. Reduces "who uses Label.xs?" lookup from grep-and-eyeball to one click. Lower priority than the Inspector itself; build after Inspector v0 lands.

- **DsInput Primitive (generic text/numeric/multiline input).** Sibling to `DsSearchField`. Keeps the `Radius.md` (12pt rounded-rect) corners that the original `DsSearchField` iter-1 had — capsule is now reserved for search per Luis 2026-05-24 iter-3. When DsInput ships, it'll share `DsSearchField`'s underlying chrome (paper2 fill, 1pt ink border, 40pt height, `hkButtonLg` text, focus-darkens via ink05 wash) but with rounded-rect ends and no built-in leading icon. Likely variants: `.text`, `.numeric` (with `.keyboardType(.decimalPad)` and tabular digits via `Font.hkData`), `.multiline`. Defer until a screen needs a non-search input.
- **DsAvatar enhancement.** Initial implementation is letter-in-circle only. Future: integrate the user's Apple ID profile photo (`AuthorizationAppleIDProvider` / signed-in iCloud account) with letter as fallback. Maintenance assignees may also surface contact-photo or SF Symbol fallbacks. Likely adds `.photo(UIImage)` and `.symbol(String)` Mode cases alongside `.letter(Character)`. Re-evaluate when sign-in / contact-picker surfaces ship.
- **DsAddTile** Primitive. Appearance-only tile that appears at the end of `RoomsRail` / `OutdoorRail` / `SystemsRail`. Passive border + muted content. Deferred — not in current dashboard build.
- **Custom icons.** SF Symbols is the icon system. A small number of household-specific concepts (grass, tree, shed, couch, faucet) likely need custom PDF-vector additions to the asset catalog when first surfaced in a real screen. Source reference: paprLCD icon library (external — Luis-local). Re-evaluate when a screen actually needs one.
- **Dark-mode value tuning.** Initial dark values inferred from canonical paprLCD vnext. Luis flagged "they suck" — easy to revise by editing each `.colorset` Contents.json (no Swift changes needed).
- **Body weight final lock.** Currently `regular` implied — revisit after first Primitive ships and we see real text in context.
- **Space Grotesk reconsideration.** Dropped this round. Revisit if display sizes (22/30/38) feel flat with DM Sans alone.
- **Pre-commit hook for audit.sh.** Wire `./design-sys/audit.sh` into `.git/hooks/pre-commit`. Phase 1.
- **Scope-aware `#Preview` exemption in audit.sh.** Currently the audit's preview-block exemption is per-line — it only matches the literal substring `#Preview` on the violation line. Multi-line preview blocks need either the per-line `// audit:exempt` escape or refactoring. Better: pre-process with awk to identify `#Preview { ... }` line ranges per file and skip violations inside them. Eliminates the escape comment usage. Defer until enough Components have multi-line previews to justify.
- **Graphify integration.** Phase 1.
