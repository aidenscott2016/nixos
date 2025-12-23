# Snowfall Lib to Den Migration Plan

## Overview

Incremental migration from Snowfall Lib to den (dendritic pattern) with continuous validation and rollback capability.

**Current State:**
- 53 NixOS modules + 12 home-manager modules using `aiden.modules.{name}.enable`
- 11 hosts across 3 architectures
- Multi-channel strategy (stable 25.11, unstable, unstable-pinned)
- Snowfall Lib namespace: "aiden"

**Target State:**
- Aspect-oriented dendritic structure using den + flake-parts
- `den.aspects.*` replacing `aiden.modules.*`
- `den.hosts.<system>.<hostname>` declarations
- Preserved multi-channel strategy

**Estimated Time:** 12-18 hours

**Work Sessions:**
- **Session 1 (Phases 0-5):** 6-8 hours - Infrastructure + aspect conversion
- **Session 2 (Phase 6):** 4-6 hours - Host migration (can be broken up per-host)
- **Session 3 (Phases 7-8):** 1-2 hours - Cleanup

---

## Phase 0: Pre-Migration Setup (1 commit)

### Create Migration Environment

```bash
cd /home/aiden/src/nixos
git worktree add -b den-migration ../nixos-den-migration
cd ../nixos-den-migration
```

### Add Den Dependencies

Update `flake.nix` inputs:
```nix
flake-parts.url = "github:hercules-ci/flake-parts";
flake-aspects.url = "github:vic/flake-aspects";
den.url = "github:vic/den";
import-tree.url = "github:vic/import-tree";
denful.url = "github:vic/denful";
flake-file.url = "github:vic/flake-file";
```

Keep snowfall-lib (will remove after Phase 2).

### Create Validation Script

Create `scripts/validate-migration.sh`:
```bash
#!/usr/bin/env bash
HOST=$1
nix build .#nixosConfigurations.$HOST.config.system.build.toplevel --out-link result-new
nix build /home/aiden/src/nixos#nixosConfigurations.$HOST.config.system.build.toplevel --out-link result-old
nvd diff result-old result-new
```

### Commit
```
git add flake.nix flake.lock scripts/
git commit -m "chore: add den dependencies alongside snowfall-lib"
```

### Validation
- `nix flake check` passes
- Existing builds still work

---

## Phase 1: Infrastructure Setup (1 commit)

### Create Directory Structure

```
modules/
├── dendritic.nix          # Bootstrap den
├── namespace.nix          # Create 'aiden' namespace
├── aspects/               # All aspects
│   ├── common/
│   ├── desktop/
│   └── ...
├── hosts/                 # Host definitions
│   ├── default.nix
│   ├── mike.nix
│   └── ...
└── users/                 # User aspects
    └── aiden.nix
```

### Create Bootstrap Files

**modules/dendritic.nix:**
```nix
{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.default
    inputs.den.flakeModules.default
    inputs.import-tree.flakeModules.default
  ];
}
```

**modules/namespace.nix:**
```nix
{ inputs, ... }:
{
  imports = [ inputs.denful.flakeModules.default ];

  denful.namespaces = {
    aiden = {
      dir = ./aspects;
    };
  };
}
```

### Update flake.nix

Replace outputs with dual-mode:
```nix
outputs = inputs:
  let
    snowfallFlake = inputs.snowfall-lib.mkFlake {
      # ... existing config
    };

    flakePartsFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/dendritic.nix
        ./modules/namespace.nix
      ];
      flake.modules = inputs.import-tree.import ./modules;
      systems = [ "x86_64-linux" "aarch64-linux" ];
    };
  in
    snowfallFlake // {
      nixosConfigurations = snowfallFlake.nixosConfigurations //
                           (flakePartsFlake.nixosConfigurations or {});
    };
```

### Commit
```
git commit -m "feat: add dendritic infrastructure alongside snowfall"
```

---

## Phase 2: Convert Core Aspects (4-6 commits)

### Conversion Pattern

**Key Principle:** Dendritic aspects are enabled by **including** them, NOT by `enable` options.

For each module, there are two patterns:

#### Pattern A: Simple Aspects (No Configuration Options)

**OLD (Snowfall):**
```nix
enableableModule "ssh" params {
  services.openssh.enable = true;
}
```

**NEW (Dendritic):**
```nix
# modules/aspects/ssh/composition.nix
{ den, ... }:
{
  den.aspects.ssh = {
    includes = [ /* dependencies */ ];
    nixos = ./ssh.nix;
  };
}

# modules/aspects/ssh/ssh.nix
{ config, lib, pkgs, ... }: {
  # NO enable option - just apply config directly
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };
  # ... rest of config
}
```

**Usage:** Include to enable
```nix
den.aspects.my-host = {
  includes = [ den.aspects.ssh ];  # This enables ssh
};
```

#### Pattern B: Aspects with Configuration Options

**OLD (Snowfall):**
```nix
options.aiden.modules.nvidia = {
  enable = mkEnableOption "nvidia";
  prime.intelBusId = mkOption { ... };
};
config = mkIf cfg.enable { ... };
```

**NEW (Dendritic):**
```nix
# modules/aspects/nvidia/composition.nix
{ den, ... }:
{
  den.aspects.nvidia = {
    nixos = ./nvidia.nix;
  };
}

# modules/aspects/nvidia/nvidia.nix
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.aiden.aspects.nvidia;
in
{
  options.aiden.aspects.nvidia = {
    # NO enable option
    # Only configuration options
    prime = {
      intelBusId = mkOption { type = types.str; };
      nvidiaBusId = mkOption { type = types.str; };
    };
    package = mkOption { type = types.package; };
  };

  config = {
    # NO mkIf cfg.enable - always apply when included
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      prime.sync.enable = true;
      prime.intelBusId = cfg.prime.intelBusId;
      prime.nvidiaBusId = cfg.prime.nvidiaBusId;
      package = cfg.package;
    };
  };
}
```

**Usage:**
```nix
den.aspects.my-host = {
  includes = [ den.aspects.nvidia ];  # Enable by including

  nixos = {
    # Set configuration options
    aiden.aspects.nvidia = {
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
};
```

### Batch 1: Foundation (No Dependencies)
- architecture
- locale
- gc
- cli-base

### Batch 2: Core Services
- nix
- ssh

### Example: Common Module (Critical!)

**modules/aspects/common/composition.nix:**
```nix
{ den, ... }:
{
  den.aspects.common = {
    includes = [ den.aspects.gc ];
    nixos = ./common.nix;
  };
}
```

**modules/aspects/common/common.nix:**
```nix
{ pkgs, lib, config, inputs, ... }:
with lib;
let
  cfg = config.aiden.aspects.common;
in
{
  options.aiden.aspects.common = {
    # NO enable option!
    # Only configuration options that hosts need to set
    domainName = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    publicKey = mkOption {
      type = types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIgHxgT0rlJDXl+opb7o2JSfjd5lJZ6QTRr57N0MIAyN aiden@lars";
    };
  };

  config = {
    # NO mkIf cfg.enable - always apply
    users.users.aiden = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [ cfg.publicKey ];
    };

    nix = {
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "root" "@wheel" ];
      };
    };

    programs.vim.defaultEditor = true;
    # ... rest of common config
  };
}
```

**Usage in hosts:**
```nix
den.aspects.my-host = {
  includes = [ den.aspects.common ];  # Enable by including

  nixos = {
    aiden.aspects.common = {
      domainName = "hostname.sw1a1aa.uk";
      email = "aiden@oldstreetjournal.co.uk";
    };
  };
};
```

### Commits
```
git commit -m "feat(den): convert foundation aspects (architecture, locale, gc, cli-base)"
git commit -m "feat(den): convert core service aspects (nix, ssh)"
```

### Validation
```bash
nix eval .#den.aspects.common --json
nix eval .#den.aspects.architecture --json
```

---

## Phase 2.5: Remove Snowfall Lib (1 commit)

**This happens after aspects are converted but before host migration**

### Update flake.nix

Remove snowfall-lib input:
```nix
# Remove from inputs:
# snowfall-lib = { ... };
```

Simplify outputs to use only flake-parts:
```nix
outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      ./modules/dendritic.nix
      ./modules/namespace.nix
    ];

    flake.modules = inputs.import-tree.import ./modules;
    systems = [ "x86_64-linux" "aarch64-linux" ];

    perSystem = { system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          nvidia.acceptLicense = true;
        };
        overlays = [ (import ./overlays/default.nix { inherit inputs; }) ];
      };
    };
  };
```

### Commit
```
git commit -m "chore: remove snowfall-lib after aspect conversion"
```

### Validation
```bash
nix flake check
# Verify aspects are accessible
nix eval .#den.aspects --apply 'builtins.attrNames'
```

**Note:** After this point, old host configurations in `systems/` won't build. This is expected - we'll recreate them as den hosts in Phase 6.

---

## Phase 3: Convert Infrastructure Aspects (6-8 commits)

### Batches

**Batch 3: Simple Services**
- tailscale, syncthing, avahi, pipewire, printer, scanner

**Batch 4: Hardware**
- hardware-acceleration, nvidia, geoclue, powermanagement, coreboot

**Batch 5: Media**
- jellyfin, navidrome, beets, transmission, multimedia

**Batch 6: Network Services**
- adguard, reverse-proxy, traefik, home-assistant, node-exporter

### Special Case: Router with Submodules

**modules/aspects/router/composition.nix:**
```nix
{ den, ... }:
{
  den.aspects.router = {
    includes = [
      den.aspects.router-dns
      den.aspects.router-dhcp
      den.aspects.router-firewall
      den.aspects.router-interfaces
    ];
    nixos = ./router.nix;
  };

  den.aspects.router-dns.nixos = ./dns.nix;
  den.aspects.router-dhcp.nixos = ./dhcp.nix;
  den.aspects.router-firewall.nixos = ./firewall.nix;
  den.aspects.router-interfaces.nixos = ./interfaces.nix;
}
```

### Commits
```
git commit -m "feat(den): convert simple service aspects"
git commit -m "feat(den): convert hardware aspects"
git commit -m "feat(den): convert media service aspects"
git commit -m "feat(den): convert network service aspects + router"
```

---

## Phase 4: Convert Meta-Aspects (3-4 commits)

### Desktop Meta-Aspect

**modules/aspects/desktop/composition.nix:**
```nix
{ den, ... }:
{
  den.aspects.desktop = {
    includes = with den.aspects; [
      syncthing redshift darkman printer emacs thunar
      locale keyd powermanagement yubikey appimage pipewire
      ssh avahi common multimedia hardware-acceleration
      ios cli-base
    ];

    nixos = ./desktop.nix;
    homeManager = ./desktop-home.nix;
  };
}
```

### Gaming Meta-Aspect

**modules/aspects/desktop/desktop.nix:**
```nix
{ config, lib, pkgs, ... }: {
  # NO enable option - enabled by including aspect

  # Desktop services
  programs.nm-applet.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  networking.networkmanager.enable = true;

  # ... rest of desktop config
}
```

**Key:** All included aspects (syncthing, redshift, etc.) are automatically applied!

### Gaming Meta-Aspect

**modules/aspects/gaming/composition.nix:**
```nix
{ den, ... }:
{
  den.aspects.gaming = {
    includes = with den.aspects; [
      steam oblivion-sync openttd
    ];
    nixos = ./gaming.nix;
  };
}
```

**modules/aspects/gaming/gaming.nix:**
```nix
{ config, lib, pkgs, ... }: {
  # NO enable option

  # Gaming-specific config if needed
  programs.gamemode.enable = true;
  # ... other gaming settings
}
```

### Commits
```
git commit -m "feat(den): convert desktop meta-aspect"
git commit -m "feat(den): convert gaming meta-aspect"
git commit -m "feat(den): convert dev aspects (virtualisation, android, etc)"
```

---

## Phase 5: Convert Home-Manager Aspects (2-3 commits)

### Pattern

**modules/aspects/bash/composition.nix:**
```nix
{ den, ... }:
{
  den.aspects.bash = {
    homeManager = ./bash-home.nix;
  };
}
```

### Modules
- bash, darkman, desktop, easyeffects
- firefox, git, gpg-agent, ideavim
- ssh, tmux, vim, xdg-portal

### Commits
```
git commit -m "feat(den): convert shell home-manager aspects"
git commit -m "feat(den): convert editor home-manager aspects"
git commit -m "feat(den): convert desktop home-manager aspects"
```

---

## Phase 6: Create Host Definitions (11 commits)

### Pattern

**modules/hosts/mike.nix:**
```nix
{ den, inputs, config, lib, pkgs, ... }:
{
  den.aspects.mike-host = {
    includes = with den.aspects; [
      desktop gaming nvidia virtualisation
      home-manager nix scanner
    ];

    nixos = { config, pkgs, lib, ... }: {
      imports = [
        /home/aiden/src/nixos/systems/x86_64-linux/mike/autorandr
        /home/aiden/src/nixos/systems/x86_64-linux/mike/packages.nix
        inputs.dwm.nixosModules.default
        inputs.nixos-facter-modules.nixosModules.facter
        inputs.disko.nixosModules.default
        /home/aiden/src/nixos/systems/x86_64-linux/mike/disk-configuration.nix
      ];

      facter.reportPath = /home/aiden/src/nixos/systems/x86_64-linux/mike/facter.json;

      aiden.architecture = {
        cpu = "intel";
        gpu = "nvidia";
      };

      aiden.aspects = {
        # NO .enable options - aspects enabled via includes!

        # Only set configuration options
        nvidia = {
          prime = {
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
          };
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        common = {
          domainName = "mike.sw1a1aa.uk";
          email = "aiden@oldstreetjournal.co.uk";
        };
      };

      system.stateVersion = "22.05";
    };
  };

  den.hosts.x86_64-linux.mike = {
    aspects = [ den.aspects.mike-host ];
  };
}
```

### Migration Order

1. barbie (simplest)
2. pxe
3. lovelace (validates aarch64)
4. thoth
5. tv
6. bes
7. gila (most complex)
8. desktop
9. locutus
10. mike
11. installer

### Validation Per Host

```bash
nix build .#nixosConfigurations.mike.config.system.build.toplevel
./scripts/validate-migration.sh mike
nvd diff result-old result-new  # Should show NO package changes
nix flake check
```

### Special Note: Gaming Sub-Options

Some modules like `gaming` currently have sub-enables like `gaming.steam.enable`. In dendritic:

**Option 1: Create separate aspects**
```nix
den.aspects.gaming = {
  includes = []; # Empty - just a namespace
};
den.aspects.gaming-steam.nixos = ./steam.nix;
den.aspects.gaming-oblivion-sync.nixos = ./oblivion-sync.nix;

# In host:
includes = [ den.aspects.gaming-steam den.aspects.gaming-oblivion-sync ];
```

**Option 2: Keep as configuration options**
```nix
# gaming/gaming.nix
options.aiden.aspects.gaming = {
  steam.enable = mkOption { default = false; };
  oblivionSync.enable = mkOption { default = false; };
};

config = {
  # Conditionally apply based on options
};

# In host:
includes = [ den.aspects.gaming ];
aiden.aspects.gaming.steam.enable = true;
```

**Recommendation:** Use Option 1 (separate aspects) - more aligned with dendritic philosophy.

### Commits
```
git commit -m "feat(den): migrate barbie host"
git commit -m "feat(den): migrate pxe host"
# ... one per host
```

---

## Phase 7: Final Validation & Cleanup (2-3 commits)

### Validate All Hosts

```bash
nix flake check

# Build all hosts
for host in mike locutus desktop gila bes thoth tv barbie pxe lovelace installer; do
  echo "Building $host..."
  nix build .#nixosConfigurations.$host.config.system.build.toplevel
done

# Compare each with original (if you kept result links from Phase 0)
for host in mike locutus desktop gila bes thoth tv barbie pxe lovelace; do
  echo "Validating $host..."
  nvd diff result-old-$host result-$host
done
```

All nvd diffs should show NO package changes, only structural differences.

### Remove Old Directories

```bash
rm -rf modules/nixos modules/home systems
```

### Commit
```
git commit -m "chore: remove old snowfall directories"
```

---

## Phase 8: Documentation & Finalization (1 commit)

### Update Documentation

Update `CLAUDE.md` with den architecture guide.

### Commit
```
git commit -m "docs: update CLAUDE.md with den architecture guide"
```

### Merge to Main

```bash
cd /home/aiden/src/nixos
git merge --no-ff den-migration
git branch -d den-migration
git worktree remove ../nixos-den-migration
```

---

## Multi-Channel Preservation

### Critical: Overlay Adaptation

Snowfall automatically provides `channels` to overlays. In den, we must create them manually.

**Update overlays/default.nix signature:**
```nix
# OLD (Snowfall - auto-provided):
{ channels, inputs, ... }:

# NEW (Den - we provide it):
{ inputs }:
```

**Provide channels in flake.nix perSystem:**
```nix
perSystem = { system, ... }:
let
  # Create channel instances for this system
  channels = {
    nixpkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    nixpkgs-unstable-pinned = import inputs.nixpkgs-unstable-pinned {
      inherit system;
      config.allowUnfree = true;
    };
    nixpkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  };
in
{
  _module.args.pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      nvidia.acceptLicense = true;
    };
    overlays = [
      (import ./overlays/default.nix { inherit inputs channels; })
    ];
  };
};
```

**Update overlays/default.nix:**
```nix
{ inputs, channels }:  # Add channels parameter

final: prev: {
  # Unchanged - same as before
  inherit (channels.nixpkgs-unstable) bazarr steamtinkerlaunch;
  inherit (channels.nixpkgs-unstable-pinned) navidrome paperless-ngx redis;
  intel-media-driver-stable = channels.nixpkgs-stable.intel-media-driver;
  # ... rest unchanged
}
```

This ensures aspects continue using overlayed packages without changes.

---

## Home-Manager Integration Pattern

**Critical gap:** How do home-manager aspects apply to users?

### Current Pattern (Snowfall)
```nix
# Host enables home-manager module
aiden.modules.home-manager.enable = true;

# Module creates empty config
home-manager.users.aiden = { };

# Home modules apply via Snowfall's auto-discovery
```

### New Pattern (Den)

**Option 1: Import home aspects directly in host** (Recommended for single-user systems)
```nix
den.aspects.mike-host = {
  includes = with den.aspects; [
    desktop  # NixOS aspect
  ];

  nixos = {
    # Home-manager NixOS module integration
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.aiden = {
      imports = with den.aspects; [
        # Import home-manager aspects here
        bash git vim tmux firefox
      ];

      home.stateVersion = "22.05";
    };
  };

  homeManager = {
    # Or define user home config as aspect
    # These get merged into home-manager.users.aiden
    programs.bash.enable = true;
  };
};
```

**Option 2: Use den.homes for standalone configs**
```nix
# For hosts where you manage home separately
den.homes.x86_64-linux.aiden = {
  modules = with den.aspects; [
    bash git vim tmux firefox
  ];
};

# Build with: home-manager switch --flake .#aiden
```

**Key insight:** Den doesn't auto-wire home-manager aspects to users. You must explicitly import them in `home-manager.users.aiden.imports = [ ]`.

---

## Troubleshooting Guide

### Common Failures & Solutions

#### 1. "Infinite recursion" or "Infinite recursion encountered"
**Cause:** Circular dependency between aspects

**Solution:**
```bash
# Find the cycle
nix-instantiate --eval --strict --show-trace

# Break the cycle by:
# - Removing circular includes
# - Using lib.mkDefault instead of direct references
# - Splitting aspect into smaller pieces
```

#### 2. "Attribute 'aspects' missing"
**Cause:** `import-tree` not loading aspect files, or namespace not configured

**Solution:**
```bash
# Verify import-tree is working
nix eval .#flake.modules --apply 'builtins.attrNames'

# Check namespace exists
nix eval .#denful.namespaces.aiden

# Ensure all aspect files have .nix extension
find modules/aspects -type f ! -name "*.nix"
```

#### 3. Build fails with "option ... is used but not defined"
**Cause:** Option referenced before aspect defining it is included

**Solution:**
```nix
# Ensure aspect with options is in includes BEFORE usage
den.aspects.my-host = {
  includes = [
    den.aspects.common  # Defines domainName
    den.aspects.traefik  # Uses common.domainName
  ];
};
```

#### 4. "The option ... does not exist"
**Cause:** Forgot to remove `.enable` from aspect usage

**Solution:**
```diff
- aiden.aspects.nvidia.enable = true;
+ # Remove - enabled via includes instead
```

#### 5. nvd shows package differences
**Cause:** Overlay not applied correctly or aspect config differs from module

**Solution:**
```bash
# Compare package versions
nvd diff result-old result-new | grep -A5 "Version changed"

# Check which aspect added/removed packages
nix-diff result-old result-new
```

### What to Look For in nvd Output

**Expected (OK):**
```
Closure size: 12.3 GB → 12.3 GB (no change)
Removed packages: (none)
Added packages: (none)
Version changed: (none)
```

**Warning Signs:**
```
- Closure size increased significantly (>100MB without reason)
- Packages added that shouldn't be there
- Core packages (systemd, kernel) changed versions
- Services added/removed unexpectedly
```

**Action:** If nvd shows unexpected changes, revert commit and investigate which aspect caused the difference.

---

## Import-Tree Behavior & Gotchas

### File Discovery Rules

1. **All `.nix` files** in modules/ are loaded
2. **Files starting with `_`** are ignored
3. **Load order is alphabetical** within directories
4. **Nested directories** are recursively scanned

### Potential Issues

**Issue:** Aspects loaded before dependencies
**Solution:** Use `includes = [ ]` - den resolves dependencies automatically

**Issue:** Duplicate aspect definitions
**Solution:** Only define each aspect once. Use `includes` for composition.

**Issue:** File naming conflicts
**Solution:** Use subdirectories: `modules/aspects/nginx/composition.nix` vs `modules/aspects/nginx/nginx.nix`

---

## Secrets & Agenix Integration

**No changes needed!** Agenix works the same in den as in Snowfall.

### Pattern Remains Unchanged

```nix
# In host aspect:
den.aspects.gila-host = {
  nixos = {
    imports = [
      inputs.agenix.nixosModules.default
    ];

    # Declare secrets (same as before)
    age.secrets.tailscale-authkey.file = "${inputs.self.outPath}/secrets/tailscale-authkey.age";
    age.secrets.mosquitto-password.file = "${inputs.self.outPath}/secrets/mosquitto-password.age";

    # Use secrets (same as before)
    services.tailscale.authKeyFile = config.age.secrets.tailscale-authkey.path;
  };
};
```

### secrets/secrets.nix

No changes needed - keep as-is:
```nix
let
  gila = "ssh-ed25519 AAAAC3...";
  mike = "ssh-ed25519 AAAAC3...";
in
{
  "tailscale-authkey.age".publicKeys = [ gila mike ];
  "mosquitto-password.age".publicKeys = [ gila ];
}
```

---

## Rollback Strategy

### Per-Phase Rollback
```bash
git reset --hard HEAD~1  # Undo last commit
git revert <commit-hash>  # Revert specific commit
```

### Full Rollback
```bash
cd /home/aiden/src/nixos
git worktree remove ../nixos-den-migration
# Continue using snowfall-lib
```

### Emergency Rollback (Live System)
```bash
sudo nixos-rebuild switch --flake /home/aiden/src/nixos#hostname
# Or use previous generation:
sudo nixos-rebuild --rollback switch
```

---

## Testing Strategy

### After Each Commit

1. **Eval test:** `nix eval .#nixosConfigurations.mike.config.system.path`
2. **Build test:** `nix build .#nixosConfigurations.mike.config.system.build.toplevel`
3. **Diff test:** `nvd diff old-result result`
4. **Flake check:** `nix flake check`

### Before Deployment (After Phase 8)

1. Build all hosts in worktree
2. Compare with nvd (should show NO package changes)
3. Deploy to real hardware:
   ```bash
   # Test on simplest host first
   sudo nixos-rebuild test --flake .#barbie

   # If successful, switch
   sudo nixos-rebuild switch --flake .#barbie

   # Then deploy to remaining hosts
   sudo nixos-rebuild switch --flake .#mike
   sudo nixos-rebuild switch --flake .#gila
   # ... etc
   ```

---

## Critical Files

1. **flake.nix** - Central orchestration
2. **modules/dendritic.nix** - Den bootstrap
3. **modules/aspects/common/composition.nix** - Foundation aspect
4. **modules/aspects/desktop/composition.nix** - Meta-aspect pattern
5. **modules/hosts/mike.nix** - Host conversion template
6. **overlays/default.nix** - Multi-channel preservation
7. **modules/aspects/router/composition.nix** - Submodule pattern

---

## Dependency Graph

```
common
├── gc
├── ssh (uses common.publicKey)
├── adguard (uses common.domainName)
├── traefik (uses common.domainName, common.email)
└── reverse-proxy (uses common.domainName)

architecture
└── hardware-acceleration (uses architecture.cpu/gpu)
    └── nvidia

desktop (meta)
├── [15+ sub-aspects]

router (composite)
├── dns
├── dhcp
├── firewall
└── interfaces
```

---

## Summary

**20-25 commits across 8 phases**

**Work Plan:**
- **Session 1 (Phases 0-5):** Complete aspect conversion and remove Snowfall
- **Session 2 (Phase 6):** Migrate all hosts to den.hosts
- **Session 3 (Phases 7-8):** Final validation, cleanup, and deployment

**Key Decisions:**
- Remove Snowfall after Phase 2 (hybrid approach)
- No hardware deployment until Phase 8 (build validation only)
- Delete old directories immediately (no .OLD backups)
- Continuous validation with nvd/nix-diff at each commit

**Estimated time: 12-18 hours** (can pause between sessions)

Start with Phase 0, validate thoroughly, commit frequently.
