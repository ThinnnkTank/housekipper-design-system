# Design System Backlog (deferred — do not action)

## Next up

- **HeroCard refactor — unify NextUpCard + ActiveProjectCard into one Component.** Approved in plan (Luis 2026-05-27 "option 1") then deferred to a focused session. Both cards already share anatomy at the visual level: 44pt header rail, 48pt SF Symbol icon with 12pt L/R breathing, asymmetric 8/24 vertical padding, Title.lg title, Label.xs eyebrow, ink40 1pt border (or signal 2pt for urgent). **Refactor goal:** single `HeroCard` struct with `State` enum (`.task(TaskState)` covering NextUp.urgent + .upcoming; `.project(ProjectState)` covering ActiveProject; `.allClear(message)` covering NextUp.allClear). **Skeleton already drafted** in conversation — eyebrow + state-specific header trailing content via `@ViewBuilder` switch, then content row via state switch. Pure restructure, no visual change. Migration: delete `NextUpCard.swift` + `ActiveProjectCard.swift`, write `HeroCard.swift`, update `DashboardScreen.HomeTab` + `_Swatches` call sites, collapse two specs into `components/hero-card.md` (old two marked ✗ Removed). Estimated ~30 min.

---

## Dashboard polish (Luis 2026-05-27 post-promotion) — partially landed

- ✅ **Hero card styling refinements** — locked 2026-05-27. Shared anatomy, asymmetric padding, hammer icon for ActiveProject, 48pt icon with 12pt L/R breathing, `.secondary` arrows.
- **Upcoming Maintenance row styles.** MaintenanceRow + MaintenanceList typography + spacing pass. Luis flagged earlier: the eyebrow ("UPCOMING MAINTENANCE") + the date column + the title can still tune. Eyebrow renamed to "Tasks" (Title.md, sans Medium 17pt). Date column bolder weight still pending — DM Mono only ships Regular + Medium (no Bold) — decision deferred. **Open:** title size relative to date, weight balance, optional location/frequency styling, hover/press behaviors on iPad.
- **Overall content size + scroll behavior.** When `MaintenanceList` overflows the Tasks card scroll area, scroll engages internally. Open questions: should the WHOLE body scroll instead on iPhone / smaller iPads? Should the right column scroll independently from the left? When user reaches bottom of MaintList, how is the scroll boundary signaled (fade? hairline?)? Cross-screen pattern decisions.
- ✅ **Minor TopNav row adjustments** — locked earlier 2026-05-27. Search width 256pt, ADD button .small +24pt extra padding, 44pt avatar/etc.

## Calendar polish (Luis 2026-05-27 — "well talk calendar later")

- Right column grid lock landed (calendar height = heroHeight × 2 + snug = 352pt; Tasks card wraps MaintList). Calendar's internal vertical compression at 352pt is functional but Luis flagged for follow-up vet — re-examine cell heights, dot prominence, legend density, and whether internal flex spacers feel balanced at the fixed height.

---

- **Popover Pattern + Primitives** (formerly "ActionSheet"). The rich-content popover anchored to "+ ADD" on the dashboard TopBar: list of options with icon + label + subtitle, separable groups via dashed dividers (e.g. routine actions vs. "Urgent repair" emergency mode in a separate group). iPad-native popover with arrow anchor; iPhone falls back to a confirmation dialog or sheet. SwiftUI: `.popover(isPresented:)` with a custom view inside (stock `Menu` can't render rich rows). Item rows use `Press.invert` (per the established vocabulary).
  - **Primitive needed:** `DsPopoverItem` — icon + label + subtitle row with invert press.
  - **Pattern needed:** `Popover` (or `DsPopover`) — wraps the SwiftUI popover with our chrome (paper2 fill, ink border, Radius.md, group separation via DsLabeledDivider or DsDivider.dashed).
  - **TopBar's `onAdd` callback** currently just dispatches — the popover presentation belongs to the Screen hosting TopBar. When the Screen lands, it wires `.popover(isPresented:)` onto its layout root.
  - Defer until the dashboard Screen is being assembled.
- **ActionCard Component.** Pairs with `DsSearchField` — the "+ add an item" affordance card that often sits next to a search filter. Luis 2026-05-23: deferred until first screen that needs it surfaces.
- **MaintenanceRow state interactions — snoozed + completed (Screen-wiring work).** When the user acts on the urgent `NextUpCard`, the corresponding `MaintenanceRow` reflects the change:
  - **Snoozed** → row gets a *paused* treatment: signal (orange) accent + pause-glyph indicator. The task lifts back into MaintenanceList (no longer in NextUpCard) but reads as deferred, not idle.
  - **Completed** → row title gets a *strikethrough* + foreground muted to ink40. Stays visible briefly (or until next refresh) so the user registers the completion.

  These are cross-Component interactions — they need a shared task model + NextUpCard ↔ MaintenanceList coordination. Defer until the Dashboard Screen wiring round. Implementation likely: add a `state: TaskState` enum on `MaintenanceList.Item` with `.upcoming` / `.snoozed` / `.completed`; MaintenanceRow grows a `state` param and renders the strikethrough / orange-pause overlay accordingly. Reference logged in `maintenance-list.md → Future states`.
- **Inspector v1/v2 — token consumers map + MCP side-channel.** v0 shipped 2026-05-24 (see [specs/_inspector.md](specs/_inspector.md)). v1 + v2 extend it.

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
- **Spec-format audit (mechanical enforcement of doc uniformity).** **Promoted from inbox 2026-05-25** — drift observed in `evals/consulting-assesment-001.md` (trigger fired). `CLAUDE.md` defines minimum required sections per layer (Primitive / Component / Screen) + canonical example specs. Currently this is reading-enforced; a future session could skip a section and we'd only notice on visual review. A mechanical extension to `design-sys/audit.sh` catches it pre-commit, same defense pattern as the Swift-side audit. **Implementation sketch:** new audit scan over `design-sys/specs/{primitives,components,screens}/*.md`; per-layer required-headings array; report missing required heading + missing `**Status:**` stamp as violations; exit non-zero. Also worth checking: orphan `🟡 pending vet` CHANGELOG entries with no follow-up ✅ row (new 🟡 closure ritual in CLAUDE.md). Defer implementation to a focused session — not bundled with content/component work.
- **Pre-commit hook for audit.sh.** Wire `./design-sys/audit.sh` into `.git/hooks/pre-commit`. Phase 1.
- **Scope-aware `#Preview` exemption in audit.sh.** Currently the audit's preview-block exemption is per-line — it only matches the literal substring `#Preview` on the violation line. Multi-line preview blocks need either the per-line `// audit:exempt` escape or refactoring. Better: pre-process with awk to identify `#Preview { ... }` line ranges per file and skip violations inside them. Eliminates the escape comment usage. Defer until enough Components have multi-line previews to justify.
- **Graphify integration.** Phase 1.
- **`make sync-design-mirror` target (one-line subtree push to public mirror).** The public mirror at https://github.com/ThinnnkTank/housekipper-design-system is a `git subtree`-published projection of `design-sys/` from this private parent repo. Today the sync is a manual command (`git subtree push --prefix=design-sys https://github.com/ThinnnkTank/housekipper-design-system.git main`) we have to remember after every `design-sys/`-touching commit lands on `main`. Wrap it in a `Makefile` (or top-level `bin/sync-design-mirror.sh`) so it's one keystroke. Optional follow-up: a git post-push hook that auto-runs when the push includes `design-sys/` changes — but only when the parent repo's branch is `main`, to avoid pushing draft work to the public side. Tracks against the broader handoff contract in `design-sys/HANDOFF.md`.
