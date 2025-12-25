{ aiden, ... }:
{
  aiden.home.darkman = {
    includes = [ aiden.home.xdg-portal ];

    nixos = { pkgs, ... }: {
      home-manager.users.aiden = {
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
  };
}
