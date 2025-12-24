{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.aiden.modules.flatpak;
in
{
  options.aiden.modules.flatpak = {
    enable = mkEnableOption "flatpak";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    aiden.modules.xdg-portal.enable = true;

    # Link necessary paths for flatpak
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
  };
}
