{ inputs, ... }:
{
  flake.overlays.default = final: prev: {
    inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system})
      bazarr steamtinkerlaunch navidrome;
    intel-media-driver-stable = inputs.nixpkgs.legacyPackages.${prev.system}.intel-media-driver;
    inherit (inputs.nixpkgs.legacyPackages.${prev.system})
      libva-vdpau-driver
      intel-compute-runtime-legacy1
      vpl-gpu-rt
      intel-ocl
      onevpl-intel-gpu;
  };
}
