{ ... }:
{
  flake.modules.nixos.immich-ml =
    { lib, pkgs, config, ... }:
    {
      virtualisation.docker.enable = true;
      virtualisation.oci-containers.backend = "docker";

      virtualisation.oci-containers.containers.immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:release-rocm";
        volumes = [ "/var/cache/immich-ml:/cache" ];
        ports = [ "0.0.0.0:3003:3003" ];
        extraOptions = [
          "--device=/dev/kfd"
          "--device=/dev/dri"
          "--group-add=video"
          "--group-add=render"
          "--security-opt=seccomp=unconfined"
        ];
        environment = {
          MPLCONFIGDIR = "/cache/matplotlib";
          MACHINE_LEARNING_WORKERS = "2";
          MACHINE_LEARNING_MODEL_TTL = "300";
        };
      };

      networking.firewall.allowedTCPPorts = [ 3003 ];

      systemd.tmpfiles.rules = [
        "d /var/cache/immich-ml 0755 root root -"
      ];
    };
}
