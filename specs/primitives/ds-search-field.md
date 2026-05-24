# DsSearchField — Primitive

**Layer:** Primitive
**Status:** 🟡 Implemented (2026-05-23) — pending iPad vetting, locks after Luis sign-off
**Implementation:** `houseKipper/houseKipper/DesignSystem/Primitives/DsSearchField.swift`

## Overview

Standard search input — text field with a left `magnifyingglass` icon and an inline clear button (`xmark.circle.fill`) that appears when text is non-empty. Used wherever a free-text search affordance is needed.

**Specialization, not generalization.** This is intentionally a search-only Primitive rather than a generic `DsInput` with a `.search` variant. Other input types (plain text, number, multiline) will land as their own Primitives or as a unified `DsInput` later if patterns repeat — premature abstraction would lock decisions before we see real use cases.

**When to use:** any "type to filter / lookup" affordance.
**When NOT to use:** plain text input (use future `DsInput`). Number / numeric stepper (TBD). Multiline notes (TBD). Tag entry / chip input (TBD).

## Anatomy

```
DsSearchField
└── HStack(spacing: Space.tight)
    ├── Image(systemName: "magnifyingglass")
    │   ├── .font(.hkButtonLg)                          14pt DM Mono Medium anchor (utility face)
    │   ├── .fontWeight(IconWeight.action)              bold for visual presence
    │   └── .foregroundStyle(TextToken.secondary)       ink60 — visible but not loud
    ├── TextField(placeholder, text: $text)
    │   ├── .font(.hkButtonLg)                          14pt DM Mono Medium — utility text family
    │   ├── .foregroundStyle(TextToken.primary)         text
    │   └── (placeholder rendered in ink40 by SwiftUI default)
    └── if !text.isEmpty {
            Button { text = "" } label:
                Image(systemName: "xmark.circle.fill")
                    .font(.hkButtonLg)
                    .foregroundStyle(TextToken.muted)   ink40 — subtle, not alarming
        }
    Padding: .horizontal Space.bodyPadding (16pt)
    Frame height: Space.buttonHeightLg (40pt)
    Background: Capsule shape via RoundedRectangle(Radius.md) fill BackgroundToken.secondary (paper2)
    Border:     RoundedRectangle(Radius.md) strokeBorder Border.Color.normal Border.Width.normal (1pt ink)
```

## Public API

```swift
struct DsSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
}
```

Argument order: `text, [placeholder]`.

Caller wires `.onSubmit { }`, `.onChange(of: text) { }`, etc. via standard SwiftUI modifiers — the Primitive doesn't impose a submit handler.

## States

| State | Trigger | Visual |
|---|---|---|
| Rest (empty) | `text.isEmpty` | Icon + placeholder visible. No clear button. |
| With text | `!text.isEmpty` | Icon + text + clear button visible. |
| Focused | iOS keyboard up | **No visual change.** Keyboard presence is the focus indicator — recoloring the border to signal focus would compete with the severity system (signal is reserved). |

No `.disabled` state in v1 — defer until a real use case appears.

## Keyboard dismissal — caller's responsibility

The Primitive owns the keyboard's **Return-key affordance** (`.submitLabel(.search)` — the keyboard shows a "Search" key instead of "Return"). That's the iOS-typical behavior every search field should have.

It does NOT own **dismissal-on-scroll** or **dismissal-on-tap-outside**, because both depend on the container the search field lives in. Caller must wire these explicitly. Standard recipe for any screen containing a `DsSearchField`:

```swift
ScrollView {
    // ... content including DsSearchField ...
}
.scrollDismissesKeyboard(.interactively)   // drag-to-scroll dismisses
.onTapGesture { dismissKeyboard() }        // tap outside dismisses
// optional, screen-dependent:
.ignoresSafeArea(.keyboard, edges: .bottom)
// where:
private func dismissKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil, from: nil, for: nil
    )
}
```

If the container isn't a `ScrollView`, omit the scroll modifier. The tap-gesture pattern stands.

**`.ignoresSafeArea(.keyboard)` — screen-context choice:**

| Screen type | Setting | Why |
|---|---|---|
| Real form (filling fields) | Leave default (keyboard avoidance ON) | SwiftUI auto-scrolls focused field above the keyboard — user can see what they're typing |
| Demo / filter / search-as-you-go | Add `.ignoresSafeArea(.keyboard, edges: .bottom)` | No auto-lift. User dismisses via tap/scroll/Search key. Avoids the iPad floating-keyboard whitespace artifact (SwiftUI lifts content even when the floating keyboard takes no screen space) |

**Testable criteria** any screen with a `DsSearchField` must pass:

1. Tap field → keyboard appears, cursor in field
2. Type → text appears
3. Tap blank area outside the field → keyboard dismisses, text retained
4. Drag-scroll (if inside ScrollView) → keyboard dismisses
5. Tap "Search" key on keyboard → keyboard dismisses

`_Swatches.swift` is the reference implementation of all five.

## SemanticTokens used

`BackgroundToken.secondary` (paper2 fill) · `Border.Color.normal` · `Border.Width.normal` · `Radius.md` · `Space.bodyPadding` · `Space.tight` · `Space.buttonHeightLg` · `TextToken.primary` / `.secondary` / `.muted` · `Font.hkButtonLg` (reused — DM Mono Medium 14pt, the same role DsButton large uses; same face/size, different consumer) · `IconWeight.action`

No new tokens introduced.

## Example

```swift
@State private var query = ""

DsSearchField(text: $query, placeholder: "Search rooms")
    .onSubmit { runSearch(query) }
```

## Cross-references

- Uses: `BackgroundToken`, `Border`, `Radius`, `Space`, `TextToken`, `Font`, `IconWeight`
- Used by: `TopBar` Component (TBD), `ActionCard` Component (TBD — backlog)
- Sibling: future `DsInput` (TBD) — may absorb DsSearchField or stay parallel

## Decisions log (this spec)

- **Search-specific Primitive** (Luis 2026-05-23): "basically an input field with search icon left." Ship now; generalize later if other input types share enough structure to warrant a unified `DsInput`.
- **No visual focus state** (2026-05-23): keyboard appearance signals focus; coloring the border would either be inert (ink → ink) or compete with severity (ink → signal). Quiet is better.
- **Inline clear button** (2026-05-23): standard iOS search affordance. `xmark.circle.fill` at `TextToken.muted` keeps it subtle.
- **paper2 fill + 1pt ink border** (2026-05-23): differentiates the input area from paper background (fill) while signaling "this is interactive" (border). Quieter than `DsButton`, which uses border for primary affordance.
- **40pt height** (2026-05-23): matches `Space.buttonHeightLg` — search and the primary button feel like the same affordance family.
- **`Radius.md` (12pt) corners** (2026-05-23): iOS-native search field feel without being fully capsule. Future `DsInput` variants will likely share this radius.
- **ActionCard deferred** (Luis 2026-05-23): the "+ add an item" card that often pairs with search lives in BACKLOG.
- **Font: DM Mono Medium 14pt** (Luis 2026-05-24): iter 1 used `Font.hkBody` (DM Sans Regular) — wrong family. Search/input is utility text, mono fits the vnext pattern (data, labels, buttons all use mono). Reusing `Font.hkButtonLg` (DM Mono Medium 14pt) — same face/size as DsButton large; just applied to an input context. No new token role introduced.
- **Keyboard dismissal NOT in the Primitive** (Luis 2026-05-24): iter 1 shipped a bare `TextField` with no submit label and no dismissal recipe — keyboard wouldn't dismiss on outside tap, which broke basic iOS expectations. Iter 2: Primitive adds `.submitLabel(.search)`; callers wire `.scrollDismissesKeyboard(.interactively)` + tap-to-dismiss via the `dismissKeyboard()` UIResponder bridge. The Primitive can't own tap-outside because it doesn't know the container; the spec documents the standard recipe so every screen using DsSearchField follows the same pattern.
