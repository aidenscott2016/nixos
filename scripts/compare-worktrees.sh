#!/usr/bin/env bash
# Compare Snowfall vs Dendritic using git worktrees

set -euo pipefail

SNOWFALL_DIR="/tmp/nixos-snowfall"
DENDRITIC_DIR="/home/aiden/src/nixos"
BASELINE_OUTPUT="/tmp/nixos-baseline"
CURRENT_OUTPUT="/tmp/nixos-dendritic"
REPORT_DIR="/tmp/nixos-comparison"

REBUILD_ALL=false
if [[ "${1:-}" == "--rebuild-all" ]]; then
  REBUILD_ALL=true
fi

mkdir -p "$BASELINE_OUTPUT" "$CURRENT_OUTPUT" "$REPORT_DIR"

HOSTS=(locutus mike desktop gila thoth bes tv barbie pxe)

echo "========================================="
echo "Snowfall vs Dendritic Comparison"
echo "========================================="
echo "Snowfall worktree: $SNOWFALL_DIR"
echo "Dendritic worktree: $DENDRITIC_DIR"
if [ "$REBUILD_ALL" = true ]; then
  echo "Mode: REBUILD EVERYTHING"
else
  echo "Mode: SKIP ALREADY BUILT"
fi
echo ""

# Step 1: Build Snowfall baseline
echo "=== Step 1: Building Snowfall Baseline ==="
cd "$SNOWFALL_DIR"

for host in "${HOSTS[@]}"; do
  echo "--- $host (Snowfall) ---"
  if [ "$REBUILD_ALL" = false ] && [ -f "$BASELINE_OUTPUT/$host.storepath" ] && [ -L "$BASELINE_OUTPUT/$host" ]; then
    echo "  → Skipping (already built: $(cat $BASELINE_OUTPUT/$host.storepath))"
    continue
  fi

  nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
    --out-link "$BASELINE_OUTPUT/$host" \
    2>&1 | tee "$BASELINE_OUTPUT/$host.build.log" | tail -5

  if [ -L "$BASELINE_OUTPUT/$host" ]; then
    readlink "$BASELINE_OUTPUT/$host" > "$BASELINE_OUTPUT/$host.storepath"
    echo "  ✓ Built: $(cat $BASELINE_OUTPUT/$host.storepath)"
  else
    echo "  ❌ Failed to build $host"
  fi
done

# Step 2: Build Dendritic current
echo ""
echo "=== Step 2: Building Dendritic Current ==="
cd "$DENDRITIC_DIR"

for host in "${HOSTS[@]}"; do
  echo "--- $host (Dendritic) ---"
  if [ "$REBUILD_ALL" = false ] && [ -f "$CURRENT_OUTPUT/$host.storepath" ] && [ -L "$CURRENT_OUTPUT/$host" ]; then
    echo "  → Skipping (already built: $(cat $CURRENT_OUTPUT/$host.storepath))"
    continue
  fi

  nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
    --out-link "$CURRENT_OUTPUT/$host" \
    2>&1 | tee "$CURRENT_OUTPUT/$host.build.log" | tail -5

  if [ -L "$CURRENT_OUTPUT/$host" ]; then
    readlink "$CURRENT_OUTPUT/$host" > "$CURRENT_OUTPUT/$host.storepath"
    echo "  ✓ Built: $(cat $CURRENT_OUTPUT/$host.storepath)"
  else
    echo "  ❌ Failed to build $host"
  fi
done

# Step 3: Compare with nvd
echo ""
echo "=== Step 3: Comparing Derivations ==="

for host in "${HOSTS[@]}"; do
  echo "--- Comparing $host ---"

  if [ ! -f "$BASELINE_OUTPUT/$host.storepath" ] || [ ! -f "$CURRENT_OUTPUT/$host.storepath" ]; then
    echo "  ❌ Missing build results for $host, skipping comparison."
    continue
  fi

  BASELINE_PATH=$(cat "$BASELINE_OUTPUT/$host.storepath")
  CURRENT_PATH=$(cat "$CURRENT_OUTPUT/$host.storepath")

  if [ "$BASELINE_PATH" = "$CURRENT_PATH" ]; then
    echo "  ✅ IDENTICAL"
  else
    echo "  ⚠️  DIFFERENT"
    nix-shell -p nvd --run "nvd diff $BASELINE_OUTPUT/$host $CURRENT_OUTPUT/$host" \
      | tee "$REPORT_DIR/$host.nvd.txt" | head -30
    echo "  Full report: $REPORT_DIR/$host.nvd.txt"
  fi
  echo ""
done

echo "========================================="
echo "✅ Comparison Complete!"
echo "Reports saved to: $REPORT_DIR"
echo "========================================="
