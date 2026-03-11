{ ... }:
{
  flake.modules.nixos.immich =
    { lib, pkgs, config, ... }:
    {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        port = 2283;
        mediaLocation = "/srv/media/photos";
        openFirewall = false;
        accelerationDevices = null;
        environment = {
          LIBVA_DRIVER_NAME = "iHD";
        };
      };

      users.users.immich = {
        extraGroups = [ "video" "render" "media" ];
      };

      systemd.tmpfiles.rules = [
        "d /srv/media/photos 0770 immich media -"
      ];
    };
}
