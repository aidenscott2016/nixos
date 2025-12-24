params@{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  modulename = "darkman";
in
{
  options = {
    aiden.modules.darkman.enable = mkEnableOption modulename;
  };
  config = mkIf config.aiden.modules.darkman.enable {
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
}
