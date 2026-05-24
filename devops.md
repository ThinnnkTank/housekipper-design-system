# DS DevOps

Tooling, workflows, and infrastructure that support design-system development. **Not visual decisions** — those live in `specs/`. This file captures how the DS gets built, vetted, and shipped session-to-session.

Universal project rules (working with Luis, MCP tools, commit hygiene, etc.) live in [`CLAUDE.md`](../CLAUDE.md). This file is DS-specific.

---

## The swatch test app

The Xcode project ships with two entry points, toggled by build configuration:

| Build | Boots into | Why |
|---|---|---|
| `DEBUG` | `_Swatches()` | Live preview of every populated token + Primitive. The DS canvas. |
| Release | `ContentView()` | Real app shell (currently placeholder; grows as Components land). |

Routing in `houseKipper/houseKipper/houseKipperApp.swift`:

```swift
#if DEBUG
_Swatches()
#else
ContentView()
#endif
```

### Why `_Swatches` is preview-only

The leading underscore marks it audit-exempt (see `foundations.md` → Conventions). It intentionally reaches across DS layers to demonstrate Primitives and would fail the layer audit otherwise. Never strip the underscore.

### Segmented nav

The app is laid out as a sticky `Picker(.segmented)` above a `ScrollView`. Add a new segment when a new layer is in play — keep the current focus the default:

```swift
enum Segment { case foundations, primitives /* , components, patterns, ... */ }
@State private var segment: Segment = .primitives
```

When components land, add `.components`. Bump the default to whatever's actively being iterated — this is a productivity device, not a contract. Don't over-document segment additions.

### Launch screen

`Info.plist` → `UILaunchScreen` dict uses the paper asset (`Colors/paper`) so a cold start matches the swatch background. No black flash. If background colors change at the SemanticToken layer, the launch screen follows automatically — it points at the asset, not a hex.

---

## Audit (`./design-sys/audit.sh`)

Ripgrep-based layer + value linter. Must pass before any commit.

Catches:
- Hex literals outside `BaseTokens/`
- `Color(hex:)` outside `BaseTokens/`
- `.shadow()` outside `ShadowTokens.swift`
- Raw `Animation(...)` outside `MotionTokens.swift`
- Raw stroke widths outside `BorderSemantics.swift`
- Dashed strokes outside `DsDivider.swift`
- `Color.red` / `Color(red:…)` literals outside `BaseTokens/`
- `Font.system(size:)` outside `TypographyTokens.swift`
- Raw numeric `.padding(N)` / `cornerRadius: N` / `spacing: N` in Primitives+
- Primitives reaching into `*Token` directly (should go through Semantic)
- Components / Patterns / Screens touching `*Token` (should go through Primitives)

Run it:
```bash
./design-sys/audit.sh
```

Exit 1 on any violation. Output is `file:line  violation  rule  suggestion`. Pre-commit hook is backlog (`BACKLOG.md`).

**Exempt:** `_`-prefixed files (e.g. `_Swatches.swift`), `#Preview` blocks, `*Tests/` directories. All three exist intentionally — don't try to make them clean.

**Per-line escape:** add `// audit:exempt` to any line and the audit skips it. Use sparingly — the right place is multi-line preview infrastructure where the `#Preview { ... }` opening line is several lines above and the per-line `#Preview` substring match doesn't reach. Document on the same line WHY the exemption is needed.

---

## Build verification

After any DS code change:

```bash
cd houseKipper && xcodebuild \
  -project houseKipper.xcodeproj \
  -scheme houseKipper \
  -destination 'generic/platform=iOS' \
  build
```

Tail must end with `** BUILD SUCCEEDED **`. Warnings on `_Swatches.swift` are tolerable; warnings on Primitives or Tokens are not.

Xcode MCP equivalent: `BuildProject` tool (pascalcase, namespaced `mcp__xcode__*`). If MCP tools aren't surfacing at session start, run `xcrun mcpbridge < /dev/null` once from a shell call to nudge registration — see `CLAUDE.md` for context.

---

## Per-change routine (DS-specific overlay)

Universal routine is in `CLAUDE.md` → Design System Rules. DS-specific points:

1. **Spec + Swift in the same commit, always.** The spec is the contract. If they drift, the spec wins and Swift gets a follow-up fix. Better to never drift.
2. **`_Swatches.swift` updated alongside any new Primitive.** A Primitive without a swatch panel can't be vetted on iPad. Add the panel before pushing.
3. **`CHANGELOG.md` only on lock-in.** Per-iteration tweaks don't get changelog entries — only the lock moment (status flips to ✅).
4. **README status table updated when a Primitive moves between 🟡 → ✅.** Three-line edit, easy to forget.

---

## iPad device deployment

For visual vetting on a real device (not just simulator):

1. Xcode → Window → Devices and Simulators → confirm iPad is paired.
2. Trust the dev cert on the iPad: Settings → General → VPN & Device Management → trust "Apple Development: mr.luis.salinas@gmail.com".
3. Build to device (Cmd+R with the iPad selected as run destination).
4. App boots into `_Swatches` (DEBUG build).

Re-trusting may be needed after a device restart or cert rotation. iOS will surface an "Untrusted developer" alert on launch if so.

---

## File-touch quick-reference

What changes when you ship a new Primitive:

| File | Change |
|---|---|
| `houseKipper/.../Primitives/Ds<Name>.swift` | New |
| `design-sys/specs/primitives/ds-<name>.md` | New (mirror `ds-button.md` structure) |
| `houseKipper/.../_Swatches.swift` | Add `<name>Section` + thread it into the Primitives segment |
| `design-sys/README.md` | Status table row |
| `design-sys/CHANGELOG.md` | Only on lock-in |
| `design-sys/specs/semantic-tokens.md` | Only if new SemanticToken roles were introduced |
| `design-sys/specs/base-tokens.md` | Only if new BaseToken values were introduced |

What changes when you tune an existing Primitive (iter 2+):

| File | Change |
|---|---|
| The `.swift` | The actual edit |
| The matching `.md` spec | Update API/states/Anatomy if the change is structural; otherwise just append to the Decisions log |
| `_Swatches.swift` | Update the panel if visual presentation changed |
| `CHANGELOG.md` | Skip until lock-in |
