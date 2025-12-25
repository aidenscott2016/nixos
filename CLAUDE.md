# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS flake configuration using the **dendritic (den) pattern** for organization. It manages 12 machines, services, and modular NixOS configurations across different architectures.

## Key Architecture

### Flake Structure
- Uses **flake-parts** with **den** (dendritic pattern) for modular configuration
- Multiple nixpkgs channels: stable (25.11), unstable, and pinned unstable
- Integrates home-manager, disko, agenix, and various specialized inputs

### Module System (Den Pattern)
All configuration uses the `aiden.*` namespace with den's aspect-based pattern:
- `modules/dendritic.nix` - Den bootstrap configuration
- `modules/namespace.nix` - Creates the `aiden` namespace
- `modules/aspects/aiden/` - All 35 reusable aspects
- `modules/hosts/` - Per-host definitions (12 hosts)
- `modules/overlays/` - Package overlays for multi-channel support

### Aspect Pattern
Aspects are defined in `modules/aspects/aiden/*.nix` following the pattern:
```nix
{
  aiden.aspect-name.nixos = { pkgs, lib, config, ... }: {
    # NixOS configuration
  };
}
```

Meta-aspects can include other aspects:
```nix
{ aiden, ... }:
{
  aiden.desktop = {
    includes = [
      aiden.syncthing
      aiden.redshift
      aiden.printer
      # ... more aspects
    ];
    nixos = { ... }: {
      # Additional desktop config
    };
  };
}
```

### Host Pattern
Hosts are defined in `modules/hosts/*.nix` following:
```nix
{ aiden, inputs, ... }:
{
  den.hosts.<arch>.<hostname>.users.<user> = { };

  den.aspects.<hostname> = {
    includes = [
      aiden.common
      aiden.ssh
      # ... more aspects
    ];

    nixos = { pkgs, lib, config, ... }: {
      imports = [
        # hardware configs, external modules
      ];
      # host-specific configuration
    };
  };
}
```

### Host Categories
- **Servers**: gila-den (router/home-assistant), thoth-den, bes-den (containers), tv-den (media)
- **Desktops**: locutus-den, mike-den, desktop-den (with gaming, autorandr profiles)
- **Special**: barbie-den (GPD Pocket 3), pxe-den (network boot), installer-den (ISO), lovelace-den (Raspberry Pi)
- **Test**: test (demo host)

### Directory Structure
- `modules/aspects/aiden/` - 35 reusable aspects
- `modules/hosts/` - 12 per-host configuration files
- `modules/dendritic.nix` - Den bootstrap
- `modules/namespace.nix` - Namespace definitions
- `modules/overlays/` - Channel-specific package overlays
- `systems/{arch}/{hostname}/` - Hardware configs, disko, autorandr (referenced by hosts)
- `secrets/` - Age-encrypted secrets with `secrets.nix` defining access
- `packages/` - Custom package derivations

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
nix build .#nixosConfigurations.installer-den.config.system.build.isoImage
```

### Testing and Evaluation
```bash
# Check flake
nix flake check

# Show flake structure
nix flake show

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

## Aspect Development Patterns

### Creating New Aspects
1. Create file in `modules/aspects/aiden/{name}.nix`
2. Follow the aspect pattern (see above)
3. Add to git: `git add modules/aspects/aiden/{name}.nix`
4. Include in hosts via `includes = [ aiden.{name} ]`

### Creating New Hosts
1. Create file in `modules/hosts/{hostname}.nix`
2. Register host via `den.hosts.{arch}.{hostname}.users.{user} = { }`
3. Define aspect with `den.aspects.{hostname} = { includes = [...]; nixos = {...}; }`
4. Add to git: `git add modules/hosts/{hostname}.nix`
5. Test build: `nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel`

### Host Configuration Best Practices
1. Import hardware configs from `../../systems/{arch}/{hostname}/`
2. Use aspect includes for reusable functionality
3. Set aspect options via `aiden.aspects.{aspect}.option = value`
4. Some aspects use direct options: `aiden.architecture.cpu = "amd"`
5. Host-specific packages/services can be inlined in the host's nixos block

### Secrets Integration
1. Add public keys to `secrets/secrets.nix`
2. Reference secrets via `config.age.secrets.{name}.path`
3. Declare secrets in host config: `age.secrets.{name}.file = "${inputs.self.outPath}/secrets/{file}.age"`

## Important Configuration Details

- All systems use the "aiden" user (uid 1000) configured in common aspect
- Default editor is vim, trusted user for nix operations
- Binary caches configured globally in flake.nix nixConfig
- GPU acceleration packages pulled from specific channels via overlays
- Router functionality concentrated in gila-den host with custom router aspect
- allowUnfree is enabled globally in the common aspect

## Available Aspects (35)

### Foundation
- architecture, locale, gc, cli-base, nix, ssh, common

### Networking
- tailscale, avahi

### Desktop
- redshift, syncthing, powermanagement, thunar, keyd, printer, yubikey
- pipewire, appimage, ios, multimedia, hardware-acceleration
- scanner, emacs, virtualisation, nvidia, home-manager, jovian
- desktop (meta-aspect)

### Gaming
- steam, oblivion-sync, gaming (meta-aspect)

### Infrastructure
- adguard, traefik, home-assistant, router

## External Inputs in Aspects

Aspects can access flake inputs at the file level:
```nix
{ aiden, inputs, ... }:
{
  aiden.example.nixos = { ... }: {
    imports = [
      inputs.some-input.nixosModules.default
    ];
  };
}
```

## Migration Notes

This repository was migrated from Snowfall Lib to den in December 2025. All hosts now use the dendritic pattern exclusively. The migration achieved:
- 100% of hosts migrated (12/12)
- 100% of needed aspects converted (35/53 original aspects)
- Cleaner organization with aspect-based composition
- Better reusability through den's includes mechanism
