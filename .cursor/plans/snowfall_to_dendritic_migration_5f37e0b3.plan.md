---
name: Snowfall to Dendritic Migration
overview: Migrate from snowfall-lib to the dendritic pattern (flake-parts + import-tree), converting all hosts, NixOS modules, home-manager modules, overlays, packages, and lib helpers into flake-parts modules where every .nix file is a top-level module implementing a single feature across configuration classes.
todos:
  - id: scaffold-flake
    content: "Replace flake.nix: swap snowfall-lib for flake-parts + import-tree, preserve all inputs"
    status: pending
  - id: convert-hosts
    content: Convert 7 hosts to flake-parts modules, each directly calling nixosSystem with the appropriate nixpkgs input
    status: pending
  - id: migrate-lib
    content: Inline toLocalReverseProxy/mkReverseProxyAppsOption into reverse-proxy module; drop enableableModule/enabled
    status: pending
  - id: convert-nixos-modules
    content: Convert 57 NixOS modules from enableableModule pattern to flake.modules.nixos.* (drop node-exporter stub)
    status: pending
  - id: convert-hm-modules
    content: "Convert 12 HM modules: unify 4 cross-cutting (darkman, ssh, desktop, xdg-portal), standalone 8"
    status: pending
  - id: hm-bootstrapper
    content: Create home-manager bootstrapper module that auto-imports all flake.modules.homeManager.* into aiden user
    status: pending
  - id: convert-hosts-old
    content: (merged into convert-hosts above)
    status: cancelled
  - id: overlays-packages
    content: Convert overlay to flake-parts module (drop paperless-ngx/jellyfin pins); convert beetcamp to perSystem package
    status: pending
  - id: cleanup
    content: Delete old snowfall structure (lib/aiden, overlays/, systems/, modules/nixos/, modules/home/), update CLAUDE.md
    status: pending
  - id: verify-builds
    content: Build all 7 hosts, verify cross-cutting modules, confirm desktop=unstable, confirm no pinned overlays for paperless/jellyfin
    status: pending
isProject: false
---

# Snowfall-lib to Dendritic Pattern Migration

## Current State

- **Framework:** snowfall-lib (`snowfall-lib.mkFlake`)
- **7 hosts** across 3 architectures (5x x86_64-linux, 1x aarch64-linux, 1x x86_64-install-iso)
- **53 NixOS modules** under `modules/nixos/` using `aiden.modules.<name>.enable` / `enableableModule`
- **12 home-manager modules** under `modules/home/` (mostly always-on, no enable gates)
- **1 overlay** file pulling packages from unstable/pinned channels
- **1 custom package** (beetcamp)
- **lib/aiden/** with `enableableModule`, `toLocalReverseProxy`, `mkReverseProxyAppsOption`

## Target State

- **Framework:** flake-parts + import-tree
- Every `.nix` file under `modules/` is a flake-parts module
- No `aiden.modules.<name>.enable` gating -- features composed via `imports`
- Cross-cutting concerns (darkman, ssh, xdg-portal, desktop) unified into single files with both `flake.modules.nixos.`* and `flake.modules.homeManager.`*
- Hosts defined as direct `flake.nixosConfigurations.<hostname>` via `nixosSystem` calls, each passing the appropriate nixpkgs input

---

## Phase 1: Scaffold flake-parts + import-tree

Replace `flake.nix` contents. Key changes:

- Replace `snowfall-lib.mkFlake` with `flake-parts.lib.mkFlake`
- Add `flake-parts` and `import-tree` inputs; drop `snowfall-lib`
- Use `imports = [ (inputs.import-tree ./modules) ]` for auto-import
- Preserve all existing inputs (agenix, disko, home-manager, etc.)

**Multi-channel nixpkgs:** Each host module directly calls `inputs.nixpkgs.lib.nixosSystem` or `inputs.nixpkgs-unstable.lib.nixosSystem` depending on which channel it needs. No evaluator or schema required.

**Revised `flake.nix` structure:**

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # ... all other existing inputs preserved ...
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
    };
}
```

---

## Phase 2: Migrate Lib Helpers

Move `lib/aiden/default.nix` into a flake-parts module at `modules/lib.nix`:

- **Drop `enableableModule`** -- no longer needed; composition is via imports
- **Drop `enabled`** -- same reason
- **Keep `toLocalReverseProxy`** and `mkReverseProxyAppsOption**` -- expose them as `flake.lib.aiden.*` or as a shared `let` binding in the reverse-proxy module

Since `toLocalReverseProxy` and `mkReverseProxyAppsOption` are only used by `modules/nixos/reverse-proxy/`, the simplest approach is to inline them into that module's file as a `let` binding.

---

## Phase 3: Convert NixOS Modules (53 modules)

Each existing `modules/nixos/<name>/default.nix` becomes a flake-parts module at `modules/<name>.nix` (or stays at `modules/nixos/<name>.nix` -- path is arbitrary). The transformation is mechanical:

**Before (snowfall + enableableModule):**

```nix
params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "ssh" params {
  services.openssh = { enable = true; ... };
}
```

**After (dendritic):**

```nix
{ ... }: {
  flake.modules.nixos.ssh = { ... }: {
    services.openssh = { enable = true; ... };
  };
}
```

No enable option. Hosts that want SSH simply `imports = [ inputs.self.modules.nixos.ssh ]`.

### Modules with custom options that should be preserved

These modules define options beyond just `enable` that other modules read:

- **common** -- `domainName`, `email`, `publicKey` options. Convert to a flake-parts-level option or keep as NixOS module options referenced via `config`.
- **architecture** -- `aiden.architecture.cpu`, `aiden.architecture.gpu`. Keep as NixOS options.
- **reverse-proxy** -- `apps` option (list of `{name, port, proto}`). Keep; `toLocalReverseProxy` inlined.
- **router** -- extensive sub-options. Keep as-is within the NixOS module.
- **gaming** -- per-feature sub-options. Keep.
- **geoclue** -- `apps` option. Keep.
- **desktop** -- `powermanagement.enable` sub-option. Keep.

### Complete NixOS module list (53 top-level + 5 router sub-modules)

All of these get a dendritic equivalent. Organized by suggested file layout:


| #     | Current Path                                                    | Dendritic Path                                               | Notes                                        |
| ----- | --------------------------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------- |
| 1     | `modules/nixos/adguard/`                                        | `modules/adguard.nix`                                        |                                              |
| 2     | `modules/nixos/android/`                                        | `modules/android.nix`                                        |                                              |
| 3     | `modules/nixos/appimage/`                                       | `modules/appimage.nix`                                       |                                              |
| 4     | `modules/nixos/architecture/`                                   | `modules/architecture.nix`                                   | options-only module                          |
| 5     | `modules/nixos/avahi/`                                          | `modules/avahi.nix`                                          |                                              |
| 6     | `modules/nixos/barrier/`                                        | `modules/barrier.nix`                                        |                                              |
| 7     | `modules/nixos/beets/`                                          | `modules/beets.nix`                                          |                                              |
| 8     | `modules/nixos/cli-base/`                                       | `modules/cli-base.nix`                                       |                                              |
| 9     | `modules/nixos/common/`                                         | `modules/common.nix`                                         | preserves domainName/email/publicKey options |
| 10    | `modules/nixos/coreboot/`                                       | `modules/coreboot.nix`                                       |                                              |
| 11    | `modules/nixos/darkman/`                                        | `modules/darkman.nix`                                        | **unified** with HM darkman                  |
| 12    | `modules/nixos/desktop/`                                        | `modules/desktop.nix`                                        | **unified** with HM desktop                  |
| 13    | `modules/nixos/emacs/`                                          | `modules/emacs.nix`                                          |                                              |
| 14    | `modules/nixos/flatpak/`                                        | `modules/flatpak.nix`                                        |                                              |
| 15    | `modules/nixos/gaming/`                                         | `modules/gaming.nix`                                         | preserves sub-options                        |
| 16    | `modules/nixos/gc/`                                             | `modules/gc.nix`                                             |                                              |
| 17    | `modules/nixos/geoclue/`                                        | `modules/geoclue.nix`                                        | preserves apps option                        |
| 18    | `modules/nixos/hardware-acceleration/`                          | `modules/hardware-acceleration.nix`                          |                                              |
| 19    | `modules/nixos/home-assistant/`                                 | `modules/home-assistant.nix`                                 |                                              |
| 20    | `modules/nixos/home-manager/`                                   | `modules/home-manager.nix`                                   | becomes the HM bootstrapper                  |
| 21    | `modules/nixos/ios/`                                            | `modules/ios.nix`                                            |                                              |
| 22    | `modules/nixos/jellyfin/`                                       | `modules/jellyfin.nix`                                       | drop pinned overlay, use nixpkgs             |
| 23    | `modules/nixos/jovian/`                                         | `modules/jovian.nix`                                         |                                              |
| 24    | `modules/nixos/keyd/`                                           | `modules/keyd.nix`                                           |                                              |
| 25    | `modules/nixos/locale/`                                         | `modules/locale.nix`                                         |                                              |
| 26    | `modules/nixos/multimedia/`                                     | `modules/multimedia.nix`                                     |                                              |
| 27    | `modules/nixos/navidrome/`                                      | `modules/navidrome.nix`                                      |                                              |
| 28    | `modules/nixos/nix/`                                            | `modules/nix.nix`                                            |                                              |
| 29    | `modules/nixos/node-exporter/`                                  | dropped (empty stub)                                         |                                              |
| 30    | `modules/nixos/nvidia/`                                         | `modules/nvidia.nix`                                         |                                              |
| 31    | `modules/nixos/oblivion-sync/`                                  | `modules/oblivion-sync.nix`                                  |                                              |
| 32    | `modules/nixos/openttd/`                                        | `modules/openttd.nix`                                        |                                              |
| 33    | `modules/nixos/paperles/`                                       | `modules/paperless.nix`                                      | fix typo; drop pinned overlay                |
| 34    | `modules/nixos/php-docker/`                                     | `modules/php-docker.nix`                                     |                                              |
| 35    | `modules/nixos/pipewire/`                                       | `modules/pipewire.nix`                                       |                                              |
| 36    | `modules/nixos/powermanagement/`                                | `modules/powermanagement.nix`                                |                                              |
| 37    | `modules/nixos/printer/`                                        | `modules/printer.nix`                                        |                                              |
| 38    | `modules/nixos/redshift/`                                       | `modules/redshift.nix`                                       |                                              |
| 39    | `modules/nixos/reverse-proxy/`                                  | `modules/reverse-proxy.nix`                                  | inline `toLocalReverseProxy`                 |
| 40    | `modules/nixos/router/`                                         | `modules/router/` (keep subdirs)                             |                                              |
| 41-45 | `modules/nixos/router/{dhcp,dns,firewall,interfaces,zeroconf}/` | `modules/router/{dhcp,dns,firewall,interfaces,zeroconf}.nix` |                                              |
| 46    | `modules/nixos/samba/`                                          | `modules/samba.nix`                                          |                                              |
| 47    | `modules/nixos/scanner/`                                        | `modules/scanner.nix`                                        |                                              |
| 48    | `modules/nixos/scala/`                                          | `modules/scala.nix`                                          |                                              |
| 49    | `modules/nixos/ssh/`                                            | `modules/ssh.nix`                                            | **unified** with HM ssh                      |
| 50    | `modules/nixos/steam/`                                          | `modules/steam.nix`                                          |                                              |
| 51    | `modules/nixos/syncthing/`                                      | `modules/syncthing.nix`                                      |                                              |
| 52    | `modules/nixos/tailscale/`                                      | `modules/tailscale.nix`                                      |                                              |
| 53    | `modules/nixos/thunar/`                                         | `modules/thunar.nix`                                         |                                              |
| 54    | `modules/nixos/traefik/`                                        | `modules/traefik.nix`                                        |                                              |
| 55    | `modules/nixos/transmission/`                                   | `modules/transmission.nix`                                   |                                              |
| 56    | `modules/nixos/virtualisation/`                                 | `modules/virtualisation.nix`                                 |                                              |
| 57    | `modules/nixos/xdg-portal/`                                     | `modules/xdg-portal.nix`                                     | **unified** with HM xdg-portal               |
| 58    | `modules/nixos/yubikey/`                                        | `modules/yubikey.nix`                                        |                                              |


---

## Phase 4: Convert Home-Manager Modules (12 modules)

### Cross-cutting modules (unified into single files)

These currently exist as separate NixOS + HM modules with bridge wiring. In the dendritic pattern, each becomes a single file with both `flake.modules.nixos.<name>` and `flake.modules.homeManager.<name>`:

- **darkman** -- NixOS side (geoclue, xdg pathsToLink) + HM side (darkman service, xdg portal config) in one `modules/darkman.nix`
- **ssh** -- NixOS side (openssh server) + HM side (ssh client matchBlocks) in one `modules/ssh.nix`
- **desktop** -- NixOS side (X, NetworkManager, etc.) + HM side (stateVersion, xdg, Downloads symlink) in one `modules/desktop.nix`
- **xdg-portal** -- NixOS side (portal enable, pathsToLink) + HM side (portal config) in one `modules/xdg-portal.nix`

Example unified module (`modules/ssh.nix`):

```nix
{ inputs, ... }: {
  flake.modules.nixos.ssh = { ... }: {
    services.openssh = { enable = true; openFirewall = true; ... };
    users.users.aiden.openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
  };

  flake.modules.homeManager.ssh = { ... }: {
    programs.ssh = { enable = true; matchBlocks = { ... }; };
  };
}
```

### Standalone HM modules

These remain HM-only and become `flake.modules.homeManager.<name>`:


| #   | Current                     | Dendritic                    | Notes                                             |
| --- | --------------------------- | ---------------------------- | ------------------------------------------------- |
| 1   | `modules/home/bash/`        | in `modules/bash.nix`        | `flake.modules.homeManager.bash`                  |
| 2   | `modules/home/easyeffects/` | in `modules/easyeffects.nix` | `flake.modules.homeManager.easyeffects`           |
| 3   | `modules/home/firefox/`     | in `modules/firefox.nix`     | `flake.modules.homeManager.firefox` + tridactylrc |
| 4   | `modules/home/git/`         | in `modules/git.nix`         | `flake.modules.homeManager.git` + gitignore       |
| 5   | `modules/home/gpg-agent/`   | in `modules/gpg-agent.nix`   | `flake.modules.homeManager.gpg-agent`             |
| 6   | `modules/home/ideavim/`     | in `modules/ideavim.nix`     | `flake.modules.homeManager.ideavim` + ideavimrc   |
| 7   | `modules/home/tmux/`        | in `modules/tmux.nix`        | `flake.modules.homeManager.tmux` + tmux.conf      |
| 8   | `modules/home/vim/`         | in `modules/vim.nix`         | `flake.modules.homeManager.vim` + vimrc           |


Files that ship config files (tridactylrc, gitignore, ideavimrc, tmux.conf, vimrc) keep them as siblings: e.g. `modules/firefox/default.nix` + `modules/firefox/tridactylrc`.

---

## Phase 5: Home-Manager Bootstrapper

The current `modules/nixos/home-manager/default.nix` wires HM into NixOS. In the dendritic pattern, a `modules/home-manager.nix` module:

```nix
{ inputs, config, ... }: {
  flake.modules.nixos.home-manager = { ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.aiden.imports =
      builtins.attrValues (config.flake.modules.homeManager or {});
  };
}
```

This auto-imports all `flake.modules.homeManager.*` into the `aiden` user. Hosts that want HM simply include `inputs.self.modules.nixos.home-manager`.

---

## Phase 7: Convert Hosts (7 hosts)

Each host becomes a flake-parts module at `modules/hosts/<hostname>.nix`. Example for `mike`:

```nix
{ inputs, config, ... }:
let
  mod = config.flake.modules.nixos;
in {
  flake.modules.nixos."nixosConfigurations/mike" = { ... }: {
    imports = [
      ./mike/hardware.nix     # facter, disko, disk-config
      inputs.disko.nixosModules.disko
      inputs.agenix.nixosModules.default
      mod.common
      mod.desktop
      mod.gaming
      mod.home-manager
      mod.nvidia
      mod.virtualisation
      mod.scanner
      mod.nix
    ];
    # host-specific inline config
    system.stateVersion = "22.05";
    # ...
  };
}
```

### Per-host migration notes

- **mike** -- desktop + gaming + nvidia + disko + facter
- **desktop** -- uses unstable nixpkgs (handled by evaluator); jovian + gaming + AI (ollama/open-webui)
- **gila** -- router + home-assistant + agenix secrets (mosquitto, cloudflare, tailscale)
- **bes** -- media server + reverse-proxy + agenix (slskd) + paperless + jellyfin (now standard nixpkgs)
- **barbie** -- minimal desktop + nixos-hardware
- **lovelace** -- aarch64 + agenix + tailscale + adguard
- **installer** -- ISO builder, minimal

---

## Phase 8: Overlays and Packages

### Overlays

Current `overlays/default.nix` uses snowfall channels API. Replace with a flake-parts module:

```nix
{ inputs, ... }: {
  flake.overlays.default = final: prev: {
    inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system})
      bazarr steamtinkerlaunch navidrome;
    # paperless-ngx and jellyfin DROPPED per constraint -- use nixpkgs versions
    inherit (inputs.nixpkgs-stable.legacyPackages.${prev.system})
      intel-media-driver-stable libva-vdpau-driver
      intel-compute-runtime-legacy1 vpl-gpu-rt intel-ocl onevpl-intel-gpu;
  };
}
```

Apply the overlay in the host evaluator's `nixpkgs.overlays`.

### Packages

`packages/beetcamp/` becomes a flake-parts `perSystem` module:

```nix
{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.beetcamp = pkgs.callPackage ./beetcamp { };
  };
}
```

---

## Phase 9: Agenix Integration

No structural change needed. Each host module that uses secrets continues to:

1. Import `inputs.agenix.nixosModules.default`
2. Declare `age.secrets.<name>.file`
3. Reference `config.age.secrets.<name>.path`

The `secrets/secrets.nix` file stays untouched.

---

## Phase 10: Cleanup

- Delete `lib/aiden/default.nix` (helpers inlined or dropped)
- Delete `overlays/default.nix` (replaced by module)
- Delete `systems/` directory tree (hosts moved to `modules/hosts/`)
- Delete old `modules/nixos/` and `modules/home/` trees (contents moved to flat `modules/`)
- Remove `snowfall-lib` input from flake
- Remove `nixpkgs-unstable-pinned` input (no longer needed after dropping pinned overlays)
- Update `CLAUDE.md` to reflect new architecture

---

## Verification Plan

### 1. Every NixOS module has a dendritic equivalent

Enumerate all 58 modules (53 top-level + 5 router sub-modules). The table in Phase 4 serves as the checklist. `node-exporter` (empty stub) is intentionally dropped. Verify by diffing: `ls modules/nixos/ | sort` vs new module list.

### 2. Every home-manager module is accounted for

12 modules total. 4 unified into cross-cutting dendritic modules (darkman, ssh, desktop, xdg-portal). 8 remain as standalone `flake.modules.homeManager.*`. Verify: `ls modules/home/ | sort` vs new module list.

### 3. Every host builds

Run for each host:

```bash
nix build .#nixosConfigurations.mike.config.system.build.toplevel
nix build .#nixosConfigurations.desktop.config.system.build.toplevel
nix build .#nixosConfigurations.gila.config.system.build.toplevel
nix build .#nixosConfigurations.bes.config.system.build.toplevel
nix build .#nixosConfigurations.barbie.config.system.build.toplevel
nix build .#nixosConfigurations.lovelace.config.system.build.toplevel
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

### 4. Cross-cutting features work without bridge wiring

Verify these files contain both `flake.modules.nixos.*` and `flake.modules.homeManager.*` in one file, with no `home-manager.users.aiden.aiden.modules.*.enable` cross-references:

- `modules/darkman.nix`
- `modules/ssh.nix`
- `modules/desktop.nix`
- `modules/xdg-portal.nix`

### 5. Desktop uses unstable, others use stable

```bash
nix eval .#nixosConfigurations.desktop.config.system.nixos.release  # should show unstable
nix eval .#nixosConfigurations.mike.config.system.nixos.release     # should show 25.11
```

### 6. Paperless-ngx and jellyfin use standard nixpkgs

Confirm no overlay entry for `paperless-ngx` or `jellyfin`. Both should resolve from the host's nixpkgs channel.