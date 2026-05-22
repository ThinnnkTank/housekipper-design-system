# Pop-up — Pattern

**Layer:** Pattern
**Status:** behavior rule locked, implementation pending

## Rule

When a Button or Icon is used to trigger a popover, modal, action sheet, or dropdown, **the triggering element remains in its pressed state until the modal is dismissed.**

Applies to all Primitives that present popovers/sheets. Implementations must hold the pressed visual via `@State` bound to the presentation binding.

## Why

Maintains spatial relationship between trigger and panel. Reduces ADHD cognitive load — the user always knows what opened the thing in front of them.
