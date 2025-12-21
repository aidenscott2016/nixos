# Phase 5 Comparison Scripts

Scripts for comparing Snowfall baseline with Dendritic implementation.

## Overview

These scripts use git worktrees to maintain both versions simultaneously:
- **Snowfall baseline**: `/tmp/nixos-snowfall` (commit fb6f7b7)
- **Dendritic current**: `/home/aiden/src/nixos` (branch dendritic-2)

## Usage

### Quick Start (Recommended)

```bash
# 1. Setup worktree and apply patches
./scripts/setup-comparison.sh

# 2. Run full comparison
./scripts/compare-worktrees.sh

# 3. Review reports
ls /tmp/nixos-comparison/*.nvd.txt
```

### Step-by-Step Approach

```bash
# 1. Setup Snowfall worktree with patches
./scripts/setup-comparison.sh

# 2. Capture Snowfall baseline
./scripts/capture-baseline.sh

# 3. Compare with Dendritic
./scripts/compare-with-baseline.sh

# 4. Validate critical services
./scripts/validate-critical-services.sh
```

### Single Host Comparison

```bash
# Compare just one host (much faster)
./scripts/compare-single-host.sh mike
```

### Quick Validation

```bash
# Fast sanity check without full comparison
./scripts/quick-validate.sh
```

## Scripts

### setup-comparison.sh
Sets up the Snowfall worktree and applies compatibility patches:
- Disables broken beets pluginOverrides
- Removes deprecated amdvlk configuration
- Comments out AdGuard querylog option

### compare-worktrees.sh
Complete comparison workflow:
1. Builds all 10 hosts on Snowfall baseline
2. Builds all 10 hosts on Dendritic current
3. Generates nvd comparison reports

### capture-baseline.sh
Standalone script to build and capture Snowfall baseline derivations.

### compare-with-baseline.sh
Builds Dendritic version and compares with existing baseline.

### compare-single-host.sh
Compares a single host between Snowfall and Dendritic.

### validate-critical-services.sh
Validates that critical services are still enabled after migration.

### quick-validate.sh
Fast validation that hosts build and modules are enabled.

## Output

### Build Artifacts
- `/tmp/nixos-baseline/` - Snowfall builds
- `/tmp/nixos-dendritic/` - Dendritic builds

### Reports
- `/tmp/nixos-comparison/*.nvd.txt` - User-friendly diffs
- `/tmp/nixos-comparison/*.nix-diff.txt` - Detailed derivation diffs

## Interpreting Results

### Expected Differences
- Store paths (different derivation hashes)
- Build timestamps
- Flake references (snowfall-lib → flake-parts)

### Problematic Differences
- Missing packages
- Disabled services
- Changed service configurations
- Missing user groups
- Different kernel modules
- Changed firewall rules

## Cleanup

```bash
# Remove worktree when done
git worktree remove /tmp/nixos-snowfall

# Clean up build artifacts
rm -rf /tmp/nixos-baseline /tmp/nixos-dendritic /tmp/nixos-comparison
```
