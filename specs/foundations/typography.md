# Typography — Foundation

## Intent

Two faces. **DM Sans** for everything except utility text; **DM Mono** for utility (labels, data, buttons, captions, timestamps). Space Grotesk dropped — DM Sans handles display at 22/30/38.

## Rules

- **Semantic Font roles only.** Use `Font.hkBody`, `Font.hkData`, `Font.hkButton`, etc. — never `Font.system(size:)` or raw `Font.custom()` in Primitives.
- All semantic roles use `relativeTo:` so Dynamic Type scales the whole system.
- **Tabular numerals on data.** `Font.hkData` is already mono. Wrap any other data-aligned text with `.monospacedDigit()`.
- **Tracking is part of the role.** Mono labels get `HkType.trackingWide`, display gets `trackingTight`, eyebrows get `trackingWider`.
- Uppercase reserved for utility text (buttons, eyebrows, badges). Body and headings stay sentence case.

See `base-tokens/typography-tokens.md` for raw values and `semantic-tokens/typography.md` for the API.

## Font registration

DM Sans + DM Mono `.ttf` files live in `design-sys/fonts/`. They must be:
1. Added to the Xcode project (drag into the synchronized `houseKipper` folder).
2. Listed in `Info.plist` under `UIAppFonts`.

If `Font.hkBody` falls back to system DM Sans equivalent, registration is missing.
