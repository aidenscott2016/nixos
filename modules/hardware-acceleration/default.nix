{ config, lib, pkgs, ... }:
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

      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          mesa
          libva
        ] ++ optional (architecture.gpu == "amd") amdvlk
          ++ cfg.extraPackages;
      };
    };

    services.xserver = mkIf config.services.xserver.enable {
      videoDrivers = singleton (
        if architecture.gpu == "amd" then "amdgpu"
        else if architecture.gpu == "intel" then "intel"
        else "nvidia"
      );
    };
  };
}
