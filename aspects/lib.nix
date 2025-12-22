{ lib, inputs, config, ... }:
{
  # Use flake-parts built-in modules option
  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  # Make custom lib functions available to all aspects
  _module.args.lib = lib.extend (self: super: {
    aiden = import ../lib/aiden { lib = self; };
  });

  # Expose inputs to aspects (already available via flake-parts, but being explicit)
  _module.args.inputs = inputs;

  # Aliases for external consumers
  flake.nixosModules = config.flake.modules.nixos or { };
  flake.homeManagerModules = config.flake.modules.homeManager or { };

  # Create overlay from channel switching (from overlays/default.nix)
  flake.overlays.default = final: prev:
    let
      # Import stable channel with unfree allowed
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit (final) system;
        config.allowUnfree = true;
      };

      # Import unstable channel with unfree allowed
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
        config.allowUnfree = true;
      };

      # Import pinned unstable with unfree allowed
      pkgs-unstable-pinned = import inputs.nixpkgs-unstable-pinned {
        inherit (final) system;
        config.allowUnfree = true;
      };
    in
    {
      # Packages from unstable channel
      inherit (pkgs-unstable)
        bazarr steamtinkerlaunch;

      # Packages from pinned unstable
      inherit (pkgs-unstable-pinned)
        navidrome paperless-ngx redis;

      # Stable channel packages (primarily for hardware acceleration)
      intel-media-driver-stable = pkgs-stable.intel-media-driver;
      inherit (pkgs-stable)
        libva-vdpau-driver
        intel-compute-runtime-legacy1
        vpl-gpu-rt
        intel-ocl
        onevpl-intel-gpu;
    };
}
