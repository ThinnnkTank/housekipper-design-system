# houseKipper Design System — Architecture Plan

## Context

iOS (SwiftUI) app for ADHD household management. The DS must survive Pandya's "session amnesia": every new agent session produces the same visual quality as the first.

I brought a 6-layer architecture from a prior consultant engagement (proven to kill the "random decisions" problem in a previous attempt). We adopt it as the authoritative model. Pandya's spec/audit discipline overlays on top of it.

We are in **Phase 0a**. Deliverable: the skeleton (folders, file stubs, naming rules, audit script). Real token values come next, when Luis provides them.

---

## The 6-layer model (authoritative)

```
BaseToken       raw named values. No SwiftUI. Just constants.
    ↓
SemanticToken   intent mapping. Asset catalog + Swift aliases.
    ↓
Primitive       atomic SwiftUI views. Consumes SemanticTokens only.
    ↓
Component       composes Primitives. No direct token access.
    ↓
Pattern         composes Components. Layout + flow logic.
    ↓
Screen          composes Patterns + Components. One per feature.
```

**Hard rule:** each layer reaches one level down only. A Component never touches a BaseToken. A Screen never builds a raw `Button` — it uses a `SearchBar` that contains a `DsButton`. This is the constraint that prevented random decisions in the prior attempt.

**`Ds` prefix on Primitives only** (`DsButton`, `DsInput`) — camel-case, Swift-idiomatic, avoids SwiftUI naming collisions. Components and above are name-distinct, no prefix.

---

## Folder structure

```
houseKipper/                                  ← repo root
├── CLAUDE.md                                 ← adds DS rules block
├── agents.md
├── design-sys/                               ← SPECS (markdown contracts)
│   ├── README.md                             ← entry point
│   ├── specs/
│   │   ├── foundations/                      ← intent prose
│   │   │   ├── color.md
│   │   │   ├── typography.md
│   │   │   ├── spacing.md
│   │   │   ├── radius.md
│   │   │   ├── motion.md
│   │   │   ├── iconography.md
│   │   │   └── accessibility.md
│   │   ├── base-tokens/                      ← raw value tables
│   │   │   ├── color-tokens.md
│   │   │   ├── spacing-tokens.md
│   │   │   ├── radius-tokens.md
│   │   │   └── typography-tokens.md
│   │   ├── semantic-tokens/                  ← intent → base mappings
│   │   │   ├── background.md
│   │   │   ├── text.md
│   │   │   └── action.md
│   │   ├── primitives/                       ← 1 spec per DS view
│   │   ├── components/
│   │   ├── patterns/
│   │   └── screens/                          ← optional, feature briefs
│   ├── fonts/                                ← DM Sans + DM Mono .ttf
│   ├── audit.sh                              ← layer-violation linter
│   ├── BACKLOG.md
│   └── CHANGELOG.md
└── houseKipper/                              ← Xcode project
    └── houseKipper/
        ├── DesignSystem/
        │   ├── BaseTokens/
        │   │   ├── ColorTokens.swift
        │   │   ├── SpacingTokens.swift
        │   │   ├── RadiusTokens.swift
        │   │   └── TypographyTokens.swift
        │   ├── SemanticTokens/
        │   │   ├── BackgroundTokens.swift
        │   │   ├── TextTokens.swift
        │   │   └── ActionTokens.swift
        │   └── Primitives/
        │       ├── DsButton.swift
        │       ├── DsInput.swift
        │       ├── DsCheckbox.swift
        │       └── DsAvatar.swift
        ├── Components/
        │   ├── SearchBar.swift
        │   ├── UserCard.swift
        │   └── (etc.)
        ├── Patterns/
        ├── Screens/
        ├── Assets.xcassets/                  ← SemanticToken .colorset entries
        └── houseKipperApp.swift
```

**Spec ↔ Swift mirror:** every Swift file has a markdown counterpart at the same path under `design-sys/specs/`. The markdown is the contract; Swift is the artifact. LLMs read specs first.

---

## Token mechanics

### BaseTokens (Swift constants, no SwiftUI)

```swift
// ColorTokens.swift
enum ColorToken {
    static let paper100 = Color(hex: "#E8EDE5")
    static let ink900   = Color(hex: "#1C1C1A")
    static let amber500 = Color(hex: "#E06518")
    // ...
}

// SpacingTokens.swift — numeric, matches the locked 18-stop ladder
enum SpacingToken {
    static let s0: CGFloat = 0
    static let s2: CGFloat = 2
    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    // ...up to s80
}
```

Numeric throughout. No semantic naming at the Base layer — semantics belong at the next tier.

### SemanticTokens (intent → base, asset-catalog backed for colors)

Colors live in **two places**:
- `Assets.xcassets/Colors/backgroundPrimary.colorset` — Any/Dark appearance variants for free light/dark mode
- `BackgroundTokens.swift` — Swift alias: `static let backgroundPrimary = Color("backgroundPrimary", bundle: .main)`

```swift
// BackgroundTokens.swift
enum BackgroundToken {
    static let primary  = Color("backgroundPrimary",  bundle: .main)
    static let elevated = Color("backgroundElevated", bundle: .main)
}

// ActionTokens.swift
enum ActionToken {
    static let primary  = Color("actionPrimary",  bundle: .main)
    static let danger   = Color("actionDanger",   bundle: .main)
    static let disabled = Color("actionDisabled", bundle: .main)
}
```

For spacing/radius/typography (no light/dark variance), SemanticTokens are intent-named Swift aliases of BaseTokens. **Primitives must use these aliases, never the BaseTokens directly.** Audit enforces.

```swift
enum Space {
    static let hairline       = SpacingToken.s2    // dividers, fine separators
    static let tight          = SpacingToken.s8    // icon-to-label, inside chips
    static let bodyPadding    = SpacingToken.s16   // default horizontal padding
    static let cardPadding    = SpacingToken.s20   // inside cards
    static let safeGutter     = SpacingToken.s24   // screen edge from safe area
    static let sectionGap     = SpacingToken.s32   // between sections
    static let blockSeparator = SpacingToken.s48   // major content blocks
}
```

**Rule:** if a Primitive needs a value with no semantic name, the name is added to `specs/semantic-tokens/spacing.md` and `Space.swift` FIRST. No `SpacingToken.sXX` in a Primitive, ever. Symmetric with the color path: Primitive → `BackgroundToken` → `ColorToken`. This is the constraint that prevents the "random decisions" problem from leaking back in at the spacing layer.

### Primitives (atomic SwiftUI views, reach only into SemanticTokens)

```swift
// DsButton.swift
struct DsButton: View {
    let label: String
    var severity: Severity = .healthy
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .padding(.horizontal, Space.bodyPadding)
                .foregroundStyle(TextToken.onAction)
                .background(severity.background)
        }
    }
}
```

`DsButton` may import `Space`, `TextToken`, `ActionToken`. It may NOT import `SpacingToken`, `ColorToken` directly.

---

## Audit script (`design-sys/audit.sh`)

Ripgrep-based. Enforces the layer-reach rule:

| Layer | May import |
|---|---|
| BaseTokens | nothing else |
| SemanticTokens | BaseTokens, Assets.xcassets |
| Primitives | SemanticTokens |
| Components | Primitives |
| Patterns | Components |
| Screens | Patterns, Components |

Also flags:
- Hex literals outside `BaseTokens/`
- Raw numeric padding/spacing outside BaseTokens (`.padding(16)` → must be `Space.x`)
- `Color.red`, `Color(red:…)`, `Color(hex:…)` outside `BaseTokens/`
- `Font.system(size:)` outside `TypographyTokens.swift`
- A Primitive importing another Primitive
- Any view in `Components/` referencing `*Token` directly (must go through Primitive)

Output: `file:line  violation  layer-rule  suggestion`. Exit 1 on any violation. Pre-commit hook wired in Phase 1.

---

## Build order (strictly sequential, each phase frozen before next)

| Phase | Layer | Done when |
|---|---|---|
| **0a** *(this plan)* | BaseTokens | All 4 base files populated with Luis's values · audit clean · specs written |
| **0b** | SemanticTokens | Asset catalog colorsets + Swift aliases · light/dark variants set · specs written |
| **1a** | Primitives | DsButton, DSInput, DSCheckbox, DSAvatar built · each has spec · previews work on iPad via MCP |
| **1b** | Components | First 3 components composed from Primitives · specs written |
| **1c** | Patterns | First flow (likely AuthOrOnboarding) · spec-driven |
| **2+** | Screens | One per milestone, starting with Dashboard |

Nothing in a later phase ships until everything in the prior phase is frozen and signed off by Luis.

---

## Component spec template (every primitive/component/pattern/screen)

```markdown
# DsButton

**Metadata**: layer · status (draft/locked) · since
**Overview**: when to use · when NOT to use
**Anatomy**: SwiftUI view tree, parts labeled
**SemanticTokens used**: ActionToken.primary, Space.bodyPadding, ...
**API**: init signature, public props
**States**: default · pressed · disabled · attention · urgent
**Example**:
```swift
DsButton(label: "Mark done", severity: .healthy) { ... }
```
**Cross-references**: Used by → SearchBar, TaskRow
```

---

## Migration of existing `design-sys/design-system.md`

Distribute into specs, archive original:

| Existing content | New spec |
|---|---|
| 4-grid preference & 18-stop ladder | `foundations/spacing.md` + `base-tokens/spacing-tokens.md` |
| Severity ladder (healthy/attention/urgent) | `foundations/color.md` + `semantic-tokens/action.md` + `primitives/ds-button.md` |
| Icons section | `foundations/iconography.md` |
| Behaviors > Pop-up | `patterns/popup.md` |
| Nav rail spec | `components/nav-rail.md` |
| Backlog (dark mode) | `design-sys/BACKLOG.md` |
| Change log | `design-sys/CHANGELOG.md` |

Original moves to `design-sys/_legacy/design-system-v1.md` for traceability.

---

## CLAUDE.md addendum (LLM contract)

Add a `## Design system rules` section:

```
Before modifying any UI code:
1. Identify which layer you're touching (BaseToken / SemanticToken /
   Primitive / Component / Pattern / Screen).
2. Read the matching spec in design-sys/specs/<layer>/.
3. You may only import from the layer immediately below. No skipping.
4. If a needed token or primitive doesn't exist, propose it in specs/ FIRST.
   Wait for sign-off. Then implement.
5. Run ./design-sys/audit.sh before any commit. Zero errors required.
```

---

## Phase 0a deliverables (this plan's scope)

1. Create folder skeleton (`design-sys/specs/*`, `houseKipper/houseKipper/DesignSystem/*`, `Components/`, `Patterns/`, `Screens/`).
2. Write 3 foundation specs from existing `design-system.md`: `color.md`, `spacing.md`, `iconography.md`.
3. Write `base-tokens/*.md` templates (empty value tables ready for Luis's input).
4. Write Swift `BaseTokens/*.swift` stubs (enums declared, values empty/`TBD`).
5. Write `audit.sh` with the layer-reach rules; passes on the empty skeleton.
6. Update `CLAUDE.md` with the DS Rules block.
7. Update `agents.md` to point at the new specs root.
8. Archive `design-sys/design-system.md` → `_legacy/design-system-v1.md`.

**Out of scope**: actual token values (next, when Luis provides them), SemanticTokens (Phase 0b), Primitives onward, Graphify wiring, pre-commit hook.

---

## Files to create / modify

**Created**:
- `design-sys/README.md`
- `design-sys/specs/foundations/*.md` (7 files)
- `design-sys/specs/base-tokens/*.md` (4 files)
- `design-sys/specs/semantic-tokens/*.md` (3 files)
- `design-sys/specs/{primitives,components,patterns,screens}/.gitkeep`
- `design-sys/audit.sh`
- `design-sys/BACKLOG.md`
- `design-sys/CHANGELOG.md`
- `houseKipper/houseKipper/DesignSystem/BaseTokens/*.swift` (4 files)
- `houseKipper/houseKipper/DesignSystem/SemanticTokens/.gitkeep`
- `houseKipper/houseKipper/DesignSystem/Primitives/.gitkeep`
- `houseKipper/houseKipper/Components/.gitkeep`
- `houseKipper/houseKipper/Patterns/.gitkeep`
- `houseKipper/houseKipper/Screens/.gitkeep`

**Modified**:
- `CLAUDE.md` (add Design System Rules section)
- `agents.md` (update design-sys path reference)

**Moved**:
- `design-sys/design-system.md` → `design-sys/_legacy/design-system-v1.md` (content distributed first)

---

## Verification

After Phase 0a executes:

1. **Spec navigability**: `design-sys/README.md` links resolve to every spec.
2. **Audit dry-run**: `./design-sys/audit.sh` returns 0 on the empty skeleton.
3. **Xcode build**: project compiles with empty BaseToken enums (no values yet).
4. **Layer enforcement test**: temporarily add `Color.red` to a Primitive stub → audit catches it → revert.
5. **Agent boot test**: fresh session, `agent designer`, ask "what's our ink color?" — agent reads `base-tokens/color-tokens.md`, reports `TBD` (not invented).
6. **Reference doc test**: ask agent to scaffold a fake Card → it reads `specs/components/` first, reports the missing spec rather than guessing.
