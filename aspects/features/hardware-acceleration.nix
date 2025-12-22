{ lib, ... }:
{
  flake.modules.nixos.hardware-acceleration = { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.aiden.modules.hardware-acceleration;
      inherit (config.aiden) architecture;
    in {
      options.aiden.modules.hardware-acceleration = {
        enable = mkEnableOption "hardware acceleration configuration";
        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "Additional packages to install for hardware acceleration";
        };
      };

      config = mkIf cfg.enable {
        hardware = {
          enableAllFirmware = true;
          enableRedistributableFirmware = true;
          intel-gpu-tools.enable = true;
          amdgpu = mkIf (architecture.gpu == "amd") {
            initrd.enable = true;
          };

          graphics = {
            enable = true;
            extraPackages =
              with pkgs;
              [
                libva
                mesa
              ]
              ++ optionals (architecture.cpu == "intel") [
                intel-media-driver-stable
                libva-vdpau-driver
                intel-compute-runtime-legacy1
                vpl-gpu-rt
                intel-ocl
              ]
              ++ cfg.extraPackages;
          };
        };

        services.xserver = mkIf config.services.xserver.enable {
          videoDrivers = singleton (
            if architecture.gpu == "amd" then
              "amdgpu"
            else if architecture.gpu == "intel" then
              "intel"
            else
              "nvidia"
          );
        };

        boot.kernelParams = optionals (architecture.cpu == "intel") [
          "i915.enable_guc=3"
        ];

        environment.systemPackages = with pkgs; [ nvtopPackages.full ];
      };
    };
}
