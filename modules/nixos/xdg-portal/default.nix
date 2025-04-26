{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.aiden.modules.xdg-portal;
in
{
  options.aiden.modules.xdg-portal = {
    enable = mkEnableOption "XDG portal configuration";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      config.common = {
        default = "*";
      };
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      xdgOpenUsePortal = true;
    };
  };
}
