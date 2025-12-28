{ nd, ... }: {
  nd.flatpak = {
    nixos =
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.narrowdivergent.aspects.flatpak;
in
{
  options.narrowdivergent.aspects.flatpak = {
    enable = mkEnableOption "flatpak";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;

    narrowdivergent.aspects.xdg-portal.enable = true;

    # Link necessary paths for flatpak
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
  };
}
;
  };
}
