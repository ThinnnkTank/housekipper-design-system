# Iconography — Foundation

## Intent

SF Symbols-first. iOS-native, free Dynamic Type, free symbol effects, system-consistent.

## Rules

- **SF Symbols only.** No custom SVGs, no third-party icon libraries.
- The SF Symbols Mac app is the reference catalog when picking an icon.
- **Custom icons** (from paprLCD library at `/Users/mclovin/Projects/HomeBot/Design/icons/icon-library.html`) only as last resort when SF Symbols has no equivalent (grass, tree, shed, couch, faucet). Export as PDF vector → asset catalog.
- **Icon weight matches body font weight.** TBD until typography is locked.
- **Microinteractions via `.symbolEffect`.** Never hand-animate when a symbol effect exists. See `motion.md` once written.

## Symbol effects to use

| State | Effect |
|---|---|
| Task completed | `.symbolEffect(.bounce, value: completed)` |
| Notification arrived | `.symbolEffect(.bounce, value: notificationCount)` |
| Error / overdue | `.symbolEffect(.wiggle, value: errorTrigger)` |
| Syncing / loading | `.symbolEffect(.rotate, options: .repeating)` |
| Toggle (play ↔ pause, bell ↔ bell.slash) | `.contentTransition(.symbolEffect(.replace))` |
