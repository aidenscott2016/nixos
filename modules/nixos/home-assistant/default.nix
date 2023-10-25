params@{ pkgs, lib, config, ... }:
with lib.aiden;
enableableModule "home-assistant" params {
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/London";
      image =
        "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [ "--network=host" ];
    };
  };
}
