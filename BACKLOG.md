# Design System Backlog (deferred — do not action)

- **Dark-mode value tuning.** Initial dark values inferred from canonical paprLCD vnext. Luis flagged "they suck" — easy to revise by editing each `.colorset` Contents.json (no Swift changes needed).
- **Body weight final lock.** Currently `regular` implied — revisit after first Primitive ships and we see real text in context.
- **Space Grotesk reconsideration.** Dropped this round. Revisit if display sizes (22/30/38) feel flat with DM Sans alone.
- **Pre-commit hook for audit.sh.** Wire `./design-sys/audit.sh` into `.git/hooks/pre-commit`. Phase 1.
- **Graphify integration.** Phase 1.
