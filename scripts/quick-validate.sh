#!/usr/bin/env bash
# scripts/quick-validate.sh
# Quick validation without full baseline comparison

set -euo pipefail

HOSTS=(locutus mike desktop gila thoth bes tv barbie pxe lovelace)

echo "Quick validation of current configuration..."
echo ""

for host in "${HOSTS[@]}"; do
  echo "=== $host ==="

  # Check system builds
  if nix build ".#nixosConfigurations.$host.config.system.build.toplevel" --dry-run 2>&1 | grep -q "will be built"; then
    echo "  ✅ Builds successfully"
  else
    echo "  ❌ Build failed!"
  fi

  # Check enabled modules
  echo "  Enabled aiden modules:"
  nix eval --json ".#nixosConfigurations.$host.config.aiden.modules" 2>/dev/null | \
    jq -r 'to_entries | map(select(.value.enable == true)) | .[].key' | \
    sed 's/^/    - /' || echo "    (unable to enumerate)"

  echo ""
done

echo "✅ Quick validation complete"
