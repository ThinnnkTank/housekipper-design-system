# NavRail — Component

**Layer:** Component
**Status:** spec carried over from paprLCD, implementation pending
**Since:** —

## Overview

Primary app navigation. Houses the main cluster and a bottom utility cluster.

## Anatomy

```
NavRail
├── Main cluster
│   ├── Home    (default active)
│   ├── Tasks
│   ├── Spaces
│   └── Alerts
├── Flexible space
└── Utility cluster
    ├── Settings (gear)
    └── Avatar
```

## Rules

- **Settings is NOT in the main cluster.** It lives in the bottom utility cluster with the avatar.
- Nav icons use full ink contrast, not muted.
- Active `Home` uses a **dashed ink border on paper background** (distinguishes from filled selection).
- Main cluster items follow severity ladder when carrying a badge.

## Composition

`NavRail` composes:
- `DsIconButton` (Primitive, TBD)
- `DsAvatar` (Primitive, TBD)
- Layout via `Space.sectionGap` between clusters

## Cross-references

- Uses: `DsIconButton`, `DsAvatar`, `Space`, `BackgroundToken`
- Used by: every Screen except onboarding
