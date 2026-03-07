{ inputs, ... }:
{
  flake.modules.nixos.darkman =
    { lib, pkgs, config, ... }:
    with lib;
    {
      imports = [ inputs.self.modules.nixos.geoclue ];

      environment.pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];
      aiden.modules.geoclue = {
        apps.darkman = {
          isAllowed = true;
          isSystem = true;
        };
      };
      xdg.portal = {
        extraPortals = [ pkgs.darkman ];
        config.common."org.freedesktop.impl.portal.Settings" = [ "darkman" ];
      };
    };

  flake.modules.homeManager.darkman =
    { ... }:
    {
      services.darkman = {
        enable = true;
        settings.usegeoclue = true;
      };
    };
}
