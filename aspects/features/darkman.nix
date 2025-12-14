{ lib, ... }:
{
  flake.nixosModules.darkman = { config, lib, ... }:
    with lib;
    let cfg = config.aiden.modules.darkman;
    in {
      options.aiden.modules.darkman.enable = mkEnableOption "darkman";

      config = mkIf cfg.enable {
        environment.pathsToLink = [
          "/share/xdg-desktop-portal"
          "/share/applications"
        ];

        aiden.modules.xdg-portal.enable = false;
        aiden.modules.geoclue = {
          enable = true;
          apps.darkman = {
            isAllowed = true;
            isSystem = true;
          };
        };

        # The darkman service comes from home-manager
        home-manager.users.aiden = {
          aiden.modules.darkman.enable = true;
        };
      };
    };

  flake.homeManagerModules.darkman = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.darkman;
    in {
      options.aiden.modules.darkman.enable = mkEnableOption "darkman home configuration";

      config = mkIf cfg.enable {
        aiden.modules.xdg-portal.enable = true;
        xdg.portal = {
          config.common = {
            "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
          };
          extraPortals = [ pkgs.darkman ];
        };

        services.darkman = {
          enable = true;
          settings.usegeoclue = true;
        };
      };
    };
}
