{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.aiden.modules.hardware-acceleration;
  inherit (config.aiden) architecture;
  jovian = config.aiden.modules.jovian;
  hasJovianMesa = jovian.enable && config.jovian.steamos.enableMesaPatches;
in
{
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
      amdgpu = mkIf (architecture.gpu == "amd") {
        amdvlk = {
          enable = true;
          support32Bit.enable = true;
        };

        initrd.enable = true;
      };

      graphics = {
        enable = true;
        extraPackages =
          with pkgs;
          [
            libva
          ]
          ++ optionals (!hasJovianMesa) [ mesa ]
          ++ optionals (architecture.gpu == "amd") [ amdvlk ]
          ++ optionals (architecture.cpu == "intel") [
            vpl-gpu-rt
            intel-media-driver # LIBVA_DRIVER_NAME=iHD
            intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
            intel-compute-runtime
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

    boot.kernelParams = optionals (architecture.cpu == "intel") [ "i915.enable_guc=2" ];

    environment.systemPackages = with pkgs; [ nvtopPackages.full ];
  };
}
