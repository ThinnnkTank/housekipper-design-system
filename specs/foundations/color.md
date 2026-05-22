# Color — Foundation

## Intent

Monochrome palette + **one functional accent** (`signal`). Dieter Rams / Braun *Signalfarbe* discipline: signal is never decorative, only functional.

Calm, paper-warm baseline. Signal earns its presence by carrying meaning (attention or urgency).

## Visual severity ladder

`signal` is expressed at two intensities plus a no-severity baseline. Each level maps to a `ActionToken` and renders consistently across primitives.

| Level | Treatment | SemanticToken |
|---|---|---|
| **Healthy** | 1px ink border, no fill | `ActionToken.healthy` |
| **Attention** | 2px signal border, no fill | `ActionToken.attention` |
| **Urgent** | 2px signal border + 8px left spine + optional soft signal tint fill | `ActionToken.urgent` |

Severity is a *Primitive concept* (`DsButton`, `DsCard`). Components/Patterns/Screens compose primitives — they never set severity colors directly.

## Documented exceptions

- **Hero cards** — no fill, regardless of severity.

## Dark mode

Not yet decided. See `BACKLOG.md`.
