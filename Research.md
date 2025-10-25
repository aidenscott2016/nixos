# NixOS Codebase Refactoring Research: Adopting the Dendritic Pattern

## Executive Summary

This document analyzes the current NixOS codebase structure and provides findings on refactoring it to follow the "dendritic pattern" using `flake-parts`. The dendritic pattern is a modular approach where each Nix file serves as a self-contained flake-parts module, implementing a single feature across all applicable module classes.

## Current Codebase Analysis

### Current Structure Overview

The codebase currently uses **Snowfall Lib** as its primary organization framework:

```nix
# flake.nix
outputs = inputs: inputs.snowfall-lib.mkFlake {
  inherit inputs;
  src = ./.;
  snowfall = { namespace = "aiden"; };
  # ...
};
```

### Directory Structure

```
/workspace/
├── flake.nix                    # Main flake using snowfall-lib
├── lib/aiden/default.nix        # Helper functions and utilities
├── modules/
│   ├── home/                    # Home Manager modules (15 modules)
│   └── nixos/                   # NixOS modules (52 modules)
├── overlays/default.nix         # Package overlays
├── packages/                    # Custom packages
├── secrets/                     # Age-encrypted secrets
└── systems/                     # System configurations
    ├── aarch64-linux/
    ├── x86_64-install-iso/
    └── x86_64-linux/            # 9 different systems
```

### Current Module Pattern

**Current NixOS Module Structure:**
```nix
# modules/nixos/desktop/default.nix
{config, lib, pkgs, ...}:
with lib.aiden;
with lib;
{
  options.aiden.modules.desktop = {
    enable = mkEnableOption "Enable desktop configuration";
    # additional options...
  };
  
  config = mkIf config.aiden.modules.desktop.enable {
    # module configuration
    aiden.modules = {
      syncthing = enabled;
      redshift = enabled;
      # other module dependencies
    };
  };
}
```

**Current Home Manager Module Structure:**
```nix
# modules/home/git/default.nix
{config, lib, pkgs, ...}:
{
  programs.git = {
    enable = true;
    userName = "Aiden";
    userEmail = "aiden@oldstreetjournal.co.uk";
    # git configuration...
  };
}
```

### Key Findings

1. **Module Organization**: 67 total modules (52 NixOS, 15 Home Manager)
2. **Namespace System**: Uses `aiden.modules.*` namespace for NixOS modules
3. **Helper Library**: Custom `lib.aiden` with utilities like `enabled` and `enableableModule`
4. **Dependency Management**: Modules reference each other through the namespace system
5. **System Configurations**: 9 different system configurations with varying module combinations

## Understanding the Dendritic Pattern

### What is the Dendritic Pattern?

The dendritic pattern is a Nix flake-parts usage pattern where:

1. **Each Nix file is a flake-parts module**
2. **Each module implements a single feature** across all applicable module classes
3. **Automatic import** - files are automatically discovered and imported
4. **No literal path imports** - enables free movement and nesting of files
5. **Files prefixed with underscore are ignored**

### Exemplar Repository Structure

From [@mightyiam/infra](https://github.com/mightyiam/infra):

```
├── flake.nix                    # Uses flake-parts.lib.mkFlake
├── modules/                     # All modules are flake-parts modules
│   ├── feature1.nix            # Single feature, cross-platform
│   ├── feature2.nix            # Automatically imported
│   └── _ignored.nix            # Underscore prefix = ignored
└── inputs/                      # Git submodules for input management
```

### Flake-Parts Module Structure

```nix
# Example flake-parts module
{ self, inputs, ... }: {
  # NixOS module definition
  flake.nixosModules.feature = { config, lib, pkgs, ... }: {
    options.services.feature = {
      enable = lib.mkEnableOption "feature";
    };
    config = lib.mkIf config.services.feature.enable {
      # NixOS configuration
    };
  };
  
  # Home Manager module definition
  flake.homeModules.feature = { config, lib, pkgs, ... }: {
    options.programs.feature = {
      enable = lib.mkEnableOption "feature";
    };
    config = lib.mkIf config.programs.feature.enable {
      # Home Manager configuration
    };
  };
  
  # Per-system packages/apps/etc
  perSystem = { pkgs, ... }: {
    packages.feature = pkgs.writeShellScript "feature" "echo hello";
  };
}
```

## Key Components for Refactoring

### 1. Flake-Parts Integration

**Required Input:**
```nix
inputs.flake-parts.url = "github:hercules-ci/flake-parts";
```

**Main Flake Structure:**
```nix
{
  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # Automatic import of all modules
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
    };
}
```

### 2. Module Conversion Strategy

#### Current Module Types to Convert:

1. **NixOS-only modules** (e.g., `modules/nixos/desktop/`) → Single flake-parts module with `flake.nixosModules`
2. **Home Manager-only modules** (e.g., `modules/home/git/`) → Single flake-parts module with `flake.homeModules`
3. **Cross-platform features** → Combined flake-parts module with both `nixosModules` and `homeModules`
4. **Packages** → flake-parts module with `perSystem.packages`
5. **System configurations** → flake-parts module with `flake.nixosConfigurations`

#### Example Conversion:

**Before (Current):**
```
modules/nixos/git/default.nix    # NixOS git config
modules/home/git/default.nix     # Home Manager git config
```

**After (Dendritic):**
```
modules/git.nix                  # Single module with both NixOS and HM
```

### 3. Automatic Import Implementation

The exemplar uses automatic import discovery. Implementation options:

1. **Manual imports** (simpler transition):
   ```nix
   imports = [
     ./modules/git.nix
     ./modules/desktop.nix
     # ... all modules
   ];
   ```

2. **Automatic imports** (true dendritic pattern):
   ```nix
   imports = lib.filesystem.listFilesRecursive ./modules
     |> builtins.filter (path: lib.hasSuffix ".nix" path)
     |> builtins.filter (path: !lib.hasInfix "/_" path)
     |> map import;
   ```

### 4. Library Functions Migration

Current `lib.aiden` functions need adaptation:

```nix
# Current: lib/aiden/default.nix
enabled = { enable = true; };
enableableModule = name: params: configToEnable: { ... };
```

**Migration Strategy:**
- Move to flake-parts module: `modules/_lib.nix` (underscore = not auto-imported)
- Expose via `flake.lib.aiden`
- Update all references

### 5. Namespace Considerations

**Current namespace:** `aiden.modules.*`
**Proposed namespace:** Standard NixOS/HM options without custom namespace

**Benefits:**
- Better integration with ecosystem
- Cleaner option names
- Follows NixOS conventions

**Challenges:**
- Requires updating all system configurations
- Need to ensure no option conflicts

## Refactoring Roadmap

### Phase 1: Foundation
1. Add flake-parts to inputs
2. Create basic flake-parts structure
3. Migrate helper library functions
4. Set up automatic import system

### Phase 2: Module Migration
1. Start with simple, standalone modules
2. Convert NixOS-only modules to flake-parts format
3. Convert Home Manager-only modules
4. Combine related cross-platform modules

### Phase 3: Advanced Features
1. Migrate package definitions
2. Convert system configurations
3. Update overlays
4. Migrate secrets management

### Phase 4: Cleanup
1. Remove snowfall-lib dependency
2. Clean up old directory structure
3. Update documentation
4. Test all system configurations

## Benefits of Migration

### Modularity Benefits
- **Single-responsibility modules**: Each file handles one feature
- **Cross-platform consistency**: Same feature works across NixOS and Home Manager
- **Easier maintenance**: Changes to a feature happen in one place

### Organization Benefits
- **Automatic discovery**: No need to manually maintain import lists
- **Flexible structure**: Files can be moved/nested freely
- **Cleaner separation**: Clear distinction between features

### Ecosystem Benefits
- **Better integration**: Follows flake-parts best practices
- **Community alignment**: Uses standard patterns
- **Future-proofing**: Aligned with ecosystem direction

## Challenges and Considerations

### Technical Challenges
1. **Namespace migration**: All system configs need updates
2. **Dependency resolution**: Module interdependencies need careful handling
3. **Testing complexity**: Need to verify all system configurations still work

### Migration Complexity
1. **Large codebase**: 67 modules + 9 systems to migrate
2. **Active development**: Ongoing changes during migration
3. **Rollback strategy**: Need ability to revert if issues arise

### Compatibility Concerns
1. **Snowfall-lib removal**: May break existing workflows
2. **Custom library functions**: Need to ensure all utilities still work
3. **External dependencies**: Some modules may rely on snowfall-lib features

## Recommendations

### Migration Strategy
1. **Incremental approach**: Migrate modules gradually, not all at once
2. **Parallel structure**: Keep both systems running during transition
3. **Extensive testing**: Test each migrated module thoroughly

### Priority Order
1. **Start with leaf modules**: Modules with no dependencies
2. **Core infrastructure**: Common, foundational modules
3. **System-specific features**: Desktop, gaming, etc.
4. **System configurations**: Last, after all modules are migrated

### Risk Mitigation
1. **Branch-based development**: Use separate branch for migration work
2. **Automated testing**: Set up CI to test all system configurations
3. **Documentation**: Maintain clear migration progress tracking

## Conclusion

The dendritic pattern offers significant benefits for this codebase in terms of modularity, maintainability, and ecosystem alignment. While the migration is complex due to the current size and structure, an incremental approach with careful planning can successfully transition the codebase to this more modern and flexible pattern.

The key success factors are:
1. Proper planning and phased approach
2. Maintaining backward compatibility during transition
3. Extensive testing at each step
4. Clear documentation of changes and progress

This migration will result in a more maintainable, flexible, and future-proof NixOS configuration system.