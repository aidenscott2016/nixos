#!/usr/bin/env bash
# Setup git worktrees and apply patches for baseline comparison

set -euo pipefail

SNOWFALL_COMMIT="fb6f7b7af43c9ff1be8e06192e173fa23aab2ce4"
SNOWFALL_WORKTREE="/tmp/nixos-snowfall"

echo "========================================="
echo "Setting up Snowfall Baseline Worktree"
echo "========================================="
echo "Commit: $SNOWFALL_COMMIT"
echo "Location: $SNOWFALL_WORKTREE"
echo ""

# Remove existing worktree if present
if [ -d "$SNOWFALL_WORKTREE" ]; then
  echo "Removing existing worktree..."
  git worktree remove "$SNOWFALL_WORKTREE" -f || true
fi

# Create new worktree
echo "Creating worktree at $SNOWFALL_COMMIT..."
git worktree add "$SNOWFALL_WORKTREE" "$SNOWFALL_COMMIT"

echo ""
echo "Applying compatibility patches..."

# Patch 1: Fix beets pluginOverrides
echo "  1. Fixing beets pluginOverrides..."
sed -i 's/environment.systemPackages = \[ beet-override \];/# Temporarily disabled for baseline comparison\n    # environment.systemPackages = [ beet-override ];\n    environment.systemPackages = [ pkgs.beets ];/' \
  "$SNOWFALL_WORKTREE/modules/nixos/beets/default.nix"

# Patch 2: Remove deprecated amdvlk config
echo "  2. Removing deprecated amdvlk config..."
# Remove the amdvlk package reference from extraPackages
sed -i 's/++ optionals (architecture.gpu == "amd") \[ amdvlk \]/# amdvlk removed - RADV is the default driver/' \
  "$SNOWFALL_WORKTREE/modules/nixos/hardware-acceleration/default.nix"
# Remove the entire amdvlk sub-block (lines with "amdvlk = {" through its closing "};")
sed -i '/amdvlk = {/,/};/d' \
  "$SNOWFALL_WORKTREE/modules/nixos/hardware-acceleration/default.nix"

# Patch 3: Fix AdGuard configuration for thoth
echo "  3. Fixing AdGuard config (deprecated options)..."
sed -i 's/settings.bind_host = "0.0.0.0";/host = "0.0.0.0";/' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/thoth/default.nix"
sed -i 's/settings.bind_port = 8081;/port = 8081;/' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/thoth/default.nix"
sed -i 's/querylog.enable = false;/# querylog.enable = false;  # Removed deprecated option/' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/thoth/default.nix"
# Fix firewall port reference
sed -i 's/config.services.adguardhome.settings.bind_port/config.services.adguardhome.port/' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/thoth/default.nix"

# Patch 4: Fix typo in tv config
echo "  4. Fixing typo in tv config (enable -> enabled)..."
sed -i 's/gc = enable;/gc = enabled;/' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/tv/default.nix"

# Patch 5: Remove deprecated opengl.driSupport from tv and barbie
echo "  5. Removing deprecated opengl.driSupport..."
sed -i '/driSupport = true;/d' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/tv/default.nix"
sed -i '/driSupport = true;/d' \
  "$SNOWFALL_WORKTREE/systems/x86_64-linux/barbie/hardware-configuration.nix"

echo ""
echo "✅ Setup complete!"
echo "Snowfall baseline ready at: $SNOWFALL_WORKTREE"
echo ""
echo "Next steps:"
echo "  1. Run: ./scripts/compare-worktrees.sh"
echo "  2. Review reports in: /tmp/nixos-comparison/"
