#!/usr/bin/env bash
# scripts/capture-baseline.sh
# Captures derivation baselines from Snowfall worktree

set -euo pipefail

BASELINE_DIR="${1:-/tmp/nixos-baseline}"
SNOWFALL_DIR="${2:-/tmp/nixos-snowfall}"

if [ ! -d "$SNOWFALL_DIR" ]; then
  echo "❌ Error: Snowfall worktree not found at $SNOWFALL_DIR"
  echo "Run ./scripts/setup-comparison.sh first"
  exit 1
fi

mkdir -p "$BASELINE_DIR"

HOSTS=(locutus mike desktop gila thoth bes tv barbie pxe lovelace)

echo "Capturing baselines to $BASELINE_DIR"
echo "From Snowfall worktree: $SNOWFALL_DIR"
echo ""

cd "$SNOWFALL_DIR"

for host in "${HOSTS[@]}"; do
  echo "=== Processing $host ==="

  # Build the system
  echo "  Building toplevel derivation..."
  nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
    --out-link "$BASELINE_DIR/$host" \
    2>&1 | tee "$BASELINE_DIR/$host.build.log"

  # Capture derivation info
  echo "  Saving derivation JSON..."
  nix derivation show \
    ".#nixosConfigurations.$host.config.system.build.toplevel" \
    > "$BASELINE_DIR/$host.drv.json"

  # Capture store path
  echo "  Recording store path..."
  readlink "$BASELINE_DIR/$host" > "$BASELINE_DIR/$host.storepath"

  echo "  ✓ $host captured"
done

# Build installer ISO
echo "=== Processing installer ==="
echo "  Building ISO image..."
nix build ".#nixosConfigurations.installer.config.system.build.isoImage" \
  --out-link "$BASELINE_DIR/installer" \
  2>&1 | tee "$BASELINE_DIR/installer.build.log"

nix derivation show \
  ".#nixosConfigurations.installer.config.system.build.isoImage" \
  > "$BASELINE_DIR/installer.drv.json"

readlink "$BASELINE_DIR/installer" > "$BASELINE_DIR/installer.storepath"
echo "  ✓ installer captured"

echo ""
echo "✅ Baseline capture complete!"
echo "Stored in: $BASELINE_DIR"
