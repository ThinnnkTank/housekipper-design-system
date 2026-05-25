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

## Current state

**Read [`CHANGELOG.md`](CHANGELOG.md).** Every shipped decision is dated and explained. Status tables drift; dated logs don't — that's the operating principle here.

This file intentionally does not maintain a phase/component status grid. The CHANGELOG is the truth. The spec files (`specs/**/*.md`) carry their own `**Status:**` stamp at the top — that's where to check whether a specific Primitive or Component is `✅ Locked` vs `🟡 Implemented (pending vet)`.

**Dev tooling** lives under `houseKipper/houseKipper/DesignSystem/_*.swift` (audit-exempt by `_` prefix, `#if DEBUG`-gated). Most relevant: `_Swatches.swift` (live token + primitive preview, hosts the Inspector toggle + Type Lab), `_DashboardMock.swift` (current dashboard vetting canvas, promotes to `DashboardScreen.swift` after iPad sign-off), `_Root.swift` (router between Swatches and Dashboard).

[BACKLOG.md](BACKLOG.md) · [CHANGELOG.md](CHANGELOG.md) · [devops.md](devops.md) (tooling, swatch app, audit, build) · [_legacy/](_legacy/) (archived paprLCD sources — v1 markdown + v1/vnext HTML style sheets)
