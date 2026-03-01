{ inputs, ... }:
{
  flake.overlays.default = final: prev:
    let
      stablePkgs = import inputs.nixpkgs {
        system = prev.system;
        config.allowUnfree = true;
      };
      unstablePkgs = import inputs.nixpkgs-unstable {
        system = prev.system;
        config.allowUnfree = true;
      };
    in
    {
      inherit (unstablePkgs)
        bazarr steamtinkerlaunch navidrome;
      intel-media-driver-stable = stablePkgs.intel-media-driver;
      inherit (stablePkgs)
        libva-vdpau-driver
        intel-compute-runtime-legacy1
        vpl-gpu-rt
        intel-ocl
        onevpl-intel-gpu;
    };
}
