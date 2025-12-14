{ lib, ... }:
{
  flake.nixosModules.ios = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.ios;
    in {
      options.aiden.modules.ios.enable = mkEnableOption "ios";

      config = mkIf cfg.enable {
        services.usbmuxd = {
          enable = true;
        };

        environment.systemPackages = with pkgs; [
          libheif
          libimobiledevice
          ifuse
        ];
      };
    };
}
