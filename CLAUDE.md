# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS flake configuration repository using flake-parts for organization. It manages multiple machines, services, and modular NixOS configurations across different architectures.

## Key Architecture

### Flake Structure
- Uses flake-parts with namespace "narrowdivergent"
- Multiple nixpkgs channels: stable (25.05), unstable, and pinned unstable
- Integrates home-manager, disko, agenix, and various specialized inputs

### Module System
All custom modules use the `narrowdivergent.modules.*` namespace with a consistent pattern:
- `lib/narrowdivergent/default.nix` provides helper functions including `enableableModule`
- Modules follow the pattern: `options.narrowdivergent.modules.{name}.enable = mkOption`
- Common module options set via `narrowdivergent.modules.common = { ... }`

### Host Categories
- **Servers**: gila (router/home-assistant), thoth, bes (containers), tv (media)
- **Desktops**: locutus, mike, desktop (with gaming, autorandr profiles)
- **Special**: barbie (likely test), pxe (network boot), installer ISO

### Directory Structure
- `modules/nixos/` - System-level NixOS modules
- `modules/home/` - Home Manager user configurations
- `systems/{arch}/{hostname}/` - Per-machine configurations
- `overlays/default.nix` - Package overlays pulling from different channels
- `secrets/` - Age-encrypted secrets with `secrets.nix` defining access

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

### Secrets Management
```bash
# Edit secrets (requires agenix)
agenix -e secrets/{secret-name}.age

# Re-key all secrets after adding new host keys
agenix -r
```

## Module Development Patterns

### Creating New Modules
1. Follow the pattern from `lib/narrowdivergent/default.nix`
2. Use `narrowdivergent.modules.{name}` namespace for module options
3. Reference the common module pattern in `modules/nixos/common/default.nix`

### Host Configuration
1. Import hardware-configuration.nix and disko configs
2. Import required modules in the modules list
3. Set module options like `narrowdivergent.modules.common = { email = "..."; domainName = "..."; }`
4. Host-specific packages go in separate `packages.nix` when complex

### Secrets Integration
1. Add public keys to `secrets/secrets.nix`
2. Reference secrets via `config.age.secrets.{name}.path`
3. Declare secrets in host config: `age.secrets.{name}.file = "${inputs.self.outPath}/secrets/{file}.age"`

## Important Configuration Details

- All systems use the "aiden" user (uid 1000) configured in common module
- Default editor is vim, trusted user for nix operations
- Binary caches configured globally in flake.nix nixConfig
- GPU acceleration packages pulled from specific channels via overlays
- Router functionality concentrated in gila host with custom router modules