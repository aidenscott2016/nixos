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
    };

  flake.modules.homeManager.darkman =
    { lib, pkgs, config, ... }:
    with lib;
    {
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
}
