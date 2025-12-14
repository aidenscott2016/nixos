{ lib, ... }:
{
  flake.nixosModules.xdg-portal = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.xdg-portal;
    in {
      options.aiden.modules.xdg-portal.enable = mkEnableOption "XDG portal configuration";

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
    };

  flake.homeManagerModules.xdg-portal = { config, lib, pkgs, ... }:
    with lib;
    let cfg = config.aiden.modules.xdg-portal;
    in {
      options.aiden.modules.xdg-portal.enable = mkEnableOption "XDG portal configuration";

      # required in system config
      # environment.pathsToLink =[ "/share/xdg-desktop-portal" "/share/applications" ];

      config = mkIf cfg.enable {
        xdg.portal = {
          enable = true;
          config.common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secrets" = [ "none" ];
            "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
          };
          extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
          xdgOpenUsePortal = true;
        };
      };
    };
}
