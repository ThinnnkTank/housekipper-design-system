# SemanticToken — Motion

Intent-named animations.

| Token | Maps to | Use |
|---|---|---|
| `Motion.quick`      | `easeOut 120ms` | Toggle flip, press release |
| `Motion.standard`   | `easeOut 220ms` | Sheet present, default UI transition |
| `Motion.gentle`     | `easeInOut 400ms` | Severity escalation, status reveal |
| `Motion.expressive` | `easeOut 600ms` | Success confirmation, attention loop |

Usage:
```swift
withAnimation(Motion.standard) { isOn.toggle() }
```

**Source:** `SemanticTokens/Motion.swift`.
