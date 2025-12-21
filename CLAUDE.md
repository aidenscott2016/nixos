# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS flake configuration repository using a **dendritic pattern** with `flake-parts`. It manages multiple machines, services, and modular NixOS configurations across different architectures.

## Key Architecture

### Flake Structure
- Uses `flake-parts` (`flake-parts.lib.mkFlake`)
- Dynamic module discovery via `import-tree` (manual collection in current `flake.nix`)
- Multiple nixpkgs channels: stable, unstable, and pinned unstable
- Integrates home-manager, disko, agenix, and various specialized inputs

### Module System
Commonly referred to as **aspects**. Each aspect in `aspects/features/` can contribute to:
- `flake.nixosModules`
- `flake.homeManagerModules`
- Per-system packages or other outputs

All custom options use the `aiden.modules.*` namespace.

### Host Categories
- **Servers**: gila (router/home-assistant), thoth, bes (containers), tv (media)
- **Desktops**: locutus, mike, desktop (with gaming, autorandr profiles)
- **Special**: barbie (likely test), pxe (network boot), installer ISO

### Directory Structure
- `aspects/features/` - Feature-centric modules (NixOS + Home Manager)
- `aspects/hosts/` - Per-machine configurations and hardware files
- `aspects/_lib.nix` - Shared helper modules, declarations, and overlays
- `lib/aiden/` - Core library functions used across modules
- `packages/` - Custom package definitions
- `secrets/` - Age-encrypted secrets
- `_archive/` - Legacy Snowfall Lib structure (archived)

## Common Development Commands

### Building and Switching
```bash
# Build a specific system
nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel

# Switch to new configuration (on target system)
sudo nixos-rebuild switch --flake .#{hostname}

# Build and switch remotely
nixos-rebuild switch --flake .#{hostname} --target-host {hostname}

# Build installer ISO
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

### Testing and Evaluation
```bash
# Check flake
nix flake check

# Show configuration for a host
nix eval .#nixosConfigurations.{hostname}.config.system.build.toplevel

# Update flake inputs
nix flake update
```

## Module Development Patterns

### Creating New Aspects
1. Create a new file in `aspects/features/{name}.nix`
2. Follow the template in `aspects/_template.nix`
3. Contribute to `flake.nixosModules.{name}` or `flake.homeManagerModules.{name}`

### Host Configuration
1. Host files are in `aspects/hosts/{hostname}/`
2. Main entry point is usually `default.nix` in that directory
3. Set `aiden.modules.common.enable = true` for base configuration

### Secrets Integration
1. Reference secrets via `config.age.secrets.{name}.path`
2. Declare secrets in host config: `age.secrets.{name}.file = "${inputs.self.outPath}/secrets/{file}.age"`

## Important Configuration Details
- All systems use the "aiden" user (uid 1000)
- `lib.aiden` provides helpers like `enabled` (sets `{ enable = true; }`)
- GPU overlays and hardware acceleration are managed in `aspects/_lib.nix`