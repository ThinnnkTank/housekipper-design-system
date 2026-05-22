# Border — Foundation

## Intent

Borders carry the depth that paprLCD chose not to express in shadows. Three roles:

- **Default** — soft separator (`rule`, 1pt)
- **Strong** — emphasis (`ruleStrong`, 1.5pt)
- **Affordance** — "this is interactive" (`ink`, 2pt)

## Rules

- Solid by default. Dashed reserved for special "warmth" dividers (e.g. active nav rail).
- Never communicate state by border color alone — pair with structure (spine, fill) for accessibility. See `accessibility.md`.
- Signal borders are reserved for `StatusToken` severity (attention/urgent) — never for ordinary interactive affordances. `ActionToken.urgent` is the one button variant that gets a signal border.
- Use `Border.default/strong/affordance` (semantic), never raw `lineWidth:`.

See `base-tokens/border-tokens.md` for raw width values and `semantic-tokens/border.md` for the runtime API.
