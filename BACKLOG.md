# Design System Backlog (deferred — do not action)

- **ActionSheet (Pattern + Primitives).** Inline OR popover variants. Items use `Press.invert`. Surfaces from the dashboard's "+ ADD" affordance. Plan + spec when first surface needs it.
- **DsAvatar enhancement.** Initial implementation is letter-in-circle only. Future: integrate the user's Apple ID profile photo (`AuthorizationAppleIDProvider` / signed-in iCloud account) with letter as fallback. Maintenance assignees may also surface contact-photo or SF Symbol fallbacks. Likely adds `.photo(UIImage)` and `.symbol(String)` Mode cases alongside `.letter(Character)`. Re-evaluate when sign-in / contact-picker surfaces ship.
- **DsAddTile** Primitive. Appearance-only tile that appears at the end of `RoomsRail` / `OutdoorRail` / `SystemsRail`. Passive border + muted content. Deferred — not in current dashboard build.
- **Custom icons.** SF Symbols is the icon system. A small number of household-specific concepts (grass, tree, shed, couch, faucet) likely need custom PDF-vector additions to the asset catalog when first surfaced in a real screen. Source reference: paprLCD icon library (external — Luis-local). Re-evaluate when a screen actually needs one.
- **Dark-mode value tuning.** Initial dark values inferred from canonical paprLCD vnext. Luis flagged "they suck" — easy to revise by editing each `.colorset` Contents.json (no Swift changes needed).
- **Body weight final lock.** Currently `regular` implied — revisit after first Primitive ships and we see real text in context.
- **Space Grotesk reconsideration.** Dropped this round. Revisit if display sizes (22/30/38) feel flat with DM Sans alone.
- **Pre-commit hook for audit.sh.** Wire `./design-sys/audit.sh` into `.git/hooks/pre-commit`. Phase 1.
- **Graphify integration.** Phase 1.
