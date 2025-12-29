{ nd, ... }: {
  nd.xdg-portal = {
    nixos =
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.narrowdivergent.aspects.xdg-portal;
in
{
  options.narrowdivergent.aspects.xdg-portal = {
    enable = mkEnableOption "XDG portal configuration";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      config.common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secrets" = [ "none" ];
        "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        pkgs.darkman
      ];
      xdgOpenUsePortal = true;
    };
  };
}
;
  };
}
