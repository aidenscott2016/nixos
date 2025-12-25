# Den Migration Completion Plan - Home-Manager & Validation

**Previous Plan:** [wondrous-tinkering-coral.md](.claude/plans/wondrous-tinkering-coral.md)

## Overview

Complete the den migration by implementing the two missing pieces:
1. **Home-Manager Aspects** - Convert 12 old home-manager modules to den aspects
2. **nvd Validation** - Enhanced validation script to verify migration parity

---

## Part 1: Home-Manager Aspects

### Background

The original Snowfall config had 12 home-manager modules in `modules/home/`:
- bash, darkman, desktop, easyeffects, firefox, git, gpg-agent, ideavim, ssh, tmux, vim, xdg-portal

With associated config files:
- `firefox/tridactylrc`, `git/gitignore`, `ideavim/ideavimrc`, `tmux/tmux.conf`, `vim/vimrc`

**Hosts that used home-manager:**
| Host | Method |
|------|--------|
| mike | `aiden.modules.home-manager.enable = true` (full HM) |
| locutus | `aiden.modules.home-manager.enable = true` (full HM) |
| desktop | `aiden.modules.home-manager.enable = true` (full HM) |
| barbie | Direct `home-manager.users.aiden = {}` (minimal) |
| tv | Direct `home-manager.users.aiden = { ... }` (minimal) |
| gila, bes, thoth, lovelace, pxe, installer | No home-manager |

### Implementation Steps

#### Step 1: Create Home-Manager Aspect Files (12 files)

Create `modules/aspects/aiden/home/` directory with:

```
modules/aspects/aiden/home/
├── bash.nix
├── darkman.nix
├── desktop.nix
├── easyeffects.nix
├── firefox.nix
├── firefox/tridactylrc
├── git.nix
├── git/gitignore
├── gpg-agent.nix
├── ideavim.nix
├── ideavim/ideavimrc
├── ssh.nix
├── tmux.nix
├── tmux/tmux.conf
├── vim.nix
└── vim/vimrc
```

#### Step 2: Aspect Definition Pattern

Each home-manager aspect uses `homeManager` block in the den aspect pattern:

```nix
# modules/aspects/aiden/home/bash.nix
{ ... }:
{
  aiden.home.bash = {
    # homeManager block applies to home-manager.users.<user>
    homeManager = {
      programs.bash = {
        enable = true;
        bashrcExtra = ''
          set -o vi
        '';
      };
    };
  };
}
```

**Key Pattern:** Den aspects can have both `nixos` and `homeManager` blocks:
- `nixos = { ... }` - Applied to NixOS system config
- `homeManager = { ... }` - Applied to home-manager user config

When an aspect with `homeManager` is included by a user, the homeManager config is automatically applied to that user's home-manager configuration.

#### Step 3: Update aiden.home-manager Aspect

Modify `modules/aspects/aiden/home-manager.nix` to include all home aspects:

```nix
{ aiden, inputs, ... }:
{
  aiden.home-manager = {
    includes = [
      aiden.home.bash
      aiden.home.git
      aiden.home.vim
      aiden.home.tmux
      aiden.home.ssh
      aiden.home.gpg-agent
      aiden.home.firefox
      aiden.home.desktop
      aiden.home.ideavim
      aiden.home.easyeffects
      # darkman and xdg-portal have options - handle specially
    ];

    nixos = { ... }: {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.aiden = { };
    };
  };
}
```

#### Step 4: Handle Conditional Aspects (darkman, xdg-portal)

These have `enable` options - convert to separate aspects that hosts can include:

```nix
# modules/aspects/aiden/home/darkman.nix
{ aiden, ... }:
{
  aiden.home.darkman = {
    includes = [ aiden.home.xdg-portal ];

    homeManager = { pkgs, ... }: {
      xdg.portal = {
        config.common."org.freedesktop.impl.portal.Settings" = [ "darkman" ];
        extraPortals = [ pkgs.darkman ];
      };
      services.darkman = {
        enable = true;
        settings.usegeoclue = true;
      };
    };
  };
}
```

#### Step 5: Update Desktop Hosts

**mike.nix, locutus.nix, desktop.nix** - Already include `aiden.home-manager` aspect in their `includes`. After the aspect is updated to include all home aspects, these hosts will automatically get the full home-manager configuration.

**barbie.nix, tv.nix** - Currently use direct home-manager integration (not via aspect):
- Option A: Convert to use `aiden.home-manager` aspect (adds full HM config)
- Option B: Keep direct integration but move HM module import to a minimal aspect

**Recommendation:** Keep barbie/tv as-is for now since:
1. They didn't use the full home-manager module in Snowfall (just stateVersion)
2. They don't need bash/git/vim/firefox configs
3. Changing them would add unnecessary packages

The current direct `inputs.home-manager.nixosModules.home-manager` import in barbie/tv is fine.

### Files to Create

| File | Source |
|------|--------|
| `modules/aspects/aiden/home/bash.nix` | `git show master:modules/home/bash/default.nix` |
| `modules/aspects/aiden/home/git.nix` | `git show master:modules/home/git/default.nix` |
| `modules/aspects/aiden/home/git/gitignore` | `git show master:modules/home/git/gitignore` |
| `modules/aspects/aiden/home/vim.nix` | `git show master:modules/home/vim/default.nix` |
| `modules/aspects/aiden/home/vim/vimrc` | `git show master:modules/home/vim/vimrc` |
| `modules/aspects/aiden/home/tmux.nix` | `git show master:modules/home/tmux/default.nix` |
| `modules/aspects/aiden/home/tmux/tmux.conf` | `git show master:modules/home/tmux/tmux.conf` |
| `modules/aspects/aiden/home/ssh.nix` | `git show master:modules/home/ssh/default.nix` |
| `modules/aspects/aiden/home/gpg-agent.nix` | `git show master:modules/home/gpg-agent/default.nix` |
| `modules/aspects/aiden/home/firefox.nix` | `git show master:modules/home/firefox/default.nix` |
| `modules/aspects/aiden/home/firefox/tridactylrc` | `git show master:modules/home/firefox/tridactylrc` |
| `modules/aspects/aiden/home/desktop.nix` | `git show master:modules/home/desktop/default.nix` |
| `modules/aspects/aiden/home/ideavim.nix` | `git show master:modules/home/ideavim/default.nix` |
| `modules/aspects/aiden/home/ideavim/ideavimrc` | `git show master:modules/home/ideavim/ideavimrc` |
| `modules/aspects/aiden/home/easyeffects.nix` | `git show master:modules/home/easyeffects/default.nix` |
| `modules/aspects/aiden/home/darkman.nix` | `git show master:modules/home/darkman/default.nix` |
| `modules/aspects/aiden/home/xdg-portal.nix` | `git show master:modules/home/xdg-portal/default.nix` |

### Files to Modify

| File | Changes |
|------|---------|
| `modules/aspects/aiden/home-manager.nix` | Add includes for all home aspects, add HM nixos import |

**No changes needed to barbie.nix or tv.nix** - they use minimal direct HM integration which is correct for their use case.

---

## Part 2: nvd Validation

### Enhanced Validation Script

Update `scripts/validate-migration.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

MASTER_PATH="${NIXOS_MASTER:-/home/aiden/src/nixos-master}"
HOSTS="${@:-mike locutus desktop gila bes thoth tv barbie pxe lovelace}"

echo "=== Den Migration Validation ==="
echo "Comparing against: $MASTER_PATH"
echo ""

FAILED_HOSTS=""
PASSED_HOSTS=""

for HOST in $HOSTS; do
  echo "--- Validating $HOST ---"

  # Build new configuration
  if ! nix build ".#nixosConfigurations.$HOST.config.system.build.toplevel" \
       --out-link "result-new-$HOST" 2>/dev/null; then
    echo "FAIL: $HOST - new config doesn't build"
    FAILED_HOSTS="$FAILED_HOSTS $HOST"
    continue
  fi

  # Build old configuration (skip if host doesn't exist in master)
  if ! nix build "$MASTER_PATH#nixosConfigurations.$HOST.config.system.build.toplevel" \
       --out-link "result-old-$HOST" 2>/dev/null; then
    echo "SKIP: $HOST - not in master (new host)"
    continue
  fi

  # Compare with nvd
  echo "Comparing packages..."
  if nvd diff "result-old-$HOST" "result-new-$HOST" 2>/dev/null; then
    echo "PASS: $HOST"
    PASSED_HOSTS="$PASSED_HOSTS $HOST"
  else
    echo "DIFF: $HOST - packages differ (review above)"
    FAILED_HOSTS="$FAILED_HOSTS $HOST"
  fi
  echo ""
done

# Summary
echo "=== Summary ==="
echo "Passed:$PASSED_HOSTS"
[ -n "$FAILED_HOSTS" ] && echo "Failed/Diff:$FAILED_HOSTS"

# Cleanup
rm -f result-old-* result-new-*
```

### Validation Workflow

1. Run for all hosts: `./scripts/validate-migration.sh`
2. Run for specific host: `./scripts/validate-migration.sh mike`
3. Output shows PASS/FAIL/DIFF for each host
4. Review any DIFF hosts to confirm changes are intentional

---

## Execution Order

1. Create `modules/aspects/aiden/home/` directory
2. Create all 12 home aspect files + config files (17 total with config files)
3. Update `modules/aspects/aiden/home-manager.nix` with includes and HM module import
4. Update validation script
5. `git add` all new files
6. Run validation for hosts: `./scripts/validate-migration.sh mike locutus desktop`
7. Commit: `feat(den): convert home-manager aspects from Snowfall`
8. Run final validation on all hosts and update MIGRATION_SUMMARY.md

---

## Expected nvd Output

After implementation, `./scripts/validate-migration.sh mike` should show:

```
--- Validating mike ---
Comparing packages...
<<< /nix/store/xxx-nixos-system-mike-25.11
>>> /nix/store/yyy-nixos-system-mike-25.11
Version changes: 0
Closure size: 12.3 GB -> 12.3 GB
PASS: mike
```

Any package differences indicate configuration drift that needs investigation.
