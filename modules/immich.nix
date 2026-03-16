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

      # Upstream sets UMask = "0077", which would make new files/dirs unreadable by the
      # immich group. Override to 0027 so the group bit is preserved on everything
      # immich writes, allowing the restic backup user (a member of the immich group)
      # to read the photo library without ACLs.
      systemd.services.immich-server.serviceConfig.UMask = lib.mkForce "0027";
      systemd.services.immich-machine-learning.serviceConfig.UMask = lib.mkForce "0027";

      # Upstream's tmpfiles `e` rule resets the mediaLocation to mode 0700 on every
      # boot. Override it to 0750 so the group read bit isn't stripped.
      systemd.tmpfiles.settings.immich."/media/t7/photos".e.mode = lib.mkForce "0750";

      systemd.tmpfiles.rules = [
        # Create the media directory with group-readable permissions on first boot.
        "d /media/t7/photos 0750 immich immich -"
      ];
    };
}
