{ lib, ... }:
{
  flake.modules.nixos.flatpak = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.flatpak;
    in {
      options.aiden.modules.flatpak.enable = mkEnableOption "flatpak";

      config = mkIf cfg.enable {
        services.flatpak.enable = true;

        aiden.modules.xdg-portal.enable = true;

        environment.pathsToLink = [
          "/share/xdg-desktop-portal"
          "/share/applications"
        ];
      };
    };
}
