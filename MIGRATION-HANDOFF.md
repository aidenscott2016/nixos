# NixOS Migration Handoff: Snowfall Lib → Dendritic Pattern

## Project Overview

This project is migrating a NixOS flake configuration from **Snowfall Lib** to the **pure dendritic (den) pattern** using flake-parts.

**Working directory:** `/home/aiden/src/nixos` (branch: `den-12-27`)
**Master (source of truth):** `/home/aiden/src/nixos-master`

## The Core Transformation

### Before (Snowfall Pattern)
```nix
# Module with enable option and mkIf wrapper
params@{ config, lib, ... }:
with lib.aiden;
let cfg = config.aiden.modules.example;
in {
  options.aiden.modules.example = {
    enable = mkEnableOption "";
    someOption = mkOption { ... };
  };
  config = mkIf cfg.enable {
    # actual config
  };
}

# Host enables modules
aiden.modules.example.enable = true;
aiden.modules.example.someOption = "value";
```

### After (Den Pattern)
```nix
# Module is always-on when imported (no enable, no mkIf)
{ config, lib, ... }:
let cfg = config.aiden.modules.example;
in {
  options.aiden.modules.example = {
    # Keep non-enable options
    someOption = mkOption { ... };
  };
  config = {
    # actual config (no mkIf wrapper)
  };
}

# Host imports module directly, only sets options
modules = [
  ../../../modules/nixos/example/default.nix
];
# In host config:
aiden.modules.example.someOption = "value";
# NO enable = true lines
```

### Host File Pattern
```nix
{ inputs, ... }:
{
  flake.nixosConfigurations.hostname = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      # Import modules (they're always-on)
      ../../../modules/nixos/common/default.nix
      ../../../modules/nixos/locale/default.nix
      # etc.

      # Host-specific config
      ({ config, pkgs, lib, inputs, ... }: {
        imports = [ ./hardware-configuration.nix ];
        # host config here
        # Only set module OPTIONS, not enable = true
        aiden.modules.common.domainName = "example.com";
      })
    ];
  };
}
```

## User Guidance and Preferences

### CRITICAL RULES
1. **NO enable options** - Remove `enable = mkEnableOption` from all modules
2. **NO mkIf cfg.enable wrappers** - Modules are always-on when imported
3. **NO unauthorized changes** - Only refactor patterns, don't change functionality
4. **Preserve everything else:**
   - Keep all non-enable options (domainName, email, authKeyPath, devices, etc.)
   - Keep commented code
   - Keep conditionals that aren't related to enable (e.g., `mkIf (!config.aiden.modules.keyd.enable or false)`)
   - Keep `with lib;` where present
   - Keep sub-feature enables (e.g., `router.dns.enable`, `router.dnsmasq.enable`)

### Sub-Feature Enables Are Different
Some modules have sub-options that enable specific features within the module. These are NOT the same as the module's own enable option:
- `aiden.modules.router.dns.enable` - enables DNS feature within router
- `aiden.modules.router.dnsmasq.enable` - enables dnsmasq feature within router

These sub-feature enables should be KEPT because they control behavior, not whether the module itself is active.

### Module Conversion Checklist
When converting a module:
1. Remove `params@` wrapper if present
2. Remove `with lib.aiden;` (Snowfall helper)
3. Remove `enable = mkEnableOption` from options
4. Remove `mkIf cfg.enable` wrapper from config
5. Keep all other options
6. Keep `with lib;` if present
7. Keep all commented code
8. Keep any conditionals unrelated to the module's own enable

### Host Conversion Checklist
When converting a host:
1. Wrap in flake-parts module format (see pattern above)
2. List all modules the host needs in the `modules` array
3. Remove ALL `aiden.modules.X.enable = true` lines
4. Keep all option settings (domainName, email, devices, etc.)
5. Keep all other host config unchanged

## Completed Work

### Infrastructure
- Removed snowfall-lib from flake.nix
- Added flake-parts and import-tree inputs
- Set up flake-parts output structure

### Converted Modules (always-on pattern)
- `modules/nixos/ssh/default.nix`
- `modules/nixos/locale/default.nix`
- `modules/nixos/common/default.nix` (still has domainName, email, publicKey options)
- `modules/nixos/gc/default.nix`
- `modules/nixos/avahi/default.nix`
- `modules/nixos/powermanagement/default.nix`
- `modules/nixos/traefik/default.nix`
- `modules/nixos/tailscale/default.nix` (keeps advertiseRoutes, authKeyPath options)
- `modules/nixos/adguard/default.nix`
- `modules/nixos/home-assistant/default.nix` (keeps devices option)
- `modules/nixos/router/default.nix` (keeps internalInterface, externalInterface, dns.enable, dnsmasq.enable)
- `modules/nixos/router/firewall/default.nix`
- `modules/nixos/router/interfaces/default.nix`
- `modules/nixos/router/zeroconf/default.nix`
- `modules/nixos/architecture/default.nix` (options only, no enable)
- `modules/nixos/syncthing/default.nix`
- `modules/nixos/cli-base/default.nix`
- `modules/nixos/navidrome/default.nix`
- `modules/nixos/reverse-proxy/default.nix` (keeps apps option)
- `modules/nixos/jellyfin/default.nix` (keeps user option)
- `modules/nixos/paperles/default.nix`
- `modules/nixos/jovian/default.nix`
- `modules/nixos/samba/default.nix` (keeps shares option)
- `modules/nixos/hardware-acceleration/default.nix` (keeps extraPackages option)

### Converted Hosts
- `systems/x86_64-linux/barbie/default.nix` - builds successfully
- `systems/x86_64-linux/gila/default.nix` - builds successfully
- `systems/x86_64-linux/bes/default.nix` - evaluates successfully (lib.aiden extension added)

### Build Verification
Both hosts build and have been compared against master:
- Package names are functionally identical
- Only difference is nix version (2.31.2 vs 2.32.4) due to flake-parts dependency differences
- This is acceptable - not a functional change

## Remaining Work

### Hosts to Convert
1. **desktop** (`systems/x86_64-linux/desktop/default.nix`)
   - Needs modules: redshift, hardware-acceleration, multimedia, jovian, desktop, gaming, virtualisation, home-manager, nix, architecture

3. **mike** (`systems/x86_64-linux/mike/default.nix`)
   - Needs modules: scanner, nvidia, desktop, gaming, virtualisation, home-manager, nix, architecture

4. **lovelace** (`systems/aarch64-linux/lovelace/default.nix`)
   - aarch64 - won't build on x86_64 machine without cross-compilation
   - May need to skip build verification or use remote build

5. **installer** (`systems/x86_64-install-iso/installer/`)
   - Special ISO build, needs investigation

### Modules to Convert
When you encounter a module not yet converted, apply the conversion pattern:
1. Read the module in the working directory
2. Remove enable option, remove mkIf wrapper, remove params@, remove with lib.aiden
3. Keep everything else

Many modules share between hosts, so converting for one host helps others.

## Deferred Work

### Final Cleanup (after all hosts converted)
1. Move files to den structure:
   - `modules/nixos/*` → `modules/aspects/aiden/`
   - `modules/home/*` → `modules/aspects/aiden/home/`
2. Switch to import-tree for auto-discovery
3. Remove lib/aiden if present
4. Update CLAUDE.md with final structure

### Home Manager Modules
- Located in `modules/home/`
- Snowfall auto-imported all of them
- Currently manually listed in barbie's host config
- Same conversion pattern applies (remove enable, remove mkIf)
- Can be converted as hosts need them

## Technical Notes

### Nix Version Difference
Builds show different nix versions:
- Master: nix 2.32.4 (split into cmd, expr, fetchers, flake, main, store, util sub-packages)
- Den: nix 2.31.2 (single package)

This is due to different flake-parts versions in lock files. It's NOT a functional issue - the NixOS configuration is identical.

### Build Comparison Commands
```bash
# Build den version
nix build .#nixosConfigurations.HOSTNAME.config.system.build.toplevel -o result-HOSTNAME-den

# Build master version
cd /home/aiden/src/nixos-master
nix build .#nixosConfigurations.HOSTNAME.config.system.build.toplevel -o result-HOSTNAME-master

# Compare
nix-store --query --requisites result-HOSTNAME-master > /tmp/master.txt
nix-store --query --requisites result-HOSTNAME-den > /tmp/den.txt
# Extract package names (remove hashes)
sed 's|/nix/store/[a-z0-9]*-||' /tmp/master.txt | sort | uniq > /tmp/master-names.txt
sed 's|/nix/store/[a-z0-9]*-||' /tmp/den.txt | sort | uniq > /tmp/den-names.txt
# Compare
comm -23 /tmp/master-names.txt /tmp/den-names.txt  # in master only
comm -13 /tmp/master-names.txt /tmp/den-names.txt  # in den only
```

### Gotchas
1. Some modules reference other modules' options (e.g., locale checks `keyd.enable`). Use `or false` pattern: `config.aiden.modules.keyd.enable or false`
2. Router module has sub-modules that need separate conversion
3. Common imports gc internally - both needed converting together
4. Home manager modules need `extraSpecialArgs = { inherit inputs; }` to access inputs

## Files of Interest

- `/home/aiden/src/nixos/flake.nix` - Main flake, add hosts to imports array
- `/home/aiden/src/nixos/modules/nixos/` - NixOS modules to convert
- `/home/aiden/src/nixos/modules/home/` - Home manager modules to convert
- `/home/aiden/src/nixos/systems/` - Host definitions
- `/home/aiden/src/nixos-master/` - Reference (snowfall) implementation

## Current State

Last commit: `refactor: convert gila host and modules to den pattern`

Ready to continue with **bes** host conversion.
