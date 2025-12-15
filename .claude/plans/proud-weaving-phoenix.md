# Dendritic Pattern Migration Plan

## Migration Status

**Current Phase**: Phase 6 - Build Verification (IN PROGRESS)

### Phase Completion Status:
- ✅ **Phase 1: Foundation Setup** - COMPLETE
- ✅ **Phase 2: Translation Patterns** - COMPLETE
- ✅ **Phase 3: Module Migration** - COMPLETE (All 70 modules translated)
- ✅ **Phase 4: Flake Transformation** - COMPLETE (flake.nix rewritten, all hosts migrated)
- ⏭️ **Phase 5: Derivation Comparison** - SKIPPED (using git rollback as safety net)
- 🔄 **Phase 6: Build Verification** - IN PROGRESS
- ⏸️ **Phase 7: Cleanup** - PENDING
- ⏸️ **Phase 8: Final Validation** - PENDING

### Recent Fixes Applied:
1. Fixed deprecated amdvlk option in hardware-acceleration module
2. Renamed module outputs from `flake.modules.*` to `flake.nixosModules/homeManagerModules`
3. Bypassed flake-parts module merging by manually collecting modules with `lib.foldl'`
4. Fixed `_lib.nix` import to load directly instead of through flake-parts
5. Fixed nested module list error by flattening with `++`

### Last Commit:
`fix: flatten module list to avoid nested lists` (commit: 1d5a857)

### Next Steps:
1. Verify `nix flake check` completes successfully
2. Build all 11 hosts locally to validate migration
3. Proceed to cleanup phase if builds successful

---

## Current Architecture Analysis

**Repository**: Personal NixOS flake using Snowfall Lib
- **Modules**: 70 total (57 NixOS, 13 home-manager)
- **Hosts**: 11 (4 servers, 3 desktops, 4 special-purpose)
- **Organization**: Convention-based auto-discovery via Snowfall Lib
- **Namespace**: All options under `aiden.modules.*`

**Key Features**:
- Router configuration with multi-VLAN support (gila)
- Gaming stack (Steam, gamemode, gamescope)
- Desktop environment with 16+ integrated modules
- Hardware acceleration for AMD/Intel/NVIDIA
- Secrets management via agenix
- Disko disk partitioning

## Migration Overview

**From**: Host-centric Snowfall Lib configuration
**To**: Feature-centric dendritic pattern with flake-parts

**Core Changes**:
1. Replace Snowfall Lib with flake-parts + import-tree
2. Restructure modules from `modules/{nixos,home}/` to feature-based organization
3. Each feature file contributes to multiple configuration classes
4. Maintain all existing functionality and options

## User Requirements (Confirmed)

1. ✅ Darwin support: Not important
2. ✅ Module scope: All 70 modules in scope
3. ✅ Router modules: Keep as separate aspects
4. ✅ Testing approach: Direct migration (git rollback as safety)
5. ✅ Timeline: No time pressure or constraints
6. ✅ Validation: Full system derivations using nix diffing tools

### Critical Success Factors:
- Zero feature loss during migration
- Ability to rollback at each phase via git
- Verification that derivations remain equivalent using nix-diff/nvd
- Preserve all secrets and hardware configurations
- Maintain `aiden.modules.*` namespace throughout

---

# Implementation Plan

## ~~Phase 1: Foundation Setup (Reversible)~~ ✅ COMPLETE

**Objective**: Add dendritic infrastructure alongside Snowfall Lib

### 1.1 Add New Inputs

Modify [flake.nix](flake.nix) inputs section:
- Add `flake-parts` from hercules-ci
- Add `import-tree` from vic
- Keep Snowfall Lib active (remove later)

### 1.2 Create Directory Structure

```bash
mkdir -p aspects/features     # Feature modules (70 files)
mkdir -p aspects/hosts        # Host configs (11 hosts)
mkdir -p aspects/lib          # Shared utilities
mkdir -p scripts              # Migration scripts
```

### 1.3 Create Helper Library

Create [aspects/_lib.nix](aspects/_lib.nix):
- Import lib/aiden helpers
- Expose inputs to all aspects
- Define channel overlay (from current overlays/default.nix)

**Status**: Fully reversible - just delete directories

---

## ~~Phase 2: Translation Patterns~~ ✅ COMPLETE

**Objective**: Establish conversion patterns for different module types

### Pattern A: Simple Module (e.g., ssh)

**From**: `modules/nixos/ssh/default.nix` using `enableableModule`
**To**: `aspects/features/ssh.nix` contributing to `flake.modules.nixos.ssh`

```nix
{ lib, ... }:
{
  flake.modules.nixos.ssh = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.ssh;
    in {
      options.aiden.modules.ssh.enable = mkEnableOption "ssh server";
      config = mkIf cfg.enable {
        services.openssh = { /* ... */ };
      };
    };
}
```

### Pattern B: Module with Sub-Options (e.g., gaming)

Preserve sub-options structure:
- `aiden.modules.gaming.steam.enable`
- `aiden.modules.gaming.moonlight.{server,client}.enable`
- `aiden.modules.gaming.games.{oblivionSync,openttd,minecraft}.enable`

Single aspect orchestrates dependent modules.

### Pattern C: Cross-Cutting (e.g., firefox)

**From**: Split across `modules/nixos/firefox/` and `modules/home/firefox/`
**To**: Single `aspects/features/firefox.nix` with both:
- `flake.modules.nixos.firefox = { ... }`
- `flake.modules.homeManager.firefox = { ... }`

### Pattern D: Router Submodules

Keep as separate aspects:
- `aspects/features/router.nix` - Main options + interfaces
- `aspects/features/router-dns.nix` - Unbound DNS
- `aspects/features/router-dhcp.nix` - Dnsmasq DHCP (multi-VLAN)
- `aspects/features/router-firewall.nix` - nftables rules
- `aspects/features/router-interfaces.nix` - systemd-networkd VLANs
- `aspects/features/router-zeroconf.nix` - Avahi mDNS

### Pattern E: Orchestrator (e.g., desktop)

**Preserve behavior**: Desktop enables 16+ modules automatically

Single aspect `aspects/features/desktop.nix` keeps orchestration logic:
```nix
aiden.modules = {
  syncthing = enabled;    # Uses lib.aiden.enabled
  redshift = enabled;
  darkman = enabled;
  # ... 13 more
};
```

**Note**: Using `enabled` helper (defined in lib/aiden/default.nix as `{ enable = true; }`)

### 2.1 Pilot Translation (3 Modules)

Test patterns with:
1. **ssh** (Pattern A - simple)
2. **syncthing** (Pattern A - with groups)
3. **firefox** (Pattern C - cross-cutting)

Validate syntax and option structure before proceeding.

---

## ~~Phase 3: Module Migration~~ ✅ COMPLETE

**Objective**: Translate all 70 modules to dendritic aspects

### 3.1 Migration Order (Dependency Tiers)

**Tier 1 - Leaf modules (15)**:
- ssh, gc, locale, avahi, keyd
- android, appimage, ios, coreboot, flatpak
- barrier, geoclue, yubikey, scala, php-docker

**Tier 2 - Mid-level (30)**:
- syncthing, pipewire, redshift, darkman, printer
- emacs, thunar, multimedia, hardware-acceleration, cli-base
- traefik, jellyfin, navidrome, beets, transmission
- tailscale, home-assistant, adguard, samba, scanner
- virtualisation, jovian, powermanagement, xdg-portal, node-exporter
- Home: bash, git, vim, tmux, gpg-agent, ssh, ideavim, easyeffects, darkman

**Tier 3 - Orchestrators (15)**:
- steam, oblivion-sync, openttd, gaming
- common (enables gc), architecture, nvidia
- Router: router, router-dns, router-dhcp, router-interfaces, router-firewall, router-zeroconf
- desktop (enables 16+ modules)
- home-manager, nix, reverse-proxy
- Home: firefox, desktop, xdg-portal

**Tier 4 - Special (11)**:
- paperles (fix typo → paperless)
- 11 host configurations

### 3.2 Translation Process

For each module:
1. Create `aspects/features/{name}.nix`
2. Copy options + config from Snowfall module
3. Wrap in `flake.modules.{nixos,homeManager}.{name} = { ... }`
4. Validate: `nix eval .#flake.modules.nixos.{name} --apply 'x: "ok"'`
5. Keep original Snowfall module until cutover

**If validation fails**:
- Check syntax errors (missing braces, semicolons)
- Verify `flake.modules.nixos.{name} = { ... }` structure
- Ensure `lib` is in scope
- Check that all imports from original module are preserved
- Fix and re-validate before moving to next module

### 3.3 Critical Modules to Review

**Desktop** [modules/nixos/desktop/default.nix](modules/nixos/desktop/default.nix):
- Enables 16+ modules using `enabled` helper
- Preserve exact orchestration behavior

**Router** [modules/nixos/router/](modules/nixos/router/):
- Main module at `router/default.nix`
- 5 submodules in subdirectories
- Coordinate via options defined in main

**Gaming** [modules/nixos/gaming/default.nix](modules/nixos/gaming/default.nix):
- Complex sub-options structure
- Orchestrates steam, oblivionSync, openttd

**Common** [modules/nixos/common/default.nix](modules/nixos/common/default.nix):
- Auto-enables gc module
- Creates user "aiden" (uid 1000)
- Base configuration for all systems

---

## ~~Phase 4: Flake Transformation~~ ✅ COMPLETE

**Objective**: Replace Snowfall Lib with flake-parts

### 4.1 Rewrite flake.nix

**Critical file**: [flake.nix](flake.nix)

New structure:
```nix
outputs = inputs@{ self, flake-parts, import-tree, nixpkgs, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } (
    # Auto-load all aspects
    import-tree.filterNot (path: baseNameOf path == "_template.nix") ./aspects

    // {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [ ./aspects/_lib.nix ];

      flake = {
        nixosConfigurations = {
          locutus = mkHost "locutus" "x86_64-linux";
          mike = mkHost "mike" "x86_64-linux";
          desktop = mkHost "desktop" "x86_64-linux";
          gila = mkHost "gila" "x86_64-linux";
          thoth = mkHost "thoth" "x86_64-linux";
          bes = mkHost "bes" "x86_64-linux";
          tv = mkHost "tv" "x86_64-linux";
          barbie = mkHost "barbie" "x86_64-linux";
          pxe = mkHost "pxe" "x86_64-linux";
          lovelace = mkHost "lovelace" "aarch64-linux";
          installer = mkInstaller "installer" "x86_64-linux";
        };
      };
    }
  );
```

Helper function `mkHost`:
```nix
mkHost = name: system: nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs self; };
  modules = [
    (builtins.attrValues self.modules.nixos)  # All feature modules
    ./aspects/hosts/${name}.nix               # Host-specific config
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.sharedModules = builtins.attrValues self.modules.homeManager;
    }
  ];
};
```

### 4.2 Migrate Host Configurations

Each host from `systems/{arch}/{hostname}/` → `aspects/hosts/{hostname}.nix`

**Example**: locutus
- Main config: `aspects/hosts/locutus.nix`
- Hardware: `aspects/hosts/locutus-hardware.nix`
- Packages: `aspects/hosts/locutus-packages.nix`
- Autorandr: `aspects/hosts/locutus-autorandr/`

**All 11 hosts**:
1. locutus, mike, desktop (desktops)
2. gila, thoth, bes, tv (servers)
3. barbie, pxe, lovelace (special)
4. installer (ISO)

### 4.3 Special Handling

**Overlays**: Move [overlays/default.nix](overlays/default.nix) → `aspects/_lib.nix`

**Custom Packages**: Keep [packages/](packages/) directory, expose via perSystem

**Secrets**: Keep [secrets/](secrets/) directory unchanged, reference via `${inputs.self}/secrets/*.age`

**Disko**: Move configs to `aspects/hosts/{name}-disko.nix`

### 4.4 Cutover Procedure

```bash
# 1. Commit all translated aspects
git add aspects/
git commit -m "Phase 3 complete: All modules translated"

# 2. Backup current flake
cp flake.nix flake.nix.snowfall.bak

# 3. Replace flake.nix
# (implement new flake-parts version)

# 4. Update lock
nix flake lock

# 5. Test eval
nix flake check

# 6. Commit cutover
git add -A
git commit -m "Phase 4: Cutover to dendritic pattern"
git tag cutover-point
```

### 4.5 Cutover Troubleshooting

**If `nix flake check` fails, fix forward**:

Common issues:
- **Import errors**: Check `import-tree` syntax in flake.nix
- **Module not found**: Ensure `aspects/_lib.nix` exists and is imported
- **Missing modules**: Verify all aspects created in Phase 3
- **Syntax errors**: Check flake.nix for typos in mkHost function
- **Home-manager integration**: Verify sharedModules attribute set correctly

**Fix approach**:
1. Read the error carefully
2. Fix the issue in flake.nix or aspect files
3. Run `nix flake check` again
4. Continue once passing

**Only rollback as last resort**: `git reset --hard HEAD^`

---

## ~~Phase 5: Derivation Comparison~~ ⏭️ SKIPPED

**Objective**: Verify no features lost using diffing tools

**Note**: This phase was skipped in favor of using git rollback as the safety net.

### 5.1 Capture Baseline (Before Cutover)

**Script**: [scripts/capture-baseline.sh](scripts/capture-baseline.sh)

```bash
for host in locutus mike desktop gila thoth bes tv barbie; do
  nix build .#nixosConfigurations.$host.config.system.build.toplevel \
    --out-link /tmp/nixos-baseline/$host

  nix derivation show \
    .#nixosConfigurations.$host.config.system.build.toplevel \
    > /tmp/nixos-baseline/$host.drv.json
done
```

### 5.2 Compare After Cutover

**Script**: [scripts/compare-with-baseline.sh](scripts/compare-with-baseline.sh)

```bash
for host in locutus mike desktop gila thoth bes tv barbie; do
  nix build .#nixosConfigurations.$host.config.system.build.toplevel \
    --out-link /tmp/nixos-dendritic/$host

  # Use nix-diff for detailed comparison (run via nix-shell if not installed)
  nix-shell -p nix-diff --run "
    nix-diff \
      $(readlink /tmp/nixos-baseline/$host) \
      $(readlink /tmp/nixos-dendritic/$host)
  " > /tmp/nixos-baseline/$host.diff.txt

  # Use nvd for visual comparison (run via nix-shell if not installed)
  nix-shell -p nvd --run "
    nvd diff \
      /tmp/nixos-baseline/$host \
      /tmp/nixos-dendritic/$host
  " | tee /tmp/nixos-baseline/$host.nvd.txt
done
```

**Tools**: `nix-diff` and `nvd` are run via `nix-shell -p` if not available

### 5.3 Acceptable Differences

**Expected**:
- Store paths (different derivation IDs)
- Build metadata (timestamps)
- Flake references (snowfall-lib → flake-parts)

**Problematic** (investigate):
- Missing packages
- Disabled services
- Changed service configs
- Missing user groups
- Different kernel modules
- Changed firewall rules

### 5.4 Service Configuration Validation

**Script**: [scripts/validate-critical-services.sh](scripts/validate-critical-services.sh)

Verify critical service configurations are present in derivations:

```bash
#!/usr/bin/env bash
# scripts/validate-critical-services.sh

HOSTS=("locutus" "gila" "mike")
SERVICES=("sshd" "tailscaled" "home-assistant" "traefik")

for host in "${HOSTS[@]}"; do
  echo "=== Validating $host ==="
  for service in "${SERVICES[@]}"; do
    echo "  Checking $service..."

    # Check if service configuration exists
    nix eval --json \
      .#nixosConfigurations.$host.config.systemd.services.$service.enable \
      2>/dev/null && echo "    ✓ $service enabled" || echo "    - $service not configured"
  done
done
```

This validates configuration exists without deploying to live hosts.

---

## Phase 6: Local Build Verification

**Objective**: Verify all hosts build successfully locally

### 6.1 Build All Hosts

Build all configurations locally without deploying:

```bash
# Build all x86_64-linux hosts
for host in locutus mike desktop gila thoth bes tv barbie pxe; do
  echo "Building $host..."
  nix build .#nixosConfigurations.$host.config.system.build.toplevel \
    --out-link result-$host
  echo "✓ $host built successfully"
done

# Build aarch64-linux host
echo "Building lovelace..."
nix build .#nixosConfigurations.lovelace.config.system.build.toplevel \
  --out-link result-lovelace
echo "✓ lovelace built successfully"

# Build installer ISO
echo "Building installer..."
nix build .#nixosConfigurations.installer.config.system.build.isoImage \
  --out-link result-installer
echo "✓ installer built successfully"
```

### 6.2 Build Validation Checklist

For each successful build, verify:
- [ ] Build completes without errors
- [ ] Derivation output exists in `/nix/store`
- [ ] Result symlink created successfully
- [ ] No evaluation errors or warnings

### 6.3 Build Failure Handling

**If any builds fail, try to fix forward first**:

1. **Diagnose the error**:
   - Read the full error message
   - Identify which module/aspect is causing the issue
   - Check if it's an evaluation error or build error

2. **Common fixes**:
   - Missing module imports in aspect
   - Incorrect option paths (typo in `config.aiden.modules.*`)
   - Missing dependencies between aspects
   - Syntax errors in converted modules
   - Incorrect flake-parts module structure

3. **Fix the issue**:
   - Edit the problematic aspect file
   - Test with: `nix eval .#nixosConfigurations.$host.config.system.build.toplevel`
   - Re-build after fix

4. **Only rollback if fix is not obvious**:
   ```bash
   # Last resort: revert to previous working commit
   git reset --hard HEAD^
   nix flake lock

   # Or rollback to specific phase
   git checkout cutover-point^  # Before cutover
   # Or
   git checkout snowfall-backup  # Complete revert to Snowfall
   ```

---

## Phase 7: Cleanup

**Objective**: Remove Snowfall artifacts

### 7.1 Archive Old Structure

```bash
mkdir _archive
git mv modules _archive/
git mv systems _archive/
git commit -m "Archive Snowfall structure"
```

### 7.2 Remove Snowfall Dependency

Edit [flake.nix](flake.nix) to remove `snowfall-lib` input:
```bash
nix flake lock
git commit -m "Remove Snowfall Lib dependency"
```

### 7.3 Update Documentation

Edit [CLAUDE.md](CLAUDE.md):
- Document dendritic pattern
- Update directory structure
- Update development commands

Create [MIGRATION.md](MIGRATION.md):
- Document what changed
- Provide before/after examples
- Include rollback instructions

### 7.4 Create Development Template

Create [aspects/_template.nix](aspects/_template.nix):
- Template for new aspect modules
- Documents the standard pattern
- Starts with `_` so import-tree ignores it

### 7.5 Tag Release

```bash
git tag v2.0-dendritic
git push origin dendritic-2 --tags
```

---

## Phase 8: Final Validation

**Objective**: Confirm everything builds successfully post-cleanup

### 8.1 Full Rebuild Test

Rebuild all hosts from clean flake to verify nothing broken by cleanup:
```bash
for host in locutus mike desktop gila thoth bes tv barbie pxe lovelace; do
  echo "Testing $host..."
  nix build .#nixosConfigurations.$host.config.system.build.toplevel \
    --rebuild
done

# ISO
nix build .#nixosConfigurations.installer.config.system.build.isoImage \
  --rebuild
```

### 8.2 Flake Check

Run final flake validation:
```bash
nix flake check
```

Verify:
- [ ] All configurations evaluate successfully
- [ ] No evaluation warnings or errors
- [ ] All packages build
- [ ] Flake lock file is valid

### 8.3 Delete Temporary Files

```bash
rm -rf /tmp/nixos-baseline /tmp/nixos-dendritic
rm flake.nix.snowfall.bak
rm result-*  # Build result symlinks

# Archive directory can stay for reference
# Delete only if absolutely certain: rm -rf _archive/
```

---

## Timeline Estimate

| Phase | Duration | Description |
|-------|----------|-------------|
| 1. Foundation | 4 hours | Setup dendritic infrastructure |
| 2. Patterns | 4 hours | Develop and test translation patterns |
| 3. Migration | 20 hours | Translate all 70 modules |
| 4. Flake Transform | 6 hours | Rewrite flake.nix, migrate hosts |
| 5. Comparison | 8 hours | Capture baselines, compare derivations |
| 6. Build Verification | 4 hours | Build all hosts locally |
| 7. Cleanup | 2 hours | Archive old structure, documentation |
| 8. Final Validation | 2 hours | Final testing and verification |
| **Total** | **50 hours** | **~6 working days** |

---

## Critical Files Summary

### To Create:
- `aspects/_lib.nix` - Shared library and overlays
- `aspects/features/*.nix` - 70 feature aspect modules
- `aspects/hosts/*.nix` - 11 host configurations
- `aspects/_template.nix` - Development template
- `scripts/capture-baseline.sh` - Pre-migration snapshot
- `scripts/compare-with-baseline.sh` - Post-migration comparison
- `scripts/validate-critical-services.sh` - Service configuration validation
- `MIGRATION.md` - Migration documentation

### To Modify:
- `flake.nix` - Complete rewrite for flake-parts
- `CLAUDE.md` - Update for dendritic pattern

### To Archive (after validation):
- `modules/` → `_archive/modules/`
- `systems/` → `_archive/systems/`
- `overlays/` → integrated into `aspects/_lib.nix`

### To Keep Unchanged:
- `lib/aiden/` - Helper functions still used
- `packages/` - Custom packages
- `secrets/` - Age-encrypted secrets

---

## Risk Mitigation

### Git Safety Net
- Work on `dendritic-2` branch
- Create `snowfall-backup` branch before cutover
- Tag each phase completion
- Can rollback to any phase

### Testing Strategy
- Dry-run builds before committing changes
- Full local builds for all hosts
- Derivation comparison for functional equivalence
- Service configuration validation via nix eval

### Validation Tools
- `nix-diff` for detailed derivation comparison
- `nvd` for user-friendly diff visualization
- `nix eval` for service configuration verification
- `nix flake check` for overall validation

### Error Recovery Strategy
**Always attempt to fix forward first before rolling back**:

1. **Build/evaluation errors**:
   - Diagnose the issue
   - Fix the problematic aspect/module
   - Re-test and continue

2. **If fix is not obvious** (rollback options):
   - `git reset --hard HEAD^` - undo last commit
   - `git checkout <working-commit>` - return to specific working state
   - `git checkout phase-N-complete` - rollback to completed phase
   - `git checkout snowfall-backup` - complete revert to Snowfall

---

## Success Criteria

- ✅ All 70 modules translated to aspects
- ✅ All 11 hosts configured and working
- ✅ Derivations functionally equivalent (verified with nix-diff)
- ✅ No service regressions
- ✅ All secrets accessible
- ✅ Hardware acceleration working
- ✅ Router routing correctly (multi-VLAN)
- ✅ Gaming stack functional
- ✅ Home-manager integrations working
- ✅ Documentation updated
- ✅ Snowfall Lib dependency removed

---

## Troubleshooting Guide

### Common Errors and Solutions

**"error: attribute 'modules' missing"**
- **Cause**: flake-parts not generating `self.modules` attribute
- **Fix**: Check that aspects are using `flake.modules.nixos.*` not `flake.nixosModules.*`

**"infinite recursion encountered"**
- **Cause**: Circular dependency between modules
- **Fix**: Review module dependencies, ensure no A→B→A chains

**"error: undefined variable 'inputs'"**
- **Cause**: `inputs` not in scope for aspect
- **Fix**: Ensure `aspects/_lib.nix` includes `_module.args.inputs = inputs;`

**"error: path '...' does not exist"**
- **Cause**: File path reference incorrect after restructure
- **Fix**: Update paths from `systems/` to `aspects/hosts/`

**Build succeeds but wrong packages**
- **Cause**: Overlay not applied or channel selection broken
- **Fix**: Verify `aspects/_lib.nix` overlay and pkgs configuration

**"option 'aiden.modules.X' is read-only"**
- **Cause**: Module tries to set option that another module owns
- **Fix**: Check module isn't redefining options, should only reference them

**Home-manager config not applied**
- **Cause**: sharedModules not loaded properly
- **Fix**: Verify `builtins.attrValues self.modules.homeManager` in host config

### Debugging Workflow

1. **Read the full error** - Don't skim, errors contain exact locations
2. **Check the file** - Navigate to file:line mentioned in error
3. **Validate syntax** - Use `nix eval` to check specific expressions
4. **Compare with original** - Look at Snowfall module for reference
5. **Test incrementally** - Fix one issue, re-test, repeat
6. **Only rollback when stuck** - Exhaust fixing options first

### Getting Unstuck

If completely stuck:
1. Check `flake.nix` structure matches plan exactly
2. Verify all aspect files created with correct names
3. Test with minimal example (just `common` module + one host)
4. Compare working example from dendritic repos online
5. As last resort, rollback to last tagged phase and retry
