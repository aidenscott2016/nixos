{ nd, ... }: {
  nd.darkman = {
    includes = [
      nd.geoclue
      nd.xdg-portal
    ];

    nixos =
{
  lib,
  pkgs,
  config,
  ...
}:
{

  config = {
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

    narrowdivergent.aspects.geoclue.apps.darkman = {
      isAllowed = true;
      isSystem = true;
    };

    # The darkman service comes from home-manager
    home-manager.users.aiden = {
      narrowdivergent.aspects.darkman.enable = true;
    };
  };
}
;
  };
}
