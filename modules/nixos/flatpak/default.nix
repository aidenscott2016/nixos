{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.narrowdivergent.modules.flatpak;
in
{
  options.narrowdivergent.modules.flatpak = {
    enable = mkEnableOption "flatpak";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    narrowdivergent.modules.xdg-portal.enable = true;

    # Link necessary paths for flatpak
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
  };
}
