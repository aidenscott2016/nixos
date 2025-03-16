params@{ lib, pkgs, config, ... }:
with lib;
let moduleName = "darkman";
in {
  options = { aiden.modules.darkman.enabled = mkEnableOption moduleName; };
  config = mkIf config.aiden.modules.darkman.enabled {

    environment.pathsToLink =
      [ "/share/xdg-desktop-portal" "/share/applications" ];

    home-manager.users.aiden = {
      aiden.modules."${moduleName}".enabled = true;
    };
  };

}
