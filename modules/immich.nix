{ ... }:
{
  flake.modules.nixos.immich =
    { lib, pkgs, config, ... }:
    {
      services.immich = {
        enable = true;
        host = "0.0.0.0";
        port = 2283;
        mediaLocation = "/media/t7/photos";
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
        "d /media/t7/photos 0770 immich immich -"
      ];
    };
}
