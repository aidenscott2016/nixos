params@{ lib, pkgs, config, ... }:
with lib;
let moduleName = "darkman";
in {
  options = { aiden.modules.darkman.enabled = mkEnableOption moduleName; };
  config = mkIf config.aiden.modules.darkman.enabled {
    environment.pathsToLink =
      [ "/share/xdg-desktop-portal" "/share/applications" ];

    aiden.modules.geoclue = {
      enabled = true;
      apps.darkman = {
        isAllowed = true;
        isSystem = true;
      };
    };

    # The darkman service comes from home-manager
    home-manager.users.aiden = {
      aiden.modules.darkman.enabled = true;
    };
  };
}
