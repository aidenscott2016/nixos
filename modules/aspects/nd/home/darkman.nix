{ nd, ... }: {
  nd.home.darkman = {
    includes = [ nd.home.xdg-portal ];

    homeManager = { config, lib, pkgs, ... }: {
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
  };
}
