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
        accelerationDevices = [ "/dev/dri/renderD128" ];
        environment = {
          LIBVA_DRIVER_NAME = "iHD";
          LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
        };
        machine-learning.enable = false;
      };

      virtualisation.oci-containers.containers.immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:release-openvino";
        volumes = [ "/var/cache/immich:/cache" ];
        ports = [ "127.0.0.1:3003:3003" ];
        extraOptions = [ "--device=/dev/dri/renderD128" ];
        environment = {
          MPLCONFIGDIR = "/cache/matplotlib";
          MACHINE_LEARNING_WORKERS = "2";
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
