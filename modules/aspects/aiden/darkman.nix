{ ... }:
{
  aiden.darkman.nixos = { pkgs, ... }: {
    environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];

    services.geoclue2 = {
      enable = true;
      enableWifi = false;
      appConfig.darkman = {
        isAllowed = true;
        isSystem = true;
      };
    };

    environment.etc = {
      "geolocation".text = ''
        51.0   # latitude
        -1.0   # longitude
        96     # altitude
        1.83   # accuracy radius
      '';

      "geoclue/conf.d/00-config.conf".text = ''
        [static-source]
        enable=true
      '';
    };

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

    home-manager.users.aiden = {
      services.darkman = {
        enable = true;
        settings.usegeoclue = true;
      };
    };
  };
}
