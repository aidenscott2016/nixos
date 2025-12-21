#!/usr/bin/env bash
# scripts/compare-with-baseline.sh
# Compares current derivations with captured baseline

set -euo pipefail

BASELINE_DIR="${1:-/tmp/nixos-baseline}"
CURRENT_DIR="${2:-/tmp/nixos-dendritic}"
REPORT_DIR="${3:-/tmp/nixos-comparison}"
DENDRITIC_DIR="${4:-/home/aiden/src/nixos}"

if [ ! -d "$BASELINE_DIR" ]; then
  echo "❌ Error: Baseline directory not found: $BASELINE_DIR"
  echo "Run ./scripts/capture-baseline.sh first"
  exit 1
fi

mkdir -p "$CURRENT_DIR"
mkdir -p "$REPORT_DIR"

HOSTS=(locutus mike desktop gila thoth bes tv barbie pxe lovelace)

echo "Comparing derivations..."
echo "Baseline: $BASELINE_DIR"
echo "Current:  $CURRENT_DIR"
echo "Reports:  $REPORT_DIR"
echo ""

cd "$DENDRITIC_DIR"

for host in "${HOSTS[@]}"; do
  echo "=== Processing $host ==="

  # Build current system
  echo "  Building current toplevel..."
  nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
    --out-link "$CURRENT_DIR/$host" \
    2>&1 | tee "$CURRENT_DIR/$host.build.log"

  readlink "$CURRENT_DIR/$host" > "$CURRENT_DIR/$host.storepath"

  # Compare with nix-diff
  echo "  Running nix-diff..."
  BASELINE_PATH=$(cat "$BASELINE_DIR/$host.storepath")
  CURRENT_PATH=$(cat "$CURRENT_DIR/$host.storepath")

  nix-shell -p nix-diff --run "
    nix-diff $BASELINE_PATH $CURRENT_PATH
  " > "$REPORT_DIR/$host.nix-diff.txt" 2>&1 || true

  # Compare with nvd
  echo "  Running nvd..."
  nix-shell -p nvd --run "
    nvd diff $BASELINE_DIR/$host $CURRENT_DIR/$host
  " | tee "$REPORT_DIR/$host.nvd.txt"

  # Quick summary
  if diff -q "$BASELINE_DIR/$host.storepath" "$CURRENT_DIR/$host.storepath" > /dev/null 2>&1; then
    echo "  ✅ $host - IDENTICAL store paths!"
  else
    echo "  ⚠️  $host - Different store paths (see reports)"
  fi
done

# Compare installer
echo "=== Processing installer ==="
echo "  Building current ISO..."
nix build ".#nixosConfigurations.installer.config.system.build.isoImage" \
  --out-link "$CURRENT_DIR/installer" \
  2>&1 | tee "$CURRENT_DIR/installer.build.log"

readlink "$CURRENT_DIR/installer" > "$CURRENT_DIR/installer.storepath"

echo "  Running nvd..."
nix-shell -p nvd --run "
  nvd diff $BASELINE_DIR/installer $CURRENT_DIR/installer
" | tee "$REPORT_DIR/installer.nvd.txt"

if diff -q "$BASELINE_DIR/installer.storepath" "$CURRENT_DIR/installer.storepath" > /dev/null 2>&1; then
  echo "  ✅ installer - IDENTICAL store paths!"
else
  echo "  ⚠️  installer - Different store paths (see reports)"
fi

echo ""
echo "✅ Comparison complete!"
echo "Reports stored in: $REPORT_DIR"
echo ""
echo "Review the following files for differences:"
echo "  - *.nvd.txt     - User-friendly diff (recommended)"
echo "  - *.nix-diff.txt - Detailed derivation diff"
