#!/usr/bin/env bash
# scripts/compare-single-host.sh
# Compares a single host between Snowfall and Dendritic

set -euo pipefail

HOST="${1:-mike}"
BASELINE_DIR="/tmp/nixos-baseline-$HOST"
CURRENT_DIR="/tmp/nixos-dendritic-$HOST"
REPORT_DIR="/tmp/nixos-comparison-$HOST"

SNOWFALL_DIR="/tmp/nixos-snowfall"
DENDRITIC_DIR="/home/aiden/src/nixos"

if [ ! -d "$SNOWFALL_DIR" ]; then
  echo "❌ Error: Snowfall worktree not found at $SNOWFALL_DIR"
  echo "Run ./scripts/setup-comparison.sh first"
  exit 1
fi

echo "========================================="
echo "Single Host Derivation Comparison"
echo "========================================="
echo "Host: $HOST"
echo "Baseline: Snowfall ($SNOWFALL_DIR)"
echo "Current: Dendritic ($DENDRITIC_DIR)"
echo ""

# Step 1: Capture Snowfall baseline
echo "Step 1: Capturing Snowfall baseline..."
mkdir -p "$BASELINE_DIR"
cd "$SNOWFALL_DIR"

echo "  Building Snowfall version of $HOST..."
nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
  --out-link "$BASELINE_DIR/$HOST" \
  2>&1 | tee "$BASELINE_DIR/$HOST.build.log"

nix derivation show \
  ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
  > "$BASELINE_DIR/$HOST.drv.json"

readlink "$BASELINE_DIR/$HOST" > "$BASELINE_DIR/$HOST.storepath"
BASELINE_PATH=$(cat "$BASELINE_DIR/$HOST.storepath")

echo "  ✅ Snowfall baseline captured: $BASELINE_PATH"
echo ""

# Step 2: Capture Dendritic current
echo "Step 2: Capturing Dendritic current..."
mkdir -p "$CURRENT_DIR"
cd "$DENDRITIC_DIR"

echo "  Building Dendritic version of $HOST..."
nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
  --out-link "$CURRENT_DIR/$HOST" \
  2>&1 | tee "$CURRENT_DIR/$HOST.build.log"

nix derivation show \
  ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
  > "$CURRENT_DIR/$HOST.drv.json"

readlink "$CURRENT_DIR/$HOST" > "$CURRENT_DIR/$HOST.storepath"
CURRENT_PATH=$(cat "$CURRENT_DIR/$HOST.storepath")

echo "  ✅ Dendritic current captured: $CURRENT_PATH"
echo ""

# Step 3: Compare
echo "Step 3: Running comparison tools..."
mkdir -p "$REPORT_DIR"

echo "  Running nix-diff..."
nix-shell -p nix-diff --run "
  nix-diff $BASELINE_PATH $CURRENT_PATH
" > "$REPORT_DIR/$HOST.nix-diff.txt" 2>&1 || true

echo "  Running nvd..."
nix-shell -p nvd --run "
  nvd diff $BASELINE_DIR/$HOST $CURRENT_DIR/$HOST
" | tee "$REPORT_DIR/$HOST.nvd.txt"

# Step 4: Summary
echo ""
echo "========================================="
echo "Comparison Summary"
echo "========================================="
echo "Baseline: $BASELINE_PATH"
echo "Current:  $CURRENT_PATH"
echo ""

if [ "$BASELINE_PATH" = "$CURRENT_PATH" ]; then
  echo "✅ IDENTICAL - Store paths match exactly!"
  echo "   No differences between Snowfall and Dendritic for $HOST"
else
  echo "⚠️  DIFFERENT - Store paths differ"
  echo ""
  echo "Reports generated:"
  echo "  📄 User-friendly: $REPORT_DIR/$HOST.nvd.txt"
  echo "  📄 Detailed:      $REPORT_DIR/$HOST.nix-diff.txt"
  echo ""
  echo "Preview of differences:"
  echo "----------------------------------------"
  head -n 50 "$REPORT_DIR/$HOST.nvd.txt"
  echo "----------------------------------------"
  echo "(See full report at $REPORT_DIR/$HOST.nvd.txt)"
fi

echo ""
echo "✅ Comparison complete!"
