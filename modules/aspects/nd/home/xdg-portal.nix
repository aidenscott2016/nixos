{ nd, ... }: {
  nd.home.xdg-portal = {
    homeManager = { config, lib, pkgs, ... }: {
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
