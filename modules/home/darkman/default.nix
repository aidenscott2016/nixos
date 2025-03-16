params@{ lib, pkgs, config, ... }:
with lib;
let moduleName = "darkman";
in {
  options = { aiden.modules.darkman.enabled = mkEnableOption moduleName; };
  config = mkIf config.aiden.modules.darkman.enabled {
    # required in system config
    # environment.pathsToLink =[ "/share/xdg-desktop-portal" "/share/applications" ];
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = "gtk";
          "org.freedesktop.impl.portal.Settings" = "darkman";

          # what's this for?
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      };
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.darkman ];
      xdgOpenUsePortal = true;
    };

    services.darkman = {
      enable = true;
      settings.usegeoclue = true;
    };
  };
}
