# houseKipper Design System

Source of truth for every visual and structural decision. **Specs are the contract. Swift is the artifact.** LLMs read specs first.

> Architecture rationale: [ARCHITECTURE.md](ARCHITECTURE.md).

## The 6-layer model

| Layer | Role | Examples |
|---|---|---|
| BaseToken | raw values · no SwiftUI | `#1F1F1D`, `8pt`, `16pt`, `0.18 opacity` |
| SemanticToken | intent mapping · asset catalog + Swift aliases | `inkPrimary`, `surfaceRaised`, `borderSubtle`, `spaceMd` |
| Primitive | atomic SwiftUI view · consumes SemanticTokens only | `DsButton`, `DsKeyButton`, `DsTextField` |
| Component | composes Primitives | task row, room card, confirmation bar |
| Pattern | composes Components | quick capture flow, chore checklist, room overview |
| Screen | composes Patterns + Components | Today screen, Room detail screen, Settings screen |

**Rule:** each layer reaches one level down for *composition* — Primitives compose SemanticTokens, Components compose Primitives, etc. Components/Patterns/Screens may ALSO consume SemanticTokens directly for layout chrome (bg, text, geometry, motion). The strict boundary is BaseTokens: only the SemanticToken layer may touch raw values. `./design-sys/audit.sh` enforces.

## Spec map

| What | Spec | Swift |
|---|---|---|
| Design intent (the *why*) | [specs/foundations.md](specs/foundations.md) | — |
| Raw token values | [specs/base-tokens.md](specs/base-tokens.md) | `DesignSystem/BaseTokens/*.swift` |
| Semantic aliases | [specs/semantic-tokens.md](specs/semantic-tokens.md) | `DesignSystem/SemanticTokens/*.swift` |
| Primitives | [specs/primitives/](specs/primitives/) — one .md per Primitive | `DesignSystem/Primitives/*.swift` |
| Components | [specs/components/](specs/components/) — one .md per Component | `Components/*.swift` |
| Patterns | [specs/patterns/](specs/patterns/) — one .md per Pattern | `Patterns/*.swift` |
| Screens | [specs/screens/](specs/screens/) — one .md per Screen | `Screens/*.swift` |

## Vetting

`houseKipper/houseKipper/DesignSystem/_Swatches.swift` — live preview of every populated token. Run on iPad to vet.

## Audit

```bash
./design-sys/audit.sh
```

Zero violations required. Pre-commit hook coming in Phase 1.

## Status

| Phase | Layer | Status |
|---|---|---|
| 0a | Skeleton | ✅ |
| 0b | BaseTokens + SemanticTokens (values) | ✅ |
| 1a | DsButton primitive | ✅ Locked |
| 1a | DsDivider primitive | ✅ Locked |
| 1a | DsKeyButton primitive | ✅ Locked |
| 1a | DsBadge primitive | ✅ Locked |
| 1a | DsAvatar primitive | ✅ Locked |
| 1a | DsStatusDot primitive | ✅ Locked |
| 1a | DsProgressBar primitive | ✅ Locked |
| 1a | DsSearchField primitive | ✅ Locked |
| 1a | DsLabeledDivider primitive | ✅ Locked |
| 1a | DsWeatherChip primitive | 🟡 Implemented (dummy, pending iPad vet) |
| 1b | NavRail component | ✅ Locked |
| 1b | SpaceCard component | ✅ Locked (bordered chrome added 2026-05-25) |
| 1b | TopBar component | 🟡 Implemented (pending iPad vet) |
| 1b | NextUpCard component | 🟡 Implemented (pending iPad vet) |
| 1b | MaintenanceRow component | 🟡 Implemented (pending iPad vet) |
| 1b | MaintenanceList component | 🟡 Implemented (pending iPad vet) |
| 1b | CalendarMonth component | 🟡 Implemented (pending iPad vet) |
| 1b | ActiveProjectCard component | 🟡 Implemented (pending iPad vet) |
| 1c-2 | Patterns / Screens | 🟡 Dashboard in mock (`_DashboardMock` — locked outer-padding contract; promotes to `DashboardScreen.swift` after iPad sign-off) |

### Dev tools (audit-exempt `_` prefix, `#if DEBUG`-gated)

| File | Role | Status |
|---|---|---|
| `_Swatches.swift` | Live preview of every populated token + Primitive + Component | Live — `INSPECT` toggle + Type Lab tab |
| `_Inspector.swift` | Touch-to-context: long-press an annotated view → identity copies to clipboard | ✅ v0 shipped (2026-05-24) |
| `_FontPairing.swift` | Type Lab — audition alternative typeface pairings against the 12-style scale | ✅ v0 shipped (2026-05-24) |
| `_DashboardMock.swift` | Vetting canvas for the dashboard layout | 🟡 Active, pending promotion to `DashboardScreen.swift` |
| `_Root.swift` | Router — toggle between Swatches and Dashboard via floating signal-orange chip | ✅ Shipped (2026-05-25) |

[BACKLOG.md](BACKLOG.md) · [CHANGELOG.md](CHANGELOG.md) · [devops.md](devops.md) (tooling, swatch app, audit, build) · [_legacy/](_legacy/) (archived paprLCD sources — v1 markdown + v1/vnext HTML style sheets)
