{
  aiden.xdg-portal.nixos =
    { pkgs, lib, config, ... }:
    with lib;
    let
      cfg = config.aiden.aspects.xdg-portal or { };
    in
    {
      options.aiden.aspects.xdg-portal = {
        enable = mkEnableOption "XDG portal configuration";
      };

      config = mkIf (cfg.enable or false) {
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
            darkman
          ];
          xdgOpenUsePortal = true;
        };
      };
    };
}
