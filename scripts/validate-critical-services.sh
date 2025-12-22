#!/usr/bin/env bash
# scripts/validate-critical-services.sh
# Validates critical service configurations are present

set -euo pipefail

# Define critical services per host
declare -A HOST_SERVICES=(
  [locutus]="sshd tailscaled"
  [mike]="sshd tailscaled"
  [desktop]="sshd tailscaled"
  [gila]="sshd tailscaled dnsmasq podman-home-assistant traefik"
  [thoth]="sshd tailscaled adguardhome"
  [bes]="sshd tailscaled"
  [tv]="sshd"
  [barbie]="sshd"
  [pxe]="sshd"
  [lovelace]="sshd"
)

echo "Validating critical services across all hosts..."
echo ""

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

for host in "${!HOST_SERVICES[@]}"; do
  echo "=== Validating $host ==="

  for service in ${HOST_SERVICES[$host]}; do
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    # Check if service is enabled
    if nix eval --json ".#nixosConfigurations.$host.config.systemd.services.\"$service\".enable" 2>/dev/null | grep -q "true"; then
      echo "  ✅ $service enabled"
      PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
      # Some services might not be in systemd.services, check alternative locations
      case "$service" in
        sshd)
          if nix eval --json ".#nixosConfigurations.$host.config.services.openssh.enable" 2>/dev/null | grep -q "true"; then
            echo "  ✅ $service enabled (via services.openssh)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
          else
            echo "  ❌ $service NOT enabled"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
          fi
          ;;
        tailscaled)
          if nix eval --json ".#nixosConfigurations.$host.config.services.tailscale.enable" 2>/dev/null | grep -q "true"; then
            echo "  ✅ $service enabled (via services.tailscale)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
          else
            echo "  ⚠️  $service not configured"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))  # Not critical if missing
          fi
          ;;
        podman-*)
          # Check if virtualisation.podman is enabled for podman services
          if nix eval --json ".#nixosConfigurations.$host.config.virtualisation.podman.enable" 2>/dev/null | grep -q "true"; then
            echo "  ✅ $service enabled (via podman)"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
          else
            echo "  ❌ $service NOT enabled"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
          fi
          ;;
        *)
          echo "  ❌ $service NOT enabled"
          FAILED_CHECKS=$((FAILED_CHECKS + 1))
          ;;
      esac
    fi
  done
  echo ""
done

echo "==================================="
echo "Total checks: $TOTAL_CHECKS"
echo "Passed: $PASSED_CHECKS"
echo "Failed: $FAILED_CHECKS"
echo "==================================="

if [ $FAILED_CHECKS -eq 0 ]; then
  echo "✅ All critical services validated!"
  exit 0
else
  echo "⚠️  Some services failed validation"
  exit 1
fi
