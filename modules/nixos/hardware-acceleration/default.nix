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
      intel-gpu-tools.enable = true;
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
            mesa
          ]
          ++ optionals (architecture.gpu == "amd") [ amdvlk ]
          ++ optionals (architecture.cpu == "intel") [
            #intel-compute-runtime
            intel-media-driver-stable # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
            libva-vdpau-driver # Previously vaapiVdpau
            # # OpenCL support for intel CPUs before 12th gen
            # # see: https://github.com/NixOS/nixpkgs/issues/356535
            intel-compute-runtime-legacy1
            vpl-gpu-rt # QSV on 11th gen or newer
            intel-ocl # OpenCL support
            onevpl-intel-gpu
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
}
