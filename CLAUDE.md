# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS flake configuration repository using the **dendritic pattern** (flake-parts + import-tree) for organization. It manages multiple machines, services, and modular NixOS configurations across different architectures.

## Key Architecture

### Flake Structure
- Uses `flake-parts` (`inputs.flake-parts.lib.mkFlake`) with `import-tree` for automatic module discovery
- Every `.nix` file under `modules/` is a flake-parts module (files/dirs prefixed with `_` are ignored by import-tree)
- Multiple nixpkgs channels: stable (25.11) and unstable
- Integrates home-manager, disko, agenix, and various specialized inputs

### Module System (Dendritic Pattern)
- No `aiden.modules.<name>.enable` gating -- features are composed via `imports` at the host level
- Each module file exposes `flake.modules.nixos.<name>` and/or `flake.modules.homeManager.<name>`
- Cross-cutting modules (darkman, ssh) define both NixOS and HM sides in the same file
- Grouping modules (desktop, gaming, router) use the **Inheritance Aspect** pattern: they `imports` their sub-features automatically

### Module File Pattern
```nix
{ ... }:            # flake-parts module (add `inputs` only if body references inputs.*)
{
  flake.modules.nixos.mymodule =
    { lib, pkgs, config, ... }:  # NixOS module
    {
      # NixOS config here
    };
}
```

### Host Categories
- **Servers**: gila (router/home-assistant/traefik), bes (containers/reverse-proxy), lovelace (aarch64 SD image)
- **Desktops**: mike (stable, dwm, gaming), desktop (unstable, jovian, gaming)
- **Special**: barbie (GPD Pocket 3, Plasma 6), installer (ISO)

### Directory Structure
- `modules/` - All flake-parts modules (auto-discovered by import-tree)
  - `modules/hosts/<hostname>/default.nix` - Per-machine nixosSystem calls
  - `modules/router/` - Router sub-modules (dhcp, dns, firewall, interfaces, zeroconf)
  - `modules/beetcamp/` - Custom beetcamp package
  - `modules/<name>.nix` - Individual NixOS/HM feature modules
- `secrets/` - Age-encrypted secrets with `secrets.nix` defining access

## Common Development Commands

### Building and Switching
```bash
# Build a specific system
nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel

# Deploy remotely (always use FQDN so the correct SSH key is matched)
nixos-rebuild switch --flake .#{hostname} --target-host aiden@{hostname}.sw1a1aa.uk --use-remote-sudo

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
1. Create `modules/<name>.nix` (or `modules/<name>/default.nix` if companion files are needed)
2. Expose it as `flake.modules.nixos.<name>` or `flake.modules.homeManager.<name>`
3. No enable gate needed -- hosts import exactly the modules they want
4. Add `inputs` to outer function args only if the module body references `inputs.*`

### Host Configuration
Each host at `modules/hosts/<hostname>/default.nix` calls `nixosSystem` directly:
```nix
{ inputs, config, ... }:
{
  flake.nixosConfigurations.myhostname = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      ./_hardware-configuration.nix
      inputs.disko.nixosModules.disko
    ] ++ (with config.flake.modules.nixos; [
      common desktop gaming nix home-manager
    ]) ++ [
      { system.stateVersion = "25.11"; }
    ];
  };
}
```

Companion files (hardware-configuration, disk config, packages) are prefixed with `_` so import-tree ignores them.

### Secrets Integration
1. Add public keys to `secrets/secrets.nix`
2. Reference secrets via `config.age.secrets.{name}.path`
3. Declare secrets in host config: `age.secrets.{name}.file = "${inputs.self.outPath}/secrets/{file}.age"`

## Workflow Rules

- All work must happen on a feature branch, never directly on master. Before creating a new branch, check whether you are already on a feature branch.
- Commit regularly as you make progress.
- Never push to or merge into master without explicit permission from the user.
- Never deploy (`nixos-rebuild switch`, `nixos-rebuild boot`, etc.) to any host without explicit permission from the user.

## Important Configuration Details

- When SSH-ing to LAN hosts, always use the FQDN (`{hostname}.sw1a1aa.uk`) — the SSH client config only matches IPs and `*.sw1a1aa.uk`; bare hostnames won't offer the correct key
- All systems use the "aiden" user (uid 1000) configured in common module
- Default editor is vim, trusted user for nix operations
- Binary caches configured globally in flake.nix nixConfig
- GPU acceleration packages managed via `modules/overlays.nix` (pulling from unstable channel)
- Router functionality in gila host using `modules/router/` sub-modules
- HM bootstrapper in `modules/home-manager.nix` wires all `flake.modules.homeManager.*` into the aiden user
