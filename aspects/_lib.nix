{ lib, inputs, config, ... }:
{
  # Declare module outputs - these get automatically merged
  options.flake.nixosModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
  };

  options.flake.homeManagerModules = lib.mkOption {
    type = lib.types.attrsOf lib.types.deferredModule;
    default = { };
  };

  # Make custom lib functions available to all aspects
  _module.args.lib = lib.extend (self: super: {
    aiden = import ../lib/aiden { lib = self; };
  });

  # Expose inputs to aspects
  _module.args.inputs = inputs;

  # Create overlay from channel switching (from overlays/default.nix)
  flake.overlays.default = final: prev: {
    # Packages from unstable channel
    inherit (inputs.nixpkgs-unstable.legacyPackages.${final.system})
      bazarr steamtinkerlaunch;

    # Packages from pinned unstable
    inherit (inputs.nixpkgs-unstable-pinned.legacyPackages.${final.system})
      navidrome paperless-ngx redis;

    # Stable channel packages (primarily for hardware acceleration)
    intel-media-driver-stable = inputs.nixpkgs-stable.legacyPackages.${final.system}.intel-media-driver;
    inherit (inputs.nixpkgs-stable.legacyPackages.${final.system})
      libva-vdpau-driver
      intel-compute-runtime-legacy1
      vpl-gpu-rt
      intel-ocl
      onevpl-intel-gpu;
  };
}
