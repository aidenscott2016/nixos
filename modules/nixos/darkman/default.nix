params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  moduleName = "darkman";
in
{
  options = {
    aiden.modules.darkman.enable = mkEnableOption moduleName;
  };
  config = mkIf config.aiden.modules.darkman.enable {
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

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
}
