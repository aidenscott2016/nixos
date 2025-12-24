# Vix Repository Pattern Comparison

## Overview
This document compares our den migration implementation with the vix repository (https://github.com/vic/vix), which is a reference implementation of the dendritic pattern.

## Directory Structure Comparison

### Vix Pattern
```
modules/
├── dendritic.nix         # Den bootstrap
├── namespace.nix         # Creates vix, vic, my namespaces
├── my/                   # Infrastructure aspects (hosts, users, system)
│   ├── hosts.nix
│   ├── user.nix
│   └── workstation.nix
├── vic/                  # User-specific aspects (17 aspects)
│   ├── browser.nix
│   ├── git.nix
│   ├── cli-tui.nix
│   └── ...
└── community/vix/        # Shared/reusable aspects (30 aspects)
    ├── kde-desktop.nix
    ├── nvidia.nix
    └── ...
```

### Our Pattern (aiden/nixos)
```
modules/
├── dendritic.nix         # Den bootstrap
├── namespace.nix         # Creates aiden namespace
├── hosts/                # Per-host definitions (12 files)
│   ├── locutus-den.nix
│   ├── desktop-den.nix
│   └── ...
└── aspects/aiden/        # All aspects (35 aspects)
    ├── architecture.nix
    ├── common.nix
    ├── desktop.nix
    └── ...
```

## Key Differences

### 1. Namespace Organization

**Vix:** Multiple namespaces for separation of concerns
- `my.*` - Infrastructure (hosts, system-level config)
- `vic.*` - Personal user configuration
- `vix.*` - Shared/community patterns

**Ours:** Single namespace
- `aiden.*` - All aspects (infrastructure + user + system)
- Simpler but less modular for sharing

### 2. Host Declaration

**Vix:** Centralized in single `modules/my/hosts.nix`
- All hosts visible at a glance
- Easier to understand fleet topology

**Ours:** One file per host in `modules/hosts/`
- Better git diffs and collaboration
- More scalable for large fleets
- Slightly less discoverable

### 3. Meta-Aspect Granularity

**Vix:** Smaller, focused meta-aspects (5-8 sub-aspects)
```nix
aiden.workstation = {
  includes = [
    aiden.hardware
    aiden.bootable
    aiden.kde-desktop
    aiden.kvm-amd
    aiden.mexico
    aiden.niri-desktop
  ];
};
```

**Ours:** Larger, comprehensive meta-aspects (17+ sub-aspects)
```nix
aiden.desktop = {
  includes = [
    aiden.syncthing
    aiden.redshift
    aiden.printer
    aiden.thunar
    aiden.keyd
    aiden.powermanagement
    aiden.yubikey
    aiden.appimage
    aiden.pipewire
    aiden.ssh
    aiden.avahi
    aiden.common
    aiden.multimedia
    aiden.hardware-acceleration
    aiden.ios
    aiden.cli-base
    aiden.emacs
  ];
};
```

## What We're Doing Well

✅ **Clean aspect structure** - Following den patterns correctly
✅ **Good composition** - Meta-aspects work well
✅ **Per-host files** - More scalable than vix's single hosts.nix
✅ **Focused aspect count** - 35 aspects vs vix's ~50 (less sprawl)
✅ **Early adoption** - Successfully using den before widespread documentation

## Opportunities for Improvement

### Priority 1 (High Value)
1. **Split large meta-aspects** - Break `desktop` into smaller composable pieces
   - Consider: `desktop-base`, `desktop-xserver`, `desktop-development`
2. **Add host overview** - Consider `modules/hosts/default.nix` that lists all hosts
3. **Namespace separation** - Explore `system.*`, `user.*`, `community.*` namespaces

### Priority 2 (Nice to Have)
4. **Community directory** - Prepare for sharing aspects publicly
5. **Parametric aspects** - Use `{ host, user }` context like vix
6. **Smaller includes** - More granular composition options

### Priority 3 (Future)
7. **Profile-based variants** - Hardware/VM/Base patterns like vix's workstation
8. **Documentation** - README for each major aspect
9. **Auto-generated flake** - Consider flake-file if managing many inputs

## Validation Against Vix Patterns

| Pattern | Vix | Our Implementation | Status |
|---------|-----|-------------------|--------|
| Dendritic bootstrap | ✅ | ✅ | Matching |
| Namespace-based aspects | ✅ | ✅ | Matching |
| Aspect composition (includes) | ✅ | ✅ | Matching |
| Host registration via den.hosts | ✅ | ✅ | Matching |
| Per-aspect nixos/homeManager | ✅ | ✅ | Matching |
| Multiple namespaces | ✅ | ❌ | Different (single namespace) |
| Centralized hosts file | ✅ | ❌ | Different (per-host files) |
| Small meta-aspects | ✅ | ❌ | Different (larger meta-aspects) |
| Community separation | ✅ | ❌ | Not implemented |
| Profile variants | ✅ | ❌ | Not implemented |

## Conclusion

Our implementation successfully adopts the core dendritic patterns and in some ways improves upon vix's approach (per-host files, focused aspect count). The main differences are architectural choices that favor simplicity over modularity, which is appropriate for a personal configuration.

Key strengths:
- **Correct den pattern usage**
- **Clean organization**
- **Good composition**
- **Pragmatic choices for personal use**

Areas to consider:
- Smaller meta-aspects for better granularity
- Namespace separation for future sharing
- Host visibility improvements

## References

- **Vix Repository:** https://github.com/vic/vix
- **Den Framework:** https://github.com/vic/den
- **Flake-parts:** https://flake.parts
- **Import-tree:** Part of den/dendritic pattern
