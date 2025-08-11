params@{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  deviceParams = map (path: "--device=${path}") config.aiden.modules.home-assistant.devices;
  enable = config.aiden.modules.home-assistant.enable;
  inherit (config.aiden.modules.common) domainName email;
  fqdn = "hass.${domainName}";
  container-name = "home-assistant";
  service-name = "${config.virtualisation.oci-containers.backend}-${container-name}";
in
{
  options.aiden.modules.home-assistant = {
    enable = mkEnableOption "home-assistant";
    devices = mkOption {
      type = with types; listOf str;
      example = [
        "/dev/serial/by-id/usb-Nabu_Casa_SkyConnect_v1.0_2ee577279f96ed119403c098a7669f5d-if00-port0"
      ];
      description = "A list of devices to mount in the HA image";
      default = [ ];
    };
  };
  config = mkIf enable {
    systemd.services.${service-name}.after = [ "traefik.service" ];
    networking.hosts."10.0.1.1" = [ fqdn ];

    virtualisation.podman.dockerSocket.enable = true;
    virtualisation.podman.dockerCompat = true;
    virtualisation.oci-containers = {
      backend = "podman";
      containers.${container-name} = {
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "Europe/London";
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.hass.rule" = "Host(`${fqdn}`)";
          "traefik.http.routers.hass.tls" = "true";
          "traefik.http.services.hass.loadbalancer.server.url" = "http://10.0.0.1:8123";
          #"traefik.http.services.hass.loadbalancer.server.port" = "8123";
          "traefik.http.routers.hass.entrypoints" = "websecure";
        };
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [ "--network=host" ] ++ deviceParams;
      };
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.homeassistant = {
            acl = [ "readwrite #" ];
            hashedPasswordFile = config.age.secrets.mosquittoPass.path;
          };
        }
      ];
    };

    # services.traefik = {
    #   dynamicConfigOptions = {
    #     http.routers.hass.service = "hass";
    #     http.routers.hass.entrypoints = "websecure";
    #     http.routers.hass.rule = "Host(`${fqdn}`)";
    #     http.routers.hass.tls = "true";
    #     "http.services.hass.loadbalancer.server.url" = "10.0.0.1";
    #     "http.services.hass.loadbalancer.server.port" = "8123";
    #   };
    # };
  };
}
