# Overlays for pulling packages from different nixpkgs channels
{ inputs, ... }:

{
  # Add channel-specific package overlays
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        # Pull specific packages from unstable
        (final: prev: {
          inherit (inputs.nixpkgs-unstable.legacyPackages.${system})
            bazarr
            steamtinkerlaunch;

          inherit (inputs.nixpkgs-unstable-pinned.legacyPackages.${system})
            navidrome
            paperless-ngx
            redis;

          # Pull specific packages from stable for hardware acceleration
          intel-media-driver-stable = inputs.nixpkgs-stable.legacyPackages.${system}.intel-media-driver;

          inherit (inputs.nixpkgs-stable.legacyPackages.${system})
            libva-vdpau-driver
            intel-compute-runtime-legacy1
            vpl-gpu-rt
            intel-ocl
            onevpl-intel-gpu;
        })
      ];
      config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
        rocmSupport = false;
        permittedInsecurePackages = [
          "qtwebengine-5.15.19"
        ];
      };
    };
  };
}
