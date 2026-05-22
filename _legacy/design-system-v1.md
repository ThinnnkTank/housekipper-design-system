# paprLCD — Design System OS

** Contributors: Luis + 🦊 Designer (Claude) **


## Geometry preference — multiples of 4 (preference, not law)

**Prefer** multiples of 4 (with 2 as half-step) for paprLCD custom component geometry — spacing, padding, margin, width, height, radii.

**Exempt:**
- **Smaller Font sizes.** Sizes 9, 11, and 13, are ok. from there 14, 16, 18, 20, 22, 24, 28, 32, 36, 40, 44, 48, 56, 64, 80, etc.
- **Border widths.** 1px hairlines, 1.5 / 2px borders are fine — the preference is for layout, not stroke weight.
- **Corner radii.** When needed 3, 5, 7 maybe ok.
- **Native Apple control dimensions** (e.g. iOS toggle 51×31, tab bar 49pt, Dynamic Type sizes). When implementing in SwiftUI we honor the platform — don't fight UIKit and oppush back when Luis says otherwise.
- **Letter spacing, durations, opacities** — not geometric.

**Why a preference and not a law:**
- iOS itself doesn't enforce a 4-grid. SwiftUI lays out with constraints, not pixel snapping. Apple's own components routinely break it.

**How to apply:**
- For *new* values, default to the ladder: `0 → 2 → 4 → 8 → 10 → 12 → 14 → 16 → 18 → 20 → 24 → 28 → 32 → 36, 40, 44, 48, 56, 64, 80.
- If an off-grid value is intentional as to make an icon inside a button look perfectly centered, that's fine.


## Visual Severity ladder — healthy / attention / urgent

paprLCD has **one** color that escapes the monochrome palette — `signal`. It is the system's **Signalfarbe** in the Dieter Rams / Braun sense: a single functional accent, never decorative. It is expressed at **two intensities**, with a third "no severity" baseline.

"SpaceButton" appearance changes depending on urgency:

| Level | Treatment | Class |
|---|---|---|
| **Healthy** | 1px solid (ink) border ` border, no fill | (default — no class) |
| **Attention** | `2px solid (signal)` border, no fill | `.is-attention` |
| **Urgent** | `2px solid (signal)` + 8px left spine + optional `var(--signal-tint-soft)` fill | `.is-urgent` |

### Documented exception: 'Hero cards', no fill



## Icons

- SF Symbols only. Custom SVGs are last resort (no SF equivalent → export PDF vector to asset catalog).
- Weight matches body font weight (TBD).
- Microinteractions via `.symbolEffect`. Never hand-animate when an effect exists.

## Behaviors

### 01. Pop-up
When a button or icon is used to trigger a popover modal, actionsheet or 'dropdown' that elemet remains in its pressed state until the modal is dismissed.


---

# Design Specs

---




---
# Backlog (deferred — do not action)
---

- **Dark-mode token reconciliation.** Luis hasn't picked dark-mode colors yet. Audit may *note* drift but no fixes until colors are decided.

### Design Specs for Nav rail:

### Navigation rail
- Main nav cluster is labeled: **Home**, **Tasks**, **Spaces**, **Alerts**.
- Settings is not part of the main nav cluster. It lives with the account avatar in the bottom utility cluster.
- Main cluster and bottom utility cluster are separated by flexible space.
- Nav icons use full `var(--ink)` for contrast, not muted ink.
- The active Home button uses a dashed ink border on paper background.

---

## Change log

| Date | Change | By |
|---|---|---|
| 2026-05-11 | File created — 5 decisions locked | 🦊 Designer (Claude) on Luis sign-off |



