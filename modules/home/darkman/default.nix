params@{ lib, pkgs, config, ... }:
with lib;
let moduleName = "darkman";
in {
  options = { aiden.modules.darkman.enable = mkEnableOption moduleName; };
  config = mkIf config.aiden.modules.darkman.enable {
    # required in system config
    # environment.pathsToLink =[ "/share/xdg-desktop-portal" "/share/applications" ];
    xdg.portal = {
      extraPortals = [ pkgs.darkman ];
    };

    services.darkman = {
      enable = true;
      settings.usegeoclue = true;
    };
  };
}
