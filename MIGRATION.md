# Migration: Snowfall Lib to Dendritic Pattern

This repository has been migrated from a Snowfall Lib structure to a **dendritic pattern** using `flake-parts`.

## Key Changes

### 1. Directory Restructuring
- The `modules/nixos/` and `modules/home/` directories have been consolidated into `aspects/features/`.
- Per-machine configurations from `systems/{arch}/{hostname}/` have been moved to `aspects/hosts/{hostname}/`.
- Legacy files are archived in `_archive/`.

### 2. Flake Configuration
- `flake.nix` now uses `flake-parts`.
- The `snowfall-lib` dependency has been removed.
- All NixOS and Home Manager modules are automatically collected from the `aspects/features` directory.

### 3. Aspect Pattern
Each file in `aspects/features/` is an "aspect" that defines both NixOS and Home Manager components.

**Before (Snowfall):**
- `modules/nixos/ssh/default.nix`
- `modules/home/ssh/default.nix`

**After (Dendritic):**
- `aspects/features/ssh.nix` containing both `flake.nixosModules.ssh` and `flake.homeManagerModules.ssh`.

## Rollback Instructions
If you need to return to the Snowfall structure:
1. Revert to the `cutover-point` tag or a commit before the Phase 4/7 changes.
2. Restore the archived directories: `mv _archive/modules .`, `mv _archive/systems .`, etc.
3. Replace `flake.nix` with the backup in `_archive/flake.nix.snowfall.bak`.
