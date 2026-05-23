#!/usr/bin/env bash
# houseKipper Design System — Layer Violation Audit
#
# Enforces the 6-layer reach rule:
#   BaseTokens     → nothing
#   SemanticTokens → BaseTokens, Assets.xcassets
#   Primitives     → SemanticTokens
#   Components     → Primitives
#   Patterns       → Components
#   Screens        → Patterns, Components
#
# Also flags raw values that should be tokens.
# Exits 1 on any violation, 0 clean.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/houseKipper/houseKipper"

PRIMITIVES="$SRC/DesignSystem/Primitives"
COMPONENTS="$SRC/Components"
PATTERNS="$SRC/Patterns"
SCREENS="$SRC/Screens"

# Use ripgrep if available, fall back to grep -r. Different flags for each.
if command -v rg >/dev/null 2>&1; then
  USE_RG=1
else
  USE_RG=0
fi

violations=0

report() {
  local file="$1" line="$2" rule="$3" suggestion="$4"
  echo "  $file:$line  $rule  → $suggestion"
  violations=$((violations + 1))
}

scan_dir() {
  local dir="$1" pattern="$2" rule="$3" suggestion="$4"
  [[ -d "$dir" ]] || return 0
  local hits
  if [[ $USE_RG -eq 1 ]]; then
    hits=$(rg --no-heading -n -g '*.swift' -e "$pattern" "$dir" 2>/dev/null || true)
  else
    hits=$(grep -rn --include='*.swift' -E "$pattern" "$dir" 2>/dev/null || true)
  fi
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    # Skip preview blocks (#Preview), tests, and instrumentation files (prefixed with _)
    case "$hit" in
      *"#Preview"*|*"Tests/"*|*"/_"*) continue ;;
    esac
    local file="${hit%%:*}"
    local rest="${hit#*:}"
    local line="${rest%%:*}"
    report "$file" "$line" "$rule" "$suggestion"
  done <<< "$hits"
}

echo "houseKipper DS audit — scanning $SRC"
echo

# ---------- Raw-value rules ----------

# Hex literals outside BaseTokens
echo "→ checking hex literals outside BaseTokens/"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS" "$SRC/DesignSystem/SemanticTokens"; do
  scan_dir "$layer" '#[0-9A-Fa-f]{6}|0x[0-9A-Fa-f]{6}' \
    "raw hex literal" \
    "move to BaseTokens/ColorTokens.swift, reference via SemanticToken"
done

# Color(hex:) outside BaseTokens — even via the extension
echo "→ checking Color(hex:) outside BaseTokens/"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS" "$SRC/DesignSystem/SemanticTokens"; do
  scan_dir "$layer" 'Color\(hex:' \
    "raw Color(hex:) initializer" \
    "use SemanticToken (BackgroundToken/TextToken/ActionToken) or asset catalog Color(\"name\")"
done

# Raw shadow values outside ShadowTokens
echo "→ checking .shadow() outside ShadowTokens.swift"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS"; do
  scan_dir "$layer" '\.shadow\(' \
    "raw shadow modifier" \
    "use ShadowToken.* via a primitive helper"
done

# Raw Animation/withAnimation outside Motion.swift
echo "→ checking raw Animation values outside Motion.swift"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS"; do
  scan_dir "$layer" '\.timingCurve\(|withAnimation\(\.|\.easeIn|\.easeOut|\.easeInOut|\.linear|\.spring' \
    "raw Animation/easing value" \
    "use Motion.quick/standard/gentle/expressive (SemanticToken)"
done

# Raw stroke widths outside BorderSemantics
echo "→ checking raw stroke widths outside BorderSemantics.swift"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS"; do
  scan_dir "$layer" 'lineWidth: [0-9]|strokeBorder.*[0-9]\.[0-9]|\.border\([^,)]+, *width: *[0-9]' \
    "raw stroke width" \
    "use Border.Width.normal/strong (SemanticToken)"
done

# Dashed strokes only allowed in DsDivider.swift
echo "→ checking dashed strokes outside DsDivider.swift"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS"; do
  while IFS= read -r hit; do
    [[ -z "$hit" ]] && continue
    case "$hit" in
      *"#Preview"*|*"Tests/"*|*"/_"*|*"DsDivider.swift"*) continue ;;
    esac
    file="${hit%%:*}"
    rest="${hit#*:}"
    line="${rest%%:*}"
    report "$file" "$line" "dashed stroke outside DsDivider" \
      "dashed lines are reserved for dividers — use DsDivider(style: .dashed)"
  done < <(
    if [[ $USE_RG -eq 1 ]]; then
      rg --no-heading -n -g '*.swift' -e 'StrokeStyle\([^)]*dash:|dash:[[:space:]]*\[' "$layer" 2>/dev/null || true
    else
      grep -rn --include='*.swift' -E 'StrokeStyle\([^)]*dash:|dash:[[:space:]]*\[' "$layer" 2>/dev/null || true
    fi
  )
done

# Color initializers outside BaseTokens
echo "→ checking Color literals outside BaseTokens/"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS"; do
  scan_dir "$layer" 'Color\(red:|Color\(hex:|Color\.(red|blue|green|yellow|orange|purple|pink|black|white|gray)' \
    "raw Color literal" \
    "use a SemanticToken (BackgroundToken/TextToken/ActionToken)"
done

# Raw font sizes outside TypographyTokens
echo "→ checking Font.system(size:) outside TypographyTokens.swift"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS" "$SRC/DesignSystem/SemanticTokens"; do
  scan_dir "$layer" 'Font\.system\(size:' \
    "raw font size" \
    "define in TypographyTokens.swift, expose via semantic Font extension"
done

# Raw numeric padding in Primitives/Components/Patterns/Screens
echo "→ checking raw numeric padding/spacing"
for layer in "$PRIMITIVES" "$COMPONENTS" "$PATTERNS" "$SCREENS"; do
  scan_dir "$layer" '\.padding\([0-9]|\.padding\(\.[a-z]+, [0-9]|cornerRadius: [0-9]|spacing: [0-9]' \
    "raw numeric layout value" \
    "use Space.* (semantic) — never SpacingToken.sXX directly in these layers"
done

# ---------- Layer-reach rules ----------

# Primitives may not import ColorToken/SpacingToken/RadiusToken/TypographyToken/InventoryToken directly
echo "→ checking Primitives don't reach BaseTokens"
scan_dir "$PRIMITIVES" '\b(ColorToken|SpacingToken|RadiusToken|TypographyToken|InventoryToken)\.' \
  "Primitive reaching BaseToken directly" \
  "use SemanticToken (Space, BackgroundToken, TextToken, ActionToken, Radius, Font, Inventory)"

# Components may not reach any *Token (must go through Primitive)
echo "→ checking Components don't touch *Token"
scan_dir "$COMPONENTS" '\b(ColorToken|SpacingToken|RadiusToken|TypographyToken|InventoryToken|BackgroundToken|TextToken|ActionToken|Inventory)\.' \
  "Component reaching tokens directly" \
  "compose Primitives; let Primitives consume tokens"

# Patterns same as Components
echo "→ checking Patterns don't touch *Token"
scan_dir "$PATTERNS" '\b(ColorToken|SpacingToken|RadiusToken|TypographyToken|InventoryToken|BackgroundToken|TextToken|ActionToken|Inventory)\.' \
  "Pattern reaching tokens directly" \
  "compose Components; let Primitives consume tokens"

# Screens same
echo "→ checking Screens don't touch *Token"
scan_dir "$SCREENS" '\b(ColorToken|SpacingToken|RadiusToken|TypographyToken|InventoryToken|BackgroundToken|TextToken|ActionToken|Inventory)\.' \
  "Screen reaching tokens directly" \
  "compose Patterns/Components"

echo
if [[ $violations -eq 0 ]]; then
  echo "✓ 0 violations. DS clean."
  exit 0
else
  echo "✗ $violations violation(s)."
  exit 1
fi
