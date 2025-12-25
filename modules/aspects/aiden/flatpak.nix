{ aiden, ... }:
{
  aiden.flatpak = {
    includes = [
      aiden.xdg-portal
    ];

    nixos =
      { pkgs, lib, config, ... }:
      with lib;
      let
        cfg = config.aiden.aspects.flatpak or { };
      in
      {
        options.aiden.aspects.flatpak = {
          enable = mkEnableOption "Flatpak support";
        };

        config = mkIf (cfg.enable or false) {
          services.flatpak.enable = true;

          # Link necessary paths for flatpak
          environment.pathsToLink = [
            "/share/xdg-desktop-portal"
            "/share/applications"
          ];
        };
      };
  };
}
