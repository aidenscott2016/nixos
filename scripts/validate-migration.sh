#!/usr/bin/env bash
set -euo pipefail

MASTER_PATH="${NIXOS_MASTER:-/home/aiden/src/nixos-master}"
HOSTS="${@:-mike locutus desktop gila bes thoth tv barbie pxe lovelace}"

echo "=== Den Migration Validation ==="
echo "Comparing against: $MASTER_PATH"
echo ""

FAILED_HOSTS=""
PASSED_HOSTS=""

for HOST in $HOSTS; do
  echo "--- Validating $HOST ---"

  # Build new configuration
  if ! nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
       --out-link "result-new-$HOST" 2>/dev/null; then
    echo "FAIL: $HOST - new config doesn't build"
    FAILED_HOSTS="$FAILED_HOSTS $HOST"
    continue
  fi

  # Build old configuration (skip if host doesn't exist in master)
  if ! nix build "$MASTER_PATH#nixosConfigurations.$HOST.config.system.build.toplevel" \
       --out-link "result-old-$HOST" 2>/dev/null; then
    echo "SKIP: $HOST - not in master (new host)"
    continue
  fi

  # Compare with nvd
  echo "Comparing packages..."
  if nvd diff "result-old-$HOST" "result-new-$HOST" 2>/dev/null; then
    echo "PASS: $HOST"
    PASSED_HOSTS="$PASSED_HOSTS $HOST"
  else
    echo "DIFF: $HOST - packages differ (review above)"
    FAILED_HOSTS="$FAILED_HOSTS $HOST"
  fi
  echo ""
done

# Summary
echo "=== Summary ==="
echo "Passed:$PASSED_HOSTS"
[ -n "$FAILED_HOSTS" ] && echo "Failed/Diff:$FAILED_HOSTS"

# Cleanup
rm -f result-old-* result-new-*
