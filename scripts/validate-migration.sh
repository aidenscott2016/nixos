#!/usr/bin/env bash
set -euo pipefail

HOST=$1

echo "Building new configuration for $HOST..."
nix build .#nixosConfigurations.$HOST.config.system.build.toplevel --out-link result-new

echo "Building old configuration for $HOST from master..."
nix build /home/aiden/src/nixos-master#nixosConfigurations.$HOST.config.system.build.toplevel --out-link result-old

echo "Comparing configurations..."
nvd diff result-old result-new
