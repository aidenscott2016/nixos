{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../geoclue/default.nix
    ../xdg-portal/default.nix
  ];

  config = {
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

    aiden.modules.xdg-portal.enable = false;
    aiden.modules.geoclue.apps.darkman = {
      isAllowed = true;
      isSystem = true;
    };

    # The darkman service comes from home-manager
    home-manager.users.aiden = {
      aiden.modules.darkman.enable = true;
    };
  };
}
